#!/bin/bash
# No spaces or lines should exist above the shebang!
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Deploying Honors App with Secret: ${secret_id}"

mkdir -p /opt/rdsapp

cat <<'PY' > /opt/rdsapp/app.py
import json, os, boto3, pymysql
from flask import Flask, make_response
from datetime import datetime

# Variables passed from Terraform templatefile
REGION = "${region}"
SECRET_ID = "${secret_id}"

secrets = boto3.client("secretsmanager", region_name=REGION)

def get_db_creds():
    resp = secrets.get_secret_value(SecretId=SECRET_ID)
    return json.loads(resp["SecretString"])

app = Flask(__name__)

@app.route("/")
def health(): return "OK", 200

@app.route("/api/public-feed")
def public_feed():
    data = {"server_time_utc": datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S'), "source": "Automated"}
    resp = make_response(json.dumps(data))
    # REQUIRED FOR HONORS CACHING
    resp.headers['Cache-Control'] = 'public, s-maxage=30, max-age=0'
    resp.headers['Content-Type'] = 'application/json'
    return resp

@app.route("/api/list")
def list_notes():
    # ... your DB logic ...
    resp = make_response("<h3>Private Data - Notes List</h3>")
    # REQUIRED: Safety proof that private data is NEVER cached
    resp.headers['Cache-Control'] = 'private, no-store'
    return resp
    
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
PY

# Create the service
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