require('elastic-apm-node').start({
  serviceName: process.env.appname,
  serverUrl: process.env.apmhost,
});

const axios = require('axios');
const express = require('express');
const { log } = require('./log');

const app = express();

const bodyParser = require('body-parser');


app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.use('/healthcheck', (req, res, next) => {
  log.info('get a request', { a: 'test' });
  res.json({
    status: 'ok',
  });
});

app.use('/apmtest', (req, res, next) => {
  log.info('apmtest log');
  axios.get(`${process.env.backendurl}/backend`)
    .then(response => res.json({
      data: process.env.appname,
      response: response.data,
    }));
});

app.use('/backend', (req, res, next) => {
  log.info('backend log');
  res.json({response: 'from backend'});
});

app.use('/errortest', (req, res, next) => {
  log.error('ops, it is an error');
  res.status(500).send();
  throw new Error('it is an error');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  log.info(`server starting on http://localhost:${port}`);
});  
