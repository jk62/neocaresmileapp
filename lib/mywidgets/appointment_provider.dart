import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/appointment_service.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'dart:developer' as devtools show log;

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  Appointment? _nextAppointment;
  bool _isLoading = false;
  late PatientService _patientService;
  StreamSubscription<Appointment?>? _nextAppointmentSubscription;
  String? _selectedAppointmentId;
  List<Appointment>? _appointments;

  String? _clinicId;
  String? _doctorId;

  //---------------------------------------------------------------------------//
  // AppointmentProvider() {
  //   _clinicId = ClinicSelection.instance.selectedClinicId;
  //   _doctorId = ClinicSelection.instance.doctorId;

  //   _patientService = PatientService(_clinicId!, _doctorId!);

  //   ClinicSelection.instance.addListener(_onClinicChanged);
  //   _setupNextAppointmentStream(); // Start listening for real-time updates
  // }

  AppointmentProvider() {
    _clinicId = ClinicSelection.instance.selectedClinicId;
    _doctorId = ClinicSelection.instance.doctorId;

    devtools.log('AppointmentProvider initialized with clinicId: $_clinicId');
    devtools.log('AppointmentProvider initialized with doctorId: $_doctorId');

    if (_clinicId == null || _clinicId!.isEmpty) {
      devtools.log('Error: Clinic ID is null or empty during initialization.');
    }

    _patientService = PatientService(_clinicId!, _doctorId!);
    ClinicSelection.instance.addListener(_onClinicChanged);
    _setupNextAppointmentStream(); // Start listening for real-time updates
  }

  //---------------------------------------------------------------------------//
  // Public getter for patientService
  PatientService get patientService => _patientService;

  // Public getter for `_clinicId`
  String? get clinicId => _clinicId;

  // Public getter for `_doctorId`
  String? get doctorId => _doctorId;

  Timer? _fetchDebounce;

  // Public method to update IDs and reset the stream
  void updateClinicAndDoctor(String newClinicId, String newDoctorId) {
    if (_clinicId != newClinicId || _doctorId != newDoctorId) {
      _clinicId = newClinicId;
      _doctorId = newDoctorId;
      _patientService.updateClinicAndDoctor(_clinicId!, _doctorId!);
      devtools.log(
          'Updating clinicId to $newClinicId and doctorId to $newDoctorId');
      _setupNextAppointmentStream(); // Restart the stream with updated IDs
    }
  }

  // Public getters
  Appointment? get nextAppointment => _nextAppointment;
  bool get isLoading => _isLoading;
  List<Appointment>? get appointments => _appointments;

  String? get selectedAppointmentId => _selectedAppointmentId;

  @override
  void notifyListeners() {
    devtools.log('notifyListeners called in AppointmentProvider');
    super.notifyListeners();
  }

  set selectedAppointmentId(String? id) {
    _selectedAppointmentId = id;
    devtools.log('selectedAppointmentId updated to $id');
    notifyListeners();
  }

  void _setupNextAppointmentStream() {
    devtools.log('Setting up next appointment stream...');
    if (_clinicId == null ||
        _clinicId!.isEmpty ||
        _doctorId == null ||
        _doctorId!.isEmpty) {
      devtools.log('Error: Invalid clinicId or doctorId.');
      return;
    }

    // Cancel any existing subscription to avoid duplicate listeners
    _nextAppointmentSubscription?.cancel();

    // Listen to real-time updates for the next appointment
    _nextAppointmentSubscription = _appointmentService
        .getNextAppointmentStream(
      doctorId: _doctorId!,
      clinicId: _clinicId!,
    )
        .listen((appointment) {
      _nextAppointment = appointment;
      notifyListeners();
    });
  }

  void _onClinicChanged() {
    final newClinicId = ClinicSelection.instance.selectedClinicId;
    final newDoctorId = ClinicSelection.instance.doctorId;

    if (_clinicId == newClinicId && _doctorId == newDoctorId) {
      devtools.log('No change in clinic or doctor detected. Skipping update.');
      return;
    }

    _clinicId = newClinicId;
    _doctorId = newDoctorId;
    devtools.log('Clinic or doctor changed. Updating next appointment stream.');
    _setupNextAppointmentStream(); // Restart the stream with updated clinic and doctor
  }

  Future<void> fetchAppointmentsForDate(DateTime date) async {
    final doctorId = ClinicSelection.instance.doctorId;
    final clinicId = ClinicSelection.instance.selectedClinicId;

    if (doctorId == null || clinicId == null) return;

    // Cancel any ongoing debounce timer to reset the delay
    if (_fetchDebounce?.isActive ?? false) _fetchDebounce!.cancel();

    // Start a new debounce timer
    _fetchDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (_isLoading) return; // Skip if already loading

      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners(); // Notify that loading has started
      });

      try {
        devtools.log('Fetching appointments for $date...');
        final fetchedAppointments =
            await _appointmentService.fetchAppointmentsForDate(
          clinicId: clinicId,
          doctorId: doctorId,
          selectedDate: date,
        );

        // Update appointments only if they have changed
        if (_appointments != fetchedAppointments) {
          _appointments = fetchedAppointments;
          devtools
              .log('Appointments fetched for $date: ${_appointments?.length}');
        }
      } catch (e) {
        devtools.log('Error fetching appointments: $e');
      } finally {
        _isLoading = false;
        notifyListeners(); // Notify listeners after fetch completes
      }
    });
  }

  Future<void> deleteAppointmentAndUpdateSlot(
    String clinicId,
    String doctorName,
    String appointmentId,
    DateTime appointmentDate,
    String appointmentSlot,
  ) async {
    try {
      await _appointmentService.deleteAppointmentAndUpdateSlot(
        clinicId,
        doctorName,
        appointmentId,
        appointmentDate,
        appointmentSlot,
        _onDeleteAppointmentAndUpdateSlotCallback,
      );
    } catch (e) {
      devtools.log('Error deleting appointment: $e');
    }
  }

  void _onDeleteAppointmentAndUpdateSlotCallback() {
    _nextAppointment = null;
    _setupNextAppointmentStream(); // Restart stream after deletion
  }

  @override
  void dispose() {
    // Clean up listeners to prevent memory leaks
    ClinicSelection.instance.removeListener(_onClinicChanged);
    _nextAppointmentSubscription?.cancel();
    super.dispose();
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// ########################################################################### //
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'dart:developer' as devtools show log;

// class AppointmentProvider extends ChangeNotifier {
//   final AppointmentService _appointmentService = AppointmentService();
//   Appointment? _nextAppointment;
//   bool _isLoading = false;
//   PatientService? _patientService;
//   StreamSubscription<Appointment?>? _nextAppointmentSubscription;
//   String? _selectedAppointmentId;
//   List<Appointment>? _appointments;

//   String? _clinicId;
//   String? _doctorId;

//   AppointmentProvider({required PatientService patientService}) {
//     _patientService = patientService;
//     ClinicSelection.instance.addListener(_onClinicChanged);
//     _setupNextAppointmentStream(); // Start listening for real-time updates
//   }
//   // Public getter for `_clinicId`
//   String? get clinicId => _clinicId;

//   // Public getter for `_doctorId`
//   String? get doctorId => _doctorId;
//   // Public method to update IDs and reset the stream
//   void updateClinicAndDoctor(String newClinicId, String newDoctorId) {
//     if (_clinicId != newClinicId || _doctorId != newDoctorId) {
//       _clinicId = newClinicId;
//       _doctorId = newDoctorId;
//       devtools.log(
//           'Updating clinicId to $newClinicId and doctorId to $newDoctorId');
//       _setupNextAppointmentStream(); // Restart the stream with updated IDs
//     }
//   }

//   // Public getters
//   Appointment? get nextAppointment => _nextAppointment;
//   bool get isLoading => _isLoading;
//   List<Appointment>? get appointments => _appointments;

//   String? get selectedAppointmentId => _selectedAppointmentId;

//   set selectedAppointmentId(String? id) {
//     _selectedAppointmentId = id;
//     notifyListeners();
//   }

//   void _setupNextAppointmentStream() {
//     devtools.log('Setting up next appointment stream...');
//     _clinicId = ClinicSelection.instance.selectedClinicId;
//     _doctorId = ClinicSelection.instance.doctorId;

//     if (_clinicId == null || _clinicId!.isEmpty || _doctorId == null) {
//       devtools.log('Error: Invalid clinicId or doctorId.');
//       return;
//     }

//     // Cancel any existing subscription to avoid duplicate listeners
//     _nextAppointmentSubscription?.cancel();

//     // Listen to real-time updates for the next appointment
//     _nextAppointmentSubscription = _appointmentService
//         .getNextAppointmentStream(
//       doctorId: _doctorId!,
//       clinicId: _clinicId!,
//     )
//         .listen((appointment) {
//       _nextAppointment = appointment;
//       notifyListeners();
//     });
//   }

//   void _onClinicChanged() {
//     final newClinicId = ClinicSelection.instance.selectedClinicId;
//     final newDoctorId = ClinicSelection.instance.doctorId;

//     if (_clinicId == newClinicId && _doctorId == newDoctorId) {
//       devtools.log('No change in clinic or doctor detected. Skipping update.');
//       return;
//     }

//     _clinicId = newClinicId;
//     _doctorId = newDoctorId;
//     devtools.log('Clinic or doctor changed. Updating next appointment stream.');

//     _setupNextAppointmentStream(); // Restart the stream with updated clinic and doctor
//   }

//   Future<void> fetchAppointmentsForDate(DateTime date) async {
//     final doctorId = ClinicSelection.instance.doctorId;
//     final clinicId = ClinicSelection.instance.selectedClinicId;

//     if (doctorId == null || clinicId == null) return;

//     _isLoading = true;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       notifyListeners();
//     });

//     try {
//       _appointments = await _appointmentService.fetchAppointmentsForDate(
//         clinicId: clinicId,
//         doctorId: doctorId,
//         selectedDate: date,
//       );
//       devtools.log('Appointments fetched for $date: ${_appointments?.length}');
//     } catch (e) {
//       devtools.log('Error fetching appointments: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> deleteAppointmentAndUpdateSlot(
//     String clinicId,
//     String doctorName,
//     String appointmentId,
//     DateTime appointmentDate,
//     String appointmentSlot,
//   ) async {
//     try {
//       await _appointmentService.deleteAppointmentAndUpdateSlot(
//         clinicId,
//         doctorName,
//         appointmentId,
//         appointmentDate,
//         appointmentSlot,
//         _onDeleteAppointmentAndUpdateSlotCallback,
//       );
//     } catch (e) {
//       devtools.log('Error deleting appointment: $e');
//     }
//   }

//   void _onDeleteAppointmentAndUpdateSlotCallback() {
//     _nextAppointment = null;
//     _setupNextAppointmentStream(); // Restart stream after deletion
//   }

//   @override
//   void dispose() {
//     // Clean up listeners to prevent memory leaks
//     ClinicSelection.instance.removeListener(_onClinicChanged);
//     _nextAppointmentSubscription?.cancel();
//     super.dispose();
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW BEFORE ITS ALIGNMENT WITH getNextAppointmentStream
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'dart:developer' as devtools show log;

// class AppointmentProvider extends ChangeNotifier {
//   final AppointmentService _appointmentService = AppointmentService();
//   Appointment? _nextAppointment;
//   bool _isLoading = false;
//   PatientService? _patientService;
//   StreamSubscription<List<Appointment>>? _appointmentSubscription;
//   String? _selectedAppointmentId;
//   List<Appointment>? _appointments;

//   //-------------------------------------------------------//

//   String? _clinicId;
//   String? _doctorId;
//   //--------------------------------------------------------//

  

//   AppointmentProvider({required PatientService patientService}) {
//     _patientService = patientService;
//     ClinicSelection.instance.addListener(_onClinicChanged);
//     initializeAppointmentsStream();
//   }

//   // Method to update the clinicId and doctorId
//   void setClinicId(String clinicId, String doctorId) {
//     if (_clinicId != clinicId || _doctorId != doctorId) {
//       _clinicId = clinicId;
//       _doctorId = doctorId;

//       devtools.log(
//           'Clinic and Doctor updated: ClinicID: $_clinicId, DoctorID: $_doctorId');

//       _appointmentSubscription?.cancel();
//       fetchNextAppointment();
//       _setupSnapshotListener();
//     }
//   }

//   //-----------------------------------------------------------------//
//   // Check if both clinicId and doctorId are valid
//   bool _hasValidSelection() {
//     return ClinicSelection.instance.doctorId.isNotEmpty &&
//         ClinicSelection.instance.selectedClinicId.isNotEmpty;
//   }

//   // Public getters
//   Appointment? get nextAppointment => _nextAppointment;
//   bool get isLoading => _isLoading;
//   List<Appointment>? get appointments => _appointments;

//   String? get selectedAppointmentId => _selectedAppointmentId;

//   set selectedAppointmentId(String? id) {
//     _selectedAppointmentId = id;
//     notifyListeners();
//   }

//   void initializeAppointmentsStream() {
//     devtools.log('Initializing appointments stream...');

//     _clinicId = ClinicSelection.instance.selectedClinicId;
//     _doctorId = ClinicSelection.instance.doctorId;

//     if (_clinicId != null && _clinicId!.isNotEmpty && _doctorId != null) {
//       _appointmentSubscription?.cancel();
//       _setupSnapshotListener();
//     } else {
//       devtools.log('Error: doctorId or clinicId is not properly set.');
//     }
//   }

//   //---------------------------------------------------------------------//
//   // This method is triggered when the clinic changes in ClinicSelection
  

//   void _onClinicChanged() {
//     final newClinicId = ClinicSelection.instance.selectedClinicId;
//     final newDoctorId = ClinicSelection.instance.doctorId;

//     if (_clinicId == newClinicId && _doctorId == newDoctorId) {
//       devtools.log(
//           '!!!! This is coming from inside _onClinicChanged defined inside AppointmentProvider. No clinic or doctor change detected; skipping update.');
//       return;
//     }

//     _clinicId = newClinicId;
//     _doctorId = newDoctorId;
//     devtools.log(
//         '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//     devtools.log(
//         '!!!! This is coming from inside _onClinicChanged defined inside AppointmentProvider. Clinic changed, re-fetching appointments for Clinic: $_clinicId, Doctor: $_doctorId !!!!');
//     devtools.log(
//         '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

//     _appointmentSubscription?.cancel();
//     fetchNextAppointment();
//     _setupSnapshotListener();
//   }

//   //----------------------------------------------------------------------//

  

//   Future<void> fetchNextAppointment() async {
//     if (_clinicId == null || _doctorId == null) {
//       devtools.log('Error: Clinic ID or Doctor ID is null!');
//       return;
//     }

//     devtools.log(
//         'Fetching next appointment for Clinic: $_clinicId, Doctor: $_doctorId');

//     _isLoading = true;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       notifyListeners();
//     });

//     try {
//       _nextAppointment = await _appointmentService.getNextAppointment(
//         doctorId: _doctorId!,
//         clinicId: _clinicId!,
//       );
//       devtools.log('Next appointment: $_nextAppointment');
//     } catch (error) {
//       devtools.log('Error fetching next appointment: $error');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   //---------------------------------------------------------------------------//
  

//   void _setupSnapshotListener() {
//     if (_clinicId == null || _doctorId == null) return;

//     devtools
//         .log('Setting up listener for Clinic: $_clinicId, Doctor: $_doctorId');

//     _appointmentSubscription = _appointmentService
//         .listenToAppointments(doctorId: _doctorId!, clinicId: _clinicId!)
//         .listen((appointments) {
//       if (appointments.isNotEmpty) {
//         _nextAppointment = appointments.first;
//       } else {
//         _nextAppointment = null;
//       }
//       notifyListeners();
//     });
//   }
//   //--------------------------------------------------------------------------//

//   Future<void> fetchAppointmentsForDate(DateTime date) async {
//     String? doctorId = ClinicSelection.instance.doctorId;
//     String? clinicId = ClinicSelection.instance.selectedClinicId;

//     if (doctorId == null || clinicId == null) return;

//     _isLoading = true;
//     //notifyListeners();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       notifyListeners();
//     });

//     try {
//       _appointments = await _appointmentService.fetchAppointmentsForDate(
//         clinicId: clinicId,
//         doctorId: doctorId,
//         selectedDate: date,
//       );
//       devtools.log('Appointments fetched for $date: ${_appointments?.length}');
//     } catch (e) {
//       devtools.log('Error fetching appointments: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> deleteAppointmentAndUpdateSlot(
//     String clinicId,
//     String doctorName,
//     String appointmentId,
//     DateTime appointmentDate,
//     String appointmentSlot,
//   ) async {
//     try {
//       await _appointmentService.deleteAppointmentAndUpdateSlot(
//         clinicId,
//         doctorName,
//         appointmentId,
//         appointmentDate,
//         appointmentSlot,
//         _onDeleteAppointmentAndUpdateSlotCallback,
//       );
//     } catch (e) {
//       devtools.log('Error deleting appointment: $e');
//     }
//   }

//   void _onDeleteAppointmentAndUpdateSlotCallback() {
//     _nextAppointment = null;
//     fetchNextAppointment();
//   }

//   @override
//   void dispose() {
//     // Clean up listeners to prevent memory leaks
//     ClinicSelection.instance.removeListener(_onClinicChanged);
//     _appointmentSubscription?.cancel();
//     super.dispose();
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE BEFORE INTRODUCTION OF CHANGENOTIFIERPROXYPROVIDER
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'dart:developer' as devtools show log;

// class AppointmentProvider extends ChangeNotifier {
//   final AppointmentService _appointmentService = AppointmentService();
//   Appointment? _nextAppointment;
//   bool _isLoading = false;
//   PatientService? _patientService;
//   StreamSubscription<List<Appointment>>? _appointmentSubscription;
//   String? _selectedAppointmentId;
//   List<Appointment>? _appointments;

//   // Constructor: Register listener to ClinicSelection changes
//   AppointmentProvider({required PatientService patientService}) {
//     _patientService = patientService;

//     // Listen for clinic changes from ClinicSelection
//     ClinicSelection.instance.addListener(_onClinicChanged);

//     // Initial data fetch using the current clinic and doctor
//     // Fetch initial data only if clinicId and doctorId are valid
//     if (_hasValidSelection()) {
//       fetchNextAppointment();
//       _setupSnapshotListener();
//     }
//   }
//   // Check if both clinicId and doctorId are valid
//   bool _hasValidSelection() {
//     return ClinicSelection.instance.doctorId.isNotEmpty &&
//         ClinicSelection.instance.selectedClinicId.isNotEmpty;
//   }

//   // Public getters
//   Appointment? get nextAppointment => _nextAppointment;
//   bool get isLoading => _isLoading;
//   List<Appointment>? get appointments => _appointments;

//   String? get selectedAppointmentId => _selectedAppointmentId;

//   set selectedAppointmentId(String? id) {
//     _selectedAppointmentId = id;
//     notifyListeners();
//   }

//   // This method is triggered when the clinic changes in ClinicSelection
//   // void _onClinicChanged() {
//   //   String newClinicId = ClinicSelection.instance.selectedClinicId;
//   //   String newDoctorId = ClinicSelection.instance.doctorId;

//   //   devtools.log('Clinic changed: $newClinicId, Doctor: $newDoctorId');

//   //   // Cancel old subscriptions to avoid memory leaks
//   //   _appointmentSubscription?.cancel();

//   //   // Fetch new data for the updated clinic and doctor
//   //   fetchNextAppointment();
//   //   _setupSnapshotListener();
//   // }
//   void _onClinicChanged() {
//     if (_hasValidSelection()) {
//       devtools.log(
//           '**** This is coming from inside _onClinicChanged defined inside AppointmentProvider. Clinic changed, re-fetching appointments.');
//       _appointmentSubscription?.cancel(); // Cancel old subscription
//       fetchNextAppointment(); // Fetch new data
//       _setupSnapshotListener(); // Set up new listener
//     } else {
//       devtools.log('Invalid clinic or doctor selection.');
//     }
//   }

//   Future<void> fetchNextAppointment() async {
//     String? doctorId = ClinicSelection.instance.doctorId;
//     String? clinicId = ClinicSelection.instance.selectedClinicId;

//     if (doctorId == null || clinicId == null || clinicId.isEmpty) {
//       devtools.log('Error: doctorId or clinicId is null or empty!');
//       return;
//     }

//     devtools.log(
//         '**** This is coming from inside fetchNextAppointment defined inside AppointmentProvider. Fetching next appointment for Doctor: $doctorId at Clinic: $clinicId');

//     _isLoading = true;
//     //notifyListeners();
//     // if (mounted) {
//     //   WidgetsBinding.instance.addPostFrameCallback((_) {
//     //     notifyListeners();
//     //   });
//     // }
//     // Defer notifyListeners() to avoid calling it during build phase
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       notifyListeners();
//     });

//     try {
//       _nextAppointment = await _appointmentService.getNextAppointment(
//         doctorId: doctorId,
//         clinicId: clinicId,
//       );
//       devtools.log('Next appointment: $_nextAppointment');
//     } catch (error) {
//       devtools.log('Error fetching next appointment: $error');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void _setupSnapshotListener() {
//     String? doctorId = ClinicSelection.instance.doctorId;
//     String? clinicId = ClinicSelection.instance.selectedClinicId;

//     if (doctorId == null || clinicId == null) return;

//     devtools
//         .log('Setting up listener for Doctor: $doctorId at Clinic: $clinicId');

//     _appointmentSubscription = _appointmentService
//         .listenToAppointments(doctorId: doctorId, clinicId: clinicId)
//         .listen((appointments) {
//       if (appointments.isNotEmpty) {
//         _nextAppointment = appointments.first;
//       } else {
//         _nextAppointment = null;
//       }
//       notifyListeners();
//     });
//   }

//   // Future<void> fetchAppointmentsForDate(DateTime date) async {
//   //   String? doctorId = ClinicSelection.instance.doctorId;
//   //   String? clinicId = ClinicSelection.instance.selectedClinicId;

//   //   if (doctorId == null || clinicId == null) return;

//   //   _isLoading = true;
//   //   //notifyListeners();
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     notifyListeners();
//   //   });

//   //   try {
//   //     _appointments = await _appointmentService.fetchAppointmentsForDate(
//   //       clinicId: clinicId,
//   //       doctorId: doctorId,
//   //       selectedDate: date,
//   //     );
//   //     devtools.log('Appointments fetched for $date: ${_appointments?.length}');
//   //   } catch (e) {
//   //     devtools.log('Error fetching appointments: $e');
//   //   } finally {
//   //     _isLoading = false;
//   //     notifyListeners();
//   //   }
//   // }

//   Future<void> deleteAppointmentAndUpdateSlot(
//     String clinicId,
//     String doctorName,
//     String appointmentId,
//     DateTime appointmentDate,
//     String appointmentSlot,
//   ) async {
//     try {
//       await _appointmentService.deleteAppointmentAndUpdateSlot(
//         clinicId,
//         doctorName,
//         appointmentId,
//         appointmentDate,
//         appointmentSlot,
//         _onDeleteAppointmentAndUpdateSlotCallback,
//       );
//     } catch (e) {
//       devtools.log('Error deleting appointment: $e');
//     }
//   }

//   void _onDeleteAppointmentAndUpdateSlotCallback() {
//     _nextAppointment = null;
//     fetchNextAppointment();
//   }

//   @override
//   void dispose() {
//     // Clean up listeners to prevent memory leaks
//     ClinicSelection.instance.removeListener(_onClinicChanged);
//     _appointmentSubscription?.cancel();
//     super.dispose();
//   }
// }
