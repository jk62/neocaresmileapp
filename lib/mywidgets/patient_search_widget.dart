// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';

// class PatientSearchWidget extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;
//   final PatientService patientService;

//   const PatientSearchWidget({
//     Key? key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//     required this.patientService,
//   }) : super(key: key);

//   @override
//   State<PatientSearchWidget> createState() => _PatientSearchWidgetState();
// }

// class _PatientSearchWidgetState extends State<PatientSearchWidget> {
//   final TextEditingController _searchController = TextEditingController();

//   List<Patient> matchingPatients = []; // Store matching patients

//   bool hasUserInput = false; // Track if the user has entered input
//   Patient? selectedPatient;
//   Stream<List<Patient>>? matchingPatientsStream;
//   // Define a GlobalKey for the navigator
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the search controller with an empty string
//     _searchController.text = '';

//     // Perform the initial search with an empty query
//     handleSearchInput('');
//   }

//   void handleSearchInput(String query) {
//     try {
//       if (query.isNotEmpty) {
//         final searchResults = widget.patientService.searchPatientsRealTime(
//           query,
//           selectedPatient,
//         );

//         setState(() {
//           matchingPatientsStream = searchResults;
//         });
//       } else {
//         // If the query is empty, show all patients
//         setState(() {
//           matchingPatientsStream =
//               widget.patientService.getAllPatientsRealTime();
//         });
//       }
//     } catch (e) {
//       devtools.log('Error handling search input in widget: $e');
//     }
//   }

//   void handleSelectPatient(Patient patient) async {
//     setState(() {
//       selectedPatient = patient;
//     });

//     // Do any additional actions needed with the selected patient
//     devtools.log(
//         'This is coming from inside handleSelectPatient. Selected Patient: ${selectedPatient?.patientName}');

//     if (selectedPatient != null && selectedPatient!.patientId.isNotEmpty) {
//       try {
//         final patientId = selectedPatient!.patientId;
//         devtools.log('patientId of selectedPatient is $patientId');

//         // Increment the searchCount for the found patient
//         //await widget.patientService.incrementSearchCount(patientId);
//       } catch (e) {
//         devtools.log('Error incrementing searchCount: $e');
//       }
//     }
//   }

//   List<Widget> _buildPatientsList(List<Patient> patients) {
//     patients.sort((a, b) {
//       final patientNameA = a.patientName;
//       final patientNameB = b.patientName;
//       return patientNameA.compareTo(patientNameB);
//     });

//     List<Widget> widgets = [];
//     String currentAlphabet = '';

//     for (final patient in patients) {
//       final patientFirstChar = patient.patientName.isNotEmpty
//           ? patient.patientName[0].toUpperCase()
//           : '';

//       if (patientFirstChar != currentAlphabet) {
//         // Add a header widget with a bigger font size
//         widgets.add(
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0), // Only left padding
//             // padding:
//             //     const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 patientFirstChar,
//                 style: MyTextStyle.textStyleMap['headline-large']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         );
//         currentAlphabet = patientFirstChar;
//       }

//       widgets.add(
//         GestureDetector(
//           onTap: () {
//             handleSelectPatient(patient);
//           },
//           // onTap: () {
//           //   Navigator.push(
//           //     context,
//           //     MaterialPageRoute(
//           //       builder: (context) => TreatmentLandingScreen(
//           //         clinicId: widget.clinicId,
//           //         doctorId: widget.doctorId,
//           //         doctorName: widget.doctorName,
//           //         patientId: patient.patientId,
//           //         patientName: patient.patientName,
//           //         patientMobileNumber: patient.patientMobileNumber,
//           //         age: patient.age,
//           //         gender: patient.gender,
//           //         patientPicUrl: patient.patientPicUrl,
//           //         uhid: patient.uhid,
//           //       ),
//           //     ),
//           //   );
//           // },
//           child: Card(
//             child: ListTile(
//               leading: CircleAvatar(
//                 radius: 24,
//                 backgroundColor: MyColors.colorPalette['surface'],
//               ),
//               title: Text(
//                 patient.patientName,
//                 style: MyTextStyle.textStyleMap['label-medium']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//               subtitle: Text(
//                 '${patient.age}, ${patient.gender}',
//                 style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return widgets;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'All Patients',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         iconTheme: IconThemeData(
//           color: MyColors.colorPalette['on-surface'],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               onChanged: (value) {
//                 setState(() {
//                   hasUserInput = value.isNotEmpty;
//                   devtools.log('value is $value');
//                 });
//                 handleSearchInput(value);
//               },
//               decoration: InputDecoration(
//                 labelText: 'Search Patient',
//                 labelStyle: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Text(
//                 'All Patients',
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<List<Patient>>(
//               stream: hasUserInput
//                   ? matchingPatientsStream
//                   : widget.patientService.getAllPatientsRealTime(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const CircularProgressIndicator(); // Placeholder for loading state
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else if ((hasUserInput &&
//                         (snapshot.data == null || snapshot.data!.isEmpty)) ||
//                     (!hasUserInput &&
//                         (snapshot.data == null || snapshot.data!.isEmpty))) {
//                   return const Text('No patients found');
//                 } else {
//                   // Render your list of patients using snapshot.data
//                   return SingleChildScrollView(
//                     child: Column(
//                       children: hasUserInput
//                           ? _buildPatientsList(snapshot.data!)
//                           : _buildPatientsList(snapshot.data!),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// List<Widget> _buildPatientsList(
//   List<QueryDocumentSnapshot<Map<String, dynamic>>> patients,
// ) {
//   // Sort the patients list alphabetically by patientName
//   patients.sort((a, b) {
//     final patientDataA = a.data();
//     final patientDataB = b.data();
//     final patientNameA = patientDataA['patientName'] as String;
//     final patientNameB = patientDataB['patientName'] as String;
//     return patientNameA.compareTo(patientNameB);
//   });

//   List<Widget> widgets = [];
//   String currentAlphabet = '';

//   for (final patient in patients) {
//     final patientData = patient.data();
//     final patientName = patientData['patientName'] as String;
//     final patientFirstChar = patientName.isNotEmpty ? patientName[0] : '';

//     if (patientFirstChar != currentAlphabet) {
//       // Add a header widget with a bigger font size
//       widgets.add(
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           child: Text(
//             patientFirstChar.toUpperCase(),
//             style: MyTextStyle.textStyleMap['headline-large']
//                 ?.copyWith(color: MyColors.colorPalette['on-surface-variant']),
//           ),
//         ),
//       );
//       currentAlphabet = patientFirstChar;
//     }

//     // Add the patient ListTile
//     widgets.add(
//       Card(
//         child: ListTile(
//           leading: CircleAvatar(
//             radius: 24,
//             backgroundColor: MyColors.colorPalette['surface'],
//           ),
//           title: Text(
//             patientName,
//             style: MyTextStyle.textStyleMap['label-medium']
//                 ?.copyWith(color: MyColors.colorPalette['on-surface']),
//           ),
//           subtitle: Text(
//             '${patientData['patientMobileNumber']}',
//             style: MyTextStyle.textStyleMap['label-medium']
//                 ?.copyWith(color: MyColors.colorPalette['on-surface-variant']),
//           ),
//         ),
//       ),
//     );
//   }

//   return widgets;
// }
