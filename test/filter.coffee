
fs = require 'fs'
should = require 'should'
test = require './test'
hbase = require '../src'

#{"op":"LESS","type":"RowFilter","comparator":{"value":"dGVzdFJvd09uZS0y","type":"BinaryComparator"}}
#{"op":"LESS_OR_EQUAL","type":"RowFilter","comparator":{"value":"dGVzdFJvd09uZS0y","type":"BinaryComparator"}}
#{"op":"NOT_EQUAL","type":"RowFilter","comparator":{"value":"dGVzdFJvd09uZS0y","type":"BinaryComparator"}}
#{"op":"GREATER_OR_EQUAL","type":"RowFilter","comparator":{"value":"dGVzdFJvd09uZS0y","type":"BinaryComparator"}}
#{"op":"GREATER","type":"RowFilter","comparator":{"value":"dGVzdFJvd09uZS0y","type":"BinaryComparator"}}
#{"op":"NOT_EQUAL","type":"RowFilter","comparator":{"value":"dGVzdFJvd09uZS0y","type":"BinaryComparator"}}
#{"op":"EQUAL","type":"RowFilter","comparator":{"value":".+-2","type":"RegexStringComparator"}}
#{"op":"EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlT25l","type":"BinaryComparator"}}
#{"op":"EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlVHdv","type":"BinaryComparator"}}
#{"op":"EQUAL","type":"ValueFilter","comparator":{"value":"testValue((One)|(Two))","type":"RegexStringComparator"}}
#{"op":"LESS","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlVHdv","type":"BinaryComparator"}}
#{"op":"LESS_OR_EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlVHdv","type":"BinaryComparator"}}
#{"op":"LESS_OR_EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlT25l","type":"BinaryComparator"}}
#{"op":"NOT_EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlT25l","type":"BinaryComparator"}}
#{"op":"GREATER_OR_EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlT25l","type":"BinaryComparator"}}
#{"op":"GREATER","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlT25l","type":"BinaryComparator"}}
#{"op":"NOT_EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlT25l","type":"BinaryComparator"}}
#{"type":"SkipFilter","filters":[{"op":"NOT_EQUAL","type":"QualifierFilter","comparator":{"value":"dGVzdFF1YWxpZmllck9uZS0y","type":"BinaryComparator"}}]}
#{"op":"MUST_PASS_ALL","type":"FilterList","filters":[{"op":"EQUAL","type":"RowFilter","comparator":{"value":".+-2","type":"RegexStringComparator"}},{"op":"EQUAL","type":"QualifierFilter","comparator":{"value":".+-2","type":"RegexStringComparator"}},{"op":"EQUAL","type":"ValueFilter","comparator":{"value":"one","type":"SubstringComparator"}}]}
#{"op":"MUST_PASS_ONE","type":"FilterList","filters":[{"op":"EQUAL","type":"RowFilter","comparator":{"value":".+Two.+","type":"RegexStringComparator"}},{"op":"EQUAL","type":"QualifierFilter","comparator":{"value":".+-2","type":"RegexStringComparator"}},{"op":"EQUAL","type":"ValueFilter","comparator":{"value":"one","type":"SubstringComparator"}}]}

