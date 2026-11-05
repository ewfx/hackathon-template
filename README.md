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
Your team's use case is in [`USE_CASE.md`](USE_CASE.md) (assigned by the organisers).
What's the specific gap you're closing, and for whom?

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

# Build & run (Docker is the expected path: replace the placeholder Dockerfile at the repo root with your own)
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
Team name and members are in `submission.yaml`. Add each member's role here:
- [Member name](https://github.com/<username>): role

---
### Must-have files (delete this section before submitting)
We build, test and run every repo automatically from a fresh clone, without internet access, before the judges
review the finalists. A repo that builds and runs gets credit for those checks. If it doesn't build in our sandbox,
you don't lose points for it: those checks just aren't scored, and organisers look at it by hand. A repo with **no
Dockerfile** (or still the placeholder) can't earn them at all.

Use the **Submission self-check** to make sure yours works: **Actions → Submission self-check → Run workflow**, then
open the run's Summary (or run `bash .github/scripts/self-check.sh` if you have Docker). It's advisory and doesn't
affect your score. Run it after big changes and once more before the freeze.

| File | Why it matters |
|---|---|
| Your own `Dockerfile` at the repo root (or in `code/`) | We build and start your app from it. The `Dockerfile` in the template is a **placeholder** with the rules in it: replace the whole file |
| Every file your Dockerfile copies, e.g. `code/requirements.txt` / `package.json` / `pom.xml` / `go.mod` | A missing one fails the build: in our dry run, 2 of 10 builds failed on a missing `code/requirements.txt` |
| Your test tool **inside the image**: `pytest` in `requirements.txt` / `jest` in `devDependencies` | We run your tests inside your own image; without the test tool they can't run at all |
| An app that listens on `0.0.0.0` on the port your Dockerfile `EXPOSE`s, ideally with a `GET /health` route | We start the container and check it answers; `127.0.0.1`/`localhost` can't be reached from outside the container |
| Tests under `code/test/` that pass **without internet** | Tests run with no network: mock LLM and other external API calls |
| `README.md` (your own, all sections), `artifacts/arch/` diagram, `artifacts/demo/DEMO.md` link | Scored as artifacts |
| `.env.example` (names only, no real values) and `submission.yaml` as we filled it in | Needed to start the app; identifies your team |

Or check it by hand from a fresh clone:
```bash
git clone <this-repo-url> check && cd check
docker build -t check .
docker run --rm --network=none check python -m pytest   # or: npm test / mvn -o test
```

### Submission checklist (delete before submitting)
- [ ] Deleted all `Delete this file` placeholder READMEs under `code/src`, `code/test`, `artifacts/arch`, `artifacts/demo`
- [ ] Left `submission.yaml` as the organisers filled it in (team and use case come from the roster)
- [ ] Added a real architecture diagram to `artifacts/arch/`
- [ ] Added a demo link to `artifacts/demo/DEMO.md` **before the 07:00 hard freeze** (unlisted YouTube / Loom)
- [ ] Replaced the placeholder `Dockerfile` with your own; it builds **from a fresh clone** (every file it copies is committed) and the app responds on its exposed port
- [ ] Tests exist under `code/test`, the test tool is installed in the image, and they pass with no internet
- [ ] `.env.example` lists every required environment variable (no real secrets)
- [ ] No committed secrets, API keys, or real personal data anywhere in the repo
- [ ] Ran **Actions → Submission self-check → Run workflow** on your final code: green (or you know why it isn't)
- [ ] Everything pushed before **07:00**: the repo becomes read-only then, with no grace period
