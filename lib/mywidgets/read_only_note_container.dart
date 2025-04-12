// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class ReadOnlyNoteContainer extends StatelessWidget {
//   final AddEmptyContainerData data;
//   final double containerHeight;

//   const ReadOnlyNoteContainer({
//     Key? key,
//     required this.containerHeight,
//     required this.data,
//   }) : super(key: key);

//   double calculateDoctorNoteContainerHeight(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     return (screenHeight / 8);
//   }

//   Widget _buildQuadrant(BuildContext context, String text) {
//     return GestureDetector(
//       child: Container(
//         width: MediaQuery.of(context).size.width / 7 - 12.0,
//         height: MediaQuery.of(context).size.height / 14 - 12.0,
//         decoration: BoxDecoration(
//           border: Border.all(
//             width: 1,
//             color:
//                 MyColors.colorPalette['on-surface'] ?? const Color(0xFF011718),
//           ),
//           borderRadius: BorderRadius.circular(5.0),
//         ),
//         child: Center(
//           child: Text(
//             text,
//             textAlign: TextAlign.center,
//             style: MyTextStyle.textStyleMap['title-Medium']
//                 ?.copyWith(color: MyColors.colorPalette['secondary']),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double doctorNoteContainerHeight =
//         calculateDoctorNoteContainerHeight(context);

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8),
//             child: Container(
//               width: double.infinity,
//               constraints: BoxConstraints(
//                 minHeight: doctorNoteContainerHeight,
//                 maxHeight: doctorNoteContainerHeight,
//               ),
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   width: 1,
//                   color: MyColors.colorPalette['on-surface'] ??
//                       const Color(0xFF011718),
//                 ),
//                 borderRadius: BorderRadius.circular(5.0),
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Icon(
//                         //   Icons.close,
//                         //   size: 24,
//                         //   color: MyColors.colorPalette[
//                         //       'on-surface'], // Adjust the color as needed
//                         // ),
//                         Text(
//                           data.timestamp,
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['outline']),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       data.doctorNote,
//                       style: MyTextStyle.textStyleMap['label-large']
//                           ?.copyWith(color: MyColors.colorPalette['secondary']),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 8, right: 8.0, left: 8.0),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   _buildQuadrant(context, data.q1),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(context, data.q2),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   _buildQuadrant(context, data.q3),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(context, data.q4),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class AddEmptyContainerData {
//   String id;
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;
//   String timestamp; // Add this line

//   AddEmptyContainerData({
//     required this.id,
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//     required this.timestamp, // Add this line
//   });
// }



// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class ReadOnlyNoteContainer extends StatelessWidget {
//   final AddEmptyContainerData data;
//   final double containerHeight;

//   const ReadOnlyNoteContainer({
//     Key? key,
//     required this.containerHeight,
//     required this.data,
//   }) : super(key: key);

//   double calculateDoctorNoteContainerHeight(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     return (screenHeight / 8);
//   }

//   Widget _buildQuadrant(BuildContext context, String text) {
//     return GestureDetector(
//       child: Container(
//         width: MediaQuery.of(context).size.width / 7 - 12.0,
//         height: MediaQuery.of(context).size.height / 14 - 12.0,
//         decoration: BoxDecoration(
//           border: Border.all(
//             width: 1,
//             color:
//                 MyColors.colorPalette['on-surface'] ?? const Color(0xFF011718),
//           ),
//           borderRadius: BorderRadius.circular(5.0),
//         ),
//         child: Center(
//           child: Text(
//             text,
//             textAlign: TextAlign.center,
//             style: MyTextStyle.textStyleMap['title-Medium']
//                 ?.copyWith(color: MyColors.colorPalette['secondary']),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double doctorNoteContainerHeight =
//         calculateDoctorNoteContainerHeight(context);

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8),
//             child: Container(
//               width: double.infinity,
//               constraints: BoxConstraints(
//                 minHeight: doctorNoteContainerHeight,
//                 maxHeight: doctorNoteContainerHeight,
//               ),
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   width: 1,
//                   color: MyColors.colorPalette['on-surface'] ??
//                       const Color(0xFF011718),
//                 ),
//                 borderRadius: BorderRadius.circular(5.0),
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(),
//                       ],
//                     ),
//                     Text(
//                       data.doctorNote,
//                       style: MyTextStyle.textStyleMap['label-large']
//                           ?.copyWith(color: MyColors.colorPalette['secondary']),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 8, right: 8.0, left: 8.0),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   _buildQuadrant(context, data.q1),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(context, data.q2),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   _buildQuadrant(context, data.q3),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(context, data.q4),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class AddEmptyContainerData {
//   String id;
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;

//   AddEmptyContainerData({
//     required this.id,
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//   });
// }
