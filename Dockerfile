# HACKATHON-PLACEHOLDER: replace this whole file with your own Dockerfile.
#
# We build, test and run every repo automatically from a fresh clone, without internet access, before the
# judges review the finalists. While this placeholder is here, your repo counts as having no Dockerfile.
#
# Your Dockerfile must:
#   1. Start with FROM and a base image for your language (e.g. python:3.12-slim, node:20-slim,
#      eclipse-temurin:21).
#   2. COPY only files that are committed to this repo (e.g. code/requirements.txt, code/package.json and
#      code/package-lock.json). A file that exists only on your laptop breaks the build.
#   3. Install your test tool inside the image (e.g. pytest in requirements.txt, jest in devDependencies):
#      we run your tests inside the image, with no internet.
#   4. EXPOSE the port your app listens on, and start the app on 0.0.0.0 (not 127.0.0.1 or localhost).
#   5. Start with only the example values in .env.example (never put real secrets in the image).
# Good practice we look at: run as a non-root USER, add a HEALTHCHECK (e.g. a GET /health route), keep the
# image small, keep a .dockerignore.
#
# Keep the file here at the repo root (or in code/). Check it any time:
# Actions tab -> Submission self-check -> Run workflow.
