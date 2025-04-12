// // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// // CODE BELOW STABLE WITHOUT onPatientSelectedForCallback FUNCTION
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/clinic_doctor_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/my_bottom_navigation_bar.dart';
// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'dart:developer' as devtools show log;
// import 'package:provider/provider.dart';

// class OverlayView extends StatefulWidget {
//   const OverlayView({super.key});

//   @override
//   State<OverlayView> createState() => _OverlayViewState();
// }

// class _OverlayViewState extends State<OverlayView> {
//   int _currentIndex = 0;
//   bool _isOverlayVisible = false;

//   String _collectedDoctorId = '';
//   String _collectedDoctorName = '';
//   String _collectedClinicId = '';
//   PatientService _collectedPatientService = PatientService('', '');
//   List<String> _collectedClinicNames = [];
//   String _collectedSelectedClinicName = '';

//   late PatientService _patientService;
//   String doctorName = '';
//   String loggedInDoctorId = '';
//   List<String> clinicNames = [];
//   String selectedClinicName = '';
//   String selectedClinicId = '';
//   bool _isLoading = false;
//   bool _isLoadingData = true;
//   bool isFetchingData = true;
//   //bool showBottomNavBar = true;
//   // bool _showBottomNavBar = true; // Default value

//   final Map<int, Widget> _screens = {};

//   final clinicSelection = ClinicSelection.instance;

//   @override
//   void initState() {
//     super.initState();
//     fetchData().then((doctorData) {
//       devtools.log('[log]- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//       devtools.log('[log]- This is coming from inside OverlayView - initState');
//       devtools.log('[log]-  ${DateTime.now()} ');
//       devtools.log(
//           '[log] -  Hi from inside initState ! doctotData is : $doctorData ');
//       devtools.log('[log]- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

//       setState(() {
//         _isLoadingData =
//             false; // Set loading indicator to false once data is fetched

//         doctorName = doctorData['doctorName'];
//         loggedInDoctorId = doctorData['userId'];

//         List<dynamic> clinicsMapped = doctorData['clinicsMapped'];
//         selectedClinicId = clinicsMapped[0]['clinicId'];
//         _collectedDoctorId = loggedInDoctorId;
//         _collectedDoctorName = doctorName;
//         _collectedClinicId = selectedClinicId;
//         initializePatientService();
//         _collectedPatientService = _patientService;

//         devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//         devtools.log('This is coming from inside initState !');
//         devtools
//             .log('_collectedDoctorId is populated with $_collectedDoctorId');
//         devtools.log(
//             '_collectedDoctorName is populated with $_collectedDoctorName');
//         devtools
//             .log('_collectedClinicId is populated with $_collectedClinicId');
//         devtools.log(
//             '_collectedPatientService is populated with $_collectedPatientService');

//         devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

//         _buildScreens(doctorData);
//       });
//     });
//   }

//   void initializePatientService() {
//     _patientService = PatientService(selectedClinicId, loggedInDoctorId);
//   }

//   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//   Future<Map<String, dynamic>> fetchData() async {
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       String userId = user.uid;
//       Map<String, dynamic>? doctorData =
//           await DoctorService().fetchDoctorDataForUser(userId) ?? {};

//       setState(() {
//         if (doctorData.isNotEmpty) {
//           doctorName = doctorData['doctorName']; //?? '';
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
//               clinicSelection.updateParameters(selectedClinicName, clinicNames);

//               _collectedDoctorId = loggedInDoctorId;
//               _collectedDoctorName = doctorName;
//               _collectedClinicId = selectedClinicId;
//               _collectedPatientService = _patientService;
//               _collectedClinicNames = clinicNames;
//               _collectedSelectedClinicName = selectedClinicName;

//               devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//               devtools.log('This is coming from inside fetchData !');
//               devtools.log(
//                   '_collectedDoctorId is populated with $_collectedDoctorId');
//               devtools.log(
//                   '_collectedDoctorName is populated with $_collectedDoctorName');
//               devtools.log(
//                   '_collectedClinicId is populated with $_collectedClinicId');
//               devtools.log(
//                   '_collectedPatientService is populated with $_collectedPatientService');
//               devtools.log(
//                   '_collectedClinicNames is populated with $_collectedClinicNames');
//               devtools.log(
//                   '_collectedSelectedClinicName is populated with $_collectedSelectedClinicName');
//               devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
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

//   void _toggleOverlay() {
//     setState(() {
//       _isOverlayVisible = !_isOverlayVisible;
//     });
//   }

//   void _navigateToAddNewPatient() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddNewPatient(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         ),
//       ),
//     ).then((_) {
//       // This code runs when the AddNewPatient screen is popped (navigated back from).
//       // You can use this callback to remove the overlay.
//       _toggleOverlay();
//     });
//   }

//   void _navigateToStartNewTreatment() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddNewPatient(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         ),
//       ),
//     ).then((_) {
//       // This code runs when the AddNewPatient screen is popped (navigated back from).
//       // You can use this callback to remove the overlay.
//       _toggleOverlay();
//     });
//   }

//   void _navigateToBookAppointment() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => BookAppointment(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         ),
//       ),
//     ).then((_) {
//       // This code runs when the BookAppointment screen is popped (navigated back from).
//       // You can use this callback to remove the overlay.
//       _toggleOverlay();
//     });
//   }

