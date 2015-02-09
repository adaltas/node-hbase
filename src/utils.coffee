crypto = require 'crypto'

utils =
  base64:
    encode: (data, to_encoding) ->
      return data if to_encoding is 'base64'
      data = new Buffer data, to_encoding or 'utf8' unless Buffer.isBuffer data
      data.toString 'base64'
    decode: (data, from_encoding) ->
      return data if from_encoding is 'base64'
      data = (new Buffer data, 'base64')
      return data unless from_encoding
      data.toString from_encoding
  url:
    ###
    Arguments:
    *   `table`
    *   `key`
    *   `columns`
    *   `start`
    *   `end`
    *   `params`
    ###
    encode: (args) ->
      throw new Error 'Missing parameters "table"' unless args.table
      newpath = '/'
      # params = args.pop() if args.length > 3 and typeof args[args.length - 1] is 'object'
      # Table
      newpath += encodeURIComponent args.table
      # Key
      if args.key
        newpath += '/'
        newpath += encodeURIComponent args.key
      # Columns
      if args.columns
        columnPath = undefined
        if Array.isArray args.columns
          columnPath = args.columns.map( (column) ->
            if Array.isArray(column)
              column.map( (c) ->
                encodeURIComponent c
              ).join ':'
            else
              encodeURIComponent column
          ).join ','
        else if typeof args.columns is 'object'
          cs = []
          for k, v of args.columns
            cs.push "#{encodeURIComponent(k)}:#{encodeURIComponent(v)}"
          columnPath = cs.join ','
        else
          columnPath = if args.columns then encodeURIComponent args.columns else ''
        newpath += "/" if columnPath
        if columnPath
          newpath += "#{columnPath}"
      # From & To
      if args.end
        newpath += '/'
        if args.start
          newpath += encodeURIComponent args.start 
          newpath += ','
        newpath += encodeURIComponent args.end
      # Params
      if args.params
        newpath += '?'
        ps = []
        for k, v of args.params
          ps.push "#{encodeURIComponent(k)}=#{encodeURIComponent(v)}"
        newpath += ps.join ','
      newpath
  merge: () ->
    target = arguments[0]
    from = 1
    to = arguments.length
    if typeof target is 'boolean'
      inverse = !! target
      target = arguments[1]
      from = 2
    # Handle case when target is a string or something (possible in deep copy)
    if typeof target isnt "object" and typeof target isnt 'function'
      target = {}
    for i in [from ... to]
      # Only deal with non-null/undefined values
      if (options = arguments[ i ]) isnt null
        # Extend the base object
        for name of options 
          src = target[ name ]
          copy = options[ name ]
          # Prevent never-ending loop
          continue if target is copy
          # Recurse if we're merging plain objects
          if copy? and typeof copy is 'object' and not Array.isArray(copy) and copy not instanceof RegExp
            clone = src and ( if src and typeof src is 'object' then src else {} )
            # Never move original objects, clone them
            target[ name ] = utils.merge false, clone, copy
          # Don't bring in undefined values
          else if copy isnt undefined
            target[ name ] = copy unless inverse and typeof target[ name ] isnt 'undefined'
    # Return the modified object
    target

module.exports = utils
