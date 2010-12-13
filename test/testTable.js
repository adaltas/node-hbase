
var utils = require('./utils')
  , Table = require('hbase').Table
  , assert = require('assert');

exports['Instance'] = function(){
	utils.getClient(function(error, client){
		assert.ok(client.getTable('my table') instanceof Table);
	});
};

exports['Create no schema'] = function(){
	utils.getClient(function(error, client, config){
		if(!config.test_table) return;
		client
		.getTable('node_table_create_no_schema')
		.create(function(error, data){
			assert.ok(this instanceof Table);
			assert.ifError(error);
			assert.strictEqual(true,data);
			this.getSchema(function(error, schema){
				assert.strictEqual('false', schema['IS_META']);
				assert.strictEqual('false', schema['IS_ROOT']);
				assert.strictEqual(false, 'ColumnSchema' in schema);
				this.delete();
			})
		});
	});
};

exports['Create with schema'] = function(){
	utils.getClient(function(error, client, config){
		if(!config.test_table) return;
		client
		.getTable('node_table_create')
		.create({
			IS_META: false,
			IS_ROOT: false,
			ColumnSchema: [{
				name: 'column_1'
			}]
		},function(error, data){
			assert.ok(this instanceof Table);
			assert.ifError(error);
			assert.strictEqual(true,data);
			this.getSchema(function(error, schema){
				assert.strictEqual(1,schema['ColumnSchema'].length)
				assert.strictEqual('column_1',schema['ColumnSchema'][0]['name'])
				this.delete();
			})
		});
	});
};

exports['Modify table'] = function(){
	// Create a table `node_table_modify`
	// Create column_2 with compression set to none
	utils.getClient(function(error, client, config){
		if(!config.test_table_modify){
			// Note, require patch 3140
			// https://issues.apache.org/jira/browse/HBASE-3140?page=com.atlassian.jira.plugin.system.issuetabpanels:all-tabpanel
			return;
		}
		client
		.getTable('node_table_modify')
		.delete(function(error, data){
			this.create({
				Attribute: {READ_ONLY:true},
				READ_ONLY: true,
				ColumnSchema: [{
					name: 'column_6',
					COMPRESSION: 'RECORD',
					READONLY: 'false'
				}]
			}, function(error, data){
				// Update column_2 with compression set to gz
				this.update({
					READ_ONLY: true,
					ColumnSchema: [{
						name: 'column_6',
						COMPRESSION: 'RECORD',
						REPLICATION_SCOPE: '1',
						IN_MEMORY: true,
						READONLY: 'true'
					},{
						name: 'column_7',
						COMPRESSION: 'RECORD',
						REPLICATION_SCOPE: '1',
						IN_MEMORY: true,
						READONLY: 'true'
					}]
				}, function(error, data){
					// todo: drop the created column
					assert.ifError(error);
					assert.ok(this instanceof Table);
					assert.strictEqual(true,data);
					this.getSchema(function(error, schema){
						assert.strictEqual(2,schema.ColumnSchema.length);
						assert.strictEqual('column_6',schema.ColumnSchema[0].name);
						assert.strictEqual('column_7',schema.ColumnSchema[1].name);
						this.delete();
					})
				})
			});
		})
	});
};

exports['Delete'] = function(){
	utils.getClient(function(error, client, config){
		if(!config.test_table) return;
		client
		.getTable('node_table_delete')
		.create({
			IS_META: false,
			IS_ROOT: false,
			ColumnSchema: [{
				name: 'column 1'
			}]
		},function(error, data){
			// really start here
			utils.getClient(function(error, client){
				if(!config.test_table) return;
				client
				.getTable('node_table_delete')
				.delete(function(error, data){
					assert.ok(this instanceof Table);
					assert.ifError(error);
					assert.strictEqual(true,data);
				});
			});
		});
	});
};

exports['Delete (no callback)'] = function(){
	utils.getClient(function(error, client, config){
		if(!config.test_table) return;
		client
		.getTable('node_table_delete_no_callback')
		.create({
			IS_META: false,
			IS_ROOT: false,
			ColumnSchema: [{
				name: 'column 1'
			}]
		},function(error, data){
			// really start here
			utils.getClient(function(error, client){
				if(!config.test_table) return;
				client
				.getTable('node_table_delete_no_callback')
				.delete();
			});
		});
	});
};

exports['Exists'] = function(){
	utils.getClient(function(error, client){
		// Test existing table
		client
		.getTable('node_table')
		.exists(function(error,exists){
			assert.ok(this instanceof Table);
			assert.ifError(error);
			assert.strictEqual(true,exists);
		});
		// Test missing table
		client
		.getTable('node_table_missing')
		.exists(function(error,exists){
			assert.ok(this instanceof Table);
			assert.ifError(error);
			assert.strictEqual(false,exists);
		});
	});
};

exports['Regions'] = function(){
	utils.getClient(function(error, client){
		client
		.getTable('node_table')
		.getRegions(function(error, regions){
			assert.ifError(error);
			assert.ok(regions['Region'].length>0);
			assert.ok('startKey' in regions['Region'][0]);
			assert.ok('name' in regions['Region'][0]);
		});
	});
};

exports['Schema'] = function(){
	utils.getClient(function(error, client){
		client
		.getTable('node_table')
		.getSchema(function(error, schema){
			assert.ifError(error);
			assert.strictEqual('node_table',schema.name);
		});
	});
};
