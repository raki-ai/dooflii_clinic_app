// File: lib/modules/triage/triage_helper.dart

class TriageHelper {
  /// Calculate BMI = weight(kg) / (height(m))^2
  static double calculateBMI(
      {required double weightKg, required double heightCm}) {
    if (weightKg <= 0 || heightCm <= 0) return 0.0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Validation helpers
  static String? validateWeightHeight(String? value, String field) {
    final val = double.tryParse(value ?? '');
    if (val == null || val <= 0) return '$field must be > 0';
    return null;
  }

  static String? validateNumeric(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final val = double.tryParse(value);
    if (val == null) return 'Invalid number';
    return null;
  }

  static String? validatePositiveInteger(String? value, String field) {
    final val = int.tryParse(value ?? '');
    if (val == null || val < 0) return '$field must be >= 0';
    return null;
  }

  static String? validateOxygen(String? value) {
    final val = int.tryParse(value ?? '');
    if (val == null || val < 0 || val > 100) return 'Oxygen must be 0-100';
    return null;
  }

  static String? validatePainScore(String? value) {
    final val = int.tryParse(value ?? '');
    if (val == null || val < 0 || val > 10) return 'Pain score must be 0-10';
    return null;
  }

  static String? validateBP(String? value) {
    final val = int.tryParse(value ?? '');
    if (val == null || val <= 0) return 'Invalid BP';
    return null;
  }
}
