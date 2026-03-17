#!/bin/bash
# No spaces or lines should exist above the shebang!
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Deploying Honors App with Secret: ${secret_id}"

# FIX: Create the parent and static directory simultaneously
mkdir -p /opt/rdsapp/static 

# Create index.html (This is the file you will later invalidate)
cat <<'HTML' > /opt/rdsapp/static/index.html
<!DOCTYPE html>
<html>
<head><title>SnailTek Invalidation Lab2b-Be-A-Man-B</title></head>
<body>
    <h1>System Status: Online</h1>
    <p>Version: 1.0.0</p>
    <p>Proof of Invalidation Success-Completed!!!</p>
</body>
</html>
HTML

cat <<'PY' > /opt/rdsapp/app.py
import json, os, boto3, pymysql
from flask import Flask, make_response, send_from_directory
from datetime import datetime

# Variables passed from Terraform templatefile
REGION = "${region}"
SECRET_ID = "${secret_id}"

secrets = boto3.client("secretsmanager", region_name=REGION)

def get_db_creds():
    resp = secrets.get_secret_value(SecretId=SECRET_ID)
    return json.loads(resp["SecretString"])

app = Flask(__name__)
# Define absolute path for static assets
STATIC_DIR = '/opt/rdsapp/static'

# 1. ALB Health Check (Crucial for infrastructure)
@app.route("/")
def health(): 
    return "OK", 200

# 2. Static Entrypoint (Target for Part B & D Invalidations)
@app.route('/static/<path:path>')
def serve_static(path):
    # This explicitly maps the URL path to the filesystem folder
    return send_from_directory(STATIC_DIR, path)

@app.route('/static/index.html')
def serve_index():
    return send_from_directory(STATIC_DIR, 'index.html')

# 3. Public API (Origin-Driven Caching Proof)
@app.route("/api/public-feed")
def public_feed():
    data = {"server_time_utc": datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')}
    resp = make_response(json.dumps(data))
    # Honors requirement: Use s-maxage for origin-driven caching
    resp.headers['Cache-Control'] = 'public, s-maxage=30, max-age=0'
    resp.headers['Content-Type'] = 'application/json'
    return resp

# 4. Private API (Safety Proof - No Caching)
@app.route("/api/list")
def list_notes():
    resp = make_response("<h3>Private Data - Notes List</h3>")
    # Honors requirement: Ensure private data is never cached
    resp.headers['Cache-Control'] = 'private, no-store'
    return resp

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
PY

# Create the systemd service
cat <<'SERVICE' > /etc/systemd/system/rdsapp.service
[Unit]
Description=Flask RDS App
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/rdsapp/app.py
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now rdsapp