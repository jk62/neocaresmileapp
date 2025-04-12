import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as devtools show log;

import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

class AddEmptyNoteContainer extends StatefulWidget {
  final AddEmptyNoteContainerData data;
  final Future<void> Function(AddEmptyNoteContainerData) onSave;
  final VoidCallback onDelete; // Add this line

  const AddEmptyNoteContainer({
    super.key,
    required this.data,
    required this.onSave,
    required this.onDelete, // Add this line
  });

  @override
  State<AddEmptyNoteContainer> createState() => _AddEmptyNoteContainerState();
}

class _AddEmptyNoteContainerState extends State<AddEmptyNoteContainer> {
  late TextEditingController _doctorNoteController;
  late TextEditingController _q1Controller;
  late TextEditingController _q2Controller;
  late TextEditingController _q3Controller;
  late TextEditingController _q4Controller;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _doctorNoteController = TextEditingController(text: widget.data.doctorNote);
    _q1Controller = TextEditingController(text: widget.data.q1);
    _q2Controller = TextEditingController(text: widget.data.q2);
    _q3Controller = TextEditingController(text: widget.data.q3);
    _q4Controller = TextEditingController(text: widget.data.q4);

    if (isEditing) {
      _startEditingDoctorNote();
      _startEditingQuadrant(_q1Controller, widget.data.q1);
      _startEditingQuadrant(_q2Controller, widget.data.q2);
      _startEditingQuadrant(_q3Controller, widget.data.q3);
      _startEditingQuadrant(_q4Controller, widget.data.q4);
    }
  }

  @override
  void dispose() {
    if (isEditing) {
      _saveData();
    }
    super.dispose();
  }

  void _saveData() async {
    final editedData = AddEmptyNoteContainerData(
      doctorNote: _doctorNoteController.text,
      q1: _q1Controller.text,
      q2: _q2Controller.text,
      q3: _q3Controller.text,
      q4: _q4Controller.text,
    );
    devtools.log(
        'Welcome inside _saveData in AddEmptyNoteContainer. editedData is $editedData');
    await widget.onSave(editedData);
  }

  double calculateDoctorNoteContainerHeight(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double doctorNoteContainerHeight = (screenHeight / 8);
    return doctorNoteContainerHeight;
  }

  Widget _buildQuadrant(String text, TextEditingController controller,
      void Function(String) onChangedCallback, bool isEditing) {
    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width / 7 - 12.0,
        height: MediaQuery.of(context).size.height / 14 - 12.0,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: MyColors.colorPalette['on-surface'] ?? Colors.black,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: isEditing
              ? TextField(
                  textAlign: TextAlign.center,
                  controller: controller,
                  onChanged: onChangedCallback,
                  enabled: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16.0),
                  maxLines: null,
                )
              : Text(
                  text,
                  style: const TextStyle(fontSize: 16.0),
                ),
        ),
      ),
    );
  }

  void _startEditingQuadrant(
      TextEditingController controller, String initialText) {
    setState(() {
      controller.text = initialText;
    });
  }

  void _startEditingDoctorNote() {
    setState(() {
      _doctorNoteController.text = widget.data.doctorNote;
    });
  }

  @override
  Widget build(BuildContext context) {
    devtools.log('Welcome to AddEmptyNoteContainer');
    double doctorNoteContainerHeight =
        calculateDoctorNoteContainerHeight(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          isEditing = true;
          _startEditingDoctorNote();
          _startEditingQuadrant(_q1Controller, widget.data.q1);
          _startEditingQuadrant(_q2Controller, widget.data.q2);
          _startEditingQuadrant(_q3Controller, widget.data.q3);
          _startEditingQuadrant(_q4Controller, widget.data.q4);
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: doctorNoteContainerHeight,
                  maxHeight: doctorNoteContainerHeight,
                ),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: MyColors.colorPalette['on-surface'] ?? Colors.black,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              widget.onDelete(); // Call the onDelete callback
                            },
                            child: Icon(
                              Icons.close,
                              size: 24,
                              color: MyColors.colorPalette['on-surface'],
                            ),
                          ),
                          Text(
                            DateFormat('MMMM dd, EEEE').format(DateTime.now()),
                            style: MyTextStyle.textStyleMap['label-medium']
                                ?.copyWith(
                                    color: MyColors.colorPalette['outline']),
                          ),
                        ],
                      ),
                      isEditing
                          ? TextFormField(
                              controller: _doctorNoteController,
                              onChanged: (editedText) {
                                _doctorNoteController.text = editedText;
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(8.0),
                              ),
                              maxLines: null,
                              style: MyTextStyle.textStyleMap['label-large']
                                  ?.copyWith(
                                      color:
                                          MyColors.colorPalette['secondary']),
                            )
                          : Text(
                              widget.data.doctorNote,
                              style: MyTextStyle.textStyleMap['label-large']
                                  ?.copyWith(
                                      color:
                                          MyColors.colorPalette['secondary']),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildQuadrant(
                      widget.data.q1,
                      _q1Controller,
                      (editedText) {
                        _q1Controller.text = editedText;
                      },
                      isEditing,
                    ),
                    const SizedBox(width: 4),
                    _buildQuadrant(
                      widget.data.q2,
                      _q2Controller,
                      (editedText) {
                        _q2Controller.text = editedText;
                      },
                      isEditing,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildQuadrant(
                      widget.data.q3,
                      _q3Controller,
                      (editedText) {
                        _q3Controller.text = editedText;
                      },
                      isEditing,
                    ),
                    const SizedBox(width: 4),
                    _buildQuadrant(
                      widget.data.q4,
                      _q4Controller,
                      (editedText) {
                        _q4Controller.text = editedText;
                      },
                      isEditing,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddEmptyNoteContainerData {
  String doctorNote;
  String q1;
  String q2;
  String q3;
  String q4;

  AddEmptyNoteContainerData({
    required this.doctorNote,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
  });
}

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'dart:developer' as devtools show log;

// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class AddEmptyNoteContainer extends StatefulWidget {
//   final AddEmptyNoteContainerData data;
//   final Future<void> Function(AddEmptyNoteContainerData) onSave;

//   const AddEmptyNoteContainer({
//     super.key,
//     required this.data,
//     required this.onSave,
//   });

//   @override
//   State<AddEmptyNoteContainer> createState() => _AddEmptyNoteContainerState();
// }

// class _AddEmptyNoteContainerState extends State<AddEmptyNoteContainer> {
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

//     // Initialize editing state if needed
//     if (isEditing) {
//       _startEditingDoctorNote();
//       _startEditingQuadrant(_q1Controller, widget.data.q1);
//       _startEditingQuadrant(_q2Controller, widget.data.q2);
//       _startEditingQuadrant(_q3Controller, widget.data.q3);
//       _startEditingQuadrant(_q4Controller, widget.data.q4);
//     }
//   }

//   // @override
//   // void dispose() {
//   //   devtools.log('Welcome to dispose inside NotesTab');
//   //   // Dispose of controllers when the widget is disposed
//   //   _doctorNoteController.dispose();
//   //   _q1Controller.dispose();
//   //   _q2Controller.dispose();
//   //   _q3Controller.dispose();
//   //   _q4Controller.dispose();
//   //   super.dispose();
//   // }

//   @override
//   void dispose() {
//     if (isEditing) {
//       _saveData();
//     }
//     super.dispose();
//   }

//   void _saveData() async {
//     // Save the edited data
//     final editedData = AddEmptyNoteContainerData(
//       doctorNote: _doctorNoteController.text,
//       q1: _q1Controller.text,
//       q2: _q2Controller.text,
//       q3: _q3Controller.text,
//       q4: _q4Controller.text,
//     );
//     devtools.log(
//         'Welcome inside _saveData in AddEmptyNoteContainer. editedData is $editedData');
//     devtools.log('editedData is ${editedData.doctorNote}');
//     devtools.log('editedData is ${editedData.q1}');
//     devtools.log('editedData is ${editedData.q2}');
//     devtools.log('editedData is ${editedData.q3}');
//     devtools.log('editedData is ${editedData.q4}');
//     await widget.onSave(editedData);
//   }

//   //##########################################################################//
//   // START calculateDoctorNoteContainerHeight FUNCTION //
//   double calculateDoctorNoteContainerHeight(BuildContext context) {
//     // Get the screen height
//     double screenHeight = MediaQuery.of(context).size.height;
//     double doctorNoteContainerHeight = (screenHeight / 8);
//     return doctorNoteContainerHeight;
//   }
//   // END calculateDoctorNoteContainerHeight FUNCTION //
//   //##########################################################################//
//   //
//   //##########################################################################//
//   // START _buildQuadrant FUNCTION //

//   Widget _buildQuadrant(String text, TextEditingController controller,
//       void Function(String) onChangedCallback, bool isEditing) {
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
//                   enabled: true,
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                   ),
//                   style: const TextStyle(fontSize: 16.0),
//                   maxLines: null,
//                 )
//               : Text(
//                   text,
//                   style: const TextStyle(fontSize: 16.0),
//                 ),
//         ),
//       ),
//     );
//   }

//   // END _buildQuadrant FUNCTION //
//   //##########################################################################//
//   //
//   //##########################################################################//
//   // START _startEditingQuadrant FUNCTION //
//   void _startEditingQuadrant(
//       TextEditingController controller, String initialText) {
//     setState(() {
//       controller.text = initialText;
//     });
//   }

//   // END _startEditingQuadrant FUNCTION //
//   //##########################################################################//
//   //
//   //##########################################################################//
//   // START _startEditingDoctorNote FUNCTION //
//   void _startEditingDoctorNote() {
//     setState(() {
//       _doctorNoteController.text = widget.data.doctorNote;
//     });
//   }
//   // END _startEditingDoctorNote FUNCTION //
//   //##########################################################################//

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to AddEmptyNoteContainer');
//     double doctorNoteContainerHeight =
//         calculateDoctorNoteContainerHeight(context);

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           isEditing = true;
//           _startEditingDoctorNote();
//           _startEditingQuadrant(_q1Controller, widget.data.q1);
//           _startEditingQuadrant(_q2Controller, widget.data.q2);
//           _startEditingQuadrant(_q3Controller, widget.data.q3);
//           _startEditingQuadrant(_q4Controller, widget.data.q4);
//         });
//       },
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Doctor's Note Container
//           Expanded(
//             child: Padding(
//               //padding: const EdgeInsets.all(8),
//               padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//               child: Container(
//                 width: double.infinity, // Take the remaining space
//                 constraints: BoxConstraints(
//                   minHeight: doctorNoteContainerHeight,
//                   maxHeight: doctorNoteContainerHeight,
//                 ),
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     //color: Colors.grey,
//                     color: MyColors.colorPalette['on-surface'] ?? Colors.black,
//                     width: 1.0,
//                     style: BorderStyle.solid,
//                   ),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Display 'X' icon and date in the top row
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // DECISION PENDING ABOUT THIS
//                           GestureDetector(
//                             onTap: () async {
//                               // Add your delete operation here
//                             },
//                             child: Icon(
//                               Icons.close,
//                               size: 24,
//                               color: MyColors
//                                   .colorPalette['on-surface'], //Colors.black,
//                             ),
//                           ),
//                           Text(
//                             DateFormat('MMMM dd, EEEE').format(DateTime.now()),
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['outline']),
//                           ),
//                         ],
//                       ),
//                       isEditing
//                           ? TextFormField(
//                               controller: _doctorNoteController,
//                               onChanged: (editedText) {
//                                 // Update the doctor's note controller
//                                 _doctorNoteController.text = editedText;
//                               },
//                               decoration: const InputDecoration(
//                                 border: InputBorder.none,
//                                 //hintText: 'Enter doctor\'s note here',
//                                 contentPadding: EdgeInsets.all(8.0),
//                               ),
//                               maxLines: null, // Allow multiple lines of text
//                               style: MyTextStyle.textStyleMap['label-large']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['secondary']),
//                             )
//                           : Text(
//                               widget.data.doctorNote,
//                               //style: const TextStyle(fontSize: 16.0),
//                               style: MyTextStyle.textStyleMap['label-large']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['secondary']),
//                             ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Quadrants
//           Padding(
//             padding: const EdgeInsets.only(top: 8, left: 8.0),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Quadrant 1
//                     _buildQuadrant(
//                       widget.data.q1,
//                       _q1Controller,
//                       (editedText) {
//                         _q1Controller.text = editedText;
//                       },
//                       isEditing,
//                     ),
//                     const SizedBox(width: 4),

//                     // Quadrant 2
//                     _buildQuadrant(
//                       widget.data.q2,
//                       _q2Controller,
//                       (editedText) {
//                         _q2Controller.text = editedText;
//                       },
//                       isEditing,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     // Quadrant 3
//                     _buildQuadrant(
//                       widget.data.q3,
//                       _q3Controller,
//                       (editedText) {
//                         _q3Controller.text = editedText;
//                       },
//                       isEditing,
//                     ),
//                     const SizedBox(width: 4),

//                     // Quadrant 4
//                     _buildQuadrant(
//                       widget.data.q4,
//                       _q4Controller,
//                       (editedText) {
//                         _q4Controller.text = editedText;
//                       },
//                       isEditing,
//                     ),
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

// class AddEmptyNoteContainerData {
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;

//   AddEmptyNoteContainerData({
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//   });
// }
