
should = require 'should'
hbase = require '..'
test = require './test'

describe 'client', ->
  it 'get version', (next) ->
    @timeout 0
    test.getClient (err, client) ->
      client.getVersion (err, version) ->
        should.not.exist err
        keys = Object.keys version
        keys.should.eql ['Server','REST','OS','Jersey','JVM']
        next()
  it 'get version cluster', (next) ->
    @timeout 0
    test.getClient (err, client) ->
      client.getVersionCluster (err, versionCluster) ->
        should.not.exist err
        versionCluster.should.match /^(Unknown)|(\d[\d\.]+)/
        next()
  it 'get status cluster', (next) ->
    @timeout 0
    test.getClient (err, client) ->
      client.getStatusCluster (err,statusCluster) ->
        should.not.exist err
        keys = Object.keys statusCluster
        keys.should.eql ['requests','regions','averageLoad','DeadNodes','LiveNodes']
        next()
  it 'get tables', (next) ->
    @timeout 0
    test.getClient (err, client) ->
      client.getTables (err,tables) ->
        should.not.exist err
        tables.filter( (table) -> table.name is 'node_table' ).length.should.eql 1
        next()
  it 'Test', (next) ->
    @timeout 0
    # Hopefully, 456789 isnt used, might worth checking it with `nc`
    hbase( host: 'localhost', port: 456789 )
    .getVersionCluster (err, versionCluster) ->
      err.should.be.an.instanceof Error
      next()
