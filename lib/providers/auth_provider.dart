import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  Session? _session;
  String? _role;

  Session? get session => _session;
  String? get role => _role;

  Future<void> init() async {
    _session = _client.auth.currentSession;
    if (_session != null) await _fetchUserRole();
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _session = response.session;
      await _fetchUserRole();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    _session = null;
    _role = null;
    notifyListeners();
  }

  Future<void> _fetchUserRole() async {
    final userId = _session?.user.id;
    if (userId == null) return;
    final result = await _client
        .from('user_roles')
        .select('role')
        .eq('user_id', userId)
        .maybeSingle();
    _role = result?['role'];
  }
}
