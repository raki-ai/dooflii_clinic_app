import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Initialize Supabase
  final supabase = SupabaseClient(
    'https://yokwvjiepbftbmrbbpfp.supabase.co',
    'YOUR-SERVICE-ROLE-KEY', // replace with your Service Role Key
  );

  // List of all user UUIDs
  final List<String> userIds = [
    '2519520b-1bfc-47b7-8367-b4616d1c87a0', // admin
    '2cf88a70-1a91-4add-80d1-01db74aa9913', // receptionist_cashier
    '3708026a-d336-41b3-b11d-a42882b4648d', // nurse
    '7b4dabe3-6fe9-44cf-b5a0-53a195fc6c0b', // radiologist
    'a413b79b-1972-486c-b7ee-d12bd2b888df', // lab
    'b72e347b-9017-4b0b-84c1-3ff6f4c7ccdd', // pharmacist_cashier
    'bcf3ab22-89bc-4249-8111-b80bd82df1d9', // doctor
    'd0b6d3a3-347f-42e9-b3b7-e223371e8500', // nurse
    'f3906495-398d-4722-9832-8dd89fbdef4e', // receptionist_cashier
    '728c789c-3695-481b-b6a3-6b0aae0beb1d', // admin
  ];

  // New password
  const newPassword = '112233';

  // Loop through users and update password
  for (var userId in userIds) {
    try {
      final response = await supabase.auth.admin.updateUserById(
        userId,
        attributes: AdminUserAttributes(
          password: newPassword,
          emailConfirm: true, // optionally confirm the user
        ),
      );
      print('Password updated for user $userId');
    } catch (e) {
      print('Error updating user $userId: $e');
    }
  }

  print('All passwords updated!');
}
