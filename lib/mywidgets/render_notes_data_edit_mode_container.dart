// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/notes_data_model.dart'; //import 'package:neocare_dental_app/mywidgets/notes_tab.dart';
// import 'dart:developer' as devtools show log;

// class RenderNotesDataEditModeContainer extends StatefulWidget {
//   final NotesDataModel data;
//   final Future<void> Function(String, NotesDataModel) onEdit;
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;
//   final VoidCallback onDeleteNote;

//   const RenderNotesDataEditModeContainer({
//     super.key,
//     required this.data,
//     required this.onEdit,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//     required this.onDeleteNote,
//   });

//   @override
//   State<RenderNotesDataEditModeContainer> createState() =>
//       _RenderNotesDataEditModeContainerState();
// }

// class _RenderNotesDataEditModeContainerState
//     extends State<RenderNotesDataEditModeContainer> {
//   late TextEditingController _doctorNoteController;
//   late TextEditingController _q1Controller;
//   late TextEditingController _q2Controller;
//   late TextEditingController _q3Controller;
//   late TextEditingController _q4Controller;

//   bool isEditing = false;

//   @override
//   void initState() {
//     super.initState();
//     _doctorNoteController = TextEditingController(text: widget.data.doctorNote);
//     _q1Controller = TextEditingController(text: widget.data.q1);
//     _q2Controller = TextEditingController(text: widget.data.q2);
//     _q3Controller = TextEditingController(text: widget.data.q3);
//     _q4Controller = TextEditingController(text: widget.data.q4);

//     if (isEditing) {
//       // if (widget.isEditing) {
//       _startEditingDoctorNote();
//       _startEditingQuadrant(_q1Controller, widget.data.q1);
//       _startEditingQuadrant(_q2Controller, widget.data.q2);
//       _startEditingQuadrant(_q3Controller, widget.data.q3);
//       _startEditingQuadrant(_q4Controller, widget.data.q4);
//     }
//   }

//   @override
//   void dispose() {
//     if (isEditing) {
//       _saveData();
//     }
//     super.dispose();
//   }

//   void _startEditingDoctorNote() {
//     setState(() {
//       _doctorNoteController.text = widget.data.doctorNote;
//     });
//   }

//   void _saveData() async {
//     devtools
//         .log('Welcome to _saveData inside RenderNotesDataEditModeContainer');
//     // Save the edited data
//     final editedData = NotesDataModel(
//       noteId: widget.data.noteId,
//       doctorNote: _doctorNoteController.text,
//       q1: _q1Controller.text,
//       q2: _q2Controller.text,
//       q3: _q3Controller.text,
//       q4: _q4Controller.text,
//       timestamp: widget.data.timestamp,
//     );
//     devtools.log('editedData is $editedData');

//     // Call the onEdit callback
//     await widget.onEdit(_doctorNoteController.text, editedData);

//     // Optionally, you can reset the editing state
//     Future.microtask(() {
//       if (mounted) {
//         setState(() {});
//       }
//     });
//   }

//   double calculateDoctorNoteContainerHeight(BuildContext context) {
//     // Get the screen height
//     double screenHeight = MediaQuery.of(context).size.height;
//     double doctorNoteContainerHeight = (screenHeight / 8);
//     return doctorNoteContainerHeight;
//   }

//   Widget _buildQuadrant(String text, TextEditingController controller,
//       void Function(String) onChangedCallback) {
//     return GestureDetector(
//       child: Container(
//         width: MediaQuery.of(context).size.width / 7 - 12.0,
//         height: MediaQuery.of(context).size.height / 14 - 12.0,
//         decoration: BoxDecoration(
//           border: Border.all(
//             width: 1,
//             color: MyColors.colorPalette['on-surface'] ?? Colors.black,
//           ),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         child: Center(
//           child: isEditing
//               ? TextField(
//                   textAlign: TextAlign.center,
//                   controller: controller,
//                   onChanged: onChangedCallback,
//                   enabled: true, // Always enabled in edit mode
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                   ),
//                   style: const TextStyle(fontSize: 16.0),
//                   maxLines: null, // Allow unlimited lines
//                 )
//               : Text(
//                   text,
//                   style: const TextStyle(fontSize: 16.0),
//                 ),
//         ),
//       ),
//     );
//   }

//   void _startEditingQuadrant(
//       TextEditingController controller, String initialText) {
//     setState(() {
//       controller.text = initialText;
//     });
//   }

