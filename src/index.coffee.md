
# Node Hbase: getting started

    hbase = module.exports = (config) ->
      new hbase.Client config

    hbase.Client = require './client'
    hbase.Connection = require './connection'
    hbase.Table = require './table'
    hbase.Row = require './row'
    hbase.Scanner = require './scanner'
    hbase.utils = require './utils'
