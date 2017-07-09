FROM sixeyed/hbase-stargate

# Install nginx
RUN yum install -y epel-release; yum clean all; yum install -y nginx --nogpgcheck

# Copy nginx proxy config
COPY nginx-proxy /etc/nginx/conf.d/proxy.conf

# Copy shell script and ensure that it's accessible
COPY launch-all.sh /opt/launch-all.sh
RUN chmod 777 /opt/launch-all.sh

# Expose port
EXPOSE 8100

CMD "/opt/launch-all.sh"