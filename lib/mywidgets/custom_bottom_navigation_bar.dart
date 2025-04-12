// import 'package:flutter/material.dart';

// class CustomBottomNavigationBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const CustomBottomNavigationBar({
//     required this.currentIndex,
//     required this.onTap,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: onTap,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.calendar_today),
//           label: 'Calendar',
//         ),
//         // Add more items for additional icons
//       ],
//     );
//   }
// }

//********* */
// import 'package:flutter/material.dart';

// class CustomBottomNavigationBar extends StatefulWidget {
//   final Function onTabSelected;

//   const CustomBottomNavigationBar({super.key, required this.onTabSelected});

//   @override
//   State<CustomBottomNavigationBar> createState() =>
//       _CustomBottomNavigationBarState();
// }

// class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType
//           .fixed, // Set type to fixed to disable animation
//       currentIndex: _currentIndex,
//       items: [
//         BottomNavigationBarItem(
//           icon: Icon(
//             Icons.home,
//             color: _currentIndex == 0 ? Colors.blue : Colors.grey,
//           ),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(
//             Icons.calendar_month_rounded,
//             color: _currentIndex == 1 ? Colors.blue : Colors.grey,
//           ),
//           label: 'Calender',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(
//             Icons.add,
//             color: _currentIndex == 2 ? Colors.blue : Colors.grey,
//           ),
//           label: 'Add',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(
//             Icons.search,
//             color: _currentIndex == 3 ? Colors.blue : Colors.grey,
//           ),
//           label: 'Search',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(
//             Icons.person,
//             color: _currentIndex == 4 ? Colors.blue : Colors.grey,
//           ),
//           label: 'Profile',
//         ),
//       ],
//       onTap: (index) {
//         setState(() {
//           _currentIndex = index;
//           widget.onTabSelected(index);
//         });
//       },
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/overlay_screen.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_n_display_all_patients.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'dart:developer' as devtools show log;

// class CustomBottomNavigationBar extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;

//   const CustomBottomNavigationBar({
//     Key? key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.patientService,
//     required this.doctorName,
//   }) : super(key: key);

//   @override
//   State<CustomBottomNavigationBar> createState() =>
//       _CustomBottomNavigationBarState();
// }

// class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
//   int _currentIndex = 0;
//   final List<bool> _selectedStates = [true, false, false, false, false];
//   late PageController _pageController;
//   List<Map<String, dynamic>> recentPatients = [];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: _currentIndex);
//     _updateRecentPatients();
//   }

//   Future<List<Map<String, dynamic>>> _fetchRecentPatients() async {
//     try {
//       final clinicRef =
//           FirebaseFirestore.instance.collection('clinics').doc(widget.clinicId);
//       final patientsQuerySnapshot = await clinicRef
//           .collection('patients')
//           .orderBy('searchCount', descending: true)
//           .limit(4)
//           .get();

//       final recentPatientsData = <Map<String, dynamic>>[];

//       for (final patientDoc in patientsQuerySnapshot.docs) {
//         final patientData = patientDoc.data();
//         devtools.log('Patient data: $patientData'); // Add this line for logging

//         if (patientData.isNotEmpty) {
//           recentPatientsData.add(patientData);
//         }
//       }

//       devtools.log(
//           'Recent patients data: $recentPatientsData'); // Add this line for logging

//       return recentPatientsData;
//     } catch (e) {
//       // Handle error
//       devtools.log('Error fetching recent patients: $e');
//       return []; // Return an empty list in case of an error
//     }
//   }

//   Future<void> _updateRecentPatients() async {
//     final patients = await _fetchRecentPatients();
//     setState(() {
//       recentPatients = patients;
//     });
//   }

//   Future<void> _onAddButtonPressed() async {
//     setState(() {
//       onAddButtonPressed();
//     });
//   }

