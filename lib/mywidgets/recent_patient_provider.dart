import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import 'package:neocaresmileapp/mywidgets/appointment_provider.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'dart:developer' as devtools show log;

import 'package:neocaresmileapp/mywidgets/patient.dart';

class RecentPatientProvider with ChangeNotifier {
  late final PatientService _patientService;
  List<Map<String, dynamic>> _recentPatients = [];
  bool _isLoading = false;
  StreamSubscription? _topRecentPatientsSubscription;
  StreamSubscription? _allPatientsSubscription;

  String? _clinicId;
  String? _doctorId;

  // Constructor: Listen to changes in ClinicSelection
  RecentPatientProvider() {
    _clinicId = ClinicSelection.instance.selectedClinicId;
    _doctorId = ClinicSelection.instance.doctorId;

    _patientService = PatientService(_clinicId!, _doctorId!);

    ClinicSelection.instance.addListener(_onClinicChanged);
    _setupSnapshotListener();
    fetchRecentPatients();
  }

  // Public getter for patientService
  PatientService get patientService => _patientService;

  // Public getters
  List<Map<String, dynamic>> get recentPatients => _recentPatients;
  bool get isLoading => _isLoading;

  // Method to set the clinic ID dynamically
  void setClinicId(String clinicId) {
    if (_clinicId == clinicId &&
        _doctorId == ClinicSelection.instance.doctorId) {
      devtools.log('No change in clinic or doctor detected. Skipping update.');
      return;
    }
    _clinicId = clinicId;
    _doctorId = ClinicSelection.instance.doctorId;

    devtools.log('Clinic ID changed to: $clinicId');
    _patientService.updateClinicAndDoctor(_clinicId!, _doctorId!);

    // Cancel existing listeners to avoid memory leaks
    _topRecentPatientsSubscription?.cancel();
    _allPatientsSubscription?.cancel();

    // Clear old data and notify listeners
    _recentPatients.clear();
    notifyListeners();

    // Fetch new data for the updated clinic
    _setupSnapshotListener();
    fetchRecentPatients();
  }

  void _onClinicChanged() {
    String newClinicId = ClinicSelection.instance.selectedClinicId;
    String newDoctorId = ClinicSelection.instance.doctorId;
    devtools.log('**** Clinic changed to $newClinicId');
    if (_clinicId == newClinicId && _doctorId == newDoctorId) {
      devtools.log('No change in clinic or doctor detected. Skipping update.');
      return;
    }
    setClinicId(newClinicId);
  }

  //---------------------------------------------------------------------------//

  // Sets up snapshot listeners for the new clinic
  void _setupSnapshotListener() {
    if (_clinicId == null) return;

    devtools.log('Setting up snapshot listener for Clinic ID: $_clinicId');

    // Listen to top 4 recent patients
    _topRecentPatientsSubscription = _patientService
        .listenToTopRecentPatients(_clinicId!)
        .listen((recentPatientsData) {
      devtools.log('Fetched recentPatientsData: $recentPatientsData');
      _recentPatients = recentPatientsData;
      notifyListeners();
    });

    // Listen to all patients and monitor search count changes
    _allPatientsSubscription = _patientService
        .listenToAllPatients(_clinicId!)
        .listen((allPatientsData) {
      devtools.log('All patients snapshot listener triggered.');

      if (_recentPatients.isNotEmpty) {
        int minSearchCountInTop4 = _recentPatients
            .map((patient) => (patient['searchCount'] ?? 0) as int)
            .reduce((a, b) => a < b ? a : b);

        bool needsUpdate = allPatientsData.any((patient) =>
            (patient['searchCount'] ?? 0) as int > minSearchCountInTop4 &&
            !_recentPatients.any((topPatient) =>
                topPatient['patientId'] == patient['patientId']));

        if (needsUpdate) {
          fetchRecentPatients();
        }
      }
    });
  }
  //---------------------------------------------------------------------------//

