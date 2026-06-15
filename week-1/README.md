# Week 1 Learning: Cloud Computing, SDLC, Linux, Shell Scripting, Git & GitHub

This repository contains notes and concepts learned in **Week 1** of my study plan. It covers:

- ☁️ Cloud Computing Basics
- 🔄 Software Development Life Cycle (SDLC) Concepts
- 🐧 Linux & Shell Scripting Concepts
- 🐙 Git & GitHub

---

## 📚 Table of Contents

1. [Cloud Computing Basics](#cloud-computing-basics)
2. [SDLC Concepts](#sdlc-concepts)
3. [Linux & Shell Scripting Concepts](#linux--shell-scripting-concepts)
4. [Git & GitHub](#git--github)

---

## ☁️ Cloud Computing Basics

**Cloud Computing** is the delivery of computing services over the internet ("the cloud"), which includes servers, storage, databases, networking, software, analytics, and more.

### 🔑 Key Concepts

#### Deployment Models

| Model | Description | Example |
|-------|-------------|---------|
| **Public Cloud** | Shared resources over the internet | AWS, Azure, GCP |
| **Private Cloud** | Dedicated resources for a single organization | On-premise servers |
| **Hybrid Cloud** | Combination of public and private clouds | Mixed environments |

#### Service Models

| Model | Full Form | Description | Example |
|-------|-----------|-------------|---------|
| **IaaS** | Infrastructure as a Service | Virtualized computing resources | AWS EC2 |
| **PaaS** | Platform as a Service | Platform to build/deploy applications | AWS Elastic Beanstalk |
| **SaaS** | Software as a Service | Software delivered over the internet | Gmail, Slack |

#### ✅ Key Benefits

- 📈 **Scalability** — Scale resources up or down as needed
- 💰 **Cost Efficiency** — Pay only for what you use
- 🔧 **Flexibility** — Access from anywhere, anytime
- 🛡️ **Disaster Recovery** — Built-in backup and recovery options

### 🛠️ Practice Tasks

- [ ] Create a free-tier cloud account (AWS / Azure / GCP)
- [ ] Launch a simple virtual server

---

## 🔄 SDLC Concepts

**Software Development Life Cycle (SDLC)** defines the steps for developing high-quality software efficiently.

### 📋 SDLC Phases

```
1. Requirement Analysis  →  Gather and document requirements
2. Design               →  Architecture, UI/UX, database schema
3. Implementation       →  Writing actual code
4. Testing              →  Verify functionality and fix bugs
5. Deployment           →  Release software to production
6. Maintenance          →  Monitor, update, and optimize software
```

### 🧩 SDLC Models

| Model | Description |
|-------|-------------|
| **Waterfall** | Sequential, phase-by-phase approach |
| **Agile** | Iterative and incremental development |
| **V-Model** | Testing planned alongside development |
| **Spiral** | Risk-driven, iterative approach |

### 💡 Key Points

- ✅ Ensures structured development
- ✅ Reduces risks
- ✅ Improves software quality

---

## 🐧 Linux & Shell Scripting Concepts

**Linux** is an open-source operating system; **Shell Scripting** automates repetitive tasks.

### 📁 Linux Basics

#### File System Structure

| Directory | Purpose |
|-----------|---------|
| `/home` | User home directories |
| `/etc` | Configuration files |
| `/var` | Variable data (logs, temp files) |
| `/usr` | User programs and utilities |

#### Common Commands

```bash
ls        # List directory contents
cd        # Change directory
pwd       # Print working directory
mkdir     # Create a new directory
rm        # Remove files or directories
chmod     # Change file permissions
ps        # Display running processes
top       # Real-time process monitoring
kill      # Terminate a process
```

### 📝 Shell Scripting Basics

A **Shell Script** is a file containing sequential commands executed by the shell to automate tasks.

#### Sample Script

```bash
#!/bin/bash
# Script to display date and time

echo "Hello, Sai Venkat!"
echo "Current Date and Time: $(date)"
```

> **Tip:** Always start a script with `#!/bin/bash` (the shebang line) to specify the interpreter.

---

## 🐙 Git & GitHub

**Git** is a distributed version control system; **GitHub** is a platform to host and collaborate on Git repositories.

### ⚙️ Essential Git Commands

#### Repository Setup

```bash
git init                          # Initialize a new repository
git clone <repo-url>              # Clone an existing repository
```

#### Daily Workflow

```bash
git status                        # Check the status of changes
git add .                         # Stage all changes
git commit -m "your message"      # Commit staged changes
git log                           # View commit history
```

#### Branching & Merging

```bash
git branch                        # List all branches
git branch <branch-name>          # Create a new branch
git checkout <branch-name>        # Switch to a branch
git merge <branch-name>           # Merge a branch into current
```

#### Remote Repository

```bash
git remote add origin <repo-url>  # Link to a remote repository
git push -u origin main           # Push to remote (first time)
git push                          # Push subsequent commits
git pull                          # Pull latest changes
```

### 🔗 Example Remote Setup

```bash
git remote add origin https://github.com/username/repo.git
git push -u origin main
```

---

> 
> 