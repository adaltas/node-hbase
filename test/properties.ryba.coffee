
###
With Ryba
echo hbase123 | kinit hbase@HADOOP.RYBA
hbase shell 2>/dev/null <<-CMD
  create 'node_table', 'node_column_family'
  grant 'ryba', 'RWC', 'node_table'
CMD
###

module.exports =
  protocol: 'https'
  host: "master3.ryba"
  port: 60080 # Default in CDH 8081
  test_table: false
  timeout: 60000
  test_table_modify: false
  cache: true
  krb5:
    principal: 'ryba@HADOOP.RYBA'
    password: 'test123'
    # service_principal: 'HTTP@master3.ryba'
