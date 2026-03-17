cat <<'PY' > /opt/rdsapp/app.py
import json, os, boto3, pymysql
from flask import Flask, jsonify
from datetime import datetime

REGION = "${region}"
SECRET_ID = "${secret_id}"

app = Flask(__name__)

def get_db_connection():
    # 1. Get the Secret
    client = boto3.client("secretsmanager", region_name=REGION)
    resp = client.get_secret_value(SecretId=SECRET_ID)
    creds = json.loads(resp["SecretString"])
    
    # 2. Connect to RDS
    return pymysql.connect(
        host=creds['host'],
        user=creds['username'],
        password=creds['password'],
        database=creds['dbname'],
        cursorclass=pymysql.cursors.DictCursor
    )

@app.route("/")
def health():
    return "OK", 200

@app.route("/api/db-test")
def db_test():
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute("SELECT VERSION() as version")
            result = cursor.fetchone()
        conn.close()
        return jsonify({"status": "Success", "db_version": result['version']})
    except Exception as e:
        return jsonify({"status": "Error", "message": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
PY