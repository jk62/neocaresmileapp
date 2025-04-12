// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class RenderTreatmentDataContainer extends StatefulWidget {
//   final TreatmentDataModel data;

//   const RenderTreatmentDataContainer({
//     Key? key,
//     required this.data,
//   }) : super(key: key);

//   @override
//   State<RenderTreatmentDataContainer> createState() =>
//       _RenderTreatmentDataContainerState();
// }

// class _RenderTreatmentDataContainerState
//     extends State<RenderTreatmentDataContainer> {
//   @override
//   Widget build(BuildContext context) {
//     // Calculate the size for the quadrants based on height
//     final double quadrantSize = MediaQuery.of(context).size.height / 14 - 12.0;

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Doctor's Note Container
//         Expanded(
//           flex: 6,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (widget.data.procedureName.isNotEmpty)
//                 Text(
//                   widget.data.procedureName,
//                   style: MyTextStyle.textStyleMap['label-large']
//                       ?.copyWith(color: MyColors.colorPalette['outline']),
//                 ),
//               const SizedBox(height: 8.0),
//               SingleChildScrollView(
//                 child: Text(
//                   widget.data.doctorNote,
//                   style: MyTextStyle.textStyleMap['label-large']
//                       ?.copyWith(color: MyColors.colorPalette['secondary']),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Spacer
//         const SizedBox(width: 16.0),

//         // Quadrant Containers
//         Column(
//           children: [
//             Row(
//               children: [
//                 _buildQuadrant(widget.data.q1, quadrantSize),
//                 const SizedBox(width: 4.0),
//                 _buildQuadrant(widget.data.q2, quadrantSize),
//               ],
//             ),
//             const SizedBox(height: 4.0),
//             Row(
//               children: [
//                 _buildQuadrant(widget.data.q3, quadrantSize),
//                 const SizedBox(width: 4.0),
//                 _buildQuadrant(widget.data.q4, quadrantSize),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildQuadrant(String text, double size) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         border: Border.all(
//           width: 1,
//           color: MyColors.colorPalette['on-surface']!,
//         ),
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Center(
//         child: Text(
//           text,
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['secondary']),
//         ),
//       ),
//     );
//   }
// }

// class TreatmentDataModel {
//   final String doctorNote;
//   final String q1;
//   final String q2;
//   final String q3;
//   final String q4;
//   final String procedureName;

//   TreatmentDataModel({
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//     required this.procedureName,
//   });
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class RenderTreatmentDataContainer extends StatefulWidget {
//   final TreatmentDataModel data;

//   const RenderTreatmentDataContainer({
//     Key? key,
//     required this.data,
//   }) : super(key: key);

//   @override
//   State<RenderTreatmentDataContainer> createState() =>
//       _RenderTreatmentDataContainerState();
// }

// class _RenderTreatmentDataContainerState
//     extends State<RenderTreatmentDataContainer> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Doctor's Note Container
//         Expanded(
//           flex: 6,
//           child: Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (widget.data.procedureName.isNotEmpty)
//                   Text(
//                     widget.data.procedureName,
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['outline']),
//                   ),
//                 const SizedBox(height: 8.0),
//                 SingleChildScrollView(
//                   child: Text(
//                     widget.data.doctorNote,
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['secondary']),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Spacer
//         const SizedBox(width: 16.0),

//         // Quadrant Containers
//         Expanded(
//           flex: 4,
//           child: Padding(
//             padding: const EdgeInsets.only(right: 4.0),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildQuadrant(widget.data.q1),
//                     _buildQuadrant(widget.data.q2),
//                   ],
//                 ),
//                 const SizedBox(height: 4.0),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildQuadrant(widget.data.q3),
//                     _buildQuadrant(widget.data.q4),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQuadrant(String text) {
//     return Container(
//       width: MediaQuery.of(context).size.width / 7 - 12.0,
//       height: MediaQuery.of(context).size.height / 14 - 12.0,
//       decoration: BoxDecoration(
//         border: Border.all(
//           width: 1,
//           color: MyColors.colorPalette['on-surface']!,
//         ),
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Center(
//         child: Text(
//           text,
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['secondary']),
//         ),
//       ),
//     );
//   }
// }

// class TreatmentDataModel {
//   final String doctorNote;
//   final String q1;
//   final String q2;
//   final String q3;
//   final String q4;
//   final String procedureName;

//   TreatmentDataModel({
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//     required this.procedureName,
//   });
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW IS STABLE WITH GRID VIEW TO DRAW QUADRANTS
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class RenderTreatmentDataContainer extends StatefulWidget {
//   final TreatmentDataModel data;
//   final double containerHeight;

//   const RenderTreatmentDataContainer({
//     Key? key,
//     required this.containerHeight,
//     required this.data,
//   }) : super(key: key);

//   @override
//   State<RenderTreatmentDataContainer> createState() =>
//       _RenderTreatmentDataContainerState();
// }

// class _RenderTreatmentDataContainerState
//     extends State<RenderTreatmentDataContainer> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // Doctor's Note Container
//         Expanded(
//           flex: 6, // Adjust flex as needed (60% of the width)
//           child: SizedBox(
//             height: widget.containerHeight,
//             child: Column(
//               children: [
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 16.0, top: 16.0),
//                     child: Text(
//                       widget.data.procedureName,
//                       style: MyTextStyle.textStyleMap['label-large']
//                           ?.copyWith(color: MyColors.colorPalette['outline']),
//                     ),
//                   ),
//                 ),
//                 //const SizedBox(height: 8.0),
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 16.0),
//                     child: SingleChildScrollView(
//                       child: Text(
//                         widget.data.doctorNote,
//                         style: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['secondary']),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Spacer
//         const SizedBox(width: 16.0),

//         // Quadrant Containers
//         Expanded(
//           flex: 4, // Adjust flex as needed (40% of the width)
//           child: Padding(
//             padding: const EdgeInsets.only(right: 16.0),
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 4.0,
//                 mainAxisSpacing: 4.0,
//               ),
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: 4,
//               itemBuilder: (context, index) {
//                 return Container(
//                   height: widget.containerHeight, // Fixed height for quadrants

//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color: MyColors.colorPalette['on-surface'] ??
//                           Colors.blueAccent,
//                       //color: Colors.blueAccent,
//                     ),
//                     borderRadius: BorderRadius.circular(5),
//                   ),

//                   child: Center(
//                     child: Text(
//                       // Display quadrant data here based on index
//                       index == 0
//                           ? widget.data.q1
//                           : index == 1
//                               ? widget.data.q2
//                               : index == 2
//                                   ? widget.data.q3
//                                   : widget.data.q4,
//                       //style: const TextStyle(fontSize: 16.0),
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                           color: MyColors.colorPalette['secondaary']),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }



// class TreatmentDataModel {
//   final String doctorNote;
//   final String q1;
//   final String q2;
//   final String q3;
//   final String q4;
//   final String procedureName; // Add this field

//   TreatmentDataModel({
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//     required this.procedureName, // Initialize this field
//   });
// }
