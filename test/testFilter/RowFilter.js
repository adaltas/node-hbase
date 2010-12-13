
// Called by "testFilter.js"

var assert = require('assert');

module.exports = {
	equal_with_binary_comparator: function(client){
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
	}
}