//   Widget _buildOverlay() {
//     return Stack(
//       children: [
//         GestureDetector(
//           onTap: () {
//             _toggleOverlay();
//           },
//           child: Container(
//             color: Colors.transparent,
//           ),
//         ),
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             decoration: BoxDecoration(
//               color: MyColors.colorPalette['surface-bright'],
//             ),
//             height: MediaQuery.of(context).size.height / 2,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                       IconButton(
//                         icon: Icon(
//                           Icons.close,
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                         onPressed: () {
//                           _toggleOverlay();
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.person_outline),
//                     ),
//                     title: Text(
//                       'Add New Patient',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: _navigateToAddNewPatient,
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: SvgPicture.asset(
//                         'assets/icons/medicines.svg',
//                         height: 24,
//                       ),
//                     ),
//                     title: Text(
//                       'Start New Treatment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: _navigateToStartNewTreatment,
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.access_time),
//                     ),
//                     title: Text(
//                       'Book Appointment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: _navigateToBookAppointment,
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _buildScreens(Map<String, dynamic> doctorData) {
//     //devtools.log('[log]-  ${DateTime.now()} ');
//     _buildScreen(0, doctorData); // LandingScreen
//     _buildScreen(1, doctorData); // CalenderView
//     _buildScreen(3, doctorData); // SearchAndDisplayAllPatients
//     _buildScreen(4, doctorData); // MyProfile
//   }

//   Widget _buildScreen(int index, Map<String, dynamic> doctorData) {
//     Widget screen;
//     //Widget? screen;

//     switch (index) {
//       case 0:
//         screen = LandingScreen(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );

//         break;

//       case 1:
//         screen = CalenderView(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//           showBottomNavigationBar: false,
//         );
//         devtools.log('case 1 triggered !');
//         break;

//       case 3:
//         screen = SearchAndDisplayAllPatients(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;

//       case 4:
//         screen = MyProfile(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;

//       default:
//         screen = Container();
//     }

//     _screens[index] = screen;
//     return screen;
//   }

//   Widget _buildLoadingIndicator() {
//     return const Center(
//       child: CircularProgressIndicator(),
//     );
//   }

// //   @override
// //   Widget build(BuildContext context) {
// //     devtools.log('OverlayView build method called');
// //     return Scaffold(
// //       body: Stack(
// //         children: [
// //           _isLoadingData
// //               ? _buildLoadingIndicator()
// //               : _buildScreen(_currentIndex, {}) ?? Container(),
// //           _isOverlayVisible ? _buildOverlay() : const SizedBox.shrink(),
// //         ],
// //       ),
// //       bottomNavigationBar: BottomNavigationBar(
// //         type: BottomNavigationBarType.fixed,
// //         currentIndex: _currentIndex,
// //         unselectedItemColor: MyColors.colorPalette['secondary'],
// //         selectedItemColor: MyColors.colorPalette['primary'],
// //         onTap: (index) {
// //           if (index == 2) {
// //             _toggleOverlay();
// //           } else if (_isOverlayVisible) {
// //             _toggleOverlay();
// //           } else {
// //             setState(() {
// //               _currentIndex = index;
// //             });
// //           }
// //         },
// //         items: [
// //           const BottomNavigationBarItem(
// //             icon: Icon(Icons.home_outlined, size: 24),
// //             activeIcon: Icon(Icons.home_filled, size: 24),
// //             label: 'Home',
// //           ),
// //           const BottomNavigationBarItem(
// //             icon: Icon(Icons.calendar_today_outlined, size: 24),
// //             activeIcon: Icon(Icons.calendar_today, size: 24),
// //             label: 'Calendar',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Container(
// //               decoration: BoxDecoration(
// //                 border: Border.all(
// //                   width: 2,
// //                   color: MyColors.colorPalette['secondary'] ?? Colors.blue,
// //                 ),
// //                 shape: BoxShape.circle,
// //               ),
// //               width: 40,
// //               height: 40,
// //               child: FloatingActionButton(
// //                 onPressed: _toggleOverlay,
// //                 backgroundColor: _isOverlayVisible
// //                     ? MyColors.colorPalette['primary']
// //                     : MyColors.colorPalette['on-primary'],
// //                 child: Icon(
// //                   Icons.add,
// //                   color: _isOverlayVisible
// //                       ? Colors.white
// //                       : MyColors.colorPalette['secondary'],
// //                   size: 35,
// //                 ),
// //               ),
// //             ),
// //             label: '',
// //           ),
// //           const BottomNavigationBarItem(
// //             icon: Icon(Icons.search_outlined, size: 24),
// //             activeIcon: Icon(Icons.search_sharp, size: 24),
// //             label: 'Search',
// //           ),
// //           const BottomNavigationBarItem(
// //             icon: Icon(Icons.person_outlined, size: 24),
// //             activeIcon: Icon(Icons.person, size: 24),
// //             label: 'Profile',
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

//   @override
//   Widget build(BuildContext context) {
//     try {
//       devtools.log('OverlayView build method called');
//       return Scaffold(
//         body: Stack(
//           children: [
//             _isLoadingData
//                 ? _buildLoadingIndicator()
//                 : _buildScreen(_currentIndex, {}) ?? Container(),
//             _isOverlayVisible ? _buildOverlay() : const SizedBox.shrink(),
//           ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: _currentIndex,
//           unselectedItemColor: MyColors.colorPalette['secondary'],
//           selectedItemColor: MyColors.colorPalette['primary'],
//           onTap: (index) {
//             if (index == 2) {
//               _toggleOverlay();
//             } else if (_isOverlayVisible) {
//               _toggleOverlay();
//             } else {
//               setState(() {
//                 _currentIndex = index;
//               });
//             }
//           },
//           items: [
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined, size: 24),
//               activeIcon: Icon(Icons.home_filled, size: 24),
//               label: 'Home',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_today_outlined, size: 24),
//               activeIcon: Icon(Icons.calendar_today, size: 24),
//               label: 'Calendar',
//             ),
//             BottomNavigationBarItem(
//               icon: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     width: 2,
//                     color: MyColors.colorPalette['secondary'] ?? Colors.blue,
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 width: 40,
//                 height: 40,
//                 child: FloatingActionButton(
//                   onPressed: _toggleOverlay,
//                   backgroundColor: _isOverlayVisible
//                       ? MyColors.colorPalette['primary']
//                       : MyColors.colorPalette['on-primary'],
//                   child: Icon(
//                     Icons.add,
//                     color: _isOverlayVisible
//                         ? Colors.white
//                         : MyColors.colorPalette['secondary'],
//                     size: 35,
//                   ),
//                 ),
//               ),
//               label: '',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.search_outlined, size: 24),
//               activeIcon: Icon(Icons.search_sharp, size: 24),
//               label: 'Search',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.person_outlined, size: 24),
//               activeIcon: Icon(Icons.person, size: 24),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       );
//     } catch (e, stackTrace) {
//       devtools.log('Error building OverlayView: $e');
//       devtools.log(stackTrace.toString());
//       // Optionally, return a placeholder widget or handle the error gracefully
//       return Container(
//         child: Text('Error: $e'),
//       );
//     }
//   }
// }
//------------------------------------------------------------------//
// Widget _buildOverlay() {
  //   return Stack(
  //     children: [
  //       GestureDetector(
  //         onTap: () {
  //           _toggleOverlay();
  //         },
  //         child: Container(
  //           color: Colors.transparent,
  //         ),
  //       ),
  //       Positioned(
  //         bottom: 0,
  //         left: 0,
  //         right: 0,
  //         child: Container(
  //           decoration: BoxDecoration(
  //             color: MyColors.colorPalette['surface-bright'],
  //           ),
  //           height: MediaQuery.of(context).size.height / 2,
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
  //                     IconButton(
  //                       icon: Icon(
  //                         Icons.close,
  //                         color: MyColors.colorPalette['on-surface'],
  //                       ),
  //                       onPressed: () {
  //                         _toggleOverlay();
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 24),
  //                 ListTile(
  //                   leading: CircleAvatar(
  //                     backgroundColor: MyColors.colorPalette['outline-variant'],
  //                     child: const Icon(Icons.person_outline),
  //                   ),
  //                   title: Text(
  //                     'Add New Patient',
  //                     style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
  //                       color: MyColors.colorPalette['on-surface'],
  //                     ),
  //                   ),
  //                   onTap: () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (context) => AddNewPatient(
  //                           doctorId: _collectedDoctorId,
  //                           doctorName: _collectedDoctorName,
  //                           clinicId: _collectedClinicId,
  //                           patientService: _collectedPatientService,
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
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (context) => SearchAndAddPatient(
  //                           doctorId: _collectedDoctorId,
  //                           doctorName: _collectedDoctorName,
  //                           clinicId: _collectedClinicId,
  //                           patientService: _collectedPatientService,
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
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (context) => BookAppointment(
  //                           doctorId: _collectedDoctorId,
  //                           doctorName: _collectedDoctorName,
  //                           clinicId: _collectedClinicId,
  //                           patientService: _collectedPatientService,
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //                 const SizedBox(height: 24),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
//-------------------------------------------------------------------//

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW WAS STABLE WITH MYBOTTOMNAVIGATIONBAR //
// START //
//   @override
//   Widget build(BuildContext bcontext) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           _isLoadingData
//               ? _buildLoadingIndicator()
//               : _buildScreen(_currentIndex, {}) ?? Container(),
//           _isOverlayVisible ? _buildOverlay() : const SizedBox.shrink(),
//         ],
//       ),
//       bottomNavigationBar: MyBottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           if (index == 2) {
//             _toggleOverlay();
//           } else if (_isOverlayVisible) {
//             _toggleOverlay();
//           } else {
//             setState(() {
//               _currentIndex = index;
//             });
//           }
//         },
//         toggleOverlay: _toggleOverlay, // Pass toggleOverlay function
//       ),
//     );
//   }
// }
// END //
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

// Widget _buildBottomNavigationBar() {
//   return BottomNavigationBar(
//     type: BottomNavigationBarType.fixed,
//     currentIndex: _currentIndex,
//     unselectedItemColor: MyColors.colorPalette['secondary'],
//     selectedItemColor: MyColors.colorPalette['primary'],
//     onTap: (index) {
//       if (index == 2) {
//         _toggleOverlay();
//       } else if (_isOverlayVisible) {
//         _toggleOverlay();
//       } else {
//         setState(() {
//           _currentIndex = index;
//         });
//       }
//     },
//     items: [
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.home_outlined, size: 24),
//         activeIcon: Icon(Icons.home_filled, size: 24),
//         label: 'Home',
//       ),
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.calendar_today_outlined, size: 24),
//         activeIcon: Icon(Icons.calendar_today, size: 24),
//         label: 'Calendar',
//       ),
//       BottomNavigationBarItem(
//         icon: Container(
//           decoration: BoxDecoration(
//             border: Border.all(
//               width: 2,
//               color: MyColors.colorPalette['secondary'] ?? Colors.blue,
//             ),
//             shape: BoxShape.circle,
//           ),
//           width: 40,
//           height: 40,
//           child: FloatingActionButton(
//             onPressed: _toggleOverlay,
//             backgroundColor: _isOverlayVisible
//                 ? MyColors.colorPalette['primary']
//                 : MyColors.colorPalette['on-primary'],
//             child: Icon(
//               Icons.add,
//               color: _isOverlayVisible
//                   ? Colors.white
//                   : MyColors.colorPalette['secondary'],
//               size: 35,
//             ),
//           ),
//         ),
//         label: '',
//       ),
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.search_outlined, size: 24),
//         activeIcon: Icon(Icons.search_sharp, size: 24),
//         label: 'Search',
//       ),
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.person_outlined, size: 24),
//         activeIcon: Icon(Icons.person, size: 24),
//         label: 'Profile',
//       ),
//     ],
//   );
// }

// ########################################################## //
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/clinic_doctor_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'dart:developer' as devtools show log;
// import 'package:provider/provider.dart';

// class OverlayView extends StatefulWidget {
//   const OverlayView({super.key});

//   @override
//   State<OverlayView> createState() => _OverlayViewState();
// }

