#!/bin/sh
set -e

echo "=== ci_post_clone.sh starting ==="

# ── Install Flutter ────────────────────────────────────────────────────────
FLUTTER_DIR="$HOME/flutter"
if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Cloning Flutter stable..."
  git clone https://github.com/flutter/flutter.git \
    --depth 1 -b stable "$FLUTTER_DIR"
fi

export PATH="$PATH:$FLUTTER_DIR/bin"
flutter --version

# ── Flutter dependencies ────────────────────────────────────────────────────
echo "Running flutter pub get..."
cd "$CI_PRIMARY_REPOSITORY_PATH/app"
flutter pub get

# ── CocoaPods ──────────────────────────────────────────────────────────────
echo "Installing CocoaPods gems if needed..."
# Xcode Cloud uses system Ruby; install pods to user gem dir
export GEM_HOME="$HOME/.gem"
export PATH="$PATH:$GEM_HOME/bin"

if ! command -v pod &>/dev/null; then
  echo "pod not found, installing..."
  gem install cocoapods --user-install --no-document
fi

pod --version

echo "Running pod install..."
cd "$CI_PRIMARY_REPOSITORY_PATH/app/ios"
pod install --repo-update

echo "=== ci_post_clone.sh complete ==="
