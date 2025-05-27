#!/bin/bash

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Install Flutter dependencies
flutter doctor
flutter pub get

# Build the web app
flutter build web

# Move the build output to the correct location
cp -r build/web/* . 