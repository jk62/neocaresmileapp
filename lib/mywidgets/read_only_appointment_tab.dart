// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:developer' as devtools show log;

// class ReadOnlyAppointmentTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;

//   const ReadOnlyAppointmentTab({
//     Key? key,
//     required this.clinicId,
//     required this.patientId,
//   }) : super(key: key);

//   @override
//   _ReadOnlyAppointmentTabState createState() => _ReadOnlyAppointmentTabState();
// }

// class _ReadOnlyAppointmentTabState extends State<ReadOnlyAppointmentTab> {
//   final AppointmentService _appointmentService = AppointmentService();
//   List<ReadOnlyAppointmentData> appointments = []; // Store fetched appointments
//   bool appointmentsFetched = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchAndDisplayPatientFutureAppointments();
//   }

//   Future<void> fetchAndDisplayPatientFutureAppointments() async {
//     try {
//       List<Appointment> patientFutureAppointments =
//           await _appointmentService.fetchPatientFutureAppointments(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//       );

//       setState(() {
//         appointments = patientFutureAppointments.map((appointment) {
//           return ReadOnlyAppointmentData(
//             appointmentId: appointment.appointmentId,
//             appointmentDate: appointment.appointmentDate,
//             slot: appointment.slot,
//           );
//         }).toList();
//         appointmentsFetched = true;
//       });
//     } catch (e) {
//       devtools
//           .log('Failed to fetch and display patient future appointments: $e');
//     }
//   }

//   Widget _buildAppointmentContainer() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Align(
//             alignment: Alignment.topLeft,
//             child: Text(
//               'All Appointments',
//               style: MyTextStyle.textStyleMap['title-large']
//                   ?.copyWith(color: MyColors.colorPalette['on-surface']),
//             ),
//           ),
//         ),
//         for (final appointment in appointments)
//           _buildReadOnlyContainer(appointment),
//       ],
//     );
//   }

//   Widget _buildReadOnlyContainer(ReadOnlyAppointmentData appointment) {
//     final formattedDate = DateFormat('MMMM d, EEEE')
//         .format(appointment.appointmentDate.toLocal());
//     final formattedTime =
//         DateFormat.jm().format(appointment.appointmentDate.toLocal());

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Icon(
//                     Icons.close,
//                     size: 24,
//                     color: MyColors.colorPalette['on-surface'],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Text(
//                 formattedDate,
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['secondary']),
//               ),
//             ),
//             Text(
//               formattedTime,
//               style: MyTextStyle.textStyleMap['body-large']
//                   ?.copyWith(color: MyColors.colorPalette['primary']),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!appointmentsFetched) {
//       return const Center(child: CircularProgressIndicator());
//     } else if (appointments.isEmpty) {
//       return Center(
//         child: Text(
//           'No appointments available',
//           style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//             color: MyColors.colorPalette['on-surface-variant'],
//           ),
//         ),
//       );
//     } else {
//       return SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildAppointmentContainer(),
//           ],
//         ),
//       );
//     }
//   }
// }

// class ReadOnlyAppointmentData {
//   String appointmentId;
//   DateTime appointmentDate;
//   String slot;

//   ReadOnlyAppointmentData({
//     required this.appointmentId,
//     required this.appointmentDate,
//     required this.slot,
//   });
// }
