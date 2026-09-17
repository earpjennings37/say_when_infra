#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================"
echo "Building secure Popeye ARM64 image"
echo "======================================"
"${SCRIPT_DIR}/build-secure-popeye.sh"

echo
echo "======================================"
echo "Building secure Kepler ARM64 image"
echo "======================================"
"${SCRIPT_DIR}/build-secure-kepler.sh"

echo
echo "All custom ARM64 images completed."