describe 'filter', ->
  @timeout 0
  it 'Option filter', (next) ->
    test.client (err, client) ->
      time = (new Date).getTime()
      client
      .table('node_table')
      .row()
      .put [
        {key:'test_filter|row_1', column:'node_column_family:aa', $:'aa'}
        {key:'test_filter|row_1', column:'node_column_family:aa', $:'ab'}
        {key:'test_filter|row_1', column:'node_column_family:aa', $:'ac'}
        {key:'test_filter|row_2', column:'node_column_family:ab', $:'ba'}
        {key:'test_filter|row_2', column:'node_column_family:bb', $:'bb'}
        {key:'test_filter|row_2', column:'node_column_family:bc', $:'bc'}
        {key:'test_filter|row_3', column:'node_column_family:ca', $:'cc'}
        {key:'test_filter|row_3', column:'node_column_family:cb', $:'cc'}
        {key:'test_filter|row_3', column:'node_column_family:cc', $:'cc'}
      ], (err, success) ->
        next err
  it 'FilterList # must_pass_all # +RegexStringComparator', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .scan
        startRow: 'test_filter|row_1'
        maxVersions: 1
        filter: {
          "op":"MUST_PASS_ALL","type":"FilterList","filters":[
            {"op":"EQUAL","type":"RowFilter","comparator":{"value":"test_filter\\|row_.*","type":"RegexStringComparator"}}
            {"op":"EQUAL","type":"RowFilter","comparator":{"value":".+2$","type":"RegexStringComparator"}}
          ]}
      , (err, cells) ->
          return next err if err
          cells.length.should.eql 3
          cells[0].key.should.eql 'test_filter|row_2'
          cells[1].key.should.eql 'test_filter|row_2'
          cells[2].key.should.eql 'test_filter|row_2'
          next()
  it 'FirstKeyOnlyFilter', (next) ->
    test.client (err, client) ->
      # Only return the first KV from each row.
      client
      .table('node_table')
      .scan
        startRow: 'test_filter|row_1'
        filter: {'type':'FirstKeyOnlyFilter'}
      , (err, cells) ->
          return next err if err
          cells.length.should.be.above 2
          cells[0].key.should.eql 'test_filter|row_1'
          cells[1].key.should.eql 'test_filter|row_2'
          cells[2].key.should.eql 'test_filter|row_3'
          next()
  it 'PageFilter # string value', (next) ->
    getKeysFromCells = (cells) ->
      keys = []
      cells.forEach (cell) ->
        if keys.indexOf(cell['key']) is -1
          keys.push cell['key']
      keys
    test.client (err, client) ->
      client
      .table('node_table')
      .scan
        startRow: 'test_filter|row_1'
        endRow: 'test_filter|row_4'
        maxVersions: 1
        filter: {"type":"PageFilter","value":"2"}
      , (err, cells) ->
          return next err if err
          cells.length.should.eql 4
          keys = getKeysFromCells(cells)
          keys.should.eql ['test_filter|row_1','test_filter|row_2']
          next()
  it 'PageFilter # int value', (next) ->
    getKeysFromCells = (cells) ->
      keys = []
      cells.forEach (cell) ->
        if keys.indexOf(cell['key']) is -1
          keys.push cell['key']
      keys
    test.client (err, client) ->
      client
      .table('node_table')
      .scan
        startRow: 'test_filter|row_1'
        endRow: 'test_filter|row_4'
        maxVersions: 1
        filter: {"type":"PageFilter","value":2}
      , (err, cells) ->
          return next err if err
          cells.length.should.eql 4
          keys = getKeysFromCells(cells)
          keys.should.eql ['test_filter|row_1','test_filter|row_2']
          next()
  it 'RowFilter # equal_with_binary_comparator', (next) ->
    test.client (err, client) ->
      # Based on the key
      client
      .table('node_table')
      .scan
        startRow: 'test_filter|row_1'
        maxVersions: 1
        filter: {'op':'EQUAL','type':'RowFilter','comparator':{'value':'test_filter|row_2','type':'BinaryComparator'}}
      , (err, cells) ->
          return next err if err
          cells.length.should.eql 3
          next()
  it 'ValueFilter # op equal', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .scan
        startRow: 'test_filter|row_1'
        endRow: 'test_filter|row_4'
        maxVersions: 1
        filter: {"op":"EQUAL","type":"ValueFilter","comparator":{"value":"bb","type":"BinaryComparator"}}
      , (err, cells) ->
          return next err if err
          cells.length.should.eql 1
          cells[0].key.should.eql 'test_filter|row_2'
          cells[0].column.should.eql 'node_column_family:bb'
          next()
