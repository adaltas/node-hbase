
// Called by "testFilter.js"

var assert = require('assert');

module.exports = {
	must_pass_all: function(client){
		// Test FilterList and RegexStringComparator
		client
		.getScanner('node_table')
		.create({
			startRow: 'test_filter|row_1',
			filter: {
				"op":"MUST_PASS_ALL","type":"FilterList","filters":[
					{"op":"EQUAL","type":"RowFilter","comparator":{"value":"test_filter\\|row_.*","type":"RegexStringComparator"}},
					{"op":"EQUAL","type":"RowFilter","comparator":{"value":".+2$","type":"RegexStringComparator"}}
				]}
		}, function(error,id){
			assert.ifError(error);
			this.get(function(error,cells){
				assert.ifError(error);
				assert.strictEqual(3,cells.length);
				assert.strictEqual('test_filter|row_2', cells[0].key);
				assert.strictEqual('test_filter|row_2', cells[1].key);
				assert.strictEqual('test_filter|row_2', cells[2].key);
				this.delete();
			})
		})
	},
	
}