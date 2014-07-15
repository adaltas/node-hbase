crypto = require 'crypto'

utils =
  base64:
    encode: (string) ->
      (new Buffer string, 'utf8').toString 'base64'

    decode: (string) ->
      (new Buffer string, 'base64').toString 'utf8'
  url:
    encode: (table, key, columns, from, to, params) ->
      args = Array::slice.call arguments
      newpath = '/'
      params = args.pop() if args.length > 3 and typeof args[args.length - 1] is 'object'
      # Table
      newpath += encodeURIComponent args.shift() if args.length
      # Key
      if args.length
        newpath += '/'
        newpath += encodeURIComponent args.shift()
      # Columns
      if args.length
        columnPath = undefined
        columns = args.shift()
        if Array.isArray columns
          columnPath = columns.map( (column) ->
            if Array.isArray(column)
              column.map( (c) ->
                encodeURIComponent c
              ).join ':'
            else
              encodeURIComponent column
          ).join ','
        else if typeof columns is 'object'
          cs = []
          for k of columns
            cs.push "#{encodeURIComponent(k)}:#{encodeURIComponent(columns[k])}"
          columnPath = cs.join ','
        else
          columnPath = if columns then encodeURIComponent columns else ''
        newpath += "/"
        if columnPath
          newpath += "#{columnPath}"
      # From & To
      from = to = null
      from = args.shift()  if args.length
      # To
      to = args.shift()  if args.length
      if to
        newpath += '/'
        if from
          newpath += encodeURIComponent from 
          newpath += ','
        newpath += encodeURIComponent to
      # Params
      if params
        newpath += '?'
        ps = []
        for k of params
          ps.push "#{encodeURIComponent(k)}=#{encodeURIComponent(params[k])}"
        newpath += ps.join ','
      newpath

module.exports = utils
