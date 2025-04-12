// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/add_empty_container.dart';
// import 'package:neocare_dental_app/mywidgets/add_empty_oral_examination_container.dart';

// import 'package:neocare_dental_app/mywidgets/treatment_screen_1.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_screen_2.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_screen_3.dart';
// import 'package:neocare_dental_app/mywidgets/user_data_provider.dart';
// import 'package:provider/provider.dart';

// class StartTreatment extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String patientId;
//   final int age;
//   final String gender;
//   final String patientName;
//   final String patientMobileNumber;
//   final String? patientPicUrl;
//   final String doctorName;
//   final String? uhid;

//   const StartTreatment({
//     Key? key,
//     required this.patientId,
//     required this.age,
//     required this.gender,
//     required this.patientName,
//     required this.patientMobileNumber,
//     required this.patientPicUrl,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//     required this.uhid,
//   }) : super(key: key);

//   @override
//   State<StartTreatment> createState() => _StartTreatmentState();
// }

// class _StartTreatmentState extends State<StartTreatment> {
//   late PageController _pageController;

//   List<AddEmptyOralExaminationContainer> containers = [];
//   List<AddEmptyContainer> dynamicContainers = [];
//   List<String> selectedProcedures = [];
//   List<dynamic> dynamicContainersData = [];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: 0);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userData = Provider.of<UserDataProvider>(context);

//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text('Treatment for ${widget.patientName}'),
//       // ),
//       body: PageView(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(),
//         children: [
//           TreatmentScreen1(
//             doctorId: widget.doctorId,
//             clinicId: widget.clinicId,
//             patientId: widget.patientId,
//             age: widget.age,
//             gender: widget.gender,
//             patientName: widget.patientName,
//             patientMobileNumber: widget.patientMobileNumber,
//             patientPicUrl: widget.patientPicUrl,
//             pageController: _pageController,
//             doctorName: widget.doctorName,
//             uhid: widget.uhid,
//           ),
//           TreatmentScreen2(
//             doctorId: widget.doctorId,
//             clinicId: widget.clinicId,
//             patientId: widget.patientId,
//             age: widget.age,
//             gender: widget.gender,
//             patientName: widget.patientName,
//             patientMobileNumber: widget.patientMobileNumber,
//             patientPicUrl: widget.patientPicUrl,
//             pageController: _pageController,
//             containers: const [], // Provide any required data for 'containers'
//             userData: userData, // Provide the 'userData' object

//             doctorName: widget.doctorName,
//             uhid: widget.uhid,
//           ),
//           TreatmentScreen3(
//             doctorId: widget.doctorId,
//             clinicId: widget.clinicId,
//             patientId: widget.patientId,
//             age: widget.age,
//             gender: widget.gender,
//             patientName: widget.patientName,
//             patientMobileNumber: widget.patientMobileNumber,
//             patientPicUrl: widget.patientPicUrl,
//             pageController: _pageController,
//             userData: userData,

//             containers: containers, // Pass the containers list here
//             dynamicContainers:
//                 dynamicContainers, // Pass the dynamicContainers list here
//             doctorName: widget.doctorName,
//             uhid: widget.uhid,
//           ),
//           // Add more screens here if needed
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/add_empty_container.dart';

// import 'package:neocare_dental_app/mywidgets/treatment_screen_1.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_screen_2.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_screen_3.dart';
// import 'package:neocare_dental_app/mywidgets/user_data_provider.dart';
// import 'package:provider/provider.dart';

// class StartTreatment extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String patientId;
//   final int age;
//   final String gender;
//   final String patientName;
//   final String patientMobileNumber;
//   final String? patientPicUrl;
//   final String doctorName;
//   final String? uhid;

//   const StartTreatment({
//     Key? key,
//     required this.patientId,
//     required this.age,
//     required this.gender,
//     required this.patientName,
//     required this.patientMobileNumber,
//     required this.patientPicUrl,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//     required this.uhid,
//   }) : super(key: key);

//   @override
//   State<StartTreatment> createState() => _StartTreatmentState();
// }

// class _StartTreatmentState extends State<StartTreatment> {
//   late PageController _pageController;
//   List<AddEmptyContainer> containers = [];
//   List<AddEmptyContainer> dynamicContainers = [];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: 0);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userData = Provider.of<UserDataProvider>(context);

//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text('Treatment for ${widget.patientName}'),
//       // ),
//       body: PageView(
//         controller: _pageController,
//         children: [
//           TreatmentScreen1(
//             doctorId: widget.doctorId,
//             clinicId: widget.clinicId,
//             patientId: widget.patientId,
//             age: widget.age,
//             gender: widget.gender,
//             patientName: widget.patientName,
//             patientMobileNumber: widget.patientMobileNumber,
//             patientPicUrl: widget.patientPicUrl,
//             pageController: _pageController,
//             doctorName: widget.doctorName,
//             uhid: widget.uhid,
//           ),
//           TreatmentScreen2(
//             doctorId: widget.doctorId,
//             clinicId: widget.clinicId,
//             patientId: widget.patientId,
//             age: widget.age,
//             gender: widget.gender,
//             patientName: widget.patientName,
//             patientMobileNumber: widget.patientMobileNumber,
//             patientPicUrl: widget.patientPicUrl,
//             pageController: _pageController,
//             containers: const [], // Provide any required data for 'containers'
//             userData: userData, // Provide the 'userData' object

//             doctorName: widget.doctorName,
//             uhid: widget.uhid,
//           ),
//           TreatmentScreen3(
//             doctorId: widget.doctorId,
//             clinicId: widget.clinicId,
//             patientId: widget.patientId,
//             age: widget.age,
//             gender: widget.gender,
//             patientName: widget.patientName,
//             patientMobileNumber: widget.patientMobileNumber,
//             patientPicUrl: widget.patientPicUrl,
//             pageController: _pageController,
//             userData: userData,

//             containers: containers, // Pass the containers list here
//             dynamicContainers:
//                 dynamicContainers, // Pass the dynamicContainers list here
//             doctorName: widget.doctorName,
//             uhid: widget.uhid,
//             //userDataScreen2: userDataScreen2,
//           ),
//           // Add more screens here if needed
//         ],
//       ),
//       // bottomNavigationBar: Row(
//       //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       //   children: [
//       //     if (_pageController.hasClients && _pageController.page != 0)
//       //       TextButton(
//       //         onPressed: () {
//       //           _pageController.previousPage(
//       //             duration: const Duration(milliseconds: 300),
//       //             curve: Curves.ease,
//       //           );
//       //         },
//       //         child: const Text('Back'),
//       //       ),
//       //     if (_pageController.hasClients && _pageController.page != 1)
//       //       TextButton(
//       //         onPressed: () {
//       //           _pageController.nextPage(
//       //             duration: const Duration(milliseconds: 300),
//       //             curve: Curves.ease,
//       //           );
//       //         },
//       //         child: const Text('Next'),
//       //       ),
//       //   ],
//       // ),
//     );
//   }
// }
