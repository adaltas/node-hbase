
# Row operations: CRUD operation on rows and columns

Row objects provide access and manipulation on colunns and rows. Single and
multiple operations are available and are documented below.

## Dependencies

    utils = require './utils'
    Table = require './table'

## Constructor

    Row = (client, table, key) ->
      @client = client
      @table = (if typeof table is "string" then table else table.name)
      @key = key
      @

## `row.get`

Retrieve values from HBase or retrieve values from multiple rows.

    Row::get = (column, callback) ->
      args = Array::slice.call(arguments)
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
      url = utils.url.encode table: @table, key: @key, columns: columns, start: start, end: end, params: params
      @client.connection.get url, (error, data) =>
        return args[0].apply(@, [error, null])  if error
        cells = []
        data.Row.forEach (row) =>
          key = utils.base64.decode row.key, @client.options.encoding
          row.Cell.forEach (cell) =>
            data = {}
            data.key = key if isGlob
            data.column = utils.base64.decode cell.column, @client.options.encoding
            data.timestamp = cell.timestamp
            data.$ = utils.base64.decode cell.$, @client.options.encoding
            cells.push data
        args[0].apply @, [null, cells]

## `row.put`

Insert and update a column value, insert and update multiple column values or insert and update multiple rows.

    Row::put = (columns, values, callback) ->
      args = Array::slice.call(arguments)
      url = undefined
      body = undefined
      bodyRow = undefined
      # First argument are columns and second argument are values
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
          key: utils.base64.encode @key, @client.options.encoding
          Cell: []
        columns.forEach (column, i) =>
          bodyCell = {}
          bodyCell.timestamp = timestamps[i]  if timestamps
          bodyCell.column = utils.base64.encode column, @client.options.encoding
          bodyCell.$ = utils.base64.encode values[i], @client.options.encoding
          bodyRow.Cell.push bodyCell
        body.Row.push bodyRow
        url = utils.url.encode table: @table, key: @key or "___false-row-key___", columns: columns
      # First argument is a full object with columns and values
      else
        data = args.shift()
        callback = args.shift()
        body = Row: []
        cellsKeys = {}
        data.forEach (d) =>
          key = d.key or @key
          cellsKeys[key] = []  unless key of cellsKeys
          cellsKeys[key].push d
        for k of cellsKeys
          cells = cellsKeys[k]
          bodyRow =
            key: utils.base64.encode k, @client.options.encoding
            Cell: []
          for k1 of cells
            cell = cells[k1]
            bodyCell = {}
            bodyCell.timestamp = "" + cell.timestamp  if cell.timestamp
            bodyCell.column = utils.base64.encode cell.column, @client.options.encoding
            bodyCell.$ = utils.base64.encode cell.$, @client.options.encoding
            bodyRow.Cell.push bodyCell
          body.Row.push bodyRow
        url = utils.url.encode table: @table, key: @key or "___false-row-key___", columns: ['test:']
      @client.connection.put url, body, (error, data) =>
        return  unless callback
        callback.apply @, [error, (if error then null else true)]

## `row.exists`

Test if a row or a column exists

    Row::exists = (column, callback) ->
      args = Array::slice.call(arguments)
      column = (if typeof args[0] is "string" then args.shift() else null)
      url = utils.url.encode table: @table, key: @key, columns: column
      @client.connection.get url, (error, exists) =>
        # note:
        # if row does not exists: 404
        # if row exists and column family does not exists: 503
        if error and (error.code is 404 or error.code is 503)
          error = null
          exists = false
        args[0].apply @, [error, (if error then null else ((if exists is false then false else true)))]

## `row.delete`

Delete a row or column or delete multiple columns.

    Row::delete = ->
      args = Array::slice.call(arguments)
      columns = undefined
      columns = args.shift()  if typeof args[0] is "string" or (typeof args[0] is "object" and args[0] instanceof Array)
      url = utils.url.encode table: @table, key: @key, columns: columns
      @client.connection.delete url, ((error, success) =>
        args[0].apply @, [error, (if error then null else true)]
      ), true

    module.exports = Row
