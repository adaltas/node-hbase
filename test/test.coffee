
hbase = require '..'
fs = require 'fs'
path = require 'path'
assert = require 'assert'

module.exports.getClient = (callback) ->
  try
    config = require "#{__dirname}/properties"
  catch e
    console.log 'Please set a "properties" module inside the "./test" folder (look at properties.*.sample)'
    config = {}
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
