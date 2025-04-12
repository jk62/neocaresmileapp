// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/constants/routes.dart';
// import 'package:neocare_dental_app/firestore/clinic_doctor_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/drop_down_menu.dart';
// import 'package:neocare_dental_app/mywidgets/my_bottom_navigation_bar.dart';
// import 'dart:developer' as devtools show log;

// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/patient_search_widget.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';

// class OverlayAddScreen extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;
//   const OverlayAddScreen(
//       {super.key,
//       required this.doctorId,
//       required this.doctorName,
//       required this.clinicId,
//       required this.patientService});

//   @override
//   State<OverlayAddScreen> createState() => _OverlayAddScreenState();
// }

// class _OverlayAddScreenState extends State<OverlayAddScreen> {
//   //String doctorName = '';
//   //String loggedInDoctorId = '';
//   List<String> clinicNames = [];
//   String selectedClinicName = '';
//   //String selectedClinicId = '';
//   bool _isLoading = false;

//   static const int defaultIndex = 2;
//   int _currentIndex = defaultIndex;

//   @override
//   void initState() {
//     super.initState();
//     devtools.log(
//         'This is coming from inside OverlayAddScreen - initState'); // Add this print statement

//     fetchDoctorData();
//   }

//   Future<void> fetchDoctorData() async {
//     devtools.log('fetchDoctorData called');
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       String userId = FirebaseAuth.instance.currentUser!.uid;

//       DoctorService doctorService = DoctorService();
//       Map<String, dynamic>? doctorData =
//           await doctorService.fetchDoctorData(userId);

//       if (doctorData?.isNotEmpty == true) {
//         setState(() {
//           //doctorName = doctorData?['doctorName'] ?? '';
//           //loggedInDoctorId = doctorData?['userId'];

//           List<dynamic> clinicsMapped = doctorData?['clinicsMapped'];
//           clinicNames = clinicsMapped
//               .map((clinic) => clinic['clinicName'] as String)
//               .toList();

//           if (clinicNames.isNotEmpty) {
//             selectedClinicName = clinicNames[0];
//             ClinicService clinicService = ClinicService();
//             clinicService.getClinicId(selectedClinicName).then((clinicId) {
//               setState(() {
//                 //selectedClinicId = clinicId;
//                 //initializePatientService(); // Initialize _patientService here
//                 _isLoading = false;
//               });
//             }).catchError((error) {
//               devtools.log(error.toString());
//               _isLoading = false;
//             });
//           } else {
//             _isLoading = false;
//           }
//         });
//       } else {
//         _isLoading = false;
//       }
//     } catch (e) {
//       devtools.log(e.toString());
//       _isLoading = false;
//       devtools.log(
//           'This is coming from catch block of fetchDoctorData. The error is : $e');
//     }
//   }

//   void _onClinicSelected(String clinicName) {
//     selectedClinicName = clinicName;
//     ClinicService clinicService = ClinicService();
//     clinicService.getClinicId(clinicName).then((clinicId) {
//       setState(() {
//         //selectedClinicId = clinicId;
//         //_patientService = PatientService(selectedClinicId, loggedInDoctorId);
//       });
//     }).catchError((error) {
//       devtools.log(error.toString());
//     });
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

//   @override
//   Widget build(BuildContext context) {
//     String currentDate = DateFormat('MMM d').format(DateTime.now());
//     String currentDay = DateFormat('E').format(DateTime.now());

//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     } else {
//       return GestureDetector(
//         onTap: () {
//           devtools.log(Navigator.of(context).toString());
//           devtools.log('Tapped outside scaffold');

