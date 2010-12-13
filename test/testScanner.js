
var utils = require('./utils')
  , hbase = require('hbase')
  , Scanner = require('hbase').Scanner
  , assert = require('assert');

exports['Instance'] = function(){
	utils.getClient(function(error, client){
		assert.ok(client.getScanner('node_table') instanceof Scanner);
		assert.ok(client.getScanner('node_table', 'my_id') instanceof Scanner);
		assert.ok(client.getTable('node_table').getScanner() instanceof Scanner);
		assert.ok(client.getTable('node_table').getScanner('my_id') instanceof Scanner);
	});
};

exports['Create'] = function(){
	utils.getClient(function(error, client){
		var rows = 
			[ {key:'test_scanner_create_1', column:'node_column_family', $:'v 1.3'}
			, {key:'test_scanner_create_2', column:'node_column_family', $:'v 1.1'}
			, {key:'test_scanner_create_3', column:'node_column_family', $:'v 1.2'}
			, {key:'test_scanner_create_4', column:'node_column_family', $:'v 2.2'}
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
				this.delete();
			})
		})
	});
}

exports['Get startRow'] = function(){
	utils.getClient(function(error, client){
		var rows = 
		[ {key:'test_scanner_get_startRow_1', column:'node_column_family', $:'v 1.3'}
		, {key:'test_scanner_get_startRow_11', column:'node_column_family', $:'v 1.1'}
		, {key:'test_scanner_get_startRow_111', column:'node_column_family', $:'v 1.2'}
		, {key:'test_scanner_get_startRow_2', column:'node_column_family', $:'v 2.2'}
		];
		client
		.getRow('node_table')
		.put(rows, function(error, success){
			assert.ifError(error);
			var options = {startRow: 'test_scanner_get_startRow_11'};
			client
			.getScanner('node_table')
			.create(options, function(error,id){
				assert.ifError(error);
				this.get(function(error,rows){
					assert.ifError(error);
					// http://brunodumon.wordpress.com/2010/02/17/building-indexes-using-hbase-mapping-strings-numbers-and-dates-onto-bytes/
					// Technically, you would set the start row for the scanner to France 
					// and stop the scanning by using a RowFilter with a BinaryPrefixComparator
					assert.strictEqual(true,rows.length >= 3);
					assert.strictEqual('test_scanner_get_startRow_11',rows[0].key);
					assert.strictEqual('node_column_family:',rows[0].column);
					assert.strictEqual('test_scanner_get_startRow_111',rows[1].key);
					assert.strictEqual('node_column_family:',rows[1].column);
					this.delete();
				})
			})
		})
	});
}

exports['Get startRow and endRow'] = function(){
	utils.getClient(function(error, client){
		var rows = 
		[ {key:'test_scanner_get_startEndRow_1', column:'node_column_family', $:'v 1.3'}
		, {key:'test_scanner_get_startEndRow_11', column:'node_column_family', $:'v 1.1'}
		, {key:'test_scanner_get_startEndRow_111', column:'node_column_family', $:'v 1.2'}
		, {key:'test_scanner_get_startEndRow_2', column:'node_column_family', $:'v 2.2'}
		];
		client
		.getRow('node_table')
		.put(rows, function(error, success){
			assert.ifError(error);
			var options = {startRow: 'test_scanner_get_startEndRow_11', endRow: 'test_scanner_get_startEndRow_2'};
			client
			.getScanner('node_table')
			.create(options, function(error,id){
				assert.ifError(error);
				this.get(function(error,rows){
					assert.ifError(error);
					// http://brunodumon.wordpress.com/2010/02/17/building-indexes-using-hbase-mapping-strings-numbers-and-dates-onto-bytes/
					// Technically, you would set the start row for the scanner to France 
					// and stop the scanning by using a RowFilter with a BinaryPrefixComparator
					assert.strictEqual(2,rows.length);
					assert.strictEqual('test_scanner_get_startEndRow_11',rows[0].key);
					assert.strictEqual('node_column_family:',rows[0].column);
					assert.strictEqual('test_scanner_get_startEndRow_111',rows[1].key);
					assert.strictEqual('node_column_family:',rows[1].column);
					this.delete();
				})
			})
		})
	});
}

exports['Get batch'] = function(){
	utils.getClient(function(error, client){
		var rows = 
		[ {key:'test_scanner_get_batch_1', column:'node_column_family', $:'v 1.3'}
		, {key:'test_scanner_get_batch_2', column:'node_column_family', $:'v 1.1'}
		, {key:'test_scanner_get_batch_3', column:'node_column_family', $:'v 1.2'}
		, {key:'test_scanner_get_batch_4', column:'node_column_family', $:'v 2.2'}
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
				var expectCells = rows.map(function(row){return row.key;});
				expectCells.push(null);
				var self = this;
				var getCallback = function(error,cells){
					assert.ifError(error);
					if(cells&&expectCells.length>1){
						var expectCell = expectCells.shift();
						assert.strictEqual(1,cells.length);
						assert.strictEqual(expectCell,cells[0].key);
						self.get(getCallback);
					}else if(cells&&expectCells.length===1){
						// unrelevant cell
						self.get(getCallback);
					}else if(cells===null&&expectCells.length===1){
						var expectCell = expectCells.shift();
						assert.strictEqual(expectCell,cells);
						this.delete();
					}else{
						assert.ok(false);
					}
				}
				this.get(getCallback);
			})
		})
	});
}

