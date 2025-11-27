// File: lib/modules/triage/triage_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'triage_model.dart';

class TriageService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Save or update a triage record for a visit
  /// Returns the triage record ID
  Future<String> saveOrUpdateTriage(Map<String, dynamic> data) async {
    final visitId = data['visit_id'] as String?;
    if (visitId == null || visitId.isEmpty) {
      throw Exception('visit_id is required to save triage.');
    }

    // Check if a triage already exists for this visit
    final existing = await getTriageByVisitId(visitId);

    if (existing != null) {
      // Update existing record
      final res = await supabase
          .from('triage')
          .update(data)
          .eq('id', existing.id)
          .select()
          .maybeSingle();

      final id = res?['id'] as String?;
      if (id == null) throw Exception('Failed to update triage record.');
      return id;
    } else {
      // Insert new record
      final res =
          await supabase.from('triage').insert([data]).select().maybeSingle();

      final id = res?['id'] as String?;
      if (id == null) throw Exception('Failed to save triage record.');
      return id;
    }
  }

  /// Get all triages for a patient
  Future<List<Triage>> getTriagesByPatient(String patientId) async {
    final res = await supabase
        .from('triage')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false);

    return (res as List<dynamic>)
        .map((e) => Triage.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a triage by visit_id
  Future<Triage?> getTriageByVisitId(String visitId) async {
    final res = await supabase
        .from('triage')
        .select()
        .eq('visit_id', visitId)
        .maybeSingle();

    if (res == null) return null;
    return Triage.fromMap(res as Map<String, dynamic>);
  }

  /// Delete a triage
  Future<void> deleteTriage(String id) async {
    await supabase.from('triage').delete().eq('id', id);
  }
}
