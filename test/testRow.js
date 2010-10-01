
var utils = require('./utils')
  , Row = require('hbase').Row;

exports['Instance'] = function(assert){
	utils.getHBase(function(error, hbase){
		assert.ok(hbase.getRow('mytable','my_row') instanceof Row);
		assert.ok(hbase.getTable('mytable').getRow('my_row') instanceof Row);
	});
};

exports['Put column family'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_put_column_family')
		.put('node_column_family', 'my value', function(error, data){
			assert.ifError(error);
			assert.strictEqual(true,data);
		})
	});
};

exports['Put column'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_put_column')
		.put('node_column_family:node_column', 'my value', function(error, data){
			assert.ifError(error);
			assert.strictEqual(true,data);
		})
	});
};

exports['Get'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_get')
		.put('node_column_family', 'my value', function(error, value){
			this.get('node_column_family',function(error, value){
				assert.ifError(error);
				assert.strictEqual('my value',value);
			})
		})
	});
};

exports['Get on row missing'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_get_row_missing')
		.get('node_column_family',function(error, value){
			assert.strictEqual(404,error.code);
			assert.strictEqual(null,value);
		})
	});
};

exports['Get on column missing'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_get_column_missing')
		.put('node_column_family', 'my value', function(error, value){
			this.get('node_column_family:column_missing',function(error, value){
				assert.strictEqual(404,error.code);
				assert.strictEqual(null,value);
			})
		})
	});
};

exports['Exists'] = function(assert){
	utils.getHBase(function(error, hbase){
		// Row exists
		hbase
		.getRow('node_table', 'test_row_exist')
		.put('node_column_family', 'value', function(error, value){
			this.exists('node_column_family', function(error, exists){
				assert.ifError(error);
				assert.strictEqual(true,exists);
			})
		});
		// Row does not exists
		hbase
		.getRow('node_table', 'test_row_exist_row_missing')
		.exists('node_column_family', function(error, exists){
			assert.ifError(error);
			assert.strictEqual(false,exists);
		})
		// Row exists and column family does not exists
		hbase
		.getRow('node_table', 'test_row_exist_column_missing')
		.put('node_column_family', 'value', function(error, value){
			this.exists('node_column_family_missing', function(error, exists){
				assert.ifError(error);
				assert.strictEqual(false,exists);
			})
		});
		// Row exists and column family exists and column does not exits
		hbase
		.getRow('node_table', 'test_row_exist_column_missing')
		.put('node_column_family', 'value', function(error, value){
			this.exists('node_column_family:column_missing', function(error, exists){
				assert.ifError(error);
				assert.strictEqual(false,exists);
			})
		});
	});
};

