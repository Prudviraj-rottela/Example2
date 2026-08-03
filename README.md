# Example2

Demo / test repo for the Docker & Kubernetes Image Drift Controller Agent.

## Branches

| Branch | Purpose |
|--------|---------|
| `main` | Baseline: `alpine:3.19` + `python:3.11-slim` |
| `test/image-drift-api` | Mild drift: alpine 3.20 + python 3.12-slim |
| `test/demo-vulnerable-drift` | **Team demo:** old CVE-heavy images + secrets / privileged K8s |

See [TESTCASE.md](./TESTCASE.md) for full demo commands.
# trigger 1785777217
