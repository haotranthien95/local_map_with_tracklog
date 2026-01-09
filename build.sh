#!/bin/bash

# Read current version from pubspec.yaml
current_version=$(grep "^version:" pubspec.yaml | sed 's/version: //')

# Extract version name and code (format: x.y.z+code)
version_name=$(echo $current_version | cut -d'+' -f1)
version_code=$(echo $current_version | cut -d'+' -f2)

# Increment version code
new_version_code=$((version_code + 1))

# Update pubspec.yaml
sed -i '' "s/^version: .*/version: ${version_name}+${new_version_code}/" pubspec.yaml

echo "Version updated: ${version_name}+${version_code} -> ${version_name}+${new_version_code}"

# Build iOS app
flutter build ipa --split-debug-info --obfuscate