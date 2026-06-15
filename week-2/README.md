# Week 2: AWS Compute & Networking
---

## 📚 Table of Contents

1. [Learning Objectives](#learning-objectives)
2. [Architecture Overview](#architecture-overview)
3. [Task 2.1 — Web Server on EC2](#task-21--web-server-on-ec2)
4. [Task 2.2 — Custom VPC with Public & Private Subnets](#task-22--custom-vpc-with-public--private-subnets)
5. [Task 2.3 — Storage Exploration (S3 & EBS)](#task-23--storage-exploration-s3--ebs)
6. [Key Concepts Learned](#key-concepts-learned)
7. [AWS Services Used](#aws-services-used)
8. [Deliverables](#deliverables)

---

## 🎓 Learning Objectives

- Launch and connect to EC2 instances securely via SSH
- Design a custom VPC with public and private subnets
- Configure security groups, route tables, gateways, and Elastic IPs
- Host content on S3 and understand object storage vs block storage (EBS)
- Produce a clear cloud architecture diagram

---

## 🗺️ Architecture Overview

The diagram below shows the full AWS network architecture built during Week 2:

```
                        INTERNET
                            │
                            │
                    Internet Gateway
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │           Custom VPC 10.0.0.0/16      │
        │                                       │
        │   ┌───────────────────────────────┐   │
        │   │     Public Subnet             │   │
        │   │     10.0.1.0/24               │   │
        │   │                               │   │
        │   │   EC2 WebServer (Nginx/Apache) │   │
        │   │   NAT Gateway                 │   │
        │   │   Public Route Table          │   │
        │   └───────────────────────────────┘   │
        │                   │                   │
        │                   ▼                   │
        │   ┌───────────────────────────────┐   │
        │   │     Private Subnet            │   │
        │   │     10.0.2.0/24               │   │
        │   │                               │   │
        │   │   Private EC2                 │   │
        │   │   Private Route Table         │   │
        │   └───────────────────────────────┘   │
        └───────────────────────────────────────┘
```

> 📎 Full architecture diagram: [`Architecture_Diagram_drawio.pdf`](./Architecture_Diagram_drawio.pdf)

### Traffic Flow

**Inbound (Public Web Access):**
```
User → Internet → Internet Gateway → Public Route Table → EC2 WebServer
```

**Outbound (Private Subnet Egress):**
```
Private EC2 → Private Route Table → NAT Gateway → Internet Gateway → Internet
```

---

## Task 2.1 — Web Server on EC2

### Introduction

Instead of purchasing physical servers, Amazon EC2 (Elastic Compute Cloud) provides virtual servers on demand. In this task, an Ubuntu EC2 instance was launched, configured with a Security Group, accessed securely using SSH, and used to host a static website through the Nginx web server. An Elastic IP was attached to provide a permanent public address.

### Instance Configuration

| Setting | Value |
|---------|-------|
| **AMI** | Ubuntu 24.04 LTS |
| **Instance Type** | t3.micro |
| **Storage** | 8 GB gp3 |
| **Key Pair** | `week2-Instance key.pem` |
| **Elastic IP** | 44.198.48.159 |

### Security Group Rules

| Protocol | Port | Purpose |
|----------|------|---------|
| SSH | 22 | Remote server access |
| HTTP | 80 | Website access |
| HTTPS | 443 | Secure website access |

### Steps Performed

**Step 1 — Connect via SSH**
```bash
chmod 400 "week2-Instance key.pem"
ssh -i "week2-Instance key.pem" ubuntu@PUBLIC-IP
```

**Step 2 — Update Packages**
```bash
sudo apt update
sudo apt upgrade -y
```

**Step 3 — Install & Verify Nginx**
```bash
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
# Expected: Active: active (running)
```

**Step 4 — Deploy Static Website**
```bash
# Edit the default HTML file
sudo nano /var/www/html/index.html
```

Sample content served:
```html
<h1>Hello from AWS EC2!</h1>
<p>Created by Dilip Kumar</p>
```

**Step 5 — Allocate & Attach Elastic IP**

- Allocated a new Elastic IP from the AWS Console
- Associated it with the EC2 instance
- Confirmed public access at `http://44.198.48.159`

### Architecture Flow

```
User Browser → Internet → Elastic IP → Security Group → EC2 (Ubuntu) → Nginx → index.html → Response
```

### Outcome

Successfully launched an Ubuntu EC2 instance, connected via SSH, installed and configured Nginx, hosted a static webpage, and attached an Elastic IP for permanent public accessibility.

---

## Task 2.2 — Custom VPC with Public & Private Subnets

### Project Overview

A secure AWS network architecture was created using a custom VPC. The architecture hosts a web server in a public subnet while keeping internal resources secure in a private subnet, with outbound internet access routed through a NAT Gateway.

### VPC Configuration

| Resource | Name | CIDR / Detail |
|----------|------|---------------|
| VPC | Custom-VPC | `10.0.0.0/16` |
| Public Subnet | Public-Subnet | `10.0.1.0/24` |
| Private Subnet | Private-Subnet | `10.0.2.0/24` |
| Internet Gateway | IGW | Attached to VPC |
| NAT Gateway | NAT-GW | Deployed in Public-Subnet |
| Elastic IP | — | Allocated for NAT Gateway |

### Route Tables

| Route Table | Destination | Target |
|-------------|-------------|--------|
| Public Route Table | `0.0.0.0/0` | Internet Gateway |
| Private Route Table | `0.0.0.0/0` | NAT Gateway |

### Steps Performed

**Step 1 — Create VPC**
- Name: `Custom-VPC`, CIDR: `10.0.0.0/16`

**Step 2 — Create Subnets**
- Public Subnet: `10.0.1.0/24`
- Private Subnet: `10.0.2.0/24`

**Step 3 — Internet Gateway**
- Created and attached IGW to the VPC

**Step 4 — Public Route Table**
- Added route `0.0.0.0/0 → Internet Gateway`
- Associated with Public-Subnet

**Step 5 — NAT Gateway**
- Allocated Elastic IP
- Deployed NAT Gateway in Public-Subnet

**Step 6 — Private Route Table**
- Added route `0.0.0.0/0 → NAT Gateway`
- Associated with Private-Subnet

**Step 7 — Launch Public EC2 (WebServer)**
- Subnet: Public-Subnet, Public IP: Enabled

```bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Welcome to My AWS Web Server</h1>" | sudo tee /var/www/html/index.html
```

**Step 8 — Launch Private EC2 (PrivateServer)**
- Subnet: Private-Subnet, Public IP: Disabled

**Step 9 — Verify NAT Gateway Egress**
```bash
# From Private EC2:
curl https://aws.amazon.com
# Successful response confirms outbound access via NAT
```

### Outcome

Successfully designed and implemented a secure AWS network with a custom VPC, public and private subnets, IGW, NAT Gateway, route tables, and EC2 instances. Verified public web access and private subnet internet egress through NAT.

---

## Task 2.3 — Storage Exploration (S3 & EBS)

### Objective

Explore AWS storage services by hosting a static website on S3, managing EBS volumes, taking snapshots, and restoring data.

---

### Part A: Amazon S3 — Static Website Hosting

**S3 Bucket:** `dilip-static-website-2026`

**Steps Performed:**

1. Created S3 bucket with a unique name
2. Uploaded `index.html`
3. Enabled Static Website Hosting (Index document: `index.html`)
4. Disabled Block Public Access
5. Applied bucket policy for public read:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::dilip-static-website-2026/*"
    }
  ]
}
```

6. Verified website accessible via S3 endpoint URL

---

### Part B: Amazon EBS — Block Storage Management

#### EBS Volume Configuration

| Setting | Value |
|---------|-------|
| **Volume Type** | gp3 |
| **Size** | 100 GB |
| **Device** | `/dev/nvme1n1` |
| **Mount Point** | `/data` |

**Steps Performed:**

```bash
# 1. Verify volume is attached
lsblk
# Output: nvme1n1 visible

# 2. Format the volume
sudo mkfs -t ext4 /dev/nvme1n1

# 3. Create mount point and mount
sudo mkdir /data
sudo mount /dev/nvme1n1 /data

# 4. Verify mount
df -h

# 5. Write test data
echo "AWS EBS Storage Test" | sudo tee /data/test.txt
cat /data/test.txt
# Output: AWS EBS Storage Test
```

#### EBS Snapshot

- **Snapshot Name:** `Week2-Task2.3-Snapshot`
- **Status:** Completed

#### Snapshot Restoration

```bash
# Mount restored volume
sudo mkdir /restore
sudo mount /dev/nvme2n1 /restore

# Verify data
cat /restore/test.txt
# Output: AWS EBS Storage Test ✅
```

---

### S3 vs EBS — Storage Comparison

| Feature | Amazon S3 | Amazon EBS |
|---------|-----------|------------|
| **Type** | Object Storage | Block Storage |
| **Access** | HTTP/HTTPS endpoint | Attached to EC2 |
| **Use Case** | Static websites, backups, media | OS disks, databases |
| **Durability** | 99.999999999% (11 9s) | Tied to one AZ |
| **Pricing** | Per GB stored + requests | Per GB provisioned |
| **Web Hosting** | ✅ Native support | ❌ Requires web server |
| **Snapshots** | ❌ Not applicable | ✅ Point-in-time backups |

### Outcome

Successfully hosted a static website on S3 and performed EBS volume creation, formatting, mounting, snapshot backup, and snapshot restoration — with data integrity verified end-to-end.

---

## 💡 Key Concepts Learned

| Concept | Description |
|---------|-------------|
| **Amazon EC2** | Virtual servers in the AWS cloud |
| **AMI** | Amazon Machine Image — OS template for instances |
| **Key Pairs** | SSH authentication using public/private keys |
| **Security Groups** | Stateful virtual firewall at the instance level |
| **Elastic IP** | Static public IP that persists across instance restarts |
| **VPC** | Logically isolated virtual network in AWS |
| **Public Subnet** | Subnet with a route to the Internet Gateway |
| **Private Subnet** | Subnet with no direct internet access |
| **Internet Gateway** | Connects VPC to the public internet |
| **NAT Gateway** | Allows private subnet outbound access, blocks inbound |
| **Route Table** | Rules that direct traffic within a VPC |
| **Amazon S3** | Scalable object storage; native static site hosting |
| **Amazon EBS** | Persistent block storage attached to EC2 |
| **EBS Snapshot** | Point-in-time backup of an EBS volume |
| **Nginx / Apache** | Web server software for serving HTML pages |

---

## 🛠️ AWS Services Used

- Amazon EC2
- Amazon VPC
- Internet Gateway (IGW)
- NAT Gateway
- Elastic IP
- Route Tables
- Security Groups
- Amazon S3
- Amazon EBS
- Amazon EBS Snapshots

---

