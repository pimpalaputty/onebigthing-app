#!/bin/bash

# Flutter Web App Vercel Deployment Script

echo "🚀 Starting deployment to Vercel..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🔨 Building Flutter web app..."
flutter build web --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"

    # Copy build files to public directory for Vercel
    echo "📦 Copying build files to public directory..."
    rm -rf public/*
    cp -r build/web/* public/
    echo "✅ Files copied to public/"

    echo ""
    echo "🌐 To deploy to Vercel:"
    echo "1. Install Vercel CLI: npm i -g vercel"
    echo "2. Run: vercel --prod"
    echo "3. Or use: npm run deploy"
    echo "4. Or connect your GitHub repo to Vercel dashboard"
    echo ""
    echo "📋 Environment variables needed in Vercel:"
    echo "- SUPABASE_URL: https://ptqhermvrvycspucgztb.supabase.co"
    echo "- SUPABASE_ANON_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0cWhlcm12cnZ5Y3NwdWNnenRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyNTc3MjYsImV4cCI6MjA3NDgzMzcyNn0.WldxvPwACjSZKfxlXBsgIa9jQB8CC9bAcV8kW-gHW-k"
    echo "- GOOGLE_CLIENT_ID: 1020627864569-q2iuillmfb43d5o3pt1ao1mt01o018it.apps.googleusercontent.com"
else
    echo "❌ Build failed!"
    exit 1
fi
