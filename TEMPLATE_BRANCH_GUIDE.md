# TEMPLATE BRANCH SETUP GUIDE

## Overview

The **template** branch is connected to a separate Firebase project (`ndt-toolkit-template`) that serves as an experimental playground, completely isolated from production.

### 📍 **Current Status:**

✅ **COMPLETED:**
- Template branch created and pushed to GitHub
- Firebase project `ndt-toolkit-template` created
- Firebase configuration updated in code
- Firestore Database created with rules and indexes deployed
- Web app deployed to: **https://ndt-toolkit-template.web.app**
- GitHub Actions configured for auto-deploy on push to template branch

⚠️ **PENDING MANUAL SETUP:**
- Enable Firebase Authentication (Email/Password)
- Enable Firebase Storage
- Deploy Cloud Functions (optional)
- Add GitHub secret for CI/CD auto-deploy

---

## 🌐 Three Environments

| Branch | Firebase Project | URL | Purpose |
|--------|-----------------|-----|---------|
| **main** | `integrity-tools` | `integrity-tools.web.app` | Production |
| **develop** | `integrity-tools` | Preview channel | Development/Staging |
| **template** | `ndt-toolkit-template` | `ndt-toolkit-template.web.app` | Experimental Playground |

---

## 🔧 Manual Setup Steps

### 1. Enable Firebase Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select **ndt-toolkit-template** project
3. Navigate to **Build → Authentication**
4. Click **Get started**
5. Select **Email/Password** provider
6. Enable **Email/Password** (first toggle)
7. Click **Save**

### 2. Enable Firebase Storage

1. In Firebase Console, go to **Build → Storage**
2. Click **Get started**
3. Choose **Production mode** (rules are already configured)
4. Select a location (e.g., `us-central1`)
5. Click **Done**
6. After storage is enabled, deploy storage rules:
   ```bash
   git checkout template
   firebase use template
   firebase deploy --only storage
   ```

### 3. Deploy Cloud Functions (Optional)

If you need Cloud Functions for the template environment:

```bash
git checkout template
firebase use template
cd functions
npm install
cd ..
firebase deploy --only functions
```

### 4. Set Up GitHub Secret for Auto-Deploy

To enable automatic deployment when you push to the template branch:

#### Step 1: Generate Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select **ndt-toolkit-template** project
3. Click gear icon → **Project settings**
4. Go to **Service accounts** tab
5. Click **Generate new private key**
6. Save the JSON file securely

#### Step 2: Add to GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings → Secrets and variables → Actions**
3. Click **New repository secret**
4. Name: `FIREBASE_SERVICE_ACCOUNT_NDT_TOOLKIT_TEMPLATE`
5. Value: Paste the entire contents of the JSON file
6. Click **Add secret**

**Result:** Every push to the template branch will now automatically deploy to `ndt-toolkit-template.web.app`

---

## 💻 Local Development Workflow

### Working on Template Branch

```bash
# Switch to template branch
git checkout template

# Make experimental changes
# ... code changes ...

# Commit and push (triggers auto-deploy)
git add .
git commit -m "Experiment: your feature description"
git push origin template

# App automatically deploys to https://ndt-toolkit-template.web.app
```

### Switching Between Firebase Projects Locally

```bash
# Use template project
firebase use template

# Use production project
firebase use default

# Check current project
firebase use
```

### Building and Deploying Manually

```bash
# Ensure you're on template branch
git checkout template

# Switch to template Firebase project
firebase use template

# Build and deploy
flutter build web
firebase deploy --only hosting
```

---

## 🍒 Cherry-Picking Features to Production

When you've successfully tested a feature in the template environment and want to move it to production:

```bash
# 1. Identify the commit hash of your feature
git log --oneline

# 2. Switch to develop branch
git checkout develop

# 3. Cherry-pick the specific commit
git cherry-pick <commit-hash>

# 4. Push to develop (triggers preview deployment)
git push origin develop

# 5. After testing in develop, merge to main
git checkout main
git merge develop
git push origin main  # Deploys to production
```

---

## 🔐 Database Isolation

Each environment has its own isolated:
- ✅ Firestore Database (separate data)
- ✅ Authentication (separate users)
- ✅ Storage (separate files)
- ✅ Analytics (separate tracking)
- ✅ Hosting (separate URLs)

**There is ZERO cross-talk between environments!**

---

## 🎯 Use Cases for Template Branch

### ✅ Good Uses:
- Testing breaking changes
- Experimenting with new features
- Trying major UI/UX redesigns
- Testing third-party integrations
- Learning new Firebase features
- Performance testing without affecting production

### ❌ Avoid:
- Don't merge template→main directly (use cherry-pick instead)
- Don't use for actual production work
- Don't store real customer data here
- Don't share template URL with end users

---

## 📊 Monitoring & Analytics

Each environment has separate analytics:

- **Production:** Track real user behavior
- **Template:** Track experimental features and tests

View analytics in Firebase Console:
- Production: Select `integrity-tools` project
- Template: Select `ndt-toolkit-template` project

---

## 🐛 Troubleshooting

### Issue: Changes don't appear after deployment

**Solution:** Clear browser cache or open in incognito mode.

### Issue: Authentication not working in template

**Solution:** Ensure you've enabled Email/Password authentication in Firebase Console for ndt-toolkit-template project.

### Issue: Storage uploads failing

**Solution:** Enable Storage in Firebase Console and deploy storage rules:
```bash
firebase use template
firebase deploy --only storage
```

### Issue: Auto-deploy not working

**Solution:** 
1. Verify GitHub secret `FIREBASE_SERVICE_ACCOUNT_NDT_TOOLKIT_TEMPLATE` is added
2. Check GitHub Actions tab for error logs
3. Ensure the secret JSON is valid

### Issue: "Project not found" error

**Solution:** Make sure you're using the correct project:
```bash
firebase use template  # For template work
firebase use default   # For production work
```

---

## 🔄 Switching Back to Main Branch

When done experimenting and want to return to production work:

```bash
# Switch to main branch
git checkout main

# Switch to production Firebase project
firebase use default

# Verify you're on the right setup
git branch  # Should show * main
firebase use  # Should show integrity-tools
```

---

## 📝 Important Notes

1. **Branch Independence:** Template branch configuration changes (firebase_options.dart, .firebaserc, etc.) do NOT affect main or develop branches
2. **Production Safety:** All changes in template are isolated—production is 100% safe
3. **GitHub Actions:** The CI/CD workflow automatically detects which branch you're pushing to and deploys to the correct Firebase project
4. **Cost Management:** Template environment uses the same Firebase pricing tier. Monitor usage in Firebase Console

---

## 🚀 Quick Reference Commands

```bash
# View all Firebase projects
firebase projects:list

# Switch projects
firebase use default   # integrity-tools (production)
firebase use template  # ndt-toolkit-template (experimental)

# View current project
firebase use

# Build and deploy
flutter build web
firebase deploy --only hosting

# Deploy specific services
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only storage
firebase deploy --only functions

# Check which branch you're on
git branch

# Check Git status
git status
```

---

## 📞 Support

If you encounter issues:
1. Check this guide first
2. Review Firebase Console error logs
3. Check GitHub Actions logs for CI/CD issues
4. Verify Firebase services are enabled in console

---

**Happy Experimenting! 🎉**

The template branch is your safe space to try new things without any risk to production!
