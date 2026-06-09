#!/bin/sh
set -e

echo "=== ci_post_clone.sh starting ==="
echo "macOS: $(sw_vers -productVersion)"
echo "Xcode: $(xcodebuild -version | head -1)"
echo "Ruby: $(ruby --version)"
echo "Homebrew: $(brew --version | head -1)"

# ── Install Flutter ────────────────────────────────────────────────────────
FLUTTER_DIR="$HOME/flutter"
if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Cloning Flutter stable..."
  git clone https://github.com/flutter/flutter.git \
    --depth 1 -b stable "$FLUTTER_DIR"
else
  echo "Flutter already cloned."
fi

export PATH="$PATH:$FLUTTER_DIR/bin"
flutter --version

# ── Flutter dependencies ───────────────────────────────────────────────────
echo "Running flutter pub get..."
cd "$CI_PRIMARY_REPOSITORY_PATH/app"
flutter pub get

# Confirm Generated.xcconfig was created (pod install depends on it)
XCCONFIG="$CI_PRIMARY_REPOSITORY_PATH/app/ios/Flutter/Generated.xcconfig"
if [ ! -f "$XCCONFIG" ]; then
  echo "ERROR: Generated.xcconfig not found after flutter pub get"
  exit 1
fi
echo "Generated.xcconfig OK"

# ── Precache iOS engine artifacts (required before pod install) ────────────
echo "Running flutter precache --ios..."
flutter precache --ios

# ── CocoaPods ─────────────────────────────────────────────────────────────
echo "Installing CocoaPods via Homebrew..."
if command -v pod &>/dev/null; then
  echo "pod already available: $(pod --version)"
else
  brew install cocoapods
fi

pod --version

echo "Running pod install (full output follows)..."
cd "$CI_PRIMARY_REPOSITORY_PATH/app/ios"
pod install --repo-update 2>&1

# ── GoogleService-Info.plist ───────────────────────────────────────────────
echo "Writing GoogleService-Info.plist..."
if [ -z "$GOOGLE_SERVICE_INFO_PLIST" ]; then
  echo "ERROR: GOOGLE_SERVICE_INFO_PLIST secret is not set in Xcode Cloud environment."
  exit 1
fi
echo "$GOOGLE_SERVICE_INFO_PLIST" | base64 --decode \
  > "$CI_PRIMARY_REPOSITORY_PATH/app/ios/Runner/GoogleService-Info.plist"
echo "GoogleService-Info.plist written OK"

echo "=== ci_post_clone.sh complete ==="
