# README.md

## Part 1:
Create Custom VPC with Subnets, IGW, NAT, GW, and EIP
-
1. Connect to AWS and log in to your console.
2. Search for VPC and open the VPC dashboard.
3. Click on Create VPC
4. Select VPC and more for VPC settings
5. Name your VPC <lab-1a-vpc>
6. Input your IPv4 CIDR block <10.249.0.0/16> 
7. Select Number of Availability Zones (AZs) <3>
8. Select number of public subnets and Number of private subnets <3>
9. Click on Customize subnets CIDR blocks and assign the CIDR blocks for each private and public subnet
10. Select Regional - New, for NAT gateways
11. Ensure that None is selected for VPC endpoints.
12. Click on Create VPC to create the VPC.

---

Part 2: Create Security Groups

-
Create Security Group-EC2

***NOTE: This requires a complete and active VPC before configuring***

1. In the VPC dashboard, select Security Groups from the left menu.
2. Click on Create security group.

#### EC2 Security Group settings
- Name: ec2-lab-sg
- Description: Security Group for lab1 EC2 Instance
- VPC: lab-1a-vpc
- Inbound Rules:
    - Type: HTTP, Port: 80, Source: Anywhere- IPv4  0.0.0.0/0, Description: HTTP
    - Type: SSH, Port: 22, Source: MyIP(auto-detects your current IP)
- Outbound rules: Default (allow all)

3. Click on Create security group


Create Security Group - RDS
1. In the VPC dashboard, select Security Groups from the left menu.
2. Click on Create security group.

#### RDS Security Group settings
- Name: rds-lab-sg
- Description: Security Group for lab1 RDS Instance
- VPC: lab-1a-vpc
- Inbound Rules:
    - Type: MySQL/Aurora, Port: 3306, Source: Custom-Scroll down and select the EC2 Security group, Description: MySQL RDS

- Outbound rules: Default (allow all)

3. Click on Create security group


##############
#### Include section to create DB subnets
##############

Part 3: Create RDS MySQL Database
- 
1. Search and navigate to the Aurora and RDS dashboard.
2. Click on Databases in the left menu and click on Create database.
3. Select the option for Full configuration
4. Select MySQL under Engine options.
5. Select the latest Engine version from the drop-down selector<MySQL 8.4.7>
6. Select Free tier under Templates
7. Select Single-AZ DB instance deployment (1 instance) in Availability and durability.
8. Name your RDS database under Settings/DB instance identifier <lab-mysql>
9. Under Credentials management, select the option Self-managed to allow you to create and manage your DB credentials.
10. Enter and confirm the Master password for the Database.
11. Under Instance configuration, select db.t3.micro from the drop-down selector
12. Under Connectivity, select the previously created lab-1a-vpc from the Virtual private cloud(VPC) drop-down selector
13. Under VPC security group (firewall), select Choose existing and select your RDS security group<rds-lab-sg> created earlier.
14. Scroll down and click on Create database.


Part 4: Store Database Credentials in Secrets Manager
-
1. Search and access the AWS Secrets Manager dashboard.
2. Click on Store a new secret.
3. Select Credentials for Amazon RDS database
4. Under Credentials, enter the User name and Password for your database created earlier.
5. Under Database, select the radio button next to your database <lab-mysql>
6. Click Next
7. Under Configure secret, provide a Secret name <lab1a-rds-mysql> and Description <Credentials for RDS Database>
8. Click Next
9. Under Configure rotation, click Next.
10. Under Review, confirm settings and click Store.

 
Part 5: Create Custom IAM Role
- 
1. Navigate to th IAM dashboard and click on Roles in the left panel.
2. Click on Create role.
3. Select AWS servcice under Trusted entity type
4. In the Use case drop-down selector, select EC2 and use the first EC2 selection "Allows EC2 instances to call AWS services on your behalf"
5. Click Next
6. Under Permissions policies, search for  and select <SecretsManagerReadWrite> and click Next
7. On the Name, review and create page, name your role<ec2-rds-role> and give it a description <IAM role for EC2 to access secrets>
8. Click on Create role.
9. Once role is created, slect View role (green bar)
10. Under the Permissions tab, click on Add permissions drop-down selector and select Create inline policy.
11. From your armageddon repo, copy the contents of 1a_inline_policy.json file.
12. On the Specify permissions page, select JSON to display the policy editor window.
13. Clear the window and paste your copied content.
14. Modify the pasted content to replace <REGION> and <Account ID> to your appropriate region and account ID.
15. Click on Next.
16. On the Review and create page, under Policy details, provide a policy name <ec2-to-secrets-inline-policy>
17. Click Create policy

---
Part 6: Launch EC2 Instance with Bootstrap User Data
- 
1. In the EC2 dashboard, click on Launch instance
    - Name: ec2-lab-app
    - AMI: Amazon Linux 2023
    - Instance type: t3.micro
2. Click Create Key pair:
        - create new <lab1a-ec2>
        - Key pair type: RSA
        - Pricate key file format: .pem
        Click Create key pair and save in an accessible location
3. Under Network settings, click edit
    - VPC: lab-1a-vpc
    - Subnet: (select a public subnet)
    - Auto-assign public IP: Enable
    - Security group: 
            - Select existing security group
            - select ec2 security group <ec2-lab-sg>
4. Expand Advanced details drop-down arrow
    - IAM instance profile: select EC2 instance role <ec2-rds-role>
5. Scroll down to User data
6. Copy and edit app file
    - go to armageddon folder and copy contents of 1a_user_data.sh
    - paste into notepad for editing
    - Edit as follows:
        - line 14 should read
        REGION = os.environ.get("AWS_REGION", "<ap-southeast-7>")
        - line 15 should include your created secret name
        SECRET_ID = os.environ.get("SECRET_ID", "<lab1a-rds-mysql>")
        - line 105 Environment=SECRET_ID=<lab1a-rds-mysql>
        replace with your created secret ID.

7. Paste the edited app file into the user data text box and click Launch instance

- 
http://43.210.40.21/init
http://43.210.40.21/add?note=cloud_labs_are_real
http://43.210.40.21/list
- 

Part 7: Teardown
- Terminate EC2 Instance
- Delete Database
- Delete NAT Gateway
- Delete VPC

++++++++++++++++++++++++++++++++++++++++++++
---
### Tear-Down Notes

- EC2 Instance
- Delete RDS DB Instance
- Delete NAT Gateway
- Delete VPC (Only after RDS and NAT are deleted)
- Security Groups will be deleted with VPC.

