# Multi-Tier Application on Kubernetes

A production-style, three-tier web application — **Frontend**, **Backend API**, and **MySQL Database** — deployed and managed entirely on **Kubernetes**, packaged as a reusable **Helm Chart**. This project demonstrates end-to-end container orchestration: Deployments, Services, ConfigMaps, Secrets, Persistent Storage, and Ingress-based routing on a local Minikube cluster.

---

## 📐 Architecture

The application follows a standard three-tier architecture. External traffic enters through an NGINX Ingress Controller, which routes requests to the Frontend and Backend services. The Backend communicates with a MySQL database backed by persistent storage. Configuration and credentials are injected via ConfigMaps and Secrets rather than hard-coded into the application.

```
                         ┌─────────────────────┐
                         │      End User        │
                         │     (Browser)         │
                         └──────────┬───────────┘
                                    │ HTTP(S)
                                    ▼
                         ┌─────────────────────┐
                         │  NGINX Ingress        │
                         │  Controller           │
                         └──────────┬───────────┘
                     ┌──────────────┴──────────────┐
                     │ / (path)                    │ /api (path)
                     ▼                              ▼
          ┌─────────────────────┐        ┌─────────────────────┐
          │  frontend-service    │        │  backend-service      │
          │  (ClusterIP)         │        │  (ClusterIP)           │
          └──────────┬───────────┘        └──────────┬───────────┘
                     ▼                                ▼
          ┌─────────────────────┐        ┌─────────────────────┐
          │  Frontend Pods        │──────▶│  Backend API Pods     │
          │  (Deployment)         │ REST  │  (Deployment)         │
          └─────────────────────┘        └──────────┬───────────┘
                                                       │ SQL
                                                       ▼
                                          ┌─────────────────────┐
                                          │   mysql-service        │
                                          │   (ClusterIP)           │
                                          └──────────┬───────────┘
                                                       ▼
                                          ┌─────────────────────┐
                                          │    MySQL Pod            │
                                          │   (Deployment)          │
                                          └──────────┬───────────┘
                                                       ▼
                                          ┌─────────────────────┐
                                          │  PVC → Persistent      │
                                          │  Volume (data)         │
                                          └─────────────────────┘

     ConfigMap ──▶ env vars ──▶ Frontend Pods, Backend Pods
     Secret     ──▶ DB creds  ──▶ Backend Pods, MySQL Pod
```

> **Architecture diagram image:**
> ![Kubernetes Architecture Diagram](./architecture/k8s_architecture.png)

**Flow summary:**
1. The user's browser sends a request to the cluster's Ingress endpoint.
2. The NGINX Ingress Controller routes `/` to the Frontend Service and `/api` to the Backend Service based on path rules.
3. The Frontend Service load-balances requests across Frontend Pods.
4. The Frontend calls the Backend API over the internal `backend-service` ClusterIP.
5. The Backend Service load-balances requests across Backend API Pods.
6. The Backend queries MySQL through the internal `mysql-service` ClusterIP.
7. MySQL persists data to a Persistent Volume via a Persistent Volume Claim, so data survives Pod restarts.
8. Application configuration is injected via a ConfigMap; database credentials are injected via a Secret — neither is hard-coded in the manifests or images.

---

## ✨ Features

- Three-tier architecture: Frontend, Backend API, and MySQL, fully containerized
- Declarative deployment via Kubernetes manifests and a custom Helm Chart
- Externalized configuration using ConfigMaps and Secrets
- Persistent, restart-safe database storage using PV/PVC
- Path-based routing through a single NGINX Ingress Controller
- Independently scalable tiers via Kubernetes Deployments
- Environment-specific configuration through Helm `values.yaml` overrides
- Clean separation of concerns between application code and infrastructure manifests

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Frontend | HTML/CSS/JS (containerized, served via Nginx) |
| Backend API | REST API service (containerized) |
| Database | MySQL 8.0 |
| Orchestration | Kubernetes (Minikube) |
| Packaging | Helm 3 |
| Ingress | NGINX Ingress Controller |
| Storage | Kubernetes PersistentVolume / PersistentVolumeClaim |
| Config Management | Kubernetes ConfigMap & Secret |
| Local Dev Cluster | Minikube (Docker driver) |

---

## 📡 API Details

