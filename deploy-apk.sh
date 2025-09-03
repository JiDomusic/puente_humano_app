#!/bin/bash

# Build release APK
echo "Building release APK..."
flutter build apk --release

# Deploy to Firebase App Distribution
echo "Deploying to Firebase App Distribution..."
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
    --app 1:YOUR_PROJECT_ID:android:YOUR_APP_ID \
    --release-notes "Nueva versión con actualizaciones de agosto 2025" \
    --testers "tu-email@gmail.com"

echo "Deploy completed!"