// File: lib/models/visit_model.dart

class Visit {
  final String visitId;
  final String patientId;
  final bool registrationFeePaid;
  final double registrationFee;
  final DateTime createdAt;
  final int? visitNumber;

  Visit({
    required this.visitId,
    required this.patientId,
    this.registrationFeePaid = false,
    this.registrationFee = 0.0,
    DateTime? createdAt,
    this.visitNumber,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Factory to create Visit from a Map (e.g., Supabase response)
  factory Visit.fromMap(Map<String, dynamic> res) {
    return Visit(
      visitId: res['visit_id'] != null ? res['visit_id'] as String : '',
      patientId: res['patient_id'] != null ? res['patient_id'] as String : '',
      registrationFeePaid: res['registration_fee_paid'] as bool? ?? false,
      registrationFee: (res['registration_fee'] as num?)?.toDouble() ?? 0.0,
      createdAt: res['created_at'] != null
          ? DateTime.tryParse(res['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      visitNumber: res['visit_number'] as int?,
    );
  }

  /// Convert Visit object to Map for inserting/updating Supabase
  Map<String, dynamic> toMap() {
    return {
      'visit_id': visitId,
      'patient_id': patientId,
      'registration_fee_paid': registrationFeePaid,
      'registration_fee': registrationFee,
      'created_at': createdAt.toIso8601String(),
      'visit_number': visitNumber,
    };
  }
}
