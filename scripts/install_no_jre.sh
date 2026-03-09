#!/usr/bin/env bash
# Installs Steply without a bundled JRE.
# Requires Java 17+ to be available on the PATH.
# Intended for CI environments (e.g. GitHub Actions or GitLab Pipeline).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/QABEES/steply/main/scripts/install_no_jre.sh | bash

set -euo pipefail

RELEASE_TAG="0.1.0-20260109"
ZIP_NAME="steply-0.1.0-no-jre-20260309.zip"
ZIP_URL="https://github.com/QABEES/steply/releases/download/${RELEASE_TAG}/${ZIP_NAME}"

INSTALL_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/steply"
INSTALL_DIR="${INSTALL_ROOT}/${RELEASE_TAG}"
BIN_DIR="$HOME/.local/bin"
LAUNCHER="${BIN_DIR}/steply"

# Verify Java is available
if ! command -v java &>/dev/null; then
  echo "ERROR: Java not found on PATH. Please install Java 17+ before running this script."
  exit 1
fi

mkdir -p "${INSTALL_DIR}" "${BIN_DIR}"

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

echo "Downloading: ${ZIP_URL}"
curl -fsSL "${ZIP_URL}" -o "${TMP_DIR}/${ZIP_NAME}"

echo "Installing to: ${INSTALL_DIR}"
rm -rf "${INSTALL_DIR:?}/"*
unzip -q "${TMP_DIR}/${ZIP_NAME}" -d "${INSTALL_DIR}"

# The zip expands into a top-level directory. No need to hard code "steply-dist" dir
DIST_DIR=$(find "${INSTALL_DIR}" -mindepth 1 -maxdepth 1 -type d | head -n1)
STEPLY_SH="${DIST_DIR}/bin/steply.sh"

if [[ ! -f "${STEPLY_SH}" ]]; then
  echo "ERROR: Expected ${STEPLY_SH} to exist after unzip, but it was not found."
  echo "Please check the zip layout: ${ZIP_URL}"
  exit 1
fi

chmod +x "${STEPLY_SH}"

# Create a user-local launcher on PATH
cat > "${LAUNCHER}" <<EOF
#!/usr/bin/env bash
exec "${STEPLY_SH}" "\$@"
EOF
chmod +x "${LAUNCHER}"

echo
echo "Installed Steply (no-JRE) ${RELEASE_TAG}."
echo "Install dir: ${DIST_DIR}"
echo "Binary: ${LAUNCHER}"
echo

if ! echo ":$PATH:" | grep -q ":${BIN_DIR}:"; then
  echo "NOTE: ${BIN_DIR} is not on your PATH."
  echo "Add this to your shell profile or CI step:"
  echo "  export PATH=\"${BIN_DIR}:\$PATH\""
  echo
fi

echo "Try:"
echo "  steply -v"
