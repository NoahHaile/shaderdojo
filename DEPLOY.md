# Staging / Production Deploy

Everything runs from a single `docker compose up -d` in `backend/`. The stack:

| Service | What | Exposed |
|---|---|---|
| `nginx` | Serves the frontend and reverse-proxies `/auth/*` → auth, `/app/*` → app | host `${HTTP_PORT}` (default 80) |
| `app` | Spring Boot API (problems, comments, accounts, verify) | internal only |
| `auth` | Spring Boot auth (register, login, JWT) | internal only |
| `validator` | Puppeteer + Chromium shader renderer | internal only |
| `db` | Postgres 15 with `init/postgres/init.sql` | internal only |
| `pgadmin` | Optional, profile=`admin` | `127.0.0.1:7089` |

Backend services and the validator are **never** published to the host — they're reachable only inside the `shaderdojo-network` bridge, and the only public surface is nginx.

---

## First deploy on a fresh staging box

Prerequisites: Docker + the Compose plugin (`docker compose version`).

```sh
git clone <repo> shaderdojo
cd shaderdojo/backend

# 1) Create your .env (NEVER commit this).
cp .env.example .env

# 2) Generate strong secrets. JWT_KEY must be >= 32 bytes after UTF-8 encode.
#    On the staging box:
echo "JWT_KEY=$(openssl rand -base64 48)"        >> .env.local
echo "API_KEY=$(openssl rand -hex 32)"           >> .env.local
echo "VALIDATOR_KEY=$(openssl rand -base64 48)"  >> .env.local
echo "POSTGRES_PASSWORD=$(openssl rand -hex 24)" >> .env.local
#    Then merge .env.local into .env by hand (don't blindly cat — .env.example
#    has POSTGRES_USER and other non-secret keys you want to keep).

# 3) Bring everything up.
docker compose up -d --build

# 4) Confirm.
curl -sS http://localhost/      # should return the ShaderDojo landing page
curl -sS http://localhost/auth/ping   # should return "pong"
```

The full stack should be reachable on `http://<staging-host>` — nginx listens on port 80 inside the container, mapped to `HTTP_PORT` (default 80) on the host.

---

## Where to put TLS

The included nginx terminates HTTP only. In staging, put TLS at one of these layers:

- **Cloudflare / ALB in front of the box.** Recommended. Set `HTTP_PORT=8080` in `.env`, point your TLS terminator at it, done. Cloudflare also gives you DDoS shielding for free.
- **Caddy or a second nginx on the host.** Proxy `https://<host>` → `http://127.0.0.1:${HTTP_PORT}` and let it handle Let's Encrypt.

Don't try to do TLS inside the compose-bundled nginx unless you have a real reason — cert renewal complicates the otherwise stateless container.

---

## What lives where

```
backend/
├── docker-compose.yml          # single source of truth for the stack
├── .env.example                # copy to .env on each deploy host
├── nginx/nginx.conf            # serves frontend + proxies /auth and /app
├── init/postgres/init.sql      # schema; applied on first DB boot only
├── app/                        # main API
├── auth/                       # auth service
└── pgadmin/                    # admin tool (--profile admin)
validator/                      # Node + Puppeteer shader renderer
frontend/                       # static HTML/JS/CSS, served by nginx
```

---

## Required env vars

These must be set in `.env` or the stack will fail to start:

| Variable | Why |
|---|---|
| `POSTGRES_USER`, `POSTGRES_PASSWORD` | Postgres creds; the app and auth services use the same pair. |
| `JWT_KEY` | HMAC signing key. **Must be ≥ 32 bytes after UTF-8 encode.** Both services fail-fast at boot if it's shorter. |
| `API_KEY` | Admin secret for `Admin-Authorization` header (admin CRUD on /problems and /comments). |
| `VALIDATOR_KEY` | Shared secret between `app` and `validator`. Constant-time compared. |

Optional:

