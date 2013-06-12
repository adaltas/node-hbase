
fs = require 'fs'
should = require 'should'
test = require './test'
hbase = require '..'
Scanner = require '../lib/scanner'

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
  it 'Option filter', (next) ->
    test.getClient (err, client) ->
      time = (new Date).getTime()
      client
      .getRow('node_table')
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
        should.not.exist err
        next()
  it 'FilterList # must_pass_all # +RegexStringComparator', (next) ->
    test.getClient (err, client) ->
      client
      .getScanner('node_table')
      .create
        startRow: 'test_filter|row_1'
        maxVersions: 1
        filter: {
          "op":"MUST_PASS_ALL","type":"FilterList","filters":[
            {"op":"EQUAL","type":"RowFilter","comparator":{"value":"test_filter\\|row_.*","type":"RegexStringComparator"}}
            {"op":"EQUAL","type":"RowFilter","comparator":{"value":".+2$","type":"RegexStringComparator"}}
          ]}
      , (err, id) ->
        should.not.exist err
        this.get (err,cells) ->
          should.not.exist err
          cells.length.should.eql 3
          cells[0].key.should.eql 'test_filter|row_2'
          cells[1].key.should.eql 'test_filter|row_2'
          cells[2].key.should.eql 'test_filter|row_2'
          this.delete next
  it 'FirstKeyOnlyFilter', (next) ->
    test.getClient (err, client) ->
      # Only return the first KV from each row.
      client
      .getScanner('node_table')
      .create
        startRow: 'test_filter|row_1'
        filter: {'type':'FirstKeyOnlyFilter'}
      , (err, id) ->
        should.not.exist err
        this.get (err, cells) ->
          should.not.exist err
          cells.length.should.be.above 2
          cells[0].key.should.eql 'test_filter|row_1'
          cells[1].key.should.eql 'test_filter|row_2'
          cells[2].key.should.eql 'test_filter|row_3'
          this.delete next
  it 'PageFilter # string value', (next) ->
    getKeysFromCells = (cells) ->
      keys = []
      cells.forEach (cell) ->
        if keys.indexOf(cell['key']) is -1
          keys.push cell['key']
      keys
    test.getClient (err, client) ->
      client
      .getScanner('node_table')
      .create
        startRow: 'test_filter|row_1'
        endRow: 'test_filter|row_4'
        maxVersions: 1
        filter: {"type":"PageFilter","value":"2"}
      , (err, id) ->
        should.not.exist err
        this.get (err, cells) ->
          should.not.exist err
          cells.length.should.eql 4
          keys = getKeysFromCells(cells)
          keys.should.eql ['test_filter|row_1','test_filter|row_2']
          this.delete next
  it 'PageFilter # int value', (next) ->
    getKeysFromCells = (cells) ->
      keys = []
      cells.forEach (cell) ->
        if keys.indexOf(cell['key']) is -1
          keys.push cell['key']
      keys
    test.getClient (err, client) ->
      client
      .getScanner('node_table')
      .create
        startRow: 'test_filter|row_1'
        endRow: 'test_filter|row_4'
        maxVersions: 1
        filter: {"type":"PageFilter","value":2}
      , (err, id) ->
        should.not.exist err
        this.get (err, cells) ->
          should.not.exist err
          cells.length.should.eql 4
          keys = getKeysFromCells(cells)
          keys.should.eql ['test_filter|row_1','test_filter|row_2']
          this.delete next
  it 'RowFilter # equal_with_binary_comparator', (next) ->
    test.getClient (err, client) ->
      # Based on the key
      client
      .getScanner('node_table')
      .create
        startRow: 'test_filter|row_1'
        maxVersions: 1
        filter: {'op':'EQUAL','type':'RowFilter','comparator':{'value':'test_filter|row_2','type':'BinaryComparator'}}
      , (err, id) ->
        should.not.exist err
        this.get (err,cells) ->
          should.not.exist err
          cells.length.should.eql 3
          this.delete next
  it 'ValueFilter # op equal', (next) ->
    test.getClient (err, client) ->
      client
      .getScanner('node_table')
      .create
        startRow: 'test_filter|row_1'
        endRow: 'test_filter|row_4'
        maxVersions: 1
        filter: {"op":"EQUAL","type":"ValueFilter","comparator":{"value":"bb","type":"BinaryComparator"}}
      , (err, id) ->
        should.not.exist err
        this.get (err,cells) ->
          should.not.exist err
          cells.length.should.eql 1
          cells[0].key.should.eql 'test_filter|row_2'
          cells[0].column.should.eql 'node_column_family:bb'
          this.delete next
