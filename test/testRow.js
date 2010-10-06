
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
		.put('node_column_family:node_column', 'my value', function(error, success){
			assert.ifError(error);
			assert.strictEqual(true,success);
		})
	});
};

exports['Put multiple columns'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_put_multiple_columns')
		.delete(function(error,success){
			assert.ifError(error);
			this.put(['node_column_family:node_column_1','node_column_family:node_column_2'], ['my value 1','my value 2'], function(error, success){
				assert.ifError(error);
				assert.strictEqual(true,success);
				this.get(function(error,cells){
					assert.strictEqual(2,cells.length);
					assert.strictEqual('node_column_family:node_column_1',cells[0].column);
					assert.strictEqual('my value 1',cells[0].$);
					assert.strictEqual('node_column_family:node_column_2',cells[1].column);
					assert.strictEqual('my value 2',cells[1].$);
				})
			})
		})
	});
};

exports['Get row'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_get_row')
		.delete(function(error, value){
			this.put(
				['node_column_family:column_1','node_column_family:column_2'], 
				['my value 1','my value 2'], 
				function(error, value){
					this.get(function(error, cells){
						assert.ifError(error);
						assert.strictEqual(true,cells instanceof Array);
						assert.strictEqual(2,cells.length);
						assert.strictEqual('undefined',typeof cells[0].key);
						assert.strictEqual('node_column_family:column_1',cells[0].column);
						assert.strictEqual('my value 1',cells[0].$);
						assert.strictEqual('node_column_family:column_2',cells[1].column);
						assert.strictEqual('my value 2',cells[1].$);
					})
				}
			)
		})
	});
};

exports['Get row with suffix globbing'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_get_globbing_1')
		.delete(function(error,success){
			assert.ifError(error);
			this.put('node_column_family:column_1', 'my value 1', function(error, success){
				assert.ifError(error);
				hbase
				.getRow('node_table', 'test_row_get_globbing_2')
				.delete(function(error, success){
					assert.ifError(error);
					this.put('node_column_family:column_1', 'my value 2', function(error, success){
						assert.ifError(error);
						hbase
						.getRow('node_table','test_row_get_globbing_*')
						.get(function(error, cells){
							assert.ifError(error);
							assert.strictEqual(2,cells.length);
							assert.strictEqual('test_row_get_globbing_1',cells[0].key);
							assert.strictEqual('test_row_get_globbing_2',cells[1].key);
						})
					})
				})
			})
		})
	});
};

exports['Get column'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_get_column')
		.delete(function(error, value){
			this.put('node_column_family', 'my value', function(error, value){
				// curl -H "Accept: application/json" http://localhost:8080/node_table/test_row_get_column/node_column_family
				this.get('node_column_family',function(error, cells){
					assert.ifError(error);
					assert.strictEqual(true,cells instanceof Array);
					assert.strictEqual(1,cells.length);
					assert.strictEqual('node_column_family:',cells[0].column);
					assert.strictEqual('my value',cells[0].$);
				})
			})
		})
	});
};

exports['Get escape'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_get_escape!\'éè~:@#.?*()') // "/, "
		.delete(function(error, value){
			assert.ifError(error);
			this.put('node_column_family:!\'éè~:@#.?*()', 'my value', function(error, success){
				assert.ifError(error);
				hbase
				.getRow('node_table', 'test_get_escape!\'éè~:@#.?*()')
				.get(function(error,value){
					assert.ifError(error);
					assert.strictEqual(1,value.length);
					assert.strictEqual('node_column_family:!\'éè~:@#.?*()',value[0].column);
				})
			})
		})
	});
};

exports['Get option v'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_get_v')
		.delete(function(error, value){
			this.put(['node_column_family','node_column_family'], ['v 1','v 2'], function(error, value){
				this.get('node_column_family', {v:1},function(error, cells){
					assert.ifError(error);
					assert.strictEqual(true,cells instanceof Array);
					assert.strictEqual(1,cells.length);
					assert.strictEqual('node_column_family:',cells[0].column);
					assert.strictEqual('v 2',cells[0].$);
				})
			})
		})
	});
};

exports['Get multiple columns'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_get_multiple_columns')
		.delete(function(error, value){
			assert.ifError(error);
			this.put(['node_column_family:c1','node_column_family:c2','node_column_family:c3'], ['v 1','v 2','v 3'], function(error, value){
				assert.ifError(error);
				this.get(['node_column_family:c1','node_column_family:c3'],function(error, cells){
					assert.ifError(error);
					assert.strictEqual(2,cells.length);
					assert.strictEqual('node_column_family:c1',cells[0].column);
					assert.strictEqual('v 1',cells[0].$);
					assert.strictEqual('node_column_family:c3',cells[1].column);
					assert.strictEqual('v 3',cells[1].$);
				})
			})
		})
	});
};