// class _OverlayViewState extends State<OverlayView> {
//   int _currentIndex = 0;
//   bool _isOverlayVisible = false;

//   String _collectedDoctorId = '';
//   String _collectedDoctorName = '';
//   String _collectedClinicId = '';
//   PatientService _collectedPatientService = PatientService('', '');
//   List<String> _collectedClinicNames = [];
//   String _collectedSelectedClinicName = '';

//   late PatientService _patientService;
//   String doctorName = '';
//   String loggedInDoctorId = '';
//   List<String> clinicNames = [];
//   String selectedClinicName = '';
//   String selectedClinicId = '';
//   bool _isLoading = false;
//   bool _isLoadingData = true;
//   bool isFetchingData = true;

//   final Map<int, Widget> _screens = {};

//   final clinicSelection = ClinicSelection.instance;

//   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//   Future<Map<String, dynamic>> fetchData() async {
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       String userId = user.uid;
//       Map<String, dynamic>? doctorData =
//           await DoctorService().fetchDoctorDataForUser(userId) ?? {};

//       setState(() {
//         if (doctorData.isNotEmpty) {
//           doctorName = doctorData['doctorName']; //?? '';
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
//               clinicSelection.updateParameters(selectedClinicName, clinicNames);

//               _collectedDoctorId = loggedInDoctorId;
//               _collectedDoctorName = doctorName;
//               _collectedClinicId = selectedClinicId;
//               _collectedPatientService = _patientService;
//               _collectedClinicNames = clinicNames;
//               _collectedSelectedClinicName = selectedClinicName;

//               devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//               devtools.log('This is coming from inside fetchData !');
//               devtools.log(
//                   '_collectedDoctorId is populated with $_collectedDoctorId');
//               devtools.log(
//                   '_collectedDoctorName is populated with $_collectedDoctorName');
//               devtools.log(
//                   '_collectedClinicId is populated with $_collectedClinicId');
//               devtools.log(
//                   '_collectedPatientService is populated with $_collectedPatientService');
//               devtools.log(
//                   '_collectedClinicNames is populated with $_collectedClinicNames');
//               devtools.log(
//                   '_collectedSelectedClinicName is populated with $_collectedSelectedClinicName');
//               devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
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
//   void initState() {
//     super.initState();
//     fetchData().then((doctorData) {
//       devtools.log('[log]- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//       devtools.log('[log]- This is coming from inside OverlayView - initState');
//       devtools.log('[log]-  ${DateTime.now()} ');
//       devtools.log(
//           '[log] -  Hi from inside initState ! doctotData is : $doctorData ');
//       devtools.log('[log]- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

//       setState(() {
//         _isLoadingData =
//             false; // Set loading indicator to false once data is fetched

//         doctorName = doctorData['doctorName'];
//         loggedInDoctorId = doctorData['userId'];

//         List<dynamic> clinicsMapped = doctorData['clinicsMapped'];
//         selectedClinicId = clinicsMapped[0]['clinicId'];
//         _collectedDoctorId = loggedInDoctorId;
//         _collectedDoctorName = doctorName;
//         _collectedClinicId = selectedClinicId;
//         initializePatientService();
//         _collectedPatientService = _patientService;

//         devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//         devtools.log('This is coming from inside initState !');
//         devtools
//             .log('_collectedDoctorId is populated with $_collectedDoctorId');
//         devtools.log(
//             '_collectedDoctorName is populated with $_collectedDoctorName');
//         devtools
//             .log('_collectedClinicId is populated with $_collectedClinicId');
//         devtools.log(
//             '_collectedPatientService is populated with $_collectedPatientService');

//         devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

//         _buildScreens(doctorData);
//       });
//     });
//   }

//   void initializePatientService() {
//     _patientService = PatientService(selectedClinicId, loggedInDoctorId);
//   }

//   void _toggleOverlay() {
//     setState(() {
//       _isOverlayVisible = !_isOverlayVisible;
//     });
//   }

//   Widget _buildOverlay() {
//     return Stack(
//       children: [
//         GestureDetector(
//           onTap: () {
//             _toggleOverlay();
//           },
//           child: Container(
//             color: Colors.transparent,
//           ),
//         ),
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             decoration: BoxDecoration(
//               color: MyColors.colorPalette['surface-bright'],
//             ),
//             height: MediaQuery.of(context).size.height / 2,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                       IconButton(
//                         icon: Icon(
//                           Icons.close,
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                         onPressed: () {
//                           _toggleOverlay();
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.person_outline),
//                     ),
//                     title: Text(
//                       'Create New Patient',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AddNewPatient(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: SvgPicture.asset(
//                         'assets/icons/medicines.svg',
//                         height: 24,
//                       ),
//                     ),
//                     title: Text(
//                       'Start New Treatment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SearchAndAddPatient(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                             onPatientSelectedForAppointment: null,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.access_time),
//                     ),
//                     title: Text(
//                       'Book Appointment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => BookAppointment(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   //final Map<int, Widget?> _screens = {};

//   void _buildScreens(Map<String, dynamic> doctorData) {
//     //devtools.log('[log]-  ${DateTime.now()} ');
//     _buildScreen(0, doctorData); // LandingScreen
//     _buildScreen(1, doctorData); // CalenderView
//     _buildScreen(3, doctorData); // SearchAndDisplayAllPatients
//     _buildScreen(4, doctorData); // MyProfile
//   }

//   Widget _buildScreen(int index, Map<String, dynamic> doctorData) {
//     Widget screen;
//     //Widget? screen;

//     switch (index) {
//       case 0:
//         // devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//         // devtools.log('This is BEFORE case 0 gets executed');
//         // devtools
//         //     .log('_collectedDoctorId is populated with $_collectedDoctorId');
//         // devtools.log(
//         //     '_collectedDoctorName is populated with $_collectedDoctorName');
//         // devtools
//         //     .log('_collectedClinicId is populated with $_collectedClinicId');
//         // devtools.log(
//         //     '_collectedPatientService is populated with $_collectedPatientService');

//         // devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//         screen = LandingScreen(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         // devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//         // devtools.log('This is AFTER case 0 gets executed');
//         // devtools
//         //     .log('_collectedDoctorId is populated with $_collectedDoctorId');
//         // devtools.log(
//         //     '_collectedDoctorName is populated with $_collectedDoctorName');
//         // devtools
//         //     .log('_collectedClinicId is populated with $_collectedClinicId');
//         // devtools.log(
//         //     '_collectedPatientService is populated with $_collectedPatientService');

//         // devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//         break;

//       case 1:
//         screen = CalenderView(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         devtools.log('case 1 triggered !');
//         break;

//       case 3:
//         screen = SearchAndDisplayAllPatients(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;

//       case 4:
//         screen = MyProfile(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;

//       default:
//         screen = Container();
//     }
//     // Ensure that 'screen' is assigned a non-nullable value before returning
//     //screen ??= Container();

//     _screens[index] = screen;
//     return screen;
//   }

//   Widget _buildLoadingIndicator() {
//     return const Center(
//       child: CircularProgressIndicator(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider.value(value: ClinicSelection.instance),
//         // Other providers...
//       ],
//       child: Scaffold(
//         body: Stack(
//           // children: [
//           //   _buildScreen(_currentIndex, {}),
//           //   _isOverlayVisible ? _buildOverlay() : const SizedBox.shrink(),
//           // ],
//           children: [
//             _isLoadingData
//                 ? _buildLoadingIndicator()
//                 : _buildScreen(_currentIndex, {}) ?? Container(),
//             _isOverlayVisible ? _buildOverlay() : const SizedBox.shrink(),
//           ],

//           // children: [
//           //   _isLoadingData
//           //       ? _buildLoadingIndicator() // Display loading indicator while data is being fetched
//           //       : _buildScreen(_currentIndex, {}),
//           //   _isOverlayVisible ? _buildOverlay() : const SizedBox.shrink(),
//           // ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: _currentIndex,
//           unselectedItemColor: MyColors.colorPalette['secondary'],
//           selectedItemColor: MyColors.colorPalette['primary'],
//           onTap: (index) {
//             if (index == 2) {
//               _toggleOverlay();
//             } else if (_isOverlayVisible) {
//               _toggleOverlay();
//             } else {
//               setState(() {
//                 _currentIndex = index;
//               });
//             }
//           },
//           items: [
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined, size: 24),
//               activeIcon: Icon(Icons.home_filled, size: 24),
//               label: 'Home',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_today_outlined, size: 24),
//               activeIcon: Icon(Icons.calendar_today, size: 24),
//               label: 'Calendar',
//             ),
//             BottomNavigationBarItem(
//               icon: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     width: 2,
//                     color: MyColors.colorPalette['secondary'] ?? Colors.blue,
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 width: 40,
//                 height: 40,
//                 child: FloatingActionButton(
//                   onPressed: _toggleOverlay,
//                   backgroundColor: _isOverlayVisible
//                       ? MyColors.colorPalette['primary']
//                       : MyColors.colorPalette['on-primary'],
//                   child: Icon(
//                     Icons.add,
//                     color: _isOverlayVisible
//                         ? Colors.white
//                         : MyColors.colorPalette['secondary'],
//                     size: 35,
//                   ),
//                 ),
//               ),
//               label: '',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.search_outlined, size: 24),
//               activeIcon: Icon(Icons.search_sharp, size: 24),
//               label: 'Search',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.person_outlined, size: 24),
//               activeIcon: Icon(Icons.person, size: 24),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//#####################################################################//
// FOLLOWING FUNCTIONS i.e. fetchData, populateParametersFromDoctorData and initState//
// TO BE DEBUGED FURTHER BEFORE REPLACE THE EXISTING fetchData AND initState //

