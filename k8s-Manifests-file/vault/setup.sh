#!/bin/bash
set -e

echo "=== HCP Vault + Kubernetes Setup (Fixed) ==="

# Required ENV
: "${VAULT_ADDR:?Need VAULT_ADDR}"
: "${VAULT_TOKEN:?Need VAULT_TOKEN}"
# Ensure this is the PUBLIC endpoint if using HCP Vault without peering
# e.g., https://<cluster>.public.vault.aws.corp.mongodb.com:8200

NAMESPACE="three-tier"
export VAULT_ADDR
export VAULT_TOKEN

echo "1. Enable Kubernetes auth"
vault auth enable kubernetes 2>/dev/null || echo "Auth already enabled"

echo "2. Create Long-Lived Token Reviewer"
# We create a ServiceAccount and a manual Secret to get a non-expiring token
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
  namespace: kube-system
---
apiVersion: v1
kind: Secret
metadata:
  name: vault-auth-token
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: vault-auth
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vault-auth-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
  - kind: ServiceAccount
    name: vault-auth
    namespace: kube-system
EOF

# Wait for the token controller to populate the secret
echo "Waiting for token generation..."
sleep 2

echo "3. Fetch Auth Config"
# Extract the long-lived token from the Secret
TOKEN_REVIEWER_JWT=$(kubectl get secret vault-auth-token -n kube-system -o jsonpath='{.data.token}' | base64 --decode)
KUBERNETES_CA_CERT=$(kubectl get secret vault-auth-token -n kube-system -o jsonpath='{.data.ca\.crt}' | base64 --decode)

# Get the Public URL of the cluster
# WARNING: Ensure this URL is reachable from the internet (HCP)
KUBERNETES_HOST=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
echo "K8s Host: $KUBERNETES_HOST"

echo "4. Configure Vault Kubernetes Auth"
vault write auth/kubernetes/config \
  token_reviewer_jwt="$TOKEN_REVIEWER_JWT" \
  kubernetes_host="$KUBERNETES_HOST" \
  kubernetes_ca_cert="$KUBERNETES_CA_CERT" \
  disable_iss_validation=true

echo "5. Write Policies"
# Assumes files exist in current directory
if [ -f "frontend-policy.hcl" ] && [ -f "backend-policy.hcl" ]; then
    vault policy write frontend-policy frontend-policy.hcl
    vault policy write backend-policy backend-policy.hcl
else
    echo "⚠️ Policy files not found, skipping..."
fi

echo "6. Create Roles"
vault write auth/kubernetes/role/frontend-role \
  bound_service_account_names=frontend-sa \
  bound_service_account_namespaces=$NAMESPACE \
  policies=frontend-policy \
  ttl=24h

vault write auth/kubernetes/role/backend-role \
  bound_service_account_names=backend-sa \
  bound_service_account_namespaces=$NAMESPACE \
  policies=backend-policy \
  ttl=24h

echo "✅ Vault + Kubernetes Integration Completed"