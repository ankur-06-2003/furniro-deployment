# HCP Vault Integration - Implementation Checklist

Use this checklist to ensure all steps are completed correctly.

## Phase 1: Prerequisites ✓

- [ ] HCP Vault cluster is running and accessible
- [ ] Have HCP Vault admin access (or sufficient permissions)
- [ ] Have Kubernetes cluster admin access
- [ ] kubectl is installed and configured
- [ ] Vault CLI is installed (`vault version` works)
- [ ] Helm is installed and configured
- [ ] Know your Vault cluster address (e.g., `https://your-cluster.hcp.vault.cloud:8200`)

## Phase 2: Install Vault Agent Injector ✓

- [ ] Add HashiCorp Helm repository
  ```bash
  helm repo add hashicorp https://helm.releases.hashicorp.com
  helm repo update
  ```

- [ ] Install Vault Agent Injector
  ```bash
  helm install vault hashicorp/vault \
    --set injector.enabled=true \
    --set server.enabled=false \
    --set injector.externalVaultAddr="https://YOUR_VAULT_ADDR:8200" \
    --namespace vault \
    --create-namespace
  ```

- [ ] Verify installation
  ```bash
  kubectl get pods -n vault
  kubectl logs -n vault -l app.kubernetes.io/name=vault-agent-injector
  ```

## Phase 3: Authenticate to Vault ✓

- [ ] Set Vault address environment variable
  ```bash
  export VAULT_ADDR="https://your-vault-cluster.hcp.vault.cloud:8200"
  ```

- [ ] Authenticate to Vault
  ```bash
  vault login -method=oidc
  ```

- [ ] Verify authentication
  ```bash
  vault auth list
  vault status
  ```

## Phase 4: Configure Kubernetes Authentication ✓

- [ ] Run automated setup script (RECOMMENDED)
  ```bash
  bash vault/setup.sh
  ```

  OR manually complete these steps:

- [ ] Enable Kubernetes auth method
  ```bash
  vault auth enable kubernetes
  ```

- [ ] Get Kubernetes cluster information
  ```bash
  kubectl cluster-info
  ```

- [ ] Configure Kubernetes auth in Vault
  ```bash
  # Get cluster info and configure
  # See vault/SETUP_GUIDE.md for detailed commands
  ```

- [ ] Verify auth method
  ```bash
  vault read auth/kubernetes/config
  ```

## Phase 5: Create Vault Policies ✓

- [ ] Create frontend policy
  ```bash
  vault policy write frontend-policy - <<'EOF'
  path "secret/data/furniro/frontend/*" {
    capabilities = ["read", "list"]
  }
  EOF
  ```

- [ ] Create backend policy
  ```bash
  vault policy write backend-policy - <<'EOF'
  path "secret/data/furniro/backend/*" {
    capabilities = ["read", "list"]
  }
  path "secret/data/furniro/database/*" {
    capabilities = ["read", "list"]
  }
  EOF
  ```

- [ ] Verify policies
  ```bash
  vault policy list
  vault policy read frontend-policy
  vault policy read backend-policy
  ```

## Phase 6: Create Vault Roles ✓

- [ ] Create frontend role
  ```bash
  vault write auth/kubernetes/role/frontend-role \
    bound_service_account_names=frontend-sa \
    bound_service_account_namespaces=three-tier \
    policies=frontend-policy \
    ttl=24h
  ```

- [ ] Create backend role
  ```bash
  vault write auth/kubernetes/role/backend-role \
    bound_service_account_names=backend-sa \
    bound_service_account_namespaces=three-tier \
    policies=backend-policy \
    ttl=24h
  ```

- [ ] Verify roles
  ```bash
  vault read auth/kubernetes/role/frontend-role
  vault read auth/kubernetes/role/backend-role
  ```

## Phase 7: Create Secrets in Vault ✓

