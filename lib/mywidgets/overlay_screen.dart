// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/my_bottom_navigation_bar.dart';
// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/patient_search_widget.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';

// class OverlayScreen extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;

//   const OverlayScreen({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.patientService,
//   });

//   @override
//   State<OverlayScreen> createState() => _OverlayScreenState();
// }

// class _OverlayScreenState extends State<OverlayScreen> {
//   static const int defaultIndex = 2;
//   int _currentIndex = defaultIndex;

//   void onPatientSelectedForTreatment(Patient patient) {
//     if (mounted) {
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => TreatmentLandingScreen(
//             doctorId: widget.doctorId,
//             doctorName: widget.doctorName,
//             clinicId: widget.clinicId,
//             patientId: patient.patientId,
//             age: patient.age,
//             gender: patient.gender,
//             patientName: patient.patientName,
//             patientMobileNumber: patient.patientMobileNumber,
//             patientPicUrl: patient.patientPicUrl,
//             uhid: patient.uhid,
//           ),
//         ),
//       );
//     }
//   }

//   void _onTabTapped(int index) {
//     setState(
//       () {
//         _currentIndex = index;
//         if (_currentIndex == 0) {
//           // Navigate to LandingScreen
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const LandingScreen()),
//           );
//         } else if (_currentIndex == 1) {
//           // Navigate to CalendarView
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CalenderView(
//                 doctorId: widget.doctorId,
//                 doctorName: widget.doctorName,
//                 clinicId: widget.clinicId,
//                 patientService: widget.patientService,
//               ),
//             ),
//           );
//         } else if (_currentIndex == 3) {
//           // Navigate to MyProfile
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SearchAndDisplayAllPatients(
//                 // Pass necessary parameters
//                 doctorId: widget.doctorId,
//                 doctorName: widget.doctorName,
//                 clinicId: widget.clinicId,
//                 patientService: widget.patientService,
//               ),
//             ),
//           );
//         } else if (_currentIndex == 4) {
//           // Navigate to MyProfile
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => MyProfile(
//                 // Pass necessary parameters
//                 doctorId: widget.doctorId,
//                 doctorName: widget.doctorName,
//                 clinicId: widget.clinicId,
//                 patientService: widget.patientService,
//               ),
//             ),
//           );
//           // }
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context).pop(); // Dismiss the overlay on tap outside
//       },
//       child: Stack(
//         children: [
//           const LandingScreen(),
//           // Positioned menu items
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 80,
//             child: Material(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: MyColors.colorPalette['surface'],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Create',
//                           style:
//                               MyTextStyle.textStyleMap['title-large']?.copyWith(
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor:
//                               MyColors.colorPalette['outline-variant'],
//                           child: const Icon(Icons.person_outline),
//                         ),
//                         title: Text(
//                           'Create New Patient',
//                           style: MyTextStyle.textStyleMap['title-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => AddNewPatient(
//                                 clinicId: widget.clinicId,
//                                 doctorId: widget.doctorId,
//                                 doctorName: widget.doctorName,
//                                 patientService: widget.patientService,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 24),
//                       ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor:
//                               MyColors.colorPalette['outline-variant'],
//                           child: SvgPicture.asset(
//                             'assets/icons/medicines.svg',
//                             height: 24,
//                           ),
//                         ),
//                         title: Text(
//                           'Start New Treatment',
//                           style: MyTextStyle.textStyleMap['title-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => SearchAndAddPatient(
//                                 clinicId: widget.clinicId,
//                                 doctorId: widget.doctorId,
//                                 doctorName: widget.doctorName,
//                                 patientService: widget.patientService,
//                                 onPatientSelectedForTreatment:
//                                     onPatientSelectedForTreatment,
//                                 onPatientSelectedForAppointment: null,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 24),
//                       ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor:
//                               MyColors.colorPalette['outline-variant'],
//                           child: const Icon(Icons.access_time),
//                         ),
//                         title: Text(
//                           'Book Appointment',
//                           style: MyTextStyle.textStyleMap['title-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => BookAppointment(
//                                 clinicId: widget.clinicId,
//                                 doctorId: widget.doctorId,
//                                 doctorName: widget.doctorName,
//                                 patientService: widget.patientService,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 24),
//                       ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor:
//                               MyColors.colorPalette['outline-variant'],
//                           child: const Icon(Icons.access_time),
//                         ),
//                         title: Text(
//                           'Patient-Search',
//                           style: MyTextStyle.textStyleMap['title-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => PatientSearchWidget(
//                                 clinicId: widget.clinicId,
//                                 doctorId: widget.doctorId,
//                                 doctorName: widget.doctorName,
//                                 patientService: widget.patientService,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 80),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           // Positioned bottom bar
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: MyBottomNavigationBar(
//               currentIndex: _currentIndex,
//               onTap: _onTabTapped,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ************* */
// @override
// Widget build(BuildContext context) {
//   return GestureDetector(
//     onTap: () {
//       Navigator.of(context).pop(); // Dismiss the overlay on tap outside
//     },
//     child: Stack(
//       children: [
        
//         Container(
//           decoration: BoxDecoration(
//             color: MyColors.colorPalette['surface'],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Create',
//                     style:
//                         MyTextStyle.textStyleMap['title-large']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor:
//                         MyColors.colorPalette['outline-variant'],
//                     child: const Icon(Icons.person_outline),
//                   ),
//                   title: Text(
//                     'Create New Patient',
//                     style:
//                         MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => AddNewPatient(
//                           clinicId: widget.clinicId,
//                           doctorId: widget.doctorId,
//                           doctorName: widget.doctorName,
//                           patientService: widget.patientService,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor:
//                         MyColors.colorPalette['outline-variant'],
//                     child: SvgPicture.asset(
//                       'assets/icons/medicines.svg',
//                       height: 24,
//                     ),
//                   ),
//                   title: Text(
//                     'Start New Treatment',
//                     style:
//                         MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => SearchAndAddPatient(
//                           clinicId: widget.clinicId,
//                           doctorId: widget.doctorId,
//                           doctorName: widget.doctorName,
//                           patientService: widget.patientService,
//                           onPatientSelectedForTreatment:
//                               onPatientSelectedForTreatment,
//                           onPatientSelectedForAppointment: null,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor:
//                         MyColors.colorPalette['outline-variant'],
//                     child: const Icon(Icons.access_time),
//                   ),
//                   title: Text(
//                     'Book Appointment',
//                     style:
//                         MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => BookAppointment(
//                           clinicId: widget.clinicId,
//                           doctorId: widget.doctorId,
//                           doctorName: widget.doctorName,
//                           patientService: widget.patientService,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor:
//                         MyColors.colorPalette['outline-variant'],
//                     child: const Icon(Icons.access_time),
//                   ),
//                   title: Text(
//                     'Patient-Search',
//                     style:
//                         MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PatientSearchWidget(
//                           clinicId: widget.clinicId,
//                           doctorId: widget.doctorId,
//                           doctorName: widget.doctorName,
//                           patientService: widget.patientService,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 80),
//               ],
//             ),
//           ),
//         ),
        
//         MyBottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: _onTabTapped,
//         ),
//       ],
//     ),
//   );
// }
//************ */

//******** */
// CODE BELOW IS STABLE WITH CALLBACK FUNCTIONS
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/patient_search_widget.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';

// class OverlayScreen extends StatefulWidget {
//   final Function onAddButtonPressed;
//   final void Function(Patient) onPatientSelectedForTreatment;
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;

//   const OverlayScreen({
//     super.key,
//     required this.onAddButtonPressed,
//     required this.onPatientSelectedForTreatment,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.patientService,
//   });

//   @override
//   State<OverlayScreen> createState() => _OverlayScreenState();
// }

// class _OverlayScreenState extends State<OverlayScreen> {
//   void onPatientSelectedForTreatment(Patient patient) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => TreatmentLandingScreen(
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           clinicId: widget.clinicId,
//           patientId: patient.patientId,
//           age: patient.age,
//           gender: patient.gender,
//           patientName: patient.patientName,
//           patientMobileNumber: patient.patientMobileNumber,
//           patientPicUrl: patient.patientPicUrl,
//           uhid: patient.uhid,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context).pop(); // Dismiss the overlay on tap outside
//       },
//       child: Stack(
//         children: [
//           const LandingScreen(),
//           // Positioned menu items
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 80,
//             child: Material(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: MyColors.colorPalette['surface'],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Create',
//                           style:
//                               MyTextStyle.textStyleMap['title-large']?.copyWith(
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor:
//                               MyColors.colorPalette['outline-variant'],
//                           child: const Icon(Icons.person_outline),
//                         ),
//                         title: Text(
//                           'Create New Patient',
//                           style: MyTextStyle.textStyleMap['title-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => AddNewPatient(
//                                 clinicId: widget.clinicId,
//                                 doctorId: widget.doctorId,
//                                 doctorName: widget.doctorName,
//                                 patientService: widget.patientService,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 24),
//                       ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor:
//                               MyColors.colorPalette['outline-variant'],
//                           child: SvgPicture.asset(
//                             'assets/icons/medicines.svg',
//                             height: 24,
//                           ),
//                         ),
//                         title: Text(
//                           'Start New Treatment',
//                           style: MyTextStyle.textStyleMap['title-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => SearchAndAddPatient(
//                                 clinicId: widget.clinicId,
//                                 doctorId: widget.doctorId,
//                                 doctorName: widget.doctorName,
//                                 patientService: widget.patientService,
//                                 onPatientSelectedForTreatment:
//                                     widget.onPatientSelectedForTreatment,
//                                 onPatientSelectedForAppointment: null,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 24),
//                       ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor:
//                               MyColors.colorPalette['outline-variant'],
//                           child: const Icon(Icons.access_time),
//                         ),
//                         title: Text(
//                           'Book Appointment',
//                           style: MyTextStyle.textStyleMap['title-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => BookAppointment(
//                                 clinicId: widget.clinicId,
//                                 doctorId: widget.doctorId,
//                                 doctorName: widget.doctorName,
//                                 patientService: widget.patientService,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 24),
//                       ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor:
//                               MyColors.colorPalette['outline-variant'],
//                           child: const Icon(Icons.access_time),
//                         ),
//                         title: Text(
//                           'Patient-Search',
//                           style: MyTextStyle.textStyleMap['title-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => PatientSearchWidget(
//                                 clinicId: widget.clinicId,
//                                 doctorId: widget.doctorId,
//                                 doctorName: widget.doctorName,
//                                 patientService: widget.patientService,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 80),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//********** */
// code below is stable
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/patient_search_widget.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';

// class OverlayScreen extends StatefulWidget {
//   final Function onAddButtonPressed;

//   final void Function(Patient) onPatientSelectedForTreatment;
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;

//   const OverlayScreen({
//     super.key,
//     required this.onAddButtonPressed,
//     required this.onPatientSelectedForTreatment,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.patientService,
//   });

//   @override
//   State<OverlayScreen> createState() => _OverlayScreenState();
// }

// class _OverlayScreenState extends State<OverlayScreen> {
//   void onPatientSelectedForTreatment(Patient patient) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => TreatmentLandingScreen(
//           // Pass patient details to TreatmentLandingScreen
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           clinicId: widget.clinicId,
//           patientId: patient.patientId,
//           age: patient.age,
//           gender: patient.gender,
//           patientName: patient.patientName,
//           patientMobileNumber: patient.patientMobileNumber,
//           patientPicUrl: patient.patientPicUrl,
//           uhid: patient.uhid,
//           // Additional parameters as needed by TreatmentLandingScreen
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         const LandingScreen(),
//         // Background overlay with a transparent background
//         Positioned.fill(
//           child: GestureDetector(
//             onTap: () {
//               // Close the overlay if the background is tapped
//               Navigator.of(context).pop();
//             },
//             child: Container(
//               //color: Colors.black.withOpacity(0),
//               color: Colors.transparent, // Set background to transparent
//             ),
//           ),
//         ),
//         // Positioned menu items
//         Positioned(
//           left: 0,
//           right: 0,
//           bottom: 80,
//           child: Material(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: MyColors.colorPalette['surface'],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Create',
//                         style:
//                             MyTextStyle.textStyleMap['title-large']?.copyWith(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor:
//                             MyColors.colorPalette['outline-variant'],
//                         child: const Icon(Icons.person_outline),
//                       ),
//                       title: Text(
//                         'Create New Patient',
//                         style:
//                             MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.of(context).pop();

//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => AddNewPatient(
//                               clinicId: widget.clinicId,
//                               doctorId: widget.doctorId,
//                               patientService: widget.patientService,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                     ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor:
//                             MyColors.colorPalette['outline-variant'],
//                         child: SvgPicture.asset(
//                           'assets/icons/medicines.svg', // Path to your SVG file
//                           height: 24, // Adjust the icon's height
//                         ),
//                       ),
//                       title: Text(
//                         'Start New Treatment',
//                         style:
//                             MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.of(context).pop();
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => SearchAndAddPatient(
//                               clinicId: widget.clinicId,
//                               doctorId: widget.doctorId,
//                               doctorName: widget.doctorName,
//                               patientService: widget.patientService,
//                               onPatientSelectedForTreatment:
//                                   widget.onPatientSelectedForTreatment,
//                               onPatientSelectedForAppointment: null,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                     ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor:
//                             MyColors.colorPalette['outline-variant'],
//                         child: const Icon(Icons.access_time),
//                       ),
//                       title: Text(
//                         'Book Appointment',
//                         style:
//                             MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.of(context).pop();

//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => BookAppointment(
//                               clinicId: widget.clinicId,
//                               doctorId: widget.doctorId,
//                               doctorName: widget.doctorName,
//                               patientService: widget.patientService,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                     ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor:
//                             MyColors.colorPalette['outline-variant'],
//                         child: const Icon(Icons.access_time),
//                       ),
//                       title: Text(
//                         'Patient-Search',
//                         style:
//                             MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.of(context).pop();

//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => PatientSearchWidget(
//                               clinicId: widget.clinicId,
//                               doctorId: widget.doctorId,
//                               doctorName: widget.doctorName,
//                               patientService: widget.patientService,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 80),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// code below uses showDialog
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';

// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/patient_search_widget.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';

// class OverlayScreen extends StatefulWidget {
//   final Function onAddButtonPressed;
//   final void Function(Patient) onPatientSelectedForTreatment;
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;

//   const OverlayScreen({
//     super.key,
//     required this.onAddButtonPressed,
//     required this.onPatientSelectedForTreatment,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.patientService,
//   });

//   @override
//   State<OverlayScreen> createState() => _OverlayScreenState();
// }

// class _OverlayScreenState extends State<OverlayScreen> {
//   void onPatientSelectedForTreatment(Patient patient) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => TreatmentLandingScreen(
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           clinicId: widget.clinicId,
//           patientId: patient.patientId,
//           age: patient.age,
//           gender: patient.gender,
//           patientName: patient.patientName,
//           patientMobileNumber: patient.patientMobileNumber,
//           patientPicUrl: patient.patientPicUrl,
//           uhid: patient.uhid,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context).pop();
//       },
//       child: AlertDialog(
//         insetPadding: EdgeInsets.zero,
//         content: Container(
//           decoration: BoxDecoration(
//             color: MyColors.colorPalette['surface'],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Create',
//                     style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: MyColors.colorPalette['outline-variant'],
//                     child: const Icon(Icons.person_outline),
//                   ),
//                   title: Text(
//                     'Create New Patient',
//                     style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => AddNewPatient(
//                           clinicId: widget.clinicId,
//                           doctorId: widget.doctorId,
//                           patientService: widget.patientService,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: MyColors.colorPalette['outline-variant'],
//                     child: SvgPicture.asset(
//                       'assets/icons/medicines.svg',
//                       height: 24,
//                     ),
//                   ),
//                   title: Text(
//                     'Start New Treatment',
//                     style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => SearchAndAddPatient(
//                           clinicId: widget.clinicId,
//                           doctorId: widget.doctorId,
//                           doctorName: widget.doctorName,
//                           patientService: widget.patientService,
//                           onPatientSelectedForTreatment:
//                               widget.onPatientSelectedForTreatment,
//                           onPatientSelectedForAppointment: null,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: MyColors.colorPalette['outline-variant'],
//                     child: const Icon(Icons.access_time),
//                   ),
//                   title: Text(
//                     'Book Appointment',
//                     style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => BookAppointment(
//                           clinicId: widget.clinicId,
//                           doctorId: widget.doctorId,
//                           doctorName: widget.doctorName,
//                           patientService: widget.patientService,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: MyColors.colorPalette['outline-variant'],
//                     child: const Icon(Icons.access_time),
//                   ),
//                   title: Text(
//                     'Patient-Search',
//                     style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PatientSearchWidget(
//                           clinicId: widget.clinicId,
//                           doctorId: widget.doctorId,
//                           doctorName: widget.doctorName,
//                           patientService: widget.patientService,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 80),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
