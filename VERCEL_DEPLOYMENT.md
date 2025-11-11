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
4. Keep the default framework preset (Other) so Vercel runs `npm run build`

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
├── scripts/
│   └── vercel_build.sh  # Installs Flutter and builds the web bundle
├── deploy.sh            # Manual deployment helper
└── public/              # Final Flutter web assets Vercel serves
```

## 🛠️ Build Configuration

The `vercel.json` file configures:
- SPA routing so every path serves `index.html`
- No custom build or install commands (handled in `package.json`)
- Additional rewrites can be added here if needed

### 🧱 Build Workflow

Vercel runs the Node build command from `package.json`:

```bash
npm run build
```

That delegates to `scripts/vercel_build.sh`, which:
- Downloads the Flutter SDK (override with `FLUTTER_VERSION` env var if required)
- Runs `flutter pub get` and builds the web bundle
- Copies `build/web/` into the repo’s `public/` folder for Vercel to deploy

> Tip: If you already have a local `flutter build web` output, run `npm run build` locally so the same script is exercised before pushing.

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
- Confirm Vercel can download the Flutter SDK (retry or pin `FLUTTER_VERSION` if a release is unavailable)

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
