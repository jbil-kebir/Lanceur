#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
SOURCES_DIR="$PROJECT_ROOT/sources"
NAS_PATH="/Volumes/Kebir/Info-Developpement/GitHub/Sesame"

# Extraire la version depuis pubspec.yaml
VERSION=$(grep "^version:" "$SOURCES_DIR/pubspec.yaml" | sed 's/version: //' | sed 's/+.*//')

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  Sesame $VERSION — Publication iOS     "
echo "╚══════════════════════════════════════╝"
echo ""

# 1. Vérifier que le NAS est monté
if [ ! -d "$NAS_PATH" ]; then
  echo "❌ NAS introuvable : $NAS_PATH"
  echo "   Montez le NAS puis relancez le script."
  exit 1
fi

# 2. Build iOS
echo "▶ Build Flutter iOS..."
cd "$SOURCES_DIR"
flutter build ios --release --no-codesign
echo "✓ Build terminé"
echo ""

# 3. Synchronisation vers le NAS
echo "▶ Synchronisation NAS..."
rsync -a --delete \
  --exclude='.git' \
  --exclude='build/' \
  --exclude='.dart_tool/' \
  --exclude='.flutter-plugins-dependencies' \
  --exclude='.flutter-plugins' \
  --exclude='*.iml' \
  --exclude='ios/Pods/' \
  --exclude='ios/.symlinks/' \
  --exclude='ios/Flutter/Generated.xcconfig' \
  --exclude='ios/Flutter/flutter_export_environment.sh' \
  --exclude='ios/Flutter/ephemeral/' \
  "$PROJECT_ROOT/" "$NAS_PATH/"
echo "✓ NAS synchronisé"
echo ""

# 4. Git commit + push
echo "▶ Git commit & push..."
cd "$PROJECT_ROOT"
git add -A
git commit -m "v$VERSION — build iOS"
git push
echo "✓ GitHub mis à jour"
echo ""

echo "✅ Publication terminée — v$VERSION"
echo ""
