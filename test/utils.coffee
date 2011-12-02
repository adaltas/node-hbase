
hbase = require '..'
fs = require 'fs'
path = require 'path'
assert = require 'assert'

module.exports.getClient = (callback) ->
    configFile = "#{__dirname}/properties.json"
    path.exists configFile, (exists) ->
        config = if exists then require configFile else {}
        client = hbase config
        table = client.getTable('node_table')
        table.exists (error, exists) ->
            assert.ifError error
            return callback(error, client, config) if exists
            table.create
                ColumnSchema: [{
                    name: 'node_column_family'
                }]
            , (error, success) ->
                callback error, client, config