// Future<Map<String, dynamic>> fetchData() async {
//   User? user = FirebaseAuth.instance.currentUser;

//   if (user != null) {
//     String userId = user.uid;
//     Map<String, dynamic>? doctorData =
//         await DoctorService().fetchDoctorDataForUser(userId) ?? {};

//     // Additional logic if needed

//     return doctorData;
//   } else {
//     _isLoading = false;
//     return {};
//   }
// }

// //void populateParametersFromDoctorData(Map<String, dynamic> doctorData) {
// Future<void> populateParametersFromDoctorData(
//     Map<String, dynamic> doctorData) async {
//   if (doctorData.isNotEmpty) {
//     doctorName = doctorData['doctorName']; //?? '';
//     loggedInDoctorId = doctorData['userId'];

//     List<dynamic> clinicsMapped = doctorData['clinicsMapped'];
//     clinicNames = clinicsMapped
//         .map((clinic) => clinic['clinicName'] as String)
//         .toList();

//     if (clinicNames.isNotEmpty) {
//       selectedClinicName = clinicNames[0];
//       ClinicService clinicService = ClinicService();
//       clinicService.getClinicId(selectedClinicName).then((clinicId) {
//         selectedClinicId = clinicId;
//         initializePatientService();
//         _isLoading = false;
//         clinicSelection.updateParameters(selectedClinicName, clinicNames);

//         _collectedDoctorId = loggedInDoctorId;
//         _collectedDoctorName = doctorName;
//         _collectedClinicId = selectedClinicId;
//         _collectedPatientService = _patientService;
//         _collectedClinicNames = clinicNames;
//         _collectedSelectedClinicName = selectedClinicName;

//         devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//         devtools.log(
//             'This is coming from inside populateParametersFromDoctorData !');
//         devtools.log('[log]-  ${DateTime.now()} ');
//         devtools
//             .log('_collectedDoctorId is populated with $_collectedDoctorId');
//         devtools.log(
//             '_collectedDoctorName is populated with $_collectedDoctorName');
//         devtools
//             .log('_collectedClinicId is populated with $_collectedClinicId');
//         devtools.log(
//             '_collectedPatientService is populated with $_collectedPatientService');
//         devtools.log(
//             '_collectedClinicNames is populated with $_collectedClinicNames');
//         devtools.log(
//             '_collectedSelectedClinicName is populated with $_collectedSelectedClinicName');
//         devtools.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//       }).catchError((error) {
//         devtools.log(error.toString());
//         _isLoading = false;
//       });
//     } else {
//       _isLoading = false;
//     }
//   } else {
//     _isLoading = false;
//   }
//   // Now call _buildScreens
//   _buildScreens(doctorData);
// }

// @override
// void initState() {
//   super.initState();
//   fetchData().then((doctorData) async {
//     devtools.log('[log]- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//     devtools.log('[log]- This is coming from inside OverlayView - initState');
//     devtools.log('[log]-  ${DateTime.now()} ');
//     devtools.log(
//         '[log] -  Hi from inside initState ! doctotData is : $doctorData ');
//     devtools.log('[log]- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

//     setState(() {
//       _isLoadingData =
//           false; // Set loading indicator to false once data is fetched
//     });

//     await populateParametersFromDoctorData(doctorData);
//   });
// }

// ########################################################################### //

// END OF STABLE CODE //

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/clinic_doctor_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';

// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'dart:developer' as devtools show log;

// import 'package:provider/provider.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: OverlayView(),
//     );
//   }
// }

// class OverlayView extends StatefulWidget {
//   const OverlayView({super.key});

//   @override
//   State<OverlayView> createState() => _OverlayViewState();
// }

// class _OverlayViewState extends State<OverlayView> {
//   //GlobalKey<LandingScreenState> _landingScreenStateKey = GlobalKey();
//   int _currentIndex = 0;
//   bool _isOverlayVisible = false;

//   // Parameters to be collected from LandingScreen
//   String _collectedDoctorId = '';
//   String _collectedDoctorName = '';
//   String _collectedClinicId = '';
//   PatientService _collectedPatientService = PatientService('', '');
//   List<String> _collectedClinicNames = [];
//   String _collectedSelectedClinicName = '';
//   final Map<int, Widget> _screens = {};
//   final clinicSelection = ClinicSelection.instance;

//   // !!!!!!!!!!!!!!!!!!!!!!!!!! //
//   late PatientService _patientService;
//   String doctorName = '';
//   String loggedInDoctorId = '';
//   List<String> clinicNames = [];
//   String selectedClinicName = '';
//   String selectedClinicId = '';
//   //!!!!!!!!!!!!!!!!!!!!!!!!!!! //
//   bool _isLoading = false;
//   String additionalContent = '';
//   String currentDate = DateFormat('MMM d').format(DateTime.now());
//   String currentDay = DateFormat('E').format(DateTime.now());
//   // !!!!!!!!!!!!!!!!!!!!!!!!!!!! //

//   @override
//   void initState() {
//     super.initState();
//     devtools.log('This is coming from inside OverlayViewState - initState');
//     //fetchDoctorDataForOverlay();
//     _fetchAndInitializeData();
//   }

//   Future<void> _fetchAndInitializeData() async {
//     await fetchDoctorDataForOverlay();
//     setState(() {
//       // Now, you can safely use the fetched data to build LandingScreen
//     });
//   }

//   Future<void> fetchDoctorDataForOverlay() async {
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       String userId = user.uid;

//       Map<String, dynamic>? doctorData =
//           await DoctorService().fetchDoctorDataForUser(userId);

//       if (doctorData?.isNotEmpty == true) {
//         setState(() {
//           doctorName = doctorData?['doctorName'] ?? '';
//           loggedInDoctorId = doctorData?['userId'];

//           List<dynamic> clinicsMapped = doctorData?['clinicsMapped'];
//           clinicNames = clinicsMapped
//               .map((clinic) => clinic['clinicName'] as String)
//               .toList();

//           if (clinicNames.isNotEmpty) {
//             selectedClinicName = clinicNames[0];
//             ClinicService clinicService = ClinicService();
//             clinicService.getClinicId(selectedClinicName).then((clinicId) {
//               setState(() {
//                 selectedClinicId = clinicId;
//                 initializePatientService();
//                 _isLoading = false;
//                 // Update clinicSelection directly
//                 clinicSelection.updateParameters(
//                     selectedClinicName, clinicNames);

//                 _collectedDoctorId = loggedInDoctorId;
//                 _collectedDoctorName = doctorName;
//                 _collectedClinicId = selectedClinicId;
//                 _collectedPatientService = _patientService;
//                 _collectedClinicNames = clinicNames;
//                 _collectedSelectedClinicName = selectedClinicName;
//                 devtools.log(
//                     '_collectedDoctorId is populated with $_collectedDoctorId');
//                 devtools.log(
//                     '_collectedDoctorName is populated with $_collectedDoctorName');
//                 devtools.log(
//                     '_collectedClinicId is populated with $_collectedClinicId');
//                 devtools.log(
//                     '_collectedPatientService is populated with $_collectedPatientService');
//                 devtools.log(
//                     '_collectedClinicNames is populated with $_collectedClinicNames');
//                 devtools.log(
//                     '_collectedSelectedClinicName is populated with $_collectedSelectedClinicName');
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
//     } else {
//       _isLoading = false;
//     }
//   }

//   void initializePatientService() {
//     _patientService = PatientService(selectedClinicId, loggedInDoctorId);
//   }

