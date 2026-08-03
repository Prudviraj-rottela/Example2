# Intentionally vulnerable / policy-breaking base image for demo.
# vs main: alpine:3.19  →  python:3.8-slim (old tag, many known CVEs, not in golden catalog approved tags)
FROM python:3.8-slim

WORKDIR /app

# --- INTENTIONAL BAD PRACTICES (visible in PR diff; Trivy scans the base IMAGE for CVEs) ---
# Hardcoded secrets (should never appear in real Dockerfiles)
ENV AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
ENV AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
ENV DB_PASSWORD=SuperSecretPassw0rd!
ENV OPENAI_API_KEY=sk-proj-demo-malicious-key-do-not-use
ENV JWT_SECRET=insecure-jwt-secret-12345

# Run as root (bad practice — golden policy prefers non-root)
USER root

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
COPY testcase/secrets.env .env

EXPOSE 8000
CMD ["python", "app.py"]
