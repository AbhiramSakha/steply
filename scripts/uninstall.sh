#!/usr/bin/env bash
set -euo pipefail

INSTALL_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/steply"
BIN_DIR="$HOME/.local/bin"
LAUNCHER="${BIN_DIR}/steply"

echo "Uninstalling Steply..."

if [[ -f "${LAUNCHER}" ]]; then
  rm -f "${LAUNCHER}"
  echo "Removed launcher: ${LAUNCHER}"
else
  echo "Launcher not found (already removed?): ${LAUNCHER}"
fi

if [[ -d "${INSTALL_ROOT}" ]]; then
  rm -rf "${INSTALL_ROOT}"
  echo "Removed install directory: ${INSTALL_ROOT}"
else
  echo "Install directory not found (already removed?): ${INSTALL_ROOT}"
fi

echo
echo "Steply has been uninstalled."
echo "If you added \$HOME/.local/bin to your PATH in ~/.zshrc or ~/.bashrc, you can remove that line manually."
