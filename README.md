AWS Cloud Infrastructure Deployment using Terraform
This project is about setting up a full AWS infrastructure using Terraform instead of manually clicking through the AWS Console. The goal was to learn how Infrastructure as Code works and apply it in a real cloud environment.

Why I used Terraform
I wanted to move away from manually setting up resources in the AWS Console. Every time you do it manually, you have to repeat the same steps — and if something goes wrong, it's hard to track what changed.
With Terraform, I write the infrastructure as code, run terraform apply, and everything gets created automatically. If I want to tear it down, I just run terraform destroy. It also makes everything version-controlled through GitHub, which is how real teams manage infrastructure.

What I built
The infrastructure includes:

A custom VPC with its own subnet, internet gateway, and route table
An EC2 instance (t2.micro) with Docker pre-installed through a bash bootstrap script
An S3 bucket with versioning enabled
A CloudWatch alarm that monitors CPU usage of the EC2 instance


Architecture
Internet
    |
Internet Gateway
    |
VPC (10.0.0.0/16)
    |
Route Table
    |
Public Subnet (10.0.1.0/24) - ap-southeast-1a
    |
Security Group (SSH port 22, HTTP port 80)
    |
EC2 Instance (t2.micro) - Amazon Linux 2
Docker installed via user_data bootstrap script
    |
S3 Bucket - lancecloud-bucket-dev
Versioning enabled
    |
CloudWatch Alarm - CPU > 80% for 2 consecutive periods

Project Structure
aws-cloud-infrastructure/
├── main.tf
├── variables.tf
├── outputs.tf
├── .terraform.lock.hcl
├── screenshots/
└── .gitignore
I split the code into 3 files to keep things organized. variables.tf holds all the values I might want to change later like region, project name, and instance type. main.tf has all the actual resource definitions. outputs.tf prints the important values after deployment like the EC2 public IP and VPC ID.

AWS Services
VPC
I created a custom VPC instead of using the default one. Custom VPCs are what you'd normally use in real environments because you have full control over the network setup. I set the CIDR block to 10.0.0.0/16 and enabled DNS support so resources can communicate with each other by name.
Subnet
A public subnet inside the VPC with CIDR 10.0.1.0/24. I set map_public_ip_on_launch to true so any EC2 launched here automatically gets a public IP.
Internet Gateway and Route Table
Without these, nothing inside the VPC can reach the internet. The Internet Gateway connects the VPC to the internet, and the Route Table tells the traffic where to go. I also created a Route Table Association to link the route table specifically to the public subnet.
Security Group
Acts as a firewall for the EC2. I opened port 22 for SSH access and port 80 for HTTP. All outbound traffic is allowed.
EC2 Instance
Running on t2.micro which is free tier eligible. I used an Amazon Linux 2 AMI and added a user_data bootstrap script that automatically installs Docker when the instance starts.
bash#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
I used yum because Amazon Linux 2 uses it as its package manager. systemctl enable makes sure Docker starts automatically even after a reboot.
S3 Bucket
Created a bucket named lancecloud-bucket-dev with versioning enabled. Versioning means every version of every uploaded file is saved, so you can recover from accidental deletes or overwrites.
CloudWatch Alarm
Monitors the CPU utilization of the EC2 instance. The alarm triggers if CPU goes above 80% for 2 consecutive 2-minute periods. Two periods instead of one to avoid triggering on normal short spikes.

Variables
hclvariable "aws_region" {
  default = "ap-southeast-1"
}

variable "project_name" {
  default = "lancecloud"
}

variable "environment" {
  default = "dev"
}

variable "instance_type" {
  default = "t2.micro"
}
All resource names follow the pattern ${var.project_name}-<resource>-${var.environment} so they're easy to identify and consistent.

Screenshots
EC2 Instance
Show Image
VPC
Show Image
S3 Bucket
Show Image
CloudWatch Alarm
Show Image
Terraform Destroy
Show Image

Note: Update the filenames to match the actual files in your screenshots folder.


How to run this
Requirements:

AWS account with an IAM user
Terraform installed
AWS CLI configured with aws configure

Steps:
bash# Clone the repo
git clone https://github.com/LDCloudProj/aws-cloud-infrastructure.git
cd aws-cloud-infrastructure

# Initialize Terraform
terraform init

# Check what will be created
terraform plan

# Deploy
terraform apply

# Remove everything when done
terraform destroy

Issues I ran into
Git conflict on push
When I pushed my local files to GitHub, it was rejected because the remote repo already had a README. I fixed it by pulling first with --allow-unrelated-histories, resolving the .gitignore conflict, and pushing again.
terraform.tfstate showing up in git status
The .gitignore from GitHub didn't carry over to my local setup. I manually added terraform.tfstate, terraform.tfstate.backup, and .terraform/ to .gitignore to make sure they don't get committed. The tfstate file contains sensitive AWS resource details so it should never be pushed to a public repo.
Wrong region on AWS Console
After deploying, I couldn't find my resources on the console. Turns out I was looking at the Sydney region instead of Singapore. Always make sure the console region matches the region in your Terraform config.

What I plan to add next

Store tfstate remotely using S3 backend and DynamoDB for state locking
Set up a GitHub Actions CI/CD pipeline to auto-deploy on push
Add an Application Load Balancer with Auto Scaling
Use AWS Systems Manager instead of SSH for EC2 access
Add SNS so CloudWatch can send alerts via email or Slack


Author
Lanceloth Joseph O. David
AWS Certified Solutions Architect Associate | AWS Cloud Practitioner | Azure Fundamentals
GitHub: https://github.com/LDCloudProj
