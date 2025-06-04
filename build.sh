#!/bin/bash

# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Build for web with release mode
flutter build web --release --web-renderer html

# Deploy to Firebase
firebase deploy --only hosting 