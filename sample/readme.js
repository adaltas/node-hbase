
  var assert = require('assert');
  var hbase = require('hbase');
  
  hbase({ host: '127.0.0.1', port: 8080 })
  .table('my_table' )
  .create('my_column_family', function(err, success){
    this
    .row('my_row')
    .put('my_column_family:my_column', 'my value', function(err, success){
      this.get('my_column_family', function(err, cells){
        this.exists(function(err, exists){
          assert.ok(exists);
        });
      });
    });
  });
