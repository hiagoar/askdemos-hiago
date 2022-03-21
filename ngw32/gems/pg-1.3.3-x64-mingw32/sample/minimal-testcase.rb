# -*- ruby -*-

require 'pg'

conn = PG.connect(dbname: 'test')
warn '---',
     RUBY_DESCRIPTION,
     PG.version_string(true),
     "Server version: #{conn.server_version}",
     "Client version: #{PG.library_version}",
     '---'

result = conn.exec('SELECT * from pg_stat_activity')

warn %(Expected this to return: ["select * from pg_stat_activity"])
p result.field_values('current_query')
