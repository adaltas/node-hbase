
http = require 'http'
hbase = require '../src'

server_start = (msg, handler) ->
  server = http.createServer (req, res) ->
    if msg.get
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end msg.get
  server.listen 12345, handler

server_close = (server, callback) ->
  server.close()
  server.on 'close', callback

describe 'connection', ->
  
  it 'send get', (next) ->
    server = server_start get: '"okay"', (err) ->
      return next err if err
      client = hbase.Client host: '127.0.0.1', port: 12345
      client.connection.get '/', (err, data) ->
        return next err if err
        data.should.eql 'okay'
        server_close server, next
  
  it 'honors timeout', (next) ->
    server = server_start {}, (err) ->
      return next err if err
      client = hbase.Client host: '127.0.0.1', port: 12345, timeout: 2000
      client.connection.get '/', (err, data) ->
        err.message.should.eql 'socket hang up'
        server_close server, next
        