exports['Get missing'] = function(assert){
	utils.getHBase(function(error, hbase){
		// on row missing
		hbase
		.getRow('node_table', 'test_row_get_row_missing')
		.get('node_column_family',function(error, value){
			assert.strictEqual(404,error.code);
			assert.strictEqual(null,value);
		})
		// on column missing
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

exports['Exists row'] = function(assert){
	utils.getHBase(function(error, hbase){
		// Row exists
		hbase
		.getRow('node_table', 'test_row_exist_row')
		.put('node_column_family', 'value', function(error, value){
			this.exists(function(error, exists){
				assert.ifError(error);
				assert.strictEqual(true,exists);
			})
		});
		// Row does not exists
		hbase
		.getRow('node_table', 'test_row_exist_row_missing')
		.exists(function(error, exists){
			assert.ifError(error);
			assert.strictEqual(false, exists);
		})
	})
}

exports['Exists column'] = function(assert){
	utils.getHBase(function(error, hbase){
		// Row exists
		hbase
		.getRow('node_table', 'test_row_exist_column')
		.put('node_column_family', 'value', function(error, value){
			this.exists('node_column_family', function(error, exists){
				assert.ifError(error);
				assert.strictEqual(true,exists);
			})
		});
		// Row does not exists
		hbase
		.getRow('node_table', 'test_row_exist_column_with_row_missing')
		.exists('node_column_family', function(error, exists){
			assert.ifError(error);
			assert.strictEqual(false, exists);
		})
		// Row exists and column family does not exists
		hbase
		.getRow('node_table', 'test_row_exist_column_with_column_missing')
		.put('node_column_family', 'value', function(error, value){
			this.exists('node_column_family_missing', function(error, exists){
				assert.ifError(error);
				assert.strictEqual(false, exists);
			})
		});
		// Row exists and column family exists and column does not exits
		hbase
		.getRow('node_table', 'test_row_exist_column_with_column_missing')
		.put('node_column_family', 'value', function(error, value){
			this.exists('node_column_family:column_missing', function(error, exists){
				assert.ifError(error);
				assert.strictEqual(false, exists);
			})
		});
	});
};

exports['Delete row'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_delete_row')
		.put('node_column_family:column_1', 'my value', function(error, value){
			this.put('node_column_family:column_2', 'my value', function(error, value){
				this.delete(function(error, success){
					assert.ifError(error);
					assert.strictEqual(true, success);
					this.exists(function(error, exists){
						assert.ifError(error);
						assert.strictEqual(false, exists);
					})
				})
			})
		})
	});
};

exports['Delete column'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_delete_column')
		.put('node_column_family:c_1', 'my value', function(error, value){
			this.put('node_column_family:c_2', 'my value', function(error, value){
				this.delete('node_column_family:c_2', function(error, success){
					assert.ifError(error);
					assert.strictEqual(true, success);
					this.exists('node_column_family:c_1', function(error, exists){
						assert.ifError(error);
						assert.strictEqual(true, exists);
					})
					this.exists('node_column_family:c_2', function(error, exists){
						assert.ifError(error);
						assert.strictEqual(false, exists);
					})
				})
			})
		})
	});
};

exports['Delete multiple columns'] = function(assert){
	utils.getHBase(function(error, hbase){
		hbase
		.getRow('node_table', 'test_row_delete_multiple_columns')
		.delete(function(error, success){
			assert.ifError(error);
			this.put(['node_column_family:c_1','node_column_family:c_2','node_column_family:c_3'], ['v 1','v 2','v 3'], function(error, value){
				assert.ifError(error);
				this.delete(['node_column_family:c_1','node_column_family:c_3'], function(error, success){
					assert.ifError(error);
					assert.strictEqual(true, success);
					this.exists('node_column_family:c_1', function(error, exists){
						assert.ifError(error);
						assert.strictEqual(false, exists);
					})
					this.exists('node_column_family:c_2', function(error, exists){
						assert.ifError(error);
						assert.strictEqual(true, exists);
					})
					this.exists('node_column_family:c_3', function(error, exists){
						assert.ifError(error);
						assert.strictEqual(false, exists);
					})
					this.exists(function(error, exists){
						assert.ifError(error);
						assert.strictEqual(true, exists);
					})
				})
			})
		})
	});
};

