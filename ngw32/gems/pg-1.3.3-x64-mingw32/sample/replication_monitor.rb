# -*- ruby -*-
# vim: set noet nosta sw=4 ts=4 :
#
# Get the current WAL segment and offset from a master postgresql
# server, and compare slave servers to see how far behind they
# are in MB.  This script should be easily modified for use with
# Nagios/Mon/Monit/Zabbix/whatever, or wrapping it in a display loop,
# and is suitable for both WAL shipping or streaming forms of replication.
#
# Mahlon E. Smith <mahlon@martini.nu>
#
# First argument is the master server, all other arguments are treated
# as slave machines.
#
#	db_replication.monitor db-master.example.com ...
#

require 'ostruct'
require 'optparse'
require 'pathname'
require 'etc'
require 'pg'
require 'pp'

### A class to encapsulate the PG handles.
###
class PGMonitor
  VERSION = 'Id'.freeze

  # When to consider a slave as 'behind', measured in WAL segments.
  # The default WAL segment size is 16, so we'll alert after
  # missing two WAL files worth of data.
  #
  LAG_ALERT = 32

  ### Create a new PGMonitor object.
  ###
  def initialize(opts, hosts)
    @opts        = opts
    @master      = hosts.shift
    @slaves      = hosts
    @current_wal = {}
    @failures    = []
  end

  attr_reader :opts, :current_wal, :master, :slaves, :failures

  ### Perform the connections and check the lag.
  ###
  def check
    # clear prior failures, get current xlog info
    @failures = []
    return unless get_current_wal

    # check all slaves
    slaves.each do |slave|
      slave_db = PG.connect(
        dbname: opts.database,
        host: slave,
        port: opts.port,
        user: opts.user,
        password: opts.pass,
        sslmode: 'prefer'
      )

      xlog = slave_db.exec('SELECT pg_last_xlog_receive_location()').getvalue(0, 0)
      slave_db.close

      lag_in_megs = (find_lag(xlog).to_f / 1024 / 1024).abs
      if lag_in_megs >= LAG_ALERT
        failures << { host: slave,
                      error: format('%0.2fMB behind the master.', lag_in_megs) }
      end
    rescue StandardError => e
      failures << { host: slave, error: e.message }
    end
  end

  #########
  protected

  #########

  ### Ask the master for the current xlog information, to compare
  ### to slaves.  Returns true on success.  On failure, populates
  ### the failures array and returns false.
  ###
  def get_current_wal
    master_db = PG.connect(
      dbname: opts.database,
      host: master,
      port: opts.port,
      user: opts.user,
      password: opts.pass,
      sslmode: 'prefer'
    )

    current_wal[ :segbytes ] = master_db.exec('SHOW wal_segment_size')
                                        .getvalue(0, 0).sub(/\D+/, '').to_i << 20

    current = master_db.exec('SELECT pg_current_xlog_location()').getvalue(0, 0)
    current_wal[:segment], current_wal[:offset] = current.split(%r{/})

    master_db.close
    true

  # If we can't get any of the info from the master, then there is no
  # point in a comparison with slaves.
  #
  rescue StandardError => e
    failures << { host: master,
                  error: format('Unable to retrieve required info from the master (%s)', e.message) }

    false
  end

  ### Given an +xlog+ position from a slave server, return
  ### the number of bytes the slave needs to replay before it
  ### is caught up to the master.
  ###
  def find_lag(xlog)
    s_segment, s_offset = xlog.split(%r{/})
    m_segment  = current_wal[:segment]
    m_offset   = current_wal[:offset]
    m_segbytes = current_wal[:segbytes]

    ((m_segment.hex - s_segment.hex) * m_segbytes) + (m_offset.hex - s_offset.hex)
  end
end

### Parse command line arguments.  Return a struct of global options.
###
def parse_args(args)
  options = OpenStruct.new
  options.database = 'postgres'
  options.port     = 5432
  options.user     = Etc.getpwuid(Process.uid).name
  options.sslmode  = 'prefer'

  opts = OptionParser.new do |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} [options] <master> <slave> [slave2, slave3...]"

    opts.separator ''
    opts.separator 'Connection options:'

    opts.on('-d', '--database DBNAME',
            "specify the database to connect to (default: \"#{options.database}\")") do |db|
      options.database = db
    end

    opts.on('-h', '--host HOSTNAME', 'database server host') do |host|
      options.host = host
    end

    opts.on('-p', '--port PORT', Integer,
            "database server port (default: \"#{options.port}\")") do |port|
      options.port = port
    end

    opts.on('-U', '--user NAME',
            "database user name (default: \"#{options.user}\")") do |user|
      options.user = user
    end

    opts.on('-W', 'force password prompt') do |_pw|
      print 'Password: '
      begin
        system 'stty -echo'
        options.pass = $stdin.gets.chomp
      ensure
        system 'stty echo'
        puts
      end
    end

    opts.separator ''
    opts.separator 'Other options:'

    opts.on_tail('--help', 'show this help, then exit') do
      warn opts
      exit
    end

    opts.on_tail('--version', 'output version information, then exit') do
      puts PGMonitor::VERSION
      exit
    end
  end

  opts.parse!(args)
  options
end

if __FILE__ == $PROGRAM_NAME
  opts = parse_args(ARGV)
  raise ArgumentError, 'At least two PostgreSQL servers are required.' if ARGV.length < 2

  mon = PGMonitor.new(opts, ARGV)

  mon.check
  if mon.failures.empty?
    puts 'All is well!'
    exit 0
  else
    puts 'Database replication delayed or broken.'
    mon.failures.each do |bad|
      puts format('%s: %s', bad[:host], bad[:error])
    end
    exit 1
  end
end
