// File: lib/modules/triage/triage_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'triage_service.dart';
import 'triage_model.dart';
import '../registration/patient_model.dart';

class TriageListScreen extends StatefulWidget {
  final Patient patient;

  const TriageListScreen({super.key, required this.patient});

  @override
  State<TriageListScreen> createState() => _TriageListScreenState();
}

class _TriageListScreenState extends State<TriageListScreen> {
  final TriageService _service = TriageService();
  List<Triage> triages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTriages();
  }

  Future<void> _loadTriages() async {
    setState(() => isLoading = true);
    try {
      triages = await _service.getTriagesByPatient(widget.patient.patientId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load triages: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  Widget _buildTriageCard(Triage triage) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visit ID: ${triage.visitId}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Created At: ${formatDate(triage.createdAt)}'),
            const SizedBox(height: 4),
            Text(
                'Weight: ${triage.weightKg} kg, Height: ${triage.heightCm} cm, BMI: ${triage.bmi}'),
            const SizedBox(height: 4),
            Text(
                'Temp: ${triage.temperature} °C, Pulse: ${triage.pulseRate}, Resp: ${triage.respiratoryRate}, O₂: ${triage.oxygenSaturation}%'),
            const SizedBox(height: 4),
            Text(
                'BP: ${triage.bpSystolic}/${triage.bpDiastolic}, Pain Score: ${triage.painScore}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Triage List - ${widget.patient.fullName}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTriages,
              child: triages.isEmpty
                  ? const Center(child: Text('No triage records found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: triages.length,
                      itemBuilder: (_, index) =>
                          _buildTriageCard(triages[index]),
                    ),
            ),
    );
  }
}
