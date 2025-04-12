import 'package:flutter/material.dart';

class ClinicModel extends ChangeNotifier {
  String _selectedClinicName = '';
  String _clinicId = '';
  final List<String> _clinicNames = []; // Add this line

  String get selectedClinicName => _selectedClinicName;
  String get clinicId => _clinicId;
  List<String> get clinicNames => _clinicNames; // Add this line

  void updateClinic(String selectedClinicName, String clinicId) {
    _selectedClinicName = selectedClinicName;
    _clinicId = clinicId;

    notifyListeners();
  }
}

  // void updateClinicNames(List<String> clinicNames) {
  //   _clinicNames = clinicNames;

  //   notifyListeners();
  // }
  // // Add the getClinicId method
  // String getClinicId(String clinicName) {
  //   // Implement logic to retrieve the clinicId based on the clinicName
  //   // For example, if you have a list of clinics, you can find the matching ID.
  //   // Replace the logic below with your actual implementation.
  //   final clinicId = clinicList
  //       .firstWhere(
  //         (clinic) => clinic.name == clinicName,
  //         orElse: () =>
  //             Clinic(id: '', name: ''), // Replace with your actual Clinic model
  //       )
  //       .id;

  //   return clinicId;
  // }
//}


// import 'package:flutter/material.dart';

// class ClinicModel extends ChangeNotifier {
//   String _selectedClinicName = '';
//   String _clinicId = '';

//   String get selectedClinicName => _selectedClinicName;
//   String get clinicId => _clinicId;

//   void updateClinic(String selectedClinicName, String clinicId) {
//     _selectedClinicName = selectedClinicName;
//     _clinicId = clinicId;

//     notifyListeners();
//   }
// }

