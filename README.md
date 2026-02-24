# Furniro Deployment

This repository contains Terraform and Kubernetes manifests to provision and deploy the Furniro application onto Google Kubernetes Engine (GKE).

## Overview
- `gke-terraform/`: Terraform code to create the GKE cluster, VPC, IAM, storage, and related cloud resources.
- `k8s-Manifests-file/`: Kubernetes manifests (backend, database, frontend, ingress, vault) and helper scripts.
- `ansible/`: Ansible playbooks for installing cluster components (in `gke-terraform/ansible`).

## Quick start

Prerequisites:
- `gcloud` CLI configured with an active project and proper IAM permissions
- `terraform` (compatible version)
- `kubectl` configured to talk to the GKE cluster
- `ansible` (optional, for cluster setup)

1. Create infrastructure (GKE + cloud resources)

```bash
cd gke-terraform
terraform init
terraform plan -var-file=values.tfvars
terraform apply -var-file=values.tfvars
```

2. Configure `kubectl` for the newly created cluster (example using `gcloud`):

```bash
gcloud container clusters get-credentials <CLUSTER_NAME> --zone <ZONE> --project <PROJECT_ID>
```

3. Deploy Kubernetes manifests

```bash
cd ../k8s-Manifests-file
# Apply namespaces/CRDs first if present, then components
kubectl apply -f backend
kubectl apply -f database
kubectl apply -f frontend
kubectl apply -f ingress
kubectl apply -f vault
```

4. Optional: run Ansible playbook to install cluster components

```bash
cd gke-terraform/ansible
ansible-playbook install_k8s_components.yml -i <inventory>
```

## Important files
- Terraform variables: `gke-terraform/values.tfvars`
- Terraform state: `gke-terraform/terraform.tfstate` (contains sensitive data; secure accordingly)
- Main manifests: `k8s-Manifests-file/backend`, `k8s-Manifests-file/frontend`, `k8s-Manifests-file/database`, `k8s-Manifests-file/ingress`, `k8s-Manifests-file/vault`
- Jenkins pipeline definitions: `gke-terraform/Jenkinsfile` and `k8s-Manifests-file/jenkinsfile`

## Vault
See `k8s-Manifests-file/vault/IMPLEMENTATION_CHECKLIST.md` and `k8s-Manifests-file/vault/setup.sh` for Vault setup notes and scripts.

## Notes & security
- Store Terraform state and sensitive values securely (remote state, IAM-restricted storage).
- Secrets defined in `k8s-Manifests-file/*/secrets.yaml` should be managed with an external secrets manager (Vault, Secrets Manager) in production.

## Troubleshooting
- If `kubectl` cannot connect, ensure kubeconfig is pointed at the correct cluster and credentials are refreshed.
- Review Terraform plan output before applying changes.

## Contact
For questions about the deployment flow, open an issue or contact the repository maintainer.
