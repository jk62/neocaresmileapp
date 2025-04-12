// import 'package:flutter/material.dart';

// class EditableNoteContainer extends StatefulWidget {
//   final Map<String, dynamic> noteData;
//   //final Function(Map<String, dynamic> updatedData) onSave;
//   //final Future<void> Function(Map<String, dynamic> updatedData) onSave;
//   final Function() onSave;

//   const EditableNoteContainer({
//     Key? key,
//     required this.noteData,
//     required this.onSave,
//   }) : super(key: key);

//   @override
//   State<EditableNoteContainer> createState() => _EditableNoteContainerState();
// }

// class _EditableNoteContainerState extends State<EditableNoteContainer> {
//   late TextEditingController doctorNoteController;
//   late TextEditingController q1Controller;
//   late TextEditingController q2Controller;
//   late TextEditingController q3Controller;
//   late TextEditingController q4Controller;

//   @override
//   void initState() {
//     super.initState();

//     doctorNoteController =
//         TextEditingController(text: widget.noteData['doctorNote']);
//     q1Controller = TextEditingController(text: widget.noteData['q1']);
//     q2Controller = TextEditingController(text: widget.noteData['q2']);
//     q3Controller = TextEditingController(text: widget.noteData['q3']);
//     q4Controller = TextEditingController(text: widget.noteData['q4']);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Display 'X' icon and date in the top row
//         Padding(
//           padding: const EdgeInsets.only(bottom: 8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'X',
//                 style: TextStyle(
//                   // Adjust the style as needed
//                   color: Colors.red,
//                   fontSize: 20.0,
//                 ),
//               ),
//               Text(
//                 widget.noteData['timestamp'] ?? '',
//                 // You might want to format the timestamp as needed
//                 style: const TextStyle(
//                   // Adjust the style as needed
//                   color: Colors.black,
//                   fontSize: 14.0,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // Editable doctor's note
//         TextField(
//           controller: doctorNoteController,
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             labelText: 'Doctor\'s Note',
//           ),
//         ),
//         // Editable quadrants
//         TextField(
//           controller: q1Controller,
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             labelText: 'Quadrant 1',
//           ),
//         ),
//         TextField(
//           controller: q2Controller,
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             labelText: 'Quadrant 2',
//           ),
//         ),
//         TextField(
//           controller: q3Controller,
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             labelText: 'Quadrant 3',
//           ),
//         ),
//         TextField(
//           controller: q4Controller,
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             labelText: 'Quadrant 4',
//           ),
//         ),
//         // Save button
//         ElevatedButton(
//           onPressed: () {
//             // Get updated data from controllers
//             final updatedData = {
//               'doctorNote': doctorNoteController.text,
//               'q1': q1Controller.text,
//               'q2': q2Controller.text,
//               'q3': q3Controller.text,
//               'q4': q4Controller.text,
//             };

//             // Call the onSave callback with updated data
//             // widget.onSave(updatedData);
//             widget.onSave();
//           },
//           child: const Text('Save'),
//         ),
//       ],
//     );
//   }
// }
