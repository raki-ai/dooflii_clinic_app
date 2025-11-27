import 'package:flutter/material.dart';

class RegistrationHelper {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Full name is required';
    if (value.length < 3) return 'Full name must be at least 3 characters';
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) return 'Age is required';
    final age = int.tryParse(value);
    if (age == null || age <= 0 || age > 120) return 'Enter a valid age';
    return null;
  }

  static String? validateFee(String? value) {
    if (value == null || value.isEmpty) return 'Registration fee is required';
    final fee = double.tryParse(value);
    if (fee == null || fee < 0) return 'Enter a valid fee';
    return null;
  }

  static void showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static String formatAmount(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  static bool isFreeRegistration(DateTime? lastVisitDate) {
    if (lastVisitDate == null) return false;
    final daysSinceLastVisit = DateTime.now().difference(lastVisitDate).inDays;
    return daysSinceLastVisit < 10;
  }
}
