# Firebase Performance Monitoring Setup Guide

## Overview

Firebase Performance Monitoring has been fully integrated into the Integrity Tools app to track real-world performance metrics and identify optimization opportunities.

**Status:** ✅ **FULLY IMPLEMENTED**

---

## What's Monitored Automatically

Firebase Performance Monitoring automatically tracks:

### ✅ **Automatic Metrics (No Code Required)**

1. **Page Load Performance (Web Vitals)**
   - **FCP (First Contentful Paint)** - Time until first content renders
   - **FID (First Input Delay)** - Time until app becomes interactive
   - **LCP (Largest Contentful Paint)** - Loading performance
   - **CLS (Cumulative Layout Shift)** - Visual stability

2. **Network Requests**
   - Firebase Storage uploads/downloads
   - Firestore queries (read/write operations)
   - Cloud Functions calls
   - HTTP/HTTPS requests

3. **App Start Time**
   - Time from app launch to first screen render
   - Measured on both web and mobile platforms

4. **Screen Rendering**
   - Frame rates and UI responsiveness
   - Slow/frozen frames detection

---

## Custom Traces Implemented

### 🔍 **1. AI Defect Analysis** (`defect_ai_analysis`)

**Location:** `lib/services/defect_service.dart`

**Tracks:**
- Time to create defect entry in Firestore
- Client name and defect type attributes
- Success/error status

**Metrics:**
- `processing_time_ms` - Duration in milliseconds
- `defect_type` - Type of defect being analyzed
- `client_name` - Which client's procedures are used

**Usage Example:**
```dart
// Automatically tracked when user logs a defect
final entry = await DefectService().addDefectEntry(defectEntry);
```

**Firebase Console View:**
- Trace name: `defect_ai_analysis`
- Average duration across all users
- Breakdown by defect type and client
- 90th/95th percentile times

---

### 📸 **2. Photo Upload** (`photo_upload`)

**Location:** `lib/services/defect_identifier_service.dart`

**Tracks:**
- Photo upload duration to Firebase Storage
- File size and platform (web vs mobile)
- Network performance impact

**Metrics:**
- `file_size_kb` - Image size in kilobytes
- `upload_duration_ms` - Time to complete upload
- `platform` - "web" or "mobile"

**Usage Example:**
```dart
// Automatically tracked when user uploads a defect photo
final photoUrl = await DefectIdentifierService().uploadPhotoForIdentification(photoFile);
```

**Why This Matters:**
- Critical for field technicians on spotty cellular networks
- Identifies slow upload scenarios
- Helps optimize image compression settings

---

### 📊 **3. Firestore Query Performance** (`firestore_query`)

**Location:** `lib/services/defect_service.dart` (getUserDefectCount)

**Tracks:**
- Database query execution time
- Collection being queried
- Success/error rates

**Metrics:**
- `query_time_ms` - Query duration
- `collection` - Which Firestore collection

**Usage Example:**
```dart
// Automatically tracked when counting defects
final count = await DefectService().getUserDefectCount();
```

**Optimization Opportunities:**
- Identify slow queries needing indexes
- Monitor query performance over time
- Detect N+1 query problems

---

## How to Add Custom Traces

### Pattern 1: Wrapper Function (Recommended)

Use the `PerformanceService` helper methods:

```dart
import 'package:calculator_app/services/performance_service.dart';

// Track any async operation
final result = await PerformanceService().trackOperation<ResultType>(
  operationName: 'my_custom_operation',
  attributes: {
    'user_type': 'field_tech',
    'location': 'texas',
  },
  metrics: {
    'item_count': 10,
  },
  operation: () async {
    // Your async code here
    return await doSomething();
  },
);
```

### Pattern 2: Manual Trace Control

For more control over start/stop timing:

