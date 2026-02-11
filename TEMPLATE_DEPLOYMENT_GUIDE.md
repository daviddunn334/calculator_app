# Template Branch Deployment Guide

The `template` branch is excluded from automatic GitHub Actions deployments to prevent conflicts and keep the main project workflow clean. Use these commands to manually deploy the template when needed.

## 📋 Prerequisites

Make sure you have:
- Flutter installed and configured
- Firebase CLI installed (`npm install -g firebase-tools`)
- Firebase logged in (`firebase login`)

## 🚀 Deploy Template to Firebase Hosting

### Step 1: Switch to Template Branch
```bash
git checkout template
```

### Step 2: Pull Latest Changes (if needed)
```bash
git pull origin template
```

### Step 3: Install Dependencies
```bash
flutter pub get
```

### Step 4: Build Web App
```bash
flutter build web
```

### Step 5: Switch to Template Firebase Project
```bash
firebase use template
```
This switches to the `ndt-toolkit-template` Firebase project (configured in `.firebaserc`)

### Step 6: Deploy to Firebase Hosting
```bash
firebase deploy --only hosting
```

### Optional: Deploy All Services
If you also want to deploy Firestore rules, Storage rules, and Cloud Functions:
```bash
firebase deploy
```

---

## 🔄 Quick Deploy Script

Copy and run this complete sequence:

```bash
# Full deployment sequence
git checkout template
git pull origin template
flutter pub get
flutter build web
firebase use template
firebase deploy --only hosting
```

---

## 📝 After Making Changes

When you've made changes to the template and want to push and deploy:

```bash
# 1. Stage and commit changes
git add .
git commit -m "Your commit message describing the changes"

# 2. Push to GitHub
git push origin template

# 3. Build and deploy
flutter build web
firebase use template
firebase deploy --only hosting
```

---

## ✅ Verify Deployment

After deployment, Firebase will provide you with a URL. Check:
- **Console:** https://console.firebase.google.com/project/ndt-toolkit-template/hosting
- **Live URL:** The URL shown in the deploy output (typically: `ndt-toolkit-template.web.app`)

---

## 🔙 Switch Back to Main Project

When you're done working with the template:

```bash
# Switch back to main branch
git checkout main

# Switch back to main Firebase project
firebase use default
```

---

## 📌 Notes

- **Automatic deployments:** Only `main` and `develop` branches deploy automatically via GitHub Actions
- **Template branch:** Always deploy manually to avoid conflicts
- **Firebase projects:** 
  - `default` → integrity-tools (main project)
  - `template` → ndt-toolkit-template (template project)
