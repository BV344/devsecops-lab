# Week 7 Notes — CI/CD Pipelines with GitHub Actions

## What is CI/CD?
CI/CD stands for Continuous Integration and Continuous Deployment.
Instead of manually building, scanning, and pushing code, a pipeline 
automatically runs a series of steps every time you push to GitHub.

- **CI (Continuous Integration)** — automatically build and test code 
  on every push
- **CD (Continuous Deployment)** — automatically deploy when all 
  checks pass

The goal is to eliminate manual steps, catch issues early, and ship 
code faster and more safely.

## GitHub Actions
GitHub Actions is GitHub's built-in CI/CD platform. You define your 
pipeline in a YAML file stored at `.github/workflows/` in your repo. 
Every time you push code that matches the trigger conditions, GitHub 
spins up a fresh virtual machine in the cloud and runs your workflow 
automatically — no servers to manage.

## Our Workflow — `docker-build-scan.yml`
The workflow triggers on every push to `main` that touches files in 
`week-03/docker-projects/my-webserver/`.

**Step 1 — Checkout code**
Clones your GitHub repo onto the fresh GitHub Actions VM. Without this 
step nothing else works — the VM starts completely empty.

**Step 2 — Login to Docker Hub**
Authenticates to Docker Hub using credentials stored in GitHub Secrets. 
Never hardcoded in the YAML file.

**Step 3 — Build Docker image**
Runs `docker build` on your Dockerfile to create the image, exactly 
like you would manually.

**Step 4 — Scan with Trivy**
Scans the built image for CRITICAL and HIGH vulnerabilities. 
Behavior depends on exit-code configuration.

**Step 5 — Push to Docker Hub**
If all previous steps pass, pushes the image to Docker Hub automatically.

## exit-code — The Security Gate

| Setting | Behavior |
|---|---|
| `exit-code: '0'` | Scan and report — pipeline continues regardless of findings |
| `exit-code: '1'` | Scan and block — pipeline fails if CRITICAL or HIGH found, image never pushed |

In production you'd use `exit-code: '1'` to prevent vulnerable images 
from ever reaching deployment. We used `exit-code: '0'` because 
nginx:alpine still has some HIGH findings without available fixes.

## GitHub Secrets
Credentials like Docker Hub username and password must NEVER be 
hardcoded in a YAML file that gets committed to Git. Anyone who 
can see the repo can see the file.

Instead store them as GitHub Secrets:
- Go to repo Settings → Secrets and variables → Actions
- Reference them in the workflow as `${{ secrets.SECRET_NAME }}`
- GitHub injects them at runtime — they never appear in logs or code

## Full Pipeline Flow
1. git push
2. GitHub Actions triggers
3. Fresh VM spins up
4. Code cloned
5. Login to DockerHub
6. Build image
7. Trivy Scan
8. Pass? Push to DockerHub : Fail? Stop pipeline

## Result
Our pipeline completed in **43 seconds** — automatically building, 
scanning, and pushing `bv344/my-webserver:latest` to Docker Hub 
with zero manual steps.
