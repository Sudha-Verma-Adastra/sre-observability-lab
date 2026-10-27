import time
from flask import Flask, Response, jsonify, request
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)
REQUESTS = Counter("http_requests_total", "Total HTTP requests", ["method", "endpoint", "status"])
LATENCY = Histogram("http_request_duration_seconds", "HTTP request duration in seconds", ["method", "endpoint"])

@app.before_request
def start_timer():
    request._started_at = time.perf_counter()

@app.after_request
def record_metrics(response):
    endpoint = request.url_rule.rule if request.url_rule else "unmatched"
    elapsed = time.perf_counter() - getattr(request, "_started_at", time.perf_counter())
    REQUESTS.labels(request.method, endpoint, str(response.status_code)).inc()
    LATENCY.labels(request.method, endpoint).observe(elapsed)
    return response

@app.get("/")
def index():
    return jsonify(service="sre-observability-demo", status="ok")

@app.get("/health")
def health():
    return jsonify(status="healthy"), 200

@app.get("/work")
def work():
    time.sleep(0.05)
    return jsonify(result="completed")

@app.get("/error")
def error():
    return jsonify(error="intentional demo error"), 500

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)
