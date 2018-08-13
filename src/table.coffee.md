
# Table operations: create, modify and delete HBase tables

## Dependencies

    Row = require './row'
    Scanner = require './scanner'

## Constructor

    Table = (client, name) ->
      @client = client
      @name = name
      @

## `table.create`

Create a new table in HBase

    Table::create = (schema, callback) ->
      args = Array::slice.call(arguments)
      schema = if args.length and typeof args[0] is 'object' or typeof args[0] is 'string' then args.shift() else {}
      callback = if args.length then args.shift() else null
      schema.name = @name
      schema = ColumnSchema: [name: schema]  if typeof schema is 'string'
      @client.connection.put "/#{@name}/schema", schema, (error, data) =>
        unless callback
          if error
            throw error
          else
            return
        callback.apply @, [error, if error then null else true]

## `table.delete`

Drop an existing table.

    Table::delete = (callback) ->
      @client.connection.delete "/#{@name}/schema", (error, data) =>
        unless callback
          if error
            throw error
          else
            return
        callback.apply @, [error, if error then null else true]

## `table.exists`

Check if a table is created.

```javascript
myTable.exists(calblack);
```

    Table::exists = (callback) ->
      @client.connection.get "/#{@name}/exists", (error, exists) =>
        if error and error.code is 404
          error = null
          exists = false
        callback.apply @, [error, if error then null else (exists isnt false)]

## Update an existing table

NOT YET WORKING, waiting for [HBASE-3140](https://issues.apache.org/jira/browse/HBASE-3140).

    Table::update = (schema, callback) ->
      schema.name = @name
      @client.connection.post "/#{@name}/schema", schema, (error, data) =>
        unless callback
          if error
            throw error
          else
            return
        callback.apply @, [error, if error then null else true]

## `table.schema`

Retrieves table schema.

    Table::schema = (callback) ->
      @client.connection.get "/#{@name}/schema", (error, data) =>
        callback.apply @, [error, if error then null else data]


## `table.regions`

Retrieves table region metadata.

    Table::regions = (callback) ->
      @client.connection.get "/#{@name}/regions", (error, data) =>
        callback.apply @, [error, if error then null else data]

## `table.row`

Return a new row instance.

    Table::row = (key) ->
      new Row @client, @name, key


## `table.scan`

Return a new scanner instance.

    Table::scan = (options, callback) ->
      if arguments.length is 0
        options = {}
      else if arguments.length is 1
        if typeof arguments[0] is 'function'
          callback = options
          options = {}
      else if arguments.length isnt 2
        throw Error 'Invalid arguments'
      options.table = @name
      scanner = new Scanner @client, options
      if callback
        chunks = []
        scanner.on 'readable', ->
          while chunk = scanner.read()
            chunks.push chunk
        scanner.on 'error', (err) ->
          callback err
        scanner.on 'end', ->
          callback null, chunks
      scanner

    module.exports = Table