  // Fetch recent patients for the selected clinic
  Future<void> fetchRecentPatients() async {
    if (_clinicId == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      _recentPatients = await _patientService.fetchRecentPatients(
        clinicId: _clinicId!,
      );
      devtools.log('Recent patients fetched: $_recentPatients');
    } catch (error) {
      devtools.log('Error fetching recent patients: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //----------------------------------------------------------------------//

  // Manually refresh the recent patients
  void refreshRecentPatients() {
    fetchRecentPatients();
  }

  // Delete a patient and refresh next appointment
  Future<void> deletePatient(String patientId, String doctorName,
      AppointmentProvider appointmentProvider) async {
    try {
      await _patientService.deletePatient(patientId, doctorName);
      _recentPatients
          .removeWhere((patient) => patient['patientId'] == patientId);
      notifyListeners();
    } catch (e) {
      devtools.log('Error deleting patient: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    // Clean up listeners to prevent memory leaks
    ClinicSelection.instance.removeListener(_onClinicChanged);
    _topRecentPatientsSubscription?.cancel();
    _allPatientsSubscription?.cancel();
    super.dispose();
  }

  //--------------------------------------------------------------------------//
  /// Stream all patients in real-time for the current clinic
  Stream<List<Patient>> getAllPatientsRealTime() {
    if (_clinicId == null || _clinicId!.isEmpty) {
      devtools
          .log('Error: Clinic ID is null or empty. Cannot fetch all patients.');
      return const Stream.empty();
    }

    devtools.log('Fetching all patients in real-time for clinicId: $_clinicId');
    return _patientService.getAllPatientsRealTime(clinicId: _clinicId!);
  }

  /// Search patients in real-time for the current clinic
  Stream<List<Patient>> searchPatientsRealTime(String query) {
    if (_clinicId == null || _clinicId!.isEmpty) {
      devtools
          .log('Error: Clinic ID is null or empty. Cannot search patients.');
      return const Stream.empty();
    }

    devtools.log(
        'Searching patients in real-time for query: $query and clinicId: $_clinicId');
    return _patientService.searchPatientsRealTime(query, _clinicId!);
  }
  //--------------------------------------------------------------------------//
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// code below before 
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'dart:developer' as devtools show log;

// class RecentPatientProvider with ChangeNotifier {
//   late final PatientService _patientService;
//   List<Map<String, dynamic>> _recentPatients = [];
//   bool _isLoading = false;
//   StreamSubscription? _topRecentPatientsSubscription;
//   StreamSubscription? _allPatientsSubscription;

//   String? _clinicId;
//   String? _doctorId;

//   // Constructor: Listen to changes in ClinicSelection
//   RecentPatientProvider() {
//     _clinicId = ClinicSelection.instance.selectedClinicId;
//     _doctorId = ClinicSelection.instance.doctorId;

//     _patientService = PatientService(_clinicId!, _doctorId!);

//     ClinicSelection.instance.addListener(_onClinicChanged);
//     _setupSnapshotListener();
//     fetchRecentPatients();
//   }

//   // Public getter for patientService
//   PatientService get patientService => _patientService;

//   // Public getters
//   List<Map<String, dynamic>> get recentPatients => _recentPatients;
//   bool get isLoading => _isLoading;

//   // Method to set the clinic ID dynamically
//   void setClinicId(String clinicId) {
//     if (_clinicId == clinicId &&
//         _doctorId == ClinicSelection.instance.doctorId) {
//       devtools.log('No change in clinic or doctor detected. Skipping update.');
//       return;
//     }
//     _clinicId = clinicId;
//     _doctorId = ClinicSelection.instance.doctorId;

//     devtools.log('Clinic ID changed to: $clinicId');
//     _patientService.updateClinicAndDoctor(_clinicId!, _doctorId!);

//     // Cancel existing listeners to avoid memory leaks
//     _topRecentPatientsSubscription?.cancel();
//     _allPatientsSubscription?.cancel();

//     // Clear old data and notify listeners
//     _recentPatients.clear();
//     notifyListeners();

//     // Fetch new data for the updated clinic
//     _setupSnapshotListener();
//     fetchRecentPatients();
//   }

//   void _onClinicChanged() {
//     String newClinicId = ClinicSelection.instance.selectedClinicId;
//     String newDoctorId = ClinicSelection.instance.doctorId;
//     devtools.log('**** Clinic changed to $newClinicId');
//     if (_clinicId == newClinicId && _doctorId == newDoctorId) {
//       devtools.log('No change in clinic or doctor detected. Skipping update.');
//       return;
//     }
//     setClinicId(newClinicId);
//   }

//   //---------------------------------------------------------------------------//

//   // Sets up snapshot listeners for the new clinic
//   void _setupSnapshotListener() {
//     if (_clinicId == null) return;

//     devtools.log('Setting up snapshot listener for Clinic ID: $_clinicId');

//     // Listen to top 4 recent patients
//     _topRecentPatientsSubscription = _patientService
//         .listenToTopRecentPatients(_clinicId!)
//         .listen((recentPatientsData) {
//       devtools.log('Fetched recentPatientsData: $recentPatientsData');
//       _recentPatients = recentPatientsData;
//       notifyListeners();
//     });

//     // Listen to all patients and monitor search count changes
//     _allPatientsSubscription = _patientService
//         .listenToAllPatients(_clinicId!)
//         .listen((allPatientsData) {
//       devtools.log('All patients snapshot listener triggered.');

//       if (_recentPatients.isNotEmpty) {
//         int minSearchCountInTop4 = _recentPatients
//             .map((patient) => (patient['searchCount'] ?? 0) as int)
//             .reduce((a, b) => a < b ? a : b);

//         bool needsUpdate = allPatientsData.any((patient) =>
//             (patient['searchCount'] ?? 0) as int > minSearchCountInTop4 &&
//             !_recentPatients.any((topPatient) =>
//                 topPatient['patientId'] == patient['patientId']));

//         if (needsUpdate) {
//           fetchRecentPatients();
//         }
//       }
//     });
//   }
//   //---------------------------------------------------------------------------//

//   // Fetch recent patients for the selected clinic
//   Future<void> fetchRecentPatients() async {
//     if (_clinicId == null) return;

//     _isLoading = true;
//     notifyListeners();
//     try {
//       _recentPatients = await _patientService.fetchRecentPatients(
//         clinicId: _clinicId!,
//       );
//       devtools.log('Recent patients fetched: $_recentPatients');
//     } catch (error) {
//       devtools.log('Error fetching recent patients: $error');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   //----------------------------------------------------------------------//

//   // Manually refresh the recent patients
//   void refreshRecentPatients() {
//     fetchRecentPatients();
//   }

//   // Delete a patient and refresh next appointment
//   Future<void> deletePatient(String patientId, String doctorName,
//       AppointmentProvider appointmentProvider) async {
//     try {
//       await _patientService.deletePatient(patientId, doctorName);
//       _recentPatients
//           .removeWhere((patient) => patient['patientId'] == patientId);
//       notifyListeners();
//     } catch (e) {
//       devtools.log('Error deleting patient: $e');
//       rethrow;
//     }
//   }

//   @override
//   void dispose() {
//     // Clean up listeners to prevent memory leaks
//     ClinicSelection.instance.removeListener(_onClinicChanged);
//     _topRecentPatientsSubscription?.cancel();
//     _allPatientsSubscription?.cancel();
//     super.dispose();
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
