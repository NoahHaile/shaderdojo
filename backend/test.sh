#!/usr/bin/env bash
# End-to-end smoke + feature tests for ShaderDojo.
# Run from anywhere; the script chdir's to its own directory and expects
# `docker compose` to be up in this same directory.
#
# Usage:   bash test.sh
# Exit:    0 if every test passes, 1 otherwise.

set -u
cd "$(dirname "$0")"

# ---- prerequisites ----
if ! command -v jq >/dev/null 2>&1; then
    echo "jq not installed; installing..."
    sudo apt-get install -y jq >/dev/null 2>&1 || { echo "Install jq manually."; exit 1; }
fi
if [[ ! -f .env ]]; then echo "No .env in $(pwd)"; exit 1; fi
set -a; source .env; set +a   # exports POSTGRES_USER, JWT_KEY, API_KEY, VALIDATOR_KEY, etc.

HOST="${HOST:-http://localhost}"

# ---- output helpers ----
if [[ -t 1 ]]; then GREEN=$'\033[32m'; RED=$'\033[31m'; DIM=$'\033[2m'; BOLD=$'\033[1m'; OFF=$'\033[0m'
else                 GREEN="";       RED="";       DIM="";      BOLD="";      OFF=""; fi

PASS=0; FAIL=0; FAILED_TESTS=()
pass() { PASS=$((PASS+1)); echo "  ${GREEN}✓${OFF} $1"; }
fail() { FAIL=$((FAIL+1)); FAILED_TESTS+=("$1"); echo "  ${RED}✗${OFF} $1   ${DIM}$2${OFF}"; }
section() { echo; echo "${BOLD}$1${OFF}"; }

# Reusable HTTP helper. Sets globals STATUS and BODY.
http() {
    local method=$1 path=$2; shift 2
    STATUS=$(curl -sS -o /tmp/sd-body -w "%{http_code}" -X "$method" "$@" "$HOST$path" 2>/dev/null || echo 000)
    BODY=$(cat /tmp/sd-body)
}

# Build the FE-equivalent fragment header (must stay byte-identical to
# frontend/scripts/shaderFunctions.js and to FRAGMENT_HEADER in the backend).
FRAGMENT_HEADER=$'\nprecision mediump float;\nuniform vec2 u_resolution;\nuniform float u_time;\n\n'

