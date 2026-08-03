# Demo testcase — Image drift + Trivy CVEs (Example2)

## What this branch tests

| Check | What changes vs `main` | Expected agent result |
|-------|------------------------|------------------------|
| Image drift (Dockerfile) | `alpine:3.19` → `python:3.8-slim` | Detected old→new |
| Image drift (K8s) | `python:3.11-slim` → `node:14-alpine` | Detected old→new |
| Trivy CVEs | Scans **new** images from registry | Many CRITICAL/HIGH on old tags |
| Policy | Tags not in golden catalog / CVE limits | **BLOCK** |
| Malicious patterns in files | Hardcoded secrets, privileged K8s | Visible in PR; agent focuses on image drift + Trivy image scan |

**Important:** The agent triggers on a **Pull Request to `main`**, not a direct push to `main`.
Push this branch → open/update PR → webhook runs (needs ngrok) OR use manual `/analyze`.

Trivy scans the **container image names** (`python:3.8-slim`, `node:14-alpine`) for CVEs/secrets/misconfigs in those images — not your local README.

---

## Before demo (start stack)

```bash
# Terminal 1 — API
cd ~/Downloads/Docker_Image_Drift_Agent_v2
source .venv/bin/activate
python main.py serve

# Terminal 2 — ngrok (for GitHub webhook)
ngrok http 8090 --config ~/snap/ngrok/common/ngrok/ngrok.yml
# Copy the https URL, then:
python main.py onboard Prudviraj-rottela/Example2 \
  --webhook-url https://YOUR-NGROK-URL.ngrok-free.dev/webhook

# Terminal 3 — UI (optional)
cd ~/Downloads/Docker_Image_Drift_Agent_v2/frontend && npm run dev
```

```bash
curl http://localhost:8090/health
# must show: "trivy":"available"
```

---

## Test A — Webhook (real GitHub trigger)

```bash
cd ~/Downloads/Docker_Image_Drift_Agent_v2/Example2
git checkout test/demo-vulnerable-drift
git push -u origin test/demo-vulnerable-drift
```

Open / refresh PR: `test/demo-vulnerable-drift` → `main`  
Or create PR:

```bash
# if PR does not exist yet (needs gh + token)
gh pr create --repo Prudviraj-rottela/Example2 \
  --base main --head test/demo-vulnerable-drift \
  --title "DEMO: vulnerable image drift + secrets" \
  --body "Intentional CVE-heavy images and bad secrets for drift agent demo."
```

To re-trigger after PR is open (must change a tracked image file or any file):

```bash
cd ~/Downloads/Docker_Image_Drift_Agent_v2/Example2
git checkout test/demo-vulnerable-drift
echo "# demo $(date +%s)" >> README.md
git add README.md && git commit -m "chore: re-trigger agent" && git push
```

---

## Test B — Manual analyze (no ngrok needed)

```bash
# Replace PR number if different
curl -X POST http://localhost:8090/analyze \
  -H "Content-Type: application/json" \
  -d '{"repo_full_name":"Prudviraj-rottela/Example2","pr_number":2,"post_to_github":true}'
```

Check: JSON `decision` (expect `block`), `old_image`/`new_image`, `trivy.critical_count` / `high_count`, GitHub PR comment + status.

---

## What to show the team

1. PR file diff: Dockerfile + k8s image change + secrets  
2. Agent report: image drift lines + Trivy CVE table  
3. GitHub commit status `docker-image-drift-agent` = failure → merge blocked  
4. UI at http://localhost:3000 → Example2 → download PDF  

---

## Reset branch to safe main images (optional)

```bash
git checkout main -- Dockerfile k8s/deployment.yaml
```
