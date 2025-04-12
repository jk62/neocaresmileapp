import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as devtools show log;
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:math';

class AddEmptyContainer extends StatefulWidget {
  final AddEmptyContainerData data;
  final double containerHeight;
  final VoidCallback? updateContainersDataCallback;
  final void Function(String id) removeContainerCallback;

  const AddEmptyContainer({
    super.key,
    required this.containerHeight,
    required this.data,
    required this.updateContainersDataCallback,
    required this.removeContainerCallback,
  });

  @override
  State<AddEmptyContainer> createState() => _AddEmptyContainerState();
}

class _AddEmptyContainerState extends State<AddEmptyContainer> {
  final TextEditingController _doctorNoteController = TextEditingController();

  final TextEditingController _q1Controller = TextEditingController();
  final TextEditingController _q2Controller = TextEditingController();
  final TextEditingController _q3Controller = TextEditingController();
  final TextEditingController _q4Controller = TextEditingController();

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
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double doctorNoteContainerHeight =
        calculateDoctorNoteContainerHeight(context);
    _doctorNoteController.text = widget.data.doctorNote;
    _q1Controller.text = widget.data.q1;
    _q2Controller.text = widget.data.q2;
    _q3Controller.text = widget.data.q3;
    _q4Controller.text = widget.data.q4;

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
                  width: 1,
                  color: MyColors.colorPalette['on-surface'] ??
                      const Color(0xFF011718),
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display 'X' icon and date in the top row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            // Add your delete operation here
                            devtools.log('Delete operation triggered');
                            // _notifyParentAboutDeletion();
                            widget.removeContainerCallback(widget.data.id);
                            devtools.log(
                                'widget.data.id being passed on is ${widget.data.id}');
                          },
                          child: Icon(
                            Icons.close,
                            size: 24,
                            color: MyColors
                                .colorPalette['on-surface'], //Colors.black,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _doctorNoteController,

                      onChanged: (value) {
                        setState(() {
                          _doctorNoteController.text = value;
                          widget.data.doctorNote = value;
                        });
                        widget.updateContainersDataCallback?.call();
                      },

                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        //hintText: 'Enter doctor\'s note here',
                        contentPadding: EdgeInsets.all(8.0),
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

        //Quadrants
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
                      setState(() {
                        _q1Controller.text = value;
                        widget.data.q1 = value;
                      });
                      widget.updateContainersDataCallback?.call();
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildQuadrant(
                    widget.data.q2,
                    _q2Controller,
                    (value) {
                      setState(() {
                        _q2Controller.text = value;
                        widget.data.q2 = value;
                      });
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
                      setState(() {
                        _q3Controller.text = value;
                        widget.data.q3 = value;
                      });
                      widget.updateContainersDataCallback?.call();
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildQuadrant(
                    widget.data.q4,
                    _q4Controller,
                    (value) {
                      setState(() {
                        _q4Controller.text = value;
                        widget.data.q4 = value;
                      });
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

class AddEmptyContainerData {
  String id;
  String doctorNote;
  String q1;
  String q2;
  String q3;
  String q4;

  AddEmptyContainerData({
    required this.id,
    required this.doctorNote,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
  });

  // Add this method
  factory AddEmptyContainerData.fromMap(Map<String, dynamic> map) {
    return AddEmptyContainerData(
      id: map['id'] ?? '',
      doctorNote: map['doctorNote'] ?? '',
      q1: map['q1'] ?? '',
      q2: map['q2'] ?? '',
      q3: map['q3'] ?? '',
      q4: map['q4'] ?? '',
    );
  }

  @override
  String toString() {
    return 'AddEmptyContainerData(id: $id, doctorNote: $doctorNote, q1: $q1, q2: $q2, q3: $q3, q4: $q4)';
  }
}


//-------------------------------------------------------------------------------//
// CODE BELOW IS WITH FOR LOOP
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:math';

// class AddEmptyContainer extends StatefulWidget {
//   final AddEmptyContainerData data;
//   final double containerHeight;
//   final VoidCallback? updateContainersDataCallback;
//   final void Function(String id) removeContainerCallback;

//   const AddEmptyContainer({
//     Key? key,
//     required this.containerHeight,
//     required this.data,
//     required this.updateContainersDataCallback,
//     required this.removeContainerCallback,
//   }) : super(key: key);

//   @override
//   State<AddEmptyContainer> createState() => _AddEmptyContainerState();
// }

// class _AddEmptyContainerState extends State<AddEmptyContainer> {
//   final TextEditingController _doctorNoteController = TextEditingController();

//   final TextEditingController _q1Controller = TextEditingController();
//   final TextEditingController _q2Controller = TextEditingController();
//   final TextEditingController _q3Controller = TextEditingController();
//   final TextEditingController _q4Controller = TextEditingController();

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
//     _doctorNoteController.text = widget.data.doctorNote;
//     _q1Controller.text = widget.data.q1;
//     _q2Controller.text = widget.data.q2;
//     _q3Controller.text = widget.data.q3;
//     _q4Controller.text = widget.data.q4;

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
//                     // Display 'X' icon and date in the top row
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         GestureDetector(
//                           onTap: () async {
//                             // Add your delete operation here
//                             devtools.log('Delete operation triggered');
//                             // _notifyParentAboutDeletion();
//                             widget.removeContainerCallback(widget.data.id);
//                             devtools.log(
//                                 'widget.data.id being passed on is ${widget.data.id}');
//                           },
//                           child: Icon(
//                             Icons.close,
//                             size: 24,
//                             color: MyColors
//                                 .colorPalette['on-surface'], //Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                     TextFormField(
//                       controller: _doctorNoteController,

//                       onChanged: (value) {
//                         setState(() {
//                           _doctorNoteController.text = value;
//                           widget.data.doctorNote = value;
//                         });
//                         widget.updateContainersDataCallback?.call();
//                       },

//                       decoration: const InputDecoration(
//                         border: InputBorder.none,
//                         //hintText: 'Enter doctor\'s note here',
//                         contentPadding: EdgeInsets.all(8.0),
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
//                       setState(() {
//                         _q1Controller.text = value;
//                         widget.data.q1 = value;
//                       });
//                       widget.updateContainersDataCallback?.call();
//                     },
//                   ),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(
//                     widget.data.q2,
//                     _q2Controller,
//                     (value) {
//                       setState(() {
//                         _q2Controller.text = value;
//                         widget.data.q2 = value;
//                       });
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
//                       setState(() {
//                         _q3Controller.text = value;
//                         widget.data.q3 = value;
//                       });
//                       widget.updateContainersDataCallback?.call();
//                     },
//                   ),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(
//                     widget.data.q4,
//                     _q4Controller,
//                     (value) {
//                       setState(() {
//                         _q4Controller.text = value;
//                         widget.data.q4 = value;
//                       });
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

//------------------------------------------------------------------------------//


// class AddEmptyContainerData {
//   final String id; // Unique identifier for each container
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

//   // Factory method to create AddEmptyContainerData from a map
//   factory AddEmptyContainerData.fromMap(Map<String, dynamic> map) {
//     return AddEmptyContainerData(
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
//     return 'AddEmptyContainerData(id: $id, doctorNote: $doctorNote, q1: $q1, q2: $q2, q3: $q3, q4: $q4)';
//   }
// }



// class AddEmptyContainerData {
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;

//   AddEmptyContainerData({
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//   });

//   // Factory method to create AddEmptyContainerData from a map
//   factory AddEmptyContainerData.fromMap(Map<String, dynamic> map) {
//     return AddEmptyContainerData(
//       doctorNote: map['doctorNote'] as String,
//       q1: map['q1'] as String,
//       q2: map['q2'] as String,
//       q3: map['q3'] as String,
//       q4: map['q4'] as String,
//     );
//   }

//   @override
//   String toString() {
//     return 'AddEmptyContainerData(doctorNote: $doctorNote, q1: $q1, q2: $q2, q3: $q3, q4: $q4)';
//   }
// }



// Display 'X' icon and date in the top row
// Row(
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     GestureDetector(
//       onTap: () async {
//         // Add your delete operation here
//         //devtools.log('Delete operation triggered');
//         // await deleteNoteFromBackend(widget.data.noteId);
//         // _notifyParentAboutDeletion();
//       },
//       child: Icon(
//         Icons.close,
//         size: 24,
//         color: MyColors
//             .colorPalette['on-surface'], //Colors.black,
//       ),
//     ),
//   ],
// ),
// CODE BELOW IS STABLE WITH GRIDVIEW
// import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

// class AddEmptyContainer extends StatefulWidget {
//   final AddEmptyContainerData data;
//   final double containerHeight;
//   final VoidCallback? updateContainersDataCallback;

//   const AddEmptyContainer({
//     Key? key,
//     required this.containerHeight,
//     required this.data,
//     required this.updateContainersDataCallback,
//   }) : super(key: key);

//   @override
//   State<AddEmptyContainer> createState() => _AddEmptyContainerState();
// }

// class _AddEmptyContainerState extends State<AddEmptyContainer> {
//   final TextEditingController _doctorNoteController = TextEditingController();

//   final TextEditingController _q1Controller = TextEditingController();
//   final TextEditingController _q2Controller = TextEditingController();
//   final TextEditingController _q3Controller = TextEditingController();
//   final TextEditingController _q4Controller = TextEditingController();

//   @override
//   void dispose() {
//     _doctorNoteController.dispose();
//     _q1Controller.dispose();
//     _q2Controller.dispose();
//     _q3Controller.dispose();
//     _q4Controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     _doctorNoteController.text = widget.data.doctorNote;
//     _q1Controller.text = widget.data.q1;
//     _q2Controller.text = widget.data.q2;
//     _q3Controller.text = widget.data.q3;
//     _q4Controller.text = widget.data.q4;
//     return Row(
//       children: [
//         // Doctor's Note Container
//         Expanded(
//           flex: 6, // Adjust flex as needed (60% of the width)
//           child: SizedBox(
//             height: widget.containerHeight,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Colors.grey,
//                     width: 1.0,
//                     style: BorderStyle.solid,
//                   ),
//                 ),
//                 child: SingleChildScrollView(
//                   child: TextFormField(
//                     controller: _doctorNoteController,
//                     onChanged: (value) {
//                       setState(() {
//                         widget.data.doctorNote = value;
//                       });

//                       devtools.log(
//                           'widget.data.doctorNote is ${widget.data.doctorNote}');
//                     },
//                     decoration: const InputDecoration(
//                       border: InputBorder.none,
//                       //hintText: 'Enter doctor\'s note here',
//                       contentPadding: EdgeInsets.all(16.0),
//                     ),
//                     maxLines: null, // Allow multiple lines of text
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // Spacer
//         const SizedBox(width: 16.0),

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
//                   decoration: BoxDecoration(border: Border.all(width: 1)),
//                   child: TextFormField(
//                     autovalidateMode: AutovalidateMode.disabled,
//                     controller: index == 0
//                         ? _q1Controller
//                         : index == 1
//                             ? _q2Controller
//                             : index == 2
//                                 ? _q3Controller
//                                 : _q4Controller,
//                     onChanged: (value) {
//                       setState(() {
//                         if (index == 0) {
//                           widget.data.q1 = value;
//                           devtools.log('widget.data.q1 is ${widget.data.q1}');
//                         } else if (index == 1) {
//                           widget.data.q2 = value;
//                           devtools.log('widget.data.q2 is ${widget.data.q2}');
//                         } else if (index == 2) {
//                           widget.data.q3 = value;
//                           devtools.log('widget.data.q3 is ${widget.data.q3}');
//                         } else {
//                           widget.data.q4 = value;
//                           devtools.log('widget.data.q4 is ${widget.data.q4}');
//                         }
//                         // widget.updateContainersDataCallback!();
//                         widget.updateContainersDataCallback?.call();
//                       });
//                     },
//                     decoration: const InputDecoration(
//                       border: InputBorder.none,
//                       focusedBorder: InputBorder.none,
//                       //hintText: 'q${index + 1}',
//                       contentPadding: EdgeInsets.all(16.0),
//                       helperText: '',
//                       counterText: '',
//                     ),
//                     keyboardType: TextInputType.number,
//                     maxLength: 2,
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




