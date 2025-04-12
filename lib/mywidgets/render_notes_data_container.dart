import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

class RenderNotesDataContainer extends StatefulWidget {
  final NotesDataModel data;

  final Future<void> Function(String, NotesDataModel)? onEdit;

  const RenderNotesDataContainer({
    Key? key,
    required this.data,
    this.onEdit,
  }) : super(key: key);

  @override
  State<RenderNotesDataContainer> createState() =>
      _RenderNotesDataContainerState();
}

class _RenderNotesDataContainerState extends State<RenderNotesDataContainer> {
  late TextEditingController _doctorNoteController;
  late TextEditingController _q1Controller;
  late TextEditingController _q2Controller;
  late TextEditingController _q3Controller;
  late TextEditingController _q4Controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _doctorNoteController = TextEditingController(text: widget.data.doctorNote);
    _q1Controller = TextEditingController(text: widget.data.q1);
    _q2Controller = TextEditingController(text: widget.data.q2);
    _q3Controller = TextEditingController(text: widget.data.q3);
    _q4Controller = TextEditingController(text: widget.data.q4);
  }

  void _startEditingDoctorNote() {
    setState(() {
      _doctorNoteController.text = widget.data.doctorNote;
      _isEditing = true; // Add this line to track editing state
    });
  }

  void _saveData() {
    // Check if onSave is provided before calling it
    if (widget.onEdit != null) {
      widget.onEdit!(
        _doctorNoteController.text,
        NotesDataModel(
          doctorNote: _doctorNoteController.text,
          q1: _q1Controller.text,
          q2: _q2Controller.text,
          q3: _q3Controller.text,
          q4: _q4Controller.text,
          timestamp: widget.data.timestamp,
        ),
      );
    }

    // Save the edited data
    final editedData = NotesDataModel(
      doctorNote: _doctorNoteController.text,
      q1: _q1Controller.text,
      q2: _q2Controller.text,
      q3: _q3Controller.text,
      q4: _q4Controller.text,
      timestamp: widget.data.timestamp,
    );

    // Optionally, you can reset the editing state
    setState(() {
      _isEditing = false;
    });
  }

  double calculateDoctorNoteContainerHeight(BuildContext context) {
    // Get the screen height
    double screenHeight = MediaQuery.of(context).size.height;
    double doctorNoteContainerHeight = (screenHeight / 8);
    return doctorNoteContainerHeight;
  }

  Widget _buildQuadrant(String text, TextEditingController controller) {
    return GestureDetector(
      onTap: () {
        // Trigger inline editing for the corresponding quadrant
        _startEditingQuadrant(controller, text);
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 7 - 12.0,
        height: MediaQuery.of(context).size.height / 14 - 12.0,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: MyColors.colorPalette['on-surface']!,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: TextField(
            controller: controller,
            onChanged: (editedText) {
              // Update the quadrant text in the parent widget if needed
              // You can add additional logic here if necessary
            },
            enabled: _isEditing, // Use the enabled property
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 16.0),
            maxLines: null, // Allow unlimited lines
          ),
        ),
      ),
    );
  }

  void _startEditingQuadrant(
      TextEditingController controller, String initialText) {
    setState(() {
      controller.text = initialText;
      _isEditing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double doctorNoteContainerHeight =
        calculateDoctorNoteContainerHeight(context);

    return GestureDetector(
      onTap: () {
        _saveData();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor's Note Container
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () {
                  // Trigger inline editing for doctor's note
                  _startEditingDoctorNote();
                },
                child: Container(
                  width: double.infinity, // Take the remaining space
                  constraints: BoxConstraints(
                    minHeight: doctorNoteContainerHeight,
                    maxHeight: doctorNoteContainerHeight,
                  ),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display 'X' icon and date in the top row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'X',
                            style: MyTextStyle.textStyleMap['label-large']
                                ?.copyWith(
                                    color: MyColors.colorPalette['secondary']),
                          ),
                          Text(
                            widget.data.timestamp,
                            style: MyTextStyle.textStyleMap['label-small']
                                ?.copyWith(
                                    color: MyColors
                                        .colorPalette['on-surface-variant']),
                          ),
                        ],
                      ),

                      // Display editable doctor's note
                      Expanded(
                        child: TextField(
                          controller: _doctorNoteController,
                          onChanged: (editedText) {
                            // Update the doctor's note in the parent widget
                            // widget.onEdit!(
                            //   widget.data.copyWith(doctorNote: editedText),
                            // );
                          },
                          // readOnly: true,
                          enabled: _isEditing, // Use the enabled property
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 16.0),
                          maxLines: null, // Allow unlimited lines
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // //Spacer
          // const SizedBox(width: 8.0),

          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8.0, left: 8.0),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjusted
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Adjusted
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjusted
                  children: [
                    // Quadrant 1
                    //_buildQuadrant(widget.data.q1),
                    _buildQuadrant(widget.data.q1, _q1Controller),

                    // Quadrant 2
                    //_buildQuadrant(widget.data.q2),
                    _buildQuadrant(widget.data.q2, _q2Controller),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Adjusted
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjusted
                  children: [
                    // Quadrant 3
                    //_buildQuadrant(widget.data.q3),
                    _buildQuadrant(widget.data.q3, _q3Controller),

                    // Quadrant 4
                    //_buildQuadrant(widget.data.q4),
                    _buildQuadrant(widget.data.q4, _q4Controller),
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

class NotesDataModel {
  String doctorNote;
  String q1;
  String q2;
  String q3;
  String q4;
  String timestamp;

  NotesDataModel({
    required this.doctorNote,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
    required this.timestamp,
  });

  // Implementing copyWith
  NotesDataModel copyWith({
    String? doctorNote,
    String? q1,
    String? q2,
    String? q3,
    String? q4,
    String? timestamp,
  }) {
    return NotesDataModel(
      doctorNote: doctorNote ?? this.doctorNote,
      q1: q1 ?? this.q1,
      q2: q2 ?? this.q2,
      q3: q3 ?? this.q3,
      q4: q4 ?? this.q4,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class RenderNotesDataContainer extends StatefulWidget {
//   final NotesDataModel data;
//   //final Function(NotesDataModel) onEdit;
//   //final Function(NotesDataModel)? onEdit;

//   const RenderNotesDataContainer({
//     Key? key,
//     required this.data,
//     //required this.onEdit,
//   }) : super(key: key);

//   @override
//   State<RenderNotesDataContainer> createState() =>
//       _RenderNotesDataContainerState();
// }

// class _RenderNotesDataContainerState extends State<RenderNotesDataContainer> {
//   late TextEditingController _doctorNoteController;
//   bool _isEditing = false;

//   @override
//   void initState() {
//     super.initState();
//     _doctorNoteController = TextEditingController(text: widget.data.doctorNote);
//   }

//   void _startEditingDoctorNote() {
//     setState(() {
//       _doctorNoteController.text = widget.data.doctorNote;
//       _isEditing = true; // Add this line to track editing state
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Doctor's Note Container
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: GestureDetector(
//               onTap: () {
//                 // Trigger inline editing for doctor's note
//                 _startEditingDoctorNote();
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Colors.grey,
//                     width: 1.0,
//                     style: BorderStyle.solid,
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Display 'X' icon and date in the top row
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 8.0),
//                       child: Row(
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
//                     ),

//                     // Display editable doctor's note
//                     TextField(
//                       controller: _doctorNoteController,
//                       maxLines:
//                           null, // Allow the TextField to dynamically adjust its height
//                       onChanged: (editedText) {
//                         // Update the doctor's note in the parent widget
//                         // widget.onEdit!(
//                         //   widget.data.copyWith(doctorNote: editedText),
//                         // );
//                       },
//                       //readOnly: true,
//                       enabled: _isEditing, // Use the enabled property
//                       decoration: const InputDecoration(
//                         border: InputBorder.none,
//                       ),
//                       style: const TextStyle(fontSize: 16.0),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // Spacer
//         const SizedBox(width: 8.0),

//         // Quadrant Containers
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 8.0,
//                 mainAxisSpacing: 8.0,
//               ),
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: 4,
//               itemBuilder: (context, index) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color: MyColors.colorPalette['on-surface']!,
//                     ),
//                     borderRadius: BorderRadius.circular(8.0),
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
//                       style: const TextStyle(fontSize: 16.0),
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
// class _RenderNotesDataContainerState extends State<RenderNotesDataContainer> {
//   late TextEditingController _doctorNoteController;
//   bool _isEditing = false;

//   @override
//   void initState() {
//     super.initState();
//     _doctorNoteController = TextEditingController(text: widget.data.doctorNote);
//   }

//   void _startEditingDoctorNote() {
//     setState(() {
//       _doctorNoteController.text = widget.data.doctorNote;
//       _isEditing = true; // Add this line to track editing state
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Doctor's Note Container
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: GestureDetector(
//               onTap: () {
//                 // Trigger inline editing for doctor's note
//                 _startEditingDoctorNote();
//               },
//               child: Container(
//                 height: calculateContainerHeight(),
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Colors.grey,
//                     width: 1.0,
//                     style: BorderStyle.solid,
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Display 'X' icon and date in the top row
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 8.0),
//                       child: Row(
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
//                     ),

//                     // Display editable doctor's note
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: TextField(
//                           controller: _doctorNoteController,
//                           onChanged: (editedText) {
//                             // Update the doctor's note in the parent widget
//                             // widget.onEdit!(
//                             //   widget.data.copyWith(doctorNote: editedText),
//                             // );
//                           },
//                           maxLines: null, // Allow unlimited lines
//                           readOnly: !_isEditing,
//                           decoration: const InputDecoration(
//                             border: InputBorder.none,
//                           ),
//                           style: const TextStyle(fontSize: 16.0),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // Spacer
//         const SizedBox(width: 8.0),

//         // Quadrant Containers
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 8.0,
//                 mainAxisSpacing: 8.0,
//               ),
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: 4,
//               itemBuilder: (context, index) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color: MyColors.colorPalette['on-surface']!,
//                     ),
//                     borderRadius: BorderRadius.circular(8.0),
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
//                       style: const TextStyle(fontSize: 16.0),
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

//   double calculateContainerHeight() {
//     // Calculate the height of 2 quadrants + vertical spacing
//     double quadrantHeight = calculateTextHeight(widget.data.q1);
//     double verticalSpacing = 8.0; // Adjust as needed
//     double totalHeight = 2 * quadrantHeight + verticalSpacing;

//     return totalHeight;
//   }

//   double calculateTextHeight(String text) {
//     // Use a TextPainter to measure the height of the text
//     final TextPainter textPainter = TextPainter(
//       text: TextSpan(text: text, style: const TextStyle(fontSize: 16.0)),
//       textDirection: TextDirection.ltr,
//     );

//     textPainter.layout(maxWidth: double.infinity);

//     return textPainter.height;
//   }
// }

// class NotesDataModel {
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;
//   String timestamp;

//   NotesDataModel({
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//     required this.timestamp,
//   });

//   // Implementing copyWith
//   NotesDataModel copyWith({
//     String? doctorNote,
//     String? q1,
//     String? q2,
//     String? q3,
//     String? q4,
//     String? timestamp,
//   }) {
//     return NotesDataModel(
//       doctorNote: doctorNote ?? this.doctorNote,
//       q1: q1 ?? this.q1,
//       q2: q2 ?? this.q2,
//       q3: q3 ?? this.q3,
//       q4: q4 ?? this.q4,
//       timestamp: timestamp ?? this.timestamp,
//     );
//   }
// }

// code below is stable
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class RenderNotesDataContainer extends StatefulWidget {
//   final NotesDataModel data;

//   const RenderNotesDataContainer({
//     Key? key,
//     required this.data,
//   }) : super(key: key);

//   @override
//   State<RenderNotesDataContainer> createState() =>
//       _RenderNotesDataContainerState();
// }

// class _RenderNotesDataContainerState extends State<RenderNotesDataContainer> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Doctor's Note Container
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.grey,
//                   width: 1.0,
//                   style: BorderStyle.solid,
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Display 'X' icon and date in the top row
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'X',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                         Text(
//                           widget.data.timestamp,
//                           style: MyTextStyle.textStyleMap['label-small']
//                               ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on-surface-variant']),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Display doctor's note
//                   SingleChildScrollView(
//                     child: Text(
//                       widget.data.doctorNote,
//                       style: const TextStyle(fontSize: 16.0),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),

//         // Spacer
//         const SizedBox(width: 8.0),

//         // Quadrant Containers
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 8.0,
//                 mainAxisSpacing: 8.0,
//               ),
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: 4,
//               itemBuilder: (context, index) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color: MyColors.colorPalette['on-surface']!,
//                     ),
//                     borderRadius: BorderRadius.circular(8.0),
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
//                       style: const TextStyle(fontSize: 16.0),
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

// class RenderNotesDataContainer extends StatefulWidget {
//   final NotesDataModel data;
//   final double containerHeight;

//   const RenderNotesDataContainer({
//     Key? key,
//     required this.containerHeight,
//     required this.data,
//   }) : super(key: key);

//   @override
//   State<RenderNotesDataContainer> createState() =>
//       _RenderNotesDataContainerState();
// }

// class _RenderNotesDataContainerState extends State<RenderNotesDataContainer> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Doctor's Note Container
//         Expanded(
//           flex: 6, // Adjust flex as needed (60% of the width)
//           child: SizedBox(
//             height: widget.containerHeight,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Colors.grey,
//                     width: 1.0,
//                     style: BorderStyle.solid,
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Display 'X' icon and date in the top row
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'X',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['secondary']),
//                           ),
//                           Text(
//                             widget
//                                 .data.timestamp, // Use the timestamp from data
//                             style: MyTextStyle.textStyleMap['label-small']
//                                 ?.copyWith(
//                                     color: MyColors
//                                         .colorPalette['on-surface-variant']),
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Display doctor's note
//                     SingleChildScrollView(
//                       child: Text(
//                         widget.data.doctorNote,
//                         style: const TextStyle(fontSize: 16.0),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // Spacer
//         const SizedBox(width: 8.0),

//         // Quadrant Containers
//         Expanded(
//           flex: 4, // Adjust flex as needed (40% of the width)
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 8.0,
//                 mainAxisSpacing: 8.0,
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
//                       color: MyColors.colorPalette['on-surface']!,
//                     ),
//                     borderRadius: BorderRadius.circular(8.0),
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
//                       style: const TextStyle(fontSize: 16.0),
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

// class NotesDataModel {
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;
//   String timestamp; // Add this line

//   NotesDataModel({
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//     required this.timestamp, // Add this line
//   });
// }

// class NotesDataModel {
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;

//   NotesDataModel({
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//   });
// }
