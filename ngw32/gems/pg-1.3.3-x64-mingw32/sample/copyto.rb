# -*- ruby -*-

require 'pg'
require 'stringio'

# An example of how to stream data to your local host from the database as CSV.

warn 'Opening database connection ...'
conn = PG.connect(dbname: 'test')

warn 'Running COPY command ...'
buf = ''
conn.transaction do
  conn.exec('COPY logs TO STDOUT WITH csv')
  $stdout.puts(buf) while buf = conn.get_copy_data
end

conn.finish
