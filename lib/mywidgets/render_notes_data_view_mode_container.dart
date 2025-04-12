// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/render_notes_data_container.dart';
// import 'dart:developer' as devtools show log;

// class RenderNotesDataViewModeContainer extends StatefulWidget {
//   final NotesDataModel data;
//   final VoidCallback onEdit;

//   const RenderNotesDataViewModeContainer({
//     Key? key,
//     required this.data,
//     required this.onEdit,
//   }) : super(key: key);

//   @override
//   State<RenderNotesDataViewModeContainer> createState() =>
//       _RenderNotesDataViewModeContainerState();
// }

// class _RenderNotesDataViewModeContainerState
//     extends State<RenderNotesDataViewModeContainer> {
//   bool _isEditing = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   double calculateDoctorNoteContainerHeight(BuildContext context) {
//     // Get the screen height
//     double screenHeight = MediaQuery.of(context).size.height;
//     double doctorNoteContainerHeight = (screenHeight / 8);
//     return doctorNoteContainerHeight;
//   }

//   Widget _buildQuadrant(String text) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           widget.onEdit(); // Notify the parent widget about the edit
//           devtools.log('quadrant container tapped.');
//         });
//       },
//       child: Container(
//         width: MediaQuery.of(context).size.width / 7 - 12.0,
//         height: MediaQuery.of(context).size.height / 14 - 12.0,
//         decoration: BoxDecoration(
//           border: Border.all(
//             width: 1,
//             color: MyColors.colorPalette['on-surface']!,
//           ),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         child: Center(
//           child: Text(
//             text,
//             style: const TextStyle(fontSize: 16.0),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double doctorNoteContainerHeight =
//         calculateDoctorNoteContainerHeight(context);

//     return GestureDetector(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Doctor's Note Container
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8),
//               child: GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     widget.onEdit(); // Notify the parent widget about the edit
//                     devtools.log('doctor note container tapped.');
//                   });
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   constraints: BoxConstraints(
//                     minHeight: doctorNoteContainerHeight,
//                     maxHeight: doctorNoteContainerHeight,
//                   ),
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Colors.grey,
//                       width: 1.0,
//                       style: BorderStyle.solid,
//                     ),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'X',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['secondary']),
//                           ),
//                           Text(
//                             widget.data.timestamp,
//                             style: MyTextStyle.textStyleMap['label-small']
//                                 ?.copyWith(
//                                     color: MyColors
//                                         .colorPalette['on-surface-variant']),
//                           ),
//                         ],
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 12.0),
//                           child: Text(
//                             widget.data.doctorNote,
//                             style: const TextStyle(fontSize: 16.0),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.only(top: 8, right: 8.0, left: 8.0),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Quadrant 1
//                     _buildQuadrant(widget.data.q1),

//                     // Quadrant 2
//                     _buildQuadrant(widget.data.q2),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Quadrant 3
//                     _buildQuadrant(widget.data.q3),

//                     // Quadrant 4
//                     _buildQuadrant(widget.data.q4),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// code below is stable
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/render_notes_data_container.dart';
// import 'dart:developer' as devtools show log;

// class RenderNotesDataViewModeContainer extends StatefulWidget {
//   final NotesDataModel data;

//   const RenderNotesDataViewModeContainer({
//     Key? key,
//     required this.data,
//   }) : super(key: key);

//   @override
//   State<RenderNotesDataViewModeContainer> createState() =>
//       _RenderNotesDataViewModeContainerState();
// }

// class _RenderNotesDataViewModeContainerState
//     extends State<RenderNotesDataViewModeContainer> {
//   late TextEditingController _doctorNoteController;
//   late TextEditingController _q1Controller;
//   late TextEditingController _q2Controller;
//   late TextEditingController _q3Controller;
//   late TextEditingController _q4Controller;
//   bool _isEditing = false;

//   @override
//   void initState() {
//     super.initState();
//     _doctorNoteController = TextEditingController(text: widget.data.doctorNote);
//     _q1Controller = TextEditingController(text: widget.data.q1);
//     _q2Controller = TextEditingController(text: widget.data.q2);
//     _q3Controller = TextEditingController(text: widget.data.q3);
//     _q4Controller = TextEditingController(text: widget.data.q4);
//   }

