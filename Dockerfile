# Starter Dockerfile — replace the base image / steps for your stack.
# Two things the evaluator checks for automatically: a non-root USER, and a
# HEALTHCHECK (or a /health endpoint your app serves on its exposed port).
FROM python:3.12-slim
WORKDIR /app

COPY code/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY code/ .

RUN useradd -m appuser
USER appuser

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost:8080/health || exit 1

CMD ["python", "src/main.py"]
