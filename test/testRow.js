
var utils = require('./utils')
  , Row = require('hbase').Row;

exports['Instance'] = function(assert){
	utils.getHBase(function(error, hbase){
		assert.ok(hbase.getRow('mytable','my_row') instanceof Row);
		assert.ok(hbase.getTable('mytable').getRow('my_row') instanceof Row);
	});
};

exports['Put'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'node_table_row')
		.put('node_column_family', 'my value', function(error, data){ //:node_column
			assert.ifError(error);
			assert.strictEqual(true,data);
		})
	});
};

