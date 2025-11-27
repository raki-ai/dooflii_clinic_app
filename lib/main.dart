import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'utils/constants.dart';
import 'providers/auth_provider.dart';
import 'login_screen.dart';
import 'modules/registration/registration_entry_screen.dart';
// Future: import other home screens as needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase using your constants
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dooflii Clinic App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/registration': (_) => const RegistrationEntryScreen(),
        // Add other module routes here later (triage, consultation, lab, etc.)
      },
    );
  }
}
