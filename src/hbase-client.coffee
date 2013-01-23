Connection = require("./hbase-connection")
Table = require("./hbase-table")
Row = require("./hbase-row")
Scanner = require("./hbase-scanner")
Client = (options) ->
  options = {}  unless options
  options.host = "127.0.0.1"  unless options.host
  options.port = "8080"  unless options.port
  options.timeout = 60 * 1000  unless options.timeout
  @options = options
  @connection = new Connection(this)

Client::getVersion = (callback) ->
  @connection.get "/version", callback

Client::getVersionCluster = (callback) ->
  @connection.get "/version/cluster", callback

Client::getStatusCluster = (callback) ->
  @connection.get "/status/cluster", callback

Client::getTables = (callback) ->
  @connection.get "/", (err, data) ->
    callback err, (if data and data.table then data.table else null)


Client::getTable = (name) ->
  new Table(this, name)

Client::getRow = (table, row) ->
  new Row(this, table, row)

Client::getScanner = (table, id) ->
  new Scanner(this, table, id)

module.exports = Client