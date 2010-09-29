
<pre>
 _______           _          _     _ ______                   
(_______)         | |        (_)   (_|____  \                  
 _     _  ___   __| |_____    _______ ____)  )_____  ___ _____ 
| |   | |/ _ \ / _  | ___ |  |  ___  |  __  ((____ |/___) ___ |
| |   | | |_| ( (_| | ____|  | |   | | |__)  ) ___ |___ | ____|
|_|   |_|\___/ \____|_____)  |_|   |_|______/\_____(___/|_____)
</pre>

Node HBase is a Node.JS client for HBase server. It use the Rest API (Stargate in previous versions) to communicate with HBase. Currently, the data exchange format is json but protocol buffer will follow.

Quick exemple
-------------

This code create a new HBase instance, create a table and a column family, insert a few records and traverse them.

	var hbase = require('hbase');
	
	hbase({ host: '127.0.0.1', port: 8080 })
	.getTable('node_hbase' )
	.create('node_hbase_column', function(error, success){
		...
	});

Installing
----------

Via git (or downloaded tarball):

    $ git clone http://github.com/wdavidw/node-hbase.git

Then, simply copy or link the lib/csv.js file into your $HOME/.node_libraries folder or inside a declared path folder.

Via [npm](http://github.com/isaacs/npm):

    $ npm install hbase

Running the tests
-----------------

Tests are executed with expresso. To install it, simple use `npm install expresso`.

To run the tests
	expresso -I lib test/test*

To develop with the tests watching at your changes
	expresso -w -I lib test/test*

To instrument the tests
	expresso -I lib --cov test/test*



Related projects
----------------

*   Official Apache HBase project: <http://hbase.apache.org/>
*   Brother project Pop HBase (PHP): <http://www.php-pop.org/pop_hbase.html>