#!/bin/sh

# Xcode Cloud CI post-clone script
# Installs Flutter and dependencies before the build starts.

set -e

# Install Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Get dependencies
cd $CI_PRIMARY_REPOSITORY_PATH/app
flutter pub get

# Install CocoaPods dependencies
cd ios
pod install

echo "ci_post_clone.sh completed successfully"
