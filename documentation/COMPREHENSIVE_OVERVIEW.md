# INTEGRITY TOOLS APP - COMPREHENSIVE OVERVIEW

**Important Rules:**
- Do not commit or push anything to any branch until instructed
- Let the programmer do all testing/running of the app
- Always bump versions (service-worker.js + pubspec.yaml) before deployment
- Use internal state management in MainScreen, NOT Navigator.pushNamed()
- Update firestore.rules when adding Firestore collections
- Add analytics tracking for new user features
- Test on both mobile and desktop layouts
- Ensure calculator tools work offline
- Follow existing file organization structure

## App Identity

- **Name:** Integrity Tools
- **Company:** Integrity Specialists
- **Tagline:** "Our people are trained to be the difference."
- **Purpose:** Mobile and web toolkit for pipeline inspection professionals (NDT)
- **Platform:** Flutter (iOS, Android, Web)
- **Backend:** Firebase (Firestore, Auth, Storage, Functions, Analytics)
- **Colors:** Navy Blue (#1b325b), Gold (#fbcd0f)
- **Package:** com.integrityspecialists.app
- **Project:** integrity-tools

## Tech Stack

- Flutter SDK 3.0+
- Firebase (Core, Auth, Firestore, Storage, Analytics, Functions)
- Syncfusion PDF libraries
- Excel package for spreadsheets
- Connectivity Plus for offline detection
- Image Picker & File Picker
- URL Launcher for contact actions

## Project Structure

```
lib/
├── calculators/    # Offline-capable calculation tools
├── models/         # Data models
├── screens/        # UI screens
├── services/       # Business logic (Auth, Firestore, PDF, Analytics)
├── theme/          # AppTheme with brand colors
├── widgets/        # Reusable UI components
└── utils/          # Helper utilities
```

## Key Features Overview

### 1. Authentication & User Management
- Firebase email/password authentication
- Role-based access (users vs admins)
- Email verification (mandatory for new signups, grandfathered existing users)
- Password reset functionality
- User profiles in Firestore `/users/{userId}`

### 2. NDT Calculator Tools (Two-Tier System)

**Most Used Tools (Index 1)** - 8 frequently used calculators:
- ABS + ES Calculator
- Pit Depth Calculator
- Time Clock Calculator
- Dent Ovality Calculator
- B31G Calculator
- Corrosion Grid Logger
- PDF to Excel Converter
- Depth Percentages Calculator

**NDT Tools (Index 2)** - 13 category folders:
1. **Beam Geometry** - Trig Beam Path, Skip Distance Table
2. **Snell's Law Suite** - Snell's Law Calculator, Mode Conversion Calculator, Critical Angle Calculator
3. Array Geometry
4. Focal Law Tools
5. Advanced
6. Amplitude / dB Tools
7. Magnetic Particle
8. Liquid Penetrant
9. Radiography
10. Materials & Metallurgy
11. Pipeline-Specific
12. Geometry & Math Reference
13. Code & Standard Reference

All calculators are **fully offline-capable**.

### 3. AI-Powered Defect Analysis

**Defect AI Analyzer (Index 12):**
- Log pipeline defects with measurements (OD, NWT, L, W, D)
- Client-specific procedure analysis
- Gemini 2.5 Flash AI integration
- Vertex AI context caching (18x faster, 73-95% cost reduction)
- Real-time analysis with status tracking
- Automatic cache invalidation on PDF changes

**Defect AI Identifier (Index 13):**
- Photo-based defect identification
- Gemini Vision API integration
- Top 3 matches with confidence levels
- Asynchronous processing with history
- Web and mobile compatible

### 4. Core Business Features
- **Inspection Reports:** Create/view/edit reports with images
- **Method Hours Tracking:** Log work hours, export to Excel (server-side)
- **Job Locations:** Hierarchical (Divisions → Projects → Digs) + Personal locations
- **Knowledge Base:** NDT procedures, defect types, formulas, safety
- **Company Directory:** Employee roster with clickable contacts
- **News & Updates:** Admin-managed content with categories

### 5. Admin Dashboard
- User management
- News management
- PDF/procedure management
- Employee directory management
- Feedback management
- Analytics and reports

### 6. Additional Features
- Firebase Analytics tracking (comprehensive event logging)
- Firebase Performance Monitoring
- User onboarding flow (6-screen tour)
- PWA with install prompts and auto-updates
- Terms of Service & Privacy Policy system
- Certifications tracking
- Inventory management
- Offline functionality with service worker

## Navigation Structure (MainScreen Indexes)

- 0: Home
- 1: Most Used Tools ⭐
- 2: NDT Tools (category folders)
- 3: Maps
- 4: Method Hours
- 5: Knowledge Base
- 6: Profile
- 7: Inventory
- 8: Company Directory
- 9: News & Updates
- 10: Equotip Data Converter
- 11: Send Feedback
- 12: Defect AI Analyzer
- 13: Defect AI Identifier

## Database Structure (Firestore)

**Main Collections:**
- `/users/{userId}` - User profiles (isAdmin, hasCompletedOnboarding, termsAcceptedAt)
- `/reports/{reportId}` - Inspection reports
- `/method_hours/{entryId}` - Method hours entries
- `/news_updates/{updateId}` - News posts
- `/defect_types/{typeId}` - Configurable defect types
- `/defect_entries/{entryId}` - Defect logs with AI analysis
- `/photo_identifications/{photoId}` - Photo defect identifications
- `/procedure_caches/{clientName}` - Vertex AI cache metadata
- `/defect_identifier_cache/defectidentifiertool` - Singleton cache for photo ID
- `/feedback/{feedbackId}` - User feedback submissions
- `/directory/{employeeId}` - Company employee directory
- `/divisions/{divId}/projects/{projId}/digs/{digId}` - Job locations

**Security Rules:**
- Users read/write their own data
- Admins have elevated permissions
- Cloud Functions can update AI analysis fields

## Key Services & Utilities

**Services:**
- `AnalyticsService` - Firebase Analytics wrapper (singleton)
- `PerformanceService` - Performance monitoring
- `AuthService` - Authentication + email verification
- `DefectService` - Defect CRUD + AI analysis
- `DefectIdentifierService` - Photo upload + identification
- `OnboardingService` - Tour management
- `UpdateService` - PWA update detection

**Utilities:**
- `ContactHelper` - Phone/email/SMS launchers
- `UrlHelper` - External link handlers

## UI/UX Design Patterns

- **Navigation:** Drawer (desktop) + Bottom nav (mobile)
- **Theme:** Clean, modern with cards, shadows, gradients
- **Colors:** Navy blue primary, gold accents, category-specific colors
- **Animations:** Fade and slide transitions
- **Responsive:** 1200px breakpoint for desktop/tablet
- **Icons:** Material Design icons
- **AppBars:** Clean white (no gradients for consistency)

## Deployment Checklist

**CRITICAL - Version Bumps Required:**
1. `web/service-worker.js` - Update CACHE_VERSION
2. `pubspec.yaml` - Increment version (MAJOR.MINOR.PATCH+BUILD)

**Format:** `1.0.X+Y`
- MAJOR: Breaking changes
- MINOR: New features (use for most deployments)
- PATCH: Bug fixes
- BUILD: ALWAYS increment

**Steps:**
```bash
# 1. Bump versions in both files
# 2. Commit changes
git add web/service-worker.js pubspec.yaml
git commit -m "Bump version to X.X.X+X for [feature]"
# 3. Push to develop → merge to main → deploy
```

**⚠️ NO VERSION BUMP = NO AUTO-UPDATES**

## Performance & Cost

**AI Analysis:**
- First defect per client: ~90s (cache creation)
- Subsequent defects: ~5-10s (18x faster with cache)
- Cost: ~$0.005 per defect analysis
- Cache lifetime: 72 hours

**Photo Identification:**
- First photo: ~60-90s (cache creation)
- Subsequent photos: ~5-10s (cache hit)
- Cost: ~$0.002-$0.003 per photo
- Singleton cache shared across all users

**Performance Targets:**
- FCP: < 1.8s
- FID: < 100ms
- LCP: < 2.5s
- Photo Upload: < 3s
- Firestore Query: < 500ms

## Important Technical Notes

**Vertex AI Context Caching:**
- Client-specific caches in `/procedure_caches/{clientName}`
- Singleton cache for photo ID in `/defect_identifier_cache/defectidentifiertool`
- Automatic invalidation on PDF changes (Storage triggers)
- MD5 hash validation for cache freshness

**Firebase Storage Paths:**
- `procedures/{clientName}/` - Client-specific PDFs for defect analysis
- `procedures/defectidentifiertool/` - Reference PDFs for photo ID
- `defect_photos/{userId}/` - User-uploaded defect photos
- `exports/{userId}/` - Generated Excel files

**Firestore Indexes Required:**
- `defect_entries`: userId (ASC) + createdAt (DESC)
- `photo_identifications`: userId (ASC) + createdAt (DESC)

**Cloud Functions Deployed:**
- `analyzeDefectOnCreate` - Defect AI analysis
- `analyzePhotoIdentificationOnCreate` - Photo AI identification
- `invalidateCacheOnPdfUpload/Delete` - Cache management
- `invalidateDefectIdentifierCacheOnUpload/Delete` - Photo cache management
- `exportMethodHoursToExcel` - Server-side Excel generation

## Current State

The app is feature-complete and deployed. Key recent additions:
- Critical Angle Calculator (Snell's Law Suite)
- Mode Conversion Calculator
- Photo-based defect identification
- Vertex AI context caching
- Terms of Service & Privacy Policy system
- Firebase Performance Monitoring
- Server-side Excel export

**Latest Updates:** February 12, 2026
- Added Critical Angle Calculator to Snell's Law Suite
- 3 calculators now in suite: Snell's Law, Mode Conversion, Critical Angle

---

This documentation provides essential reference for maintaining and extending the Integrity Tools app.