# ============================================================================
section "## Validator (direct, internal network)"
# ============================================================================
VHEALTH=$(docker compose exec -T backend wget -qO- http://validator:3000/health 2>&1 || true)
echo "$VHEALTH" | grep -q '"ok":true' && pass "validator /health" || fail "validator /health" "$VHEALTH"

V_RENDER=$(docker compose exec -T backend wget -qO- \
    --header="X-Validator-Key: $VALIDATOR_KEY" \
    --header='Content-Type: application/json' \
    --post-data='{"vertexShader":"attribute vec4 aVertexPosition;void main(){gl_Position=aVertexPosition;}","fragmentShader":"precision mediump float;void main(){gl_FragColor=vec4(0.0,1.0,0.0,1.0);}","time":20}' \
    http://validator:3000/execute-shader 2>&1 || true)
echo "$V_RENDER" | grep -q '"imageHash"' && pass "validator renders a valid shader" || fail "validator render" "$V_RENDER"

V_REJECT=$(docker compose exec -T backend wget -SO- \
    --header='Content-Type: application/json' \
    --post-data='{"vertexShader":"x","fragmentShader":"y","time":0}' \
    http://validator:3000/execute-shader 2>&1 || true)
echo "$V_REJECT" | grep -q '401' && pass "validator rejects missing key" || fail "validator unauth" "$V_REJECT"

# ============================================================================
section "## Backend — public read endpoints"
# ============================================================================
http GET /app/actuator/health
[[ "$STATUS" == 200 && "$BODY" == *'"status":"UP"'* ]] \
    && pass "GET /app/actuator/health → 200 UP" \
    || fail "/app/actuator/health" "got $STATUS $BODY"

http GET /app/courses
COURSES_JSON="$BODY"
if [[ "$STATUS" == 200 ]] && echo "$BODY" | jq -e '.[] | select(.slug=="basics")' >/dev/null \
    && echo "$BODY" | jq -e '.[] | select(.slug=="shaping")' >/dev/null \
    && echo "$BODY" | jq -e '.[] | select(.slug=="color")' >/dev/null; then
    pass "GET /app/courses returns the 3 seed courses"
else
    fail "/app/courses content" "$STATUS"
fi

# Lesson count = 15 across all courses
LESSON_COUNT=$(echo "$COURSES_JSON" | jq '[.[].lessons[]] | length' 2>/dev/null)
[[ "$LESSON_COUNT" == 15 ]] && pass "15 lessons across the 3 courses" || fail "lesson count" "got $LESSON_COUNT"

# Pick the first lesson (Hello, color) for follow-up tests
FIRST_LESSON_ID=$(echo "$COURSES_JSON" | jq -r '.[0].lessons[0].id')
FIRST_LESSON_TITLE=$(echo "$COURSES_JSON" | jq -r '.[0].lessons[0].title')
echo "  ${DIM}using lesson: $FIRST_LESSON_TITLE  ($FIRST_LESSON_ID)${OFF}"

http GET /app/courses/basics
[[ "$STATUS" == 200 && "$BODY" == *'"slug":"basics"'* ]] \
    && pass "GET /app/courses/basics" \
    || fail "/app/courses/basics" "$STATUS"

http GET "/app/lessons/$FIRST_LESSON_ID"
LESSON_VERIFIED=$(echo "$BODY" | jq -r '.verified' 2>/dev/null)
[[ "$STATUS" == 200 && "$LESSON_VERIFIED" == "true" ]] \
    && pass "GET /app/lessons/{id} reports verified=true" \
    || fail "/app/lessons/{id}" "status=$STATUS verified=$LESSON_VERIFIED"

http GET "/app/lessons/$FIRST_LESSON_ID/solution"
CANONICAL=$(echo "$BODY" | jq -r '.canonicalFragmentShader' 2>/dev/null)
[[ "$STATUS" == 200 && -n "$CANONICAL" && "$CANONICAL" != "null" ]] \
    && pass "GET /app/lessons/{id}/solution returns canonical shader" \
    || fail "/app/lessons/{id}/solution" "$STATUS"

http GET "/app/comments/$FIRST_LESSON_ID"
[[ "$STATUS" == 200 ]] && pass "GET /app/comments/{lessonId}" || fail "/app/comments/{lessonId}" "$STATUS"

http GET /app/account
[[ "$STATUS" == 401 ]] && pass "GET /app/account without JWT → 401" || fail "/app/account unauth" "got $STATUS"

# ============================================================================
section "## Auth — register + login"
# ============================================================================
SUFFIX=$(date +%s%N | sha256sum | cut -c1-12)
USERNAME="tester-$SUFFIX"
PASSWORD="P@ssw0rd-$SUFFIX"
EMAIL="$USERNAME@test.local"

http POST /auth/register -H 'Content-Type: application/json' \
    -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"email\":\"$EMAIL\"}"
JWT=""
if [[ "$STATUS" == 200 && -n "$BODY" && "$BODY" != *'"error"'* ]]; then
    JWT="$BODY"
    pass "POST /auth/register issues a JWT"
else
    fail "POST /auth/register" "status=$STATUS body=$BODY"
fi

http POST /auth/login -H 'Content-Type: application/json' \
    -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}"
[[ "$STATUS" == 200 && -n "$BODY" && "$BODY" != *'"error"'* ]] \
    && pass "POST /auth/login (correct creds) issues a JWT" \
    || fail "/auth/login correct" "status=$STATUS"

http POST /auth/login -H 'Content-Type: application/json' \
    -d "{\"username\":\"$USERNAME\",\"password\":\"wrong-password\"}"
[[ "$STATUS" == 401 ]] && pass "POST /auth/login (wrong creds) → 401" || fail "/auth/login wrong" "got $STATUS"

http POST /auth/register -H 'Content-Type: application/json' \
    -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"email\":\"$EMAIL\"}"
[[ "$STATUS" == 409 ]] && pass "POST /auth/register (duplicate username) → 409" || fail "/auth/register dup" "got $STATUS"

# ============================================================================
section "## Account — authed endpoints"
# ============================================================================
if [[ -z "$JWT" ]]; then
    echo "  ${DIM}skipping: no JWT from register${OFF}"
else
    http GET /app/account -H "Authorization: Bearer $JWT"
    [[ "$STATUS" == 200 && "$BODY" == *"$USERNAME"* ]] && pass "GET /app/account returns own account" || fail "/app/account" "status=$STATUS"

    http GET /app/account/verify_account -H "Authorization: Bearer $JWT"
    [[ "$STATUS" == 200 ]] && pass "GET /app/account/verify_account → 200" || fail "verify_account" "got $STATUS"

    http GET "/app/account/status/$FIRST_LESSON_ID" -H "Authorization: Bearer $JWT"
    if [[ "$STATUS" == 200 ]] && echo "$BODY" | jq -e '.status' >/dev/null; then
        pass "GET /app/account/status/{lessonId} returns attempt status"
    else
        fail "/app/account/status" "$STATUS $BODY"
    fi
fi

# ============================================================================
section "## Lesson verify — canonical solution must score"
# ============================================================================
if [[ -z "$JWT" || -z "$CANONICAL" ]]; then
    echo "  ${DIM}skipping: missing JWT or canonical shader${OFF}"
else
    # Build full fragment as the FE does: header + body. jq builds the JSON safely.
    FULL_FRAG="${FRAGMENT_HEADER}${CANONICAL}"
    SUBMIT=$(jq -n --arg ls "$FIRST_LESSON_ID" --arg fs "$FULL_FRAG" \
        '{lessonId:$ls, vertexShader:"unused", fragmentShader:$fs, time:20}')

    http POST /app/lessons/verify -H "Authorization: Bearer $JWT" \
        -H 'Content-Type: application/json' -d "$SUBMIT"
    [[ "$STATUS" == 200 ]] \
        && pass "POST /app/lessons/verify with canonical shader → 200" \
        || fail "verify canonical" "status=$STATUS body=$BODY"

    # Submit a deliberately wrong shader; expect 400 Incorrect
    WRONG=$(jq -n --arg ls "$FIRST_LESSON_ID" \
        --arg fs "${FRAGMENT_HEADER}void main(){gl_FragColor=vec4(0.9,0.1,0.5,1.0);}" \
        '{lessonId:$ls, vertexShader:"unused", fragmentShader:$fs, time:20}')
    http POST /app/lessons/verify -H "Authorization: Bearer $JWT" \
        -H 'Content-Type: application/json' -d "$WRONG"
    [[ "$STATUS" == 400 ]] \
        && pass "POST /app/lessons/verify with wrong shader → 400" \
        || fail "verify wrong" "got $STATUS"

    # After a successful submit, status should now be SUCCESSFUL
    http GET "/app/account/status/$FIRST_LESSON_ID" -H "Authorization: Bearer $JWT"
    STATUS_VAL=$(echo "$BODY" | jq -r '.status' 2>/dev/null)
    [[ "$STATUS_VAL" == "SUCCESSFUL" ]] \
        && pass "attempt status flipped to SUCCESSFUL" \
        || fail "status after submit" "got $STATUS_VAL"
fi

# ============================================================================
section "## Comments — post + list (authed + anonymous)"
# ============================================================================
# Authed comment via the new POST /comments/:lessonId
if [[ -z "$JWT" ]]; then
    echo "  ${DIM}skipping authed-comment test: no JWT${OFF}"
else
    COMMENT_BODY=$(jq -n --arg c "void main(){gl_FragColor=vec4(0.0,1.0,0.0,1.0);}" \
        --arg d "authed smoke-test ($SUFFIX)" \
        '{code:$c, content:$d}')
    http POST "/app/comments/$FIRST_LESSON_ID" \
        -H "Authorization: Bearer $JWT" \
        -H 'Content-Type: application/json' -d "$COMMENT_BODY"
    [[ "$STATUS" == 201 ]] \
        && pass "POST /app/comments/{lessonId} (authed) → 201" \
        || fail "post authed comment" "status=$STATUS body=$BODY"
fi

# Anonymous comment — same endpoint, no Authorization header
ANON_BODY=$(jq -n --arg d "anon smoke-test ($SUFFIX)" '{content:$d}')
http POST "/app/comments/$FIRST_LESSON_ID" \
    -H 'Content-Type: application/json' -d "$ANON_BODY"
[[ "$STATUS" == 201 ]] \
    && pass "POST /app/comments/{lessonId} (anonymous) → 201" \
    || fail "post anon comment" "status=$STATUS body=$BODY"

http GET "/app/comments/$FIRST_LESSON_ID"
HAS_AUTHED=$(echo "$BODY" | jq --arg s "authed smoke-test ($SUFFIX)" \
    '[.[] | select(.content == $s)] | length' 2>/dev/null)
HAS_ANON=$(echo "$BODY"   | jq --arg s "anon smoke-test ($SUFFIX)" \
    '[.[] | select(.content == $s and .username == null)] | length' 2>/dev/null)
if [[ -z "$JWT" ]]; then HAS_AUTHED=1; fi   # would have been skipped above
[[ "$HAS_AUTHED" -ge 1 && "$HAS_ANON" -ge 1 ]] \
    && pass "GET /app/comments/{lessonId} contains both authed + anonymous comments" \
    || fail "comment list" "authed=$HAS_AUTHED anon=$HAS_ANON"

# ============================================================================
section "## Admin — recompute-hashes auth"
# ============================================================================
http POST /app/lessons/recompute-hashes -H "Admin-Authorization: $API_KEY"
[[ "$STATUS" == 200 ]] && pass "POST recompute-hashes with correct admin key → 200" || fail "recompute admin" "$STATUS"

http POST /app/lessons/recompute-hashes -H "Admin-Authorization: definitely-wrong-key"
[[ "$STATUS" == 401 ]] && pass "POST recompute-hashes (wrong key) → 401" || fail "recompute wrong-key" "got $STATUS"

http POST /app/lessons/recompute-hashes
[[ "$STATUS" == 401 ]] && pass "POST recompute-hashes (no key) → 401" || fail "recompute no-key" "got $STATUS"

# ============================================================================
section "## Summary"
# ============================================================================
TOTAL=$((PASS+FAIL))
echo "  Tests: $TOTAL    ${GREEN}Pass: $PASS${OFF}    ${RED}Fail: $FAIL${OFF}"
if (( FAIL > 0 )); then
    echo
    echo "${BOLD}${RED}Failed features:${OFF}"
    for t in "${FAILED_TESTS[@]}"; do echo "  - $t"; done
    exit 1
fi
echo
echo "${GREEN}${BOLD}All features green.${OFF}"
