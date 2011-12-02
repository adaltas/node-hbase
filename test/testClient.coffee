
hbase = require '..'
utils = require './utils'
assert = require 'assert'

module.exports =
    'Get version': (next) ->
        utils.getClient (error, client) ->
            client.getVersion (err, version) ->
                assert.ifError err
                keys = Object.keys version
                assert.deepEqual(['Server','REST','OS','Jersey','JVM'],keys)
                next()
    'Get version cluster': (next) ->
        utils.getClient (error, client) ->
            client.getVersionCluster (err, versionCluster) ->
                assert.ifError err
                assert.ok(/^(Unknown)|(\d[\d\.]+)/.test(versionCluster))
                next()
    'Get status cluster': (next) ->
        utils.getClient (error, client) ->
            client.getStatusCluster (err,statusCluster) ->
                assert.ifError err
                keys = Object.keys statusCluster
                assert.deepEqual(['requests','regions','averageLoad','DeadNodes','LiveNodes'],keys)
                next()
    'Get tables': (next) ->
        utils.getClient (error, client) ->
            client.getTables (err,tables) ->
                assert.ifError err
                assert.strictEqual 1, tables.filter( (table) -> table.name is 'node_table' ).length
                next()
    'Test': (next) ->
        # Hopefully, 456789 isnt used, might worth checking it with `nc`
        hbase({host: 'localhost', port: 456789})
        .getVersionCluster (err, versionCluster) ->
            assert.ok err instanceof Error
            next()
