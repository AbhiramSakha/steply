#!/usr/bin/env bash
# Builds and installs Steply from your local source tree.
# No GitHub download. Uses system/sdkman Java (no bundled JRE).
# (Occasionally needed to run sanity tests from IDE/terminal)
#
# Usage (run from repo root):
#   ./scripts/install-local.sh
#
# After install, the `steply` command on your PATH will use this local build.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL_DIR="${HOME}/.local/share/steply/local"
BIN_DIR="${HOME}/.local/bin"
LAUNCHER="${BIN_DIR}/steply"

# ── 1. Build ────────────────────────────────────────────────────────────────
echo "==> Building from source..."
cd "${REPO_ROOT}"
mvn clean package -DskipTests -q

# ── 2. Locate the fat jar ───────────────────────────────────────────────────
CLI_JAR=$(ls steply-cli/target/*-jar-with-dependencies.jar 2>/dev/null | head -1 || true)
if [[ -z "${CLI_JAR}" ]]; then
  echo "ERROR: jar-with-dependencies not found after build."
  exit 1
fi

# ── 3. Assemble dist folder ─────────────────────────────────────────────────
echo "==> Assembling dist in ${INSTALL_DIR}..."
rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}/lib" "${INSTALL_DIR}/bin" "${INSTALL_DIR}/config" "${INSTALL_DIR}/example"

cp "${CLI_JAR}" "${INSTALL_DIR}/lib/"
cp -r config/*   "${INSTALL_DIR}/config/"  2>/dev/null || true
cp -r example/*  "${INSTALL_DIR}/example/" 2>/dev/null || true
cp scripts/steply.sh "${INSTALL_DIR}/bin/steply.sh"
chmod +x "${INSTALL_DIR}/bin/steply.sh"
cp LICENSE README.md VERSION.txt "${INSTALL_DIR}/" 2>/dev/null || true

# ── 4. Update the launcher ───────────────────────────────────────────────────
mkdir -p "${BIN_DIR}"
cat > "${LAUNCHER}" <<EOF
#!/usr/bin/env bash
exec "${INSTALL_DIR}/bin/steply.sh" "\$@"
EOF
chmod +x "${LAUNCHER}"

# ── 5. Done ──────────────────────────────────────────────────────────────────
VERSION=$(head -n1 "${REPO_ROOT}/VERSION.txt" | sed 's/steply.version=//' 2>/dev/null || echo "unknown")
echo
echo "Installed Steply ${VERSION} (local build)."
echo "Install dir : ${INSTALL_DIR}"
echo "Binary      : ${LAUNCHER}"
echo

if ! echo ":${PATH}:" | grep -q ":${BIN_DIR}:"; then
  echo "NOTE: ${BIN_DIR} is not on your PATH."
  echo "Add this to your ~/.zshrc (or ~/.bashrc):"
  echo "  export PATH=\"${BIN_DIR}:\$PATH\""
  echo
fi

echo "Try:"
echo "  steply -v"
