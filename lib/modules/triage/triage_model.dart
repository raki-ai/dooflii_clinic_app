// File: lib/modules/triage/triage_model.dart

class Triage {
  final String id;
  final String patientId;
  final String visitId;
  final int visitNumber;
  final String fullName;
  final int age;
  final String gender;
  final String? address;
  final double weightKg;
  final double heightCm;
  final double bmi;
  final double temperature;
  final int pulseRate;
  final int respiratoryRate;
  final int oxygenSaturation;
  final int painScore;
  final int bpSystolic;
  final int bpDiastolic;
  final DateTime createdAt;

  Triage({
    required this.id,
    required this.patientId,
    required this.visitId,
    required this.visitNumber,
    required this.fullName,
    required this.age,
    required this.gender,
    this.address,
    this.weightKg = 0.0,
    this.heightCm = 0.0,
    this.bmi = 0.0,
    this.temperature = 0.0,
    this.pulseRate = 0,
    this.respiratoryRate = 0,
    this.oxygenSaturation = 0,
    this.painScore = 0,
    this.bpSystolic = 0,
    this.bpDiastolic = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Triage.fromMap(Map<String, dynamic> map) {
    return Triage(
      id: map['id'] as String? ?? '',
      patientId: map['patient_id'] as String? ?? '',
      visitId: map['visit_id'] as String? ?? '',
      visitNumber: map['visit_number'] as int? ?? 1,
      fullName: map['full_name'] as String? ?? '',
      age: map['age'] as int? ?? 0,
      gender: map['gender'] as String? ?? 'Male',
      address: map['address'] as String?,
      weightKg: (map['weight_kg'] as num?)?.toDouble() ?? 0.0,
      heightCm: (map['height_cm'] as num?)?.toDouble() ?? 0.0,
      bmi: (map['bmi'] as num?)?.toDouble() ?? 0.0,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      pulseRate: map['pulse_rate'] as int? ?? 0,
      respiratoryRate: map['respiratory_rate'] as int? ?? 0,
      oxygenSaturation: map['oxygen_saturation'] as int? ?? 0,
      painScore: map['pain_score'] as int? ?? 0,
      bpSystolic: map['bp_systolic'] as int? ?? 0,
      bpDiastolic: map['bp_diastolic'] as int? ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'visit_id': visitId,
      'visit_number': visitNumber,
      'full_name': fullName,
      'age': age,
      'gender': gender,
      'address': address,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'bmi': bmi,
      'temperature': temperature,
      'pulse_rate': pulseRate,
      'respiratory_rate': respiratoryRate,
      'oxygen_saturation': oxygenSaturation,
      'pain_score': painScore,
      'bp_systolic': bpSystolic,
      'bp_diastolic': bpDiastolic,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
