const express = require('express');
const fs = require('fs');
const path = require('path');
const client = require('prom-client');

const app = express();
const logPath = path.resolve(__dirname, 'logs', 'node-app.log');
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ timeout: 5000 });

const httpRequestDurationMicroseconds = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

app.get('/api/hello', (req, res) => {
  const end = httpRequestDurationMicroseconds.startTimer();
  res.json({ message: 'Hello from Node AIOps app' });
  end({ method: req.method, route: req.path, status_code: 200 });
  fs.appendFileSync(logPath, JSON.stringify({
    timestamp: new Date().toISOString(),
    level: 'info',
    message: 'hello endpoint called',
    route: req.path,
    status_code: 200
  }) + '\n');
});

app.get('/api/error', (req, res) => {
  const end = httpRequestDurationMicroseconds.startTimer();
  res.status(500).json({ error: 'Simulated error' });
  end({ method: req.method, route: req.path, status_code: 500 });
  fs.appendFileSync(logPath, JSON.stringify({
    timestamp: new Date().toISOString(),
    level: 'error',
    message: 'simulated error hit',
    route: req.path,
    status_code: 500
  }) + '\n');
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

const port = 4000;
app.listen(port, () => {
  console.log(`Node app listening on port ${port}`);
});
