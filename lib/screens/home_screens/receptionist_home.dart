// File: lib/screens/home_screens/receptionist_home.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dooflii_clinic_app/widgets/logout_button.dart';

class ReceptionistHome extends StatefulWidget {
  const ReceptionistHome({super.key});

  @override
  State<ReceptionistHome> createState() => _ReceptionistHomeState();
}

// ------------------------
// Typed RPC response models
// ------------------------
class PatientIdResponse {
  final String patientId;
  PatientIdResponse({required this.patientId});

  factory PatientIdResponse.fromMap(Map<String, dynamic> map) {
    return PatientIdResponse(patientId: map['patient_id']?.toString() ?? '');
  }
}

class VisitIdResponse {
  final String visitId;
  VisitIdResponse({required this.visitId});

  factory VisitIdResponse.fromMap(Map<String, dynamic> map) {
    return VisitIdResponse(visitId: map['visit_id']?.toString() ?? '');
  }
}

// ------------------------
// ReceptionistHome State
// ------------------------
class _ReceptionistHomeState extends State<ReceptionistHome> {
  final SupabaseClient supabase = Supabase.instance.client;

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

  @override
  void dispose() {
    phoneController.dispose();
    fullNameController.dispose();
    ageController.dispose();
    addressController.dispose();
    feeController.dispose();
    super.dispose();
  }

  // ------------------------
  // RPC helpers
  Future<PatientIdResponse> fetchPatientId() async {
    final Map<String, dynamic>? response =
        await supabase.rpc('generate_patient_id').maybeSingle();

    if (response == null) throw 'Failed to generate patient ID';

    // Always expect a Map<String, dynamic> with a "patient_id" field
    final patientId = response['patient_id']?.toString();
    if (patientId == null || patientId.isEmpty) {
      throw 'RPC returned null or empty patient_id';
    }

    return PatientIdResponse(patientId: patientId);
  }

  Future<VisitIdResponse> fetchVisitId() async {
    final Map<String, dynamic>? response =
        await supabase.rpc('generate_visit_id').maybeSingle();

    if (response == null) throw 'Failed to generate visit ID';

    final visitId = response['visit_id']?.toString();
    if (visitId == null || visitId.isEmpty) {
      throw 'RPC returned null or empty visit_id';
    }

    return VisitIdResponse(visitId: visitId);
  }

