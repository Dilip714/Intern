# ☁️ AWS Advanced Compute & Networking – Week 2 Extension

> **AWS Cloud Training Program | Week 2 Extension**
> A hands-on implementation of production-grade AWS networking and compute architecture covering Multi-AZ VPCs, Auto Scaling, Load Balancing, Secure Private Access, Advanced Storage, and Monitoring.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Day-by-Day Implementation](#day-by-day-implementation)
  - [Day 1 – Multi-AZ VPC Design](#day-1--multi-az-vpc-design)
  - [Day 2 – Automated EC2 Provisioning](#day-2--automated-ec2-provisioning)
  - [Day 3 – Load Balancing and Auto Scaling](#day-3--load-balancing-and-auto-scaling)
  - [Day 4 – Private Connectivity](#day-4--private-connectivity)
  - [Day 5 – Advanced Storage](#day-5--advanced-storage)
  - [Day 6 – Monitoring and Private AWS Access](#day-6--monitoring-and-private-aws-access)
- [Security Controls](#security-controls)
- [Cost Optimization](#cost-optimization)
- [Screenshots](#screenshots)
- [Setup & Reproduction Guide](#setup--reproduction-guide)
- [AWS Well-Architected Alignment](#aws-well-architected-alignment)
- [Author](#author)

---

## Overview

This project implements a production-style AWS infrastructure across 6 days of structured labs. It demonstrates core AWS competencies required for real-world cloud engineering roles, including:

- Designing a **highly available, Multi-AZ VPC** with public and private subnet tiers
- Automating EC2 provisioning with **User Data scripts** and **IAM Roles**
- Deploying a **self-healing web tier** with ALB + Auto Scaling
- Enabling **zero-port-22 private access** via AWS Systems Manager Session Manager
- Implementing **S3 lifecycle management** and EBS snapshot strategies
- Creating **private S3 access** via VPC Gateway Endpoints (eliminating NAT cost for S3 traffic)
- Monitoring infrastructure with **CloudWatch Metrics, Logs, and VPC Flow Logs**

**AWS Account:** `582500932246`  
**Primary Region:** `us-east-1` (N. Virginia)  
**Period:** June 21 – June 23, 2026

---

## Architecture

![AWS Architecture Diagram](./architecture/aws_architecture.png)

### Traffic Flow Summary

```
Internet Users
    │
    ▼  HTTPS
Internet Gateway (week-03-IGW)
    │
    ▼  HTTP :80
Application Load Balancer (week3-alb)
    │                    │
    ▼                    ▼
EC2 web-server       EC2 web-server
(us-east-1a)         (us-east-1b)
[EBS gp3]            [EBS gp3]
    │                    │
    └──── Auto Scaling Group (week3-ASG) ────┘
              min:2 / desired:2 / max:4
    │
    ▼  private (no internet)
VPC Gateway Endpoint → S3 Bucket (week3-storage-demo)

    │  outbound only
    ▼
NAT Gateway (week-03-NAT)
    │
    ▼
Internet Gateway

    │  management (no port 22)
    ▼
Systems Manager Session Manager → Private Instances

    ──── CloudWatch collects metrics from all components ────
```

### Key Architecture Decisions

| Decision | Reason |
|----------|--------|
| Multi-AZ deployment | Eliminates single AZ as a single point of failure |
| Private subnets for EC2 | No direct internet exposure; traffic enters only via ALB |
| NAT Gateway in public subnet | Outbound-only internet for OS updates from private instances |
| VPC Gateway Endpoint for S3 | Private S3 access without NAT — reduces cost and latency |
| Session Manager instead of port 22 | No open SSH port; full audit trail via CloudWatch |
| Auto Scaling Group | Automatic instance replacement on failure; scales to demand |

---

## Features

- ✅ **Multi-AZ VPC** — 4 subnets (2 public, 2 private) across `us-east-1a` and `us-east-1b`
- ✅ **Internet Gateway** — Public internet entry point
- ✅ **NAT Gateway** — Outbound-only access for private instances
- ✅ **Application Load Balancer** — HTTP load distribution across AZs
- ✅ **Auto Scaling Group** — Self-healing, demand-driven scaling
- ✅ **Bastion Host** — SSH jump server with IP-restricted access
- ✅ **Session Manager** — Agentless private access (no port 22)
- ✅ **IAM Role (EC2-S3-ReadOnly-Role)** — Least-privilege S3 access from EC2
- ✅ **EBS Volumes** — Persistent gp3 volumes with snapshot backup
- ✅ **S3 Versioning + Lifecycle** — Object history + automated storage-class transitions
- ✅ **VPC Gateway Endpoint** — Private S3 access bypassing NAT
- ✅ **CloudWatch + VPC Flow Logs** — Full observability stack

---

## Tech Stack

| Layer | Service / Tool |
|-------|---------------|
| Networking | Amazon VPC, Internet Gateway, NAT Gateway, Route Tables, Network ACLs |
| Compute | Amazon EC2 (t3.micro), Auto Scaling Groups, Launch Templates |
| Load Balancing | Application Load Balancer (ALB), Target Groups |
| Security | IAM Roles & Policies, Security Groups, Bastion Host, AWS SSM Session Manager |
| Storage | Amazon S3 (Versioning, Lifecycle), Amazon EBS (gp3, Snapshots) |
| Private Connectivity | VPC Gateway Endpoint (S3) |
| Monitoring | Amazon CloudWatch (Metrics, Logs, Alarms), VPC Flow Logs |
| OS / Web Server | Amazon Linux 2023, Apache / Nginx (via User Data) |

---

## Project Structure

```
aws-week2-extension/
│
├── architecture/
│   └── aws_architecture.png          # Full system architecture diagram
│
├── screenshots/
│   ├── day1/
│   │   ├── vpc_resource_map.png      # VPC subnets, route tables, connections
│   │   ├── bastion_private_ec2.png   # Instance list
│   │   ├── ssh_bastion_connect.png   # SSH terminal session
│   │   └── ping_statistics.png       # Private subnet outbound internet proof
│   ├── day2/
│   │   ├── ec2_instance1_web.png     # Browser: Welcome to EC2 Instance 1
│   │   ├── ec2_instance2_web.png     # Browser: Welcome to EC2 Instance 2
│   │   ├── ec2_instances_list.png    # AWS Console instances
│   │   └── iam_role_s3readonly.png   # IAM Role configuration
│   ├── day3/
│   │   ├── security_group_rules.png  # WEB-SG inbound rules
│   │   ├── alb_web_output.png        # ALB DNS serving web page
│   │   ├── target_group_healthy.png  # Both targets healthy
│   │   ├── auto_scaling_group.png    # ASG capacity overview
│   │   └── instance_replacement.png  # Post-termination recovery
│   ├── day4/
│   │   ├── bastion_private_server.png # Instance list
│   │   ├── security_groups.png        # Bastion-SG and Private-SG
│   │   └── ssm_session_manager.png    # SSM terminal session
│   ├── day5/
│   │   └── s3_lifecycle_rule.png      # MoveToIA lifecycle rule
│   └── day6/
│       └── vpc_endpoint_s3.png        # Gateway endpoint details
│
├── userdata/
│   ├── webserver-userdata.sh          # Apache/Nginx bootstrap script
│   └── cloudwatch-agent-config.json  # CloudWatch Agent configuration
│
├── README.md                          # This file
└── WEEK2_REPORT.docx                  # Full submission report
```

---

## Day-by-Day Implementation

### Day 1 – Multi-AZ VPC Design

**Goal:** Build a production-style VPC with public/private subnet isolation across two AZs.

**Resources Created:**

| Resource | Name / ID | Details |
|----------|-----------|---------|
| VPC | `week-3` | CIDR: 10.0.0.0/16 |
| Public Subnet A | `PUB-Sub-A` | 10.0.1.0/24, us-east-1a |
| Public Subnet B | `PUB-sub-B` | 10.0.2.0/24, us-east-1b |
| Private Subnet A | `PRI-sub-A` | 10.0.3.0/24, us-east-1a |
| Private Subnet B | `PRI-sub-B` | 10.0.4.0/24, us-east-1b |
| Internet Gateway | `week-03-IGW` | Attached to VPC |
| NAT Gateway | `week-03-NAT` | In PUB-sub-B |
| Public Route Table | `PUB-RT` | 0.0.0.0/0 → IGW |
| Private Route Table | `PRI-RT` | 0.0.0.0/0 → NAT GW |

**Verification:** SSH through Bastion Host into private instance `10.0.11.53` and ran `ping google.com` — 56 packets transmitted, 0% loss.

---

### Day 2 – Automated EC2 Provisioning

**Goal:** Launch web servers automatically at boot using EC2 User Data; attach IAM role for S3 access.

**IAM Role:** `EC2-S3-ReadOnly-Role`  
**Policy Attached:** `AmazonS3ReadOnlyAccess` (AWS Managed)

**User Data Script (example):**

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
echo "<h1>Welcome to EC2 Instance 1</h1>" > /var/www/html/index.html
```

**Security Group Rules (WEB-SG):**

| Type | Protocol | Port | Source |
|------|----------|------|--------|
| SSH | TCP | 22 | 49.37.159.136/32 (your IP only) |
| HTTP | TCP | 80 | sg-096e97b81107346e9 (ALB SG) |
| All traffic outbound | All | All | 0.0.0.0/0 |

---

### Day 3 – Load Balancing and Auto Scaling

**Goal:** Deploy a self-healing, load-balanced web tier spanning two AZs.

**ALB:** `week3-alb` — DNS: `week3-alb-510286039.us-east-1.elb.amazonaws.com`  
**Target Group:** `week3-tg` — Protocol: HTTP, Port: 80  
**Health Check:** HTTP GET `/` — both instances **Healthy**

**Auto Scaling Group:** `week3-ASG`

| Setting | Value |
|---------|-------|
| Launch Template | `New-Temp` (Version Default) |
| Desired Capacity | 2 |
| Minimum | 2 |
| Maximum | 4 |
| AZs | us-east-1a, us-east-1b |
| Instance Health | 2/2 Healthy |

**Self-Healing Test:** Manually terminated one instance → ASG detected failure → launched replacement within ~2 minutes. Total running instances restored to 2.

---

### Day 4 – Private Connectivity

**Goal:** Access private instances securely using two methods: Bastion Host and SSM Session Manager.

#### Method 1: Bastion Host (SSH)

```
Local Machine → SSH → Bastion Host (13.219.243.195) → SSH → Private Instance (10.0.2.240)
```

**Security Group chain:**
- `Bastion-SG`: Allow SSH from `49.37.159.136/32` only
- `Private-SG`: Allow SSH from `Bastion-SG` only (no direct internet)

#### Method 2: AWS Systems Manager Session Manager

```
AWS Console / CLI → SSM → Private Instance
(No port 22 required, no key pair needed)
```

**IAM Role required:** `SSMRole` with `AmazonSSMManagedInstanceCore` policy  
**Verified:** `whoami` returned `ssm-user`, hostname `ip-10-0-2-240.ec2.internal`

---

### Day 5 – Advanced Storage

**Goal:** Demonstrate EBS lifecycle management and S3 versioning + lifecycle automation.

**EBS Operations:**
1. Created and attached additional gp3 volume to EC2 instance
2. Formatted: `mkfs -t ext4 /dev/xvdf`
3. Mounted: `mount /dev/xvdf /data`
4. Persisted via `/etc/fstab`
5. Created EBS Snapshot → restored new volume from snapshot

**S3 Bucket:** `week3-storage-demo`

| Feature | Configuration |
|---------|--------------|
| Versioning | Enabled |
| Lifecycle Rule | `MoveToIA` — Transition to Standard-IA after 30 days |
| Scope | Entire bucket |
| Status | Enabled |

---

### Day 6 – Monitoring and Private AWS Access

**Goal:** Eliminate NAT dependency for S3 and enable full network observability.

**VPC Gateway Endpoint:**

| Attribute | Value |
|-----------|-------|
| Name | `enpoint-01` |
| Endpoint ID | `vpce-00e151399c6ad9c50` |
| Type | Gateway |
| Service | `com.amazonaws.us-east-1.s3` |
| Status | Available |
| VPC | `vpc-039bb5e252e718c82` (week-3) |

**CloudWatch Agent — Metrics Collected:**

```json
{
  "metrics": {
    "metrics_collected": {
      "cpu": { "measurement": ["cpu_usage_idle", "cpu_usage_user"] },
      "mem": { "measurement": ["mem_used_percent"] },
      "disk": { "measurement": ["disk_used_percent"], "resources": ["/"] }
    }
  }
}
```

**VPC Flow Logs:** Enabled on week-3 VPC — captures all ACCEPT/REJECT traffic for security analysis.

---

## Security Controls

| Control | Implementation |
|---------|---------------|
| No direct internet to EC2 | Instances in private subnets; only ALB in public |
| Least-privilege IAM | EC2-S3-ReadOnly-Role: read-only S3, no write permissions |
| IP-restricted SSH | Bastion SG allows SSH only from `49.37.159.136/32` |
| SG chaining | Private-SG allows SSH from Bastion-SG only |
| Port-22-free admin access | SSM Session Manager; fully audited |
| Private S3 traffic | VPC Gateway Endpoint: S3 traffic never leaves AWS backbone |
| Network traffic auditing | VPC Flow Logs → CloudWatch Logs |

---

## Cost Optimization

| Strategy | Impact |
|----------|--------|
| VPC Gateway Endpoint for S3 | Eliminates NAT Gateway data processing charges for S3 traffic |
| S3 Lifecycle: Standard → Standard-IA | Reduces storage cost by ~58% after 30 days |
| t3.micro instances | Burstable performance at lowest EC2 cost tier |
| Auto Scaling (min=desired=2) | No over-provisioning; scales only when needed |
| EBS gp3 over gp2 | gp3 is ~20% cheaper with better baseline performance |
| Single NAT Gateway | One NAT GW per region (not per AZ) sufficient for lab workloads |

---

## Screenshots

### Day 1 – VPC Design

| Screenshot | Description |
|------------|-------------|
| ![VPC Resource Map](./screenshots/day1/vpc_resource_map.png) | VPC with 4 subnets, 3 route tables, IGW and NAT connections |
| ![Bastion and Private Instance](./screenshots/day1/bastion_private_ec2.png) | EC2 Instances: Bastion-Host and Private-Instance |
| ![SSH Session](./screenshots/day1/ssh_bastion_connect.png) | SSH through Bastion into private instance + ping google.com |
| ![Ping Stats](./screenshots/day1/ping_statistics.png) | 56 packets, 0% loss – confirmed outbound internet from private subnet |

### Day 2 – EC2 Provisioning

| Screenshot | Description |
|------------|-------------|
| ![EC2 Instance 1](./screenshots/day2/ec2_instance1_web.png) | Browser output: Welcome to EC2 Instance 1 |
| ![EC2 Instance 2](./screenshots/day2/ec2_instance2_web.png) | Browser output: Welcome to EC2 Instance 2 |
| ![Instances List](./screenshots/day2/ec2_instances_list.png) | AWS Console: web-server-1 and web-server-2 running |
| ![IAM Role](./screenshots/day2/iam_role_s3readonly.png) | EC2-S3-ReadOnly-Role with AmazonS3ReadOnlyAccess policy |

### Day 3 – Load Balancing & Auto Scaling

| Screenshot | Description |
|------------|-------------|
| ![Security Groups](./screenshots/day3/security_group_rules.png) | WEB-SG inbound rules: SSH restricted, HTTP from ALB |
| ![ALB Output](./screenshots/day3/alb_web_output.png) | Auto Scaling Web Server served via ALB DNS |
| ![Target Group](./screenshots/day3/target_group_healthy.png) | week3-tg: both instances Healthy in both AZs |
| ![ASG](./screenshots/day3/auto_scaling_group.png) | week3-ASG: desired 2, limits 2–4, 2/2 healthy |
| ![Recovery](./screenshots/day3/instance_replacement.png) | Instances after termination: ASG replaced terminated instance |

### Day 4 – Private Connectivity

| Screenshot | Description |
|------------|-------------|
| ![Instances](./screenshots/day4/bastion_private_server.png) | Private-server and Bastion-Host running |
| ![Security Groups](./screenshots/day4/security_groups.png) | Bastion-SG and Private-SG configured |
| ![SSM Session](./screenshots/day4/ssm_session_manager.png) | Session Manager terminal: ssm-user on private instance |

### Day 5 – Advanced Storage

| Screenshot | Description |
|------------|-------------|
| ![Lifecycle Rule](./screenshots/day5/s3_lifecycle_rule.png) | S3 MoveToIA lifecycle rule enabled on week3-storage-demo |

### Day 6 – VPC Endpoint & Monitoring

| Screenshot | Description |
|------------|-------------|
| ![VPC Endpoint](./screenshots/day6/vpc_endpoint_s3.png) | Gateway endpoint enpoint-01 available for S3 |

---

## Setup & Reproduction Guide

### Prerequisites

- AWS Account with IAM permissions for EC2, VPC, S3, IAM, CloudWatch
- AWS CLI configured: `aws configure`
- Key pair created in us-east-1 (e.g., `Week2-key.pem`)

### Step 1 – Create the VPC

```bash
# Create VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=week-3}]'

# Create subnets (repeat for all 4)
aws ec2 create-subnet --vpc-id <VPC_ID> --cidr-block 10.0.1.0/24 --availability-zone us-east-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=PUB-Sub-A}]'
```

### Step 2 – Attach Internet Gateway

```bash
aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=week-03-IGW}]'
aws ec2 attach-internet-gateway --internet-gateway-id <IGW_ID> --vpc-id <VPC_ID>
```

### Step 3 – Create NAT Gateway

```bash
# Allocate Elastic IP first
aws ec2 allocate-address --domain vpc

# Create NAT Gateway in public subnet
aws ec2 create-nat-gateway --subnet-id <PUB_SUBNET_B_ID> --allocation-id <EIP_ALLOC_ID>
```

### Step 4 – Launch EC2 Instances with User Data

```bash
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --instance-type t3.micro \
  --key-name Week2-key \
  --subnet-id <PRIVATE_SUBNET_ID> \
  --security-group-ids <WEB_SG_ID> \
  --iam-instance-profile Name=EC2-S3-ReadOnly-Role \
  --user-data file://userdata/webserver-userdata.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server-1}]'
```

### Step 5 – Create Load Balancer and Auto Scaling

```bash
# Create ALB
aws elbv2 create-load-balancer --name week3-alb --type application \
  --subnets <PUB_SUBNET_A_ID> <PUB_SUBNET_B_ID> --security-groups <ALB_SG_ID>

# Create Target Group
aws elbv2 create-target-group --name week3-tg --protocol HTTP --port 80 --vpc-id <VPC_ID>

# Create Auto Scaling Group
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name week3-ASG \
  --launch-template LaunchTemplateName=New-Temp,Version='$Default' \
  --min-size 2 --desired-capacity 2 --max-size 4 \
  --availability-zones us-east-1a us-east-1b \
  --target-group-arns <TARGET_GROUP_ARN>
```

### Step 6 – Create VPC Gateway Endpoint for S3

```bash
aws ec2 create-vpc-endpoint \
  --vpc-id <VPC_ID> \
  --service-name com.amazonaws.us-east-1.s3 \
  --route-table-ids <PRIVATE_RT_ID> \
  --tag-specifications 'ResourceType=vpc-endpoint,Tags=[{Key=Name,Value=enpoint-01}]'
```

### Step 7 – Enable VPC Flow Logs

```bash
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids <VPC_ID> \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name /vpc/week3-flow-logs \
  --deliver-logs-permission-arn <FLOW_LOGS_ROLE_ARN>
```

---

## AWS Well-Architected Alignment

### Reliability Pillar
- Multi-AZ deployment eliminates single-AZ failure as an outage cause
- Auto Scaling Group automatically replaces unhealthy instances
- ALB health checks route traffic only to healthy targets
- EBS Snapshots provide point-in-time recovery for data volumes

### Security Pillar
- EC2 instances run in private subnets with no public IPs
- Least-privilege IAM role limits S3 access to read-only
- Security Group chaining ensures private instances are only reachable via Bastion or ALB
- SSM Session Manager eliminates open SSH ports; all sessions are logged
- VPC Flow Logs capture all network-level events for audit

### Cost Optimization Pillar
- VPC Gateway Endpoint for S3 removes per-GB NAT processing costs
- S3 Standard-IA lifecycle rule reduces storage costs after 30 days
- gp3 EBS volumes offer better price-performance than gp2
- Auto Scaling prevents paying for idle capacity during low-traffic periods

---

## Author

**Dilip Kumar**  
AWS Cloud Training Program — Week 2 Extension  
Account: `582500932246` | Region: `us-east-1`  
Period: June 21 – June 23, 2026

---

*This project was completed as part of a structured AWS cloud training program. All infrastructure was deployed and verified in a live AWS environment.*
