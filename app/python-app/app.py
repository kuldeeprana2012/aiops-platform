from flask import Flask, Response, jsonify
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import logging
import os

app = Flask(__name__)
log_dir = os.path.join(os.path.dirname(__file__), 'logs')
os.makedirs(log_dir, exist_ok=True)
log_file = os.path.join(log_dir, 'python-app.log')
logging.basicConfig(
    filename=log_file,
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)

REQUEST_COUNTER = Counter('http_requests_total', 'HTTP requests total', ['method', 'endpoint', 'status_code'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'Request latency', ['method', 'endpoint'])

@app.route('/api/hello')
def hello():
    with REQUEST_LATENCY.labels(method='GET', endpoint='/api/hello').time():
        REQUEST_COUNTER.labels(method='GET', endpoint='/api/hello', status_code='200').inc()
        logging.info('Hello endpoint called', extra={'endpoint': '/api/hello', 'status_code': 200})
        return jsonify({'message': 'Hello from Python AIOps app'})

@app.route('/api/error')
def error():
    with REQUEST_LATENCY.labels(method='GET', endpoint='/api/error').time():
        REQUEST_COUNTER.labels(method='GET', endpoint='/api/error', status_code='500').inc()
        logging.error('Simulated error route called', extra={'endpoint': '/api/error', 'status_code': 500})
        return jsonify({'error': 'Simulated error'}), 500

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