```dart
import 'package:calculator_app/services/performance_service.dart';

final trace = PerformanceService().startTrace('complex_calculation');

try {
  // Add custom attributes
  trace.putAttribute('calculator_name', 'B31G');
  trace.putAttribute('input_method', 'manual');
  
  // Perform the operation
  final result = performCalculation();
  
  // Add metrics based on result
  trace.setMetric('calculation_steps', result.steps);
  trace.setMetric('iterations', result.iterations);
  
  trace.putAttribute('status', 'success');
} catch (e) {
  trace.putAttribute('status', 'error');
  trace.putAttribute('error_type', e.runtimeType.toString());
  rethrow;
} finally {
  await trace.stop();
}
```

---

## Adding Performance Tracking to Calculators

### Example: B31G Calculator

```dart
import 'package:flutter/material.dart';
import 'package:calculator_app/services/performance_service.dart';

class B31GCalculator extends StatefulWidget {
  // ... existing code ...
  
  void _calculateB31G() {
    final trace = PerformanceService().startTrace('calculator_load');
    trace.putAttribute('calculator_name', 'B31G Calculator');
    
    setState(() {
      try {
        // Perform calculation
        final results = performB31GCalculation(
          depth: double.parse(_depthController.text),
          length: double.parse(_lengthController.text),
          // ... other inputs
        );
        
        _results = results;
        trace.putAttribute('status', 'success');
        trace.setMetric('input_fields', 5);
      } catch (e) {
        trace.putAttribute('status', 'error');
        // ... error handling
      } finally {
        trace.stop();
      }
    });
  }
}
```

---

## Predefined Helper Methods

The `PerformanceService` includes these convenience methods:

### 1. `trackDefectAnalysis()`
```dart
await PerformanceService().trackDefectAnalysis<DefectEntry>(
  defectType: 'corrosion',
  clientName: 'williams',
  operation: () async => await createDefect(),
);
```

### 2. `trackPhotoUpload()`
```dart
await PerformanceService().trackPhotoUpload<String>(
  fileSizeBytes: 2048000,
  platform: 'mobile',
  operation: () async => await uploadPhoto(),
);
```

### 3. `trackPhotoIdentification()`
```dart
await PerformanceService().trackPhotoIdentification<Result>(
  operation: () async => await analyzePhoto(),
);
```

### 4. `trackPdfConversion()`
```dart
await PerformanceService().trackPdfConversion<Excel>(
  pdfPages: 15,
  operation: () async => await convertPdf(),
);
```

### 5. `trackCalculatorLoad()`
```dart
await PerformanceService().trackCalculatorLoad<Widget>(
  calculatorName: 'Pit Depth Calculator',
  operation: () async => await loadCalculator(),
);
```

### 6. `trackFirestoreQuery()`
```dart
await PerformanceService().trackFirestoreQuery<List<Defect>>(
  collection: 'defect_entries',
  operation: () async => await queryDefects(),
);
```

---

## Viewing Performance Data

### Firebase Console Access

1. Go to: https://console.firebase.google.com/
2. Select project: **integrity-tools**
3. Navigate to: **Performance** (left sidebar)

### Dashboard Sections

#### **1. Performance Overview**
- App start time trends
- Page load performance (FCP, FID, LCP)
- Network request performance
- Custom trace statistics

#### **2. Custom Traces**
- `defect_ai_analysis` - AI processing times
- `photo_upload` - Upload performance by network type
- `firestore_query` - Database query performance

#### **3. Network Requests**
- Firestore operations
- Firebase Storage uploads/downloads
- Cloud Functions calls
- Success rates and failure patterns

#### **4. Web Vitals (PWA)**
- LCP (Largest Contentful Paint)
- FID (First Input Delay)
- CLS (Cumulative Layout Shift)
- Breakdown by device, browser, location

---

## Key Insights You'll Get

### For Field Technicians

**📍 Geographic Performance**
- See which regions have slower performance
- Identify areas with poor network connectivity
- Optimize for specific locations

**📱 Device/Browser Breakdown**
- Chrome vs Safari performance
- Mobile vs desktop differences
- iOS vs Android comparison

**🌐 Network Analysis**
- WiFi vs cellular performance
- Upload/download speed impact
- Offline mode effectiveness

### For Developers

**⚡ Optimization Opportunities**
- Identify slowest operations
- Find bottlenecks in AI analysis
- Optimize photo upload sizes
- Improve Firestore query performance

