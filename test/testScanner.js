
var utils = require('./utils')
  , Scanner = require('hbase').Scanner;

exports['Instance'] = function(assert){
	utils.getClient(function(error, client){
		assert.ok(client.getScanner('node_table') instanceof Scanner);
		assert.ok(client.getScanner('node_table', 'my_id') instanceof Scanner);
		assert.ok(client.getTable('node_table').getScanner() instanceof Scanner);
		assert.ok(client.getTable('node_table').getScanner('my_id') instanceof Scanner);
	});
};

exports['Create'] = function(assert){
	utils.getClient(function(error, client){
		var rows = 
			[ {row:'test_scanner_create_1', column:'node_column_family', $:'v 1.3'}
			, {row:'test_scanner_create_2', column:'node_column_family', $:'v 1.1'}
			, {row:'test_scanner_create_3', column:'node_column_family', $:'v 1.2'}
			, {row:'test_scanner_create_4', column:'node_column_family', $:'v 2.2'}
			];
		client
		.getRow('node_table', null)
		.put(rows, function(error, success){
			assert.ifError(error);
			client
			.getScanner('node_table')
			.create(function(error,id){
				assert.ifError(error);
				assert.strictEqual(true,/\w+/.test(id));
				assert.strictEqual(this.id,id);
			})
		})
	});
}

exports['Get startRow'] = function(assert){
	utils.getClient(function(error, client){
		var rows = 
		[ {row:'test_scanner_get_startRow_1', column:'node_column_family', $:'v 1.3'}
		, {row:'test_scanner_get_startRow_2', column:'node_column_family', $:'v 1.1'}
		, {row:'test_scanner_get_startRow_3', column:'node_column_family', $:'v 1.2'}
		, {row:'test_scanner_get_startRow_4', column:'node_column_family', $:'v 2.2'}
		];
		client
		.getRow('node_table')
		.put(rows, function(error, success){
			assert.ifError(error);
			var options = {startRow: 'test_scanner_get_startRow_3'};
			client
			.getScanner('node_table')
			.create(options, function(error,id){
				assert.ifError(error);
				this.get(function(error,rows){
					assert.ifError(error);
					assert.strictEqual(2,rows.length);
					assert.strictEqual('test_scanner_get_startRow_3',rows[0].key);
					assert.strictEqual('node_column_family:',rows[0].column);
					assert.strictEqual('test_scanner_get_startRow_4',rows[1].key);
					assert.strictEqual('node_column_family:',rows[1].column);
				})
			})
		})
	});
}

exports['Get batch'] = function(assert){
	utils.getClient(function(error, client){
		var rows = 
		[ {row:'test_scanner_get_batch_1', column:'node_column_family', $:'v 1.3'}
		, {row:'test_scanner_get_batch_2', column:'node_column_family', $:'v 1.1'}
		, {row:'test_scanner_get_batch_3', column:'node_column_family', $:'v 1.2'}
		, {row:'test_scanner_get_batch_4', column:'node_column_family', $:'v 2.2'}
		];
		client
		.getRow('node_table')
		.put(rows, function(error, success){
			assert.ifError(error);
			var options = {startRow: 'test_scanner_get_batch_1', batch:1};
			client
			.getScanner('node_table')
			.create(options, function(error,id){
				assert.ifError(error);
				this.get(function(error,rows){
					assert.ifError(error);
					assert.strictEqual(1,rows.length);
					assert.strictEqual('test_scanner_get_batch_1',rows[0].key);
				})
			})
		})
	});
}

exports['Get columns'] = function(assert){
	utils.getClient(function(error, hbase){
		var rows = 
		[ {row:'test_scanner_get_columns_1', column:'node_column_family:c1', $:'v 1.1'}
		, {row:'test_scanner_get_columns_1', column:'node_column_family:c2', $:'v 1.2'}
		, {row:'test_scanner_get_columns_1', column:'node_column_family:c3', $:'v 1.3'}
		, {row:'test_scanner_get_columns_1', column:'node_column_family:c4', $:'v 1.4'}
		, {row:'test_scanner_get_columns_2', column:'node_column_family:c1', $:'v 2.1'}
		, {row:'test_scanner_get_columns_2', column:'node_column_family:c2', $:'v 2.2'}
		, {row:'test_scanner_get_columns_2', column:'node_column_family:c3', $:'v 2.3'}
		, {row:'test_scanner_get_columns_2', column:'node_column_family:c4', $:'v 2.4'}
		, {row:'test_scanner_get_columns_3', column:'node_column_family:c1', $:'v 3.1'}
		, {row:'test_scanner_get_columns_3', column:'node_column_family:c2', $:'v 3.2'}
		, {row:'test_scanner_get_columns_3', column:'node_column_family:c3', $:'v 3.3'}
		, {row:'test_scanner_get_columns_3', column:'node_column_family:c4', $:'v 3.4'}
		];
		hbase
		.getRow('node_table')
		.put(rows, function(error, success){
			assert.ifError(error);
			var options = {};
			options.startRow = 'test_scanner_get_columns';
			options.column = ['node_column_family:c4','node_column_family:c2'];
			hbase
			.getScanner('node_table')
			.create(options, function(error,id){
				assert.ifError(error);
				this.get(function(error,rows){
					assert.strictEqual(6,rows.length);
					assert.strictEqual('test_scanner_get_columns_1',rows[0].key);
					assert.strictEqual('node_column_family:c2',rows[0].column);
					assert.strictEqual('test_scanner_get_columns_1',rows[1].key);
					assert.strictEqual('node_column_family:c4',rows[1].column);
				})
			})
		})
	});
}
