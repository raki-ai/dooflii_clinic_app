// File: lib/modules/triage/triage_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:dooflii_clinic_app/modules/triage/triage_service.dart';
import 'package:dooflii_clinic_app/modules/triage/triage_helper.dart';
import 'package:dooflii_clinic_app/modules/registration/patient_model.dart';

class TriageEntryScreen extends StatefulWidget {
  final Patient patient;
  final String visitId;
  final int visitNumber;

  const TriageEntryScreen({
    super.key,
    required this.patient,
    required this.visitId,
    required this.visitNumber,
  });

  @override
  State<TriageEntryScreen> createState() => _TriageEntryScreenState();
}

class _TriageEntryScreenState extends State<TriageEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final bmiController = TextEditingController();
  final tempController = TextEditingController();
  final pulseController = TextEditingController();
  final respController = TextEditingController();
  final oxygenController = TextEditingController();
  final painController = TextEditingController();
  final bpSystolicController = TextEditingController();
  final bpDiastolicController = TextEditingController();

  bool isLoading = false;
  final TriageService _service = TriageService();

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    bmiController.dispose();
    tempController.dispose();
    pulseController.dispose();
    respController.dispose();
    oxygenController.dispose();
    painController.dispose();
    bpSystolicController.dispose();
    bpDiastolicController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    final weight = double.tryParse(weightController.text) ?? 0.0;
    final height = double.tryParse(heightController.text) ?? 0.0;
    if (weight > 0 && height > 0) {
      final bmi = TriageHelper.calculateBMI(weightKg: weight, heightCm: height);
      bmiController.text = bmi.toStringAsFixed(2);
    } else {
      bmiController.text = '';
    }
  }

  Future<void> _saveTriage() async {
    if (_formKey.currentState?.validate() != true) return;

    if (widget.patient.patientId.isEmpty || widget.visitId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient ID or Visit ID is missing.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = {
        'patient_id': widget.patient.patientId,
        'visit_id': widget.visitId,
        'visit_number': widget.visitNumber,
        'full_name': widget.patient.fullName,
        'age': widget.patient.age,
        'gender': widget.patient.gender,
        'address': widget.patient.address,
        'weight_kg': double.tryParse(weightController.text) ?? 0.0,
        'height_cm': double.tryParse(heightController.text) ?? 0.0,
        'bmi': double.tryParse(bmiController.text) ?? 0.0,
        'temperature': double.tryParse(tempController.text) ?? 0.0,
        'pulse_rate': int.tryParse(pulseController.text) ?? 0,
        'respiratory_rate': int.tryParse(respController.text) ?? 0,
        'oxygen_saturation': int.tryParse(oxygenController.text) ?? 0,
        'pain_score': int.tryParse(painController.text) ?? 0,
        'bp_systolic': int.tryParse(bpSystolicController.text) ?? 0,
        'bp_diastolic': int.tryParse(bpDiastolicController.text) ?? 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      final triageId = await _service.saveOrUpdateTriage(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Triage saved successfully: $triageId')),
      );

      _formKey.currentState?.reset();
      bmiController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save triage: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildIconTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? onChanged,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (_) => onChanged?.call(),
      readOnly: readOnly,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Triage Entry')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${widget.patient.fullName}'),
                          Text('Phone: ${widget.patient.phone}'),
                          Text('Age: ${widget.patient.age}'),
                          Text('Gender: ${widget.patient.gender}'),
                          Text('Address: ${widget.patient.address}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildIconTextField(
                          controller: weightController,
                          label: 'Weight (kg)',
                          icon: Icons.fitness_center,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              TriageHelper.validateWeightHeight(v, 'Weight'),
                          onChanged: _calculateBMI,
                        ),
                        const SizedBox(height: 10),
                        _buildIconTextField(
                          controller: heightController,
                          label: 'Height (cm)',
                          icon: Icons.height,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              TriageHelper.validateWeightHeight(v, 'Height'),
                          onChanged: _calculateBMI,
                        ),
                        const SizedBox(height: 10),
                        _buildIconTextField(
                          controller: bmiController,
                          label: 'BMI',
                          icon: Icons.monitor_weight,
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        _buildIconTextField(
                          controller: tempController,
                          label: 'Temperature (°C)',
                          icon: Icons.thermostat,
                          keyboardType: TextInputType.number,
                          validator: TriageHelper.validateNumeric,
                        ),
                        const SizedBox(height: 10),
                        _buildIconTextField(
                          controller: pulseController,
                          label: 'Pulse Rate',
                          icon: Icons.favorite,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              TriageHelper.validatePositiveInteger(
                                  v, 'Pulse Rate'),
                        ),
                        const SizedBox(height: 10),
                        _buildIconTextField(
                          controller: respController,
                          label: 'Respiratory Rate',
                          icon: Icons.air,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              TriageHelper.validatePositiveInteger(
                                  v, 'Respiratory Rate'),
                        ),
                        const SizedBox(height: 10),
                        _buildIconTextField(
                          controller: oxygenController,
                          label: 'Oxygen Saturation',
                          icon: Icons.bloodtype,
                          keyboardType: TextInputType.number,
                          validator: TriageHelper.validateOxygen,
                        ),
                        const SizedBox(height: 10),
                        _buildIconTextField(
                          controller: painController,
                          label: 'Pain Score (1-10)',
                          icon: Icons.sentiment_very_dissatisfied,
                          keyboardType: TextInputType.number,
                          validator: TriageHelper.validatePainScore,
                        ),
                        const SizedBox(height: 10),
                        _buildIconTextField(
                          controller: bpSystolicController,
                          label: 'BP Systolic',
                          icon: Icons.monitor_heart,
                          keyboardType: TextInputType.number,
                          validator: TriageHelper.validateBP,
                        ),
                        const SizedBox(height: 10),
                        _buildIconTextField(
                          controller: bpDiastolicController,
                          label: 'BP Diastolic',
                          icon: Icons.monitor_heart,
                          keyboardType: TextInputType.number,
                          validator: TriageHelper.validateBP,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveTriage,
                          child: const Text('Save Triage'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
