import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service for tracking user behavior and app analytics
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  /// Get the analytics observer for navigation tracking
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(
        analytics: _analytics,
      );

  /// Log a screen view
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
      );
      if (kDebugMode) {
        print('Analytics: Screen view logged - $screenName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Analytics Error: Failed to log screen view - $e');
      }
    }
  }

  /// Log a custom event with parameters
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      if (kDebugMode) {
        print('Analytics: Event logged - $name ${parameters != null ? "with params: $parameters" : ""}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Analytics Error: Failed to log event - $e');
      }
    }
  }

  /// Set user ID for tracking
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      if (kDebugMode) {
        print('Analytics: User ID set - ${userId ?? "null"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Analytics Error: Failed to set user ID - $e');
      }
    }
  }

  /// Set user properties
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      if (kDebugMode) {
        print('Analytics: User property set - $name: $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Analytics Error: Failed to set user property - $e');
      }
    }
  }

  // ========== PREDEFINED EVENT METHODS ==========

  /// Log user login
  Future<void> logLogin(String method) async {
    await logEvent(
      name: 'login',
      parameters: {'method': method},
    );
  }

  /// Log user signup
  Future<void> logSignUp(String method) async {
    await logEvent(
      name: 'sign_up',
      parameters: {'method': method},
    );
  }

  /// Log calculator usage
  Future<void> logCalculatorUsed(String calculatorName, {Map<String, dynamic>? inputValues}) async {
    await logEvent(
      name: 'calculator_used',
      parameters: {
        'calculator_name': calculatorName,
        if (inputValues != null) ...inputValues,
      },
    );
  }

  /// Log report creation
  Future<void> logReportCreated(String methodType) async {
    await logEvent(
      name: 'report_created',
      parameters: {'method_type': methodType},
    );
  }

  /// Log report edited
  Future<void> logReportEdited(String reportId) async {
    await logEvent(
      name: 'report_edited',
      parameters: {'report_id': reportId},
    );
  }

  /// Log report deleted
  Future<void> logReportDeleted(String reportId) async {
    await logEvent(
      name: 'report_deleted',
      parameters: {'report_id': reportId},
    );
  }

  /// Log method hours entry
  Future<void> logMethodHoursLogged(List<String> methods, double totalHours) async {
    await logEvent(
      name: 'method_hours_logged',
      parameters: {
        'methods': methods.join(','),
        'total_hours': totalHours,
      },
    );
  }

  /// Log location added
  Future<void> logLocationAdded(String locationType) async {
    await logEvent(
      name: 'location_added',
      parameters: {'location_type': locationType},
    );
  }

  /// Log knowledge base article viewed
  Future<void> logKnowledgeBaseViewed(String articleType) async {
    await logEvent(
      name: 'knowledge_base_viewed',
      parameters: {'article_type': articleType},
    );
  }

  /// Log PDF conversion
  Future<void> logPdfConverted(String conversionType) async {
    await logEvent(
      name: 'pdf_converted',
      parameters: {'conversion_type': conversionType},
    );
  }

  /// Log feature usage
  Future<void> logFeatureUsed(String featureName) async {
    await logEvent(
      name: 'feature_used',
      parameters: {'feature_name': featureName},
    );
  }

  /// Log error occurrence
  Future<void> logError({
    required String errorMessage,
    required String screen,
    String? stackTrace,
  }) async {
    await logEvent(
      name: 'error_occurred',
      parameters: {
        'error_message': errorMessage,
        'screen': screen,
        if (stackTrace != null) 'stack_trace': stackTrace.substring(0, stackTrace.length > 100 ? 100 : stackTrace.length),
      },
    );
  }

  /// Log search performed
  Future<void> logSearch(String searchTerm, String searchContext) async {
    await logEvent(
      name: 'search',
      parameters: {
        'search_term': searchTerm,
        'search_context': searchContext,
      },
    );
  }

  /// Log news update viewed
  Future<void> logNewsViewed(String newsId, String newsCategory) async {
    await logEvent(
      name: 'news_viewed',
      parameters: {
        'news_id': newsId,
        'news_category': newsCategory,
      },
    );
  }

  /// Log directory contact action
  Future<void> logContactAction(String actionType, String contactMethod) async {
    await logEvent(
      name: 'contact_action',
      parameters: {
        'action_type': actionType,
        'contact_method': contactMethod,
      },
    );
  }

  /// Log defect logged
  Future<void> logDefectLogged(String defectType, String clientName) async {
    await logEvent(
      name: 'defect_logged',
      parameters: {
        'defect_type': defectType,
        'client_name': clientName,
      },
    );
  }

  /// Log AI analysis started
  Future<void> logDefectAnalysisStarted(String defectId, String defectType) async {
    await logEvent(
      name: 'defect_analysis_started',
      parameters: {
        'defect_id': defectId,
        'defect_type': defectType,
      },
    );
  }

  /// Log AI analysis completed
  Future<void> logDefectAnalysisCompleted({
    required String defectId,
    required String defectType,
    required String severity,
    required bool repairRequired,
    required String confidence,
  }) async {
    await logEvent(
      name: 'defect_analysis_completed',
      parameters: {
        'defect_id': defectId,
        'defect_type': defectType,
        'severity': severity,
        'repair_required': repairRequired.toString(),
        'confidence': confidence,
      },
    );
  }

  /// Log AI analysis failed
  Future<void> logDefectAnalysisFailed(String defectId, String errorMessage) async {
    await logEvent(
      name: 'defect_analysis_failed',
      parameters: {
        'defect_id': defectId,
        'error_message': errorMessage,
      },
    );
  }

  /// Log AI analysis retried
  Future<void> logDefectAnalysisRetried(String defectId) async {
    await logEvent(
      name: 'defect_analysis_retried',
      parameters: {
        'defect_id': defectId,
      },
    );
  }

  /// Log defect viewed
  Future<void> logDefectViewed(String defectId, bool hasAnalysis) async {
    await logEvent(
      name: 'defect_viewed',
      parameters: {
        'defect_id': defectId,
        'has_analysis': hasAnalysis.toString(),
      },
    );
  }

  /// Log defect photo identification started
  Future<void> logDefectPhotoIdentificationStarted() async {
    await logEvent(
      name: 'defect_photo_identification_started',
      parameters: {},
    );
  }

  /// Log defect photo identification completed
  Future<void> logDefectPhotoIdentificationCompleted(
    String topMatch,
    String confidence,
    double processingTime,
  ) async {
    await logEvent(
      name: 'defect_photo_identification_completed',
      parameters: {
        'top_match': topMatch,
        'confidence': confidence,
        'processing_time': processingTime,
      },
    );
  }

  /// Log defect photo identification failed
  Future<void> logDefectPhotoIdentificationFailed(String errorMessage) async {
    await logEvent(
      name: 'defect_photo_identification_failed',
      parameters: {
        'error_message': errorMessage,
      },
    );
  }
}