exports['Get columns'] = function(){
	utils.getClient(function(error, hbase){
		var rows = 
		[ {key:'test_scanner_get_columns_1', column:'node_column_family:c1', $:'v 1.1'}
		, {key:'test_scanner_get_columns_1', column:'node_column_family:c2', $:'v 1.2'}
		, {key:'test_scanner_get_columns_1', column:'node_column_family:c3', $:'v 1.3'}
		, {key:'test_scanner_get_columns_1', column:'node_column_family:c4', $:'v 1.4'}
		, {key:'test_scanner_get_columns_2', column:'node_column_family:c1', $:'v 2.1'}
		, {key:'test_scanner_get_columns_2', column:'node_column_family:c2', $:'v 2.2'}
		, {key:'test_scanner_get_columns_2', column:'node_column_family:c3', $:'v 2.3'}
		, {key:'test_scanner_get_columns_2', column:'node_column_family:c4', $:'v 2.4'}
		, {key:'test_scanner_get_columns_3', column:'node_column_family:c1', $:'v 3.1'}
		, {key:'test_scanner_get_columns_3', column:'node_column_family:c2', $:'v 3.2'}
		, {key:'test_scanner_get_columns_3', column:'node_column_family:c3', $:'v 3.3'}
		, {key:'test_scanner_get_columns_3', column:'node_column_family:c4', $:'v 3.4'}
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
					assert.ifError(error);
					assert.strictEqual(6,rows.length);
					assert.strictEqual('test_scanner_get_columns_1',rows[0].key);
					assert.strictEqual('node_column_family:c2',rows[0].column);
					assert.strictEqual('test_scanner_get_columns_1',rows[1].key);
					assert.strictEqual('node_column_family:c4',rows[1].column);
					this.delete();
				})
			})
		})
	});
}

// Does not work : even if maxVersion is missing, only one version is returned by the scanner
// exports['Option maxVersions'] = function(){
// 	utils.getClient(function(error, hbase){
// 		var time = (new Date).getTime();
// 		hbase
// 		.getRow('node_table')
// 		.put([
// 			{key:'test_scanner_maxversions_1', column:'node_column_family::c', timestamp: time+1, $:'v 1.1'},
// 			{key:'test_scanner_maxversions_1', column:'node_column_family::c', timestamp: time+2, $:'v 1.2'},
// 			{key:'test_scanner_maxversions_1', column:'node_column_family::c', timestamp: time+3, $:'v 1.3'},
// 			{key:'test_scanner_maxversions_1', column:'node_column_family::c', timestamp: time+4, $:'v 1.4'}
// 		], function(error, success){
// 			assert.ifError(error);
// 			hbase
// 			.getScanner('node_table')
// 			.create({
// 				startRow: 'test_scanner_maxversions_1',
// 				endRow: 'test_scanner_maxversions_11',
// 				column: 'node_column_family::c',
// 				maxVersions: 3
// 			}, function(error,id){
// 				assert.ifError(error);
// 				this.get(function(error,cells){
// 					assert.ifError(error);
// 					console.log(cells);
// 					assert.strictEqual(3,cells.length);
// 					this.delete();
// 				})
// 			})
// 		})
// 	});
// }

exports['Get columns'] = function(){
	utils.getClient(function(error, client){
		client
		.getRow('node_table')
		.put([
			{key:'test_scanner_continue_1', column:'node_column_family', $:'v 1.3'},
			{key:'test_scanner_continue_2', column:'node_column_family', $:'v 1.1'},
			{key:'test_scanner_continue_3', column:'node_column_family', $:'v 1.2'},
			{key:'test_scanner_continue_4', column:'node_column_family', $:'v 2.2'}
		], function(error, success){
			assert.ifError(error);
			client
			.getScanner('node_table')
			.create({
				startRow: 'test_scanner_continue_1', 
				endRow: 'test_scanner_continue_4',
				batch: 2
			}, function(error,id){
				assert.ifError(error);
				var i = 1;
				this.get(function(error,rows){
					assert.ifError(error);
					if(rows===null&&i===5){
						// end of scanner
						return this.delete();
					}
					assert.strictEqual('test_scanner_continue_'+i,rows[0].key);
					i += 2;
					this.continue();
				})
			})
		})
	});
}
