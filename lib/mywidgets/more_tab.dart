import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/appoinment_tab.dart';
import 'package:neocaresmileapp/mywidgets/gallery_tab.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/payment_tab.dart';

import 'dart:developer' as devtools show log;

class MoreTab extends StatefulWidget {
  final String clinicId;
  final String patientId;
  final String? treatmentId;
  final String doctorId;
  final String doctorName;
  final Map<String, dynamic>? treatmentData;
  final String patientName;
  final String patientMobileNumber;
  final int age;
  final String gender;
  final String? patientPicUrl;
  final String? uhid;

  const MoreTab({
    super.key,
    required this.clinicId,
    required this.patientId,
    required this.treatmentId,
    required this.doctorId,
    required this.doctorName,
    required this.treatmentData,
    required this.patientName,
    required this.patientMobileNumber,
    required this.age,
    required this.gender,
    required this.patientPicUrl,
    required this.uhid,
  });

  @override
  State<MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<MoreTab> {
  bool _isPaymentButtonFocussed = false;
  bool _isAppointmentButtonFocussed = false;
  bool _isGalleryButtonFocussed = false;
  Widget _tabContent = const SizedBox();

  void _navigateToPaymentTab() {
    devtools.log('This is coming from inside _navigateToPaymentTab');
    setState(() {
      _isPaymentButtonFocussed = true;
      _isAppointmentButtonFocussed = false;
      _isGalleryButtonFocussed = false;

      _tabContent = PaymentTab(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
        treatmentId: widget.treatmentId,
        doctorId: widget.doctorId,
        treatmentData: widget.treatmentData,
      );
    });
  }

  void _navigateToAppointmentTab() {
    devtools.log('This is coming from inside _navigateToAppointmentTab');
    setState(() {
      _isAppointmentButtonFocussed = true;
      _isPaymentButtonFocussed = false;
      _isGalleryButtonFocussed = false;

      _tabContent = AppointmentTab(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
        treatmentId: widget.treatmentId,
        doctorId: widget.doctorId,
        doctorName: widget.doctorName,
        patientName: widget.patientName,
        patientMobileNumber: widget.patientMobileNumber,
        age: widget.age,
        gender: widget.gender,
        patientPicUrl: widget.patientPicUrl,
        uhid: widget.uhid,
      );
    });
  }

  // void _navigateToGalleryTab() {
  //   devtools.log('This is coming from inside _navigateToGalleryTab');
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => GalleryScreen(
  //         clinicId: widget.clinicId,
  //         patientId: widget.patientId,
  //         treatmentId: widget.treatmentId!,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    devtools.log('Welcome to main build widget of MoreTab');
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _isAppointmentButtonFocussed
                        ? MyColors.colorPalette['primary'] ?? Colors.blue
                        : Colors.transparent,
                    width: 1.0,
                  ),
                ),
              ),
              child: TextButton(
                onPressed: _navigateToAppointmentTab,
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return _isAppointmentButtonFocussed
                          ? MyColors.colorPalette['primary'] ?? Colors.blue
                          : MyColors.colorPalette['on-surface'] ?? Colors.grey;
                    },
                  ),
                ),
                child: const Text('Appointment'),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _isPaymentButtonFocussed
                        ? MyColors.colorPalette['primary'] ?? Colors.blue
                        : Colors.transparent,
                    width: 1.0,
                  ),
                ),
              ),
              child: TextButton(
                onPressed: _navigateToPaymentTab,
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return _isPaymentButtonFocussed
                          ? MyColors.colorPalette['primary'] ?? Colors.blue
                          : MyColors.colorPalette['on-surface'] ?? Colors.grey;
                    },
                  ),
                ),
                child: const Text('Payment'),
              ),
            ),
            // Container(
            //   decoration: BoxDecoration(
            //     border: Border(
            //       bottom: BorderSide(
            //         color: _isGalleryButtonFocussed
            //             ? MyColors.colorPalette['primary'] ?? Colors.blue
            //             : Colors.transparent,
            //         width: 1.0,
            //       ),
            //     ),
            //   ),
            //   child: TextButton(
            //     onPressed: _navigateToGalleryTab,
            //     style: ButtonStyle(
            //       foregroundColor: MaterialStateProperty.resolveWith<Color>(
            //         (Set<MaterialState> states) {
            //           return _isGalleryButtonFocussed
            //               ? MyColors.colorPalette['primary'] ?? Colors.blue
            //               : MyColors.colorPalette['on-surface'] ?? Colors.grey;
            //         },
            //       ),
            //     ),
            //     child: const Text('Gallery'),
            //   ),
            // ),
          ],
        ),
        // Expanded(
        //   child: _tabContent,
        // ),
        _tabContent,
      ],
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  //
// import 'dart:ffi';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/appoinment_tab.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/payment_tab.dart';
// import 'package:neocare_dental_app/mywidgets/gallery_tab.dart';
// import 'dart:developer' as devtools show log;

