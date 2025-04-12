import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as devtools show log;
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:math';

class AddEmptyOralExaminationContainer extends StatefulWidget {
  final AddEmptyOralExaminationContainerData data;
  final double containerHeight;
  final VoidCallback? updateContainersDataCallback;
  final Function(String)
      removeContainerCallback; // Define removeContainerCallback
  final GlobalKey<AddEmptyOralExaminationContainerState> key;

  const AddEmptyOralExaminationContainer({
    required this.key,
    required this.containerHeight,
    required this.data,
    required this.updateContainersDataCallback,
    required this.removeContainerCallback, // Add it to the constructor
  }) : super(key: key);

  @override
  AddEmptyOralExaminationContainerState createState() =>
      AddEmptyOralExaminationContainerState();
}

class AddEmptyOralExaminationContainerState
    extends State<AddEmptyOralExaminationContainer> {
  late TextEditingController _doctorNoteController;
  late TextEditingController _q1Controller;
  late TextEditingController _q2Controller;
  late TextEditingController _q3Controller;
  late TextEditingController _q4Controller;

  @override
  void initState() {
    super.initState();
    _doctorNoteController = TextEditingController(text: widget.data.doctorNote);
    _q1Controller = TextEditingController(text: widget.data.q1);
    _q2Controller = TextEditingController(text: widget.data.q2);
    _q3Controller = TextEditingController(text: widget.data.q3);
    _q4Controller = TextEditingController(text: widget.data.q4);
  }

  @override
  void dispose() {
    _doctorNoteController.dispose();
    _q1Controller.dispose();
    _q2Controller.dispose();
    _q3Controller.dispose();
    _q4Controller.dispose();
    super.dispose();
  }

  double calculateDoctorNoteContainerHeight(BuildContext context) {
    // Get the screen height
    double screenHeight = MediaQuery.of(context).size.height;
    double doctorNoteContainerHeight = (screenHeight / 8);
    return doctorNoteContainerHeight;
  }

  Widget _buildQuadrant(String text, TextEditingController controller,
      void Function(String) onChangedCallback) {
    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width / 7 - 12.0,
        height: MediaQuery.of(context).size.height / 14 - 12.0,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color:
                MyColors.colorPalette['on-surface'] ?? const Color(0xFF011718),
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Center(
          child: TextField(
            textAlign: TextAlign.center,
            controller: controller,
            onChanged: onChangedCallback,
            enabled: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}')),
            ],
            style: MyTextStyle.textStyleMap['title-Medium']
                ?.copyWith(color: MyColors.colorPalette['secondary']),
            maxLines: null,
          ),
        ),
      ),
    );
  }

  // Method to update doctorNote from template
  void updateDoctorNoteFromTemplate(String template) {
    setState(() {
      _doctorNoteController.text = template;
      widget.data.doctorNote = template;
      widget.updateContainersDataCallback?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    double doctorNoteContainerHeight =
        calculateDoctorNoteContainerHeight(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Doctor's Note Container
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: double.infinity, // Take the remaining space
              constraints: BoxConstraints(
                minHeight: doctorNoteContainerHeight,
                maxHeight: doctorNoteContainerHeight,
              ),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  //color: Colors.grey,
                  color: MyColors.colorPalette['on-surface'] ??
                      const Color(0xFF011718),
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display 'X' icon and date in the top row
                    GestureDetector(
                      onTap: () {
                        // Call the removeContainerCallback function to remove the container
                        widget.removeContainerCallback(widget.data.id);
                      },
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color:
                            MyColors.colorPalette['on-surface'], //Colors.black,
                      ),
                    ),
                    TextFormField(
                      controller: _doctorNoteController,
                      onChanged: (value) {
                        widget.data.doctorNote = value;
                        widget.updateContainersDataCallback?.call();
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      maxLines: null, // Allow multiple lines of text
                      style: MyTextStyle.textStyleMap['label-large']
                          ?.copyWith(color: MyColors.colorPalette['secondary']),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),

        // Quadrants
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 8.0, left: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildQuadrant(
                    widget.data.q1,
                    _q1Controller,
                    (value) {
                      widget.data.q1 = value;
                      widget.updateContainersDataCallback?.call();
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildQuadrant(
                    widget.data.q2,
                    _q2Controller,
                    (value) {
                      widget.data.q2 = value;
                      widget.updateContainersDataCallback?.call();
                    },
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
                    (value) {
                      widget.data.q3 = value;
                      widget.updateContainersDataCallback?.call();
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildQuadrant(
                    widget.data.q4,
                    _q4Controller,
                    (value) {
                      widget.data.q4 = value;
                      widget.updateContainersDataCallback?.call();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddEmptyOralExaminationContainerData {
  final String id; // Unique identifier for each container
  String doctorNote;
  String q1;
  String q2;
  String q3;
  String q4;

  AddEmptyOralExaminationContainerData({
    required this.id,
    required this.doctorNote,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
  });

  // Factory method to create AddEmptyContainerData from a map
  factory AddEmptyOralExaminationContainerData.fromMap(
      Map<String, dynamic> map) {
    return AddEmptyOralExaminationContainerData(
      id: map['id'] ??
          Random()
              .nextInt(1000000)
              .toString(), // Generate a random ID if not provided
      doctorNote: map['doctorNote'] as String,
      q1: map['q1'] as String,
      q2: map['q2'] as String,
      q3: map['q3'] as String,
      q4: map['q4'] as String,
    );
  }

  @override
  String toString() {
    return 'AddEmptyOralExaminationContainerData(id: $id, doctorNote: $doctorNote, q1: $q1, q2: $q2, q3: $q3, q4: $q4)';
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW IS STABLE WITHOUT TEMPLATE IMPLEMENTATION
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:math';

// class AddEmptyOralExaminationContainer extends StatefulWidget {
//   final AddEmptyOralExaminationContainerData data;
//   final double containerHeight;
//   final VoidCallback? updateContainersDataCallback;
//   final Function(String)
//       removeContainerCallback; // Define removeContainerCallback

//   const AddEmptyOralExaminationContainer({
//     super.key,
//     required this.containerHeight,
//     required this.data,
//     required this.updateContainersDataCallback,
//     required this.removeContainerCallback, // Add it to the constructor
//   });

//   @override
//   State<AddEmptyOralExaminationContainer> createState() =>
//       _AddEmptyOralExaminationContainerState();
// }

// class _AddEmptyOralExaminationContainerState
//     extends State<AddEmptyOralExaminationContainer> {
//   late TextEditingController _doctorNoteController;
//   late TextEditingController _q1Controller;
//   late TextEditingController _q2Controller;
//   late TextEditingController _q3Controller;
//   late TextEditingController _q4Controller;

//   @override
//   void initState() {
//     super.initState();
//     _doctorNoteController = TextEditingController(text: widget.data.doctorNote);
//     _q1Controller = TextEditingController(text: widget.data.q1);
//     _q2Controller = TextEditingController(text: widget.data.q2);
//     _q3Controller = TextEditingController(text: widget.data.q3);
//     _q4Controller = TextEditingController(text: widget.data.q4);
//   }

//   @override
//   void dispose() {
//     _doctorNoteController.dispose();
//     _q1Controller.dispose();
//     _q2Controller.dispose();
//     _q3Controller.dispose();
//     _q4Controller.dispose();
//     super.dispose();
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
//             color:
//                 MyColors.colorPalette['on-surface'] ?? const Color(0xFF011718),
//           ),
//           borderRadius: BorderRadius.circular(5.0),
//         ),
//         child: Center(
//             child: TextField(
//           textAlign: TextAlign.center,
//           controller: controller,
//           onChanged: onChangedCallback,
//           enabled: true,
//           decoration: const InputDecoration(
//             border: InputBorder.none,
//           ),
//           keyboardType: TextInputType.number,
//           inputFormatters: [
//             FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}')),
//           ],
//           style: MyTextStyle.textStyleMap['title-Medium']
//               ?.copyWith(color: MyColors.colorPalette['secondary']),
//           maxLines: null,
//         )),
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
//         // Doctor's Note Container
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8),
//             child: Container(
//               width: double.infinity, // Take the remaining space
//               constraints: BoxConstraints(
//                 minHeight: doctorNoteContainerHeight,
//                 maxHeight: doctorNoteContainerHeight,
//               ),
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   //color: Colors.grey,
//                   color: MyColors.colorPalette['on-surface'] ??
//                       const Color(0xFF011718),
//                   width: 1.0,
//                   style: BorderStyle.solid,
//                 ),
//                 borderRadius: BorderRadius.circular(5.0),
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Display 'X' icon and date in the top row
//                     GestureDetector(
//                       onTap: () {
//                         // Call the removeContainerCallback function to remove the container
//                         widget.removeContainerCallback(widget.data.id);
//                       },
//                       child: Icon(
//                         Icons.close,
//                         size: 24,
//                         color:
//                             MyColors.colorPalette['on-surface'], //Colors.black,
//                       ),
//                     ),
//                     TextFormField(
//                       controller: _doctorNoteController,
//                       onChanged: (value) {
//                         widget.data.doctorNote = value;
//                         widget.updateContainersDataCallback?.call();
//                       },
//                       decoration: const InputDecoration(
//                         border: InputBorder.none,
//                       ),
//                       maxLines: null, // Allow multiple lines of text
//                       style: MyTextStyle.textStyleMap['label-large']
//                           ?.copyWith(color: MyColors.colorPalette['secondary']),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),

//         //Quadrants
//         Padding(
//           padding: const EdgeInsets.only(top: 8, right: 8.0, left: 8.0),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   _buildQuadrant(
//                     widget.data.q1,
//                     _q1Controller,
//                     (value) {
//                       widget.data.q1 = value;
//                       widget.updateContainersDataCallback?.call();
//                     },
//                   ),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(
//                     widget.data.q2,
//                     _q2Controller,
//                     (value) {
//                       widget.data.q2 = value;
//                       widget.updateContainersDataCallback?.call();
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   _buildQuadrant(
//                     widget.data.q3,
//                     _q3Controller,
//                     (value) {
//                       widget.data.q3 = value;
//                       widget.updateContainersDataCallback?.call();
//                     },
//                   ),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(
//                     widget.data.q4,
//                     _q4Controller,
//                     (value) {
//                       widget.data.q4 = value;
//                       widget.updateContainersDataCallback?.call();
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class AddEmptyOralExaminationContainerData {
//   final String id; // Unique identifier for each container
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;

//   AddEmptyOralExaminationContainerData({
//     required this.id,
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//   });

//   // Factory method to create AddEmptyContainerData from a map
//   factory AddEmptyOralExaminationContainerData.fromMap(
//       Map<String, dynamic> map) {
//     return AddEmptyOralExaminationContainerData(
//       id: map['id'] ??
//           Random()
//               .nextInt(1000000)
//               .toString(), // Generate a random ID if not provided
//       doctorNote: map['doctorNote'] as String,
//       q1: map['q1'] as String,
//       q2: map['q2'] as String,
//       q3: map['q3'] as String,
//       q4: map['q4'] as String,
//     );
//   }

//   @override
//   String toString() {
//     return 'AddEmptyOralExaminationContainerData(id: $id, doctorNote: $doctorNote, q1: $q1, q2: $q2, q3: $q3, q4: $q4)';
//   }
// }
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
