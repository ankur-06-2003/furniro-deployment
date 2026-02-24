# Furniro E-Commerce Platform - Kubernetes Deployment & DevOps

A production-grade, cloud-native deployment infrastructure for the **Furniro E-Commerce Platform** using Kubernetes, GitOps, and modern DevOps best practices.

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Key Components](#key-components)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [CI/CD Pipeline](#cicd-pipeline)
- [Kubernetes Architecture](#kubernetes-architecture)
- [Security Implementation](#security-implementation)
- [Monitoring & Observability](#monitoring--observability)
- [Vault Integration](#vault-integration)
- [Setup & Configuration](#setup--configuration)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Project Overview

**Furniro** is a full-stack e-commerce platform with dedicated **Backend API** and **Frontend** applications. This repository contains the complete Kubernetes manifests and DevOps infrastructure for deploying Furniro on **Google Kubernetes Engine (GKE)**.

### Key Features:
- ✅ **Three-Tier Architecture**: Frontend, API Backend, and MongoDB Database
- ✅ **CI/CD Pipeline**: Automated build, test, security scan, and deployment via Jenkins
- ✅ **GitOps Deployment**: Argo CD for declarative, version-controlled infrastructure
- ✅ **Security-First**: OWASP checks, Trivy vulnerability scanning, RBAC, Network Policies
- ✅ **Secret Management**: HashiCorp Vault integration for secure credential handling
- ✅ **Observability**: Prometheus metrics collection and Grafana visualization
- ✅ **High Availability**: Rolling updates, horizontal scaling, multi-replica deployments
- ✅ **Infrastructure as Code**: Terraform-managed cloud resources with kind cluster configuration

---

## 🏗️ Architecture

### DevOps Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│  CONTINUOUS INTEGRATION (CI) FLOW                                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Developer  →  GitHub  →  Jenkins  →  SonarQube  →  Trivy  →  OWASP     │
│           git commit   (Source)      (Quality)   (Security) (Check)     │
│                                                                         │
│                                          ↓                              │
│                                                                         │
│                              Artifact Registry 🏠                       │
│                              (Docker Images)                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  CONTINUOUS DELIVERY (CD) & GITOPS                                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  GitHub Manifests Repo  →  Helm Charts  →  Argo CD  →  GKE Cluster      │
│  (K8s Configs)            (Templates)      (GitOps)    (Deploy)         │
│                                                                         │
│  Terraform (IaC)  →  Infrastructure Provisioning  →  GKE Setup          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

                    ╔════════════════════════════════╗
                    ║   Google Kubernetes Engine      ║
                    ║   (GKE Cluster)                 ║
                    ║  ┌────────────────────────────┐ ║
                    ║  │ Frontend PODs (HTML/CSS)   │ ║
                    ║  │ API Backend PODs (Node)    │ ║
                    ║  │ MongoDB StatefulSet        │ ║
                    ║  │ Ingress Controller         │ ║
                    ║  └────────────────────────────┘ ║
                    ║                                 ║
                    ║  Monitoring:                    ║
                    ║  ├─ Prometheus (Metrics)        ║
                    ║  └─ Grafana (Dashboards)        ║
                    ╚═══════════════════════════════-═╝
```

### Data Flow

1. **Development Phase**: Developer commits code to GitHub
2. **CI Phase**: Jenkins automatically triggers the pipeline
   - Pulls source code from application repository
   - Runs SonarQube code quality checks
   - Executes Trivy security vulnerability scans
   - Performs OWASP compliance checks
3. **Build & Push**: Docker images are built and pushed to Google Artifact Registry
4. **CD Phase**: Kubernetes manifests are automatically updated
5. **GitOps Deployment**: Argo CD syncs the cluster state with Git repository
6. **Monitoring**: Prometheus collects metrics; Grafana creates visualization dashboards

---

## 📁 Project Structure

```
furniro-deployment/
├── furniro-k8s-Manifests-file/       # Kubernetes Manifests
│   ├── README.md                      # This file
│   ├── config.yaml                    # KIND cluster configuration
│   ├── jenkinsfile                    # CI/CD pipeline definition
│   │
│   ├── backend/                       # Backend API Deployment
│   │   ├── deployment.yaml            # Backend deployment spec
│   │   ├── service.yaml               # Backend service configuration
│   │   ├── serviceAccount.yaml        # RBAC service account
│   │   ├── configmap.yaml             # Configuration data
│   │   ├── secrets.yaml               # Sensitive data (encrypted)
│   │   ├── hpa.yaml                   # Horizontal Pod Autoscaler
│   │   ├── rbac.yaml                  # Role-based access control
│   │   └── backend-policy.hcl         # Vault policy
│   │
│   ├── frontend/                      # Frontend Application Deployment
│   │   ├── deployment.yaml            # Frontend deployment spec
│   │   ├── service.yaml               # Frontend service
│   │   ├── serviceAccount.yaml        # RBAC service account
│   │   ├── hpa.yaml                   # Horizontal Pod Autoscaler
│   │   └── configmap.yaml             # Environment variables
│   │
│   ├── database/                      # MongoDB Database
│   │   ├── statefulset.yaml           # MongoDB stateful deployment
│   │   ├── service.yaml               # MongoDB service (headless)
│   │   └── pvc.yaml                   # Persistent volume claims
│   │
│   ├── ingress/                       # API Gateway & Routing
│   │   └── ingress.yaml               # Ingress controller rules
│   │
│   └── vault/                         # Secret Management
│       ├── setup.sh                   # Vault initialization script
│       └── IMPLEMENTATION_CHECKLIST.md # Vault integration guide
│
└── flowchart.xml                      # Architecture diagram (diagrams.net format)
```

---

## 🔧 Key Components

### 1. **Backend (Node.js API)**
- **Framework**: Express.js or similar Node.js framework
- **Database**: MongoDB (NoSQL)
- **Replicas**: 2 (production), configurable via HPA
- **Port**: 8000/3002
- **Image Registry**: Google Artifact Registry

**Deployment Features**:
- Vault agent injection for secrets
- JWT authentication support
- Cloudinary integration for image storage
- MongoDB username/password from Vault

### 2. **Frontend (Next.js/React)**
- **Framework**: Next.js or React
- **Replicas**: 2 (deployment), configurable via HPA
- **Port**: 3000
- **Image Registry**: Google Artifact Registry

**Features**:
- Dynamic API endpoints via environment variables
- Base URL configuration support
- Rolling update strategy

### 3. **Database (MongoDB)**
- **Deployment**: StatefulSet (persistent state)
- **Replicas**: 1 (configurable for HA)
- **Persistence**: PersistentVolumeClaim (PVC)
- **Port**: 27017
- **Security**: Non-root user (UID 999)

### 4. **Ingress Controller**
- Routes external traffic to frontend and backend
- Load balancing across multiple pods
- TLS/SSL termination support

### 5. **Monitoring Stack**
- **Prometheus**: Metrics collection and storage
- **Grafana**: Real-time dashboards and alerting

### 6. **Secret Management**
- **HashiCorp Vault**: Centralized secret storage
- **Vault Agent Injector**: Automatic secret injection into pods

---

## 📋 Prerequisites

Before deploying Furniro, ensure you have:

### Local Environment
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Kubernetes CLI
- [docker](https://www.docker.com/products/docker-desktop) - Container runtime
- [helm](https://helm.sh/docs/intro/install/) - Package manager for Kubernetes
- [terraform](https://www.terraform.io/downloads) - Infrastructure as Code
- [gcloud CLI](https://cloud.google.com/sdk/docs/install) - Google Cloud SDK
- [vault CLI](https://www.vaultproject.io/downloads) - HashiCorp Vault CLI

### Cloud Setup
- Active Google Cloud Project with GKE enabled
- Service Account with appropriate IAM roles
- GCP Artifact Registry repository
- HCP Vault cluster (or self-hosted Vault)

### CI/CD Requirements
- Jenkins server running
- Jenkins plugins: Docker, Kubernetes, SonarQube, GitHub
- Credentials configured:
  - `gcp-project-id` (GCP project ID)
  - `github-token` (GitHub personal access token)
  - `Sonar-token` (SonarQube authentication)

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/ankur-06-2003/furniro-deployment.git
cd furniro-deployment/furniro-k8s-Manifests-file
```

### 2. Configure kubectl

```bash
# Set up GKE credentials (if using GKE)
gcloud container clusters get-credentials furniro-cluster --region=us-central1

# Or configure for local KIND cluster
kubectl config use-context kind-furniro
```

### 3. Create Namespace

```bash
kubectl create namespace three-tier
```

### 4. Deploy MongoDB

```bash
# Create MongoDB secrets
kubectl apply -f database/pvc.yaml -n three-tier
kubectl apply -f database/service.yaml -n three-tier
kubectl apply -f database/statefulset.yaml -n three-tier

# Verify
kubectl get statefulset -n three-tier
```

### 5. Deploy Backend API

```bash
kubectl apply -f backend/configmap.yaml -n three-tier
kubectl apply -f backend/secrets.yaml -n three-tier
kubectl apply -f backend/serviceAccount.yaml -n three-tier
kubectl apply -f backend/deployment.yaml -n three-tier
kubectl apply -f backend/service.yaml -n three-tier
kubectl apply -f backend/hpa.yaml -n three-tier
kubectl apply -f backend/rbac.yaml -n three-tier

# Verify
kubectl get deployment -n three-tier
kubectl logs -f deployment/api -n three-tier
```

### 6. Deploy Frontend

```bash
kubectl apply -f frontend/serviceAccount.yaml -n three-tier
kubectl apply -f frontend/deployment.yaml -n three-tier
kubectl apply -f frontend/service.yaml -n three-tier
kubectl apply -f frontend/hpa.yaml -n three-tier

# Verify
kubectl get deployment -n three-tier
kubectl logs -f deployment/frontend -n three-tier
```

### 7. Configure Ingress

```bash
kubectl apply -f ingress/ingress.yaml -n three-tier

# Get ingress IP
kubectl get ingress -n three-tier
```

### 8. Verify All Components

```bash
# Check all resources in the three-tier namespace
kubectl get all -n three-tier

# Get detailed pod status
kubectl get pods -n three-tier -o wide

# Verify services
kubectl get svc -n three-tier
```

---

## 🔄 CI/CD Pipeline

### Pipeline Stages

The Jenkins pipeline (defined in `jenkinsfile`) executes the following stages:

#### Stage 1: **Clean Workspace**
```groovy
cleanWs()  // Clean Jenkins workspace
```

#### Stage 2: **Checkout Application Repo**
```groovy
git branch: 'main',
    url: 'https://github.com/ankur-06-2003/furniro-ecommerce.git'
```

#### Stage 3: **Configure GCP & Docker**
```bash
gcloud auth configure-docker ${REGION}-docker.pkg.dev
```

#### Stage 4: **Trivy Filesystem Scan**
```bash
trivy fs --format table -o trivy-fs-report.html .
```
- Scans source code for vulnerabilities before build

#### Stage 5: **SonarQube Code Quality Analysis**
```bash
sonar-scanner \
  -Dsonar.projectKey=furniro \
  -Dsonar.projectName=furniro \
  -Dsonar.qualitygate.wait=true
```

#### Stage 6: **Build Docker Images**
```bash
docker build -t furniro-backend:latest ./backend
docker build -t furniro-frontend:latest ./frontend
```

#### Stage 7: **Push to Artifact Registry**
```bash
docker tag furniro-backend:latest $BACKEND_URI:${IMAGE_TAG}
docker push $BACKEND_URI:${IMAGE_TAG}
```

#### Stage 8: **Trivy Image Vulnerability Scan**
```bash
trivy image --severity CRITICAL --exit-code 1 $BACKEND_URI:${IMAGE_TAG}
```
- **Fails pipeline on CRITICAL vulnerabilities**

#### Stage 9: **OWASP Dependency Check**
- Validates dependencies against known vulnerabilities

#### Stage 10: **Checkout Deployment Repo**
```groovy
git branch: 'main',
    url: 'https://github.com/ankur-06-2003/furniro-deployment.git'
```

#### Stage 11: **Update Kubernetes Manifests**
```bash
sed -i "s|image: .*furniro-backend.*|image: $BACKEND_URI:${IMAGE_TAG}|" backend/deployment.yaml
```
- Automatically updates image tags in deployment manifests

#### Stage 12: **Commit & Push CD Changes**
```bash
git commit -m "CI: Update images to ${IMAGE_TAG}"
git push https://${TOKEN_APP_NAME}:${GITHUB_TOKEN}@github.com/ankur-06-2003/furniro-deployment.git HEAD:main
```

### Image Tagging Strategy

```
IMAGE_TAG = "1.0.${BUILD_NUMBER}"
```
- **Example**: `1.0.42` for the 42nd build
- Combines semantic versioning with CI build number for immutability and ordering

### Pipeline Trigger

The pipeline automatically triggers when:
- Code is pushed to the `main` branch in the application repository
- GitHub webhook notifies Jenkins of the push

---

## ☸️ Kubernetes Architecture

### Namespace Organization

All resources are deployed in the `three-tier` namespace:

```bash
kubectl config set-context --current --namespace=three-tier
```

### Pod Architecture

```
┌─────────────────────────────────────────────────────┐
│         three-tier Namespace                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Frontend Deployment (Replicas: 2)                  │
│  ├─ frontend-pod-1 (3000/tcp)                       │
│  └─ frontend-pod-2 (3000/tcp)                       │
│         ↓                                           │
│    Frontend Service (ClusterIP)                     │
│                                                     │
│  Backend Deployment (Replicas: 2)                   │
│  ├─ api-pod-1 (8000/tcp)                            │
│  └─ api-pod-2 (8000/tcp)                            │
│         ↓                                           │
│    Backend Service (ClusterIP)                      │
│                                                     │
│  MongoDB StatefulSet (Replicas: 1)                  │
│  ├─ mongodb-0 (27017/tcp)                           │
│         ↓                                           │
│    MongoDB Service (Headless) (27017/tcp)           │
│                                                     │
│  Ingress Controller                                 │
│  ├─ Routes /api → Backend Service                   │
│  └─ Routes / → Frontend Service                     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Scaling Configuration

#### Horizontal Pod Autoscaler (HPA)

**Backend HPA**:
```yaml
apiVersion: autoscaling/v2
metadata:
  name: backend-hpa
spec:
  scaleTargetRef:
    kind: Deployment
    name: api
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

**Frontend HPA**: Similar configuration with 2-5 replicas

### Deployment Strategy

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1          # Maximum 1 extra pod during update
    maxUnavailable: 1    # Maximum 1 unavailable pod
```
- Ensures zero-downtime deployments
- Gradually replaces old pods with new ones

---

## 🔒 Security Implementation

### 1. **RBAC (Role-Based Access Control)**

Each component has dedicated ServiceAccount with minimal permissions:

```yaml
# backend/serviceAccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backend-sa
  namespace: three-tier
```

Associated RBAC rules in `backend/rbac.yaml`:
- Minimal required permissions
- Read-only access to ConfigMaps and Secrets
- No cluster-admin privileges

### 2. **Vault Integration**

#### Agent Injection Annotations

```yaml
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/agent-inject-status: "update"
vault.hashicorp.com/role: "backend-role"
vault.hashicorp.com/agent-inject-secret-app-secrets: "secret/data/furniro/backend/secrets"
```

#### Injected Secrets

Vault automatically injects:
- `JWT_SECRET` - JWT signing key
- `CLOUDINARY_CLOUD_NAME` - Image storage service
- `CLOUDINARY_API_KEY` - Image service credentials
- `MONGO_USERNAME` - Database authentication
- `MONGO_PASSWORD` - Database password

### 3. **Secrets Management**

```yaml
# backend/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mongo-sec
type: Opaque
data:
  username: <base64-encoded>
  password: <base64-encoded>
```

**Best Practices**:
- ✅ Encrypt at rest using KMS
- ✅ Encrypt in transit (HTTPS/TLS)
- ✅ Rotate secrets regularly
- ✅ Use Vault for secret generation and rotation
- ❌ Never commit secrets to Git

### 4. **Network Security**

#### Pod Security Context

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 999                    # MongoDB user
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL                         # Drop all unsafe Linux capabilities
```

#### Image Pull Security

```yaml
imagePullPolicy: IfNotPresent       # Only use cached images by default
```

### 5. **CI/CD Security Scans**

**SonarQube**: Code quality and bug detection
**Trivy**: Container image vulnerability scanning
- Fails on CRITICAL vulnerabilities
- Scans filesystem and dependencies

**OWASP**: Dependency security analysis

---

## 📊 Monitoring & Observability

### Prometheus Configuration

Prometheus automatically scrapes metrics from:
- API backend pods (Kubernetes metrics)
- MongoDB database
- Job queue and worker processes

### Grafana Dashboards

Pre-configured dashboards visualize:
- Pod CPU and memory usage
- Network I/O metrics
- Database connection counts
- Request latency metrics
- Error rates and 5xx responses

### Metric Collection

```
GKE Cluster
    ↓
Prometheus Scraper (30s interval)
    ↓
Prometheus Database (15 days retention)
    ↓
Grafana Visualization
```

### Alert Rules

Example alert conditions:
- Pod CrashLoopBackOff
- High CPU usage (>80%)
- High memory usage (>85%)
- Database unavailable
- API response time > 5s

---

## 🔐 Vault Integration

### Setup Process

The Vault setup is documented in `vault/IMPLEMENTATION_CHECKLIST.md` and automated by `vault/setup.sh`.

#### Phase 1: Prerequisites
- [ ] HCP Vault cluster running and accessible
- [ ] Kubernetes cluster admin access
- [ ] Vault CLI installed
- [ ] Helm installed

#### Phase 2: Install Vault Agent Injector

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault \
  --set injector.enabled=true \
  -n vault --create-namespace
```

#### Phase 3: Configure Kubernetes Auth

```bash
vault auth enable kubernetes
vault write auth/kubernetes/config \
  kubernetes_host="$K8S_HOST" \
  kubernetes_ca_cert="$K8S_CA_CERT" \
  token_reviewer_jwt="$K8S_TOKEN"
```

#### Phase 4: Create Secret Policies

```bash
vault write secret/data/furniro/backend/secrets \
  JWT_SECRET="..." \
  CLOUDINARY_CLOUD_NAME="..." \
  CLOUDINARY_API_KEY="..." \
  MONGO_USERNAME="..." \
  MONGO_PASSWORD="..."
```

#### Phase 5: Link Service Accounts

```bash
vault write auth/kubernetes/role/backend-role \
  bound_service_account_names=backend-sa \
  bound_service_account_namespaces=three-tier \
  policies=backend-policy \
  ttl=24h
```

### Secret Rotation

Vault automatically rotates secrets using:
- Time-based rotation (e.g., daily)
- Database password auto-rotation
- JWT token refresh

---

## ⚙️ Setup & Configuration

### Environment Variables

**Frontend** (`frontend/configmap.yaml`):
```yaml
NEXT_PUBLIC_API_URL: "https://api.furniro.example.com"
NEXT_PUBLIC_BASE_URL: "https://furniro.example.com"
```

**Backend** (Vault + Secrets):
```
MONGO_URI: "mongodb://mongodb-sa:password@mongodb-svc:27017/furniro"
JWT_SECRET: <from Vault>
CLOUDINARY_CLOUD_NAME: <from Vault>
```

### Database Initialization

MongoDB initializes with:
- Root username/password from Secrets
- Default database: `furniro`
- Automatic schema creation

### Persistent Storage

```yaml
# database/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodb-pvc
  namespace: three-tier
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 10Gi
```

---

## 🤝 Contributing

### Branch Naming Convention

- `main` - Production branch (protected)
- `develop` - Development branch
- `feature/*` - Feature branches
- `bugfix/*` - Bug fix branches
- `hotfix/*` - Production hotfixes

### Pull Request Process

1. Create feature branch from `develop`
2. Make changes and commit
3. Push to remote and create pull request
4. Request review from maintainers
5. Address feedback and address comments
6. Merge after approval

### Code Standards

- Consistent Kubernetes YAML formatting
- Comments for non-obvious configurations
- Resource requests and limits defined
- Health checks (livenessProbe, readinessProbe)

---

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. **Pod Not Starting (ImagePullBackOff)**

```bash
# Check event logs
kubectl describe pod <pod-name> -n three-tier

# Solution: Verify image registry credentials and image URI
kubectl get secret -n three-tier
```

#### 2. **Database Connection Failures**

```bash
# Test MongoDB connectivity
kubectl exec -it deployment/api -n three-tier -- \
  npm run db:test

# Check MongoDB logs
kubectl logs -f statefulset/mongodb -n three-tier
```

#### 3. **Secrets Not Injected**

```bash
# Verify Vault agent injector is running
kubectl get pods -n vault

# Check pod annotations
kubectl describe pod <api-pod> -n three-tier | grep vault

# View agent logs
kubectl logs <api-pod> -c vault-agent -n three-tier
```

#### 4. **High Memory Usage**

```bash
# Check resource usage
kubectl top pods -n three-tier

# Increase limits in deployment.yaml
# Increase HPA maxReplicas for autoscaling
```

#### 5. **CI/CD Pipeline Failures**

Pipeline failure diagnosis:
1. Check Jenkins logs in dashboard
2. Review SonarQube quality gates
3. Verify Trivy scan results
4. Check GitHub credentials in Jenkins

```bash
# Verify credentials
jenkins-cli list-credentials
jenkins-cli get-credentials gcp-project-id
```

#### 6. **Kubectl Connection Issues**

```bash
# Verify kubectl configuration
kubectl config current-context
kubectl config view

# Reset kubectl cluster connection
gcloud container clusters get-credentials furniro-cluster \
  --region=us-central1 --project=PROJECT_ID

# Or for KIND cluster
kubectl config use-context kind-furniro
```

### Debug Commands

```bash
# Get all resources with full information
kubectl get all -n three-tier -o wide

# Describe specific pod
kubectl describe pod <pod-name> -n three-tier

# View pod logs
kubectl logs <pod-name> -n three-tier
kubectl logs -f <pod-name> -n three-tier  # Stream logs

# Execute command in pod
kubectl exec -it <pod-name> -n three-tier -- /bin/bash

# Port forward for local testing
kubectl port-forward svc/frontend 3000:3000 -n three-tier &
kubectl port-forward svc/api 8000:8000 -n three-tier &

# Check resource requests vs actual usage
kubectl describe node
kubectl top nodes
kubectl top pods -n three-tier
```

---

## 📚 Additional Resources

### Official Documentation
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Google Kubernetes Engine Docs](https://cloud.google.com/kubernetes-engine/docs)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [HashiCorp Vault Docs](https://www.vaultproject.io/docs)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/grafana/)

### Related Repositories
- [Furniro E-Commerce Backend](https://github.com/ankur-06-2003/furniro-ecommerce)
- [Furniro Frontend Application](https://github.com/ankur-06-2003/furniro-frontend)

---

## 📞 Support & Contact

For questions or issues, please:
1. Check this README and troubleshooting section
2. Review the vault implementation checklist
3. Consult the Jenkins pipeline logs
4. Open an issue in the GitHub repository
5. Contact the maintainer: [ankuryadav8802@gmail.com](mailto:ankuryadav8802@gmail.com)

---

## 📄 License

This project infrastructure is maintained by the Furniro team.

---

**Last Updated**: February 24, 2026  
**Maintained By**: Ankur Yadav  
**Repository**: [furniro-deployment](https://github.com/ankur-06-2003/furniro-deployment)

---

### Quick Links

- 🚀 [Getting Started](#getting-started)
- 🏗️ [Architecture](#architecture)
- 🔄 [CI/CD Pipeline](#cicd-pipeline)
- 🔐 [Security Implementation](#security-implementation)
- 📊 [Monitoring](#monitoring--observability)
- 🔧 [Troubleshooting](#troubleshooting)
