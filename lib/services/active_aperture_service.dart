/// Active Aperture Calculation Service
/// Handles the math for phased-array probe active aperture calculations
class ActiveApertureService {
  /// Calculates the active aperture size of a phased-array probe
  /// 
  /// Parameters:
  /// - [numElements]: Number of active elements (n) - must be >= 1
  /// - [pitch]: Center-to-center spacing between elements (e) - must be > 0
  /// - [elementWidth]: Physical width of each element (a) - must be > 0
  /// 
  /// Returns a map containing:
  /// - 'span': Active element span excluding element width, (n - 1) * e
  /// - 'aperture': Total active aperture, (n - 1) * e + a
  /// - 'error': Error message if validation fails (null if valid)
  static Map<String, dynamic> calculateActiveAperture({
    required int numElements,
    required double pitch,
    required double elementWidth,
  }) {
    // Validate inputs
    if (numElements < 1) {
      return {
        'span': null,
        'aperture': null,
        'error': 'Number of elements must be at least 1',
      };
    }

    if (pitch <= 0) {
      return {
        'span': null,
        'aperture': null,
        'error': 'Pitch must be greater than 0',
      };
    }

    if (elementWidth <= 0) {
      return {
        'span': null,
        'aperture': null,
        'error': 'Element width must be greater than 0',
      };
    }

    // Calculate span (active element spacing)
    final double span = (numElements - 1) * pitch;

    // Calculate total active aperture
    final double aperture = span + elementWidth;

    return {
      'span': span,
      'aperture': aperture,
      'error': null,
    };
  }

  /// Validates input values before calculation
  static String? validateInputs({
    required int numElements,
    required double pitch,
    required double elementWidth,
  }) {
    if (numElements < 1) {
      return 'Number of elements must be at least 1';
    }
    if (pitch <= 0) {
      return 'Pitch must be greater than 0';
    }
    if (elementWidth <= 0) {
      return 'Element width must be greater than 0';
    }
    return null;
  }
}
