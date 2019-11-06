const elasticsearch = require('elasticsearch');
const client = new elasticsearch.Client({
  host: '9.197.12.28:9200',
  log: 'trace',
  apiVersion: '7.4',
});

client.ping({
  // ping usually has a 3000ms timeout
  requestTimeout: 1000
}, function (error) {
  if (error) {
    console.trace('elasticsearch cluster is down!');
  } else {
    console.log('All is well');
  }
});