//   // IDEALLY deleteNoteFromBackend SHOULD STAY INSIDE NOTES TAB
//   // BEST PRACTICE IS TO KEEP THE UI LOGIC AND BUSINESS LOGIC SEPARATE
//   // IT WILL BE SHIFTED BACK TO NOTES TAB LATER AND WILL BE USED AS A CALLBACK FUCNTION LATER
//   Future<void> deleteNoteFromBackend(String noteId) async {
//     try {
//       final clinicId = widget.clinicId;
//       final patientId = widget.patientId;
//       final treatmentId = widget.treatmentId;

//       // Reference to the notes sub-collection and the specific note document
//       final noteRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId)
//           .collection('treatments')
//           .doc(treatmentId)
//           .collection('notes')
//           .doc(noteId);

//       // Delete the note document from Firestore
//       await noteRef.delete();

//       devtools.log('Note deleted from the backend successfully');
//     } catch (e) {
//       devtools.log('Error deleting note data: $e');
//     }
//   }

//   // Add this function to notify the parent about the deletion
//   void _notifyParentAboutDeletion() {
//     widget.onDeleteNote();
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to RenderNotesDataEditModeContainer');
//     double doctorNoteContainerHeight =
//         calculateDoctorNoteContainerHeight(context);

//     return GestureDetector(
//       onTap: () {
//         isEditing = true;
//         if (isEditing) {
//           _startEditingDoctorNote();
//           _startEditingQuadrant(_q1Controller, widget.data.q1);
//           _startEditingQuadrant(_q2Controller, widget.data.q2);
//           _startEditingQuadrant(_q3Controller, widget.data.q3);
//           _startEditingQuadrant(_q4Controller, widget.data.q4);
//         }
//       },
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Padding(
//               //padding: const EdgeInsets.all(8),
//               padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//               child: GestureDetector(
//                 child: Container(
//                   width: double.infinity,
//                   constraints: BoxConstraints(
//                     minHeight: doctorNoteContainerHeight,
//                     maxHeight: doctorNoteContainerHeight,
//                   ),
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color:
//                           MyColors.colorPalette['on-surface'] ?? Colors.black,
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
//                           GestureDetector(
//                             onTap: () async {
//                               // Add your delete operation here
//                               devtools.log('Delete operation triggered');
//                               await deleteNoteFromBackend(widget.data.noteId);
//                               _notifyParentAboutDeletion();
//                             },
//                             child: Icon(
//                               Icons.close,
//                               size: 24,
//                               color: MyColors
//                                   .colorPalette['on-surface'], //Colors.black,
//                             ),
//                           ),
//                           Text(
//                             widget.data.timestamp,
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['outline']),
//                           ),
//                         ],
//                       ),
//                       Expanded(
//                         child: isEditing
//                             ? TextField(
//                                 controller: _doctorNoteController,
//                                 onChanged: (editedText) {
//                                   // Update the doctor's note controller
//                                   _doctorNoteController.text = editedText;
//                                   devtools.log(
//                                       '_doctorNoteController.text is ${_doctorNoteController.text}');
//                                 },
//                                 decoration: const InputDecoration(
//                                   border: InputBorder.none,
//                                 ),
//                                 //style: const TextStyle(fontSize: 16.0),
//                                 style: MyTextStyle.textStyleMap['label-large']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary']),
//                                 maxLines: null,
//                               )
//                             : Text(
//                                 widget.data.doctorNote,
//                                 //style: const TextStyle(fontSize: 16.0),
//                                 style: MyTextStyle.textStyleMap['label-large']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary']),
//                               ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 8, left: 8.0),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Quadrant 1
//                     _buildQuadrant(widget.data.q1, _q1Controller, (editedText) {
//                       _q1Controller.text = editedText;
//                       devtools
//                           .log('_q1Controller.text is ${_q1Controller.text}');
//                     }),

//                     // Quadrant 2
//                     _buildQuadrant(widget.data.q2, _q2Controller, (editedText) {
//                       _q2Controller.text = editedText;
//                     }),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Quadrant 3
//                     _buildQuadrant(widget.data.q3, _q3Controller, (editedText) {
//                       _q3Controller.text = editedText;
//                     }),

//                     // Quadrant 4
//                     _buildQuadrant(widget.data.q4, _q4Controller, (editedText) {
//                       _q4Controller.text = editedText;
//                     }),
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
