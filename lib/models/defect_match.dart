/// Model for AI defect identification results
class DefectMatch {
  final String defectType;
  final String confidence; // "high" | "medium" | "low"
  final double confidenceScore; // 0-100
  final String reasoning;
  final List<String> visualIndicators;

  DefectMatch({
    required this.defectType,
    required this.confidence,
    required this.confidenceScore,
    required this.reasoning,
    required this.visualIndicators,
  });

  factory DefectMatch.fromJson(Map<String, dynamic> json) {
    return DefectMatch(
      defectType: json['defectType'] ?? '',
      confidence: json['confidence'] ?? 'low',
      confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
      reasoning: json['reasoning'] ?? '',
      visualIndicators: List<String>.from(json['visualIndicators'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defectType': defectType,
      'confidence': confidence,
      'confidenceScore': confidenceScore,
      'reasoning': reasoning,
      'visualIndicators': visualIndicators,
    };
  }

  // Helper to get confidence color
  String get confidenceEmoji {
    switch (confidence.toLowerCase()) {
      case 'high':
        return '🟢';
      case 'medium':
        return '🟡';
      case 'low':
        return '🔴';
      default:
        return '⚪';
    }
  }
}

/// Response from photo identification Cloud Function
class DefectIdentificationResponse {
  final List<DefectMatch> matches;
  final double processingTime; // seconds

  DefectIdentificationResponse({
    required this.matches,
    required this.processingTime,
  });

  factory DefectIdentificationResponse.fromJson(Map<String, dynamic> json) {
    final matchesJson = json['matches'] as List<dynamic>? ?? [];
    final matches = matchesJson
        .map((m) => DefectMatch.fromJson(m as Map<String, dynamic>))
        .toList();

    return DefectIdentificationResponse(
      matches: matches,
      processingTime: (json['processingTime'] ?? 0).toDouble(),
    );
  }
}