//   void onAddButtonPressed() async {
//     // Implement your logic for the Add button press
//     devtools.log('Add button pressed!');
//     // Perform the desired action when the add button is pressed
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OverlayScreen(
//           onAddButtonPressed: () async {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => AddNewPatient(
//                   clinicId: widget.clinicId,
//                   doctorId: widget.doctorId,
//                   doctorName: widget.doctorName,
//                   patientService: widget.patientService,
//                 ),
//               ),
//             );
//             // Assuming you want to navigate back to the original screen
//             _onItemTapped(_currentIndex);
//           },
//           onPatientSelectedForTreatment: onPatientSelectedForTreatment,
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           clinicId: widget.clinicId,
//           patientService: widget.patientService,
//         ),
//       ),
//     );
//   }

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

//   BottomNavigationBarItem _buildBottomNavigationBarItem({
//     required IconData icon,
//     required IconData selectedIcon,
//     required String label,
//     required int index,
//   }) {
//     return BottomNavigationBarItem(
//       icon: _selectedStates[index]
//           ? Icon(selectedIcon, size: 24)
//           : Icon(icon, size: 24),
//       label: label,
//     );
//   }

//   void _onItemTapped(int index) {
//     _pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   void _updateSelectedStates() {
//     for (int i = 0; i < _selectedStates.length; i++) {
//       _selectedStates[i] = (i == _currentIndex);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           setState(() {
//             _currentIndex = index;
//             _updateSelectedStates();
//           });
//         },
//         children: [
//           // LandingScreen(
//           //   doctorId: widget.doctorId,
//           //   clinicId: widget.clinicId,
//           //   patientService: widget.patientService,
//           //   doctorName: widget.doctorName,
//           // ),
//           CalenderView(
//             doctorId: widget.doctorId,
//             doctorName: widget.doctorName,
//             clinicId: widget.clinicId,
//             patientService: widget.patientService,
//           ),

//           // Add other screens here
//           OverlayScreen(
//             doctorId: widget.doctorId,
//             doctorName: widget.doctorName,
//             clinicId: widget.clinicId,
//             patientService: widget.patientService,
//             onPatientSelectedForTreatment: onPatientSelectedForTreatment,
//             onAddButtonPressed: _onAddButtonPressed,
//           ),

//           SearchAndDisplayAllPatients(
//             clinicId: widget.clinicId,
//             doctorId: widget.doctorId,
//             doctorName: widget.doctorName,
//             patientService: widget.patientService,
//             recentPatients: recentPatients,
//           ),

//           MyProfile(
//             doctorId: widget.doctorId,
//             clinicId: widget.clinicId,
//             doctorName: widget.doctorName,
//             patientService: widget.patientService,
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         currentIndex: _currentIndex,
//         onTap: _onItemTapped,
//         items: [
//           _buildBottomNavigationBarItem(
//             icon: Icons.home_outlined,
//             selectedIcon: Icons.home,
//             label: 'Home',
//             index: 0,
//           ),
//           _buildBottomNavigationBarItem(
//             icon: Icons.calendar_today_outlined,
//             selectedIcon: Icons.calendar_today_rounded,
//             label: 'Calendar',
//             index: 1,
//           ),
//           _buildBottomNavigationBarItem(
//             icon: Icons.add_circle_outline_outlined,
//             selectedIcon: Icons.add_circle_outlined,
//             label: '',
//             index: 2,
//           ),
//           _buildBottomNavigationBarItem(
//             icon: Icons.search_outlined,
//             selectedIcon: Icons.search_sharp,
//             label: 'Search',
//             index: 3,
//           ),
//           _buildBottomNavigationBarItem(
//             icon: Icons.person_outline,
//             selectedIcon: Icons.person,
//             label: 'Profile',
//             index: 4,
//           ),
//         ],
//       ),
//     );
//   }
// }

// Functions to be executed when buttons are pressed
// void _onCalendarButtonPressed() {
//   // Implement your logic for the Calendar button press
//   devtools.log('Calendar button pressed!');
//   // Navigate to the Calendar View page
//   Navigator.of(context).push(
//     MaterialPageRoute(
//       builder: (context) => CalenderView(
//         doctorId: widget.doctorId,
//         doctorName: widget.doctorName,
//         clinicId: widget.clinicId,
//         patientService: widget.patientService,
//       ),
//     ),
//   );
// }

// void _onSearchButtonPressed() async {
//   // Implement your logic for the Search button press
//   devtools.log('Search button pressed!');
//   // Fetch recent patients
//   List<Map<String, dynamic>> recentPatients = await _fetchRecentPatients();

//   // ignore: use_build_context_synchronously
//   Navigator.of(context).push(
//     MaterialPageRoute(
//       builder: (context) => SearchAndDisplayAllPatients(
//         clinicId: widget.clinicId,
//         doctorId: widget.doctorId,
//         doctorName: widget.doctorName,
//         patientService: widget.patientService,
//         recentPatients: recentPatients,
//       ),
//     ),
//   );
// }

// void _onProfileButtonPressed() {
//   // Implement your logic for the Profile button press
//   devtools.log('Profile button pressed!');
//   // Implement logic to navigate to the Profile screen
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => MyProfile(
//         doctorId: widget.doctorId,
//         clinicId: widget.clinicId,
//         doctorName: widget.doctorName,
//         patientService: widget.patientService,
//       ),
//     ),
//   );
// }

//********** */
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/overlay_screen.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_n_display_all_patients.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'dart:developer' as devtools show log;

// class CustomBottomNavigationBar extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;

//   const CustomBottomNavigationBar({
//     super.key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.patientService,
//     required this.doctorName,
//   });

//   @override
//   State<CustomBottomNavigationBar> createState() =>
//       _CustomBottomNavigationBarState();
// }

// class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
//   int _currentIndex = 0; // Default selected index is 0 (Home)
//   List<bool> _selectedStates = [true, false, false, false, false];

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: _selectedStates[_currentIndex]
//           ? Colors.blue // Change to your primary color
//           : Colors.grey, // Change to your secondary color
//       unselectedItemColor: Colors.grey, // Change to your secondary color
//       currentIndex: _currentIndex,
//       onTap: _onItemTapped,
//       items: [
//         _buildBottomNavigationBarItem(
//           icon: Icons.home_outlined,
//           selectedIcon: Icons.home,
//           label: 'Home',
//           index: 0,
//         ),
//         _buildBottomNavigationBarItem(
//           icon: Icons.calendar_today_outlined,
//           selectedIcon: Icons.calendar_today_rounded,
//           label: 'Calendar',
//           index: 1,
//         ),
//         _buildBottomNavigationBarItem(
//           icon: Icons.add_circle_outline_outlined,
//           selectedIcon: Icons.add_circle_outlined,
//           label: '',
//           index: 2,
//         ),
//         _buildBottomNavigationBarItem(
//           icon: Icons.search_outlined,
//           selectedIcon: Icons.search_sharp,
//           label: 'Search',
//           index: 3,
//         ),
//         _buildBottomNavigationBarItem(
//           icon: Icons.person_outline,
//           selectedIcon: Icons.person,
//           label: 'Profile',
//           index: 4,
//         ),
//       ],
//     );
//   }

//   BottomNavigationBarItem _buildBottomNavigationBarItem({
//     required IconData icon,
//     required IconData selectedIcon,
//     required String label,
//     required int index,
//   }) {
//     return BottomNavigationBarItem(
//       icon: _selectedStates[index]
//           ? Icon(selectedIcon, size: 24)
//           : Icon(icon, size: 24),
//       label: label,
//     );
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       if (index == _currentIndex) {
//         // The user tapped on the already selected icon (Home)
//         // You can perform additional actions or simply return
//         return;
//       }

//       _currentIndex = index;
//       _updateSelectedStates();
//     });

//     // Handle navigation to the corresponding screens based on the index
//     switch (index) {
//       case 0:
//         // Navigate back to the LandingScreen (Home)
//         Navigator.pop(context);
//         break;
//       case 1:
//         // Execute the function for the Calendar button
//         _onCalendarButtonPressed();
//         break;
//       case 2:
//         // Execute the function for the Add button
//         _onAddButtonPressed();
//         break;
//       case 3:
//         // Execute the function for the Search button
//         _onSearchButtonPressed();
//         break;
//       case 4:
//         // Execute the function for the Profile button
//         _onProfileButtonPressed();
//         break;
//     }
//   }

//   Future<List<Map<String, dynamic>>> _fetchRecentPatients() async {
//     try {
//       final clinicRef =
//           FirebaseFirestore.instance.collection('clinics').doc(widget.clinicId);
//       final patientsQuerySnapshot = await clinicRef
//           .collection('patients')
//           .orderBy('searchCount', descending: true)
//           .limit(4)
//           .get();

//       final recentPatientsData = <Map<String, dynamic>>[];

//       for (final patientDoc in patientsQuerySnapshot.docs) {
//         final patientData = patientDoc.data();
//         devtools.log('Patient data: $patientData'); // Add this line for logging

//         if (patientData.isNotEmpty) {
//           recentPatientsData.add(patientData);
//         }
//       }

//       devtools.log(
//           'Recent patients data: $recentPatientsData'); // Add this line for logging

//       return recentPatientsData;
//     } catch (e) {
//       // Handle error
//       devtools.log('Error fetching recent patients: $e');
//       return []; // Return an empty list in case of an error
//     }
//   }

//   void _updateSelectedStates() {
//     for (int i = 0; i < _selectedStates.length; i++) {
//       _selectedStates[i] = (i == _currentIndex);
//     }
//   }

//   // Functions to be executed when buttons are pressed
//   void _onCalendarButtonPressed() {
//     // Implement your logic for the Calendar button press
//     devtools.log('Calendar button pressed!');
//     // Navigate to the Calendar View page
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => CalenderView(
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           clinicId: widget.clinicId,
//           patientService: widget.patientService,
//         ),
//       ),
//     );
//   }

//   void _onAddButtonPressed() async {
//     // Implement your logic for the Add button press
//     devtools.log('Add button pressed!');
//     // Perform the desired action when the add button is pressed
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OverlayScreen(
//           onAddButtonPressed: () async {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => AddNewPatient(
//                   clinicId: widget.clinicId,
//                   doctorId: widget.doctorId,
//                   doctorName: widget.doctorName,
//                   patientService: widget.patientService,
//                 ),
//               ),
//             );
//             // Assuming you want to navigate back to the original screen
//             _onItemTapped(_currentIndex);
//           },
//           onPatientSelectedForTreatment: onPatientSelectedForTreatment,
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           clinicId: widget.clinicId,
//           patientService: widget.patientService,
//         ),
//       ),
//     );
//   }

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

//   void _onSearchButtonPressed() async {
//     // Implement your logic for the Search button press
//     devtools.log('Search button pressed!');
//     // Fetch recent patients
//     List<Map<String, dynamic>> recentPatients = await _fetchRecentPatients();

//     // ignore: use_build_context_synchronously
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => SearchAndDisplayAllPatients(
//           clinicId: widget.clinicId,
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           patientService: widget.patientService,
//           recentPatients: recentPatients,
//         ),
//       ),
//     );
//   }

//   void _onProfileButtonPressed() {
//     // Implement your logic for the Profile button press
//     devtools.log('Profile button pressed!');
//     // Implement logic to navigate to the Profile screen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MyProfile(
//           doctorId: widget.doctorId,
//           clinicId: widget.clinicId,
//           doctorName: widget.doctorName,
//           patientService: widget.patientService,
//         ),
//       ),
//     );
//   }
// }