- [ ] Create frontend configuration secrets
  ```bash
  vault kv put secret/furniro/frontend/config \
    NEXT_PUBLIC_API_URL="https://furniro.example.com/api" \
    NEXT_PUBLIC_BASE_URL="https://furniro.example.com"
  ```

- [ ] Create backend secrets
  ```bash
  vault kv put secret/furniro/backend/secrets \
    JWT_SECRET="your-jwt-secret-here" \
    CLOUDINARY_CLOUD_NAME="your-cloud-name" \
    CLOUDINARY_API_KEY="your-api-key" \
    MONGO_USERNAME="furniro_admin" \
    MONGO_PASSWORD="your-db-password"
  ```

- [ ] (Optional) Create database secrets
  ```bash
  vault kv put secret/furniro/database/credentials \
    USERNAME="furniro_admin" \
    PASSWORD="your-db-password"
  ```

- [ ] Verify secrets
  ```bash
  vault kv list secret/furniro/
  vault kv get secret/furniro/backend/secrets
  vault kv get secret/furniro/frontend/config
  ```

## Phase 8: Apply Kubernetes Manifests ✓

- [ ] Apply auth configuration
  ```bash
  kubectl apply -f vault/auth-config.yaml
  ```

- [ ] Verify service accounts
  ```bash
  kubectl get sa -n three-tier
  ```

- [ ] Apply backend deployment
  ```bash
  kubectl apply -f backend/deployment.yaml
  ```

- [ ] Apply frontend deployment
  ```bash
  kubectl apply -f frontend/deployment.yaml
  ```

- [ ] Apply database manifests
  ```bash
  kubectl apply -f database/
  ```

- [ ] Apply ingress
  ```bash
  kubectl apply -f ingress/
  ```

## Phase 9: Verification ✓

- [ ] Check pods are running
  ```bash
  kubectl get pods -n three-tier
  kubectl get pods -n vault
  ```

- [ ] Check pod status details
  ```bash
  kubectl describe pod <pod-name> -n three-tier
  ```

- [ ] Check Vault Agent init logs
  ```bash
  kubectl logs <pod-name> -n three-tier -c vault-agent-init
  ```

- [ ] Check Vault Agent running logs
  ```bash
  kubectl logs <pod-name> -n three-tier -c vault-agent
  ```

- [ ] Verify Vault Agent Injector controller logs
  ```bash
  kubectl logs -n vault -l app.kubernetes.io/name=vault-agent-injector -f
  ```

- [ ] Verify secrets are injected
  ```bash
  kubectl exec -it <pod-name> -n three-tier -- ls -la /vault/secrets/
  kubectl exec -it <pod-name> -n three-tier -- cat /vault/secrets/app-secrets
  ```

- [ ] Test application connectivity
  ```bash
  kubectl port-forward svc/frontend 3000:80 -n three-tier
  kubectl port-forward svc/api 8000:8000 -n three-tier
  ```

## Phase 10: Production Migration ✓

- [ ] Backup old Kubernetes secrets
  ```bash
  kubectl get secret mongo-sec -n three-tier -o yaml > backup-mongo-sec.yaml
  kubectl get secret app-secrets -n three-tier -o yaml > backup-app-secrets.yaml
  ```

- [ ] Test application functionality
  - [ ] Test frontend (check env variables work)
  - [ ] Test backend (verify API calls work)
  - [ ] Test database connectivity

- [ ] Enable Vault audit logging
  ```bash
  vault audit enable file file_path=/vault/logs/audit.log
  ```

- [ ] Delete old Kubernetes secrets
  ```bash
  kubectl delete secret mongo-sec app-secrets -n three-tier
  ```

- [ ] Document secrets location
  - [ ] Create runbook for secret rotation
  - [ ] Document Vault backup procedure
  - [ ] Add emergency access procedure to docs

## Phase 11: Post-Deployment ✓

- [ ] Set up alert monitoring
  - [ ] Monitor Vault cluster health
  - [ ] Set up alerts for failed authentications
  - [ ] Monitor secret access patterns

