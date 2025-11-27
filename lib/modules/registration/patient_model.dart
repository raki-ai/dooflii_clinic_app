class Patient {
  final String patientId;
  final String fullName;
  final String phone;
  final int age;
  final String gender;
  final String address;

  Patient({
    required this.patientId,
    required this.fullName,
    required this.phone,
    required this.age,
    required this.gender,
    required this.address,
  });

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      patientId: map['patient_id'] as String,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String,
      age: map['age'] as int? ?? 0,
      gender: map['gender'] as String? ?? 'Male',
      address: map['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'full_name': fullName,
      'phone': phone,
      'age': age,
      'gender': gender,
      'address': address,
      // DOB removed completely
    };
  }
}
