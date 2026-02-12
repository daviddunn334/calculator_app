import 'package:cloud_firestore/cloud_firestore.dart';

class DefectEntry {
  final String id;
  final String userId;
  final String defectType;
  final double pipeOD; // Pipe Outside Diameter (inches)
  final double pipeNWT; // Pipe Nominal Wall Thickness (inches)
  final double length; // inches
  final double width; // inches
  final double depth; // inches (or Max HB for Hardspot)
  final String? notes;
  final String clientName; // Client company for AI analysis
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // AI Analysis fields
  final String? analysisStatus; // 'pending' | 'analyzing' | 'complete' | 'error'
  final DateTime? analysisCompletedAt;
  
  // Analysis Results
  final bool? repairRequired;
  final String? repairType;
  final String? severity; // 'low' | 'medium' | 'high' | 'critical'
  final String? aiRecommendations;
  final String? procedureReference;
  final String? aiConfidence; // 'high' | 'medium' | 'low'
  final String? errorMessage;

  DefectEntry({
    required this.id,
    required this.userId,
    required this.defectType,
    required this.pipeOD,
    required this.pipeNWT,
    required this.length,
    required this.width,
    required this.depth,
    this.notes,
    required this.clientName,
    required this.createdAt,
    required this.updatedAt,
    this.analysisStatus,
    this.analysisCompletedAt,
    this.repairRequired,
    this.repairType,
    this.severity,
    this.aiRecommendations,
    this.procedureReference,
    this.aiConfidence,
    this.errorMessage,
  });

  factory DefectEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return DefectEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      defectType: data['defectType'] ?? '',
      pipeOD: (data['pipeOD'] ?? 0).toDouble(),
      pipeNWT: (data['pipeNWT'] ?? 0).toDouble(),
      length: (data['length'] ?? 0).toDouble(),
      width: (data['width'] ?? 0).toDouble(),
      depth: (data['depth'] ?? 0).toDouble(),
      notes: data['notes'],
      clientName: data['clientName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate().toUtc(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate().toUtc(),
      analysisStatus: data['analysisStatus'],
      analysisCompletedAt: data['analysisCompletedAt'] != null
          ? (data['analysisCompletedAt'] as Timestamp).toDate().toUtc()
          : null,
      repairRequired: data['repairRequired'],
      repairType: data['repairType'],
      severity: data['severity'],
      aiRecommendations: data['aiRecommendations'],
      procedureReference: data['procedureReference'],
      aiConfidence: data['aiConfidence'],
      errorMessage: data['errorMessage'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'defectType': defectType,
      'pipeOD': pipeOD,
      'pipeNWT': pipeNWT,
      'length': length,
      'width': width,
      'depth': depth,
      'notes': notes,
      'clientName': clientName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper method to get local date
  DateTime get localCreatedAt => createdAt.toLocal();
  DateTime get localUpdatedAt => updatedAt.toLocal();
  DateTime? get localAnalysisCompletedAt => analysisCompletedAt?.toLocal();

  // Helper to check if this is a hardspot defect
  bool get isHardspot => defectType.toLowerCase().contains('hardspot');

  // Helper to get the appropriate label for the depth field
  String get depthLabel => isHardspot ? 'Max HB' : 'Depth (in)';
  
  // Helper to check if analysis is complete
  bool get hasAnalysis => analysisStatus == 'complete' && aiRecommendations != null;
  
  // Helper to check if analysis is in progress
  bool get isAnalyzing => analysisStatus == 'analyzing';
  
  // Helper to check if analysis has error
  bool get hasAnalysisError => analysisStatus == 'error';
}
