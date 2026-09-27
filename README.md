# [Project Name]

> Replace this whole README with your own — keep the section headings below,
> since a missing/placeholder README costs you points under the "Artifacts
> completeness" evaluation category (see the FAQ in the help repo for what's
> being scored, at a high level).

## Table of Contents
- [Problem](#problem)
- [Solution](#solution)
- [Architecture](#architecture)
- [How to run](#how-to-run)
- [Tech stack](#tech-stack)
- [Security](#security)
- [Team](#team)

## Problem
Which problem statement are you attempting, and what's the specific gap you're closing?
(Copy the exact problem-statement title from the kickoff announcement.)

## Solution
What does your solution do? Who is it for? What's the core user flow?

## Architecture
See [`artifacts/arch/`](artifacts/arch/) for the diagram. Summarize the key
components and data flow here in 3-5 sentences.

## How to run
```bash
# Clone
git clone <this-repo-url>
cd <this-repo>

# Build & run (Docker is the expected path — see code/Dockerfile)
docker build -t my-submission .
docker run --env-file .env -p 8080:8080 my-submission

# Or run tests locally
cd code
pip install -r requirements.txt   # or: npm install / mvn install / go build ...
pytest                            # or your stack's test runner
```

## Tech stack
- **Frontend:**
- **Backend:**
- **Database:**
- **Other (LLM/GenAI APIs, infra, etc.):**

## Security
Briefly describe: where secrets/config come from (should be `.env`, never
committed — see `.env.example`), whether/how you handle any PII in your
data, and anything else a reviewer should know.

## Team
- [Your Name](https://github.com/<you>)

---
### Submission checklist (delete before submitting)
- [ ] Deleted all `Delete this file` placeholder READMEs under `code/src`, `code/test`, `artifacts/arch`, `artifacts/demo`
- [ ] Filled in `submission.yaml` with your chosen problem-statement prefix
- [ ] Added a real architecture diagram to `artifacts/arch/`
- [ ] Added a demo link to `artifacts/demo/DEMO.md` (YouTube unlisted / Drive / Loom — see the FAQ)
- [ ] `Dockerfile` builds and the app responds on its exposed port
- [ ] Tests exist under `code/test` and pass
- [ ] `.env.example` lists every required environment variable (no real secrets)
- [ ] No committed secrets, API keys, or real personal data anywhere in the repo
