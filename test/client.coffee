
hbase = require '../src'
test = require './test'
sort = (a, b) -> if a.toLowerCase() < b.toLowerCase() then -1 else 1

describe 'client', ->
  it 'get version', (next) ->
    @timeout 0
    test.client (err, client) ->
      client.version (err, version) ->
        should.not.exist err
        Object.keys(version)
        .sort(sort)
        .should.eql ['Jersey','JVM','OS','REST','Server']
        next()
  it 'get version cluster', (next) ->
    @timeout 0
    test.client (err, client) ->
      client.version_cluster (err, versionCluster) ->
        should.not.exist err
        versionCluster.should.match /^(Unknown)|(\d[\d\.]+)/
        next()
  it 'get status cluster', (next) ->
    @timeout 0
    test.client (err, client) ->
      client.status_cluster (err,statusCluster) ->
        should.not.exist err
        Object.keys(statusCluster)
        .sort(sort)
        .should.eql ['averageLoad','DeadNodes','LiveNodes','regions','requests']
        next()
  it 'get tables', (next) ->
    @timeout 0
    test.client (err, client) ->
      client.tables (err,tables) ->
        should.not.exist err
        tables.filter( (table) -> table.name is 'node_table' ).length.should.eql 1
        next()
  it 'throw error if port is invalid', (next) ->
    @timeout 0
    # Hopefully, 54321 isnt used, might worth checking it with `nc`
    hbase( host: 'localhost', port: 54321 )
    .version_cluster (err, versionCluster) ->
      err.should.be.an.instanceof Error
      next()
  it 'should pass custom options to connection', (next) ->
    @timeout 0
    connection_opts = hbase(
      protocol: 'https'
      host: 'localhost',
      port: 8080,
      path: '/rest',
      cert: 'test_cert.crt',
      key: 'test_key.key',
      headers: {
        'content-length': 5000
      }
    ).connection.options
    connection_opts.protocol.should.eql 'https:'
    connection_opts.hostname.should.eql 'localhost'
    connection_opts.port.should.eql 8080
    connection_opts.path.should.eql '/rest'
    connection_opts.cert.should.eql 'test_cert.crt'
    connection_opts.key.should.eql 'test_key.key'
    connection_opts.headers.should.eql {
      "Accept": "application/json"
      "content-length": 5000
      "content-type": "application/json"
    }
    next()
  it 'only accept request headers as an object', (next) ->
    @timeout 0
    connection_opts = hbase(
      host: 'localhost',
      port: 8080,
      headers: 'test'
    ).connection.options
    connection_opts.headers.should.eql {
      "Accept": "application/json"
      "content-type": "application/json"
    }
    next()
  it 'should use default request headers when none is passed by the user', (next) ->
    @timeout 0
    connection_opts = hbase(
      host: 'localhost',
      port: 8080
    ).connection.options
    connection_opts.headers.should.eql {
      "Accept": "application/json"
      "content-type": "application/json"
    }
    next()
