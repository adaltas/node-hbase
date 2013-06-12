
should = require 'should'
test = require './test'
Scanner = require '../lib/scanner'

describe 'scanner', ->
  it 'Instance', (next) ->
    test.getClient (err, client) ->
      client.getScanner('node_table').should.be.an.instanceof Scanner
      client.getScanner('node_table', 'my_id').should.be.an.instanceof Scanner
      client.getTable('node_table').getScanner().should.be.an.instanceof Scanner
      client.getTable('node_table').getScanner('my_id').should.be.an.instanceof Scanner
      next()
  it 'Create', (next) ->
    test.getClient (err, client) ->
      client
      .getRow('node_table', null)
      .put [
        { key:'test_scanner_create_1', column:'node_column_family', $:'v 1.3' }
        { key:'test_scanner_create_2', column:'node_column_family', $:'v 1.1' }
        { key:'test_scanner_create_3', column:'node_column_family', $:'v 1.2' }
        { key:'test_scanner_create_4', column:'node_column_family', $:'v 2.2' }
      ], (err, success) ->
        should.not.exist err
        client
        .getScanner('node_table')
        .create (err, id) ->
          should.not.exist err
          id.should.match /\w+/
          id.should.eql this.id
          this.delete next
  it 'Get startRow', (next) ->
    test.getClient (err, client) ->
      client
      .getRow('node_table')
      .put [
        { key:'test_scanner_get_startRow_1', column:'node_column_family', $:'v 1.3' }
        { key:'test_scanner_get_startRow_11', column:'node_column_family', $:'v 1.1' }
        { key:'test_scanner_get_startRow_111', column:'node_column_family', $:'v 1.2' }
        { key:'test_scanner_get_startRow_2', column:'node_column_family', $:'v 2.2' }
      ], (err, success) ->
        should.not.exist err
        client
        .getScanner('node_table')
        .create
          startRow: 'test_scanner_get_startRow_11'
          maxVersions: 1
        , (err, id) ->
          should.not.exist err
          this.get (err, rows) ->
            should.not.exist err
            # http:#brunodumon.wordpress.com/2010/02/17/building-indexes-using-hbase-mapping-strings-numbers-and-dates-onto-bytes/
            # Technically, you would set the start row for the scanner to France 
            # and stop the scanning by using a RowFilter with a BinaryPrefixComparator
            rows.length.should.be.above 2
            rows[0].key.should.eql 'test_scanner_get_startRow_11'
            rows[0].column.should.eql 'node_column_family:'
            rows[1].key.should.eql 'test_scanner_get_startRow_111'
            rows[1].column.should.eql 'node_column_family:'
            this.delete next
  it 'Get startRow and endRow', (next) ->
    test.getClient (err, client) ->
      client
      .getRow('node_table')
      .put [
        { key:'test_scanner_get_startEndRow_1', column:'node_column_family', $:'v 1.3' }
        { key:'test_scanner_get_startEndRow_11', column:'node_column_family', $:'v 1.1' }
        { key:'test_scanner_get_startEndRow_111', column:'node_column_family', $:'v 1.2' }
        { key:'test_scanner_get_startEndRow_2', column:'node_column_family', $:'v 2.2' }
      ], (err, success) ->
        should.not.exist err
        client
        .getScanner('node_table')
        .create
          startRow: 'test_scanner_get_startEndRow_11'
          endRow: 'test_scanner_get_startEndRow_2'
          maxVersions: 1
        , (err, id) ->
          should.not.exist err
          this.get (err, rows) ->
            should.not.exist err
            # http:#brunodumon.wordpress.com/2010/02/17/building-indexes-using-hbase-mapping-strings-numbers-and-dates-onto-bytes/
            # Technically, you would set the start row for the scanner to France 
            # and stop the scanning by using a RowFilter with a BinaryPrefixComparator
            rows.length.should.eql 2
            rows[0].key.should.eql 'test_scanner_get_startEndRow_11'
            rows[0].column.should.eql 'node_column_family:'
            rows[1].key.should.eql 'test_scanner_get_startEndRow_111'
            rows[1].column.should.eql 'node_column_family:'
            this.delete next
  it 'Get batch', (next) ->
    test.getClient (err, client) ->
      client
      .getRow('node_table')
      .put [
        { key:'test_scanner_get_batch_1', column:'node_column_family', $:'v 1.3' }
        { key:'test_scanner_get_batch_2', column:'node_column_family', $:'v 1.1' }
        { key:'test_scanner_get_batch_3', column:'node_column_family', $:'v 1.2' }
        { key:'test_scanner_get_batch_4', column:'node_column_family', $:'v 2.2' }
      ], (err, success) ->
        should.not.exist err
        client
        .getScanner('node_table')
        .create
          startRow: 'test_scanner_get_batch_1'
          endRow: 'test_scanner_get_batch_4_'
          batch:1
          maxVersions: 1
        , (err, id) ->
          should.not.exist err
          count = 0
          self = this
          getCallback = (err, cells) ->
            should.not.exist err
            if count is 4
              should.not.exist cells
              return next()
            cells.length.should.eql 1
            count++
            self.get(getCallback)
          this.get(getCallback)
  it 'Get columns', (next) ->
    test.getClient (err, client) ->
      client
      .getRow('node_table')
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
        should.not.exist err
        client
        .getScanner('node_table')
        .create
          startRow: 'test_scanner_get_columns_1'
          endRow: 'test_scanner_get_columns_3'
          maxVersions: 1
          column: ['node_column_family:c4','node_column_family:c2']
          # maxVersions only work if placed before column property
          # maxVersions: 1
        , (err, id) ->
          should.not.exist err
          this.get (err, rows) ->
            should.not.exist err
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
            this.delete next
  it 'Option maxVersions', (next) ->
    test.getClient (err, client) ->
      time = (new Date).getTime()
      client
      .getRow('node_table')
      .put [
        { key:'test_scanner_maxversions_1', column:'node_column_family::c', timestamp: time+1, $:'v 1.1' }
        { key:'test_scanner_maxversions_1', column:'node_column_family::c', timestamp: time+2, $:'v 1.2' }
        { key:'test_scanner_maxversions_1', column:'node_column_family::c', timestamp: time+3, $:'v 1.3' }
        { key:'test_scanner_maxversions_1', column:'node_column_family::c', timestamp: time+4, $:'v 1.4' }
      ], (err, success) ->
        should.not.exist err
        client
        .getScanner('node_table')
        .create
          startRow: 'test_scanner_maxversions_1'
          endRow: 'test_scanner_maxversions_11'
          column: 'node_column_family::c'
          maxVersions: 3
        , (err, id) ->
          should.not.exist err
          this.get (err, cells) ->
            should.not.exist err
            cells.length.should.eql 3
            this.delete next
  it 'should honor batch by returning defined number of record on each call', (next) ->
    test.getClient (err, client) ->
      client
      .getRow('node_table')
      .put [
        { key:'test_scanner_continue_1', column:'node_column_family', $:'v 1.3' }
        { key:'test_scanner_continue_2', column:'node_column_family', $:'v 1.1' }
        { key:'test_scanner_continue_3', column:'node_column_family', $:'v 1.2' }
        { key:'test_scanner_continue_4', column:'node_column_family', $:'v 2.2' }
      ], (err, success) ->
        should.not.exist err
        client
        .getScanner('node_table')
        .create
          startRow: 'test_scanner_continue_1'
          endRow: 'test_scanner_continue_4'
          batch: 2
          maxVersions: 1
        , (err, id) ->
          should.not.exist err
          i = 1
          this.get (err, rows) ->
            should.not.exist err
            # end of scanner
            return this.delete next if rows is null and i is 5
            rows[0].key.should.eql 'test_scanner_continue_' + i
            i += 2
            this.continue()

