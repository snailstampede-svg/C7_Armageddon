#!/bin/bash
# 1. Update and install core dependencies
dnf update -y
dnf install -y python3-pip amazon-cloudwatch-agent rsyslog

# 2. Start rsyslog immediately (Required for AL2023 to create /var/log/messages)
systemctl enable rsyslog
systemctl start rsyslog

# 3. Install Python dependencies
/usr/bin/python3 -m pip install flask pymysql boto3

# 4. Deploy the Python Application
mkdir -p /opt/rdsapp
cat >/opt/rdsapp/app.py <<'PY'
import json
import os
import boto3
import pymysql
from flask import Flask, request

REGION = os.environ.get("AWS_REGION", "ap-southeast-7")
SECRET_ID = os.environ.get("SECRET_ID", "lab/rds/mysql_v4")

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
        database=c.get("dbname", "lab1cdb"), # Matches your Terraform DB Name
        autocommit=True
    )

app = Flask(__name__)

@app.route("/")
def home():
    return "<h2>EC2 → RDS Notes App</h2><p>GET /init</p><p>POST /add?note=hello</p>"

@app.route("/init")
def init_db():
    c = get_db_creds()
    conn = pymysql.connect(
        host=c["host"], user=c["username"], password=c["password"], 
        port=int(c.get("port", 3306)), autocommit=True
    )
    cur = conn.cursor()
    db_name = c.get("dbname", "lab1cdb")
    cur.execute(f"CREATE DATABASE IF NOT EXISTS {db_name};")
    cur.execute(f"USE {db_name};")
    cur.execute("CREATE TABLE IF NOT EXISTS notes (id INT AUTO_INCREMENT PRIMARY KEY, note VARCHAR(255) NOT NULL);")
    cur.close()
    conn.close()
    return f"Initialized {db_name} + notes table."

@app.route("/add", methods=["POST", "GET"])
def add_note():
    note = request.args.get("note", "").strip()
    if not note: return "Missing note param", 400
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("INSERT INTO notes(note) VALUES(%s);", (note,))
    cur.close()
    conn.close()
    return f"Inserted note: {note}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
PY

# 5. Configure CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}",
            "retention_in_days": 7
          }
        ]
      }
    }
  }
}
EOF

# 6. Start the CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# 7. Setup and Start Systemd Service
cat >/etc/systemd/system/rdsapp.service <<EOF
[Unit]
Description=EC2 to RDS Notes App
After=network.target

[Service]
WorkingDirectory=/opt/rdsapp
Environment=SECRET_ID=${secret_id}
Environment=AWS_REGION=${region}
ExecStart=/usr/bin/python3 /opt/rdsapp/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable rdsapp
systemctl start rdsapp