// class MoreTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;
//   final String doctorId;
//   final String doctorName;
//   final Map<String, dynamic>? treatmentData;
//   final String patientName;
//   final String patientMobileNumber;
//   final int age;
//   final String gender;
//   final String? patientPicUrl;
//   final String? uhid;

//   const MoreTab({
//     Key? key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//     required this.doctorId,
//     required this.doctorName,
//     required this.treatmentData,
//     required this.patientName,
//     required this.patientMobileNumber,
//     required this.age,
//     required this.gender,
//     required this.patientPicUrl,
//     required this.uhid,
//   }) : super(key: key);

//   @override
//   State<MoreTab> createState() => _MoreTabState();
// }

// class _MoreTabState extends State<MoreTab> {
//   bool _isPaymentButtonFocussed = false;
//   bool _isAppointmentButtonFocussed = false;
//   bool _isGalleryButtonFocussed = false; // New state for Gallery button
//   Widget _tabContent = const SizedBox();
//   bool _areTabsVisible = true;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   void _navigateToPaymentTab() {
//     devtools.log('This is coming from inside _navigateToPaymentTab');
//     setState(() {
//       _isPaymentButtonFocussed = true;
//       _isAppointmentButtonFocussed = false;
//       _isGalleryButtonFocussed = false;

//       _tabContent = PaymentTab(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//         treatmentId: widget.treatmentId,
//         doctorId: widget.doctorId,
//         treatmentData: widget.treatmentData,
//       );
//     });
//   }

//   void _navigateToAppointmentTab() {
//     devtools.log('This is coming from inside _navigateToAppointmentTab');
//     setState(() {
//       _isAppointmentButtonFocussed = true;
//       _isPaymentButtonFocussed = false;
//       _isGalleryButtonFocussed = false;

//       _tabContent = AppointmentTab(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//         treatmentId: widget.treatmentId,
//         doctorId: widget.doctorId,
//         doctorName: widget.doctorName,
//         patientName: widget.patientName,
//         patientMobileNumber: widget.patientMobileNumber,
//         age: widget.age,
//         gender: widget.gender,
//         patientPicUrl: widget.patientPicUrl,
//         uhid: widget.uhid,
//       );
//     });
//   }

//   void _navigateToGalleryTab() {
//     devtools.log('This is coming from inside _navigateToGalleryTab');
//     setState(() {
//       _isGalleryButtonFocussed = true;
//       _isAppointmentButtonFocussed = false;
//       _isPaymentButtonFocussed = false;

//       _tabContent = GalleryTab(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//         treatmentId: widget.treatmentId!,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to main build widget of MoreTab');
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: _isAppointmentButtonFocussed
//                         ? MyColors.colorPalette['primary'] ?? Colors.blue
//                         : Colors.transparent,
//                     width: 1.0,
//                   ),
//                 ),
//               ),
//               child: TextButton(
//                 onPressed: _navigateToAppointmentTab,
//                 style: ButtonStyle(
//                   foregroundColor: MaterialStateProperty.resolveWith<Color>(
//                     (Set<MaterialState> states) {
//                       return _isAppointmentButtonFocussed
//                           ? MyColors.colorPalette['primary'] ?? Colors.blue
//                           : MyColors.colorPalette['on-surface'] ?? Colors.grey;
//                     },
//                   ),
//                 ),
//                 child: const Text('Appointment'),
//               ),
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: _isPaymentButtonFocussed
//                         ? MyColors.colorPalette['primary'] ?? Colors.blue
//                         : Colors.transparent,
//                     width: 1.0,
//                   ),
//                 ),
//               ),
//               child: TextButton(
//                 onPressed: _navigateToPaymentTab,
//                 style: ButtonStyle(
//                   foregroundColor: MaterialStateProperty.resolveWith<Color>(
//                     (Set<MaterialState> states) {
//                       return _isPaymentButtonFocussed
//                           ? MyColors.colorPalette['primary'] ?? Colors.blue
//                           : MyColors.colorPalette['on-surface'] ?? Colors.grey;
//                     },
//                   ),
//                 ),
//                 child: const Text('Payment'),
//               ),
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: _isGalleryButtonFocussed
//                         ? MyColors.colorPalette['primary'] ?? Colors.blue
//                         : Colors.transparent,
//                     width: 1.0,
//                   ),
//                 ),
//               ),
//               child: TextButton(
//                 onPressed: _navigateToGalleryTab,
//                 style: ButtonStyle(
//                   foregroundColor: MaterialStateProperty.resolveWith<Color>(
//                     (Set<MaterialState> states) {
//                       return _isGalleryButtonFocussed
//                           ? MyColors.colorPalette['primary'] ?? Colors.blue
//                           : MyColors.colorPalette['on-surface'] ?? Colors.grey;
//                     },
//                   ),
//                 ),
//                 child: const Text('Gallery'),
//               ),
//             ),
//           ],
//         ),
//         _tabContent,
//         //Expanded(child: _tabContent),
//       ],
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW IS STABLE BEFORE INTRODUCTION OF GALLERY TAB
// import 'dart:ffi';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/appoinment_tab.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/payment_tab.dart';
// import 'dart:developer' as devtools show log;

