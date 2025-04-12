import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/firestore/appointment_service.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/treatment_summary_screen.dart';

import 'dart:developer' as devtools show log;

class TreatmentStarted extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String patientId;
  final int age;
  final String gender;
  final String patientName;
  final String patientMobileNumber;
  final String? patientPicUrl;
  final PageController pageController;
  final String? treatmentId;
  final Map<String, dynamic>? treatmentData;
  final String doctorName;
  final String? uhid;

  const TreatmentStarted({
    Key? key,
    required this.clinicId,
    required this.doctorId,
    required this.patientId,
    required this.age,
    required this.gender,
    required this.patientName,
    required this.patientMobileNumber,
    required this.patientPicUrl,
    required this.pageController,
    this.treatmentId,
    this.treatmentData,
    required this.doctorName,
    required this.uhid,
  }) : super(key: key);

  @override
  State<TreatmentStarted> createState() => _TreatmentStartedState();
}

class _TreatmentStartedState extends State<TreatmentStarted> {
  DateTime? appointmentDate;
  late AppointmentService _appointmentService;

  @override
  void initState() {
    super.initState();
    _appointmentService = AppointmentService(); // Initialize the service
    fetchAppointmentDate(); // Fetch the appointment date on initialization
  }

  Future<void> fetchAppointmentDate() async {
    // Use the AppointmentService to update treatment ID and fetch appointment date
    appointmentDate =
        await _appointmentService.updateTreatmentIdInAppointmentsAndFetchDate(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      treatmentId: widget.treatmentId,
    );

    devtools.log('Appointment Date is: $appointmentDate');

    // Trigger a UI rebuild with the updated appointmentDate
    setState(() {});
  }

