# -*- ruby -*-

require 'pg'
require 'stringio'

# Using COPY asynchronously

warn 'Opening database connection ...'
conn = PG.connect(dbname: 'test')
conn.setnonblocking(true)

socket = conn.socket_io

warn 'Running COPY command ...'
buf = ''
conn.transaction do
  conn.send_query('COPY logs TO STDOUT WITH csv')
  buf = nil

  # #get_copy_data returns a row if there's a whole one to return, false
  # if there isn't one but the COPY is still running, or nil when it's
  # finished.
  loop do
    warn 'COPY loop'
    conn.consume_input
    while conn.is_busy
      warn '  ready loop'
      select([socket], nil, nil, 5.0) or
        raise 'Timeout (5s) waiting for query response.'
      conn.consume_input
    end

    buf = conn.get_copy_data
    $stdout.puts(buf) if buf
    break if buf.nil?
  end
end

conn.finish
