
utils = require('./utils')
Row = require('hbase').Row
assert = require('assert')

module.exports = 
    'Row # Instance': (next) ->
        utils.getClient (error, client) ->
            assert.ok client.getRow('mytable', 'my_row') instanceof Row
            assert.ok client.getTable('mytable').getRow('my_row') instanceof Row
            next()
    'Row # Put column family': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_put_column_family')
            .put 'node_column_family', 'my value', (error, data) ->
                assert.ifError error
                assert.strictEqual(true, data)
                next()
    'Row # Put column': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_put_column')
            .put 'node_column_family:node_column', 'my value', (error, success) ->
                assert.ifError error
                assert.strictEqual(true,success)
                next()
    'Row # Put multiple rows': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table','test_row_put_x_rows_1')
            .delete () ->
                client
                .getRow('node_table','test_row_put_x_rows_2')
                .delete () ->
                    time = Date.now()
                    rows = [
                        {key: 'test_row_put_x_rows_1', column: 'node_column_family', timestamp: time + 20, $: 'v 1.3'}
                        {key: 'test_row_put_x_rows_1', column: 'node_column_family', timestamp: time + 60, $: 'v 1.1'}
                        {key: 'test_row_put_x_rows_1', column: 'node_column_family', timestamp: time + 40, $: 'v 1.2'}
                        {key: 'test_row_put_x_rows_2', column: 'node_column_family', timestamp: time + 40, $: 'v 2.2'}
                    ]
                    client
                    .getRow('node_table', null) # 'test_row_put_multiple_rows'
                    .put rows, (error, success) ->
                        assert.ifError error
                        assert.strictEqual(true,success)
                        client
                        .getRow('node_table', 'test_row_put_x_rows_*')
                        .get (error,cells) ->
                            assert.ifError error
                            assert.deepEqual([  
                                { key: 'test_row_put_x_rows_1', column: 'node_column_family:', timestamp: time + 60, '$': 'v 1.1'}
                                { key: 'test_row_put_x_rows_1', column: 'node_column_family:', timestamp: time + 40, '$': 'v 1.2'}
                                { key: 'test_row_put_x_rows_1', column: 'node_column_family:', timestamp: time + 20, '$': 'v 1.3'}
                                { key: 'test_row_put_x_rows_2', column: 'node_column_family:', timestamp: time + 40, '$': 'v 2.2'}
                            ], cells)
                            next()
    'Row # Put multiple columns': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_put_multiple_columns_multi_args')
            .delete (error, success) ->
                assert.ifError error
                this.put ['node_column_family:node_column_1','node_column_family:node_column_2'], ['my value 1','my value 2'], (error, success) ->
                    assert.ifError error
                    assert.strictEqual(true,success)
                    this.get (error, cells) ->
                        assert.strictEqual(2,cells.length)
                        assert.strictEqual('node_column_family:node_column_1',cells[0].column)
                        assert.strictEqual('my value 1',cells[0].$)
                        assert.strictEqual('node_column_family:node_column_2',cells[1].column)
                        assert.strictEqual('my value 2',cells[1].$)
                        next()
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_put_multiple_columns_one_arg')
            .delete (error, success) ->
                assert.ifError error
                columns = [
                    { column: 'node_column_family:c1', $: 'v 1' }
                    { column: 'node_column_family:c2', $: 'v 2' }
                ]
                this.put columns, (error, success) ->
                    assert.ifError error
                    assert.strictEqual(true,success)
                    this.get (error, cells) ->
                        assert.ifError error
                        assert.strictEqual(2,cells.length)
                        assert.strictEqual('node_column_family:c1',cells[0].column)
                        assert.strictEqual('v 1',cells[0].$)
                        assert.strictEqual('node_column_family:c2',cells[1].column)
                        assert.strictEqual('v 2',cells[1].$)
                        next()
    'Row # Get row': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_get_row')
            .delete (error, value) ->
                colums = ['node_column_family:column_1', 'node_column_family:column_2']
                values = ['my value 1','my value 2']
                this.put colums, values, (error, value) ->
                    this.get (error, cells) ->
                        assert.ifError error
                        assert.strictEqual(true,cells instanceof Array)
                        assert.strictEqual(2,cells.length)
                        assert.strictEqual('undefined',typeof cells[0].key)
                        assert.strictEqual('node_column_family:column_1',cells[0].column)
                        assert.strictEqual('my value 1',cells[0].$)
                        assert.strictEqual('node_column_family:column_2',cells[1].column)
                        assert.strictEqual('my value 2',cells[1].$)
                        next()
    'Row # Get row with suffix globbing': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_get_globbing_1')
            .delete (error, success) ->
                assert.ifError error
                this.put 'node_column_family:column_1', 'my value 1', (error, success) ->
                    assert.ifError error
                    client
                    .getRow('node_table', 'test_row_get_globbing_2')
                    .delete (error, success) ->
                        assert.ifError error
                        this.put 'node_column_family:column_1', 'my value 2', (error, success) ->
                            assert.ifError error
                            client
                            .getRow('node_table','test_row_get_globbing_*')
                            .get (error, cells) ->
                                assert.ifError error
                                assert.strictEqual(2,cells.length)
                                assert.strictEqual('test_row_get_globbing_1',cells[0].key)
                                assert.strictEqual('test_row_get_globbing_2',cells[1].key)
                                next()
    'Row # Get column': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_get_column')
            .delete (error, value) ->
                this.put 'node_column_family', 'my value', (error, value) ->
                    # curl -H "Accept: application/json" http:#localhost:8080/node_table/test_row_get_column/node_column_family
                    this.get 'node_column_family', (error, cells) ->
                        assert.ifError error
                        assert.strictEqual(true,cells instanceof Array)
                        assert.strictEqual(1,cells.length)
                        assert.strictEqual('node_column_family:',cells[0].column)
                        assert.strictEqual('my value',cells[0].$)
                        next()
    'Row # Get escape': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_get_escape!\'éè~:@#.?*()') # "/, "
            .delete (error, value) ->
                assert.ifError error
                this.put 'node_column_family:!\'éè~:@#.?*()', 'my value', (error, success) ->
                    assert.ifError error
                    client
                    .getRow('node_table', 'test_get_escape!\'éè~:@#.?*()')
                    .get (error,value) ->
                        assert.ifError error
                        assert.strictEqual(1,value.length)
                        assert.strictEqual('node_column_family:!\'éè~:@#.?*()',value[0].column)
                        next()
    'Row # Get options start and end': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_get_start_end')
            .delete (error, success) ->
                time = Date.now()
                rows = [
                    { column: 'node_column_family:c1', timestamp: time+20, $: 'v 1' }
                    { column: 'node_column_family:c1', timestamp: time+40, $: 'v 2' }
                    { column: 'node_column_family:c1', timestamp: time+60, $: 'v 3' }
                    { column: 'node_column_family:c1', timestamp: time+80, $: 'v 4' }
                ]
                this.put rows, (error, success) ->
                    assert.ifError error
                    this.get 'node_column_family:c1', {start: time+40, end:time+60+1}, (error, cells) ->
                        assert.ifError error
                        assert.strictEqual(2,cells.length)
                        assert.strictEqual(time+60, cells[0].timestamp)
                        assert.strictEqual(time+40, cells[1].timestamp)
                        next()
    'Row # Get option v': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_get_v')
            .delete (error, value) ->
                this.put ['node_column_family','node_column_family'], ['v 1','v 2'], (error, value) ->
                    this.get 'node_column_family', {v:1}, (error, cells) ->
                        assert.ifError error
                        assert.strictEqual(true,cells instanceof Array)
                        assert.strictEqual(1,cells.length)
                        assert.strictEqual('node_column_family:',cells[0].column)
                        assert.strictEqual('v 2',cells[0].$)
                        next()
    'Row # Get multiple columns': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_get_multiple_columns')
            .delete (error, value) ->
                assert.ifError error
                this.put ['node_column_family:c1','node_column_family:c2','node_column_family:c3'], ['v 1','v 2','v 3'], (error, value) ->
                    assert.ifError error
                    this.get ['node_column_family:c1','node_column_family:c3'], (error, cells) ->
                        assert.ifError error
                        assert.strictEqual(2,cells.length)
                        assert.strictEqual('node_column_family:c1',cells[0].column)
                        assert.strictEqual('v 1',cells[0].$)
                        assert.strictEqual('node_column_family:c3',cells[1].column)
                        assert.strictEqual('v 3',cells[1].$)
                        next()
    'Row # Get missing row': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_get_row_missing')
            .get 'node_column_family', (error, value) ->
                assert.strictEqual(true, error.code is 404 or error.code is 503)
                assert.strictEqual(null, value)
                next()
    'Row # Get missing column': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_get_column_missing')
            .put 'node_column_family', 'my value', (error, value) ->
                this.get 'node_column_family:column_missing', (error, value) ->
                    assert.strictEqual(404,error.code)
                    assert.strictEqual(null,value)
                    next()
    'Row # Exists # row # Row exists': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_exist_row')
            .put 'node_column_family', 'value', (error, value) ->
                this.exists (error, exists) ->
                    assert.ifError error
                    assert.strictEqual(true,exists)
                    next()
    'Row # Exists # row # Row does not exists': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_exist_row_missing')
            .exists (error, exists) ->
                assert.ifError error
                assert.strictEqual(false, exists)
                next()
    'Row # Exists # column # Row exists': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_exist_column')
            .put 'node_column_family', 'value', (error, value) ->
                this.exists 'node_column_family', (error, exists) ->
                    assert.ifError error
                    assert.strictEqual(true,exists)
                    next()
    'Row # Exists # column # Row does not exists': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_exist_column_with_row_missing')
            .exists 'node_column_family', (error, exists) ->
                assert.ifError error
                assert.strictEqual(false, exists)
                next()
    'Row # Exists # column # Row exists and column family does not exists': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_exist_column_with_column_missing')
            .put 'node_column_family', 'value', (error, value) ->
                this.exists 'node_column_family_missing', (error, exists) ->
                    assert.ifError error
                    assert.strictEqual(false, exists)
                    next()
    'Row # Exists # column # Row exists and column family exists and column does not exits': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_exist_column_with_column_missing')
            .put 'node_column_family', 'value', (error, value) ->
                this.exists 'node_column_family:column_missing', (error, exists) ->
                    assert.ifError error
                    assert.strictEqual(false, exists)
                    next()
    'Row # Delete row': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_delete_row')
            .put 'node_column_family:column_1', 'my value', (error, value) ->
                this.put 'node_column_family:column_2', 'my value', (error, value) ->
                    this.delete (error, success) ->
                        assert.ifError error
                        assert.strictEqual(true, success)
                        this.exists (error, exists) ->
                            assert.ifError error
                            assert.strictEqual(false, exists)
                            next()
    'Row # Delete column': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_delete_column')
            .put 'node_column_family:c_1', 'my value', (error, value) ->
                this.put 'node_column_family:c_2', 'my value', (error, value) ->
                    this.delete 'node_column_family:c_2', (error, success) ->
                        assert.ifError error
                        assert.strictEqual(true, success)
                        this.exists 'node_column_family:c_1', (error, exists) ->
                            assert.ifError error
                            assert.strictEqual(true, exists)
                        this.exists 'node_column_family:c_2', (error, exists) ->
                            assert.ifError error
                            assert.strictEqual(false, exists)
                            next()
    'Row # Delete multiple columns': (next) ->
        utils.getClient (error, client) ->
            client
            .getRow('node_table', 'test_row_delete_multiple_columns')
            .delete (error, success) ->
                assert.ifError error
                this.put ['node_column_family:c_1','node_column_family:c_2','node_column_family:c_3'], ['v 1','v 2','v 3'], (error, value) ->
                    assert.ifError error
                    this.delete ['node_column_family:c_1','node_column_family:c_3'], (error, success) ->
                        assert.ifError error
                        assert.strictEqual(true, success)
                        this.exists 'node_column_family:c_1', (error, exists) ->
                            assert.ifError error
                            assert.strictEqual(false, exists)
                        this.exists 'node_column_family:c_2', (error, exists) ->
                            assert.ifError error
                            assert.strictEqual(true, exists)
                        this.exists 'node_column_family:c_3', (error, exists) ->
                            assert.ifError error
                            assert.strictEqual(false, exists)
                        this.exists (error, exists) ->
                            assert.ifError error
                            assert.strictEqual(true, exists)
                            next()