//   // void onParametersUpdated(
//   //   String doctorId,
//   //   String doctorName,
//   //   String clinicId,
//   //   PatientService patientService,
//   //   List<String> clinicNames,
//   //   String selectedClinicName,
//   // ) {
//   //   devtools.log(
//   //     'This is coming from inside onParametersUpdated function in Overlayview'
//   //     'Updated Parameters received inside OverlayView: '
//   //     'DoctorID=$doctorId, DoctorName=$doctorName, ClinicID=$clinicId, '
//   //     'PatientService=$patientService, ClinicNames=$clinicNames, '
//   //     'SelectedClinicName=$selectedClinicName',
//   //   );
//   //   setState(() {
//   //     _collectedDoctorId = doctorId;
//   //     _collectedDoctorName = doctorName;
//   //     _collectedClinicId = clinicId;
//   //     _collectedPatientService = patientService;

//   //     _collectedClinicNames = clinicNames;
//   //     _collectedSelectedClinicName = selectedClinicName;
//   //     // Update app bar parameters using ChangeNotifier
//   //     // appBarParameters.updateParameters(selectedClinicName, clinicNames);
//   //     // clinicSelection.updateSelectedClinic(selectedClinicName);
//   //     // clinicSelection.updateClinicNames(clinicNames);
//   //     clinicSelection.updateParameters(selectedClinicName, clinicNames);
//   //   });
//   // }

//   void _toggleOverlay() {
//     setState(() {
//       _isOverlayVisible = !_isOverlayVisible;
//     });
//   }

//   Widget _buildOverlay() {
//     return Stack(
//       children: [
//         // Background to capture taps outside the overlay
//         GestureDetector(
//           onTap: () {
//             _toggleOverlay(); // Close the overlay when tapped outside the menu
//           },
//           child: Container(
//             color: Colors.transparent,
//           ),
//         ),
//         // Overlay menu
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             decoration: BoxDecoration(
//               color: MyColors.colorPalette['surface-bright'],
//             ),
//             height: MediaQuery.of(context).size.height / 2,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                       IconButton(
//                         icon: Icon(
//                           Icons.close,
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                         onPressed: () {
//                           _toggleOverlay(); // Close the overlay when 'X' is pressed
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.person_outline),
//                     ),
//                     title: Text(
//                       'Create New Patient',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AddNewPatient(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: SvgPicture.asset(
//                         'assets/icons/medicines.svg',
//                         height: 24,
//                       ),
//                     ),
//                     title: Text(
//                       'Start New Treatment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SearchAndAddPatient(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                             onPatientSelectedForAppointment: null,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.access_time),
//                     ),
//                     title: Text(
//                       'Book Appointment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => BookAppointment(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildScreen(int index) {
//     if (_screens.containsKey(index)) {
//       return _screens[index]!;
//     }

//     Widget screen;

//     switch (index) {
//       case 0:
//         screen = LandingScreen(
//           //key: const ValueKey<String>('landing_screen_key'),
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         // Add print statements or logs to check the values
//         devtools.log('This is coming from inside case 0');
//         devtools.log('Doctor ID: $_collectedDoctorId');
//         devtools.log('Doctor Name: $_collectedDoctorName');
//         devtools.log('Clinic ID: $_collectedClinicId');
//         devtools.log('Patient Service: $_collectedPatientService');

//         break;

//       case 1:
//         // Create CalenderView instance
//         screen = CalenderView(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         // Add print statements or logs to check the values
//         devtools.log('This is coming from inside case 1');
//         devtools.log('Doctor ID: $_collectedDoctorId');
//         devtools.log('Doctor Name: $_collectedDoctorName');
//         devtools.log('Clinic ID: $_collectedClinicId');
//         devtools.log('Patient Service: $_collectedPatientService');

//         break;

//       case 2:
//         // Toggle overlay when "Add" icon is tapped
//         _toggleOverlay();
//         // Return a placeholder container to satisfy the return type
//         screen = Container();
//         break;

//       case 3:
//         // Create SearchAndDisplayAllPatients instance
//         screen = SearchAndDisplayAllPatients(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         // Add print statements or logs to check the values
//         devtools.log('This is coming from inside case 3');
//         devtools.log('Doctor ID: $_collectedDoctorId');
//         devtools.log('Doctor Name: $_collectedDoctorName');
//         devtools.log('Clinic ID: $_collectedClinicId');
//         devtools.log('Patient Service: $_collectedPatientService');

//         break;

//       case 4:
//         // Create MyProfile instance
//         screen = MyProfile(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         // Add print statements or logs to check the values
//         devtools.log('This is coming from inside case 4');
//         devtools.log('Doctor ID: $_collectedDoctorId');
//         devtools.log('Doctor Name: $_collectedDoctorName');
//         devtools.log('Clinic ID: $_collectedClinicId');
//         devtools.log('Patient Service: $_collectedPatientService');

//         break;

//       default:
//         screen = Container(); // Placeholder, you may want to handle this case
//     }

//     _screens[index] = screen;
//     return screen;
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to the build widget of OverlayView!');
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider.value(value: ClinicSelection.instance),

//         // Other providers...
//       ],
//       child: Scaffold(
//         body: Stack(
//           children: [
//             _buildScreen(_currentIndex),
//             _isOverlayVisible ? _buildOverlay() : const SizedBox.shrink(),
//           ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: _currentIndex,
//           unselectedItemColor: MyColors.colorPalette['secondary'],
//           selectedItemColor: MyColors.colorPalette['primary'],
//           onTap: (index) {
//             if (index == 2) {
//               _toggleOverlay(); // Toggle overlay when the 5th item (Add icon) is tapped
//             } else if (_isOverlayVisible) {
//               _toggleOverlay(); // If the overlay is visible, close it when tapping other icons
//             } else {
//               setState(() {
//                 _currentIndex = index; // Switch to a different screen
//               });
//             }
//           },
//           items: [
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined, size: 24),
//               activeIcon: Icon(Icons.home_filled, size: 24),
//               label: 'Home',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_today_outlined, size: 24),
//               activeIcon: Icon(Icons.calendar_today, size: 24),
//               label: 'Calendar',
//             ),
//             //####################################//
//             BottomNavigationBarItem(
//               icon: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     width: 2,
//                     color: MyColors.colorPalette['secondary'] ?? Colors.blue,
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 width: 40,
//                 height: 40,
//                 child: FloatingActionButton(
//                   onPressed: _toggleOverlay,
//                   backgroundColor: _isOverlayVisible
//                       ? MyColors.colorPalette['primary']
//                       : MyColors.colorPalette['on-primary'],
//                   child: Icon(
//                     Icons.add,
//                     color: _isOverlayVisible
//                         ? Colors.white
//                         : MyColors.colorPalette['secondary'],
//                     size: 35,
//                   ),
//                 ),
//               ),
//               label: '',
//             ),

//             const BottomNavigationBarItem(
//               icon: Icon(Icons.search_outlined, size: 24),
//               activeIcon: Icon(Icons.search_sharp, size: 24),
//               label: 'Search',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.person_outlined, size: 24),
//               activeIcon: Icon(Icons.person, size: 24),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// BEFORE fetchDoctorDataForOverlay IMPLEMENTATION //
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';

// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'dart:developer' as devtools show log;

// import 'package:provider/provider.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: OverlayView(),
//     );
//   }
// }

// class OverlayView extends StatefulWidget {
//   const OverlayView({super.key});

//   @override
//   _OverlayViewState createState() => _OverlayViewState();
// }

// class _OverlayViewState extends State<OverlayView> {
//   //GlobalKey<LandingScreenState> _landingScreenStateKey = GlobalKey();
//   int _currentIndex = 0;
//   bool _isOverlayVisible = false;

//   // Parameters to be collected from LandingScreen
//   String _collectedDoctorId = '';
//   String _collectedDoctorName = '';
//   String _collectedClinicId = '';
//   PatientService _collectedPatientService = PatientService('', '');
//   List<String> _collectedClinicNames = [];
//   String _collectedSelectedClinicName = '';

//   final Map<int, Widget> _screens = {};
//   // final appBarParameters = AppBarParameters();
//   final clinicSelection = ClinicSelection.instance;

//   void onParametersUpdated(
//     String doctorId,
//     String doctorName,
//     String clinicId,
//     PatientService patientService,
//     List<String> clinicNames,
//     String selectedClinicName,
//   ) {
//     devtools.log(
//       'This is coming from inside onParametersUpdated function in Overlayview'
//       'Updated Parameters received inside OverlayView: '
//       'DoctorID=$doctorId, DoctorName=$doctorName, ClinicID=$clinicId, '
//       'PatientService=$patientService, ClinicNames=$clinicNames, '
//       'SelectedClinicName=$selectedClinicName',
//     );
//     setState(() {
//       _collectedDoctorId = doctorId;
//       _collectedDoctorName = doctorName;
//       _collectedClinicId = clinicId;
//       _collectedPatientService = patientService;

