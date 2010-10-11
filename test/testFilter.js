
var utils = require('./utils')
  , hbase = require('hbase')
  , Scanner = require('hbase').Scanner;

//{"op":"LESS","type":"RowFilter","comparator":{"value":"dGVzdFJvd09uZS0y","type":"BinaryComparator"}}
//{"op":"LESS_OR_EQUAL","type":"RowFilter","comparator":{"value":"dGVzdFJvd09uZS0y","type":"BinaryComparator"}}
//{"op":"NOT_EQUAL","type":"RowFilter","comparator":{"value":"dGVzdFJvd09uZS0y","type":"BinaryComparator"}}
//{"op":"GREATER_OR_EQUAL","type":"RowFilter","comparator":{"value":"dGVzdFJvd09uZS0y","type":"BinaryComparator"}}
//{"op":"GREATER","type":"RowFilter","comparator":{"value":"dGVzdFJvd09uZS0y","type":"BinaryComparator"}}
//{"op":"NOT_EQUAL","type":"RowFilter","comparator":{"value":"dGVzdFJvd09uZS0y","type":"BinaryComparator"}}
//{"op":"EQUAL","type":"RowFilter","comparator":{"value":".+-2","type":"RegexStringComparator"}}
//{"op":"EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlT25l","type":"BinaryComparator"}}
//{"op":"EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlVHdv","type":"BinaryComparator"}}
//{"op":"EQUAL","type":"ValueFilter","comparator":{"value":"testValue((One)|(Two))","type":"RegexStringComparator"}}
//{"op":"LESS","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlVHdv","type":"BinaryComparator"}}
//{"op":"LESS_OR_EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlVHdv","type":"BinaryComparator"}}
//{"op":"LESS_OR_EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlT25l","type":"BinaryComparator"}}
//{"op":"NOT_EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlT25l","type":"BinaryComparator"}}
//{"op":"GREATER_OR_EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlT25l","type":"BinaryComparator"}}
//{"op":"GREATER","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlT25l","type":"BinaryComparator"}}
//{"op":"NOT_EQUAL","type":"ValueFilter","comparator":{"value":"dGVzdFZhbHVlT25l","type":"BinaryComparator"}}
//{"type":"SkipFilter","filters":[{"op":"NOT_EQUAL","type":"QualifierFilter","comparator":{"value":"dGVzdFF1YWxpZmllck9uZS0y","type":"BinaryComparator"}}]}
//{"op":"MUST_PASS_ALL","type":"FilterList","filters":[{"op":"EQUAL","type":"RowFilter","comparator":{"value":".+-2","type":"RegexStringComparator"}},{"op":"EQUAL","type":"QualifierFilter","comparator":{"value":".+-2","type":"RegexStringComparator"}},{"op":"EQUAL","type":"ValueFilter","comparator":{"value":"one","type":"SubstringComparator"}}]}
//{"op":"MUST_PASS_ONE","type":"FilterList","filters":[{"op":"EQUAL","type":"RowFilter","comparator":{"value":".+Two.+","type":"RegexStringComparator"}},{"op":"EQUAL","type":"QualifierFilter","comparator":{"value":".+-2","type":"RegexStringComparator"}},{"op":"EQUAL","type":"ValueFilter","comparator":{"value":"one","type":"SubstringComparator"}}]}


exports['Option filter'] = function(assert){
	utils.getClient(function(error, client){
		var time = (new Date).getTime();
		client
		.getRow('node_table')
		.put([
			{key:'test_filter_row_1', column:'node_column_family:aa', $:'aa'},
			{key:'test_filter_row_1', column:'node_column_family:aa', $:'ab'},
			{key:'test_filter_row_1', column:'node_column_family:aa', $:'ac'},
			{key:'test_filter_row_2', column:'node_column_family:ab', $:'ba'},
			{key:'test_filter_row_2', column:'node_column_family:bb', $:'bb'},
			{key:'test_filter_row_2', column:'node_column_family:bc', $:'bc'},
			{key:'test_filter_row_3', column:'node_column_family:ca', $:'cc'},
			{key:'test_filter_row_3', column:'node_column_family:cb', $:'cc'},
			{key:'test_filter_row_3', column:'node_column_family:cc', $:'cc'}
		], function(error, success){
			// Test RowFilter EQUAL with BinaryComparator
			// Based on the key
			client
			.getScanner('node_table')
			.create({
				startRow: 'test_filter_row_1',
				filter: {'op':'EQUAL','type':'RowFilter','comparator':{'value':'test_filter_row_2','type':'BinaryComparator'}}
			}, function(error,id){
				assert.ifError(error);
				this.get(function(error,cells){
					assert.ifError(error);
					assert.strictEqual(3,cells.length);
					this.delete();
				})
			})
			// Test FirstKeyOnlyFilter
			// Only return the first KV from each row.
			client
			.getScanner('node_table')
			.create({
				startRow: 'test_filter_row_1',
				filter: {'type':'FirstKeyOnlyFilter'}
			}, function(error,id){
				assert.ifError(error);
				this.get(function(error,cells){
					assert.ifError(error);
					assert.strictEqual(true,cells.length > 2);
					assert.strictEqual('test_filter_row_1', cells[0].key);
					assert.strictEqual('test_filter_row_2', cells[1].key);
					assert.strictEqual('test_filter_row_3', cells[2].key);
					this.delete();
				})
			})
			// Test FilterList and RegexStringComparator
			client
			.getScanner('node_table')
			.create({
				startRow: 'test_filter_row_1',
				filter: {
					"op":"MUST_PASS_ALL","type":"FilterList","filters":[
						{"op":"EQUAL","type":"RowFilter","comparator":{"value":"test_filter_row_.*","type":"RegexStringComparator"}},
						{"op":"EQUAL","type":"RowFilter","comparator":{"value":".+2$","type":"RegexStringComparator"}}
					]}
			}, function(error,id){
				assert.ifError(error);
				this.get(function(error,cells){
					assert.ifError(error);
					assert.strictEqual(3,cells.length);
					assert.strictEqual('test_filter_row_2', cells[0].key);
					assert.strictEqual('test_filter_row_2', cells[1].key);
					assert.strictEqual('test_filter_row_2', cells[2].key);
					this.delete();
				})
			})
			// Test ValueFilter
			client
			.getScanner('node_table')
			.create({
				startRow: 'test_filter_row_1',
				endRow: 'test_filter_row_4',
				filter: {"op":"EQUAL","type":"ValueFilter","comparator":{"value":"bb","type":"BinaryComparator"}}
			}, function(error,id){
				assert.ifError(error);
				this.get(function(error,cells){
					assert.ifError(error);
					assert.strictEqual(1,cells.length);
					assert.strictEqual('test_filter_row_2', cells[0].key);
					assert.strictEqual('node_column_family:bb', cells[0].column);
					this.delete();
				})
			})
		})
	});
}
