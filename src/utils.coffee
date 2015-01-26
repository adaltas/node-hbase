crypto = require 'crypto'

utils =
  base64:
    encode: (string) ->
      (new Buffer string, 'utf8').toString 'base64'

    decode: (string) ->
      (new Buffer string, 'base64').toString 'utf8'
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

module.exports = utils
