#!/bin/bash
# 1. Create the configuration file with correct values
cat <<EOF > /etc/default/rdsapp
AWS_REGION=ap-southeast-1
SECRET_ID=lab-1c/rds/mysql_v24
EOF

# 2. Inject the EnvironmentFile line into the service file if it's missing
# This looks for the [Service] header and adds the line right under it
if ! grep -q "EnvironmentFile" /etc/systemd/system/rdsapp.service; then
    sed -i '/\[Service\]/a EnvironmentFile=-\/etc\/default\/rdsapp' /etc/systemd/system/rdsapp.service
fi

# 3. Reload systemd because we modified a .service file
systemctl daemon-reload

# 4. Restart the app to apply all changes
systemctl restart rdsapp