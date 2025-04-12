import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/appointment_provider.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/next_appointment.dart';
import 'package:neocaresmileapp/mywidgets/recent_patient.dart';
import 'package:neocaresmileapp/mywidgets/recent_patient_provider.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

class LandingScreen extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  final String clinicId;

  const LandingScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    // Access the currently selected clinic using the provider
    final clinicSelection = context.watch<ClinicSelection>();
    final selectedClinicId = clinicSelection.selectedClinicId;

    devtools.log(
      '**** Welcome to LandingScreen. Selected clinicId: $selectedClinicId and clinicName: ${clinicSelection.selectedClinicName}',
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            // Next Appointment Section
            Expanded(
              child: _buildNextAppointmentWidget(selectedClinicId),
            ),
            const Divider(),
            // Recent Patient Section
            Expanded(
              child: _buildRecentPatientWidget(selectedClinicId),
            ),
          ],
        ),
      ),
    );
  }

  /// Method to build the Next Appointment widget
  Widget _buildNextAppointmentWidget(String selectedClinicId) {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final appointment = provider.nextAppointment;
        if (appointment == null) {
          return const Center(child: Text('No appointments today!'));
        }
        return NextAppointment(
          doctorId: appointment.doctorId,
          clinicId: selectedClinicId,
          doctorName: appointment.doctorName,
          patientService: provider.patientService, // Access PatientService here
        );
      },
    );
  }

  /// Method to build the Recent Patient widget
  Widget _buildRecentPatientWidget(String selectedClinicId) {
    return Consumer<RecentPatientProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.recentPatients.isEmpty) {
          return const Center(child: Text('No recent patients available!'));
        }
        return RecentPatient(
          doctorId: doctorId,
          clinicId: selectedClinicId,
          doctorName: doctorName,
          patientService: provider.patientService, // Access PatientService here
        );
      },
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// #########################################################################//
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/next_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/recent_patient.dart';
// import 'package:neocare_dental_app/mywidgets/recent_patient_provider.dart';
// import 'package:provider/provider.dart';
// import 'dart:developer' as devtools show log;

// class LandingScreen extends StatelessWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;

//   const LandingScreen({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.patientService,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Access the currently selected clinic using the provider
//     final clinicSelection = context.watch<ClinicSelection>();
//     final selectedClinicId = clinicSelection.selectedClinicId;

//     devtools.log(
//       '**** Welcome to LandingScreen. Selected clinicId: $selectedClinicId and clinicName: ${clinicSelection.selectedClinicName}',
//     );

//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//         child: Column(
//           children: [
//             // Next Appointment Section
//             Expanded(
//               child: _buildNextAppointmentWidget(selectedClinicId),
//             ),
//             const Divider(),
//             // Recent Patient Section
//             Expanded(
//               child: _buildRecentPatientWidget(selectedClinicId),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Method to build the Next Appointment widget
//   Widget _buildNextAppointmentWidget(String selectedClinicId) {
//     return Consumer<AppointmentProvider>(
//       builder: (context, provider, child) {
//         if (provider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         final appointment = provider.nextAppointment;
//         if (appointment == null) {
//           return const Center(child: Text('No appointments today!'));
//         }
//         return NextAppointment(
//           doctorId: appointment.doctorId,
//           clinicId: selectedClinicId,
//           doctorName: appointment.doctorName,
//           patientService: patientService,
//         );
//       },
//     );
//   }

//   /// Method to build the Recent Patient widget
//   Widget _buildRecentPatientWidget(String selectedClinicId) {
//     return Consumer<RecentPatientProvider>(
//       builder: (context, provider, child) {
//         if (provider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (provider.recentPatients.isEmpty) {
//           return const Center(child: Text('No recent patients available!'));
//         }
//         return RecentPatient(
//           doctorId: doctorId,
//           clinicId: selectedClinicId,
//           doctorName: doctorName,
//           patientService: patientService,
//         );
//       },
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// code below stable with direct CommonAppBar implemention
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/common_app_bar.dart';
// import 'package:neocare_dental_app/mywidgets/next_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/recent_patient.dart';
// import 'package:neocare_dental_app/mywidgets/recent_patient_provider.dart';
// import 'package:provider/provider.dart';
// import 'dart:developer' as devtools show log;

// class LandingScreen extends StatelessWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;

//   const LandingScreen({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.patientService,
//   });

  

//   @override
//   Widget build(BuildContext context) {
//     final selectedClinicId = context.watch<ClinicSelection>().selectedClinicId;
//     final selectedClinicName =
//         context.watch<ClinicSelection>().selectedClinicName;

//     devtools.log(
//       '**** Welcome to LandingScreen. Selected clinicId: $selectedClinicId and clinicName: $selectedClinicName',
//     );

//     return Scaffold(
//       appBar: CommonAppBar(
//         backgroundImage: 'assets/images/img1.png',
//         isLandingScreen: true,
//         additionalContent: doctorName,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//         child: Column(
//           children: [
//             // Next Appointment Section
//             Expanded(
//               child: _buildNextAppointmentWidget(selectedClinicId),
//             ),
//             const Divider(), // Optional: Adds a divider between sections
//             // Recent Patient Section
//             Expanded(
//               child: _buildRecentPatientWidget(selectedClinicId),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Updated method to pass selectedClinic to NextAppointment
//   Widget _buildNextAppointmentWidget(String selectedClinicId) {
//     return Consumer<AppointmentProvider>(
//       builder: (context, provider, child) {
//         if (provider.isLoading) {
//           return const CircularProgressIndicator();
//         }
//         final appointment = provider.nextAppointment;
//         if (appointment == null) {
//           return const Text('No appointments today!');
//         }
//         return NextAppointment(
//           doctorId: appointment.doctorId,
//           clinicId: selectedClinicId, // Use selectedClinic here
//           doctorName: appointment.doctorName,
//           patientService: patientService,
//         );
//       },
//     );
//   }

//   /// Updated method to pass selectedClinic to RecentPatient
//   Widget _buildRecentPatientWidget(String selectedClinicId) {
//     devtools.log(
//         '**** _buildRecentPatientWidget invoked. Selected Clinic ID: $selectedClinicId');
//     devtools
//         .log('**** _buildRecentPatientWidget invoked. Doctor ID: $doctorId');

//     return Consumer<RecentPatientProvider>(
//       builder: (context, provider, child) {
//         if (provider.isLoading) {
//           return const CircularProgressIndicator();
//         }
//         if (provider.recentPatients.isEmpty) {
//           return const Text('No recent patients available!');
//         }
//         return RecentPatient(
//           doctorId: provider.recentPatients.first['doctorId'],
//           clinicId: selectedClinicId, // Use selectedClinic here
//           doctorName: doctorName,
//           patientService: patientService,
//         );
//       },
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
