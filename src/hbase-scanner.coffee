utils = require("./hbase-utils")
Table = require("./hbase-table")
Scanner = (client, table, id) ->
  @client = client
  @table = (if typeof table is "string" then table else table.name)
  @id = id or null
  @callback = null


#myScanner.continue()
Scanner::continue = ->
  @get()


#myScanner.create([params], callback)
Scanner::create = (params, callback) ->
  self = this
  args = Array::slice.call(arguments_)
  key = "/" + @table + "/scanner"
  params = (if typeof args[0] is "object" then args.shift() else {})
  callback = args.shift()
  params.startRow = utils.base64.encode(params.startRow)  if params.startRow
  params.endRow = utils.base64.encode(params.endRow)  if params.endRow
  if params.column
    if typeof params.column is "string"
      params.column = utils.base64.encode(params.column)
    else
      params.column.forEach (column, i) ->
        params.column[i] = utils.base64.encode(column)

  if params.filter
    encode = (obj) ->
      for k of obj
        if k is "value" and (not obj["type"] or obj["type"] isnt "RegexStringComparator" and obj["type"] isnt "PageFilter")
          obj[k] = utils.base64.encode(obj[k])
        else encode obj[k]  if typeof obj[k] is "object"

    encode params.filter
    params.filter = JSON.stringify(params.filter)
  console.log params
  @client.connection.put key, params, (error, data, response) ->
    return callback.apply(self, [error, null])  if error
    id = /scanner\/(\w+)$/.exec(response.headers.location)[1]
    self.id = id
    callback.apply self, [null, id]



# myScanner.delete(callback)
Scanner::delete = (callback) ->
  self = this
  key = "/" + @table + "/scanner/" + @id
  @client.connection.delete key, (error, success) ->
    unless callback
      if error
        throw error
      else
        return
    callback.apply self, [error, (if error then null else true)]



# myScanner.get(callback)
Scanner::get = (callback) ->
  self = this
  key = "/" + @table + "/scanner/" + @id
  if callback
    @callback = callback
  else
    callback = @callback
  @client.connection.get key, (error, data, response) ->
    
    # result is successful but the scanner is exhausted, returns HTTP 204 status (no content)
    return callback.apply(self, [null, null])  if response and response.statusCode is 204
    return callback.apply(self, [error, null])  if error
    cells = []
    data.Row.forEach (row) ->
      key = utils.base64.decode(row.key)
      row.Cell.forEach (cell) ->
        data = {}
        data.key = key
        data.column = utils.base64.decode(cell.column)
        data.timestamp = cell.timestamp
        data.$ = utils.base64.decode(cell.$)
        cells.push data


    callback.apply self, [null, cells]


module.exports = Scanner