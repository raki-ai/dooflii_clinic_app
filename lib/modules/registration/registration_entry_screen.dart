// File: lib/modules/registration/registration_entry_screen.dart

import 'package:flutter/material.dart';
import 'registration_service.dart';
import 'registration_helper.dart';
import 'package:dooflii_clinic_app/modules/registration/patient_model.dart';
import '../../widgets/logout_button.dart';
import 'registration_list_screen.dart';

class RegistrationEntryScreen extends StatefulWidget {
  const RegistrationEntryScreen({super.key});

  @override
  State<RegistrationEntryScreen> createState() =>
      _RegistrationEntryScreenState();
}

class _RegistrationEntryScreenState extends State<RegistrationEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final phoneController = TextEditingController();
  final fullNameController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();
  final feeController = TextEditingController();

  String gender = 'Male';
  String patientId = '';
  String visitId = '';
  bool isExistingPatient = false;
  bool isPaymentApproved = false;
  bool isLoading = false;

  final RegistrationService _service = RegistrationService();

  @override
  void dispose() {
    phoneController.dispose();
    fullNameController.dispose();
    ageController.dispose();
    addressController.dispose();
    feeController.dispose();
    super.dispose();
  }

  Future<void> _checkPatient() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      RegistrationHelper.showSnack(context, 'Please enter phone number.');
      return;
    }

    setState(() {
      isLoading = true;
      isExistingPatient = false;
      patientId = '';
      visitId = '';
      isPaymentApproved = false;
    });

    try {
      final existingPatient = await _service.getPatientByPhone(phone);

      if (existingPatient != null) {
        setState(() {
          isExistingPatient = true;
          fullNameController.text = existingPatient.fullName;
          ageController.text = existingPatient.age.toString();
          gender = existingPatient.gender;
          addressController.text = existingPatient.address;
          patientId = existingPatient.patientId;
        });

        // Check last visit for 10-day free registration
        final lastVisit =
            await _service.getLastVisit(existingPatient.patientId);
        if (lastVisit != null && lastVisit['created_at'] != null) {
          final lastVisitDate =
              DateTime.parse(lastVisit['created_at'] as String);
          if (RegistrationHelper.isFreeRegistration(lastVisitDate)) {
            RegistrationHelper.showSnack(
              context,
              'Patient visited within last 10 days. Registration can be free.',
            );
          }
        }

        RegistrationHelper.showSnack(context, 'Returning patient loaded.');
      } else {
        RegistrationHelper.showSnack(
            context, 'No existing patient. Fill details for new patient.');
      }
    } catch (e) {
      RegistrationHelper.showSnack(context, 'Error checking patient: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _approvePayment() async {
    final fee = double.tryParse(feeController.text.trim()) ?? 0.0;
    if (fee < 0) {
      RegistrationHelper.showSnack(
          context, 'Enter a valid registration fee before approving.');
      return;
    }

    if (!isExistingPatient || patientId.isEmpty) {
      try {
        patientId = await _service.generatePatientId();
      } catch (e) {
        RegistrationHelper.showSnack(
            context, 'Error generating patient ID: $e');
        return;
      }
    }

    setState(() {
      isPaymentApproved = true;
    });
    RegistrationHelper.showSnack(
        context, 'Payment approved. Ready to register patient.');
  }

  Future<void> _registerPatient() async {
    if (!isPaymentApproved) {
      RegistrationHelper.showSnack(context, 'Approve payment first.');
      return;
    }

    if (_formKey.currentState?.validate() != true) return;

    final age = int.tryParse(ageController.text.trim()) ?? 0;
    if (age <= 0) {
      RegistrationHelper.showSnack(context, 'Enter a valid age.');
      return;
    }

    final registrationFee = double.tryParse(feeController.text.trim()) ?? 0.0;

    setState(() => isLoading = true);

    try {
      final patient = Patient(
        patientId: patientId,
        phone: phoneController.text.trim(),
        fullName: fullNameController.text.trim(),
        age: age,
        gender: gender,
        address: addressController.text.trim(),
      );

      visitId = await _service.registerPatient(
        patient,
        registrationFee: registrationFee,
      );

      RegistrationHelper.showSnack(
          context, 'Registration successful: ${patient.patientId} / $visitId');

      // Reset form except phone
      fullNameController.clear();
      ageController.clear();
      addressController.clear();
      feeController.clear();
      setState(() {
        isExistingPatient = false;
        isPaymentApproved = false;
      });
    } catch (e) {
      RegistrationHelper.showSnack(context, 'Registration failed: $e');
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
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Registration'),
        actions: const [LogoutButton()],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search patient
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildIconTextField(
                            controller: phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_android,
                            validator: RegistrationHelper.validatePhone,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                              onPressed: _checkPatient,
                              child: const Text('Check Patient')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Patient info + form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildIconTextField(
                          controller: fullNameController,
                          label: 'Full Name',
                          icon: Icons.person,
                          validator: RegistrationHelper.validateFullName,
                        ),
                        const SizedBox(height: 10),
                        _buildIconTextField(
                          controller: ageController,
                          label: 'Age',
                          icon: Icons.numbers,
                          keyboardType: TextInputType.number,
                          validator: RegistrationHelper.validateAge,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: gender,
                          items: const [
                            DropdownMenuItem(
                                value: 'Male', child: Text('Male')),
                            DropdownMenuItem(
                                value: 'Female', child: Text('Female')),
                          ],
                          onChanged: (v) =>
                              setState(() => gender = v ?? 'Male'),
                          decoration: const InputDecoration(
                              labelText: 'Gender', prefixIcon: Icon(Icons.wc)),
                        ),
                        const SizedBox(height: 10),
                        _buildIconTextField(
                          controller: addressController,
                          label: 'Address',
                          icon: Icons.location_on,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter address' : null,
                        ),
                        const SizedBox(height: 10),
                        _buildIconTextField(
                          controller: feeController,
                          label: 'Registration Fee',
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          validator: RegistrationHelper.validateFee,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed:
                                isPaymentApproved ? null : _approvePayment,
                            child: Text(isPaymentApproved
                                ? 'Payment Approved'
                                : 'Approve Payment')),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: _registerPatient,
                            child: const Text('Register Patient')),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const RegistrationListScreen()));
                            },
                            child: const Text('View Registration List')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
