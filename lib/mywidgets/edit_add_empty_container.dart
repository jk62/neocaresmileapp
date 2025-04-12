// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:uuid/uuid.dart';

// class EditAddEmptyContainer extends StatefulWidget {
//   final EditAddEmptyContainerData data;
//   final double containerHeight;
//   final void Function(EditAddEmptyContainerData)? updateContainersDataCallback;
//   final void Function(String id) removeContainerCallback;

//   const EditAddEmptyContainer({
//     Key? key,
//     required this.containerHeight,
//     required this.data,
//     required this.updateContainersDataCallback,
//     required this.removeContainerCallback,
//   }) : super(key: key);

//   @override
//   State<EditAddEmptyContainer> createState() => _EditAddEmptyContainerState();
// }

// class _EditAddEmptyContainerState extends State<EditAddEmptyContainer> {
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
//           child: TextField(
//             textAlign: TextAlign.center,
//             controller: controller,
//             onChanged: onChangedCallback,
//             enabled: true,
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//             ),
//             keyboardType: TextInputType.number,
//             inputFormatters: [
//               FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}')),
//             ],
//             style: MyTextStyle.textStyleMap['title-Medium']
//                 ?.copyWith(color: MyColors.colorPalette['secondary']),
//             maxLines: null,
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
//                         GestureDetector(
//                           onTap: () {
//                             devtools.log('Delete operation triggered');
//                             widget.removeContainerCallback(widget.data.id);
//                             devtools.log(
//                                 'widget.data.id being passed on is ${widget.data.id}');
//                           },
//                           child: Icon(
//                             Icons.close,
//                             size: 24,
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                       ],
//                     ),
//                     TextFormField(
//                       controller: _doctorNoteController,
//                       onChanged: (value) {
//                         setState(() {
//                           widget.data.doctorNote = value;
//                         });
//                         widget.updateContainersDataCallback?.call(widget.data);
//                       },
//                       decoration: const InputDecoration(
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.all(8.0),
//                       ),
//                       maxLines: null,
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
//                   _buildQuadrant(widget.data.q1, _q1Controller, (value) {
//                     setState(() {
//                       widget.data.q1 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(widget.data.q2, _q2Controller, (value) {
//                     setState(() {
//                       widget.data.q2 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   _buildQuadrant(widget.data.q3, _q3Controller, (value) {
//                     setState(() {
//                       widget.data.q3 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(widget.data.q4, _q4Controller, (value) {
//                     setState(() {
//                       widget.data.q4 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // class EditAddEmptyContainerData {
// //   String id;
// //   String doctorNote;
// //   String q1;
// //   String q2;
// //   String q3;
// //   String q4;

// //   EditAddEmptyContainerData({
// //     required this.id,
// //     required this.doctorNote,
// //     required this.q1,
// //     required this.q2,
// //     required this.q3,
// //     required this.q4,
// //   });

// //   factory EditAddEmptyContainerData.fromMap(Map<String, dynamic> map) {
// //     return EditAddEmptyContainerData(
// //       id: map['id'] ?? const Uuid().v4().toString(),
// //       doctorNote: map['doctorNote'] ?? '',
// //       q1: map['q1'] ?? '',
// //       q2: map['q2'] ?? '',
// //       q3: map['q3'] ?? '',
// //       q4: map['q4'] ?? '',
// //     );
// //   }

// //   @override
// //   String toString() {
// //     return 'EditAddEmptyContainerData(id: $id, doctorNote: $doctorNote, q1: $q1, q2: $q2, q3: $q3, q4: $q4)';
// //   }
// // }
// class EditAddEmptyContainerData {
//   String id;
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;

//   EditAddEmptyContainerData({
//     required this.id,
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//   });

//   factory EditAddEmptyContainerData.fromMap(Map<String, dynamic> map) {
//     return EditAddEmptyContainerData(
//       id: map['id'] ?? const Uuid().v4().toString(),
//       doctorNote: map['doctorNote'] ?? '',
//       q1: map['q1'] ?? '',
//       q2: map['q2'] ?? '',
//       q3: map['q3'] ?? '',
//       q4: map['q4'] ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'doctorNote': doctorNote,
//       'q1': q1,
//       'q2': q2,
//       'q3': q3,
//       'q4': q4,
//     };
//   }