- [ ] Configure backup/recovery
  ```bash
  # Set up Vault backup procedure
  # Test recovery procedure
  ```

- [ ] Update documentation
  - [ ] Document secret rotation procedure
  - [ ] Document emergency access process
  - [ ] Update team runbooks

- [ ] Train team members
  - [ ] Share Vault documentation
  - [ ] Demonstrate secret rotation
  - [ ] Review security best practices

## Phase 12: Ongoing Maintenance ✓

### Daily
- [ ] Monitor pod logs for errors
- [ ] Check Vault health status
  ```bash
  vault status
  ```

### Weekly
- [ ] Review Vault audit logs
  ```bash
  vault audit list
  ```
- [ ] Check for failed authentications

### Monthly
- [ ] Rotate JwtSecrets if using time-based rotation
- [ ] Review access policies
- [ ] Test disaster recovery procedure

### Quarterly
- [ ] Review and update Vault policies
- [ ] Audit who has admin access
- [ ] Review Vault version updates

## Troubleshooting Checklist

If something isn't working:

- [ ] Verify HCP Vault is accessible
  ```bash
  curl -k https://your-vault-addr:8200/v1/sys/health
  ```

- [ ] Check Kubernetes cluster connectivity
  ```bash
  kubectl version
  kubectl cluster-info
  ```

- [ ] Verify Vault Agent Injector is running
  ```bash
  kubectl get deployment vault-agent-injector -n vault
  ```

- [ ] Check pod annotations
  ```bash
  kubectl get pod <pod-name> -n three-tier -o json | jq .metadata.annotations
  ```

- [ ] Review Vault Agent logs
  ```bash
  kubectl logs <pod-name> -n three-tier -c vault-agent
  ```

- [ ] Verify Kubernetes auth configuration
  ```bash
  vault read auth/kubernetes/config
  vault list auth/kubernetes/role
  ```

- [ ] Verify policies exist and are correct
  ```bash
  vault policy list
  vault policy read frontend-policy
  vault policy read backend-policy
  ```

- [ ] Verify secrets exist
  ```bash
  vault kv list secret/furniro/
  vault kv get secret/furniro/frontend/config
  vault kv get secret/furniro/backend/secrets
  ```

- [ ] Check pod events for errors
  ```bash
  kubectl describe pod <pod-name> -n three-tier
  ```

- [ ] Review Vault API access logs
  ```bash
  vault audit list
  ```

## Success Criteria ✓

Your deployment is successful when:

- [ ] All pods in `three-tier` namespace are in `Running` state
- [ ] No pods showing `CreateContainerConfigError` or `Init:Error`
- [ ] `kubectl exec <pod> -- cat /vault/secrets/app-secrets` shows injected secrets
- [ ] Application logs show successful authentication
- [ ] No errors in Vault Agent logs
- [ ] Vault shows successful K8s auth attempts in audit logs
- [ ] Applications can access their required configuration
- [ ] Database connectivity works
- [ ] Ingress routing works

## Rollback Plan

If you need to revert to Kubernetes Secrets:

- [ ] Restore backed-up secrets
  ```bash
  kubectl apply -f backup-mongo-sec.yaml
  kubectl apply -f backup-app-secrets.yaml
  ```

- [ ] Revert deployment manifests (remove Vault annotations)
- [ ] Add back `secretKeyRef` to environment variables
- [ ] Apply reverted manifests
- [ ] Verify pods restart and work

## Additional Resources

- **This Quick Reference**: `VAULT_QUICKREF.md`
- **Setup Guide**: `vault/SETUP_GUIDE.md`
- **Migration Guide**: `vault/MIGRATION_GUIDE.md`
- **Entrypoint Examples**: `vault/ENTRYPOINT_EXAMPLES.md`
- **Main README**: `README.md`

---

**Last Updated**: 2026-02-24  
**Status**: ✓ Ready for Production