//           if (Navigator.canPop(context)) {
//             Navigator.pop(context);
//           } else {
//             // Navigator.pushReplacementNamed(context, landingScreenRoute);
//             //Navigator.pushReplacementNamed(context, LandingScreen.routeName);
//             Navigator.pushNamedAndRemoveUntil(
//               context,
//               LandingScreen.routeName,
//               (route) => false, // Remove all routes until the new route
//             );
//           }
//         },
//         child: Scaffold(
//           appBar: PreferredSize(
//             preferredSize: const Size.fromHeight(256),
//             child: Stack(
//               children: [
//                 const Positioned.fill(
//                   child: Image(
//                     image: AssetImage('assets/images/img1.png'),
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Visibility(
//                       visible: clinicNames.isNotEmpty,
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: 40),
//                         child: DropDownMenu(
//                           clinicNames: clinicNames,
//                           onClinicSelected: _onClinicSelected,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 48),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '$currentDay, $currentDate',
//                               style: MyTextStyle.textStyleMap['title-medium']
//                                   ?.copyWith(
//                                 color:
//                                     MyColors.colorPalette['on_surface-variant'],
//                               ),
//                             ),
//                             const SizedBox(height: 8.0),
//                             Text(
//                               'Hi ${widget.doctorName}',
//                               style: MyTextStyle.textStyleMap['title-large']
//                                   ?.copyWith(
//                                 color: MyColors.colorPalette['on_surface'],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           body: Stack(
//             children: [
//               Container(
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
//                         //onTap: () {},
//                         onTap: () {
//                           // Navigate to AddNewPatient screen
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
//                         //onTap: () {},
//                         onTap: () {
//                           // Navigate to SearchAndAddPatient screen
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
//                         //onTap: () {},
//                         onTap: () {
//                           // Navigate to BookAppointment screen
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
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           bottomNavigationBar: MyBottomNavigationBar(
//             currentIndex: _currentIndex,
//             onTap: _onTabTapped,
//           ),
//         ),
//       );
//     }
//   }
// }

//*********** */
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/constants/routes.dart';
// import 'package:neocare_dental_app/firestore/clinic_doctor_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/drop_down_menu.dart';
// import 'package:neocare_dental_app/mywidgets/my_bottom_navigation_bar.dart';
// import 'dart:developer' as devtools show log;

// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/patient_search_widget.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';

// class OverlayAddScreen extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;
//   const OverlayAddScreen(
//       {super.key,
//       required this.doctorId,
//       required this.doctorName,
//       required this.clinicId,
//       required this.patientService});

//   @override
//   State<OverlayAddScreen> createState() => _OverlayAddScreenState();
// }

// class _OverlayAddScreenState extends State<OverlayAddScreen> {
//   //String doctorName = '';
//   //String loggedInDoctorId = '';
//   List<String> clinicNames = [];
//   String selectedClinicName = '';
//   //String selectedClinicId = '';
//   bool _isLoading = false;

//   static const int defaultIndex = 2;
//   int _currentIndex = defaultIndex;

//   @override
//   void initState() {
//     super.initState();
//     devtools.log(
//         'This is coming from inside OverlayAddScreen - initState'); // Add this print statement

//     fetchDoctorData();
//   }

//   Future<void> fetchDoctorData() async {
//     devtools.log('fetchDoctorData called');
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       String userId = FirebaseAuth.instance.currentUser!.uid;

//       DoctorService doctorService = DoctorService();
//       Map<String, dynamic>? doctorData =
//           await doctorService.fetchDoctorData(userId);

//       if (doctorData?.isNotEmpty == true) {
//         setState(() {
//           //doctorName = doctorData?['doctorName'] ?? '';
//           //loggedInDoctorId = doctorData?['userId'];

//           List<dynamic> clinicsMapped = doctorData?['clinicsMapped'];
//           clinicNames = clinicsMapped
//               .map((clinic) => clinic['clinicName'] as String)
//               .toList();

//           if (clinicNames.isNotEmpty) {
//             selectedClinicName = clinicNames[0];
//             ClinicService clinicService = ClinicService();
//             clinicService.getClinicId(selectedClinicName).then((clinicId) {
//               setState(() {
//                 //selectedClinicId = clinicId;
//                 //initializePatientService(); // Initialize _patientService here
//                 _isLoading = false;
//               });
//             }).catchError((error) {
//               devtools.log(error.toString());
//               _isLoading = false;
//             });
//           } else {
//             _isLoading = false;
//           }
//         });
//       } else {
//         _isLoading = false;
//       }
//     } catch (e) {
//       devtools.log(e.toString());
//       _isLoading = false;
//       devtools.log(
//           'This is coming from catch block of fetchDoctorData. The error is : $e');
//     }
//   }

//   void _onClinicSelected(String clinicName) {
//     selectedClinicName = clinicName;
//     ClinicService clinicService = ClinicService();
//     clinicService.getClinicId(clinicName).then((clinicId) {
//       setState(() {
//         //selectedClinicId = clinicId;
//         //_patientService = PatientService(selectedClinicId, loggedInDoctorId);
//       });
//     }).catchError((error) {
//       devtools.log(error.toString());
//     });
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

//   @override
//   Widget build(BuildContext context) {
//     String currentDate = DateFormat('MMM d').format(DateTime.now());
//     String currentDay = DateFormat('E').format(DateTime.now());

//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     } else {
//       return GestureDetector(
//         onTap: () {
//           devtools.log(Navigator.of(context).toString());
//           devtools.log('Tapped outside scaffold');

//           // Navigator.of(context).popUntil(
//           //     ModalRoute.withName('/')); // Dismiss the overlay on tap outside
//           // Navigator.pushReplacementNamed(context, landingScreenRoute);
//           if (Navigator.canPop(context)) {
//             Navigator.pop(context);
//           } else {
//             Navigator.pushReplacementNamed(context, landingScreenRoute);
//           }
//         },
//         child: Scaffold(
//           appBar: PreferredSize(
//             preferredSize: const Size.fromHeight(256),
//             child: Stack(
//               children: [
//                 const Positioned.fill(
//                   child: Image(
//                     image: AssetImage('assets/images/img1.png'),
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Visibility(
//                       visible: clinicNames.isNotEmpty,
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: 40),
//                         child: DropDownMenu(
//                           clinicNames: clinicNames,
//                           onClinicSelected: _onClinicSelected,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 48),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '$currentDay, $currentDate',
//                               style: MyTextStyle.textStyleMap['title-medium']
//                                   ?.copyWith(
//                                 color:
//                                     MyColors.colorPalette['on_surface-variant'],
//                               ),
//                             ),
//                             const SizedBox(height: 8.0),
//                             Text(
//                               'Hi ${widget.doctorName}',
//                               style: MyTextStyle.textStyleMap['title-large']
//                                   ?.copyWith(
//                                 color: MyColors.colorPalette['on_surface'],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           body: Stack(
//             children: [
//               Container(
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
          //               onTap: () {
          //                 Navigator.of(context).pop();
          //                 Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                     builder: (context) => AddNewPatient(
          //                       clinicId: widget.clinicId,
          //                       doctorId: widget.doctorId,
          //                       doctorName: widget.doctorName,
          //                       patientService: widget.patientService,
          //                     ),
          //                   ),
          //                 );
          //               },
          //             ),
          //             const SizedBox(height: 24),
          //             ListTile(
          //               leading: CircleAvatar(
          //                 backgroundColor:
          //                     MyColors.colorPalette['outline-variant'],
          //                 child: SvgPicture.asset(
          //                   'assets/icons/medicines.svg',
          //                   height: 24,
          //                 ),
          //               ),
          //               title: Text(
          //                 'Start New Treatment',
          //                 style: MyTextStyle.textStyleMap['title-medium']
          //                     ?.copyWith(
          //                   color: MyColors.colorPalette['on-surface'],
          //                 ),
          //               ),
          //               onTap: () {
          //                 Navigator.of(context).pop();
          //                 Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                     builder: (context) => SearchAndAddPatient(
          //                       clinicId: widget.clinicId,
          //                       doctorId: widget.doctorId,
          //                       doctorName: widget.doctorName,
          //                       patientService: widget.patientService,
          //                       onPatientSelectedForTreatment:
          //                           onPatientSelectedForTreatment,
          //                       onPatientSelectedForAppointment: null,
          //                     ),
          //                   ),
          //                 );
          //               },
          //             ),
          //             const SizedBox(height: 24),
          //             ListTile(
          //               leading: CircleAvatar(
          //                 backgroundColor:
          //                     MyColors.colorPalette['outline-variant'],
          //                 child: const Icon(Icons.access_time),
          //               ),
          //               title: Text(
          //                 'Book Appointment',
          //                 style: MyTextStyle.textStyleMap['title-medium']
          //                     ?.copyWith(
          //                   color: MyColors.colorPalette['on-surface'],
          //                 ),
          //               ),
          //               onTap: () {
          //                 Navigator.of(context).pop();
          //                 Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                     builder: (context) => BookAppointment(
          //                       clinicId: widget.clinicId,
          //                       doctorId: widget.doctorId,
          //                       doctorName: widget.doctorName,
          //                       patientService: widget.patientService,
          //                     ),
          //                   ),
          //                 );
          //               },
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
//           bottomNavigationBar: MyBottomNavigationBar(
//             currentIndex: _currentIndex,
//             onTap: _onTabTapped,
//           ),
//         ),
//       );
//     }
//   }
// }
