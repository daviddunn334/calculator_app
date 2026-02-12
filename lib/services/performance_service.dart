import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

/// Service for tracking app performance metrics using Firebase Performance Monitoring
/// 
/// Tracks:
/// - Custom operations (AI analysis, photo uploads, PDF conversions)
/// - Network requests (automatically tracked)
/// - Screen rendering performance
/// - Web vitals (LCP, FID, CLS)
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final FirebasePerformance _performance = FirebasePerformance.instance;

  /// Start a custom trace
  /// 
  /// Example:
  /// ```dart
  /// final trace = PerformanceService().startTrace('ai_analysis');
  /// trace.putAttribute('defect_type', 'corrosion');
  /// // ... perform operation ...
  /// await trace.stop();
  /// ```
  Trace startTrace(String traceName) {
    try {
      final trace = _performance.newTrace(traceName);
      trace.start();
      
      if (kDebugMode) {
        print('[Performance] Trace started: $traceName');
      }
      
      return trace;
    } catch (e) {
      if (kDebugMode) {
        print('[Performance] Error starting trace $traceName: $e');
      }
      rethrow;
    }
  }

  /// Create a new trace without starting it (for manual control)
  Trace newTrace(String traceName) {
    return _performance.newTrace(traceName);
  }

  /// Create and track an HTTP metric
  /// 
  /// Example:
  /// ```dart
  /// final metric = PerformanceService().createHttpMetric(
  ///   url: 'https://api.example.com/data',
  ///   httpMethod: HttpMethod.Get,
  /// );
  /// await metric.start();
  /// // ... make request ...
  /// metric.responseCode = 200;
  /// await metric.stop();
  /// ```
  HttpMetric createHttpMetric({
    required String url,
    required HttpMethod httpMethod,
  }) {
    try {
      final metric = _performance.newHttpMetric(url, httpMethod);
      
      if (kDebugMode) {
        print('[Performance] HTTP metric created: $httpMethod $url');
      }
      
      return metric;
    } catch (e) {
      if (kDebugMode) {
        print('[Performance] Error creating HTTP metric: $e');
      }
      rethrow;
    }
  }

  // ========== PREDEFINED TRACE HELPERS ==========

  /// Track AI defect analysis performance
  Future<T> trackDefectAnalysis<T>({
    required String defectType,
    required String clientName,
    required Future<T> Function() operation,
  }) async {
    final trace = startTrace('defect_ai_analysis');
    trace.putAttribute('defect_type', defectType);
    trace.putAttribute('client_name', clientName);
    
    try {
      final startTime = DateTime.now();
      final result = await operation();
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      trace.setMetric('processing_time_ms', duration);
      trace.putAttribute('status', 'success');
      
      if (kDebugMode) {
        print('[Performance] Defect analysis completed in ${duration}ms');
      }
      
      return result;
    } catch (e) {
      trace.putAttribute('status', 'error');
      trace.putAttribute('error_type', e.runtimeType.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Track photo upload performance
  Future<T> trackPhotoUpload<T>({
    required int fileSizeBytes,
    required String platform,
    required Future<T> Function() operation,
  }) async {
    final trace = startTrace('photo_upload');
    trace.setMetric('file_size_kb', (fileSizeBytes / 1024).round());
    trace.putAttribute('platform', platform);
    
    try {
      final startTime = DateTime.now();
      final result = await operation();
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      trace.setMetric('upload_duration_ms', duration);
      trace.putAttribute('status', 'success');
      
      if (kDebugMode) {
        print('[Performance] Photo upload completed in ${duration}ms (${(fileSizeBytes / 1024).toStringAsFixed(2)} KB)');
      }
      
      return result;
    } catch (e) {
      trace.putAttribute('status', 'error');
      trace.putAttribute('error_type', e.runtimeType.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Track photo AI identification performance
  Future<T> trackPhotoIdentification<T>({
    required Future<T> Function() operation,
  }) async {
    final trace = startTrace('photo_ai_identification');
    
    try {
      final startTime = DateTime.now();
      final result = await operation();
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      trace.setMetric('processing_time_ms', duration);
      trace.putAttribute('status', 'success');
      
      if (kDebugMode) {
        print('[Performance] Photo identification completed in ${duration}ms');
      }
      
      return result;
    } catch (e) {
      trace.putAttribute('status', 'error');
      trace.putAttribute('error_type', e.runtimeType.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Track PDF conversion performance
  Future<T> trackPdfConversion<T>({
    required int pdfPages,
    required Future<T> Function() operation,
  }) async {
    final trace = startTrace('pdf_conversion');
    trace.setMetric('pdf_pages', pdfPages);
    
    try {
      final startTime = DateTime.now();
      final result = await operation();
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      trace.setMetric('conversion_time_ms', duration);
      trace.putAttribute('status', 'success');
      
      if (kDebugMode) {
        print('[Performance] PDF conversion completed in ${duration}ms ($pdfPages pages)');
      }
      
      return result;
    } catch (e) {
      trace.putAttribute('status', 'error');
      trace.putAttribute('error_type', e.runtimeType.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Track calculator load performance
  Future<T> trackCalculatorLoad<T>({
    required String calculatorName,
    required Future<T> Function() operation,
  }) async {
    final trace = startTrace('calculator_load');
    trace.putAttribute('calculator_name', calculatorName);
    
    try {
      final startTime = DateTime.now();
      final result = await operation();
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      trace.setMetric('load_time_ms', duration);
      trace.putAttribute('status', 'success');
      
      if (kDebugMode) {
        print('[Performance] Calculator "$calculatorName" loaded in ${duration}ms');
      }
      
      return result;
    } catch (e) {
      trace.putAttribute('status', 'error');
      trace.putAttribute('error_type', e.runtimeType.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Track Firestore query performance
  Future<T> trackFirestoreQuery<T>({
    required String collection,
    required Future<T> Function() operation,
  }) async {
    final trace = startTrace('firestore_query');
    trace.putAttribute('collection', collection);
    
    try {
      final startTime = DateTime.now();
      final result = await operation();
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      trace.setMetric('query_time_ms', duration);
      trace.putAttribute('status', 'success');
      
      if (kDebugMode) {
        print('[Performance] Firestore query on "$collection" completed in ${duration}ms');
      }
      
      return result;
    } catch (e) {
      trace.putAttribute('status', 'error');
      trace.putAttribute('error_type', e.runtimeType.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Track generic async operation
  Future<T> trackOperation<T>({
    required String operationName,
    Map<String, String>? attributes,
    Map<String, int>? metrics,
    required Future<T> Function() operation,
  }) async {
    final trace = startTrace(operationName);
    
    // Add custom attributes
    if (attributes != null) {
      attributes.forEach((key, value) {
        trace.putAttribute(key, value);
      });
    }
    
    // Add custom metrics
    if (metrics != null) {
      metrics.forEach((key, value) {
        trace.setMetric(key, value);
      });
    }
    
    try {
      final startTime = DateTime.now();
      final result = await operation();
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      trace.setMetric('duration_ms', duration);
      trace.putAttribute('status', 'success');
      
      if (kDebugMode) {
        print('[Performance] Operation "$operationName" completed in ${duration}ms');
      }
      
      return result;
    } catch (e) {
      trace.putAttribute('status', 'error');
      trace.putAttribute('error_type', e.runtimeType.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Enable/disable performance monitoring
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    try {
      await _performance.setPerformanceCollectionEnabled(enabled);
      
      if (kDebugMode) {
        print('[Performance] Performance collection ${enabled ? "enabled" : "disabled"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Performance] Error setting collection enabled: $e');
      }
    }
  }
}
