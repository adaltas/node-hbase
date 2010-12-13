
// Called by "testFilter.js"

var assert = require('assert');

module.exports = {
	simple: function(client){
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
	}
}