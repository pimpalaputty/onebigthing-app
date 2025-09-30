# Vercel Deployment Guide - One Big Thing App

## 🚀 Deployment Options

### Option 1: Vercel CLI (Recommended)

1. **Install Vercel CLI:**
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel:**
   ```bash
   vercel login
   ```

3. **Deploy:**
   ```bash
   vercel --prod
   ```

### Option 2: GitHub Integration

1. Push your code to GitHub
2. Go to [vercel.com](https://vercel.com)
3. Import your GitHub repository
4. Vercel will automatically detect the Flutter project

## 🔧 Environment Variables

Set these in your Vercel dashboard (Project Settings > Environment Variables):

```
SUPABASE_URL=https://ptqhermvrvycspucgztb.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0cWhlcm12cnZ5Y3NwdWNnenRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyNTc3MjYsImV4cCI6MjA3NDgzMzcyNn0.WldxvPwACjSZKfxlXBsgIa9jQB8CC9bAcV8kW-gHW-k
GOOGLE_CLIENT_ID=529923259303-6ac2151j0an5dur0j37976679vj647q3.apps.googleusercontent.com
```

## 📁 Project Structure

```
onebigthing_app/
├── vercel.json          # Vercel configuration
├── package.json         # Node.js package info
├── .vercelignore        # Files to ignore during deployment
├── deploy.sh           # Deployment script
└── build/web/          # Flutter web build output
```

## 🛠️ Build Configuration

The `vercel.json` file configures:
- Build command: `flutter build web --release`
- Output directory: `build/web`
- Install command: `flutter pub get`
- Caching headers for optimal performance

## 🔄 Automatic Deployments

Once connected to GitHub:
- Every push to `main` branch triggers production deployment
- Pull requests create preview deployments
- Build logs are available in Vercel dashboard

## 🐛 Troubleshooting

### Build Failures
- Check Flutter version compatibility
- Ensure all dependencies are in `pubspec.yaml`
- Verify environment variables are set

### Runtime Issues
- Check browser console for errors
- Verify Supabase connection
- Test Google OAuth configuration

## 📊 Performance

The app is optimized with:
- Tree-shaking for smaller bundle size
- Static asset caching
- Gzip compression (automatic on Vercel)

## 🔒 Security

- Environment variables are encrypted
- HTTPS is enforced automatically
- CORS is configured for Supabase

## 📱 PWA Features

The app includes:
- Service worker for offline functionality
- App manifest for installability
- Responsive design for mobile devices
