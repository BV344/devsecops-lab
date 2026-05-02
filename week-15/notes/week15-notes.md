# Week 15 Notes — Kubernetes (K8s)

## What is Kubernetes and Why Does it Exist?
Kubernetes (K8s) is a container orchestration platform. When you 
have many containers running across many servers, manually managing 
them becomes impossible — who restarts a crashed container? Who 
moves containers when a server dies? Who scales up when traffic spikes?

Kubernetes solves this by:
- Automatically restarting crashed containers
- Distributing containers across multiple servers
- Scaling up and down based on load
- Managing networking between containers
- Handling rolling updates with zero downtime

## Core Concepts

### Pods
The smallest unit in Kubernetes. A pod wraps one or more containers 
and is managed by Kubernetes. Think of it like a Docker container 
but with Kubernetes handling its lifecycle — starting, stopping, 
restarting, and scheduling it onto nodes.

### Deployments
A Deployment declares the desired state of your pods:
- Which image to run
- How many replicas to maintain
- Resource limits per container
- Update strategy

Kubernetes continuously reconciles reality with your declaration. 
If you say `replicas: 2` and one pod dies, Kubernetes immediately 
creates a new one.

### Services
Pods have random IPs that change every time they restart. A Service 
provides a stable network endpoint that always routes to healthy pods. 
It uses **labels and selectors** to find the right pods automatically.

## Labels and Selectors — How Everything Connects
This is the key to how Kubernetes components communicate without 
hardcoding names or IPs.

The Deployment labels every pod it creates:
```yaml
labels:
  app: my-webserver
```

The Service selects pods using that label:
```yaml
selector:
  app: my-webserver
```

When a pod dies and a new one appears with the same label, the 
Service instantly routes to it. No manual update needed. Think of 
it like a name tag system — the Service routes to whoever is wearing 
the right name tag.

## Self-Healing — Desired State Reconciliation
Kubernetes constantly watches the cluster and compares the actual 
state to the desired state declared in your Deployment.

Demonstrated this week:
- Deployment says `replicas: 2`
- Deleted a pod manually
- Kubernetes detected 1 pod running (actual) vs 2 desired
- New pod appeared within 1 second automatically
- Deleted again → new pod appeared in 2 seconds

This is called **desired state reconciliation** — the core concept 
behind Kubernetes.

## Resource Limits in Kubernetes
Similar to Docker's `--memory` and `--cpus` flags but defined in YAML:

```yaml
resources:
  limits:
    memory: "128Mi"   # hard cap
    cpu: "500m"       # 500 millicores = 0.5 CPU
  requests:
    memory: "64Mi"    # reserved for scheduling
    cpu: "250m"       # minimum guaranteed
```

- **limits** — maximum the container can consume
- **requests** — what Kubernetes reserves when placing the pod on a node

## Service Types

| Type | Use case |
|---|---|
| NodePort | Development/testing — exposes a random port on the node |
| ClusterIP | Internal only — pods talk to each other inside the cluster |
| LoadBalancer | Production — gets a real public IP from the cloud provider |

NodePort assigned port `30372` randomly — fine for learning, 
not for production.

## Minikube
Minikube runs a full Kubernetes cluster locally by creating a Docker 
container on your machine that acts as a Kubernetes node. It gets 
its own private Docker network IP (`192.168.49.2`) separate from 
your desktop's real IP (`10.0.0.15`).

1. Ubuntu Desktop(10.X.X.X)
2. Docker Network(192.168.49.X)
3. Minikube Node(192.168.49.2)
5. Pods Running Inside

In production you'd use a managed Kubernetes service like 
AWS EKS, Google GKE, or Azure AKS instead of Minikube.

## Key Commands
```bash
minikube start --driver=docker    # Start local cluster
kubectl get nodes                  # List cluster nodes
kubectl get pods                   # List running pods
kubectl get services               # List services
kubectl apply -f file.yml          # Deploy from YAML file
kubectl delete pod <name>          # Delete a pod
kubectl describe pod <name>        # Detailed pod info
kubectl logs <pod-name>            # View pod logs
minikube service <name> --url      # Get service URL
```
