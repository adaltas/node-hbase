Row = require("./hbase-row")
Scanner = require("./hbase-scanner")
Table = (client, name) ->
  @client = client
  @name = name


#myTable.create([schema], [callback])
Table::create = (schema, callback) ->
  self = this
  args = Array::slice.call(arguments_)
  schema = (if args.length and typeof args[0] is "object" or typeof args[0] is "string" then args.shift() else {})
  callback = (if args.length then args.shift() else null)
  schema.name = @name
  schema = ColumnSchema: [name: schema]  if typeof schema is "string"
  @client.connection.put "/" + @name + "/schema", schema, (error, data) ->
    unless callback
      if error
        throw error
      else
        return
    callback.apply self, [error, (if error then null else true)]



# myTable.delete([callback])
Table::delete = (callback) ->
  self = this
  @client.connection.delete "/" + @name + "/schema", (error, data) ->
    unless callback
      if error
        throw error
      else
        return
    callback.apply self, [error, (if error then null else true)]



#myTable.exists(callback)
Table::exists = (callback) ->
  self = this
  @client.connection.get "/" + @name + "/exists", (error, exists) ->
    if error and error.code is 404
      error = null
      exists = false
    callback.apply self, [error, (if error then null else (exists isnt false))]



#myTable.update(schema, [callback])
Table::update = (schema, callback) ->
  self = this
  schema.name = @name
  @client.connection.post "/" + @name + "/schema", schema, (error, data) ->
    unless callback
      if error
        throw error
      else
        return
    callback.apply self, [error, (if error then null else true)]



#myTable.getSchema(callback)
Table::getSchema = (callback) ->
  self = this
  @client.connection.get "/" + @name + "/schema", (error, data) ->
    callback.apply self, [error, (if error then null else data)]



#myTable.getRegions(callback)
Table::getRegions = (callback) ->
  self = this
  @client.connection.get "/" + @name + "/regions", (error, data) ->
    callback.apply self, [error, (if error then null else data)]



#myTable.getRow(key)
Table::getRow = (key) ->
  new Row(@client, @name, key)


#myTable.getScanner(key)
Table::getScanner = (id) ->
  new Scanner(@client, @name, id)

module.exports = Table