//       _collectedClinicNames = clinicNames;
//       _collectedSelectedClinicName = selectedClinicName;
//       // Update app bar parameters using ChangeNotifier
//       // appBarParameters.updateParameters(selectedClinicName, clinicNames);
//       // clinicSelection.updateSelectedClinic(selectedClinicName);
//       // clinicSelection.updateClinicNames(clinicNames);
//       clinicSelection.updateParameters(selectedClinicName, clinicNames);
//     });
//   }

//   void _toggleOverlay() {
//     setState(() {
//       _isOverlayVisible = !_isOverlayVisible;
//     });
//   }

//   Widget _buildOverlay() {
//     return Stack(
//       children: [
//         // Background to capture taps outside the overlay
//         GestureDetector(
//           onTap: () {
//             _toggleOverlay(); // Close the overlay when tapped outside the menu
//           },
//           child: Container(
//             color: Colors.transparent,
//           ),
//         ),
//         // Overlay menu
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             decoration: BoxDecoration(
//               color: MyColors.colorPalette['surface-bright'],
//             ),
//             height: MediaQuery.of(context).size.height / 2,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                       IconButton(
//                         icon: Icon(
//                           Icons.close,
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                         onPressed: () {
//                           _toggleOverlay(); // Close the overlay when 'X' is pressed
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.person_outline),
//                     ),
//                     title: Text(
//                       'Create New Patient',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AddNewPatient(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: SvgPicture.asset(
//                         'assets/icons/medicines.svg',
//                         height: 24,
//                       ),
//                     ),
//                     title: Text(
//                       'Start New Treatment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SearchAndAddPatient(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                             onPatientSelectedForAppointment: null,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.access_time),
//                     ),
//                     title: Text(
//                       'Book Appointment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => BookAppointment(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildScreen(int index) {
//     if (_screens.containsKey(index)) {
//       return _screens[index]!;
//     }

//     Widget screen;

//     switch (index) {
//       case 0:
//         // Create LandingScreen instance
//         screen = LandingScreen(
//           key: const ValueKey<String>('landing_screen_key'),
//           onParametersUpdated: onParametersUpdated,
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//           clinicNames: _collectedClinicNames,
//           selectedClinicName: _collectedSelectedClinicName,
//         );
//         break;

//       case 1:
//         // Create CalenderView instance
//         screen = CalenderView(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;

//       case 2:
//         // Toggle overlay when "Add" icon is tapped
//         _toggleOverlay();
//         // Return a placeholder container to satisfy the return type
//         screen = Container();
//         break;

//       case 3:
//         // Create SearchAndDisplayAllPatients instance
//         screen = SearchAndDisplayAllPatients(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;

//       case 4:
//         // Create MyProfile instance
//         screen = MyProfile(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;

//       default:
//         screen = Container(); // Placeholder, you may want to handle this case
//     }

//     _screens[index] = screen;
//     return screen;
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to the build widget of OverlayView!');
//     return MultiProvider(
//       providers: [
//         // Use the existing instance of AppBarParameters
//         //ChangeNotifierProvider.value(value: appBarParameters),
//         ChangeNotifierProvider.value(value: ClinicSelection.instance),

//         // Other providers...
//       ],
//       child: Scaffold(
//         body: Stack(
//           children: [
//             _buildScreen(_currentIndex),
//             _isOverlayVisible ? _buildOverlay() : const SizedBox.shrink(),
//           ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: _currentIndex,
//           unselectedItemColor: MyColors.colorPalette['secondary'],
//           selectedItemColor: MyColors.colorPalette['primary'],
//           onTap: (index) {
//             if (index == 2) {
//               _toggleOverlay(); // Toggle overlay when the 5th item (Add icon) is tapped
//             } else if (_isOverlayVisible) {
//               _toggleOverlay(); // If the overlay is visible, close it when tapping other icons
//             } else {
//               setState(() {
//                 _currentIndex = index; // Switch to a different screen
//               });
//             }
//           },
//           items: [
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined, size: 24),
//               activeIcon: Icon(Icons.home_filled, size: 24),
//               label: 'Home',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_today_outlined, size: 24),
//               activeIcon: Icon(Icons.calendar_today, size: 24),
//               label: 'Calendar',
//             ),
//             //####################################//
//             BottomNavigationBarItem(
//               icon: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     width: 2,
//                     color: MyColors.colorPalette['secondary'] ?? Colors.blue,
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 width: 40,
//                 height: 40,
//                 child: FloatingActionButton(
//                   onPressed: _toggleOverlay,
//                   backgroundColor: _isOverlayVisible
//                       ? MyColors.colorPalette['primary']
//                       : MyColors.colorPalette['on-primary'],
//                   child: Icon(
//                     Icons.add,
//                     color: _isOverlayVisible
//                         ? Colors.white
//                         : MyColors.colorPalette['secondary'],
//                     size: 35,
//                   ),
//                 ),
//               ),
//               label: '',
//             ),

//             const BottomNavigationBarItem(
//               icon: Icon(Icons.search_outlined, size: 24),
//               activeIcon: Icon(Icons.search_sharp, size: 24),
//               label: 'Search',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.person_outlined, size: 24),
//               activeIcon: Icon(Icons.person, size: 24),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//##################################################################################//

// START OF STABLE CODE WITH ADD ICON ON THE BOTTOM BAR IN PLACE OF floatingActionButton//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/app_bar_parameters.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'dart:developer' as devtools show log;

// import 'package:provider/provider.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: OverlayView(),
//     );
//   }
// }

// class OverlayView extends StatefulWidget {
//   const OverlayView({super.key});

//   @override
//   _OverlayViewState createState() => _OverlayViewState();
// }

// class _OverlayViewState extends State<OverlayView> {
//   //GlobalKey<LandingScreenState> _landingScreenStateKey = GlobalKey();
//   int _currentIndex = 0;
//   bool _isOverlayVisible = false;

//   // Parameters to be collected from LandingScreen
//   String _collectedDoctorId = '';
//   String _collectedDoctorName = '';
//   String _collectedClinicId = '';
//   PatientService _collectedPatientService = PatientService('', '');
//   List<String> _collectedClinicNames = [];
//   String _collectedSelectedClinicName = '';

//   final Map<int, Widget> _screens = {};
//   final appBarParameters = AppBarParameters();

//   void onParametersUpdated(
//     String doctorId,
//     String doctorName,
//     String clinicId,
//     PatientService patientService,
//     List<String> clinicNames,
//     String selectedClinicName,
//   ) {
//     devtools.log(
//       'This is coming from inside onParametersUpdated function in Overlayview'
//       'Updated Parameters received inside OverlayView: '
//       'DoctorID=$doctorId, DoctorName=$doctorName, ClinicID=$clinicId, '
//       'PatientService=$patientService, ClinicNames=$clinicNames, '
//       'SelectedClinicName=$selectedClinicName',
//     );
//     setState(() {
//       _collectedDoctorId = doctorId;
//       _collectedDoctorName = doctorName;
//       _collectedClinicId = clinicId;
//       _collectedPatientService = patientService;

//       _collectedClinicNames = clinicNames;
//       _collectedSelectedClinicName = selectedClinicName;
//       // Update app bar parameters using ChangeNotifier
//       appBarParameters.updateParameters(selectedClinicName, clinicNames);
//     });
//   }

//   void _toggleOverlay() {
//     setState(() {
//       _isOverlayVisible = !_isOverlayVisible;
//     });
//   }

