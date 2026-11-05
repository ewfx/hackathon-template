#!/usr/bin/env bash
# Submission self-check: does what the organisers' evaluation does, from a fresh clone of this repo.
#   1. find the Dockerfile   2. build it   3. run your tests inside the image with no internet
#   4. start the app and check it answers HTTP   5. checklist warnings (README, diagram, demo link...)
# Usage: .github/scripts/self-check.sh   (needs Docker; run from the repo root)
# It never sends your code anywhere. Results: GitHub Actions summary, or this terminal.
set -u

IMAGE=self-check-submission
SUMMARY="${GITHUB_STEP_SUMMARY:-/dev/null}"
FAILED=0
ROWS=""

row() {   # row <status> <check> <detail>
  ROWS="${ROWS}| $1 | $2 | $3 |"$'\n'
  echo "[$1] $2: $3"
}
error() {   # annotation in GitHub, plain text locally
  if [ -n "${GITHUB_ACTIONS:-}" ]; then echo "::error title=$1::$2"; fi
  FAILED=1
}
warn() {
  if [ -n "${GITHUB_ACTIONS:-}" ]; then echo "::warning title=$1::$2"; fi
}

# ---- 1. Dockerfile (same places the evaluation looks) ----
DOCKERFILE=""
for f in Dockerfile dockerfile code/Dockerfile code/src/Dockerfile app/Dockerfile backend/Dockerfile src/Dockerfile; do
  if [ -f "$f" ]; then DOCKERFILE="$f"; break; fi
done
if [ -z "$DOCKERFILE" ]; then
  DOCKERFILE="$(find . -maxdepth 3 -type f -iname 'dockerfile' -not -path './.git/*' | sort | head -n 1)"
  DOCKERFILE="${DOCKERFILE#./}"
fi
PLACEHOLDER=0
if [ -n "$DOCKERFILE" ] && grep -q 'HACKATHON-PLACEHOLDER' "$DOCKERFILE" && ! grep -qiE '^[[:space:]]*FROM[[:space:]]+[^[:space:]]' "$DOCKERFILE"; then
  PLACEHOLDER=1
fi

BUILT=0
if [ "$PLACEHOLDER" = 1 ]; then
  row "❌" "Dockerfile" "$DOCKERFILE is still the placeholder: replace it with your own (the rules are in the file)"
  error "Placeholder Dockerfile" "Replace $DOCKERFILE with your own Dockerfile; the rules are in the file."
elif [ -z "$DOCKERFILE" ]; then
  row "❌" "Dockerfile" "none found: add one at the repo root or in code/ (without it nothing can be built, tested or run)"
  error "No Dockerfile" "Add a Dockerfile at the repo root or in code/."