//   String toJson() => json.encode(toMap());

//   factory EditAddEmptyContainerData.fromJson(String source) =>
//       EditAddEmptyContainerData.fromMap(json.decode(source));
// }


// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class EditAddEmptyContainer extends StatefulWidget {
//   final EditAddEmptyContainerData data;
//   final double containerHeight;
//   final void Function(EditAddEmptyContainerData)? updateContainersDataCallback;
//   final void Function(String id) removeContainerCallback;

//   const EditAddEmptyContainer({
//     Key? key,
//     required this.containerHeight,
//     required this.data,
//     required this.updateContainersDataCallback,
//     required this.removeContainerCallback,
//   }) : super(key: key);

//   @override
//   State<EditAddEmptyContainer> createState() => _EditAddEmptyContainerState();
// }

// class _EditAddEmptyContainerState extends State<EditAddEmptyContainer> {
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
//           child: TextField(
//             textAlign: TextAlign.center,
//             controller: controller,
//             onChanged: onChangedCallback,
//             enabled: true,
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//             ),
//             keyboardType: TextInputType.number,
//             inputFormatters: [
//               FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}')),
//             ],
//             style: MyTextStyle.textStyleMap['title-Medium']
//                 ?.copyWith(color: MyColors.colorPalette['secondary']),
//             maxLines: null,
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
//                         GestureDetector(
//                           onTap: () {
//                             devtools.log('Delete operation triggered');
//                             widget.removeContainerCallback(widget.data.id);
//                             devtools.log(
//                                 'widget.data.id being passed on is ${widget.data.id}');
//                           },
//                           child: Icon(
//                             Icons.close,
//                             size: 24,
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                       ],
//                     ),
//                     TextFormField(
//                       controller: _doctorNoteController,
//                       onChanged: (value) {
//                         setState(() {
//                           widget.data.doctorNote = value;
//                         });
//                         widget.updateContainersDataCallback?.call(widget.data);
//                       },
//                       decoration: const InputDecoration(
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.all(8.0),
//                       ),
//                       maxLines: null,
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
//                   _buildQuadrant(widget.data.q1, _q1Controller, (value) {
//                     setState(() {
//                       widget.data.q1 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(widget.data.q2, _q2Controller, (value) {
//                     setState(() {
//                       widget.data.q2 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   _buildQuadrant(widget.data.q3, _q3Controller, (value) {
//                     setState(() {
//                       widget.data.q3 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(widget.data.q4, _q4Controller, (value) {
//                     setState(() {
//                       widget.data.q4 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class EditAddEmptyContainerData {
//   String id;
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;

//   EditAddEmptyContainerData({
//     required this.id,
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//   });

//   factory EditAddEmptyContainerData.fromMap(Map<String, dynamic> map) {
//     return EditAddEmptyContainerData(
//       id: map['id'] ?? '',
//       doctorNote: map['doctorNote'] ?? '',
//       q1: map['q1'] ?? '',
//       q2: map['q2'] ?? '',
//       q3: map['q3'] ?? '',
//       q4: map['q4'] ?? '',
//     );
//   }

