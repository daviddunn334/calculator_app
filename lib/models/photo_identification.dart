import 'package:cloud_firestore/cloud_firestore.dart';
import 'defect_match.dart';

/// Model for photo identification entries with async analysis
class PhotoIdentification {
  final String id;
  final String userId;
  final String photoUrl;
  final String analysisStatus; // 'pending' | 'analyzing' | 'complete' | 'error'
  final DateTime createdAt;
  final DateTime? analysisCompletedAt;
  
  // Analysis Results
  final List<DefectMatch>? matches; // Top 3 results
  final double? processingTime; // seconds
  final String? errorMessage;

  PhotoIdentification({
    required this.id,
    required this.userId,
    required this.photoUrl,
    required this.analysisStatus,
    required this.createdAt,
    this.analysisCompletedAt,
    this.matches,
    this.processingTime,
    this.errorMessage,
  });

  factory PhotoIdentification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse matches if available
    List<DefectMatch>? matches;
    if (data['matches'] != null) {
      final matchesJson = data['matches'] as List<dynamic>;
      matches = matchesJson
          .map((m) => DefectMatch.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    
    return PhotoIdentification(
      id: doc.id,
      userId: data['userId'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      analysisStatus: data['analysisStatus'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate().toUtc(),
      analysisCompletedAt: data['analysisCompletedAt'] != null
          ? (data['analysisCompletedAt'] as Timestamp).toDate().toUtc()
          : null,
      matches: matches,
      processingTime: data['processingTime'] != null 
          ? (data['processingTime'] as num).toDouble() 
          : null,
      errorMessage: data['errorMessage'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'photoUrl': photoUrl,
      'analysisStatus': analysisStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      if (analysisCompletedAt != null)
        'analysisCompletedAt': Timestamp.fromDate(analysisCompletedAt!),
      if (matches != null)
        'matches': matches!.map((m) => m.toJson()).toList(),
      if (processingTime != null)
        'processingTime': processingTime,
      if (errorMessage != null)
        'errorMessage': errorMessage,
    };
  }

  // Helper method to get local date
  DateTime get localCreatedAt => createdAt.toLocal();
  DateTime? get localAnalysisCompletedAt => analysisCompletedAt?.toLocal();
  
  // Helper to check if analysis is complete
  bool get hasAnalysis => analysisStatus == 'complete' && matches != null;
  
  // Helper to check if analysis is in progress
  bool get isAnalyzing => analysisStatus == 'analyzing';
  
  // Helper to check if analysis has error
  bool get hasAnalysisError => analysisStatus == 'error';
  
  // Get top match for display in list view
  DefectMatch? get topMatch => matches?.isNotEmpty == true ? matches!.first : null;
}
