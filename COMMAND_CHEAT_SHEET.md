# 🚀 COMMAND CHEAT SHEET

Quick reference for the most commonly used commands in this project.

---

## 📱 **Local Development**

```bash
# Run app in Chrome
flutter run -d chrome

# Build for production
flutter build web

# Clean and rebuild
flutter clean && flutter build web

# Install/update dependencies
flutter pub get
```

---

## 🔥 **Firebase**

### Switch Projects
```bash
firebase use default    # Production (integrity-tools)
firebase use template   # Template (ndt-toolkit-template)
firebase use           # Show current project
```

### Deploy
```bash
firebase deploy --only hosting              # Deploy web app
firebase deploy --only firestore:rules      # Deploy Firestore rules
firebase deploy --only firestore:indexes    # Deploy Firestore indexes
firebase deploy --only storage              # Deploy Storage rules
firebase deploy --only functions            # Deploy Cloud Functions
firebase deploy                             # Deploy everything
```

---

## 🌿 **Git**

### Branch Management
```bash
git checkout main       # Switch to production
git checkout develop    # Switch to development
git checkout template   # Switch to experimental

git branch             # Show current branch
git status             # Show changes
```

### Commit & Push
```bash
git add .                              # Stage all changes
git commit -m "Your message"           # Commit changes
git push origin branch-name            # Push to remote
```

### Pull Latest Changes
```bash
git pull origin main       # Update from production
git pull origin develop    # Update from develop
git pull origin template   # Update from template
```

---

## 🔄 **Common Workflows**

### **1. Quick Local Test**
```bash
flutter run -d chrome
```

### **2. Deploy to Production**
```bash
git checkout main
flutter build web
firebase use default
firebase deploy --only hosting
git add .
git commit -m "Deploy update"
git push origin main
```

### **3. Update Firestore Rules**
```bash
# Edit firestore.rules file, then:
firebase use default
firebase deploy --only firestore:rules
git add firestore.rules
git commit -m "Update Firestore rules"
git push origin main
```

### **4. Work on Template Branch**
```bash
git checkout template
firebase use template
# Make changes
flutter build web
firebase deploy --only hosting
git add .
git commit -m "Experiment: feature name"
git push origin template
```

### **5. Cherry-Pick from Template to Production**
```bash
# On template branch:
git log --oneline    # Find commit hash

# Switch to develop:
git checkout develop
git cherry-pick abc123   # Use actual commit hash

# Test, then push:
git push origin develop

# Merge to main:
git checkout main
git merge develop
git push origin main
```

---

## ⚡ **Before You Start Working**

```bash
# 1. Check where you are
git branch          # Check Git branch
firebase use        # Check Firebase project

# 2. Update code
git pull origin branch-name

# 3. Update dependencies
flutter pub get
```

---

## 🛑 **Before You Deploy**

```bash
# 1. Test locally
flutter run -d chrome

# 2. Check what changed
git status
git diff

# 3. Make sure you're deploying to correct project
firebase use
```

---

## 🔍 **Inspection**

```bash
git status                  # Show uncommitted changes
git log --oneline          # Show commit history
git diff                   # Show file changes
firebase projects:list     # Show all Firebase projects
flutter doctor             # Check Flutter setup
```

---

## 🆘 **Troubleshooting**

```bash
flutter clean              # Clear build cache
flutter pub cache repair   # Fix dependency issues
flutter doctor -v          # Detailed Flutter diagnostics
```

---

## 📋 **Environment Quick Check**

| What | Production | Template |
|------|-----------|----------|
| **Git Branch** | `main` | `template` |
| **Firebase Project** | `default` (integrity-tools) | `template` (ndt-toolkit-template) |
| **URL** | integrity-tools.web.app | ndt-toolkit-template.web.app |
| **Check Command** | `git branch` / `firebase use` | `git branch` / `firebase use` |

---

## 💡 **Pro Tips**

1. **Always verify before deploying:**
   ```bash
   git branch      # Check Git branch
   firebase use    # Check Firebase project
   ```

2. **Most common daily workflow:**
   ```bash
   git pull origin main
   flutter pub get
   flutter run -d chrome
   # Make changes
   flutter build web
   firebase deploy --only hosting
   git add .
   git commit -m "Update"
   git push origin main
   ```

3. **Safe experimentation:**
   - Use `template` branch for experiments
   - Use `develop` for feature development
   - Use `main` only for production-ready code

---

## 🎯 **Most Used Commands (Top 10)**

1. `flutter run -d chrome` - Run locally
2. `git status` - Check changes
3. `git checkout branch-name` - Switch branches
4. `firebase use` - Check/switch Firebase project
5. `flutter build web` - Build for production
6. `firebase deploy --only hosting` - Deploy web app
7. `git add .` - Stage changes
8. `git commit -m "message"` - Commit changes
9. `git push origin branch-name` - Push to remote
10. `firebase deploy --only firestore:rules` - Update database rules

---

**📖 For detailed commands, see the full documentation in TEMPLATE_BRANCH_GUIDE.md**