//   @override
//   String toString() {
//     return 'EditAddEmptyContainerData(id: $id, doctorNote: $doctorNote, q1: $q1, q2: $q2, q3: $q3, q4: $q4)';
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class EditAddEmptyContainer extends StatefulWidget {
//   final EditAddEmptyContainerData data;
//   final double containerHeight;
//   final void Function(EditAddEmptyContainerData)? updateContainersDataCallback;
//   final void Function(String id) removeContainerCallback;

//   const EditAddEmptyContainer({
//     Key? key,
//     required this.containerHeight,
//     required this.data,
//     required this.updateContainersDataCallback,
//     required this.removeContainerCallback,
//   }) : super(key: key);

//   @override
//   State<EditAddEmptyContainer> createState() => _EditAddEmptyContainerState();
// }

// class _EditAddEmptyContainerState extends State<EditAddEmptyContainer> {
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
//           child: TextField(
//             textAlign: TextAlign.center,
//             controller: controller,
//             onChanged: onChangedCallback,
//             enabled: true,
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//             ),
//             keyboardType: TextInputType.number,
//             inputFormatters: [
//               FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}')),
//             ],
//             style: MyTextStyle.textStyleMap['title-Medium']
//                 ?.copyWith(color: MyColors.colorPalette['secondary']),
//             maxLines: null,
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
//                         GestureDetector(
//                           onTap: () {
//                             devtools.log('Delete operation triggered');
//                             widget.removeContainerCallback(widget.data.id);
//                             devtools.log(
//                                 'widget.data.id being passed on is ${widget.data.id}');
//                           },
//                           child: Icon(
//                             Icons.close,
//                             size: 24,
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                       ],
//                     ),
//                     TextFormField(
//                       controller: _doctorNoteController,
//                       onChanged: (value) {
//                         setState(() {
//                           widget.data.doctorNote = value;
//                         });
//                         widget.updateContainersDataCallback?.call(widget.data);
//                       },
//                       decoration: const InputDecoration(
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.all(8.0),
//                       ),
//                       maxLines: null,
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
//                   _buildQuadrant(widget.data.q1, _q1Controller, (value) {
//                     setState(() {
//                       widget.data.q1 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(widget.data.q2, _q2Controller, (value) {
//                     setState(() {
//                       widget.data.q2 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   _buildQuadrant(widget.data.q3, _q3Controller, (value) {
//                     setState(() {
//                       widget.data.q3 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(widget.data.q4, _q4Controller, (value) {
//                     setState(() {
//                       widget.data.q4 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class EditAddEmptyContainerData {
//   String id;
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;

//   EditAddEmptyContainerData({
//     required this.id,
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//   });

//   factory EditAddEmptyContainerData.fromMap(Map<String, dynamic> map) {
//     return EditAddEmptyContainerData(
//       id: map['id'] ?? '',
//       doctorNote: map['doctorNote'] ?? '',
//       q1: map['q1'] ?? '',
//       q2: map['q2'] ?? '',
//       q3: map['q3'] ?? '',
//       q4: map['q4'] ?? '',
//     );
//   }