//   Widget _buildOverlay() {
//     return Stack(
//       children: [
//         // Background to capture taps outside the overlay
//         GestureDetector(
//           onTap: () {
//             _toggleOverlay(); // Close the overlay when tapped outside the menu
//           },
//           child: Container(
//             color: Colors.transparent,
//           ),
//         ),
//         // Overlay menu
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             decoration: BoxDecoration(
//               color: MyColors.colorPalette['surface-bright'],
//             ),
//             height: MediaQuery.of(context).size.height / 2,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                       IconButton(
//                         icon: Icon(
//                           Icons.close,
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                         onPressed: () {
//                           _toggleOverlay(); // Close the overlay when 'X' is pressed
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.person_outline),
//                     ),
//                     title: Text(
//                       'Create New Patient',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AddNewPatient(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: SvgPicture.asset(
//                         'assets/icons/medicines.svg',
//                         height: 24,
//                       ),
//                     ),
//                     title: Text(
//                       'Start New Treatment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SearchAndAddPatient(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                             onPatientSelectedForAppointment: null,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.access_time),
//                     ),
//                     title: Text(
//                       'Book Appointment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => BookAppointment(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildScreen(int index) {
//     if (_screens.containsKey(index)) {
//       return _screens[index]!;
//     }

//     Widget screen;

//     switch (index) {
//       case 0:
//         // Create LandingScreen instance
//         screen = LandingScreen(
//           key: const ValueKey<String>('landing_screen_key'),
//           onParametersUpdated: onParametersUpdated,
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//           clinicNames: _collectedClinicNames,
//           selectedClinicName: _collectedSelectedClinicName,
//         );
//         break;

//       case 1:
//         // Create CalenderView instance
//         screen = CalenderView(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;

//       case 2:
//         // Toggle overlay when "Add" icon is tapped
//         _toggleOverlay();
//         // Return a placeholder container to satisfy the return type
//         screen = Container();
//         break;

//       case 3:
//         // Create SearchAndDisplayAllPatients instance
//         screen = SearchAndDisplayAllPatients(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;

//       case 4:
//         // Create MyProfile instance
//         screen = MyProfile(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;

//       default:
//         screen = Container(); // Placeholder, you may want to handle this case
//     }

//     _screens[index] = screen;
//     return screen;
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to the build widget of OverlayView!');
//     return MultiProvider(
//       providers: [
//         // Use the existing instance of AppBarParameters
//         ChangeNotifierProvider.value(value: appBarParameters),

//         // Other providers...
//       ],
//       child: Scaffold(
//         body: Stack(
//           children: [
//             _buildScreen(_currentIndex),
//             _isOverlayVisible ? _buildOverlay() : const SizedBox.shrink(),
//           ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: _currentIndex,
//           unselectedItemColor: MyColors.colorPalette['secondary'],
//           selectedItemColor: MyColors.colorPalette['primary'],
//           onTap: (index) {
//             if (index == 2) {
//               _toggleOverlay(); // Toggle overlay when the 5th item (Add icon) is tapped
//             } else if (_isOverlayVisible) {
//               _toggleOverlay(); // If the overlay is visible, close it when tapping other icons
//             } else {
//               setState(() {
//                 _currentIndex = index; // Switch to a different screen
//               });
//             }
//           },
//           items: [
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined, size: 24),
//               activeIcon: Icon(Icons.home_filled, size: 24),
//               label: 'Home',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_today_outlined, size: 24),
//               activeIcon: Icon(Icons.calendar_today, size: 24),
//               label: 'Calendar',
//             ),
//             //####################################//
//             BottomNavigationBarItem(
//               icon: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     width: 2,
//                     color: MyColors.colorPalette['secondary'] ?? Colors.blue,
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 width: 40,
//                 height: 40,
//                 child: FloatingActionButton(
//                   onPressed: _toggleOverlay,
//                   backgroundColor: _isOverlayVisible
//                       ? MyColors.colorPalette['primary']
//                       : MyColors.colorPalette['on-primary'],
//                   child: Icon(
//                     Icons.add,
//                     color: _isOverlayVisible
//                         ? Colors.white
//                         : MyColors.colorPalette['secondary'],
//                     size: 35,
//                   ),
//                 ),
//               ),
//               label: '',
//             ),

//             const BottomNavigationBarItem(
//               icon: Icon(Icons.search_outlined, size: 24),
//               activeIcon: Icon(Icons.search_sharp, size: 24),
//               label: 'Search',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.person_outlined, size: 24),
//               activeIcon: Icon(Icons.person, size: 24),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// END OF STABLE CODE WITH ADD ICON ON BOTTOM BAR IN PLACE OF floatingActionButton//
//###################################################################################//
// floatingActionButton: Container(
//   decoration: BoxDecoration(
//     border: Border.all(
//       width: 2,
//       color: MyColors.colorPalette['secondary'] ?? Colors.blue,
//     ),
//     shape: BoxShape.circle,
//   ),
//   width: 40,
//   height: 40,
//   child: FloatingActionButton(
//     onPressed: _toggleOverlay,
//     backgroundColor: _isOverlayVisible
//         ? MyColors.colorPalette['primary']
//         : MyColors.colorPalette['on-primary'],
//     child: Icon(
//       Icons.add,
//       color: _isOverlayVisible
//           ? Colors.white
//           : MyColors.colorPalette['secondary'],
//       size: 35,
//     ),
//   ),
// ),
// floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

// Widget _buildScreen(int index) {
//   if (_screens.containsKey(index)) {
//     return _screens[index]!;
//   }

//   Widget screen;

//   switch (index) {

//     case 0:
//       // Create LandingScreen instance
//       screen = LandingScreen(
//         key: const ValueKey<String>('landing_screen_key'),
//         onParametersUpdated: onParametersUpdated,
//         doctorId: _collectedDoctorId,
//         doctorName: _collectedDoctorName,
//         clinicId: _collectedClinicId,
//         patientService: _collectedPatientService,
//         clinicNames: _collectedClinicNames,
//         selectedClinicName: _collectedSelectedClinicName,
//       );
//       break;

//     case 1:
//       // Create CalenderView instance
//       screen = CalenderView(
//         doctorId: _collectedDoctorId,
//         doctorName: _collectedDoctorName,
//         clinicId: _collectedClinicId,
//         patientService: _collectedPatientService,
//       );
//       break;
//     case 2:
//       // Create SearchAndDisplayAllPatients instance
//       screen = SearchAndDisplayAllPatients(
//         doctorId: _collectedDoctorId,
//         doctorName: _collectedDoctorName,
//         clinicId: _collectedClinicId,
//         patientService: _collectedPatientService,
//       );
//       break;
//     case 3:
//       // Create MyProfile instance
//       screen = MyProfile(
//         doctorId: _collectedDoctorId,
//         doctorName: _collectedDoctorName,
//         clinicId: _collectedClinicId,
//         patientService: _collectedPatientService,
//       );
//       break;
//     default:
//       screen = Container(); // Placeholder, you may want to handle this case
//   }

//   _screens[index] = screen;
//   return screen;
// }

// case 0:
//   // Create LandingScreen instance
//   screen = LandingScreen(
//     key: const ValueKey<String>('landing_screen_key'),
//     onParametersUpdated: (String doctorId,
//         String doctorName,
//         String clinicId,
//         PatientService patientService,
//         List<String> clinicNames,
//         String selectedClinicName) {
//       // devtools.log(
//       //   'Updated Parameters received inside OverlayView: DoctorID=$doctorId, DoctorName=$doctorName, ClinicID=$clinicId',
//       devtools.log(
//         'Updated Parameters received inside OverlayView: '
//         'DoctorID=$doctorId, DoctorName=$doctorName, ClinicID=$clinicId, '
//         'PatientService=$patientService, ClinicNames=$clinicNames, '
//         'SelectedClinicName=$selectedClinicName',
//       );
//       setState(() {
//         _collectedDoctorId = doctorId;
//         _collectedDoctorName = doctorName;
//         _collectedClinicId = clinicId;
//         _collectedPatientService = patientService;

//         _collectedClinicNames = clinicNames;
//         _collectedSelectedClinicName = selectedClinicName;
//       });
//     },
//     doctorId: _collectedDoctorId,
//     doctorName: _collectedDoctorName,
//     clinicId: _collectedClinicId,
//     patientService: _collectedPatientService,
//     clinicNames: _collectedClinicNames,
//     selectedClinicName: _collectedSelectedClinicName,

//   );
//   break;
// START OF OverlayView FUNCTION //
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'dart:developer' as devtools show log;

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: OverlayView(),
//     );
//   }
// }

// class OverlayView extends StatefulWidget {
//   const OverlayView({super.key});

//   @override
//   _OverlayViewState createState() => _OverlayViewState();
// }

// class _OverlayViewState extends State<OverlayView> {
//   //GlobalKey<LandingScreenState> _landingScreenStateKey = GlobalKey();
//   int _currentIndex = 0;
//   bool _isOverlayVisible = false;

//   // Parameters to be collected from LandingScreen
//   String _collectedDoctorId = '';
//   String _collectedDoctorName = '';
//   String _collectedClinicId = '';
//   PatientService _collectedPatientService = PatientService('', '');

//   final Map<int, Widget> _screens = {};

