#!/bin/bash
echo "Cleaning previous builds..."
flutter clean

echo "Getting dependencies..."
dart pub get

echo "Building project..."
dart run build_runner build --delete-conflicting-outputs

# 1. Kompilasi Drift Web Worker
echo "Compiling drift_worker.dart to root..."
dart compile js -o web/drift_worker.dart.js drift_worker.dart

# Cek apakah kompilasi worker berhasil
if [ $? -ne 0 ]; then
    echo "ERROR: Drift worker compilation failed."
    exit 1
fi

# 2. Tambah .env
echo "Generating .env from .env.example..."
cp .env.example .env

echo "Compiling drift_worker.dart to root/web..."
dart compile js -o drift_worker.dart.js drift_worker.dart

# Cek apakah kompilasi worker berhasil
if [ $? -ne 0 ]; then
    echo "ERROR: Drift worker compilation failed."
    exit 1
fi