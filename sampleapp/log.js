const elasticsearch = require('elasticsearch');
const winston = require('winston');
const Elasticsearch = require('winston-elasticsearch');

const client = new elasticsearch.Client({
  host: 'localhost:9200',
  log: 'trace',
  apiVersion: '7.4',
});

const esTransportOpts = {
  level: 'info',
  client,
  indexPrefix: 'testapp',
};
var logger = winston.createLogger({
  transports: [
    new Elasticsearch(esTransportOpts)
  ]
});

module.exports.log = logger;
