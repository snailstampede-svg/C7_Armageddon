#!/bin/bash
# Note: In a Golden AMI, the dnf/pip commands below would already be baked in.
# This script would then only focus on the file creation and service start.

mkdir -p /opt/rdsapp
cat >/opt/rdsapp/app.py <<'PY'
import json
import os
import boto3
import pymysql
from flask import Flask, request, make_response
from datetime import datetime

REGION = os.environ.get("AWS_REGION", "us-east-1")
SECRET_ID = os.environ.get("SECRET_ID", "lab/rds/mysql")

secrets = boto3.client("secretsmanager", region_name=REGION)

def get_db_creds():
    resp = secrets.get_secret_value(SecretId=SECRET_ID)
    return json.loads(resp["SecretString"])

def get_conn():
    c = get_db_creds()
    return pymysql.connect(
        host=c["host"], 
        user=c["username"], 
        password=c["password"], 
        port=int(c.get("port", 3306)), 
        database=c.get("dbname", "labdb"), 
        autocommit=True
    )

app = Flask(__name__)

# --- HONORS ENDPOINT: PUBLIC FEED (Cacheable) ---
@app.route("/api/public-feed")
def public_feed():
    data = {
        "server_time_utc": datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S'),
        "message_of_the_minute": "Keep your VPC hardened and your cache warm."
    }
    resp = make_response(json.dumps(data))
    # Honors Requirement: s-maxage=30 tells CloudFront to cache for 30s
    resp.headers['Cache-Control'] = 'public, s-maxage=30, max-age=0'
    resp.headers['Content-Type'] = 'application/json'
    return resp

# --- HONORS ENDPOINT: PRIVATE LIST (Non-Cacheable) ---
@app.route("/api/list")
def list_notes():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SELECT id, note FROM notes ORDER BY id DESC;")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    
    out = "<h3>Notes</h3><ul>"
    for r in rows:
        out += f"<li>{r[0]}: {r[1]}</li>"
    out += "</ul>"
    
    resp = make_response(out)
    # Honors Requirement: private, no-store prevents CloudFront from caching
    resp.headers['Cache-Control'] = 'private, no-store'
    return resp

# Standard /init and /add endpoints remain the same...
@app.route("/init")
def init_db():
    c = get_db_creds()
    conn = pymysql.connect(host=c["host"], user=c["username"], password=c["password"], port=int(c.get("port", 3306)), autocommit=True)
    cur = conn.cursor()
    cur.execute("CREATE DATABASE IF NOT EXISTS labdb;")
    cur.execute("USE labdb;")
    cur.execute("CREATE TABLE IF NOT EXISTS notes (id INT AUTO_INCREMENT PRIMARY KEY, note VARCHAR(255) NOT NULL);")
    cur.close()
    conn.close()
    return "Initialized."

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
PY

# systemd service remains the same as your original 1a_user_data.sh
cat >/etc/systemd/system/rdsapp.service <<'SERVICE'
[Unit]
Description=EC2 to RDS Notes App
After=network.target

[Service]
WorkingDirectory=/opt/rdsapp
Environment=SECRET_ID=lab/rds/mysql
ExecStart=/usr/bin/python3 /opt/rdsapp/app.py
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable rdsapp
systemctl start rdsapp
