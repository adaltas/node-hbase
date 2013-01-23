utils = require("./hbase-utils")
Table = require("./hbase-table")
Row = (client, table, key) ->
  @client = client
  @table = (if typeof table is "string" then table else table.name)
  @key = key


# myRow.delete([column], [callback])
Row::delete = ->
  self = this
  args = Array::slice.call(arguments_)
  columns = undefined
  columns = args.shift()  if typeof args[0] is "string" or (typeof args[0] is "object" and args[0] instanceof Array)
  url = utils.url.encode(@table, @key, columns)
  @client.connection.delete url, ((error, success) ->
    args[0].apply self, [error, (if error then null else true)]
  ), true


# myRow.exists(column, [callback])
Row::exists = (column, callback) ->
  self = this
  args = Array::slice.call(arguments_)
  column = (if typeof args[0] is "string" then args.shift() else null)
  url = utils.url.encode(@table, @key, column)
  @client.connection.get url, (error, exists) ->
    
    # note:
    # if row does not exists: 404
    # if row exists and column family does not exists: 503
    if error and (error.code is 404 or error.code is 503)
      error = null
      exists = false
    args[0].apply self, [error, (if error then null else ((if exists is false then false else true)))]



# myRow.get([column], [callback])
Row::get = (column, callback) ->
  self = this
  args = Array::slice.call(arguments_)
  key = "/" + @table + "/" + @key
  isGlob = @key.substr(-1, 1) is "*"
  options = {}
  columns = null
  start = null
  end = null
  params = {}
  columns = args.shift()  if typeof args[0] is "string" or (typeof args[0] is "object" and args[0] instanceof Array)
  options = args.shift()  if typeof args[0] is "object"
  start = options.start  if options.start
  end = options.end  if options.end
  params.v = options.v  if options.v
  url = utils.url.encode(@table, @key, columns, start, end, params)
  @client.connection.get url, (error, data) ->
    return args[0].apply(self, [error, null])  if error
    cells = []
    data.Row.forEach (row) ->
      key = utils.base64.decode(row.key)
      row.Cell.forEach (cell) ->
        data = {}
        data.key = key  if isGlob
        data.column = utils.base64.decode(cell.column)
        data.timestamp = cell.timestamp
        data.$ = utils.base64.decode(cell.$)
        cells.push data


    args[0].apply self, [null, cells]



# myRow.put(column(s), value(s), [timestamp(s)], [callback])
# myRow.put(data, [callback])
Row::put = (columns, values, callback) ->
  self = this
  args = Array::slice.call(arguments_)
  url = undefined
  body = undefined
  bodyRow = undefined
  if args.length > 2
    columns = args.shift()
    values = args.shift()
    timestamps = undefined
    timestamps = args.shift()  if typeof args[0] isnt "function"
    callback = args.shift()
    if typeof columns is "string"
      columns = [columns]
      values = [values]
    else throw new Error("Columns count must match values count")  if columns.length isnt values.length
    body = Row: []
    bodyRow =
      key: utils.base64.encode(self.key)
      Cell: []

    columns.forEach (column, i) ->
      bodyCell = {}
      bodyCell.timestamp = timestamps[i]  if timestamps
      bodyCell.column = utils.base64.encode(column)
      bodyCell.$ = utils.base64.encode(values[i])
      bodyRow.Cell.push bodyCell

    body.Row.push bodyRow
    url = utils.url.encode(@table, @key or "___false-row-key___", columns)
  else
    data = args.shift()
    callback = args.shift()
    body = Row: []
    cellsKeys = {}
    data.forEach (d) ->
      key = d.key or self.key
      cellsKeys[key] = []  unless key of cellsKeys
      cellsKeys[key].push d

    for k of cellsKeys
      cells = cellsKeys[k]
      bodyRow =
        key: utils.base64.encode(k)
        Cell: []

      for k1 of cells
        cell = cells[k1]
        bodyCell = {}
        bodyCell.timestamp = "" + cell.timestamp  if cell.timestamp
        bodyCell.column = utils.base64.encode(cell.column)
        bodyCell.$ = utils.base64.encode(cell.$)
        bodyRow.Cell.push bodyCell
      body.Row.push bodyRow
    url = utils.url.encode(@table, @key or "___false-row-key___")
  @client.connection.put url, body, (error, data) ->
    return  unless callback
    callback.apply self, [error, (if error then null else true)]


module.exports = Row