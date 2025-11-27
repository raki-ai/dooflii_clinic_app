// File: lib/modules/registration/registration_list_screen.dart

import 'package:flutter/material.dart';
import 'registration_service.dart';
import 'package:dooflii_clinic_app/modules/registration/patient_model.dart';
import 'registration_entry_screen.dart';

class RegistrationListScreen extends StatefulWidget {
  const RegistrationListScreen({super.key});

  @override
  State<RegistrationListScreen> createState() => _RegistrationListScreenState();
}

class _RegistrationListScreenState extends State<RegistrationListScreen> {
  final RegistrationService _service = RegistrationService();
  bool isLoading = true;
  List<Patient> patients = [];

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() => isLoading = true);

    try {
      // Use the new getAllPatients() method from RegistrationService
      patients = await _service.getAllPatients();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching patients: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registered Patients')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patients.isEmpty
              ? const Center(child: Text('No patients found.'))
              : ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (_, index) {
                    final patient = patients[index];
                    return ListTile(
                      title: Text(patient.fullName),
                      subtitle:
                          Text('Phone: ${patient.phone}, Age: ${patient.age}'),
                      trailing: Text(patient.gender),
                      onTap: () {
                        // Optionally, pass patient to entry screen to edit
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegistrationEntryScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
