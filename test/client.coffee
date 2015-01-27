
should = require 'should'
hbase = require '..'
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
  it 'Test', (next) ->
    @timeout 0
    # Hopefully, 456789 isnt used, might worth checking it with `nc`
    hbase( host: 'localhost', port: 456789 )
    .version_cluster (err, versionCluster) ->
      err.should.be.an.instanceof Error
      next()
