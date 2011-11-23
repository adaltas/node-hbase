
assert = require('assert')
Table = require('hbase').Table
utils = require('./utils')

module.exports =
    'Instance': (next) ->
        utils.getClient (error, client) ->
            assert.ok(client.getTable('my table') instanceof Table)
            next()
    'Create no schema': (next) ->
        utils.getClient (error, client, config) ->
            return next() unless config.test_table
            client
            .getTable('node_table_create_no_schema')
            .create (error, data) ->
                assert.ok(this instanceof Table)
                assert.ifError error
                assert.strictEqual(true,data)
                this.getSchema (error, schema) ->
                    assert.strictEqual('false', schema['IS_META'])
                    assert.strictEqual('false', schema['IS_ROOT'])
                    assert.strictEqual(false, 'ColumnSchema' in schema)
                    this.delete next
    'Create with schema': (next) ->
        utils.getClient (error, client, config) ->
            return next() unless config.test_table
            client
            .getTable('node_table_create')
            .create
                IS_META: false
                IS_ROOT: false
                ColumnSchema: [{
                    name: 'column_1'
                }]
            , (error, data) ->
                assert.ok(this instanceof Table)
                assert.ifError error
                assert.strictEqual(true,data)
                this.getSchema (error, schema) ->
                    assert.strictEqual(1,schema['ColumnSchema'].length)
                    assert.strictEqual('column_1',schema['ColumnSchema'][0]['name'])
                    this.delete next
    'Modify table': (next) ->
        # Create a table `node_table_modify`
        # Create column_2 with compression set to none
        utils.getClient (error, client, config) ->
            # Note, require patch 3140
            # https:#issues.apache.org/jira/browse/HBASE-3140?page=com.atlassian.jira.plugin.system.issuetabpanels:all-tabpanel
            return next() unless config.test_table_modify
            client
            .getTable('node_table_modify')
            .delete (error, data) ->
                this.create
                    Attribute: {READ_ONLY:true}
                    READ_ONLY: true
                    ColumnSchema: [{
                        name: 'column_6'
                        COMPRESSION: 'RECORD'
                        READONLY: 'false'
                    }]
                , (error, data) ->
                    # Update column_2 with compression set to gz
                    this.update
                        READ_ONLY: true
                        ColumnSchema: [
                            name: 'column_6'
                            COMPRESSION: 'RECORD'
                            REPLICATION_SCOPE: '1'
                            IN_MEMORY: true
                            READONLY: 'true'
                        
                            name: 'column_7'
                            COMPRESSION: 'RECORD'
                            REPLICATION_SCOPE: '1'
                            IN_MEMORY: true
                            READONLY: 'true'
                        ]
                    , (error, data) ->
                        # todo: drop the created column
                        assert.ifError error
                        assert.ok this instanceof Table
                        assert.strictEqual(true,data)
                        this.getSchema (error, schema) ->
                            assert.strictEqual(2,schema.ColumnSchema.length)
                            assert.strictEqual('column_6',schema.ColumnSchema[0].name)
                            assert.strictEqual('column_7',schema.ColumnSchema[1].name)
                            this.delete next
    'Delete': (next) ->
        utils.getClient (error, client, config) ->
            return next() unless config.test_table
            client
            .getTable('node_table_delete')
            .create
                IS_META: false
                IS_ROOT: false
                ColumnSchema: [{
                    name: 'column 1'
                }]
            , (error, data) ->
                # really start here
                utils.getClient (error, client) ->
                    client
                    .getTable('node_table_delete')
                    .delete (error, data) ->
                        assert.ok(this instanceof Table)
                        assert.ifError error
                        assert.strictEqual(true,data)
                        next()
    'Delete (no callback)': (next) ->
        utils.getClient (error, client, config) ->
            return next() unless config.test_table
            client
            .getTable('node_table_delete_no_callback')
            .create
                IS_META: false
                IS_ROOT: false
                ColumnSchema: [{
                    name: 'column 1'
                }]
            , (error, data) ->
                # really start here
                utils.getClient (error, client) ->
                    client
                    .getTable('node_table_delete_no_callback')
                    .delete( next )
    'Exists': (next) ->
        utils.getClient (error, client) ->
            # Test existing table
            client
            .getTable('node_table')
            .exists (error,exists) ->
                assert.ok this instanceof Table
                assert.ifError error
                assert.strictEqual true, exists
            # Test missing table
            client
            .getTable('node_table_missing')
            .exists (error,exists) ->
                assert.ok this instanceof Table
                assert.ifError error
                assert.strictEqual false, exists
                next()
    'Regions': (next) ->
        utils.getClient (error, client) ->
            client
            .getTable('node_table')
            .getRegions (error, regions) ->
                assert.ifError error
                assert.ok regions['Region'].length > 0
                assert.ok regions['Region'][0].startKey?
                assert.ok regions['Region'][0].name?
                next()
    'Schema': (next) ->
        utils.getClient (error, client) ->
            client
            .getTable('node_table')
            .getSchema (error, schema) ->
                assert.ifError error
                assert.strictEqual('node_table',schema.name)
                next()
