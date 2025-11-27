import 'dart:io';

void main() {
  // Base lib path
  final basePath = Directory('lib');

  // List of folders to create
  final folders = [
    'models',
    'helpers',
    'services',
    'widgets',
    'screens/home_screens',
    'constants',
    'modules/registration',
    'modules/triage',
    'modules/doctor_consultation',
    'modules/doctor_cashier',
    'modules/lab',
    'modules/imaging',
    'modules/procedure',
    'modules/pharmacy',
    'modules/admin',
  ];

  // List of files to create
  final files = [
    // Models
    'models/patient_model.dart',
    'models/visit_model.dart',
    'models/triage_model.dart',
    'models/consultation_model.dart',
    'models/test_model.dart',
    'models/prescription_model.dart',
    'models/procedure_model.dart',
    'models/staff_model.dart',

    // Helpers
    'helpers/dropdowns.dart',
    'helpers/validators.dart',
    'helpers/utils.dart',

    // Services
    'services/supabase_service.dart',

    // Screens
    'screens/home_screens/receptionist_home.dart',
    'screens/home_screens/cashier_home.dart',
    'screens/home_screens/admin_home.dart',
    'screens/login_screen.dart',
    'screens/splash_screen.dart',

    // Widgets
    'widgets/logout_button.dart',
    'widgets/custom_textfield.dart',
    'widgets/patient_card.dart',
    'widgets/loading_overlay.dart',

    // Constants
    'constants/colors.dart',
    'constants/sizes.dart',
    'constants/strings.dart',

    // Modules - Registration
    'modules/registration/registration_entry_screen.dart',
    'modules/registration/registration_list_screen.dart',
    'modules/registration/registration_helper.dart',

    // Modules - Triage
    'modules/triage/triage_entry_screen.dart',
    'modules/triage/triage_list_screen.dart',
    'modules/triage/triage_helper.dart',

    // Modules - Doctor Consultation
    'modules/doctor_consultation/consultation_entry_screen.dart',
    'modules/doctor_consultation/consultation_list_screen.dart',
    'modules/doctor_consultation/consultation_helper.dart',
    'modules/doctor_consultation/consultation_models.dart',

    // Modules - Doctor Cashier
    'modules/doctor_cashier/doctor_services_pending_payment_list_screen.dart',
    'modules/doctor_cashier/doctor_cashier_helper.dart',

    // Modules - Lab
    'modules/lab/lab_entry_screen.dart',
    'modules/lab/lab_queue_screen.dart',
    'modules/lab/lab_helper.dart',

    // Modules - Imaging
    'modules/imaging/imaging_entry_screen.dart',
    'modules/imaging/imaging_queue_screen.dart',
    'modules/imaging/imaging_helper.dart',

    // Modules - Procedure
    'modules/procedure/procedure_entry_screen.dart',
    'modules/procedure/procedure_queue_screen.dart',
    'modules/procedure/procedure_helper.dart',

    // Modules - Pharmacy
    'modules/pharmacy/pharmacy_pending_payment_list_screen.dart',
    'modules/pharmacy/pharmacy_dispense_screen.dart',
    'modules/pharmacy/pharmacy_helper.dart',

    // Modules - Admin
    'modules/admin/admin_home.dart',
    'modules/admin/reports_screen.dart',
    'modules/admin/admin_helper.dart',
  ];

  // Create folders
  for (var folder in folders) {
    final dir = Directory('${basePath.path}/$folder');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
      print('Created folder: ${dir.path}');
    }
  }

  // Create files
  for (var filePath in files) {
    final file = File('${basePath.path}/$filePath');
    if (!file.existsSync()) {
      file.createSync(recursive: true);
      print('Created file: ${file.path}');
    }
  }

  print('✅ Full Flutter folder structure created successfully!');
}
