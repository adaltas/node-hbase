
# Client: server information and object factory

## Dependencies

    util = require 'util'
    EventEmitter = require 'events'
    Connection = require "./connection"
    Table = require "./table"
    Row = require "./row"
    Scanner = require "./scanner"

## Constructor

    Client = (options) ->
      options = {}  unless options
      EventEmitter.call @, @options
      options.protocol ?= 'http'
      options.host ?= '127.0.0.1'
      options.port ?= '8080'
      options.krb5 ?= {}
      options.encoding ?= 'utf8'
      throw Error "Invalid protocol #{JSON.stringify options.protocol}" unless options.protocol in ['http', 'https']
      @options = options
      @connection = new Connection @
      @
    util.inherits Client, EventEmitter

## `client.version`

Query Software Version.

    Client::version = (callback) ->
      @connection.get "/version", callback

## `client.version_cluster`

Query Storage Cluster Version.

    Client::version_cluster = (callback) ->
      @connection.get "/version/cluster", callback

## `client.status_cluster`

Query Storage Cluster Status.

    Client::status_cluster = (callback) ->
      @connection.get "/status/cluster", callback

## `client.tables`

List tables.

    Client::tables = (callback) ->
      @connection.get "/", (err, data) ->
        callback err, (if data and data.table then data.table else null)

## `client.table`

Return a new instance of "hbase.Table".

    Client::table = (name) ->
      new Table(this, name)

    module.exports = Client
