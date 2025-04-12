import 'dart:async';
import 'dart:developer' as devtools show log;
import 'package:flutter/foundation.dart';
import 'package:neocaresmileapp/firestore/clinic_service.dart';

class ClinicSelection extends ChangeNotifier {
  static final ClinicSelection _instance = ClinicSelection._();

  late String _selectedClinicName;
  late List<String> _clinicNames;
  late String _selectedClinicId;
  late String _loggedInDoctorId; // New field to store doctorId
  Timer? _debounce;

  // Private constructor
  ClinicSelection._() {
    _selectedClinicName = ''; // Initialize with an empty string
    _clinicNames = [];
    _selectedClinicId = ''; // Initialize _selectedClinicId
    _loggedInDoctorId = ''; // Initialize _doctorId
  }

  // Getter for the instance (singleton pattern)
  static ClinicSelection get instance => _instance;

  // Public getters for state
  String get selectedClinicName => _selectedClinicName;
  List<String> get clinicNames => _clinicNames;
  String get selectedClinicId => _selectedClinicId;
  String get doctorId => _loggedInDoctorId; // Getter for doctorId

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Method to update the doctorId
  void setDoctorId(String doctorId) {
    if (_loggedInDoctorId != doctorId) {
      _loggedInDoctorId = doctorId;
      devtools
          .log('!!!! Doctor ID set to: $doctorId Listeners are being notified');
      notifyListeners(); // Notify listeners of the change
    }
  }

  @override
  void notifyListeners() {
    devtools.log('#### notifyListeners called in ClinicSelection.');
    super.notifyListeners();
  }

  Future<void> updateClinic(String newClinicName) async {
    if (_selectedClinicName == newClinicName) {
      devtools.log('#### Clinic update skipped: No change in clinic.');
      return; // Skip if the clinic name is unchanged
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (_isLoading) {
        devtools.log(
            '#### Clinic update ignored: Another update is already in progress');
        return;
      }

      _isLoading = true;
      notifyListeners();

      try {
        final clinicId = await ClinicService().getClinicId(newClinicName);
        _selectedClinicName = newClinicName;
        _selectedClinicId = clinicId;

        devtools.log(
            '#### Clinic updated: $newClinicName with ID: $clinicId at ${DateTime.now()}');
      } catch (error) {
        devtools.log('#### Error updating clinic: $error');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // Method to update clinic names
  void updateClinicNames(List<String> newClinicNames) {
    _clinicNames = newClinicNames;
    devtools.log(
        '#### This is coming from updateClinicNames defined inside updateClinicNames. Updated clinic names: $newClinicNames Listeners being notified.');
    notifyListeners(); // Notify listeners when clinic names change
  }

  // Method to update multiple parameters at once
  void updateParameters(
      String selectedClinicName, List<String> newClinicNames, String clinicId) {
    _selectedClinicName = selectedClinicName;
    _clinicNames = newClinicNames;
    _selectedClinicId = clinicId;
    devtools.log(
        '#### This is coming from updateParameters defined inside ClinicSelection. Updated parameters: '
        'ClinicName: $selectedClinicName, ClinicID: $clinicId Notifying listeners...@@@@@@@@@@@@');
    notifyListeners(); // Notify listeners after all updates
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// ########################################################################### //
// import 'dart:async';
// import 'dart:developer' as devtools show log;
// import 'package:flutter/foundation.dart';

// class ClinicSelection extends ChangeNotifier {
//   static final ClinicSelection _instance = ClinicSelection._();

//   late String _selectedClinicName;
//   late List<String> _clinicNames;
//   late String _selectedClinicId;
//   late String _loggedInDoctorId; // New field to store doctorId
//   Timer? _debounce;

//   // Private constructor
//   ClinicSelection._() {
//     _selectedClinicName = ''; // Initialize with an empty string
//     _clinicNames = [];
//     _selectedClinicId = ''; // Initialize _selectedClinicId
//     _loggedInDoctorId = ''; // Initialize _doctorId
//   }

//   // Getter for the instance (singleton pattern)
//   static ClinicSelection get instance => _instance;

//   // Public getters for state
//   String get selectedClinicName => _selectedClinicName;
//   List<String> get clinicNames => _clinicNames;
//   String get selectedClinicId => _selectedClinicId;
//   String get doctorId => _loggedInDoctorId; // Getter for doctorId

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   // Method to update the doctorId
//   void setDoctorId(String doctorId) {
//     if (_loggedInDoctorId != doctorId) {
//       _loggedInDoctorId = doctorId;
//       devtools.log('Doctor ID set to: $doctorId');
//       notifyListeners(); // Notify listeners of the change
//     }
//   }

//   // Method to update selected clinic and trigger notifications

//   // Updated asynchronous method to handle clinic updates

//   //-----------------------------------------------------------//

//   Future<void> updateClinic(String newClinicName, String newClinicId) async {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();

//     _debounce = Timer(const Duration(milliseconds: 300), () async {
//       if (_isLoading) {
//         devtools.log(
//             '#### Clinic update ignored: Another update is already in progress');
//         return;
//       }

//       if (_selectedClinicName != newClinicName ||
//           _selectedClinicId != newClinicId) {
//         _isLoading = true;
//         notifyListeners();

//         try {
//           _selectedClinicName = newClinicName;
//           _selectedClinicId = newClinicId;

//           devtools.log(
//               '#### Clinic updated: $newClinicName with ID: $newClinicId at ${DateTime.now()}');
//         } catch (error) {
//           devtools.log('#### Error updating clinic: $error');
//         } finally {
//           _isLoading = false;
//           notifyListeners();
//         }
//       } else {
//         devtools.log(
//             '#### Clinic update skipped: Same clinic already selected ($newClinicName, $newClinicId)');
//       }
//     });
//   }

//   //-----------------------------------------------------------//

//   // Method to update clinic names
//   void updateClinicNames(List<String> newClinicNames) {
//     _clinicNames = newClinicNames;
//     devtools.log(
//         '#### This is coming from updateClinicNames defined inside updateClinicNames. Updated clinic names: $newClinicNames');
//     notifyListeners(); // Notify listeners when clinic names change
//   }

//   // Method to update multiple parameters at once
//   void updateParameters(
//       String selectedClinicName, List<String> newClinicNames, String clinicId) {
//     _selectedClinicName = selectedClinicName;
//     _clinicNames = newClinicNames;
//     _selectedClinicId = clinicId;
//     devtools.log(
//         '#### This is coming from updateParameters defined inside ClinicSelection. Updated parameters: '
//         'ClinicName: $selectedClinicName, ClinicID: $clinicId');
//     notifyListeners(); // Notify listeners after all updates
//   }
// }


// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