// class MoreTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;
//   final String doctorId;
//   final String doctorName;
//   final Map<String, dynamic>? treatmentData;
//   final String patientName;
//   final String patientMobileNumber;
//   final int age;
//   final String gender;
//   final String? patientPicUrl;
//   final String? uhid;
//   const MoreTab({
//     Key? key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//     required this.doctorId,
//     required this.doctorName,
//     required this.treatmentData,
//     required this.patientName,
//     required this.patientMobileNumber,
//     required this.age,
//     required this.gender,
//     required this.patientPicUrl,
//     required this.uhid,
//   }) : super(key: key);

//   @override
//   State<MoreTab> createState() => _MoreTabState();
// }

// class _MoreTabState extends State<MoreTab> {
//   bool _isPaymentButtonFocussed = false;
//   bool _isAppointmentButtonFocussed = false;
//   Widget _tabContent = const SizedBox();
//   bool _areTabsVisible = true;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   void _navigateToPaymentTab() {
//     devtools.log('This is coming from inside _navigateToPaymentTab');
//     setState(() {
//       _isPaymentButtonFocussed = true;
//       _isAppointmentButtonFocussed = false;

//       _tabContent = PaymentTab(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//         treatmentId: widget.treatmentId,
//         doctorId: widget.doctorId,
//         treatmentData: widget.treatmentData,
//       );
//     });
//   }

//   void _navigateToAppointmentTab() {
//     devtools.log('This is coming from inside _navigateToAppointmentTab');
//     setState(() {
//       _isAppointmentButtonFocussed = true;
//       _isPaymentButtonFocussed = false;

//       _tabContent = AppointmentTab(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//         treatmentId: widget.treatmentId,
//         doctorId: widget.doctorId,
//         doctorName: widget.doctorName,
//         patientName: widget.patientName,
//         patientMobileNumber: widget.patientMobileNumber,
//         age: widget.age,
//         gender: widget.gender,
//         patientPicUrl: widget.patientPicUrl,
//         uhid: widget.uhid,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to main build widget of MoreTab');
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: _isAppointmentButtonFocussed
//                         ? MyColors.colorPalette['primary'] ??
//                             Colors.blue // Border color on selection
//                         : Colors
//                             .transparent, // No border on non-selection state
//                     width: 1.0, // Border thickness
//                   ),
//                 ),
//               ),
//               child: TextButton(
//                 onPressed: _navigateToAppointmentTab,
//                 style: ButtonStyle(
//                   foregroundColor: MaterialStateProperty.resolveWith<Color>(
//                     (Set<MaterialState> states) {
//                       return _isAppointmentButtonFocussed
//                           ? MyColors.colorPalette['primary'] ??
//                               Colors.blue // Text color on selection
//                           : MyColors.colorPalette['on-surface'] ??
//                               Colors.grey; // Text color on non-selection state
//                     },
//                   ),
//                 ),
//                 child: const Text(
//                   'Appointment',
//                 ),
//               ),
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: _isPaymentButtonFocussed
//                         ? MyColors.colorPalette['primary'] ??
//                             Colors.blue // Border color on selection
//                         : Colors
//                             .transparent, // No border on non-selection state
//                     width: 1.0, // Border thickness
//                   ),
//                 ),
//               ),
//               child: TextButton(
//                 onPressed: _navigateToPaymentTab,
//                 style: ButtonStyle(
//                   foregroundColor: MaterialStateProperty.resolveWith<Color>(
//                     (Set<MaterialState> states) {
//                       return _isPaymentButtonFocussed
//                           ? MyColors.colorPalette['primary'] ??
//                               Colors.blue // Text color on selection
//                           : MyColors.colorPalette['on-surface'] ??
//                               Colors.grey; // Text color on non-selection state
//                     },
//                   ),
//                 ),
//                 child: const Text(
//                   'Payment',
//                 ),
//               ),
//             ),
//           ],
//         ),
//         // Rest of your content
//         _tabContent,
//       ],
//     );
//   }
// }