//   @override
//   String toString() {
//     return 'EditAddEmptyContainerData(id: $id, doctorNote: $doctorNote, q1: $q1, q2: $q2, q3: $q3, q4: $q4)';
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class EditAddEmptyContainer extends StatefulWidget {
//   final EditAddEmptyContainerData data;
//   final double containerHeight;
//   final void Function(EditAddEmptyContainerData)? updateContainersDataCallback;
//   final void Function(String id) removeContainerCallback;

//   const EditAddEmptyContainer({
//     Key? key,
//     required this.containerHeight,
//     required this.data,
//     required this.updateContainersDataCallback,
//     required this.removeContainerCallback,
//   }) : super(key: key);

//   @override
//   State<EditAddEmptyContainer> createState() => _EditAddEmptyContainerState();
// }

// class _EditAddEmptyContainerState extends State<EditAddEmptyContainer> {
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
//           child: TextField(
//             textAlign: TextAlign.center,
//             controller: controller,
//             onChanged: onChangedCallback,
//             enabled: true,
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//             ),
//             keyboardType: TextInputType.number,
//             inputFormatters: [
//               FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}')),
//             ],
//             style: MyTextStyle.textStyleMap['title-Medium']
//                 ?.copyWith(color: MyColors.colorPalette['secondary']),
//             maxLines: null,
//           ),
//         ),
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
//                         GestureDetector(
//                           onTap: () {
//                             devtools.log('Delete operation triggered');
//                             widget.removeContainerCallback(widget.data.id);
//                             devtools.log(
//                                 'widget.data.id being passed on is ${widget.data.id}');
//                           },
//                           child: Icon(
//                             Icons.close,
//                             size: 24,
//                             color: MyColors.colorPalette['on-surface'],
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
//                         widget.updateContainersDataCallback?.call(widget.data);
//                       },
//                       decoration: const InputDecoration(
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.all(8.0),
//                       ),
//                       maxLines: null,
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
//                   _buildQuadrant(widget.data.q1, _q1Controller, (value) {
//                     setState(() {
//                       _q1Controller.text = value;
//                       widget.data.q1 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(widget.data.q2, _q2Controller, (value) {
//                     setState(() {
//                       _q2Controller.text = value;
//                       widget.data.q2 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   _buildQuadrant(widget.data.q3, _q3Controller, (value) {
//                     setState(() {
//                       _q3Controller.text = value;
//                       widget.data.q3 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                   const SizedBox(width: 4),
//                   _buildQuadrant(widget.data.q4, _q4Controller, (value) {
//                     setState(() {
//                       _q4Controller.text = value;
//                       widget.data.q4 = value;
//                     });
//                     widget.updateContainersDataCallback?.call(widget.data);
//                   }),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class EditAddEmptyContainerData {
//   String id;
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;

//   EditAddEmptyContainerData({
//     required this.id,
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//   });

//   factory EditAddEmptyContainerData.fromMap(Map<String, dynamic> map) {
//     return EditAddEmptyContainerData(
//       id: map['id'] ?? '',
//       doctorNote: map['doctorNote'] ?? '',
//       q1: map['q1'] ?? '',
//       q2: map['q2'] ?? '',
//       q3: map['q3'] ?? '',
//       q4: map['q4'] ?? '',
//     );
//   }

//   @override
//   String toString() {
//     return 'EditAddEmptyContainerData(id: $id, doctorNote: $doctorNote, q1: $q1, q2: $q2, q3: $q3, q4: $q4)';
//   }
// }


// class EditAddEmptyContainerData {
//   final String id;
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;

//   EditAddEmptyContainerData({
//     required this.id,
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//   });

//   // Method to create an instance from a map
//   factory EditAddEmptyContainerData.fromMap(Map<String, dynamic> map) {
//     return EditAddEmptyContainerData(
//       id: map['id'],
//       doctorNote: map['doctorNote'],
//       q1: map['q1'],
//       q2: map['q2'],
//       q3: map['q3'],
//       q4: map['q4'],
//     );
//   }

//   // Override equality operator
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is EditAddEmptyContainerData &&
//           runtimeType == other.runtimeType &&
//           id == other.id;

//   // Override hashcode
//   @override
//   int get hashCode => id.hashCode;
// }


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:math';

// class EditAddEmptyContainer extends StatefulWidget {
//   final EditAddEmptyContainerData data;
//   final double containerHeight;
//   final VoidCallback? updateContainersDataCallback;
//   final void Function(String id) removeContainerCallback;

//   const EditAddEmptyContainer({
//     Key? key,
//     required this.containerHeight,
//     required this.data,
//     required this.updateContainersDataCallback,
//     required this.removeContainerCallback,
//   }) : super(key: key);

//   @override
//   State<EditAddEmptyContainer> createState() => _EditAddEmptyContainerState();
// }

// class _EditAddEmptyContainerState extends State<EditAddEmptyContainer> {
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

// class EditAddEmptyContainerData {
//   String id;
//   String doctorNote;
//   String q1;
//   String q2;
//   String q3;
//   String q4;

//   EditAddEmptyContainerData({
//     required this.id,
//     required this.doctorNote,
//     required this.q1,
//     required this.q2,
//     required this.q3,
//     required this.q4,
//   });

//   // Add this method
//   factory EditAddEmptyContainerData.fromMap(Map<String, dynamic> map) {
//     return EditAddEmptyContainerData(
//       id: map['id'] ?? '',
//       doctorNote: map['doctorNote'] ?? '',
//       q1: map['q1'] ?? '',
//       q2: map['q2'] ?? '',
//       q3: map['q3'] ?? '',
//       q4: map['q4'] ?? '',
//     );
//   }

//   @override
//   String toString() {
//     return 'EditAddEmptyContainerData(id: $id, doctorNote: $doctorNote, q1: $q1, q2: $q2, q3: $q3, q4: $q4)';
//   }
// }
