
<pre style="font-family:courier">
 ___   _           _          _     _ ______                   
|   \ | |         | |        | |   | |____  \                  
| |\ \| | ___   __| |_____   | |___| |____)  )_____  ___ _____ 
| | \   |/ _ \ / _  | ___ |  |  ___  |  __  ((____ |/___) ___ |
| |  \  | |_| ( |_| | ____|  | |   | | |__)  ) ___ |___ | ____|
|_|   |_|\___/ \____|_____)  |_|   |_|______/\_____(___/|_____) New BSD License
</pre>

Node HBase is a Node.JS client for the Apache HBase database. It use the Rest API (Stargate) to communicate with HBase. Currently, all the API is implemented and the data exchange format is JSON (but protocol buffer could follow).

Apache HBase is part of the Hadoop ecosystem. It describes itself as the Hadoop database optimized for random, realtime read/write access to big data. It is an open-source, distributed, versioned, column-oriented store modeled after Google' Bigtable.

Client features include:
-   Intuitive API following HBase naming conventions
-   Documentation and tests
-   Full Implementation of the REST API
-   Transparent encoding/decoding of values
-   Scanner and filter support

Installing
----------

Via [npm](http://github.com/isaacs/npm):

```bash
    npm install hbase
```

Quick example
-------------

This code create a new HBase instance, create a table and a column family, insert a few records and traverse them.

```javascript
	var assert = require('assert');
	var hbase = require('hbase');
	
	hbase({ host: '127.0.0.1', port: 8080 })
	.getTable('my_table' )
	.create('my_column_family', function(err, success){
		this
		.getRow('my_row')
		.put('my_column_family:my_column', 'my value', function(err, success){
			this.get('my_column_family', function(err, cells){
				this.exists(function(err, exists){
					assert.ok(exists);
				});
			});
		});
	});
```

Scanner Filters
-----------------

It can be quite a pain to figure out what options can be sent
with a scanner request. [Marc Trudel](https://github.com/stelcheck) has 
published a few examples [here](https://gist.github.com/3979381). 

Running the tests
-----------------

Tests are executed with expresso. To install it, simple use 
`npm install -g expresso`. Before running the tests the first time, copy the
file "./test/properties.json.sample" to "./test/properties.json" and make the
appropriate changes.

To run the tests

```bash
	expresso -s -t 100000
```

To instrument the tests
```bash
	expresso --cov -s -t 100000
```

Related projects
----------------

*   Official Apache HBase project: <http://hbase.apache.org/>
*   Brother project Pop HBase (PHP): <https://github.com/pop/pop_hbase>


Contributors
------------

*   David Worms: <https://github.com/wdavidw>
*   Michael Kurze: <https://github.com/michaelku>
*   Michal Taborsky: <https://github.com/whizz>
