
should = require 'should'
Table = require '../src/table'
test = require './test'

describe 'table', ->
  @timeout 0
  it 'Instance', (next) ->
    test.client (err, client) ->
      client.table('my table').should.be.an.instanceof Table
      next()
  it 'Create no schema', (next) ->
    test.client (err, client, config) ->
      return next() unless config.test_table
      client
      .table('node_table_create_no_schema')
      .create (err, data) ->
        this.should.be.an.instanceof Table
        should.not.exist err
        assert.strictEqual(true,data)
        this.schema (err, schema) ->
          schema['IS_META'].should.eql 'false'
          schema['IS_ROOT'].should.eql 'false'
          # assert.strictEqual(false, 'ColumnSchema' in schema)
          schema.should.not.include 'ColumnSchema'
          this.delete next
  it 'Create with schema', (next) ->
    test.client (err, client, config) ->
      return next() unless config.test_table
      client
      .table('node_table_create')
      .create
        IS_META: false
        IS_ROOT: false
        ColumnSchema: [{
          name: 'column_1'
        }]
      , (err, data) ->
        this.should.be.an.instanceof Table
        should.not.exist err
        data.should.be.ok
        this.schema (err, schema) ->
          schema['ColumnSchema'].length.should.eql 1
          schema['ColumnSchema'][0]['name'].should.eql 'column_1'
          this.delete next
  it 'Modify table', (next) ->
    # Create a table `node_table_modify`
    # Create column_2 with compression set to none
    test.client (err, client, config) ->
      # Note, require patch 3140
      # https:#issues.apache.org/jira/browse/HBASE-3140?page=com.atlassian.jira.plugin.system.issuetabpanels:all-tabpanel
      return next() unless config.test_table_modify
      client
      .table('node_table_modify')
      .delete (err, data) ->
        this.create
          Attribute: {READ_ONLY:true}
          READ_ONLY: true
          ColumnSchema: [{
            name: 'column_6'
            COMPRESSION: 'RECORD'
            READONLY: 'false'
          }]
        , (err, data) ->
          # Update column_2 with compression set to gz
          this.update
            READ_ONLY: true
            ColumnSchema: [
              name: 'column_6'
              COMPRESSION: 'RECORD'
              REPLICATION_SCOPE: '1'
              IN_MEMORY: true
              READONLY: 'true'
            ,
              name: 'column_7'
              COMPRESSION: 'RECORD'
              REPLICATION_SCOPE: '1'
              IN_MEMORY: true
              READONLY: 'true'
            ]
          , (err, data) ->
            # todo: drop the created column
            should.not.exist err
            this.should.be.an.instanceof Table
            data.should.be.ok
            this.schema (err, schema) ->
              schema.ColumnSchema.length.should.eql 2
              schema.ColumnSchema[0].name.should.eql 'column_6'
              schema.ColumnSchema[1].name.should.eql 'column_7'
              this.delete next
  it 'Delete', (next) ->
    test.client (err, client, config) ->
      return next() unless config.test_table
      client
      .table('node_table_delete')
      .create
        IS_META: false
        IS_ROOT: false
        ColumnSchema: [{
          name: 'column 1'
        }]
      , (err, data) ->
        # really start here
        test.client (err, client) ->
          client
          .table('node_table_delete')
          .delete (err, data) ->
            this.should.be.an.instanceof Table
            should.not.exist err
            data.should.be.ok
            next()
  it 'Delete (no callback)', (next) ->
    test.client (err, client, config) ->
      return next() unless config.test_table
      client
      .table('node_table_delete_no_callback')
      .create
        IS_META: false
        IS_ROOT: false
        ColumnSchema: [{
          name: 'column 1'
        }]
      , (err, data) ->
        # really start here
        test.client (err, client) ->
          client
          .table('node_table_delete_no_callback')
          .delete( next )
  it 'Exists', (next) ->
    test.client (err, client) ->
      # Test existing table
      client
      .table('node_table')
      .exists (err, exists) ->
        this.should.be.an.instanceof Table
        should.not.exist err
        exists.should.be.ok
      # Test missing table
      client
      .table('node_table_missing')
      .exists (err, exists) ->
        this.should.be.an.instanceof Table
        should.not.exist err
        exists.should.not.be.ok
        next()
  it 'Regions', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .regions (err, regions) ->
        should.not.exist err
        regions['Region'].length.should.be.above 0
        regions['Region'][0].startKey.should.exist
        regions['Region'][0].name.should.exist
        next()
  it 'Schema', (next) ->
    test.client (err, client) ->
      client
      .table('node_table')
      .schema (err, schema) ->
        should.not.exist err
        schema.name.should.eql 'node_table'
        next()

