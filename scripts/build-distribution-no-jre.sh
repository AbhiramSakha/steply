#!/usr/bin/env bash
# Build a distribution zip WITHOUT a bundled JRE (suitable for CI / systems with Java pre-installed).
# Usage: ./build-distribution-no-jre.sh [output-dir]
# Example: ./build-distribution-no-jre.sh /tmp/steply-dist-nojre

set -euo pipefail

OUTDIR=${1:-./dist-nojre}

rm -rf "$OUTDIR"
mkdir -p "$OUTDIR/lib" "$OUTDIR/bin" "$OUTDIR/config" "$OUTDIR/example"

# Ensure CLI jar exists (built as jar-with-dependencies)
CLI_JAR=$(ls steply-cli/target/*-jar-with-dependencies.jar 2>/dev/null || true)
if [ -z "$CLI_JAR" ]; then
  echo "Error: CLI jar-with-dependencies not found. Build it first with:"
  echo "  mvn -pl steply-cli -am package -DskipTests"
  exit 1
fi

echo "Copying CLI jar to lib/"
cp -v "$CLI_JAR" "$OUTDIR/lib/"

cp -r config/* "$OUTDIR/config/" || true
cp -r example/* "$OUTDIR/example/" || true
cp -r scripts/* "$OUTDIR/bin/"
chmod +x "$OUTDIR/bin/"*.sh || true

cp LICENSE README.md VERSION.txt "$OUTDIR/" || true

ZIPNAME="steply-$(head -n1 VERSION.txt | sed 's/steply.version=//')-no-jre.zip"
cd "$OUTDIR/.."
zip -r "$ZIPNAME" "$(basename "$OUTDIR")"
shasum -a 256 "$ZIPNAME" > "$ZIPNAME".sha256
echo "Distribution created: $(pwd)/$ZIPNAME"