**📊 Real User Monitoring**
- Actual performance vs synthetic tests
- 90th/95th percentile latencies
- Error rates and failure patterns

**🔍 Debug Production Issues**
- Track specific user sessions
- Identify performance regressions
- Validate optimization improvements

---

## Performance Targets

### Recommended Thresholds

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| **FCP** | < 1.8s | 1.8s - 3s | > 3s |
| **FID** | < 100ms | 100ms - 300ms | > 300ms |
| **LCP** | < 2.5s | 2.5s - 4s | > 4s |
| **Photo Upload** | < 3s | 3s - 10s | > 10s |
| **AI Analysis** | < 10s | 10s - 30s | > 30s |
| **Firestore Query** | < 500ms | 500ms - 2s | > 2s |

---

## Cost Information

### Free Tier Limits

- **Custom traces:** 50,000/day (more than sufficient)
- **Network monitoring:** Unlimited
- **Automatic metrics:** Unlimited
- **Data retention:** 90 days

### Current Usage Estimate

Based on app usage patterns:
- ~100-500 defect entries/day = ~500 custom traces
- ~50-200 photo uploads/day = ~200 custom traces
- Firestore queries = automatically tracked (free)

**Total:** Well within free tier limits ✅

---

## Troubleshooting

### No Data Appearing in Console

**Wait Time:** Data can take 12-24 hours to appear initially, then updates every ~1 hour.

**Debug Logging:**
Check console for these messages:
```
[Performance] Firebase Performance Monitoring enabled
[Performance] Trace started: defect_ai_analysis
[Performance] Defect analysis completed in 1234ms
```

**Verify Initialization:**
```dart
// In lib/main.dart
if (kDebugMode) {
  print('[Performance] Firebase Performance Monitoring enabled');
}
```

### Traces Not Recording

**Check Import:**
```dart
import 'package:calculator_app/services/performance_service.dart';
```

**Verify Trace Stopped:**
```dart
try {
  // operation
} finally {
  await trace.stop(); // MUST call this!
}
```

### Web Performance Not Tracking

**Verify web/index.html includes:**
```javascript
import { getPerformance } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-performance.js";
const performance = getPerformance(app);
```

---

## Best Practices

### ✅ DO

- Use descriptive trace names (`defect_ai_analysis`, not `trace1`)
- Add relevant attributes (defect type, client name, platform)
- Set meaningful metrics (file size, processing time)
- Always stop traces in `finally` blocks
- Track critical user journeys (photo upload, AI analysis)

### ❌ DON'T

- Track PII (Personally Identifiable Information)
- Create traces for every button click
- Use random/dynamic trace names
- Forget to stop traces (memory leaks!)
- Track operations < 10ms (overhead not worth it)

---

## Integration Checklist

- [x] Add `firebase_performance` dependency
- [x] Create `PerformanceService` singleton
- [x] Initialize in `main.dart`
- [x] Add performance SDK to `web/index.html`
- [x] Implement AI analysis tracking
- [x] Implement photo upload tracking
- [x] Implement Firestore query tracking
- [ ] **Optional:** Add calculator load tracking
- [ ] **Optional:** Add PDF conversion tracking
- [ ] **Optional:** Add more Firestore query tracking

---

## Support & Resources

**Firebase Documentation:**
- https://firebase.google.com/docs/perf-mon

**Flutter Package:**
- https://pub.dev/packages/firebase_performance

**Firebase Console:**
- https://console.firebase.google.com/project/integrity-tools/performance

**Project Contact:**
- Email: daviddunn334@gmail.com
- GitHub: https://github.com/daviddunn334/calculator_app

---

## Next Steps

1. **Wait 24 hours** for initial data to populate
2. **Monitor dashboard** for baseline metrics
3. **Identify slow operations** from 95th percentile data
4. **Optimize** based on real user data
5. **Track improvements** over time
6. **Set up alerts** for performance degradation (optional)

---

**Last Updated:** February 12, 2026
**Implementation Status:** ✅ Complete
**Version:** 1.0.3+4
