---
title: "Node Hbase: getting started"
date: 2015-01-26T22:21:40.052Z
language: en
layout: page
comments: false
sharing: false
footer: false
navigation: hbase
github: https://github.com/wdavidw/node-hbase
---

About HBase
-----------

HBase is part of the Hadoop ecosystem from the Apache Software Foundation. It is a column oriented database (think NoSql) that really scale and is modelled after Google papers and its BigTable database.

Installing HBase
----------------

We found the cloudera distribution to be the easiest way to get started. If you run Ubuntu, Debian or RedHat, the packages are integrated with apt-get and yum. However, desptite respecting the Unix conventions, we found the installation quite inconvient, having constantly to search for config, bin, data files all dispatched over the filesystem. For this reason, we usually download the packages from `http://archive.cloudera.com/cdh/3/` and install each of them manually inside a single folder. At minimum, you'll need to install hadoop and hbase.

Starting HBase
--------------

It seems like Stargate took the place of the old REST namespace. However, i need confirmation on this one. So if i'm right, assuming `${HBASE_HOME}/bin` is in your classpath, starting HBase with REST connector is as follow:

```bash
start-hbase.sh
hbase-daemon.sh start rest
```

And stoping:

```bash
hbase-daemon.sh stop rest
stop-hbase.sh
```

Or

```bash
ps ax | grep hbase | awk '{print $1}' | xargs kill -9
```

Installing node-hbase
---------------------

You can get the source code from GitHub with the git command `git clone http://github.com/wdavidw/node-hbase.git` and place it inside your project. 
Then, simply copy or link the lib/csv.js file into your $HOME/.node_libraries folder or inside a declared path folder.

Node-hbase is also integrated to npm and can be installed with

```bash
npm install hbase
```

Creating a new instance
-----------------------

```javascript
var hbase = require('hbase');
var client = hbase({
  host: '127.0.0.1',
  port: 8080
});
```

Or

```javascript
var hbase = require('hbase');
var client = new hbase.Client({
  host: '127.0.0.1',
  port: 8080
});
```
