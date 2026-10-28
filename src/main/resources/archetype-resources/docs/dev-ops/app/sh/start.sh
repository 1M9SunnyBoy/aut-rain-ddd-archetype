#set( $dollar = '$' )
#set( $hash = '#' )
${hash}!/usr/bin/env bash
set -euo pipefail
if (( ${dollar}${hash} > 2 )); then echo "Usage: bash start.sh [image-tag] [env-file]" >&2; exit 2; fi
export IMAGE_TAG="${dollar}{1:-latest}"
[[ "${dollar}IMAGE_TAG" =~ ^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}${dollar} ]] || { echo "Invalid image tag" >&2; exit 2; }
SCRIPT_DIR="${dollar}(cd -- "${dollar}(dirname -- "${dollar}{BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="${dollar}(cd -- "${dollar}SCRIPT_DIR/../.." && pwd)"
ENV_FILE="${dollar}{2:-${dollar}OPS_DIR/app/.env}"
[[ -f "${dollar}ENV_FILE" ]] || { echo "Missing production env file: ${dollar}ENV_FILE (see app/.env.example)" >&2; exit 1; }
command -v docker >/dev/null || { echo "Missing command: docker" >&2; exit 1; }
COMPOSE=(docker compose --project-name ${artifactId} --project-directory "${dollar}OPS_DIR/environment" --env-file "${dollar}ENV_FILE" -f "${dollar}OPS_DIR/environment/docker-compose.yml" -f "${dollar}OPS_DIR/app/docker-compose.yml")
"${dollar}{COMPOSE[@]}" config --quiet
${hash} Verify both images before replacing either running container.
for component in app web; do docker image inspect "${artifactId}/${dollar}component:${dollar}IMAGE_TAG" >/dev/null; done
"${dollar}{COMPOSE[@]}" up -d --no-deps --no-build --pull never --force-recreate --wait --wait-timeout 180 app
"${dollar}{COMPOSE[@]}" up -d --no-deps --no-build --pull never --force-recreate --wait --wait-timeout 180 nginx
"${dollar}{COMPOSE[@]}" ps app nginx
echo "Application started."
