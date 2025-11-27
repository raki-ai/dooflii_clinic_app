// File: lib/home_redirect.dart

import 'package:flutter/material.dart';
import 'screens/home_screens/nurse_home.dart';
import 'modules/registration/registration_entry_screen.dart';
import 'modules/registration/patient_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRedirect extends StatelessWidget {
  const HomeRedirect({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> _getUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final res = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return res as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snapshot.data;
        final role = profile?['role'] as String? ?? 'guest';

        if (role == 'nurse') {
          // Open NurseHome
          return NurseHome();
        }

        // Default fallback for admin or other roles
        return const RegistrationEntryScreen();
      },
    );
  }
}