//   void onParametersUpdated(String doctorId, String doctorName, String clinicId,
//       PatientService patientService) {
//     devtools.log(
//         'Updated Parameters received from LandingScreen are : DoctorID=$doctorId, DoctorName=$doctorName, ClinicID=$clinicId');
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to the build widget of  OverlayView!');
//     return Scaffold(
//       body: Stack(
//         children: [
//           _buildScreen(_currentIndex),
//           _isOverlayVisible ? _buildOverlay() : const SizedBox.shrink(),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _currentIndex,
//         unselectedItemColor: MyColors.colorPalette['secondary'],
//         selectedItemColor: MyColors.colorPalette['primary'],
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined, size: 24),
//             activeIcon: Icon(Icons.home_filled, size: 24),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_today_outlined, size: 24),
//             activeIcon: Icon(Icons.calendar_today, size: 24),
//             label: 'Calendar',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search_outlined, size: 24),
//             activeIcon: Icon(Icons.search_sharp, size: 24),
//             label: 'Search',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outlined, size: 24),
//             activeIcon: Icon(Icons.person, size: 24),
//             label: 'Profile',
//           ),
//         ],
//       ),
//       floatingActionButton: Container(
//         decoration: BoxDecoration(
//             border: Border.all(
//               width: 2,
//               color: MyColors.colorPalette['secondary'] ?? Colors.blue,
//             ),
//             shape: BoxShape.circle),
//         width: 40,
//         height: 40,
//         child: FloatingActionButton(
//           onPressed: _toggleOverlay,
//           backgroundColor: _isOverlayVisible
//               ? MyColors.colorPalette['primary']
//               : MyColors.colorPalette['on-primary'],
//           child: Icon(
//             Icons.add,
//             color: _isOverlayVisible
//                 ? Colors.white
//                 : MyColors.colorPalette['secondary'],
//             size: 35,
//           ),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }

//   void _toggleOverlay() {
//     setState(() {
//       _isOverlayVisible = !_isOverlayVisible;
//     });
//   }

//   Widget _buildOverlay() {
//     return Stack(
//       children: [
//         // Background to capture taps outside the overlay
//         GestureDetector(
//           onTap: () {
//             _toggleOverlay(); // Close the overlay when tapped outside the menu
//           },
//           child: Container(
//             color: Colors.transparent,
//           ),
//         ),
//         // Overlay menu
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             decoration: BoxDecoration(
//               color: MyColors.colorPalette['surface-bright'],
//             ),
//             height: MediaQuery.of(context).size.height / 2,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                       IconButton(
//                         icon: Icon(
//                           Icons.close,
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                         onPressed: () {
//                           _toggleOverlay(); // Close the overlay when 'X' is pressed
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.person_outline),
//                     ),
//                     title: Text(
//                       'Create New Patient',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AddNewPatient(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: SvgPicture.asset(
//                         'assets/icons/medicines.svg',
//                         height: 24,
//                       ),
//                     ),
//                     title: Text(
//                       'Start New Treatment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SearchAndAddPatient(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                             onPatientSelectedForAppointment: null,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.access_time),
//                     ),
//                     title: Text(
//                       'Book Appointment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => BookAppointment(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildScreen(int index) {
//     if (_screens.containsKey(index)) {
//       return _screens[index]!;
//     }

//     Widget screen;

//     switch (index) {
//       case 0:
//         // Create LandingScreen instance
//         screen = LandingScreen(
//           //key: _landingScreenStateKey,
//           key: const ValueKey<String>('landing_screen_key'),
//           onParametersUpdated: (String doctorId, String doctorName,
//               String clinicId, PatientService patientService) {
//             devtools.log(
//               'Updated Parameters received inside OverlayView: DoctorID=$doctorId, DoctorName=$doctorName, ClinicID=$clinicId',
//             );
//             setState(() {
//               _collectedDoctorId = doctorId;
//               _collectedDoctorName = doctorName;
//               _collectedClinicId = clinicId;
//               _collectedPatientService = patientService;
//             });
//           },
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;

//       case 1:
//         // Create CalenderView instance
//         screen = CalenderView(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;
//       case 2:
//         // Create SearchAndDisplayAllPatients instance
//         screen = SearchAndDisplayAllPatients(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;
//       case 3:
//         // Create MyProfile instance
//         screen = MyProfile(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;
//       default:
//         screen = Container(); // Placeholder, you may want to handle this case
//     }

//     _screens[index] = screen;
//     return screen;
//   }
// }
// END OF OverlayView FUNCTION //

//###################################################################################//

// // START OF OverlayView FUNCTION //
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'dart:developer' as devtools show log;

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: OverlayView(),
//     );
//   }
// }

// class OverlayView extends StatefulWidget {
//   const OverlayView({super.key});

//   @override
//   _OverlayViewState createState() => _OverlayViewState();
// }

// class _OverlayViewState extends State<OverlayView> {
//   int _currentIndex = 0;
//   bool _isOverlayVisible = false;

//   // Parameters to be collected from LandingScreen
//   String _collectedDoctorId = '';
//   String _collectedDoctorName = '';
//   String _collectedClinicId = '';
//   PatientService _collectedPatientService = PatientService('', '');

//   Map<int, Widget> _screens = {};

//   void onParametersUpdated(String doctorId, String doctorName, String clinicId,
//       PatientService patientService) {
//     devtools.log(
//         'Updated Parameters received from LandingScreen are : DoctorID=$doctorId, DoctorName=$doctorName, ClinicID=$clinicId');
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to the build widget of  OverlayView!');
//     return Scaffold(
//       body: Stack(
//         children: [
//           _buildScreen(_currentIndex),
//           _isOverlayVisible ? _buildOverlay() : const SizedBox.shrink(),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _currentIndex,
//         unselectedItemColor: MyColors.colorPalette['secondary'],
//         selectedItemColor: MyColors.colorPalette['primary'],
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined, size: 24),
//             activeIcon: Icon(Icons.home_filled, size: 24),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_today_outlined, size: 24),
//             activeIcon: Icon(Icons.calendar_today, size: 24),
//             label: 'Calendar',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search_outlined, size: 24),
//             activeIcon: Icon(Icons.search_sharp, size: 24),
//             label: 'Search',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outlined, size: 24),
//             activeIcon: Icon(Icons.person, size: 24),
//             label: 'Profile',
//           ),
//         ],
//       ),
//       floatingActionButton: Container(
//         decoration: BoxDecoration(
//             border: Border.all(
//               width: 2,
//               color: MyColors.colorPalette['secondary'] ?? Colors.blue,
//             ),
//             shape: BoxShape.circle),
//         width: 40,
//         height: 40,
//         child: FloatingActionButton(
//           onPressed: _toggleOverlay,
//           backgroundColor: _isOverlayVisible
//               ? MyColors.colorPalette['primary']
//               : MyColors.colorPalette['on-primary'],
//           child: Icon(
//             Icons.add,
//             color: _isOverlayVisible
//                 ? Colors.white
//                 : MyColors.colorPalette['secondary'],
//             size: 35,
//           ),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }

//   void _toggleOverlay() {
//     setState(() {
//       _isOverlayVisible = !_isOverlayVisible;
//     });
//   }

//   Widget _buildOverlay() {
//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: MyColors.colorPalette['surface-bright'],
//             ),
//             height: MediaQuery.of(context).size.height / 2,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const SizedBox(height: 24),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'Create',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.person_outline),
//                     ),
//                     title: Text(
//                       'Create New Patient',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AddNewPatient(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: SvgPicture.asset(
//                         'assets/icons/medicines.svg',
//                         height: 24,
//                       ),
//                     ),
//                     title: Text(
//                       'Start New Treatment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SearchAndAddPatient(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                             onPatientSelectedForAppointment: null,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: MyColors.colorPalette['outline-variant'],
//                       child: const Icon(Icons.access_time),
//                     ),
//                     title: Text(
//                       'Book Appointment',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => BookAppointment(
//                             doctorId: _collectedDoctorId,
//                             doctorName: _collectedDoctorName,
//                             clinicId: _collectedClinicId,
//                             patientService: _collectedPatientService,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildScreen(int index) {
//     if (_screens.containsKey(index)) {
//       return _screens[index]!;
//     }

//     Widget screen;

//     switch (index) {
//       case 0:
//         // Create LandingScreen instance
//         screen = LandingScreen(
//           onParametersUpdated: (String doctorId, String doctorName,
//               String clinicId, PatientService patientService) {
//             devtools.log(
//               'Updated Parameters received inside OverlayView: DoctorID=$doctorId, DoctorName=$doctorName, ClinicID=$clinicId',
//             );
//             setState(() {
//               _collectedDoctorId = doctorId;
//               _collectedDoctorName = doctorName;
//               _collectedClinicId = clinicId;
//               _collectedPatientService = patientService;
//             });
//           },
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;
//       case 1:
//         // Create CalenderView instance
//         screen = CalenderView(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;
//       case 2:
//         // Create SearchAndDisplayAllPatients instance
//         screen = SearchAndDisplayAllPatients(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;
//       case 3:
//         // Create MyProfile instance
//         screen = MyProfile(
//           doctorId: _collectedDoctorId,
//           doctorName: _collectedDoctorName,
//           clinicId: _collectedClinicId,
//           patientService: _collectedPatientService,
//         );
//         break;
//       default:
//         screen = Container(); // Placeholder, you may want to handle this case
//     }

//     _screens[index] = screen;
//     return screen;
//   }
// }
// // END OF OverlayView FUNCTION //

// //###################################################################################//