| Variable | Default | Purpose |
|---|---|---|
| `HTTP_PORT` | `80` | What nginx publishes on the host. |
| `CORS_ALLOWED_ORIGINS` | empty | Comma-separated origins. Leave blank when the frontend is served by the bundled nginx — same-origin doesn't need CORS. |
| `VALIDATOR_MAX_CONCURRENT_RENDERS` | `2` | Bounded worker pool inside the validator. |
| `VALIDATOR_RENDER_TIMEOUT_MS` | `5000` | Per-render watchdog. |

---

## Day-2 operations

```sh
# Logs (Ctrl-C exits, services keep running)
docker compose logs -f app auth validator nginx

# Rebuild a single service after a code change
docker compose up -d --build app

# Database shell
docker compose exec db psql -U $POSTGRES_USER -d shader_dojo

# pgAdmin (web UI on 127.0.0.1:7089). Requires PGADMIN_EMAIL and PGADMIN_PASSWORD.
docker compose --profile admin up -d pgadmin

# Stop the stack
docker compose down

# Stop AND wipe the database volume
docker compose down -v
```

---

## Populating lesson answer hashes (mandatory after first deploy / new lessons)

`init.sql` ships three courses (Basics, Shaping, Color) with 15 lessons. Each lesson has a `canonical_fragment_shader` but **no `hashed_answer`** — that hash depends on what the validator's Chromium build actually produces, so it has to be computed on the running box.

After `docker compose up -d --build`, hit the admin batch endpoint:

```sh
API_KEY=$(grep ^API_KEY .env | cut -d= -f2-)
curl -sS -X POST http://localhost/app/lessons/recompute-hashes \
  -H "Admin-Authorization: $API_KEY" | jq
```

The endpoint walks every lesson, renders its canonical shader through the validator, and writes `hashed_answer`. Response:

```json
{
  "updated": [{ "id": "...", "title": "Hello, color", "hash": "..." }],
  "skipped": [],
  "failed": [],
  "verificationTime": 20.0
}
```

It's idempotent — re-run any time you add a lesson or change a canonical answer. Lessons without a hash appear as `Explore` in the UI and reject `POST /lessons/verify`. Lessons with a hash appear as `Verified`.

### Adding more lessons

You don't need to edit `init.sql` after the initial deploy — use the admin REST endpoints (which DO require a JWT, unlike `recompute-hashes` which is admin-key-only):

```sh
TOKEN=$(curl -sS -X POST http://localhost/auth/login -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"<pw>"}')

# Create a course
curl -X POST http://localhost/app/courses \
  -H "Authorization: Bearer $TOKEN" -H "Admin-Authorization: $API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"slug":"shapes-2","title":"Shapes II","displayOrder":3}'

# Create a lesson (the response from the call above gives the course id)
curl -X POST http://localhost/app/lessons \
  -H "Authorization: Bearer $TOKEN" -H "Admin-Authorization: $API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"courseId":"<course-id>","slug":"my-lesson","displayOrder":0,"title":"My lesson","description":"...","starterFragmentShader":"void main(){...}","canonicalFragmentShader":"void main(){...}"}'

# Then run recompute-hashes to populate the new lesson's hashed_answer.
```

---

## Updating

```sh
git pull
docker compose up -d --build      # rebuilds only services whose context changed
```

The Postgres volume (`postgres_data`) survives `docker compose down` and rebuilds — `init.sql` is only re-run on a fresh volume.

---

## Common gotchas

- **`jwt.key must be set and at least 32 bytes`** at app boot → your `JWT_KEY` is too short. Use `openssl rand -base64 48`.
- **`Validator unreachable`** in `app` logs → the `validator` container failed to start. Check `docker compose logs validator` for Chrome sandbox errors.
- **Frontend 404s on JS files** → the `frontend/` bind mount is missing. Confirm the path in `docker-compose.yml` resolves on the host.
- **`Unauthorized` from `/app/problems/verify`** → user JWT expired (30 days) or `VALIDATOR_KEY` in `app`'s environment doesn't match the validator's.
- **Bringing up pgAdmin on the public internet** is a bad idea even with credentials. Keep the port bound to `127.0.0.1` and SSH-forward when you need it.
