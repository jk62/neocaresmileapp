// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/clinic_service.dart';
// import 'package:neocare_dental_app/firestore/doctor_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';

// class DoctorData extends StatefulWidget {
//   const DoctorData({super.key});

//   @override
//   _DoctorDataState createState() => _DoctorDataState();
// }

// class _DoctorDataState extends State<DoctorData> {
//   String _collectedDoctorId = '';
//   String _collectedDoctorName = '';
//   String _collectedClinicId = '';
//   PatientService _collectedPatientService = PatientService('', '');
//   List<String> _collectedClinicNames = [];
//   String _collectedSelectedClinicName = '';
//   bool _isLoading = false;

//   String doctorName = '';
//   String loggedInDoctorId = '';
//   List<String> clinicNames = [];
//   String selectedClinicName = '';
//   String selectedClinicId = '';
//   late PatientService _patientService;
//   final clinicSelection = ClinicSelection.instance;

//   void initializePatientService() {
//     _patientService = PatientService(selectedClinicId, loggedInDoctorId);
//   }

//   Future<Map<String, dynamic>> fetchData() async {
//     return _fetchData();
//   }

//   Future<Map<String, dynamic>> _fetchData() async {
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       String userId = user.uid;
//       Map<String, dynamic>? doctorData =
//           await DoctorService().fetchDoctorDataForUser(userId) ?? {};

//       setState(() {
//         if (doctorData.isNotEmpty) {
//           doctorName = doctorData['doctorName'] ?? '';
//           loggedInDoctorId = doctorData['userId'];

//           List<dynamic> clinicsMapped = doctorData['clinicsMapped'];
//           clinicNames = clinicsMapped
//               .map((clinic) => clinic['clinicName'] as String)
//               .toList();

//           if (clinicNames.isNotEmpty) {
//             selectedClinicName = clinicNames[0];
//             ClinicService clinicService = ClinicService();
//             clinicService.getClinicId(selectedClinicName).then((clinicId) {
//               selectedClinicId = clinicId;
//               initializePatientService();
//               _isLoading = false;
//               //------------------------------------//
//               clinicSelection.updateParameters(
//                   selectedClinicName, clinicNames, selectedClinicId);

//               //-----------------------------------//

//               _collectedDoctorId = loggedInDoctorId;
//               _collectedDoctorName = doctorName;
//               _collectedClinicId = selectedClinicId;
//               _collectedPatientService = _patientService;
//               _collectedClinicNames = clinicNames;
//               _collectedSelectedClinicName = selectedClinicName;
//             }).catchError((error) {
//               devtools.log(error.toString());
//               _isLoading = false;
//             });
//           } else {
//             _isLoading = false;
//           }
//         } else {
//           _isLoading = false;
//         }
//       });

//       return doctorData;
//     } else {
//       _isLoading = false;
//       return {};
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

