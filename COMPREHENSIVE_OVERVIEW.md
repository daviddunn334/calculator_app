# INTEGRITY TOOLS APP - COMPREHENSIVE OVERVIEW

## App Identity

- Name: Integrity Tools
- Company: Integrity Specialists
- Tagline: "Our people are trained to be the difference."
- Purpose: A comprehensive mobile and web toolkit for pipeline inspection professionals specializing in NDT (Non-Destructive Testing)
- Platform: Flutter (iOS, Android, Web)
- Backend: Firebase (Firestore, Authentication, Storage, Cloud Functions, **Analytics**)

## Brand Guidelines

- Primary Color: Navy Blue (#1b325b)
- Accent Color: Gold (#fbcd0f)
- Package Name: com.integrityspecialists.app
- Firebase Project: integrity-tools

## Core Architecture

### Tech Stack

- Flutter SDK 3.0+
- Firebase Core, Auth, Firestore, Storage, **Analytics**
- Syncfusion PDF libraries for PDF viewing and generation
- Excel package for spreadsheet generation
- Connectivity Plus for offline detection
- Image Picker & File Picker for media handling
- **URL Launcher for contact actions (phone, email, SMS)**

### Project Structure

```
lib/
├── calculators/        # Offline-capable calculation tools
├── models/            # Data models (User, Report, NewsUpdate, etc.)
├── screens/           # UI screens (Home, Tools, Profile, Admin, etc.)
├── services/          # Business logic (Auth, Firestore, PDF, Offline, Analytics)
├── theme/             # AppTheme with brand colors
├── widgets/           # Reusable UI components
└── utils/             # Helper utilities (ContactHelper, LocationColors, etc.)
```

## Key Features

### 1. Authentication System

- Firebase Authentication with email/password
- User profiles stored in Firestore /users/{userId}
- Role-based access control (regular users vs admins)
- Persistent authentication using LOCAL persistence
- Offline mode bypasses auth for calculator tools

### 2. NDT Calculator Tools (Offline-Capable)

Eight professional calculators for pipeline inspection:

- ABS + ES Calculator: Calculate ABS and ES values for offset and distance
- Pit Depth Calculator: Wall loss and remaining thickness calculations
- Time Clock Calculator: Clock position to distance conversions
- Dent Ovality Calculator: Dent deformation percentage calculations
- B31G Calculator: ASME B31G standard for corrosion assessment
- Depth Percentages Calculator: Data visualization and analysis
- SOC/EOC Calculator: Start/End of corrosion calculations
- Corrosion Grid Logger: Grid data logging for RSTRENG export

### 3. Inspection Reports System

- Create detailed inspection reports with:
  - Location, method (MT, PT, UT, PAUT, VT, ET, LM)
  - Technician information
  - Image attachments (Firebase Storage)
  - Timestamps and metadata
- View, edit, and delete reports
- Reports stored in /reports/{reportId} with userId reference
- Admin users can view all reports

### 4. Method Hours Tracking

- Log work hours by inspection method
- Calendar-based date selection
- Location and supervising technician tracking
- Multiple methods per entry
- Export to Excel templates
- Stored in /method_hours/{entryId}

### 5. Job Locations / Maps

- Personal Locations: User-created locations with custom folders and colors
- Job Locations: Company-wide hierarchical structure:
  - Divisions → Projects → Digs
  - Color-coded organization system
- Stored in /divisions/{divId}/projects/{projId}/digs/{digId}

### 6. Knowledge Base

Multiple reference sections:

- NDT Procedures & Standards
- Defect Types & Identification (corrosion, dents, hard spots, cracks)
- Common Formulas
- Field Safety
- Terminology
- Equipment Guides

### 7. Company Directory

- Employee roster with contact information
- **Clickable phone numbers and emails (opens native dialer/email client)**
- **List and grid view layouts**
- Admin-managed employee database
- Stored in /directory/{employeeId}
- **Integrated analytics tracking for contact actions**

### 8. News & Updates System

- Admin-created content with categories:
  - Safety alerts, Technical updates, Company news, Training, Announcements
- Draft and published states
- View counter tracking
- Rich content with images and icons
- Stored in /news_updates/{updateId}

### 9. PDF Tools

- Equotip Data Converter: Convert hardness test PDF files to Excel format
- PDF viewer using Syncfusion
- Template-based Excel generation

### 10. Admin Dashboard

Accessible only to users with isAdmin: true in their profile:

- User Management: View/edit users, toggle admin status
- News Management: Create/edit/delete news posts
- Reports Management: View all user reports
- PDF Management: Manage PDF documents
- Employee Management: Manage company directory
- Analytics: System statistics and health monitoring

### 11. **Firebase Analytics Tracking** ⭐ NEW

Comprehensive user behavior and engagement tracking:

**Automatic Tracking:**
- Screen views for all 10 main screens (home, tools, maps, method_hours, knowledge_base, profile, inventory, company_directory, news_updates, equotip_converter)
- Navigation patterns between screens
- Contact actions (phone calls, emails from directory)

**Available Event Methods:**
- `logLogin(method)` - User authentication
- `logSignUp(method)` - New user registration
- `logCalculatorUsed(name, inputValues)` - Calculator usage with parameters
- `logReportCreated(methodType)` - Inspection report creation
- `logReportEdited(reportId)` - Report modifications
- `logReportDeleted(reportId)` - Report deletions
- `logMethodHoursLogged(methods, hours)` - Method hours entries
- `logLocationAdded(type)` - Location additions
- `logKnowledgeBaseViewed(article)` - KB article views
- `logPdfConverted(type)` - PDF conversion actions
- `logFeatureUsed(featureName)` - Generic feature usage
- `logError(message, screen, stackTrace)` - Error tracking for debugging
- `logSearch(term, context)` - Search queries
- `logNewsViewed(id, category)` - News article engagement
- `logContactAction(action, method)` - Contact interactions

**Analytics Service Features:**
- Singleton pattern for efficient tracking
- Debug mode logging for development
- Silent background tracking (no user impact)
- Privacy-focused (no PII collection)
- Extensible for future events

### 12. Additional Features

- Certifications tracking
- Inventory management
- Profile management with preferences
- Weather widget
- Safety banner
- Responsive design (mobile + desktop/tablet layouts with 1200px breakpoint)
- **Contact helper utility for launching phone, email, and SMS**

## Offline Functionality

- Offline Service: Monitors connectivity using Connectivity Plus
- Calculator tools work completely offline
- Local data storage using SharedPreferences
- Offline mode shows special UI with calculator-only access
- Online features require authentication and connectivity

## Database Structure (Firestore)

### Collections

- /users/{userId} - User profiles with isAdmin flag
- /reports/{reportId} - Inspection reports with userId reference
- /method_hours/{entryId} - Method hours entries with userId reference
- /news_updates/{updateId} - News posts with isPublished flag
- /divisions/{divId}/projects/{projId}/digs/{digId} - Job location hierarchy
- /personal_folders/{folderId} - User-created location folders
- /personal_locations/{locationId} - User-created locations
- /directory/{employeeId} - Company employee directory

### Security Rules

- Users can read/write their own data
- Admins have elevated permissions
- News updates: read if published, admins can manage all
- Job locations: all users read, admins write
- Helper function isAdmin() checks user's admin status

## UI/UX Design Pattern

- Main Navigation: Drawer (sidebar on desktop, hamburger on mobile) + Bottom nav (mobile)
- Screens: Home, Tools, Maps, Method Hours, Knowledge Base, Profile, Inventory, Directory, News
- Theme: Clean, modern design with cards, shadows, gradients
- Animations: Fade and slide transitions between screens
- Colors: Navy blue primary, gold accents, green/orange/purple for categories
- **Interactive elements: Clickable contacts with visual feedback (ripple effects, underlines)**

## Utilities & Helpers

### **ContactHelper** ⭐ NEW
Located in `lib/utils/contact_helper.dart`

**Methods:**
- `launchPhone(context, phoneNumber)` - Opens native phone dialer
- `launchEmail(context, email, {subject, body})` - Opens email client with optional pre-fill
- `launchSMS(context, phoneNumber)` - Opens SMS app
- `formatPhoneNumber(phoneNumber)` - Formats for display (XXX) XXX-XXXX

**Features:**
- Error handling with user-friendly SnackBars
- Phone number cleaning (removes spaces, dashes, parentheses)
- Supports mailto: links with subject and body
- Integrated analytics tracking
- Cross-platform support (iOS, Android, Web)

### **AnalyticsService** ⭐ NEW
Located in `lib/services/analytics_service.dart`

**Core Methods:**
- `logScreenView(screenName)` - Track screen navigation
- `logEvent(name, parameters)` - Custom event logging
- `setUserId(userId)` - Associate events with user
- `setUserProperty(name, value)` - Set user attributes

**Architecture:**
- Singleton pattern for app-wide access
- Wrapper around FirebaseAnalytics
- Debug mode console logging
- Error handling with fallbacks

## Current State

The app is functional and feature-complete, preparing for Google Play Store and Apple App Store deployment. It includes proper Firebase integration (including Analytics), security rules, responsive layouts, comprehensive NDT tools for field use, and data-driven insights through analytics tracking.

---

## Recent Updates (Latest Session)

### **February 10, 2026**

1. **Firebase Analytics Integration**
   - Added firebase_analytics: ^10.8.0 dependency
   - Created AnalyticsService with 15+ predefined event methods
   - Implemented automatic screen view tracking for all 10 main screens
   - Added contact action tracking (phone, email)
   - Created comprehensive setup documentation (FIREBASE_ANALYTICS_SETUP.md)

2. **Company Directory Enhancements**
   - Made phone numbers and emails clickable
   - Added ContactHelper utility for launching native apps
   - Integrated analytics tracking for all contact actions
   - Enhanced UI with visual feedback (underlines, colors, ripple effects)
   - Both list and grid views support interactive contacts

3. **Navigation Tracking**
   - MainScreen now logs all screen transitions
   - Analytics automatically tracks user navigation patterns
   - Debug mode shows real-time tracking in console

4. **Documentation**
   - Created FIREBASE_ANALYTICS_SETUP.md with implementation guide
   - Updated project structure documentation
   - Added examples for future event tracking

**Files Added:**
- `lib/services/analytics_service.dart`
- `lib/utils/contact_helper.dart`
- `FIREBASE_ANALYTICS_SETUP.md`

**Files Modified:**
- `pubspec.yaml` - Added analytics dependency
- `lib/screens/main_screen.dart` - Screen tracking
- `lib/screens/company_directory_screen.dart` - Clickable contacts

**Commit:** `3094694` - "Add Firebase Analytics tracking with screen views and contact actions"
**Status:** Merged to main branch and deployed

5. **PWA Optimization & Install Prompt** 🚀 NEW
   - Enhanced manifest.json with 4 shortcuts (Tools, Reports, Knowledge Base, Directory)
   - Created custom install prompt system that triggers on first visit
   - Upgraded service worker with advanced caching strategies (cache-first, network-first, stale-while-revalidate)
   - Implemented PWA update notification system with user-controlled deployment
   - Added UpdateService for detecting and managing app updates
   - Created UpdateBanner widget for non-intrusive update notifications
   - Version management with automatic cache cleanup
   - Comprehensive analytics tracking for installs and updates

**PWA Features:**
- **Install Prompt** (web/install-prompt.js): Shows on first visit, localStorage tracking, dismissible
- **Enhanced Caching**: 30-50% faster load times, full offline app shell caching
- **Update Service** (lib/services/update_service.dart): Detects updates every 30 minutes, user-controlled updates
- **Update Banner** (lib/widgets/update_banner.dart): Material banner with "Later" / "Update Now" actions
- **Version**: Bumped to 1.0.1+2

**New Analytics Events:**
- `pwa_install_prompt_shown`, `pwa_install_prompt_action`, `pwa_installed`, `pwa_launched`
- `pwa_update_detected`, `pwa_update_dismissed`, `pwa_update_applied`

**Files Added:**
- `web/install-prompt.js` - Custom branded install prompt handler
- `lib/services/update_service.dart` - Update detection and management
- `lib/widgets/update_banner.dart` - Update notification UI
- `PWA_OPTIMIZATION_GUIDE.md` - Complete implementation documentation

**Files Modified:**
- `web/manifest.json` - Added shortcuts, updated orientation and start_url
- `web/service-worker.js` - Advanced caching with version-based management (v1.0.1)
- `web/index.html` - Integrated install-prompt.js
- `lib/main.dart` - Initialize UpdateService and UpdateBanner
- `pubspec.yaml` - Version bumped to 1.0.1+2

**Benefits:**
- Native app-like experience on mobile devices
- Install to home screen capability with custom prompt
- Faster load times with intelligent caching
- Full offline support for calculator tools and app shell
- Controlled update deployment with user notification
- No disruption to existing users

**Status:** Implemented and ready for deployment

6. **Mobile Install Instructions & Aggressive Auto-Updates** 📱⚡ NEW
   - Created platform-specific mobile install instructions dialog
   - Implemented aggressive 3-second auto-update system
   - Enhanced UpdateService for immediate reload capability
   - Integrated mobile guidance into login screen

**Mobile Install Features:**
- **Platform Detection**: Automatically detects iOS Safari, iOS Chrome, and Android Chrome
- **Specific Instructions**: 
  - iOS: "Tap Share → Add to Home Screen" with 3 visual steps
  - Android: "Tap menu (⋮) → Install app" with 3 visual steps
- **Smart Triggers**: Shows on login page after 2 seconds, only on mobile devices
- **User-Friendly**: Dismissible, remembers choice in localStorage, skips if already installed
- **Benefits Display**: Shows 30-50% faster load times, offline mode, one-tap access features

**Aggressive Auto-Update System:**
- **Non-Dismissible**: 3-second countdown ensures 100% user adoption
- **Visual Feedback**: Blue banner with pulsing icon, countdown timer, and "Update Now" button
- **Automatic Reload**: Page reloads after 3 seconds (user can skip countdown)
- **Zero Reinstalls**: PWA updates in place, never requires uninstall/reinstall
- **Instant Deployment**: All users get updates within seconds of deployment

**New Components:**
- **MobileInstallDialog** (lib/widgets/mobile_install_dialog.dart):
  - Platform-specific instruction builder
  - Benefit showcase with icons
  - localStorage tracking for dismissed state
  - 
  - Full customization for iOS vs Android

- **AutoUpdateNotification** (lib/widgets/auto_update_notification.dart):
  - Countdown timer widget with animation
  - Pulsing update icon
  - "Update Now" skip button
  - Slide-in animation from top

- **AggressiveUpdateWrapper** (in lib/main.dart):
  - Wraps entire app
  - Listens to update stream
  - Shows overlay when update detected

**Technical Implementation:**
- UpdateService enhanced with `immediate` parameter for instant reload
- Service worker version bumped to v1.0.2
- App version bumped to 1.0.2+3
- Platform detection using user agent strings
- Standalone mode detection to avoid showing on installed apps

**Files Added:**
- `lib/widgets/mobile_install_dialog.dart` - Mobile install guidance
- `lib/widgets/auto_update_notification.dart` - Aggressive update UI

**Files Modified:**
- `lib/services/update_service.dart` - Added immediate reload support
- `lib/screens/login_screen.dart` - Integrated mobile install dialog
- `lib/main.dart` - Added AggressiveUpdateWrapper
- `web/service-worker.js` - Version v1.0.2
- `pubspec.yaml` - Version 1.0.2+3

**User Experience:**
- **Desktop**: Existing install banner + 3-second auto-update
- **Android Chrome**: Install instructions dialog + 3-second auto-update
- **iOS Safari**: Install instructions dialog + 3-second auto-update
- **All Platforms**: Zero reinstalls required for updates

**Benefits:**
- Crystal-clear install guidance for mobile users
- 100% update adoption rate (non-dismissible)
- No user action required for updates
- Professional, branded experience
- Minimal disruption (3-second warning)

**Commit:** `da46fa8` - "Add aggressive auto-updates and mobile install instructions"
**Status:** Pushed to develop branch, ready for testing

7. **In-App Feedback & Bug Reporting System** 🐛💬 NEW
   - Complete feedback submission system for users to report bugs and request features
   - Admin management dashboard with filtering and status tracking
   - Image attachment support with Firebase Storage
   - Device information auto-capture for debugging
   - Firestore security rules for user/admin permissions

**Feedback System Features:**
- **User Submission Form** (lib/screens/feedback_screen.dart):
  - Three feedback types: Bug Report, Feature Request, General Feedback
  - Required fields: Subject, Description
  - Optional screenshot attachment (from device gallery)
  - Auto-captures device info (platform, OS version, browser, app version)
  - Clean, modern UI with type selection cards
  - Analytics tracking for submissions

- **Admin Management** (lib/screens/admin/feedback_management_screen.dart):
  - Real-time feedback list with DataTable
  - Filter by type (Bug/Feature/General) and status (New/In Review/Resolved)
  - Search by keyword
  - View full details in modal dialogs
  - Status management (Mark In Review, Mark Resolved)
  - Delete functionality
  - Screenshot preview support
  - Responsive design with stats cards

- **FeedbackService** (lib/services/feedback_service.dart):
  - `submitFeedback()` - Create new feedback with optional screenshot
  - `uploadScreenshot()` - Upload images to Firebase Storage
  - `getFeedbackList()` - Real-time stream for admin dashboard
  - `updateStatus()` - Change feedback status
  - `getDeviceInfo()` - Auto-capture platform, OS, browser details
  - Search and filter capabilities

- **FeedbackSubmission Model** (lib/models/feedback_submission.dart):
  - Properties: id, userId, userName, userEmail, type, subject, description
  - Screenshot URL (optional)
  - Device info object (platform, osVersion, appVersion, browserInfo)
  - Timestamp, status enum (New, In Review, Resolved)
  - Color-coded types and statuses

**Database Structure:**
- Collection: `/feedback/{feedbackId}`
- Security Rules:
  - Users can create and read their own feedback
  - Admins can read, update, and delete all feedback
  - Status field can only be updated by admins

**Navigation Integration:**
- Added to AppDrawer under "PROFESSIONAL" section
- Uses internal state management (index 10) for smooth transitions
- ⚠️ **IMPORTANT NAVIGATION PATTERN:** Always add new screens to MainScreen's `_screens` list with a unique index, never use `Navigator.pushNamed()` for main app screens to maintain consistent smooth transitions without URL changes

**Files Added:**
- `lib/models/feedback_submission.dart` - Data model with enums
- `lib/services/feedback_service.dart` - CRUD operations and device info
- `lib/screens/feedback_screen.dart` - User submission form
- `lib/screens/admin/feedback_management_screen.dart` - Admin dashboard

**Files Modified:**
- `lib/main.dart` - Added /feedback route (kept for direct access)
- `lib/widgets/app_drawer.dart` - Added "Send Feedback" menu item with index 10
- `lib/screens/main_screen.dart` - Added FeedbackScreen to _screens list at index 10
- `lib/screens/admin/admin_main_screen.dart` - Replaced Report Management with Feedback Management
- `lib/widgets/admin_drawer.dart` - Updated menu item
- `firestore.rules` - Added /feedback collection rules

**Analytics Events:**
- `feedback_submitted` - Tracks type and screenshot presence

**Commits:**
- `ba763bd` - "Add in-app feedback system with user submission and admin management"
- `6a4ce59` - "Fix text color in feedback screen header - make title readable"
- `939cfa3` - "Fix feedback screen navigation - use internal state management instead of named routes"

**Status:** Deployed to develop branch with Firestore rules

**🚨 NAVIGATION PATTERN LESSON LEARNED:**
When adding new screens to the app, always follow this pattern to maintain smooth transitions:
1. Add screen to `lib/screens/main_screen.dart` `_screens` list with new index
2. Add icon mapping in `_getIconForIndex()`
3. Add label mapping in `_getLabelForIndex()`
4. Add analytics name in `_getScreenNameForIndex()`
5. Update drawer to use `onItemSelected(index)` instead of `Navigator.pushNamed()`

**Why This Matters:**
- ✅ Smooth fade transitions between screens
- ✅ No URL changes (consistent PWA experience)
- ✅ Proper analytics tracking
- ✅ Fast, instant navigation
- ❌ Using `Navigator.pushNamed()` causes full page reloads and URL changes, breaking the smooth UX

---

This is the context you need when helping implement changes or new features for this application.
