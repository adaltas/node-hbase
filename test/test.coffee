
hbase = require '../src'
fs = require 'fs'
path = require 'path'
assert = require 'assert'

module.exports.getClient = (options, callback) ->
  if arguments.length is 1
    callback = options
    options = {}
  try
    properties = require "#{__dirname}/properties"
  catch e
    console.log 'Please set a "properties" module inside the "./test" folder (look at properties.*.sample)'
    properties = {}
  for k, v of properties
    options[k] ?= properties[k]
  options.encoding ?= 'utf8'
  client = hbase options
  table = client.getTable('node_table')
  table.exists (error, exists) ->
    assert.ifError error
    return callback(error, client, options) if exists
    table.create
      ColumnSchema: [{
        name: 'node_column_family'
        VERSIONS: 5
      }]
    , (error, success) ->
      callback error, client, options
