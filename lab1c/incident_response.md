


aws sns subscribe \
            --topic-arn arn:aws:sns:ap-southeast-7:880420038324:lab-1c-db-incidents \
            --protocol email \
            --notification-endpoint snailstampede+lab1c@gmail.com



Output

{
    "SubscriptionArn": "pending confirmation"
}

2. CloudWatch Alarm → SNS

aws cloudwatch put-metric-alarm \
          --alarm-name lab-1c-db-connection-failure \
          --metric-name DBConnectionErrors \
          --namespace Lab/RDSApp \
          --statistic Sum \
          --period 300 \
          --threshold 3 \
          --comparison-operator GreaterThanOrEqualToThreshold \
          --evaluation-periods 1 \
          --alarm-actions arn:aws:sns:ap-southeast-7:880420038324:lab-1c-db-incidents


Runbook Section #1
1.1 Confirm Alert


morris@Mamba:~$ aws cloudwatch describe-alarms \
  --alarm-names lab-1c-db-connection-failure \
  --query "MetricAlarms[].StateValue"
[
    "INSUFFICIENT_DATA"
]
morris@Mamba:~$ aws cloudwatch describe-alarms   --alarm-names lab-1c-db-connection-failure   --query "MetricAlarms[].StateValue"
[
    "ALARM"
]
2.1 Check Application Logs

aws logs filter-log-events \
      --log-group-name /aws/ec2/lab-1c-rds-app \
      --filter-pattern "ERROR"
This "ERROR" was caused by changing the Secrets Manager Secret which caused the user to not be able to /init or /add notes in the RDS database.

3.1 Retrieve Parameter Store Values
    
      aws ssm get-parameters \
        --names /lab/db/endpoint /lab/db/port /lab/db/name \
        --with-decryption



morris@Mamba:~$ aws ssm get-parameters \
        --names /lab/db/endpoint /lab/db/port /lab/db/name \
        --with-decryption

---

{
    "Parameters": [
        {
            "Name": "/lab/db/endpoint",
            "Type": "String",
            "Value": "lab-1c-rds01.c1scsu4609mp.ap-southeast-7.rds.amazonaws.com",
            "Version": 1,
            "LastModifiedDate": "2026-02-18T22:49:42.132000-08:00",
            "ARN": "arn:aws:ssm:ap-southeast-7:880420038324:parameter/lab/db/endpoint",
            "DataType": "text"
        },
        {
            "Name": "/lab/db/name",
            "Type": "String",
            "Value": "labdb",
            "Version": 1,
            "LastModifiedDate": "2026-02-18T22:44:29.954000-08:00",
            "ARN": "arn:aws:ssm:ap-southeast-7:880420038324:parameter/lab/db/name",
            "DataType": "text"
        },
        {
            "Name": "/lab/db/port",
            "Type": "String",
            "Value": "3306",
            "Version": 1,
            "LastModifiedDate": "2026-02-18T22:49:42.125000-08:00",
            "ARN": "arn:aws:ssm:ap-southeast-7:880420038324:parameter/lab/db/port",
            "DataType": "text"
        }
    ],
    "InvalidParameters": []
}
---
3.2 Retrieve Secrets Manager Values

      aws secretsmanager get-secret-value \
      --secret-id lab-1c/rds/mysql_v7
---
{
    "ARN": "arn:aws:secretsmanager:ap-southeast-7:880420038324:secret:lab-1c/rds/mysql_v7-QeyG4C",
    "Name": "lab-1c/rds/mysql_v7",
    "VersionId": "31fe17da-3981-4ca9-849e-12f1568e19e1",
    "SecretString": "{\"dbname\":\"labdb\",\"host\":\"lab-1c-rds01.c1scsu4609mp.ap-southeast-7.rds.amazonaws.com\",\"password\":\"armageddon-blows-6-9\",\"port\":3306,\"username\":\"admin\"}",
    "VersionStages": [
        "AWSCURRENT"
    ],
    "CreatedDate": "2026-02-18T23:14:06.637000-08:00"
}
---
The previous command shows that the password for the admin database user has been changed from a known good value.i.e. Credential Drift
System State has been preserved for recovery.

Recovery

Credential Drift has been identified as the cause of errors. Secrets Manager has been updated to match known good value.

The command  curl http://43.209.211.52/list should be successful after state is returned to known good value.


6.1 Confirm Alarm Clears

    aws cloudwatch describe-alarms \
      --alarm-names lab-1c-db-connection-failure \
      --query "MetricAlarms[].StateValue"

---
morris@Mamba:~$ aws cloudwatch describe-alarms \
      --alarm-names lab-1c-db-connection-failure \
      --query "MetricAlarms[].StateValue"
[
    "INSUFFICIENT_DATA"
]
---
6.2 Confirm Logs Normalize

    aws logs filter-log-events \
      --log-group-name /aws/ec2/lab-1c-rds-app \
      --filter-pattern "ERROR"


