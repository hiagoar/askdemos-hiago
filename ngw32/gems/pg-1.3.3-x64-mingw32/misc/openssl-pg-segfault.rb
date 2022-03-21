# -*- ruby -*-

PGHOST   = 'localhost'.freeze
PGDB     = 'test'.freeze
# SOCKHOST = 'github.com'
SOCKHOST = 'it-trac.laika.com'.freeze

# Load pg first, so the libssl.so that libpq is linked against is loaded.
require 'pg'
warn "connecting to postgres://#{PGHOST}/#{PGDB}"
conn = PG.connect(PGHOST, dbname: PGDB)

# Now load OpenSSL, which might be linked against a different libssl.
require 'socket'
require 'openssl'
warn "Connecting to #{SOCKHOST}"
sock = TCPSocket.open(SOCKHOST, 443)
ctx = OpenSSL::SSL::SSLContext.new
sock = OpenSSL::SSL::SSLSocket.new(sock, ctx)
sock.sync_close = true

# The moment of truth...
warn 'Attempting to connect...'
begin
  sock.connect
rescue Errno
  warn 'Got an error connecting, but no segfault.'
else
  warn 'Nope, no segfault!'
end
