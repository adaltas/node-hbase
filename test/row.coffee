
should = require 'should'
test = require './test'
Row = require '../src/row'

describe 'row', ->
  @timeout 0
  it 'put column family', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_put_column_family')
      .put 'node_column_family:', 'my value', (err, data) ->
        should.not.exist err
        data.should.be.ok
        next()
  it 'put column', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_put_column')
      .put 'node_column_family:node_column', 'my value', (err, success) ->
        should.not.exist err
        success.should.be.ok
        next()
  it 'put multiple rows', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_put_x_rows_1')
      .delete ->
        client
        .table('node_table')
        .row('test_row_put_x_rows_2')
        .delete () ->
          time = Date.now()
          client
          .table('node_table')
          .row(null) # 'test_row_put_multiple_rows'
          .put [
            {key: 'test_row_put_x_rows_1', column: 'node_column_family:', timestamp: time + 20, $: 'v 1.3'}
            {key: 'test_row_put_x_rows_1', column: 'node_column_family:', timestamp: time + 60, $: 'v 1.1'}
            {key: 'test_row_put_x_rows_1', column: 'node_column_family:', timestamp: time + 40, $: 'v 1.2'}
            {key: 'test_row_put_x_rows_2', column: 'node_column_family:', timestamp: time + 40, $: 'v 2.2'}
          ], (err, success) ->
            return next err if err
            should.not.exist err
            success.should.be.ok
            client
            .table('node_table')
            .row('test_row_put_x_rows_*')
            .get 'node_column_family:', v: 3, (err, cells) ->
              should.not.exist err
              cells.should.eql [
                { key: 'test_row_put_x_rows_1', column: 'node_column_family:', timestamp: time + 60, '$': 'v 1.1'}
                { key: 'test_row_put_x_rows_1', column: 'node_column_family:', timestamp: time + 40, '$': 'v 1.2'}
                { key: 'test_row_put_x_rows_1', column: 'node_column_family:', timestamp: time + 20, '$': 'v 1.3'}
                { key: 'test_row_put_x_rows_2', column: 'node_column_family:', timestamp: time + 40, '$': 'v 2.2'}
              ]
              next()
  it 'put multiple columns with multiple arguments', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_put_multiple_columns_multi_args')
      .delete (err, success) ->
        should.not.exist err
        this.put [
          'node_column_family:node_column_1'
          'node_column_family:node_column_2'
        ], [
          'my value 1'
          'my value 2'
        ], (err, success) ->
          should.not.exist err
          success.should.be.ok
          this.get (err, cells) ->
            cells.length.should.eql 2
            cells[0].column.should.eql 'node_column_family:node_column_1'
            cells[0].$.should.eql 'my value 1'
            cells[1].column.should.eql 'node_column_family:node_column_2'
            cells[1].$.should.eql 'my value 2'
            next()
  it 'put multiple columns with one arguments', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_put_multiple_columns_one_arg')
      .delete (err, success) ->
        should.not.exist err
        columns = [
          { column: 'node_column_family:c1', $: 'v 1' }
          { column: 'node_column_family:c2', $: 'v 2' }
        ]
        this.put columns, (err, success) ->
          should.not.exist err
          success.should.be.ok
          this.get (err, cells) ->
            should.not.exist err
            cells.length.should.eql 2
            cells[0].column.should.eql 'node_column_family:c1'
            cells[0].$.should.eql 'v 1'
            cells[1].column.should.eql 'node_column_family:c2'
            cells[1].$.should.eql 'v 2'
            next()
  it 'get row', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_get_row')
      .delete (err, value) ->
        colums = ['node_column_family:column_1', 'node_column_family:column_2']
        values = ['my value 1','my value 2']
        this.put colums, values, (err, value) ->
          this.get (err, cells) ->
            should.not.exist err
            cells.should.be.an.instanceof Array
            cells.length.should.eql 2
            should.not.exist cells[0].key
            cells[0].column.should.eql 'node_column_family:column_1'
            cells[0].$.should.eql 'my value 1'
            cells[1].column.should.eql 'node_column_family:column_2'
            cells[1].$.should.eql 'my value 2'
            next()
  it 'get row with suffix globbing', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_get_globbing_1')
      .delete (err, success) ->
        should.not.exist err
        this.put 'node_column_family:column_1', 'my value 1', (err, success) ->
          should.not.exist err
          client
          .table('node_table')
          .row('test_row_get_globbing_2')
          .delete (err, success) ->
            should.not.exist err
            this.put 'node_column_family:column_1', 'my value 2', (err, success) ->
              should.not.exist err
              client
              .table('node_table')
              .row('test_row_get_globbing_*')
              .get (err, cells) ->
                should.not.exist err
                cells.length.should.eql 2
                cells[0].key.should.eql 'test_row_get_globbing_1'
                cells[1].key.should.eql 'test_row_get_globbing_2'
                next()
  it 'get column', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_get_column')
      .delete (err, value) ->
        this.put 'node_column_family:', 'my value', (err, value) ->
          # curl -H "Accept: application/json" http:#localhost:8080/node_table/test_row_get_column/node_column_family
          this.get 'node_column_family:', (err, cells) ->
            should.not.exist err
            cells.should.be.an.instanceof Array
            cells.length.should.eql 1
            cells[0].column.should.eql 'node_column_family:'
            cells[0].$.should.eql 'my value'
            next()
  it 'get escape', (next) ->
    # the "!" and "'" are not escaped by "encodeURIComponent")
    # and java throw an error
    row = 'test_get_escape!\'éè~:@#.? ()' # '*' is not accepted
    column = 'node_column_family:!\'éè~:@#.? ()' # "*" is not accepted
    test.client (err, client) ->
      client
      .table('node_table')
      .row(row) # "/, "
      .delete (err, value) ->
        should.not.exist err
        this.put column, 'my value', (err, success) ->
          should.not.exist err
          client
          .table('node_table')
          .row(row)
          .get (err, value) ->
            should.not.exist err
            value.length.should.eql 1
            value[0].column.should.eql column
            next()
  it 'get options start and end', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_get_start_end')
      .delete (err, success) ->
        time = Date.now()
        rows = [
          { column: 'node_column_family:c1', timestamp: time+20, $: 'v 1' }
          { column: 'node_column_family:c1', timestamp: time+40, $: 'v 2' }
          { column: 'node_column_family:c1', timestamp: time+60, $: 'v 3' }
          { column: 'node_column_family:c1', timestamp: time+80, $: 'v 4' }
        ]
        this.put rows, (err, success) ->
          should.not.exist err
          setTimeout =>
            this.get 'node_column_family:c1', {start: time+40, end:time+60+1, v:10}, (err, cells) ->
              should.not.exist err
              cells.length.should.eql 2
              cells[0].timestamp.should.eql time+60
              cells[1].timestamp.should.eql time+40
              next()
          , 1000
  it 'get option v', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_get_v')
      .delete (err, value) ->
        this.put ['node_column_family:','node_column_family:'], ['v 1','v 2'], (err, value) ->
          this.get 'node_column_family:', {v:1}, (err, cells) ->
            should.not.exist err
            cells.should.be.an.instanceof Array
            cells.length.should.eql 1
            cells[0].column.should.eql 'node_column_family:'
            cells[0].$.should.eql 'v 2'
            next()
  it 'get multiple columns', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_get_multiple_columns')
      .delete (err, value) ->
        should.not.exist err
        this.put ['node_column_family:c1','node_column_family:c2','node_column_family:c3'], ['v 1','v 2','v 3'], (err, value) ->
          should.not.exist err
          this.get ['node_column_family:c1','node_column_family:c3'], (err, cells) ->
            should.not.exist err
            cells.length.should.eql 2
            cells[0].column.should.eql 'node_column_family:c1'
            cells[0].$.should.eql 'v 1'
            cells[1].column.should.eql 'node_column_family:c3'
            cells[1].$.should.eql 'v 3'
            next()
  it 'get missing row', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_get_row_missing')
      .get 'node_column_family:', (err, value) ->
        (err.code is 404 or err.code is 503).should.be.true
        should.not.exist value
        next()
  it 'get missing column', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_get_column_missing')
      .put 'node_column_family:', 'my value', (err, value) ->
        this.get 'node_column_family:column_missing', (err, value) ->
          err.code.should.eql 404
          should.not.exist value
          next()
  it 'exists # row # Row exists', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_exist_row')
      .put 'node_column_family:', 'value', (err, value) ->
        this.exists (err, exists) ->
          should.not.exist err
          exists.should.be.ok
          next()
  it 'exists # row # Row does not exists', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_exist_row_missing')
      .exists (err, exists) ->
        should.not.exist err
        exists.should.not.be.ok
        next()
  it 'exists # column # Row exists', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_exist_column')
      .put 'node_column_family:', 'value', (err, value) ->
        this.exists 'node_column_family:', (err, exists) ->
          should.not.exist err
          exists.should.be.ok
          next()
  it 'exists # column # Row does not exists', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_exist_column_with_row_missing')
      .exists 'node_column_family:', (err, exists) ->
        should.not.exist err
        exists.should.not.be.ok
        next()
  it 'exists # column # Row exists and column family does not exists', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_exist_column_with_column_missing')
      .put 'node_column_family:', 'value', (err, value) ->
        this.exists 'node_column_family_missing', (err, exists) ->
          should.not.exist err
          exists.should.not.be.ok
          next()
  it 'exists # column # Row exists and column family exists and column does not exits', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_exist_column_with_column_missing')
      .put 'node_column_family:', 'value', (err, value) ->
        this.exists 'node_column_family:column_missing', (err, exists) ->
          should.not.exist err
          exists.should.not.be.ok
          next()
  it 'delete row', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_delete_row')
      .put 'node_column_family:column_1', 'my value', (err, value) ->
        this.put 'node_column_family:column_2', 'my value', (err, value) ->
          this.delete (err, success) ->
            should.not.exist err
            success.should.be.true
            this.exists (err, exists) ->
              should.not.exist err
              exists.should.not.be.ok
              next()
  it 'delete column', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_delete_column')
      .put 'node_column_family:c_1', 'my value', (err, value) ->
        this.put 'node_column_family:c_2', 'my value', (err, value) ->
          this.delete 'node_column_family:c_2', (err, success) ->
            should.not.exist err
            success.should.be.true
            count = 0
            this.exists 'node_column_family:c_1', (err, exists) ->
              should.not.exist err
              exists.should.be.ok
              done()
            this.exists 'node_column_family:c_2', (err, exists) ->
              should.not.exist err
              exists.should.not.be.ok
              done()
            count = 0
            done = (err) ->
              count++
              next err if err or count is 2
  it 'delete multiple columns', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .row('test_row_delete_multiple_columns')
      .delete (err, success) ->
        should.not.exist err
        this.put ['node_column_family:c_1','node_column_family:c_2','node_column_family:c_3'], ['v 1','v 2','v 3'], (err, value) ->
          should.not.exist err
          this.delete ['node_column_family:c_1','node_column_family:c_3'], (err, success) ->
            should.not.exist err
            success.should.be.true
            this.exists 'node_column_family:c_1', (err, exists) ->
              should.not.exist err
              exists.should.not.be.ok
              done()
            this.exists 'node_column_family:c_2', (err, exists) ->
              should.not.exist err
              exists.should.be.ok
              done()
            this.exists 'node_column_family:c_3', (err, exists) ->
              should.not.exist err
              exists.should.not.be.ok
              done()
            this.exists (err, exists) ->
              should.not.exist err
              exists.should.be.ok
              done()
            count = 0
            done = (err) ->
              count++
              next err if err or count is 4

