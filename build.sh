#!/bin/bash
echo "Cleaning previous builds..."
flutter clean

echo "Getting dependencies..."
dart pub get

echo "Building project..."
dart build build_runner build --delete-conflicting-outputs

# 1. Kompilasi Drift Web Worker
echo "Compiling drift_worker.dart to root..."
dart compile js -o web/drift_worker.dart.js drift_worker.dart

# Cek apakah kompilasi worker berhasil
if [ $? -ne 0 ]; then
    echo "ERROR: Drift worker compilation failed."
    exit 1
fi

echo "Compiling drift_worker.dart to root/web..."
dart compile js -o drift_worker.dart.js drift_worker.dart

# Cek apakah kompilasi worker berhasil
if [ $? -ne 0 ]; then
    echo "ERROR: Drift worker compilation failed."
    exit 1
fi