// File: lib/modules/registration/registration_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'patient_model.dart';

class RegistrationService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Generate a unique patient ID using your RPC function
  Future<String> generatePatientId() async {
    final res = await supabase.rpc('generate_patient_id').maybeSingle();
    final generated = res?['patient_id'] as String?;
    if (generated == null) {
      throw Exception('Failed to generate patient ID.');
    }
    return generated;
  }

  /// Get patient by phone number
  Future<Patient?> getPatientByPhone(String phone) async {
    final res = await supabase
        .from('patients')
        .select()
        .eq('phone', phone)
        .maybeSingle();

    if (res == null) return null;
    return Patient.fromMap(res as Map<String, dynamic>);
  }

  /// Get the last visit for a patient
  Future<Map<String, dynamic>?> getLastVisit(String patientId) async {
    final res = await supabase
        .from('visits')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return res as Map<String, dynamic>?;
  }

  /// Register a patient (insert new patient if not exists, insert visit, insert payment if fee > 0)
  Future<String> registerPatient(Patient patient,
      {required double registrationFee}) async {
    // Check existing patient
    final existing = await getPatientByPhone(patient.phone);
    final patientId = existing?.patientId ?? patient.patientId;

    // Insert new patient if not exists
    if (existing == null) {
      await supabase.from('patients').insert(patient.toMap());
    }

    // 10-day returning patient check
    final lastVisit = await getLastVisit(patientId);
    if (lastVisit != null && lastVisit['created_at'] != null) {
      final lastVisitDate = DateTime.parse(lastVisit['created_at'] as String);
      if (lastVisitDate
          .isAfter(DateTime.now().subtract(const Duration(days: 10)))) {
        registrationFee = 0.0;
      }
    }

    // Insert visit
    final visitRes = await supabase
        .from('visits')
        .insert({
          'patient_id': patientId,
          'registration_fee_paid': registrationFee > 0,
          'registration_fee': registrationFee,
        })
        .select()
        .single();

    final visitId = visitRes['visit_id'] as String?;
    if (visitId == null) {
      throw Exception('Failed to register visit.');
    }

    // Insert payment if registrationFee > 0
    if (registrationFee > 0) {
      await supabase.from('payments').insert({
        'patient_id': patientId,
        'visit_id': visitId,
        'type': 'registration',
        'amount': registrationFee,
        'status': 'paid',
      });
    }

    return visitId;
  }

  /// Fetch all patients
  Future<List<Patient>> getAllPatients() async {
    final res = await supabase.from('patients').select().order('full_name');
    return (res as List)
        .map((e) => Patient.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
