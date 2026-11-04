#set( $dollar = '$' )
#set( $hash = '#' )
${hash}!/usr/bin/env bash
${hash} description: 检查并构建前后端产物及 Docker 镜像，不启动服务。
${hash} author: zzy
${hash} created: 2026-10-28
${hash} Arguments: [image-tag], default latest. Builds artifacts and images without starting services.
set -euo pipefail
if (( ${dollar}${hash} > 1 )); then echo "Usage: bash build.sh [image-tag]" >&2; exit 2; fi
IMAGE_TAG="${dollar}{1:-latest}"
[[ "${dollar}IMAGE_TAG" =~ ^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}${dollar} ]] || { echo "Invalid image tag" >&2; exit 2; }
SCRIPT_DIR="${dollar}(cd -- "${dollar}(dirname -- "${dollar}{BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${dollar}(cd -- "${dollar}SCRIPT_DIR/../../../.." && pwd)"
for cmd in java mvn node corepack docker; do command -v "${dollar}cmd" >/dev/null || { echo "Missing command: ${dollar}cmd" >&2; exit 1; }; done
[[ "${dollar}(node --version)" == "v22.22.0" ]] || { echo "Node.js 22.22.0 is required" >&2; exit 1; }
docker info >/dev/null
cd -- "${dollar}PROJECT_ROOT"
mvn -B -ntp -f app-backend/pom.xml clean package
corepack pnpm --dir web install --frozen-lockfile
for task in typecheck lint test build; do corepack pnpm --dir web "${dollar}task"; done
[[ -f "app-backend/${artifactId}-app/target/${artifactId}-app.jar" && -f web/dist/index.html ]] || { echo "Missing build artifacts" >&2; exit 1; }
docker build --tag "${artifactId}/app:${dollar}IMAGE_TAG" "app-backend/${artifactId}-app"
docker build --tag "${artifactId}/web:${dollar}IMAGE_TAG" --file docs/dev-ops/environment/nginx/Dockerfile .
echo "Built ${artifactId}/app:${dollar}IMAGE_TAG and ${artifactId}/web:${dollar}IMAGE_TAG"
