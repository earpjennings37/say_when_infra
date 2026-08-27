#!/usr/bin/env bash

set -euo pipefail

AWS_REGION="us-east-1"
POPEYE_VERSION="0.22.1"
REPOSITORY_NAME="popeye-arm64"
IMAGE_TAG="${POPEYE_VERSION}-arm64"

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE="${ECR_REGISTRY}/${REPOSITORY_NAME}:${IMAGE_TAG}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SBOM_DIR="${REPO_ROOT}/artifacts/sbom"

# Keep personal signing identity outside the public repo.
COSIGN_IDENTITY="${COSIGN_IDENTITY:-}"
COSIGN_ISSUER="${COSIGN_ISSUER:-https://github.com/login/oauth}"

echo "========================================"
echo "Secure Popeye Build"
echo "========================================"
echo "Image: ${IMAGE}"
echo

# --------------------------------------------------
# Check required tools
# --------------------------------------------------

for command in aws docker syft cosign; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "ERROR: ${command} is not installed or not in PATH."
    exit 1
  fi
done

# --------------------------------------------------
# 1. Confirm ECR repository exists
# --------------------------------------------------

echo "[1/7] Checking ECR repository..."

aws ecr describe-repositories \
  --repository-names "${REPOSITORY_NAME}" \
  --region "${AWS_REGION}" \
  >/dev/null

# --------------------------------------------------
# 2. Authenticate Docker to ECR
# --------------------------------------------------

echo "[2/7] Logging into ECR..."

aws ecr get-login-password \
  --region "${AWS_REGION}" \
  | docker login \
      --username AWS \
      --password-stdin \
      "${ECR_REGISTRY}"

# --------------------------------------------------
# 3. Build + push ARM64 Popeye image
# --------------------------------------------------

echo "[3/7] Building and pushing ARM64 Popeye image..."

docker buildx build \
  --platform linux/arm64 \
  -t "${IMAGE}" \
  --push \
  "${REPO_ROOT}/images/popeye"

# --------------------------------------------------
# 4. Resolve immutable image digest
# --------------------------------------------------

echo "[4/7] Resolving image digest..."

DIGEST="$(aws ecr describe-images \
  --repository-name "${REPOSITORY_NAME}" \
  --image-ids imageTag="${IMAGE_TAG}" \
  --region "${AWS_REGION}" \
  --query 'imageDetails[0].imageDigest' \
  --output text)"

IMAGE_DIGEST="${ECR_REGISTRY}/${REPOSITORY_NAME}@${DIGEST}"

echo "Digest:"
echo "${IMAGE_DIGEST}"
echo

# --------------------------------------------------
# 5. Generate SBOMs
# --------------------------------------------------

echo "[5/7] Generating SBOMs..."

mkdir -p "${SBOM_DIR}"

syft "${IMAGE_DIGEST}" \
  --platform linux/arm64 \
  -o "cyclonedx-json=${SBOM_DIR}/popeye-${POPEYE_VERSION}-cyclonedx.json" \
  -o "spdx-json=${SBOM_DIR}/popeye-${POPEYE_VERSION}-spdx.json"

echo
echo "SBOM files:"
ls -lh "${SBOM_DIR}"
echo

# --------------------------------------------------
# 6. Sign immutable image
# --------------------------------------------------

echo "[6/7] Signing image with Cosign..."
echo "You may be prompted to authenticate with your OIDC provider."

cosign sign "${IMAGE_DIGEST}"

# --------------------------------------------------
# 7. Verify signature
# --------------------------------------------------

if [[ -n "${COSIGN_IDENTITY}" ]]; then
  echo
  echo "[7/7] Strictly verifying Cosign signature..."

  cosign verify "${IMAGE_DIGEST}" \
    --certificate-identity="${COSIGN_IDENTITY}" \
    --certificate-oidc-issuer="${COSIGN_ISSUER}"

  VERIFY_STATUS="Strict Cosign verification successful."
else
  echo
  echo "[7/7] Strict verification skipped."
  echo "Set COSIGN_IDENTITY locally to enable strict verification."

  VERIFY_STATUS="Image signed; strict identity verification skipped."
fi

echo
echo "========================================"
echo "Secure Popeye build complete."
echo "========================================"
echo
echo "Image tag:"
echo "${IMAGE}"
echo
echo "Immutable image:"
echo "${IMAGE_DIGEST}"
echo
echo "SBOMs:"
echo "${SBOM_DIR}/popeye-${POPEYE_VERSION}-cyclonedx.json"
echo "${SBOM_DIR}/popeye-${POPEYE_VERSION}-spdx.json"
echo
echo "${VERIFY_STATUS}"