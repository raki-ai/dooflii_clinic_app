// File: lib/screens/home_screens/nurse_home.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../modules/registration/patient_model.dart';
import '../../modules/triage/triage_entry_screen.dart';
import '../../modules/triage/triage_service.dart';

class NurseHome extends StatefulWidget {
  const NurseHome({super.key});

  @override
  State<NurseHome> createState() => _NurseHomeState();
}

class _NurseHomeState extends State<NurseHome> {
  final TextEditingController searchController = TextEditingController();
  final supabase = Supabase.instance.client;

  Patient? selectedPatient;
  Map<String, dynamic>? selectedVisit;

  bool isSearching = false;

  /// Search patients by phone or name
  Future<void> _performSearch() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => isSearching = true);

    final res = await supabase
        .from('patients')
        .select()
        .or('phone.ilike.%$query%,full_name.ilike.%$query%')
        .maybeSingle();

    if (res == null) {
      setState(() {
        selectedPatient = null;
        selectedVisit = null;
        isSearching = false;
      });
      return;
    }

    final patient = Patient.fromMap(res);

    // Get latest visit without a triage
    final visitRes = await supabase
        .from('visits')
        .select('id, visit_id, visit_number, patient_id, created_at')
        .eq('patient_id', patient.patientId)
        .not('visit_id', 'in', '''
            (SELECT visit_id FROM triage)
        ''')
        .order('created_at', ascending: true)
        .maybeSingle();

    setState(() {
      selectedPatient = patient;
      selectedVisit = visitRes;
      isSearching = false;
    });
  }

  Future<void> _openTriage() async {
    if (selectedPatient == null || selectedVisit == null) return;

    final visitId = selectedVisit!['visit_id'] as String;
    final visitNumber = selectedVisit!['visit_number'] as int;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TriageEntryScreen(
          patient: selectedPatient!,
          visitId: visitId,
          visitNumber: visitNumber,
        ),
      ),
    );
  }

  /// Stream visits waiting for triage
  Stream<List<Map<String, dynamic>>> queueStream() {
    // Return visits that do not have a triage yet
    return supabase
        .from('visits')
        .stream(primaryKey: ['visit_id'])
        .order('created_at', ascending: true)
        .map((visits) {
          final List<Map<String, dynamic>> waiting = [];
          for (var v in visits) {
            // Only include visits that do not have a triage
            // Supabase Realtime cannot do joins, so this is filtered client-side
            if (v['visit_id'] != null && v['triage_exists'] != true) {
              waiting.add(v as Map<String, dynamic>);
            }
          }
          return waiting;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nurse Home'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SEARCH FIELD
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search by name or phone",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      selectedPatient = null;
                      selectedVisit = null;
                    });
                  },
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),

            const SizedBox(height: 12),
            if (isSearching) const LinearProgressIndicator(),

            // PATIENT INFO
            if (selectedPatient != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${selectedPatient!.fullName}"),
                      Text("Phone: ${selectedPatient!.phone}"),
                      Text("Age: ${selectedPatient!.age}"),
                      Text("Gender: ${selectedPatient!.gender}"),
                      Text("Address: ${selectedPatient!.address}"),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // START TRIAGE BUTTON
            if (selectedVisit != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.local_hospital),
                label: const Text("Start / View Triage"),
                onPressed: _openTriage,
              ),

            const SizedBox(height: 20),

            // QUEUE LIST
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Patients Waiting for Triage",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: queueStream(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final queue = snapshot.data!;
                if (queue.isEmpty) {
                  return const Text("No patients in queue.");
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: queue.length,
                  itemBuilder: (_, i) {
                    final v = queue[i];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(v['patient_name'] ?? ''),
                        subtitle: Text('Visit #${v['visit_number']}'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () async {
                          // load patient info
                          final p = await supabase
                              .from('patients')
                              .select()
                              .eq('patient_id', v['patient_id'])
                              .maybeSingle();

                          if (p == null) return;

                          setState(() {
                            selectedPatient = Patient.fromMap(p);
                            selectedVisit = v;
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
