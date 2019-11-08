require('elastic-apm-node').start({
  serviceName: process.env.appname,
  serverUrl: 'http://apmserver:8200',
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
  console.log(process.env.backendurl);
  axios.get(`${process.env.backendurl}/backend`)
    .then(response => res.json({
      data: process.env.appname,
      response: response.data,
    }));
});

app.use('/backend', (req, res, next) => {
  res.json({response: 'from backend'});
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  log.info(`server starting on http://localhost:${port}`);
});