  void _navigateToTreatmentSummaryScreen() async {
    final DateTime? fetchedAppointmentDate =
        await _appointmentService.updateTreatmentIdInAppointmentsAndFetchDate(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      treatmentId: widget.treatmentId,
    );

    // Navigate to TreatmentSummaryScreen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TreatmentSummaryScreen(
          clinicId: widget.clinicId,
          patientId: widget.patientId,
          appointmentDate: fetchedAppointmentDate,
          patientPicUrl: widget.patientPicUrl,
          age: widget.age,
          gender: widget.gender,
          patientName: widget.patientName,
          patientMobileNumber: widget.patientMobileNumber,
          treatmentId: widget.treatmentId,
          treatmentData: widget.treatmentData,
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
          uhid: widget.uhid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if treatmentData is loaded and contains 'treatmentCost' and 'totalCost'.
    bool hasTotalCost = widget.treatmentData != null &&
        widget.treatmentData!.containsKey('treatmentCost') &&
        widget.treatmentData!['treatmentCost']!.containsKey('totalCost');

    // Extract totalCost or set it to 'N/A' if not found.
    double? totalCost = hasTotalCost
        ? widget.treatmentData!['treatmentCost']!['totalCost']
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatment Started'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Patient information container
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: MyColors.colorPalette['surface'],
                          backgroundImage: widget.patientPicUrl != null &&
                                  widget.patientPicUrl!.isNotEmpty
                              ? NetworkImage(widget.patientPicUrl!)
                              : Image.asset(
                                  'assets/images/default-image.png',
                                  color: MyColors.colorPalette['primary'],
                                  colorBlendMode: BlendMode.color,
                                ).image,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.patientName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.age.toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const Text(
                                '/',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                widget.gender,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.patientMobileNumber,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Ongoing Treatment title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ongoing Treatment',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Treatment details container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Fetch ongoing treatment here'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Appointment on:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        appointmentDate != null
                            ? DateFormat('E, d MMM, hh:mm a')
                                .format(appointmentDate!)
                            : 'N/A',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      InkWell(
                        onTap: _navigateToTreatmentSummaryScreen,
                        child: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Amount Paid/Total Cost',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '₹ 0 / ${totalCost != null ? totalCost.toString() : 'N/A'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Treatment History title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Treatment History',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Patient has no previous treatment history with the clinic',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE WITH DIRECT BACKEND CALLS
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_summary_screen.dart';
// import 'dart:developer' as devtools show log;

// class TreatmentStarted extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String patientId;
//   final int age;
//   final String gender;
//   final String patientName;
//   final String patientMobileNumber;
//   final String? patientPicUrl;
//   final PageController pageController;
//   final String? treatmentId;
//   final Map<String, dynamic>? treatmentData;
//   final String doctorName;
//   final String? uhid;

//   const TreatmentStarted({
//     Key? key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.patientId,
//     required this.age,
//     required this.gender,
//     required this.patientName,
//     required this.patientMobileNumber,
//     required this.patientPicUrl,
//     required this.pageController,
//     this.treatmentId,
//     this.treatmentData,
//     required this.doctorName,
//     required this.uhid,
//   }) : super(key: key);

//   @override
//   State<TreatmentStarted> createState() => _TreatmentStartedState();
// }

// class _TreatmentStartedState extends State<TreatmentStarted> {
//   DateTime? appointmentDate; // Define the appointmentDate variable

//   Future<void> fetchAppointmentDate() async {
//     appointmentDate =
//         await updateTreatmentIdInAppointmentsAndFetchAppointmentDate();

//     devtools.log(
//         'This is coming from inside fetchAppointmentDate function. Appointment Date is: $appointmentDate');
//     // Add setState here to trigger a rebuild with the updated appointmentDate
//     setState(() {
//       appointmentDate = appointmentDate;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchAppointmentDate(); // Call the function in the initState
//   }

//   Future<DateTime?>
//       updateTreatmentIdInAppointmentsAndFetchAppointmentDate() async {
//     // Create references to the appointment documents in both locations
//     final clinicRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(widget.clinicId)
//         .collection('appointments');
//     final patientRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(widget.clinicId)
//         .collection('patients')
//         .doc(widget.patientId)
//         .collection('appointments');

//     // Fetch the appointments matching the patientId and date from the clinic sub-collection
//     final clinicQuery = await clinicRef
//         .where('patientId', isEqualTo: widget.patientId)
//         .where('date', isGreaterThanOrEqualTo: Timestamp.now())
//         .get();

//     // Push the widget.treatmentId into the "treatmentId" field of clinic appointments
//     for (final clinicDoc in clinicQuery.docs) {
//       final appointmentId = clinicDoc.id;
//       devtools.log('appointmentId captured which is: $appointmentId');
//       try {
//         await clinicRef
//             .doc(appointmentId)
//             .update({'treatmentId': widget.treatmentId});

//         // Capture appointmentId and fetch the corresponding patient appointment
//         final patientQuery = await patientRef
//             .where('appointmentId', isEqualTo: appointmentId)
//             .get();

//         for (final patientDoc in patientQuery.docs) {
//           final patientAppointmentId = patientDoc.id;
//           try {
//             await patientRef
//                 .doc(patientAppointmentId)
//                 .update({'treatmentId': widget.treatmentId});
//           } catch (e) {
//             devtools.log('Error updating patient appointment document: $e');
//           }
//         }
//       } catch (e) {
//         devtools.log('Error updating clinic appointment document: $e');
//       }
//     }

//     // Return the appointmentDate
//     // if (clinicQuery.docs.isNotEmpty) {
//     //   final Timestamp appointmentTimestamp = clinicQuery.docs.first['date'];
//     //   return appointmentTimestamp.toDate();
//     // } else {
//     //   return null; // Handle the case where no appointments were found
//     // }
//     if (clinicQuery.docs.isNotEmpty) {
//       final Timestamp appointmentTimestamp = clinicQuery.docs.first['date'];
//       devtools.log(
//           'Appointment Timestamp: $appointmentTimestamp'); // Add this line for debugging
//       return appointmentTimestamp.toDate();
//     } else {
//       devtools.log('No appointments found'); // Add this line for debugging
//       return null; // Handle the case where no appointments were found
//     }
//   }

//   void _navigateToTreatmentSummaryScreen() async {
//     final DateTime? appointmentDate =
//         await updateTreatmentIdInAppointmentsAndFetchAppointmentDate();

//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => TreatmentSummaryScreen(
//           clinicId: widget.clinicId,
//           patientId: widget.patientId,
//           appointmentDate: appointmentDate,
//           patientPicUrl: widget.patientPicUrl,
//           age: widget.age,
//           gender: widget.gender,
//           patientName: widget.patientName,
//           patientMobileNumber: widget.patientMobileNumber,
//           treatmentId: widget.treatmentId,
//           treatmentData: widget.treatmentData,
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           uhid: widget.uhid,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Check if treatmentData is loaded and contains 'treatmentCost' and 'totalCost'.
//     bool hasTotalCost = widget.treatmentData != null &&
//         widget.treatmentData!.containsKey('treatmentCost') &&
//         widget.treatmentData!['treatmentCost']!.containsKey('totalCost');

//     // Extract totalCost or set it to 'N/A' if not found.
//     double totalCost = hasTotalCost
//         ? widget.treatmentData!['treatmentCost']!['totalCost']
//         : 'N/A';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Treatment Started'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Align(
//               alignment: Alignment.topCenter,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue, width: 3),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: IntrinsicHeight(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Align(
//                         alignment: Alignment.topLeft,
//                         // child: CircleAvatar(
//                         //   radius: 30,
//                         // ),
//                         child: CircleAvatar(
//                           radius: 24,
//                           backgroundColor: MyColors.colorPalette['surface'],
//                           backgroundImage: widget.patientPicUrl != null &&
//                                   widget.patientPicUrl!.isNotEmpty
//                               ? NetworkImage(widget.patientPicUrl!)
//                               : Image.asset(
//                                   'assets/images/default-image.png',
//                                   color: MyColors.colorPalette['primary'],
//                                   colorBlendMode: BlendMode.color,
//                                 ).image,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.patientName,
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               Text(
//                                 widget.age.toString(),
//                                 style: const TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.normal,
//                                 ),
//                               ),
//                               const Text(
//                                 '/',
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.normal,
//                                 ),
//                               ),
//                               Text(
//                                 widget.gender,
//                                 style: const TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.normal,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             widget.patientMobileNumber,
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.normal,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Ongoing Treatment',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.teal, width: 3),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 children: [
//                   const Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text('Fetch ongoing treatment here'),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment:
//                         MainAxisAlignment.spaceBetween, // Add this line
//                     children: [
//                       const Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Appointment on:',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         appointmentDate != null
//                             ? DateFormat('E, d MMM, hh:mm a')
//                                 .format(appointmentDate!)
//                             : 'N/A',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                       InkWell(
//                         onTap: _navigateToTreatmentSummaryScreen,
//                         child: const Icon(Icons.arrow_forward),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   const Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'Amount Paid/Total Cost',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.normal,
//                       ),
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       '₹ 0 / $totalCost',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Treatment History',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Patient has no previous treatment history with the clinic',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
