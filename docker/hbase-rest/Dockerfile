FROM nerdammer/hbase:1.1.2
MAINTAINER Elton Stoneman <elton@sixeyed.com>

ADD start-rest.sh /opt/hbase/bin/start-rest.sh
#Stargate
EXPOSE 8080
EXPOSE 8085
#run in pseudo-distributed mode and start Stargate
CMD /opt/hbase/bin/start-rest.sh