  // ------------------------
  // Check existing patient
  // ------------------------
  Future<void> _checkPatient() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnack('Please enter phone number.');
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
      final existing = await supabase
          .from('patients')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (existing != null) {
        setState(() {
          isExistingPatient = true;
          fullNameController.text = existing['full_name'] ?? '';
          ageController.text = existing['age']?.toString() ?? '';
          gender = existing['gender'] ?? 'Male';
          addressController.text = existing['address'] ?? '';
          patientId = existing['patient_id'] ?? '';
        });
        _showSnack('Returning patient loaded.');
      } else {
        _showSnack('No existing patient. Fill details for new patient.');
      }
    } catch (e) {
      _showSnack('Error checking patient: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ------------------------
  // Approve payment
  // ------------------------
  Future<void> _approvePayment() async {
    final fee = double.tryParse(feeController.text.trim()) ?? 0.0;
    if (fee <= 0) {
      _showSnack('Enter a valid registration fee before approving payment.');
      return;
    }

    setState(() {
      isPaymentApproved = true;
      isLoading = true;
    });

    try {
      if (!isExistingPatient || patientId.isEmpty) {
        final rpcResult = await fetchPatientId();
        patientId = rpcResult.patientId;
      }
      _showSnack('Payment approved. Ready to register patient.');
    } catch (e) {
      _showSnack('Error during approval: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ------------------------
  // Register patient + visit
  // ------------------------
  Future<void> _registerPatient() async {
    final ageText = ageController.text.trim();

    if (fullNameController.text.trim().isEmpty) {
      _showSnack('Full name is required.');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      _showSnack('Phone is required.');
      return;
    }

    if (ageText.isEmpty) {
      _showSnack('Age is required.');
      return;
    }

    if (!isPaymentApproved) {
      _showSnack('Approve payment first.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final phone = phoneController.text.trim();
      final fullName = fullNameController.text.trim();
      final age = int.tryParse(ageText) ?? 0;
      final address = addressController.text.trim();
      final fee = double.tryParse(feeController.text.trim()) ?? 0.0;

      // ------------------------
      // Insert or update patient
      // ------------------------
      if (!isExistingPatient) {
        final patientMap = {
          if (patientId.isNotEmpty) 'patient_id': patientId,
          'phone': phone,
          'full_name': fullName,
          'age': age,
          'gender': gender,
          'address': address,
          'registration_fee': fee,
        };

        final insertedPatient = await supabase
            .from('patients')
            .insert(patientMap)
            .select()
            .maybeSingle();

        if (insertedPatient == null) throw 'Failed to create patient';

        patientId = (insertedPatient['patient_id'] ?? patientId).toString();
      } else {
        await supabase
            .from('patients')
            .update({'address': address, 'registration_fee': fee}).eq(
                'patient_id', patientId);
      }

      // ------------------------
      // Insert visit
      // ------------------------
      final visitInsert = {
        'patient_id': patientId,
        'registration_fee_paid': true,
      };

      final insertedVisit = await supabase
          .from('visits')
          .insert(visitInsert)
          .select()
          .maybeSingle();

      if (insertedVisit == null) throw 'Failed to create visit';

      visitId = (insertedVisit['visit_id'] ?? '').toString();

      _showSnack('Registration successful: $patientId / $visitId');

      // Reset form (keep phone for quick next registration)
      setState(() {
        fullNameController.clear();
        ageController.clear();
        addressController.clear();
        feeController.clear();
        isExistingPatient = false;
        isPaymentApproved = false;
      });
    } catch (e) {
      _showSnack('Registration failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _buildIconTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
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
    final themeBlue = const Color(0xFF64B5F6);

    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Receptionist Home'),
          actions: const [LogoutButton()],
          backgroundColor: themeBlue,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Phone search
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Search / New Patient',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            _buildIconTextField(
                              controller: phoneController,
                              label: 'Phone Number',
                              icon: Icons.phone_android,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.search),
                              label: const Text('Check Patient'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: themeBlue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              onPressed: _checkPatient,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Patient info
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Patient Information',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              _buildIconTextField(
                                controller: fullNameController,
                                label: 'Full Name',
                                icon: Icons.person,
                              ),
                              const SizedBox(height: 10),
                              _buildIconTextField(
                                controller: ageController,
                                label: 'Age',
                                icon: Icons.numbers,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: gender,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.wc),
                                  labelText: 'Gender',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Male', child: Text('Male')),
                                  DropdownMenuItem(
                                      value: 'Female', child: Text('Female')),
                                ],
                                onChanged: (v) =>
                                    setState(() => gender = v ?? 'Male'),
                              ),
                              const SizedBox(height: 10),
                              _buildIconTextField(
                                  controller: addressController,
                                  label: 'Address',
                                  icon: Icons.location_on),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Payment',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              _buildIconTextField(
                                  controller: feeController,
                                  label: 'Registration Fee (ETB)',
                                  icon: Icons.attach_money,
                                  keyboardType: TextInputType.number),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: Icon(isPaymentApproved
                                    ? Icons.check_circle
                                    : Icons.payment),
                                label: Text(isPaymentApproved
                                    ? 'Payment Approved'
                                    : 'Approve Payment'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: isPaymentApproved
                                        ? Colors.green
                                        : themeBlue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                onPressed:
                                    isPaymentApproved ? null : _approvePayment,
                              ),
                              const SizedBox(height: 12),
                              if (patientId.isNotEmpty && visitId.isNotEmpty)
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Patient ID',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                              const SizedBox(height: 6),
                                              Text(patientId,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ]),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Visit ID',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                              const SizedBox(height: 6),
                                              Text(visitId,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ]),
                                      ),
                                    ]),
                            ]),
                      ),
                    ),

                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _registerPatient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Register Patient',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}
