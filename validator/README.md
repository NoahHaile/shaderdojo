# ShaderDojo Validator

Renders user-submitted WebGL shaders in headless Chromium and returns a SHA-256 hash of the resulting PNG. Called by the Java app at `/problems/verify`.

## Running

```sh
VALIDATOR_KEY=<shared-secret> npm start
```

`VALIDATOR_KEY` is required. The Java app sends the same value in the `X-Validator-Key` header.

## Environment

| Variable | Default | Purpose |
|---|---|---|
| `PORT` | `3000` | Listen port |
| `VALIDATOR_KEY` | — *(required)* | Shared secret. Constant-time compared against `X-Validator-Key` header. |
| `MAX_CONCURRENT_RENDERS` | `2` | Bounded worker pool — extra requests queue, then `429`. |
| `QUEUE_WAIT_TIMEOUT_MS` | `8000` | Max wait in queue before returning `429`. |
| `RENDER_TIMEOUT_MS` | `5000` | Per-render watchdog. Long-running shaders return `504`. |
| `RENDER_SETTLE_MS` | `150` | Idle wait after `drawArrays` before screenshot. |
| `MAX_SHADER_BYTES` | `32768` | Per-shader source size limit. Over-size returns `413`. |

## Sandbox

The validator launches Puppeteer **with the Chromium sandbox enabled** (no `--no-sandbox`). Because it executes attacker-controlled GLSL, the sandbox is load-bearing.

If you run the validator inside Docker:
- Use a non-root user inside the container, or
- Use a Chromium-ready base image such as `ghcr.io/puppeteer/puppeteer:latest`, or
- As a last resort, add `--cap-add=SYS_ADMIN` (less safe).

Do not re-enable `--no-sandbox` outside a contained, untrusted-friendly host.

## Security design

- User-supplied vertex/fragment source is passed as **arguments to `page.evaluate`** — Puppeteer JSON-serializes them, so they can never escape into JS context (the previous template-literal interpolation was a pre-auth RCE).
- All endpoints except `/health` require the shared-secret header.
- Bounded concurrency + per-render timeout protect against infinite-loop GLSL.
- No temp files written to disk.

## API

### `POST /execute-shader`

Request:
```json
{ "vertexShader": "string", "fragmentShader": "string", "time": 0.0 }
```

Headers: `X-Validator-Key: <secret>`

Response (`200`):
```json
{ "imageHash": "<sha256 hex>", "byteLength": <png-bytes> }
```

Errors: `400` invalid input / shader compile failure, `401` bad key, `413` shader too large, `429` queue full, `504` render timeout, `500` internal.

### `GET /health`

Returns `{ "ok": true }` (no auth).
