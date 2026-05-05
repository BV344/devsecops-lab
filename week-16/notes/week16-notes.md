# Week 16 Notes — Kubernetes Security

## RBAC (Role Based Access Control)
RBAC controls who can do what inside a Kubernetes cluster. 
Same concept as AWS IAM from Week 13 but applied to Kubernetes 
resources instead of AWS services.

Without RBAC anyone with kubectl access can do anything — 
delete pods, read secrets, modify deployments. RBAC locks this down.

## Roles vs RoleBindings

**Role** — defines what actions are allowed on which resources:
```yaml
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
```

**RoleBinding** — attaches a Role to a user, group, or service account:
```yaml
subjects:
- kind: User
  name: developer
roleRef:
  kind: Role
  name: developer-readonly
```

Think of it exactly like AWS IAM:
- Role = IAM Policy (defines permissions)
- RoleBinding = IAM Group membership (attaches policy to identity)

## Verbs — What Users Can Do

| Verb | Action |
|---|---|
| `get` | Read a specific resource by name |
| `list` | List all resources of a type |
| `watch` | Stream real-time updates |
| `create` | Create new resources |
| `update` | Modify existing resources |
| `delete` | Remove resources |
| `patch` | Partially modify resources |

Our `developer-readonly` role only has `get`, `list`, `watch` — 
read only, cannot create or destroy anything.

## Security Contexts
Security contexts define security settings for pods and containers 
in Kubernetes — the equivalent of Docker's `--user` and security flags.

**Pod-level security context:**
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 100
  runAsGroup: 102
```

**Container-level security context:**
```yaml
securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  capabilities:
    drop:
    - ALL
```

## runAsNonRoot
Tells Kubernetes to verify the container is not running as root 
before starting it. Kubernetes checks the numeric UID — root is 
always UID 0, so any other UID passes the check.

**Important:** Kubernetes requires a **numeric UID** — it cannot 
verify named users like `appuser`. Use `runAsUser: 100` not 
`runAsUser: appuser`.

## allowPrivilegeEscalation: false
Prevents the container process from gaining more privileges than 
it started with — even if a vulnerability is exploited. Stops 
attacks that try to escalate from a low-privilege user to root 
inside the container.

## capabilities: drop: ALL
Linux capabilities are fine-grained root permissions. Dropping ALL 
removes every special privilege from the container — it can't open 
raw network sockets, can't modify kernel settings, can't access 
hardware directly. Dramatically reduces what an attacker can do 
even if they compromise the container.

## Debugging the UID Issue
When `runAsNonRoot: true` was set with a named user (`appuser`) 
Kubernetes threw:

"image has non-numeric user (appuser), cannot verify user is non-root"

Fix — find the numeric UID the image actually uses:
```bash
docker run --rm bv344/my-webserver:v3 id
# uid=100(appuser) gid=102(appgroup)
```

Then use the numeric UID in the security context:
```yaml
runAsUser: 100
runAsGroup: 102
```

Key lesson: always check actual UIDs with `docker run id` 
before writing security contexts. Syntax errors and incorrect 
values are the most common Kubernetes debugging issues.

## Key Commands
```bash
kubectl get roles                    # List roles
kubectl get rolebindings             # List role bindings
kubectl describe pod <name>          # Detailed pod info including events
kubectl logs <pod-name>              # View pod logs
kubectl delete pod <name>            # Delete a pod
docker run --rm <image> id           # Check UID inside an image
```