//   double calculateDoctorNoteContainerHeight(BuildContext context) {
//     // Get the screen height
//     double screenHeight = MediaQuery.of(context).size.height;
//     double doctorNoteContainerHeight = (screenHeight / 8);
//     return doctorNoteContainerHeight;
//   }

//   Widget _buildQuadrant(String text, TextEditingController controller) {
//     return GestureDetector(
//       onTap: () {
//         // Trigger inline editing for the corresponding quadrant
//         _startEditingQuadrant(controller, text);
//       },
//       child: Container(
//         width: MediaQuery.of(context).size.width / 7 - 12.0,
//         height: MediaQuery.of(context).size.height / 14 - 12.0,
//         decoration: BoxDecoration(
//           border: Border.all(
//             width: 1,
//             color: MyColors.colorPalette['on-surface']!,
//           ),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         child: Center(
//           child: TextField(
//             controller: controller,
//             onChanged: (editedText) {
//               // Update the quadrant text in the parent widget if needed
//               // You can add additional logic here if necessary
//             },
//             enabled: _isEditing, // Use the enabled property
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//             ),
//             style: const TextStyle(fontSize: 16.0),
//             maxLines: null, // Allow unlimited lines
//           ),
//         ),
//       ),
//     );
//   }

//   void _startEditingDoctorNote() {
//     setState(() {
//       _doctorNoteController.text = widget.data.doctorNote;
//       _isEditing = true; // Add this line to track editing state
//     });
//   }

//   void _startEditingQuadrant(
//       TextEditingController controller, String initialText) {
//     setState(() {
//       controller.text = initialText;
//       _isEditing = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to RenderNotesDataViewModeContainer');

//     double doctorNoteContainerHeight =
//         calculateDoctorNoteContainerHeight(context);

//     return GestureDetector(
      
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Doctor's Note Container
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8),
//               child: GestureDetector(
//                 onTap: () {
//                   // Trigger inline editing for doctor's note
//                   _startEditingDoctorNote();
//                 },
//                 child: Container(
//                   width: double.infinity, // Take the remaining space
//                   constraints: BoxConstraints(
//                     minHeight: doctorNoteContainerHeight,
//                     maxHeight: doctorNoteContainerHeight,
//                   ),
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Colors.grey,
//                       width: 1.0,
//                       style: BorderStyle.solid,
//                     ),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Display 'X' icon and date in the top row
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'X',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['secondary']),
//                           ),
//                           Text(
//                             widget.data.timestamp,
//                             style: MyTextStyle.textStyleMap['label-small']
//                                 ?.copyWith(
//                                     color: MyColors
//                                         .colorPalette['on-surface-variant']),
//                           ),
//                         ],
//                       ),

//                       // Display editable doctor's note
//                       Expanded(
//                         child: TextField(
//                           controller: _doctorNoteController,
//                           onChanged: (editedText) {
                            
//                           },
//                           // readOnly: true,
//                           enabled: _isEditing, // Use the enabled property
//                           decoration: const InputDecoration(
//                             border: InputBorder.none,
//                           ),
//                           style: const TextStyle(fontSize: 16.0),
//                           maxLines: null, // Allow unlimited lines
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // //Spacer
//           // const SizedBox(width: 8.0),

//           Padding(
//             padding: const EdgeInsets.only(top: 8, right: 8.0, left: 8.0),
//             child: Column(
//               //mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjusted
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end, // Adjusted
//                   //mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjusted
//                   children: [
//                     // Quadrant 1
//                     //_buildQuadrant(widget.data.q1),
//                     _buildQuadrant(widget.data.q1, _q1Controller),

//                     // Quadrant 2
//                     //_buildQuadrant(widget.data.q2),
//                     _buildQuadrant(widget.data.q2, _q2Controller),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end, // Adjusted
//                   //mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjusted
//                   children: [
//                     // Quadrant 3
//                     //_buildQuadrant(widget.data.q3),
//                     _buildQuadrant(widget.data.q3, _q3Controller),

//                     // Quadrant 4
//                     //_buildQuadrant(widget.data.q4),
//                     _buildQuadrant(widget.data.q4, _q4Controller),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
