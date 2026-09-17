#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="026090519635"

ECR_REPO="kepler-arm64"
KEPLER_VERSION="v0.11.4"

REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE="${REGISTRY}/${ECR_REPO}:${KEPLER_VERSION}"

# Persist outside Terraform/ECR so destroy does NOT remove build cache.
CACHE_DIR="${HOME}/.cache/kepler-buildx"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SBOM_DIR="${INFRA_ROOT}/artifacts/sbom"

if [[ -z "${COSIGN_IDENTITY:-}" ]]; then
  echo "ERROR: COSIGN_IDENTITY is not set."
  echo 'Example: export COSIGN_IDENTITY="<your identity>"'
  exit 1
fi

for cmd in aws docker git syft cosign; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "ERROR: ${cmd} is required but not installed."
    exit 1
  fi
done

echo "Checking ECR repository..."
aws ecr describe-repositories \
  --region "${AWS_REGION}" \
  --repository-names "${ECR_REPO}" \
  >/dev/null

echo "Logging into ECR..."
aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login \
      --username AWS \
      --password-stdin \
      "${REGISTRY}"

# If image already exists in ECR, don't rebuild it.
if aws ecr describe-images \
  --region "${AWS_REGION}" \
  --repository-name "${ECR_REPO}" \
  --image-ids imageTag="${KEPLER_VERSION}" \
  >/dev/null 2>&1; then

  echo
  echo "Kepler image already exists in ECR:"
  echo "${IMAGE}"
  echo "Skipping Docker build."
  exit 0
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

echo "Cloning Kepler ${KEPLER_VERSION}..."
git clone \
  --depth 1 \
  --branch "${KEPLER_VERSION}" \
  https://github.com/sustainable-computing-io/kepler.git \
  "${WORKDIR}/kepler"

cd "${WORKDIR}/kepler"

GIT_COMMIT="$(git rev-parse HEAD)"

# IMPORTANT:
# Use the Git commit timestamp instead of "date now".
# This stays identical for the same Kepler version and allows Docker
# to reuse the expensive Go compilation layer.
BUILD_TIME="$(git show -s --format=%cI HEAD)"

mkdir -p "${CACHE_DIR}"
mkdir -p "${SBOM_DIR}"

echo
echo "Building ARM64 Kepler image..."
echo "Image: ${IMAGE}"
echo "Build cache: ${CACHE_DIR}"
echo

docker buildx build \
  --progress=plain \
  --platform linux/arm64 \
  --cache-from "type=local,src=${CACHE_DIR}" \
  --cache-to "type=local,dest=${CACHE_DIR},mode=max" \
  --build-arg VERSION="${KEPLER_VERSION}" \
  --build-arg GIT_COMMIT="${GIT_COMMIT}" \
  --build-arg GIT_BRANCH="${KEPLER_VERSION}" \
  --build-arg BUILD_TIME="${BUILD_TIME}" \
  -t "${IMAGE}" \
  --push \
  .

echo
echo "Verifying image architecture..."
docker buildx imagetools inspect "${IMAGE}"

echo
echo "Generating SBOM..."
syft "${IMAGE}" \
  -o spdx-json \
  > "${SBOM_DIR}/kepler-${KEPLER_VERSION}.spdx.json"

echo
echo "Signing image..."
cosign sign \
  --yes \
  "${IMAGE}"

echo
echo "Verifying Cosign signature..."
cosign verify \
  --certificate-identity "${COSIGN_IDENTITY}" \
  --certificate-oidc-issuer "https://github.com/login/oauth" \
  "${IMAGE}"

echo
echo "======================================"
echo "Kepler ARM64 image complete"
echo "======================================"
echo "${IMAGE}"