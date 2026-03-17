# Class 7 Armageddon

## Create an RDS MySQL Database
1. In AWS Console, go to Aurora and RDS panel and click on Create database
2. Use Full configuration option
3. Under Engine type, select MySQL
4. Unter Templates, select the Free tier option
5. In the Settings, type "lab-mysql" as the DB instance identifier. This is the name of your database.
6. Under Credentials and Settings, use admin as the MAster username
7. Under Credentials management, select Self managed to avoid AWS charges
8. Select Auto generate password to allow AWS to generate a password for you. Password will be available after database is created.
9. Under Connectivity, ensure that the Default VPC is selected
10. Under Public access, select No
11. Under VPC security groups, select Create new option, and enter "secgrp-rds-lab" as the New VPC security group name
12. Scroll to bottom of page and click on Create database.


## Create an EC2 Instance
1. Go to EC2 dashboard and click on Launch instance.
2. Under Name and tags, name your instance "lab-ec2-app"
3. Under Application and OS Images (Amazon Machine Image), select Amazon Linux and ensure that Amazon Linux 2023 is selected as the Amazon Machine Image.
4. Under Instance type, select t3.micro
5. Under Key pair (login), click on Create new key pair.
6. In the Create key pair window, name your key pair the same as your EC2 instance "lab-ec2-app"
7. Select Key pair type RSA and .pem as the Private key file format.
8. Click Create key pair and save in a secure location.
9. Under Network settings, click Edit and select the Default VPC
10. For Firewall (security groups) select the option to Create security group and name your security group "secgrp-ec2-lab".
11. Give a security group a description: "secgrp-ec2-lab"
12. For Inbound Security Group Rules:
    - Type: SSH
    - Protocol: TCP
    - Port range: 22
    - Source type: MyIP(later)
    - Description: SSH for EC2-RDS

13. Click on Add security group rule
    - Type: HTTP
    - Protocol: TCP
    - Port Range: 80
    - Source type: Anywhere
    - Description: HTTP for EC2-RDS

14. **Leave Outbound Rules as Default**




## Edit RDS Security Group Settings
1. Go back to RDS and click Connectivity and Security, and click on the link under VPC security groups attached to RDS.
2. Click on Edit Inbound Rules and set Source to Custom and sele
2. Click on the Cecurity group ID link for the Security group name (secgrp-rds-lab) we created earlier in step 11 during the RDS Database creation.