else
  row "✅" "Dockerfile" "$DOCKERFILE"
  # ---- 2. build: repo root as context first, then the Dockerfile's folder (as the evaluation does) ----
  if docker build -q -t "$IMAGE" -f "$DOCKERFILE" . >/tmp/build.log 2>&1 \
     || docker build -q -t "$IMAGE" -f "$DOCKERFILE" "$(dirname "$DOCKERFILE")" >/tmp/build.log 2>&1; then
    BUILT=1
    row "✅" "Build" "builds from a fresh clone"
  else
    missing="$(grep -oE 'stat [^:]+: file does not exist|"[^"]+": not found' /tmp/build.log | head -n 1)"
    row "❌" "Build" "failed${missing:+: $missing} — is every file the Dockerfile copies committed (e.g. code/requirements.txt)?"
    error "Docker build failed" "${missing:-see the build log}. Commit every file your Dockerfile copies."
    tail -n 30 /tmp/build.log
  fi
fi

# ---- 3. tests, inside the image, with no internet ----
RUNNER=""
if find . -path ./.git -prune -o -type f \( -name 'test_*.py' -o -name '*_test.py' \) -print | grep -q . || [ -f pytest.ini ]; then
  RUNNER=pytest; CMD=(python -m pytest -q -p no:cacheprovider)
else
  # project files at the repo root or in code/ (the Node/Java starters use code/)
  for base in . code; do
    if [ -f "$base/package.json" ] && grep -q '"test"' "$base/package.json" && ! grep -q 'no test specified' "$base/package.json"; then
      RUNNER=npm; CMD=(npm test --silent); break
    elif [ -f "$base/pom.xml" ]; then
      RUNNER=maven; CMD=(mvn -q -o test); break
    elif [ -f "$base/build.gradle" ] || [ -f "$base/build.gradle.kts" ]; then
      RUNNER=gradle; CMD=(gradle test --offline --console=plain); break
    fi
  done
fi
if [ -z "$RUNNER" ] && { [ -f go.mod ] || [ -f code/go.mod ]; }; then
  RUNNER=go; CMD=(go test ./...)
fi

if [ -z "$RUNNER" ]; then
  row "⚠️" "Tests" "no tests found (put them under code/test/)"
  warn "No tests" "No tests found. Add tests under code/test/."
elif [ "$BUILT" = 0 ]; then
  row "⏭️" "Tests" "not run: the image didn't build"
else
  if docker run --rm --network=none -e HOME=/tmp -e COLUMNS=200 "$IMAGE" "${CMD[@]}" >/tmp/test.log 2>&1; then
    row "✅" "Tests ($RUNNER)" "pass inside the image with no internet"
  elif grep -qiE 'No module named pytest|command not found|: not found$|executable file not found' /tmp/test.log; then
    row "❌" "Tests ($RUNNER)" "the test tool isn't installed in the image: add it (e.g. pytest to requirements.txt)"
    error "Test tool missing from the image" "Add $RUNNER to your image (e.g. pytest in requirements.txt)."
  elif grep -qiE 'name resolution|Name or service not known|getaddrinfo|ENOTFOUND|EAI_AGAIN|Network is unreachable|Failed to establish a new connection|Could not resolve host' /tmp/test.log; then
    row "⚠️" "Tests ($RUNNER)" "need internet: mock LLM and other external API calls (only partial credit offline)"
    warn "Tests need internet" "Mock external calls so the tests pass offline."
  else
    row "❌" "Tests ($RUNNER)" "failing inside the image (see the log above)"
    error "Tests fail" "Your tests fail inside the image with no internet."
  fi
  tail -n 25 /tmp/test.log
fi

# ---- 4. the app starts and answers HTTP ----
if [ "$BUILT" = 1 ]; then
  CANDIDATES="$(grep -ihoE '^[[:space:]]*EXPOSE[[:space:]]+[0-9]+' "$DOCKERFILE" | grep -oE '[0-9]+') 8080 8000 3000 5000"
  PORTS="$(echo $CANDIDATES | tr ' ' '\n' | awk '!seen[$0]++' | tr '\n' ' ')"
  PUBLISH=""; for p in $PORTS; do PUBLISH="$PUBLISH -p 127.0.0.1::$p"; done
  # with the example env values first; if Docker rejects that file's format, without it
  docker run -d --name self-check-app $PUBLISH --env-file .env.example "$IMAGE" >/dev/null 2>&1 \
    || { docker rm -f self-check-app >/dev/null 2>&1; docker run -d --name self-check-app $PUBLISH "$IMAGE" >/dev/null 2>&1; }
  ANSWERED=""
  for _ in $(seq 1 30); do
    for p in $PORTS; do
      host="$(docker port self-check-app "$p/tcp" 2>/dev/null | head -n 1 | sed 's/.*://')"
      [ -z "$host" ] && continue
      code="$(curl -s -o /dev/null -m 2 -w '%{http_code}' "http://127.0.0.1:$host/" || true)"
      if [ -n "$code" ] && [ "$code" != "000" ]; then ANSWERED="$p"; break 2; fi
    done
    sleep 2
  done
  if [ -n "$ANSWERED" ]; then
    row "✅" "App runs" "answers HTTP on port $ANSWERED"
  else
    row "❌" "App runs" "didn't answer HTTP within 60 s on ports $PORTS (EXPOSE the port it listens on)"
    error "App didn't start" "The container didn't answer HTTP. Check it starts with only .env.example values."
    docker logs self-check-app 2>&1 | tail -n 25
  fi
  docker rm -f self-check-app >/dev/null 2>&1
fi

# ---- 5. checklist (warnings only) ----
if grep -q "Replace this whole README" README.md 2>/dev/null; then
  row "⚠️" "README" "still the template text: write your own"; warn "README" "Still the template README."
else
  row "✅" "README" "your own"
fi
if [ -f .env.example ]; then row "✅" ".env.example" "present"; else
  row "⚠️" ".env.example" "missing: list every variable your app needs (names only)"; warn ".env.example" "Missing."; fi
if git ls-files --error-unmatch .env >/dev/null 2>&1; then
  row "❌" ".env" "committed: remove it and rotate any real keys in it"; error ".env committed" "Remove .env from the repo."
fi
if find artifacts/arch -type f ! -iname 'README.md' 2>/dev/null | grep -q .; then row "✅" "Architecture diagram" "found in artifacts/arch/"
else row "⚠️" "Architecture diagram" "add one to artifacts/arch/"; warn "Architecture diagram" "Add one to artifacts/arch/."; fi
if grep -qiE 'https?://(www\.)?(youtu\.be|youtube\.com|loom\.com|vimeo\.com|drive\.google\.com)/' artifacts/demo/DEMO.md 2>/dev/null; then
  row "✅" "Demo link" "found in artifacts/demo/DEMO.md"
else row "⚠️" "Demo link" "add it to artifacts/demo/DEMO.md before the freeze"; warn "Demo link" "Add it to artifacts/demo/DEMO.md."; fi

{
  echo "## Submission self-check"
  echo
  echo "Runs what the organisers' evaluation runs, from a fresh clone. ❌ items cost points; fix them before the freeze."
  echo
  echo "| | Check | Result |"
  echo "|---|---|---|"
  printf '%s' "$ROWS"
} >> "$SUMMARY"

exit "$FAILED"
