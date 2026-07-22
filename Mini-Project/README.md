# Mini End-to-End App Deployment

A mini DevOps project that takes a simple containerized web application and deploys it through three complementary paths — a local Docker build, an automated AWS EC2 deployment (Terraform + GitHub Actions), and a Kubernetes deployment (Minikube) — using only concepts already covered in prior training modules.

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Docker](https://img.shields.io/badge/docker-ready-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

---

## Table of contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Tech stack](#tech-stack)
- [Folder structure](#folder-structure)
- [Getting started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running locally with Docker](#running-locally-with-docker)
  - [Deploying to AWS with Terraform](#deploying-to-aws-with-terraform)
  - [Deploying to Kubernetes](#deploying-to-kubernetes)
- [CI/CD pipeline](#cicd-pipeline)
- [API reference](#api-reference)
- [Screenshots](#screenshots)
- [Comparison: EC2 vs. Kubernetes](#comparison-ec2-vs-kubernetes)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This repository demonstrates a full containerized application lifecycle:

1. **Build** — A lightweight Python/Flask application is containerized with Docker.
2. **Push** — The image is published to Docker Hub, manually and via CI/CD.
3. **Deploy** — The image is deployed two independent ways:
   - **Path A:** A single AWS EC2 instance, provisioned with Terraform, pulling and running the container via a User Data bootstrap script.
   - **Path B:** A Kubernetes Deployment (2 replicas) running on Minikube, exposed through a NodePort Service.
4. **Automate** — A GitHub Actions workflow rebuilds and republishes the image on every push to `main`.

The goal is to show the same application running reliably across multiple deployment strategies, and to compare the operational differences between a plain virtual machine and a container-orchestrated environment.

---

## Architecture

```
 Developer
     │  git push
     ▼
 GitHub Actions  ──build & push image──▶  Docker Hub (image registry)
                                                │
                              ┌─────────────────┴─────────────────┐
                              ▼                                   ▼
                     EC2 instance                        Kubernetes cluster
                (provisioned via Terraform)             (Minikube, 2 replicas)
                              │                                   │
                              └─────────────────┬─────────────────┘
                                                 ▼
                                          User browser
```

**Flow description**

| Stage | Component | Responsibility |
|---|---|---|
| 1 | Developer | Writes code, commits, and pushes to the `main` branch |
| 2 | GitHub Actions | Checks out the repo, authenticates to Docker Hub, builds the image, and pushes it |
| 3 | Docker Hub | Stores and versions the built image (`dilipdev714/miniapp`) |
| 4a | EC2 instance | Terraform provisions the VM; a User Data script installs Docker, pulls the image, and runs the container on boot |
| 4b | Kubernetes cluster | A Deployment manifest runs 2 replicas of the same image; a NodePort Service exposes it |
| 5 | User browser | Sends an HTTP request to either the EC2 public IP or the Kubernetes NodePort and renders the response |

> **Architecture diagram image:** `docs/architecture-diagram.png`
>
> ![Architecture diagram](docs/architecture-diagram.png)

---

## Features

- Minimal Flask web application, fully containerized
- Single Dockerfile reused across all three deployment paths
- Infrastructure as Code with Terraform (EC2, security group, public subnet)
- Zero-touch instance bootstrap via EC2 User Data (installs Docker, pulls image, runs container)
- CI/CD pipeline with GitHub Actions — builds and pushes the Docker image on every push to `main`
- Kubernetes manifests for a 2-replica Deployment and a NodePort Service
- Side-by-side comparison of a traditional VM deployment vs. a container-orchestrated deployment
- Fully documented, screenshot-backed deployment walkthrough

---

## Tech stack

| Layer | Technology |
|---|---|
| Application | Python 3.12, Flask |
| Containerization | Docker |
| Image registry | Docker Hub |
| Infrastructure as Code | Terraform |
| Cloud provider | AWS (EC2, VPC, Security Groups) |
| CI/CD | GitHub Actions |
| Orchestration | Kubernetes (Minikube) |
| OS (EC2) | Amazon Linux 2023 |

---

## Folder structure

```
Mini-End-To-End-App/
├── app.py                      # Flask application entry point
├── requirements.txt            # Python dependencies
├── Dockerfile                  # Container image definition
├── README.md                   # Project documentation (this file)
│
├── .github/
│   └── workflows/
│       └── ci.yml               # GitHub Actions workflow: build & push Docker image
│
├── terraform/
│   ├── provider.tf              # AWS provider configuration
│   ├── main.tf                  # EC2 instance resource definition
│   ├── variables.tf             # Input variables
│   ├── outputs.tf                # Public IP / DNS outputs
│   ├── terraform.tfvars          # Variable values (not committed with secrets)
│   └── userdata.sh              # EC2 bootstrap script (installs Docker, runs container)
│
├── kubernetes/
│   ├── deployment.yaml           # Kubernetes Deployment (2 replicas)
│   └── service.yaml              # NodePort Service definition
│
└── docs/
    ├── architecture-diagram.png  # System architecture diagram
    └── screenshots/              # Deployment walkthrough screenshots
```

---

## Getting started

### Prerequisites

Make sure the following are installed and configured before proceeding:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.5+)
- An [AWS account](https://aws.amazon.com/) with configured credentials (`aws configure`)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) and [kubectl](https://kubernetes.io/docs/tasks/tools/)
- A [Docker Hub](https://hub.docker.com/) account

### Installation

```bash
git clone https://github.com/<your-username>/Mini-End-To-End-App.git
cd Mini-End-To-End-App
pip install -r requirements.txt
```

### Running locally with Docker

```bash
# Build the image
docker build -t <your-dockerhub-username>/miniapp:v1 .

# Run the container
docker run -d -p 5000:5000 --name miniapp <your-dockerhub-username>/miniapp:v1

# Push to Docker Hub
docker login
docker push <your-dockerhub-username>/miniapp:v1
```

The app will be available at `http://localhost:5000`.

### Deploying to AWS with Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Terraform will output the instance's public IP and DNS name:

```
Outputs:
public_dns = "ec2-XX-XX-XX-XX.<region>.compute.amazonaws.com"
public_ip  = "XX.XX.XX.XX"
```

The EC2 instance's User Data script automatically installs Docker, pulls the published image, and starts the container — no manual SSH steps are required for the first deployment. Visit `http://<public_ip>` in a browser to confirm the app is running.

To tear down the infrastructure:

```bash
terraform destroy
```

### Deploying to Kubernetes

```bash
minikube start

cd kubernetes
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

kubectl get pods
kubectl get deployments

minikube service miniapp-service
```

`minikube service` opens a tunnel and launches the app in your default browser via the NodePort Service.

---

## CI/CD pipeline

The workflow defined in [`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs automatically on every push to `main`:

1. Checks out the repository (`actions/checkout@v4`)
2. Authenticates to Docker Hub (`docker/login-action@v3`) using `DOCKER_USERNAME` and `DOCKER_PASSWORD` repository secrets
3. Builds the Docker image
4. Pushes the image to Docker Hub

To redeploy the latest image to the running EC2 instance, SSH in and run:

```bash
docker pull <your-dockerhub-username>/miniapp:latest
docker stop miniapp && docker rm miniapp
docker run -d -p 80:5000 --name miniapp <your-dockerhub-username>/miniapp:latest
```

---

## API reference

This project exposes a single route for demonstration purposes.

| Method | Endpoint | Description | Response |
|---|---|---|---|
| `GET` | `/` | Returns the application landing page | `200 OK`, HTML content |

> The application is intentionally minimal (a single Flask route) to keep the focus on the deployment pipeline rather than application logic. The Dockerfile and CI/CD structure generalize to any Flask/Node/PHP backend with additional routes or a connected database.

---

## Screenshots

| Stage | Screenshot |
|---|---|
| App running locally via Docker | ![Local run](docs/screenshots/01-local-docker-run.png) |
| Docker Hub repository | ![Docker Hub](docs/screenshots/02-dockerhub-repo.png) |
| Terraform apply output | ![Terraform apply](docs/screenshots/03-terraform-apply.png) |
| App running on EC2 | ![EC2 deployment](docs/screenshots/04-ec2-deployment.png) |
| GitHub Actions workflow run | ![GitHub Actions](docs/screenshots/05-github-actions-run.png) |
| App running via Kubernetes NodePort | ![Kubernetes deployment](docs/screenshots/06-kubernetes-deployment.png) |

---

## Comparison: EC2 vs. Kubernetes

| Aspect | EC2 (Terraform) | Kubernetes (Minikube) |
|---|---|---|
| Replica management | Manual — one container per instance | Automatic — Deployment controller maintains 2 replicas |
| Scaling | Requires provisioning additional instances | Change `replicas` in the manifest |
| Networking | Direct host port mapping | Abstracted via a Service (NodePort) |
| Redeployment | Manual SSH + `docker pull` / `docker run` | Rolling update via `kubectl apply` |
| Self-healing | None — a crashed container stays down | Kubernetes automatically restarts failed pods |
| Best suited for | Simple, low-traffic single-instance workloads | Applications needing resilience and horizontal scale |

---

## Roadmap

- [ ] Add a persistent database tier (PostgreSQL/MySQL) to complete the two-tier architecture
- [ ] Add health checks and readiness probes to the Kubernetes Deployment
- [ ] Automate EC2 redeployment via GitHub Actions (`workflow_dispatch` + SSH action)
- [ ] Add HTTPS termination via an Application Load Balancer / Ingress
- [ ] Add unit and integration tests to the CI pipeline

---

## Contributing

Contributions are welcome. Please open an issue to discuss proposed changes before submitting a pull request.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m "Add my feature"`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a pull request

---

## License

This project is licensed under the [MIT License](LICENSE).
