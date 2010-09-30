
var utils = require('./utils')
  , HBase = require('hbase').HBase
  , Table = require('hbase').Table;

exports['Instance'] = function(assert){
	utils.getHBase(function(error, hbase){
		assert.ok(hbase.getTable('my table') instanceof Table);
	});
};

exports['Create'] = function(assert){
	utils.getHBase(function(error, hbase,config){
		if(!config.test_table) return;
		hbase
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

//exports['Modify table'] = function(assert){
//	console.log('ok 0');
//	// Create column_2 with compression set to none
//	utils.getHBase(function(error, hbase,config){
//		hbase
//		.getTable('node_table_modify')
//		.create({
//			Attribute: {READ_ONLY:true},
//			READ_ONLY: true,
//			ColumnSchema: [{
//				name: 'column_6',
//				COMPRESSION: 'RECORD',
//				READONLY: 'true'
//			}]
//		}, function(error, data){
//			console.log('ok 5');
//			// Update column_2 with compression set to gz
//			this.update({
//				READ_ONLY: true,
//				ColumnSchema: [{
//					name: 'column_6',
//					COMPRESSION: 'RECORD',
//					REPLICATION_SCOPE: '1',
//					IN_MEMORY: true,
//					READONLY: 'true'
//				}]
//			}, function(error, data){
//				console.log('ok 6');
//				// todo: drop the created column
//				assert.ok(this instanceof Table);
//				assert.ifError(error);
//				assert.strictEqual(true,data);
//				console.log('ok 1');
//				this.getSchema(function(error, schema){
//					console.log('ok 2');
//					console.log(schema)
//					this.delete();
//				})
//			})
//		});
//	});
//};

exports['Delete'] = function(assert){
	utils.getHBase(function(error, hbase,config){
		if(!config.test_table) return;
		hbase
		.getTable('node_table_delete')
		.create({
			IS_META: false,
			IS_ROOT: false,
			ColumnSchema: [{
				name: 'column 1'
			}]
		},function(error, data){
			// really start here
			utils.getHBase(function(error, hbase){
				if(!config.test_table) return;
				hbase
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

exports['Delete (no callback)'] = function(assert){
	utils.getHBase(function(error, hbase,config){
		if(!config.test_table) return;
		hbase
		.getTable('node_table_delete_no_callback')
		.create({
			IS_META: false,
			IS_ROOT: false,
			ColumnSchema: [{
				name: 'column 1'
			}]
		},function(error, data){
			// really start here
			utils.getHBase(function(error, hbase){
				if(!config.test_table) return;
				hbase
				.getTable('node_table_delete_no_callback')
				.delete();
			});
		});
	});
};

exports['Exists'] = function(assert){
	utils.getHBase(function(error, hbase){
		// Test existing table
		hbase
		.getTable('node_table')
		.exists(function(error,exists){
			assert.ok(this instanceof Table);
			assert.ifError(error);
			assert.strictEqual(true,exists);
		});
		// Test missing table
		hbase
		.getTable('node_table_missing')
		.exists(function(error,exists){
			assert.ok(this instanceof Table);
			assert.ifError(error);
			assert.strictEqual(false,exists);
		});
	});
};

exports['Regions'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getTable('node_table')
		.getRegions(function(error, regions){
			assert.ifError(error);
			assert.ok(regions['Region'].length>0);
			assert.ok('startKey' in regions['Region'][0]);
			assert.ok('name' in regions['Region'][0]);
		});
	});
};

exports['Schema'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getTable('node_table')
		.getSchema(function(error, schema){
			assert.ifError(error);
			assert.strictEqual('node_table',schema.name);
		});
	});
};
