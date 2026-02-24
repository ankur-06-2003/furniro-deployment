# Furniro GKE Terraform with Vault

Production-ready Terraform configuration for deploying a secure Google Kubernetes Engine (GKE) cluster on Google Cloud Platform with Vault integration and Kubernetes component orchestration via Ansible.

## 📋 Overview

This repository contains Infrastructure as Code (IaC) for provisioning a complete Kubernetes infrastructure on GCP with:

- **Secure GKE Cluster**: Private cluster with network policies and Workload Identity
- **Networking**: Custom VPC with secondary IP ranges for pods and services
- **Security**: Least-privilege IAM roles and service accounts
- **Container Registry**: Artifact Registry for Docker images
- **State Management**: GCS bucket for Terraform state
- **CI/CD**: Jenkins pipeline for infrastructure deployment
- **Kubernetes Components**: Ansible playbooks for installing ArgoCD, monitoring, and NGINX ingress

## 📁 Project Structure

```
furniro-terraform-with-vault/
├── gke.tf                      # GKE cluster and node pool configuration
├── iam-vpc.tf                  # IAM roles, service accounts, and VPC networking
├── storage.tf                  # GCS state bucket and Artifact Registry
├── provider.tf                 # Terraform provider configuration
├── variable.tf                 # Variable definitions
├── values.tfvars               # Default variable values
├── Jenkinsfile                 # CI/CD pipeline configuration
├── .gitignore                  # Git ignore rules
├── .terraform.lock.hcl         # Terraform dependency lock file
└── ansible/
    └── install_k8s_components.yml  # Kubernetes component installation playbook
```

## 🚀 Quick Start

### Prerequisites

- Terraform >= 1.0
- Google Cloud SDK (`gcloud`)
- kubectl configured
- Ansible (for K8s component installation)
- GCP Project with billing enabled
- Service account with appropriate permissions

### 1. Authentication

Authenticate with GCP:
```bash
gcloud auth application-default login
```

Or use a service account:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
```

### 2. Configure Variables

Edit `values.tfvars` with your environment specifics:
```hcl
region      = "us-central1"
zone        = "us-central1-a"
project     = "your-gcp-project-id"
K8s_version = "1.31.6-gke.1020000"
cluster_name = "gke-cluster"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan Infrastructure

```bash
terraform plan -var-file=values.tfvars
```

### 5. Apply Configuration

```bash
terraform apply -var-file=values.tfvars
```

### 6. Get Cluster Credentials

```bash
gcloud container clusters get-credentials gke-cluster \
  --zone=us-central1-a \
  --project=your-project-id
```

## 📦 Infrastructure Components

### GKE Cluster (`gke.tf`)

- **Cluster Configuration**:
  - Private cluster with public endpoint
  - Network policies enabled
  - Workload Identity for Vault integration
  - Regular release channel
  - Deletion protection enabled

- **Node Pool**:
  - Machine type: `e2-standard-4`
  - Auto-scaling: 1-5 nodes
  - Disk: 100GB SSD (pd-balanced)
  - Image: Ubuntu with containerd

### Networking (`iam-vpc.tf`)

- **VPC**: `prod-vpc` with custom subnets
- **Subnet**: `prod-subnet` (10.10.0.0/16)
- **Secondary IP Ranges**:
  - Pods: 10.20.0.0/16
  - Services: 10.30.0.0/16

### IAM & Service Accounts (`iam-vpc.tf`)

Least-privilege service account for GKE nodes with permissions:
- `roles/logging.logWriter` - Cloud Logging
- `roles/monitoring.metricWriter` - Cloud Monitoring
- `roles/artifactregistry.reader` - Container image pulls

### Storage (`storage.tf`)

- **Artifact Registry**: Docker image repository for container images
- **GCS State Bucket**: Versioned state storage with 1-year retention policy