The Backend exposes a REST API consumed by the Frontend and reachable inside the cluster at `http://backend-service` (port `80`).

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/` | Health/status check — confirms the Backend API is running |
| `GET` | `/api/items` | Returns a list of items from the MySQL database |
| `POST` | `/api/items` | Creates a new item in the database |
| `GET` | `/api/items/:id` | Retrieves a single item by ID |
| `PUT` | `/api/items/:id` | Updates an existing item |
| `DELETE` | `/api/items/:id` | Deletes an item by ID |

> Update this table to match your Backend's actual routes and payloads.

---

## 📁 Folder Structure

```
final-project/
├── backend/
│   └── ...                     # Backend API source code & Dockerfile
├── frontend/
│   └── ...                     # Frontend source code & Dockerfile
├── config/
│   └── ...                     # App-level config files
├── architecture/
│   └── k8s_architecture.png    # Architecture diagram
├── screenshots/
│   └── ...                     # Deployment & verification screenshots
├── helm/
│   └── final-project/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── .helmignore
│       └── templates/
│           ├── _helpers.tpl
│           ├── frontend-deployment.yaml
│           ├── frontend-service.yaml
│           ├── backend-deployment.yaml
│           ├── backend-service.yaml
│           ├── mysql-deployment.yaml
│           ├── mysql-service.yaml
│           ├── configmap.yaml
│           ├── secret.yaml
│           ├── pv.yaml
│           ├── pvc.yaml
│           └── ingress.yaml
├── README.md
└── LICENSE
```

---

## ✅ Prerequisites

- [Docker](https://www.docker.com/) installed and running
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) (or any Kubernetes cluster)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configured against your cluster
- [Helm 3](https://helm.sh/docs/intro/install/)
- An NGINX Ingress Controller enabled on the cluster

---

## 🚀 Installation & Setup

### 1. Clone the repository
```bash
git clone https://github.com/Dilip714/final-project.git
cd final-project
```

### 2. Start the local cluster
```bash
minikube start --driver=docker
minikube addons enable ingress
```

### 3. Build and load application images (if building locally)
```bash
docker build -t frontend:latest ./frontend
docker build -t backend:latest ./backend

# Make images available to Minikube
minikube image load frontend:latest
minikube image load backend:latest
```

### 4. Deploy with Helm
```bash
cd helm/final-project
helm lint .
helm install final-project .
```

### 5. Verify the deployment
```bash
kubectl get pods
kubectl get svc
kubectl get ingress
```

### 6. Access the application
```bash
minikube ip
# Add the IP to /etc/hosts if using a custom hostname, or:
minikube service frontend-service --url
```

---

## ▶️ Running & Common Operations

**Scale a tier:**
```bash
kubectl scale deployment backend-deployment --replicas=5
```

**Upgrade the release after a values/template change:**
```bash
helm upgrade final-project ./helm/final-project
```

**Roll back to a previous release:**
```bash
helm rollback final-project 1
```

**View release history:**
```bash
helm history final-project
```

**Tail logs for the Backend:**
```bash
kubectl logs -f deployment/backend-deployment
```

**Uninstall everything:**
```bash
helm uninstall final-project
```

---

## ⚙️ Configuration

Key values can be overridden in `helm/final-project/values.yaml` or via `--set` flags at install time:

```bash
helm install final-project . \
  --set frontend.image.tag=v1.2.0 \
  --set backend.replicaCount=3 \
  --set mysql.persistence.size=10Gi
```

| Parameter | Description | Default |
|---|---|---|
| `frontend.image.repository` | Frontend image repository | `frontend` |
| `frontend.image.tag` | Frontend image tag | `latest` |
| `backend.replicaCount` | Number of Backend replicas | `2` |
| `mysql.persistence.size` | MySQL PVC storage size | `5Gi` |
| `ingress.className` | Ingress class | `nginx` |
| `ingress.path` | Ingress base path | `/` |

---

## 🖼 Screenshots

> Replace these placeholders with your actual screenshots from the `screenshots/` folder.

**Cluster and Pods running:**
![Pods Running](./screenshots/pods-running.png)

**Services and Ingress configuration:**
![Services and Ingress](./screenshots/services-ingress.png)

**Frontend application in the browser:**
![Frontend App](./screenshots/frontend-app.png)

**Backend API response verification:**
![Backend API](./screenshots/backend-api.png)

**Helm release history:**
![Helm History](./screenshots/helm-history.png)

---

## 🧭 Deployment Guide (Summary)

1. Provision a Kubernetes cluster (Minikube for local development).
2. Enable the Ingress addon / install an Ingress Controller.
3. Build and publish (or load) the Frontend and Backend container images.
4. Configure `values.yaml` with your image tags, replica counts, and storage size.
5. Run `helm lint` to validate the chart, then `helm install`.
6. Confirm all Pods reach `Running` and Services/Ingress have the expected endpoints.
7. Access the app through the Ingress address and validate Frontend → Backend → MySQL connectivity.

---

## 🗺 Roadmap / Possible Improvements

- Add Horizontal Pod Autoscaling (HPA) for the Backend tier
- Add readiness/liveness probes to all Deployments
- Integrate a CI/CD pipeline (GitHub Actions) for automated build, test, and Helm deploy
- Migrate to a managed Kubernetes service (EKS) with TLS-enabled Ingress
- Externalize MySQL to a managed database service for production

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.

---

## 👤 Author

**Dilip**
GitHub: [Dilip714](https://github.com/Dilip714)
Portfolio: [portfolio-two-fawn-18.vercel.app](https://portfolio-two-fawn-18.vercel.app)
