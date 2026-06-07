git pull
cd backend

# export API_KEY from .env (handles '=' in the value)
export API_KEY=$(grep -E '^API_KEY=' .env | head -n1 | cut -d= -f2-)

docker compose down -v

# bring the stack up
docker compose up -d --build

# wait for nginx to serve, then populate lesson answer hashes
until curl -fsS -o /dev/null http://localhost/; do sleep 2; done
curl -fsS -X POST http://localhost/app/lessons/recompute-hashes \
  -H "Admin-Authorization: $API_KEY"