## 🔧 Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `project` | string | `round-centaur-477210-k3` | GCP Project ID |
| `region` | string | `us-central1` | GCP Region |
| `zone` | string | `us-central1-a` | GCP Zone |
| `K8s_version` | string | `1.31.6-gke.1020000` | Kubernetes version |
| `cluster_name` | string | `prod-gke-cluster` | GKE cluster name |

## 🔐 Security Features

- **Private Cluster**: Nodes have no public IPs
- **Network Policies**: Enabled for pod-to-pod communication control
- **Workload Identity**: Pods can assume GCP service account roles
- **Metadata Protection**: GKE_METADATA mode for node metadata endpoint
- **Least Privilege IAM**: Minimal permissions for service accounts
- **Deletion Protection**: Prevents accidental cluster deletion

## 📝 CI/CD Pipeline (Jenkinsfile)

Automated deployment via Jenkins with parameterized builds:

**Stages**:
1. **Checkout Code**: Pulls from GitHub repository
2. **Terraform Init**: Initializes Terraform backend
3. **Terraform Plan**: Reviews infrastructure changes (apply action)
4. **Terraform Apply**: Provisions infrastructure (apply action)
5. **Terraform Destroy**: Removes all resources (destroy action)

**Parameters**:
- `ACTION`: Choose between `apply` or `destroy`

## 🛠️ Kubernetes Components Installation (Ansible)

The `install_k8s_components.yml` playbook installs:

- **Namespaces**: argocd, monitoring, ingress-nginx
- **NGINX Ingress Controller**: LoadBalancer service with metrics
- **ArgoCD**: GitOps CD tool with Vault-sourced admin password
- **Monitoring Stack**: Grafana with Vault-sourced admin password

**Requirements**:
- Ansible with community.kubernetes and community.hashi_vault plugins
- `KUBECONFIG` environment variable set
- Vault access for secret retrieval

**Run playbook**:
```bash
ansible-playbook ansible/install_k8s_components.yml
```

## 📊 Terraform State Management

State is stored in GCS bucket with:
- **Versioning**: Track all infrastructure changes
- **Encryption**: Automatic encryption at rest
- **Retention**: Auto-delete after 365 days
- **Access Control**: Restricted to project editors

## 🔄 Common Commands

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Check current state
terraform state list

# Destroy specific resource
terraform destroy -target=resource_type.resource_name

# Show detailed plan
terraform plan -var-file=values.tfvars -out=tfplan

# Apply saved plan
terraform apply tfplan
```

## 🚨 Troubleshooting

**Issue**: Terraform init fails with GCS backend error
- **Solution**: Ensure the state bucket exists or let Terraform create it first

**Issue**: GKE cluster creation timeout
- **Solution**: Check GCP quotas and increase if needed

**Issue**: Workload Identity not working
- **Solution**: Verify service account is bound to pod SA in namespace:
  ```bash
  kubectl annotate serviceaccount your-sa \
    iam.gke.io/gcp-service-account=your-gcp-sa@project.iam.gserviceaccount.com
  ```

**Issue**: Ansible playbook fails with Vault errors
- **Solution**: Ensure Vault is accessible and credentials are configured in Ansible

## 📚 Additional Resources

- [Google Kubernetes Engine Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest)
- [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Ansible Kubernetes Module](https://docs.ansible.com/ansible/latest/collections/kubernetes/core/index.html)

## 🔗 Repository

[GitHub: furniro-gke-terraform](https://github.com/ankur-06-2003/furniro-gke-terraform.git)

## 📝 License

This project is part of Furniro infrastructure management.

## ⚠️ Important Notes

- **Deletion Protection**: The cluster has deletion protection enabled. Modify `gke.tf` to disable before destroying.
- **Costs**: Private clusters incur additional costs for private endpoint access.
- **State Sensitivity**: The `terraform.tfstate` file contains sensitive data. Store securely and add to `.gitignore`.
- **GCP Quotas**: Ensure your project has sufficient quota for GKE clusters and resources.

---

**Created**: February 2026  
**Terraform Version**: >= 1.0  
**Google Provider Version**: ~> 6.0
