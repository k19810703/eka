const apm = require('elastic-apm-node').start({
  serviceName: 'apmtest',
  serverUrl: 'http://localhost:8200',
});
const express = require('express');
const { log } = require('./log');

const app = express();

const bodyParser = require('body-parser');


app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.use('/test', (req, res, next) => {
  log.info('get a request', { a: 'test' });
  res.json({
    status: 'ok',
  });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  log.info(`server starting on http://localhost:${port}`);
});
