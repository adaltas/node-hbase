
each = require 'each'
docgen = require 'docgen'

docgen 
  source: [
    "#{__dirname}/index.coffee"
    "#{__dirname}/client.coffee"
    "#{__dirname}/connection.coffee"
    "#{__dirname}/table.coffee"
    "#{__dirname}/row.coffee"
    "#{__dirname}/scanner.coffee"
  ]
  destination: [
    "#{__dirname}/../doc/"
    process.env.HBASE_DOC
  ]
  jekyll: 
    language: 'en',
    layout: 'page',
    comments: 'false'
    sharing: 'false'
    footer: 'false'
    navigation: 'hbase'
    github: 'https://github.com/wdavidw/node-hbase'
  , (err, hum) ->
    console.log 'Documentation generated'