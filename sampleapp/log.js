const elasticsearch = require('elasticsearch');
const winston = require('winston');
const Elasticsearch = require('winston-elasticsearch');

const client = new elasticsearch.Client({
  host: process.env.eshost,
  log: 'trace',
  apiVersion: '7.4',
});

const esTransportOpts = {
  level: 'info',
  client,
  indexPrefix: process.env.appname,
};
var logger = winston.createLogger({
  transports: [
    new Elasticsearch(esTransportOpts)
  ]
});

module.exports.log = logger;
