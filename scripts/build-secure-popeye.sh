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
# Confirm ECR repository exists
# --------------------------------------------------

echo "[1/7] Checking ECR repository..."

aws ecr describe-repositories \
  --repository-names "${REPOSITORY_NAME}" \
  --region "${AWS_REGION}" \
  >/dev/null

# --------------------------------------------------
# Authenticate Docker to ECR
# --------------------------------------------------

echo "[2/7] Logging into ECR..."

aws ecr get-login-password \
  --region "${AWS_REGION}" \
  | docker login \
      --username AWS \
      --password-stdin \
      "${ECR_REGISTRY}"

# --------------------------------------------------
# Build + push ARM64 image
# --------------------------------------------------

echo "[3/7] Building and pushing ARM64 Popeye image..."

docker buildx build \
  --platform linux/arm64 \
  -t "${IMAGE}" \
  --push \
  "${REPO_ROOT}/images/popeye"

# --------------------------------------------------
# Resolve immutable image digest
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

# --------------------------------------------------
# Generate SBOMs
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

# --------------------------------------------------
# Sign image
# --------------------------------------------------

echo "[6/7] Signing image with Cosign..."
echo "You may be prompted to authenticate with your OIDC provider."

cosign sign "${IMAGE_DIGEST}"

# --------------------------------------------------
# Verification
# --------------------------------------------------

echo "[7/7] Signature created."
echo
echo "Image:"
echo "${IMAGE_DIGEST}"
echo
echo "To perform strict verification, run:"
echo
echo "cosign verify '${IMAGE_DIGEST}' \\"
echo "  --certificate-identity='YOUR_IDENTITY' \\"
echo "  --certificate-oidc-issuer='YOUR_OIDC_ISSUER'"
echo
echo "Secure Popeye build complete."