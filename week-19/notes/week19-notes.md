# Week 19 Notes — DevSecOps Pipeline Security

## What is Supply Chain Security?
Supply chain security means securing everything that goes INTO 
your software — not just the code you write, but the dependencies, 
base images, build tools, and CI/CD pipeline itself.

The 2021 SolarWinds attack compromised a build pipeline to inject 
malware into software used by thousands of companies. This made 
supply chain security one of the top priorities in DevSecOps.

Key threats:
- Accidentally committed secrets in Git history
- Vulnerable dependencies or base images
- Compromised third-party actions in CI/CD pipelines
- Malicious packages in public registries

## Gitleaks — Secret Scanning
Gitleaks scans your entire Git repository — including all commit 
history — for accidentally committed secrets like API keys, 
passwords, tokens, and private keys.

```bash
gitleaks detect --source . -v
```

### False Positives
Gitleaks uses pattern matching and entropy analysis. Sometimes it 
flags things that look like secrets but aren't — like example 
credentials in documentation or notes files.

Our false positive: `db_password="secret123"` in week-10 notes 
was flagged by the `hashicorp-tf-password` rule even though it 
was just a learning example.

Fix options:
- Change placeholder values to `YOUR_PASSWORD_HERE`
- Add a `.gitleaks.toml` allowlist for known safe files

## Adding Gitleaks to the Pipeline
Added as a separate job in `.github/workflows/docker-build-scan.yml`:

```yaml
secret-scan:
  runs-on: ubuntu-latest
  steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Scan full git history
    - name: Run Gitleaks
      uses: gitleaks/gitleaks-action@v2
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

`fetch-depth: 0` is critical — without it only the latest commit 
is checked, missing secrets buried in older commits.

## The `needs:` Keyword
Creates a dependency between jobs. The `build-scan-push` job 
won't start until `secret-scan` completes successfully:

```yaml
build-scan-push:
  needs: secret-scan
```

If `secret-scan` fails the entire pipeline stops — the image 
never gets built or pushed. This is a hard security gate.

## What Happened When Trivy Found a HIGH Vulnerability
Trivy found `CVE-2026-27135` in `nghttp2-libs` (HIGH severity) 
in our `nginx:alpine` base image. Because `exit-code: '1'` was 
set, the pipeline failed and the image was **never pushed to 
Docker Hub**.

This is exactly correct behavior — a vulnerable image should 
never reach production.

The fix wasn't available in Alpine yet so we documented it as 
an accepted risk using a `.trivyignore` file.

## .trivyignore
Works similarly to `.gitignore` — tells Trivy to skip specific 
CVEs that have been reviewed and accepted as known risks:

### nghttp2 fix not yet available in Alpine 3.23 - accepted risk
#### CVE-2026-27135

This is the professional approach — you're not blindly disabling 
security scanning. You're explicitly documenting that a specific 
CVE has been reviewed, the fix isn't available yet, and the risk 
has been accepted. Every ignored CVE should have a comment 
explaining why.

## Full Pipeline Security Flow
1. git push
2. secret-scan(gitleaks)
3. Secrets found? X Pipeline Stops
3. No Secrets? Continue :)
4. build-scan-push
5. Build Docker Image (--pull for latest base)
6. Trivy Scan (HIGH/CRITICAL with exit-code:1)
7. Vulnerabilities found? X Pipeline Stops
7. Clean? Continue :)
8. Push to Docker Hub

## Pipeline Run History This Week
- Run #3 ❌ — YAML syntax error (indentation)
- Run #4 ❌ — Trivy blocked HIGH vulnerability
- Run #5 ❌ — Trivy still blocked (fix not in Alpine yet)
- Run #6 ✅ — trivyignore added, pipeline passed

Runs #3, #4, #5 never pushed to Docker Hub — the security 
gates worked exactly as designed.
