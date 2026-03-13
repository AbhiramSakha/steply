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

for PROFILE in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [[ -f "$PROFILE" ]] && grep -qF "${BIN_DIR}" "$PROFILE"; then
    sed -i "\|# Added by Steply installer|d" "$PROFILE"
    sed -i "\|${BIN_DIR}|d" "$PROFILE"
    echo "Removed ${BIN_DIR} from PATH in ${PROFILE}."
  fi
done

echo
echo "Steply has been uninstalled."
