
var utils = require('./utils')
  , HBase = require('hbase').HBase
  , Table = require('hbase').Table;

exports['Get table'] = function(assert){
	utils.getHBase(function(error,hbase){
		assert.ok(hbase.getTable('my table') instanceof Table);
	});
};

exports['Create table'] = function(assert){
	utils.getHBase(function(error,hbase,config){
		if(!config.test_table) return;
		hbase
		.getTable('node_hbase_create')
		.create({
			IS_META: false,
			IS_ROOT: false,
			COLUMNS: [{
				NAME: 'column 1'
			}]
		},function(err,data){
			assert.ok(this instanceof Table);
			assert.strictEqual(null,err);
			assert.strictEqual(true,data);
			this.delete();
		});
	});
};

exports['Delete table'] = function(assert){
	utils.getHBase(function(error,hbase,config){
		if(!config.test_table) return;
		hbase
		.getTable('node_hbase_delete')
		.create({
			IS_META: false,
			IS_ROOT: false,
			COLUMNS: [{
				NAME: 'column 1'
			}]
		},function(err,data){
			// really start here
			utils.getHBase(function(error,hbase){
				if(!config.test_table) return;
				hbase
				.getTable('node_hbase_delete')
				.delete(function(err,data){
					assert.ok(this instanceof Table);
					assert.strictEqual(null,err);
					assert.strictEqual(true,data);
				});
			});
		});
	});
};

exports['Delete no callback'] = function(assert){
	utils.getHBase(function(error,hbase,config){
		if(!config.test_table) return;
		hbase
		.getTable('node_hbase_delete_no_callback')
		.create({
			IS_META: false,
			IS_ROOT: false,
			COLUMNS: [{
				NAME: 'column 1'
			}]
		},function(err,data){
			// really start here
			utils.getHBase(function(error,hbase){
				if(!config.test_table) return;
				hbase
				.getTable('node_hbase_delete_no_callback')
				.delete();
			});
		});
	});
};

exports['Exists table'] = function(assert){
	utils.getHBase(function(error,hbase){
		// Test existing table
		hbase
		.getTable('node_hbase')
		.exists(function(err,exists){
			assert.ok(this instanceof Table);
			assert.strictEqual(null,err);
			assert.strictEqual(true,exists);
		});
		// Test missing table
		hbase
		.getTable('node_hbase_missing')
		.exists(function(err,exists){
			assert.ok(this instanceof Table);
			assert.strictEqual(null,err);
			assert.strictEqual(false,exists);
		});
	});
};
