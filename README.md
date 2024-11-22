# VM-Series with AWS GWLB Demo Guide

## Overview

This code helps deploy all the resources required to successfully demonstrate the VM-Series reference architecture with the AWS Gateway Load Balancer. This deployment Post the successful deployment of the resources, including the Palo Alto Networks VM-Series Next Generation Firewall, you will be able to secure all Inbound, Outbound and East traffic to the 2 spoke servers also deployed as part of the demonstration.

## Pre-requisites

- Permissions to subscribe to VM-Series on the AWS Marketplace.
- Permissions to deploy all networking resources like VPC, Subnets, etc.
- Permissions to deploy EC2 instances and connect to them via SSH.
- Five (5) available Elastic IP in your quota (by default, accounts have a quota of 5, if you're using any separate from this lab, you'll need to increase your quote before running this).
- If running from a local workspace, either a macOS or GNU Linux environment is required (alternatively, you can use AWS CloudShell).
- If on macOS, Homebrew installed.

## Demo Lab Setup

In this section, we will launch the lab environment. These are the steps that we will accomplish at this time.

- Login to the AWS Console using the provided credentials and set up IAM roles
- Subscribe to the Palo Alto Networks VM-Series PAYG on the AWS Marketplace.
   - You can follow this link to open the Marketplace page directly. On the page that opens up, Click on “Continue to Subscribe” and then Click on “Accept Terms”.<br/>https://aws.amazon.com/marketplace/pp?sku=hd44w1chf26uv4p52cdynb2o
- If you do not have room for 4 more Elastic IPs, request an increase in the Elastic IP service quota to add 5 more. ([In the service quotas, under EC2](https://us-east-1.console.aws.amazon.com/servicequotas/home/services/ec2/quotas), search for "EC2-VPC Elastic IPs".)
- Create a new SSH key pair in the AWS console. Enter the name of they key in the environment variables below.
- Deploy lab environment using Terraform (via the setup.sh script).

### Cloning the Git Repo

- Download/Clone the Git repository from the below link.<br/>
https://github.com/PaloAltoNetworks/aws-vmseries-gwlb-poc.git

```
git clone https://github.com/PaloAltoNetworks/aws-vmseries-gwlb-poc.git && cd aws-vmseries-gwlb-poc
```

#### Deploying from local workspace

If you are attempting to deploy from your local workspace, you would need to update the below values on the _aws-vmseries-gwlb-poc/terraform/vmseries/student.auto.tfvars_ file.

```
access-key      = ""
secret-key      = ""
session-token   = ""
region          = ""
ssh-key-name    = ""
```

In case you are using AWS CloudShell, you can ignore this step. 

### Run the setup

Once you have completed the above steps as required, ensure that you are in the root directory of the cloned repo and run the below command. 

> **NOTE:** Running this script WILL INSTALL other dependencies!

```
./setup.sh
```

It will take around 5 minutes to deploy all the lab components. Status will be updated on the cloudshell console as deployment progresses. At the end of deployment, you should see the message “Completed successfully!”

## Demo Lab Teardown

Ensure that you have the permissions to delete all the resources that were created as part of the setup. Adjust the "cd" command below to change the directory as required.

Run the below commands to teardown the setup.

```
cd ~/aws-vmseries-gwlb-poc/terraform/vmseries
terraform destroy -auto-approve
```

## Connecting to the Palo Alto Networks VM-Series Firewall

Before connecting to the web console of the Palo Alto Networks VM-Series Firewall, you need to set up the password for the admin user. You can do this by connecting to the firewall using SSH and running the below command.

1. ssh to the ip address of the firewall (from the terraform output) `ssh -i /path/to/ssh-key.pem admin@<firewall-ip>`
2. Run the below command to set the password for the admin user.

```bash
set mgt-config users admin password
```

After an admin password is set, you can access the web interface at https://<firewall-ip> with the username as "admin" and the password that you set.

# TODO: Explain better how to use the Firewall web interface for verifying the configuration.

## Connecting to the app servers

We will be using the user ‘ec2-user’ as the username to login to these applications. Use the SSH key that you provided in the environment variables.

You can also verify the app server (vulnerable web server) are up with:
http://<elastic-ip>:8080 (vulnerable web server)

# TODO: Explain better the role of the "Attack" and "Vulnerable" servers and how to test with them.

### On the AWS CloudShell

- Navigate to the AWS CloudShell and run the below command to log in to the EC2 instance on the AWS environment. Make sure to replace the _&lt;instance-id>_ in the command below with the instance ID of the EC2 instance.

```
aws ec2-instance-connect ssh --instance-id <instance-id>
```

### On the EC2 console

You could also connect to the servers directly on the EC2 console by selecting the instance that you want to connect to, and clicking on the __Connect__ button provided above the instance list. Ensure that you use the username as _ec2-user_ for logging in.

# Fin