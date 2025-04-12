import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class AppBarParameters extends ChangeNotifier {
  String _selectedClinicName = '';
  String _clinicId = '';
  List<String> _clinicNames = [];

  String get selectedClinicName => _selectedClinicName;
  List<String> get clinicNames => _clinicNames;

  void updateParameters(String selectedClinicName, List<String> clinicNames) {
    devtools.log('**************************************');

    devtools.log('Welcome to updateParameters inside AppBarParameters class');
    devtools.log(
        'Updating parameters - SelectedClinicName: $selectedClinicName, ClinicNames: $clinicNames');
    devtools.log('**************************************');

    _selectedClinicName = selectedClinicName;
    _clinicNames = clinicNames;
    notifyListeners();
  }

  void updateClinic(String selectedClinicName, String clinicId) {
    devtools.log('**************************************');
    devtools.log('Welcome to updateClinic inside AppBarParameters class');
    devtools.log(
        'Updating clinic - SelectedClinicName: $selectedClinicName, ClinicId: $clinicId');
    devtools.log('**************************************');

    _selectedClinicName = selectedClinicName;
    // Update clinicId if needed
    _clinicId = clinicId;

    notifyListeners();
  }

  // ... existing code ...

  void updateClinicNames(List<String> clinicNames) {
    devtools.log('**************************************');
    devtools.log('Welcome to updateClinicNames inside AppBarParameters class');
    devtools.log('Updating clinic names - ClinicNames: $clinicNames');
    devtools.log('**************************************');

    _clinicNames = clinicNames;
    notifyListeners();
  }
}

// import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

// class AppBarParameters extends ChangeNotifier {
//   String _selectedClinicName = '';
//   List<String> _clinicNames = [];

//   String get selectedClinicName => _selectedClinicName;
//   List<String> get clinicNames => _clinicNames;

//   void updateParameters(String selectedClinicName, List<String> clinicNames) {
//     devtools.log('**************************************');

//     devtools.log('Welcome to updateParameters inside AppBarParameters class');
//     devtools.log(
//         'Updating parameters - SelectedClinicName: $selectedClinicName, ClinicNames: $clinicNames');
//     devtools.log('**************************************');

//     _selectedClinicName = selectedClinicName;
//     _clinicNames = clinicNames;
//     notifyListeners();
//   }
// }
