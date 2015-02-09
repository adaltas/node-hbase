
should = require 'should'
test = require './test'
# Scanner = require '../src/scanner'

describe 'scanner', ->
  @timeout 0
  it 'stream readable', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row()
      .put [
        { key:'test_scanner_stream_readable_1', column:'node_column_family:', $:'v 1.3' }
        { key:'test_scanner_stream_readable_11', column:'node_column_family:', $:'v 1.1' }
        { key:'test_scanner_stream_readable_111', column:'node_column_family:', $:'v 1.2' }
        { key:'test_scanner_stream_readable_2', column:'node_column_family:', $:'v 2.2' }
      ], (err, success) ->
        return next err if err
        scanner = client
        .table('node_table')
        .scan
          startRow: 'test_scanner_get_startRow_11'
          maxVersions: 1
        rows = []
        scanner.on 'readable', ->
          while chunk = scanner.read()
            rows.push chunk
        scanner.on 'error', (err) ->
          next err
        scanner.on 'end', ->
          rows.length.should.be.above 2
          next()
  it 'Get startRow', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row()
      .put [
        { key:'test_scanner_get_startRow_1', column:'node_column_family:', $:'v 1.3' }
        { key:'test_scanner_get_startRow_11', column:'node_column_family:', $:'v 1.1' }
        { key:'test_scanner_get_startRow_111', column:'node_column_family:', $:'v 1.2' }
        { key:'test_scanner_get_startRow_2', column:'node_column_family:', $:'v 2.2' }
      ], (err, success) ->
        return next err if err
        client
        .table('node_table')
        .scan
          startRow: 'test_scanner_get_startRow_11'
          maxVersions: 1
        , (err, rows) ->
          return next err if err
          # http:#brunodumon.wordpress.com/2010/02/17/building-indexes-using-hbase-mapping-strings-numbers-and-dates-onto-bytes/
          # Technically, you would set the start row for the scanner to France 
          # and stop the scanning by using a RowFilter with a BinaryPrefixComparator
          rows.length.should.be.above 2
          rows[0].key.should.eql 'test_scanner_get_startRow_11'
          rows[0].column.should.eql 'node_column_family:'
          rows[1].key.should.eql 'test_scanner_get_startRow_111'
          rows[1].column.should.eql 'node_column_family:'
          next()
  it 'Get startRow and endRow', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row()
      .put [
        { key:'test_scanner_get_startEndRow_1', column:'node_column_family:', $:'v 1.3' }
        { key:'test_scanner_get_startEndRow_11', column:'node_column_family:', $:'v 1.1' }
        { key:'test_scanner_get_startEndRow_111', column:'node_column_family:', $:'v 1.2' }
        { key:'test_scanner_get_startEndRow_2', column:'node_column_family:', $:'v 2.2' }
      ], (err, success) ->
        return next err if err
        client
        .table('node_table')
        .scan
          startRow: 'test_scanner_get_startEndRow_11'
          endRow: 'test_scanner_get_startEndRow_2'
          maxVersions: 1
        , (err, rows) ->
          return next err if err
          # http:#brunodumon.wordpress.com/2010/02/17/building-indexes-using-hbase-mapping-strings-numbers-and-dates-onto-bytes/
          # Technically, you would set the start row for the scanner to France 
          # and stop the scanning by using a RowFilter with a BinaryPrefixComparator
          rows.length.should.eql 2
          rows[0].key.should.eql 'test_scanner_get_startEndRow_11'
          rows[0].column.should.eql 'node_column_family:'
          rows[1].key.should.eql 'test_scanner_get_startEndRow_111'
          rows[1].column.should.eql 'node_column_family:'
          next()
  it 'Get columns', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row()
      .put [
        { key:'test_scanner_get_columns_1', column:'node_column_family:c1', $:'v 1.1' }
        { key:'test_scanner_get_columns_1', column:'node_column_family:c2', $:'v 1.2' }
        { key:'test_scanner_get_columns_1', column:'node_column_family:c3', $:'v 1.3' }
        { key:'test_scanner_get_columns_1', column:'node_column_family:c4', $:'v 1.4' }
        { key:'test_scanner_get_columns_2', column:'node_column_family:c1', $:'v 2.1' }
        { key:'test_scanner_get_columns_2', column:'node_column_family:c2', $:'v 2.2' }
        { key:'test_scanner_get_columns_2', column:'node_column_family:c3', $:'v 2.3' }
        { key:'test_scanner_get_columns_2', column:'node_column_family:c4', $:'v 2.4' }
        { key:'test_scanner_get_columns_3', column:'node_column_family:c1', $:'v 3.1' }
        { key:'test_scanner_get_columns_3', column:'node_column_family:c2', $:'v 3.2' }
        { key:'test_scanner_get_columns_3', column:'node_column_family:c3', $:'v 3.3' }
        { key:'test_scanner_get_columns_3', column:'node_column_family:c4', $:'v 3.4' }
      ], (err, success) ->
        return next err if err
        client
        .table('node_table')
        .scan
          startRow: 'test_scanner_get_columns_1'
          endRow: 'test_scanner_get_columns_3'
          maxVersions: 1
          column: ['node_column_family:c4','node_column_family:c2']
        , (err, rows) ->
            return next err if err
            rows.length.should.eql 4
            keys = rows.map (row) -> row.key
            keys.should.eql [ 'test_scanner_get_columns_1',
              'test_scanner_get_columns_1',
              'test_scanner_get_columns_2',
              'test_scanner_get_columns_2' ]
            columns = rows.map (row) -> row.column
            columns.should.eql [ 'node_column_family:c2',
              'node_column_family:c4',
              'node_column_family:c2',
              'node_column_family:c4' ]
            next()
  it 'Option maxVersions', (next) ->
    test.client (err, client) ->
      time = (new Date).getTime()
      client
      .table('node_table')
      .row()
      .put [
        { key:'test_scanner_maxversions_1', column:'node_column_family:c', timestamp: time+1, $:'v 1.1' }
        { key:'test_scanner_maxversions_1', column:'node_column_family:c', timestamp: time+2, $:'v 1.2' }
        { key:'test_scanner_maxversions_1', column:'node_column_family:c', timestamp: time+3, $:'v 1.3' }
        { key:'test_scanner_maxversions_1', column:'node_column_family:c', timestamp: time+4, $:'v 1.4' }
      ], (err, success) ->
        return next err if err
        client
        .table('node_table')
        .scan
          startRow: 'test_scanner_maxversions_1'
          endRow: 'test_scanner_maxversions_11'
          column: 'node_column_family:c'
          maxVersions: 3
        , (err, cells) ->
            return next err if err
            cells.length.should.eql 3
            next()

