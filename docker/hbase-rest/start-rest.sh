#!/bin/bash

/opt/hbase/bin/start-pseudo-distributed.sh > logmaster.log 2>&1 &

/opt/hbase/bin/hbase rest start

