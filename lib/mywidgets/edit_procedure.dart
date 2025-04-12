import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/procedure_service.dart';
import 'package:neocaresmileapp/mywidgets/procedure.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

class EditProcedureScreen extends StatefulWidget {
  final String clinicId;
  final Procedure procedure;
  final ProcedureService procedureService;

  const EditProcedureScreen({
    super.key,
    required this.clinicId,
    required this.procedure,
    required this.procedureService,
  });

  @override
  State<EditProcedureScreen> createState() => _EditProcedureScreenState();
}

class _EditProcedureScreenState extends State<EditProcedureScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _feeController;
  late TextEditingController _doctorNoteController;

  bool isUpdatingProcedure = false;
  bool isToothwise = true; // New field to manage tooth-specific procedures

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.procedure.procName);
    _feeController =
        TextEditingController(text: widget.procedure.procFee.toString());
    _doctorNoteController =
        TextEditingController(text: widget.procedure.doctorNote);
    isToothwise =
        widget.procedure.isToothwise; // Initialize with existing value
  }

  void _updateProcedure() async {
    if (_nameController.text.isEmpty || _feeController.text.isEmpty) {
      _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
      return;
    }

    if (isUpdatingProcedure) {
      return;
    }

    setState(() {
      isUpdatingProcedure = true;
    });

    try {
      // Populate the tooth tables with default values if they are empty
      List<int> updatedToothTable1 = widget.procedure.toothTable1.isNotEmpty
          ? widget.procedure.toothTable1
          : [
              14,
              13,
              12,
              11,
              18,
              17,
              16,
              15,
            ];
      List<int> updatedToothTable2 = widget.procedure.toothTable2.isNotEmpty
          ? widget.procedure.toothTable2
          : [
              21,
              22,
              23,
              24,
              25,
              26,
              27,
              28,
            ];
      List<int> updatedToothTable3 = widget.procedure.toothTable3.isNotEmpty
          ? widget.procedure.toothTable3
          : [
              44,
              43,
              42,
              41,
              48,
              47,
              46,
              45,
            ];
      List<int> updatedToothTable4 = widget.procedure.toothTable4.isNotEmpty
          ? widget.procedure.toothTable4
          : [
              31,
              32,
              33,
              34,
              35,
              36,
              37,
              38,
            ];

      Procedure updatedProcedure = Procedure(
        procId: widget.procedure.procId,
        procName: _nameController.text,
        procFee: double.parse(_feeController.text),
        toothTable1: updatedToothTable1,
        toothTable2: updatedToothTable2,
        toothTable3: updatedToothTable3,
        toothTable4: updatedToothTable4,
        doctorNote: _doctorNoteController.text,
        isToothwise: isToothwise, // Update the isToothwise field
      );

      await widget.procedureService.updateProcedure(updatedProcedure);

      setState(() {
        isUpdatingProcedure = false;
      });

      _showAlertDialog('Success', 'Procedure updated successfully.', () {
        Navigator.pop(context, updatedProcedure);
      });
    } catch (error) {
      setState(() {
        isUpdatingProcedure = false;
      });
      _showAlertDialog(
          'Error', 'An error occurred while updating the procedure.');
    }
  }

  void _showAlertDialog(String title, String content, [VoidCallback? onOk]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) onOk();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Procedure'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 1,
                    color:
                        MyColors.colorPalette['outline'] ?? Colors.blueAccent,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Procedure Name',
                          labelStyle: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors
                                      .colorPalette['on-surface-variant']),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: MyColors.colorPalette['primary'] ??
                                  Colors.black,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color:
                                  MyColors.colorPalette['on-surface-variant'] ??
                                      Colors.black,
                            ),
                          ),
                          contentPadding: const EdgeInsets.only(left: 8.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _feeController,
                        decoration: InputDecoration(
                          labelText: 'Procedure Fee',
                          labelStyle: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors
                                      .colorPalette['on-surface-variant']),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: MyColors.colorPalette['primary'] ??
                                  Colors.black,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color:
                                  MyColors.colorPalette['on-surface-variant'] ??
                                      Colors.black,
                            ),
                          ),
                          contentPadding: const EdgeInsets.only(left: 8.0),
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _doctorNoteController,
                        decoration: InputDecoration(
                          labelText: 'Doctor Note',
                          labelStyle: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors
                                      .colorPalette['on-surface-variant']),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color: MyColors.colorPalette['primary'] ??
                                  Colors.black,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                              color:
                                  MyColors.colorPalette['on-surface-variant'] ??
                                      Colors.black,
                            ),
                          ),
                          contentPadding: const EdgeInsets.only(left: 8.0),
                        ),
                        maxLines: 3,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Toothwise Procedure',
                            style: MyTextStyle.textStyleMap['label-large']
                                ?.copyWith(
                                    color: MyColors.colorPalette['on-surface']),
                          ),
                          Switch(
                            value: isToothwise,
                            onChanged: (bool value) {
                              setState(() {
                                isToothwise = value;
                              });
                            },
                            activeColor: MyColors.colorPalette['primary'],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 48,
                            width: 144,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    MyColors.colorPalette['primary']!),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: MyColors.colorPalette['primary']!,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                              ),
                              onPressed: _updateProcedure,
                              child: Text(
                                'Update',
                                style: MyTextStyle.textStyleMap['label-large']
                                    ?.copyWith(
                                        color: MyColors
                                            .colorPalette['on-primary']),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          if (isUpdatingProcedure)
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// code below stable with single tooth table
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/procedure_service.dart';
// import 'package:neocare_dental_app/mywidgets/procedure.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class EditProcedureScreen extends StatefulWidget {
//   final String clinicId;
//   final Procedure procedure;
//   final ProcedureService procedureService;

//   const EditProcedureScreen({
//     super.key,
//     required this.clinicId,
//     required this.procedure,
//     required this.procedureService,
//   });

//   @override
//   State<EditProcedureScreen> createState() => _EditProcedureScreenState();
// }

// class _EditProcedureScreenState extends State<EditProcedureScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   late TextEditingController _nameController;
//   late TextEditingController _feeController;
//   late TextEditingController _doctorNoteController;

//   List<int> selectedTeeth = []; // Store selected teeth numbers
//   bool isToothwise = false; // Add this field

//   bool isUpdatingProcedure = false;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.procedure.procName);
//     _feeController =
//         TextEditingController(text: widget.procedure.procFee.toString());
//     _doctorNoteController =
//         TextEditingController(text: widget.procedure.doctorNote);
//     selectedTeeth = List<int>.from(widget.procedure.toothTable);
//     isToothwise = widget.procedure.isToothwise; // Initialize isToothwise
//   }

//   void _updateProcedure() async {
//     if (_nameController.text.isEmpty || _feeController.text.isEmpty) {
//       _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
//       return;
//     }

//     if (isUpdatingProcedure) {
//       return;
//     }

//     setState(() {
//       isUpdatingProcedure = true;
//     });

//     try {
//       Procedure updatedProcedure = Procedure(
//         procId: widget.procedure.procId,
//         procName: _nameController.text,
//         procFee: double.parse(_feeController.text),
//         toothTable: selectedTeeth, // Include the updated toothTable
//         doctorNote:
//             _doctorNoteController.text, // Include the updated doctorNote
//         isToothwise: isToothwise, // Include the updated isToothwise flag
//       );

//       await widget.procedureService.updateProcedure(updatedProcedure);

//       setState(() {
//         isUpdatingProcedure = false;
//       });

//       _showAlertDialog('Success', 'Procedure updated successfully.', () {
//         Navigator.pop(context, updatedProcedure);
//       });
//     } catch (error) {
//       setState(() {
//         isUpdatingProcedure = false;
//       });
//       _showAlertDialog(
//           'Error', 'An error occurred while updating the procedure.');
//     }
//   }

//   void _showAlertDialog(String title, String content, [VoidCallback? onOk]) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               if (onOk != null) onOk();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Procedure'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Form(
//             key: _formKey,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     width: 1,
//                     color:
//                         MyColors.colorPalette['outline'] ?? Colors.blueAccent,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: TextFormField(
//                         controller: _nameController,
//                         decoration: InputDecoration(
//                           labelText: 'Procedure Name',
//                           labelStyle: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on-surface-variant']),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(8.0)),
//                             borderSide: BorderSide(
//                               color: MyColors.colorPalette['primary'] ??
//                                   Colors.black,
//                             ),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(8.0)),
//                             borderSide: BorderSide(
//                               color:
//                                   MyColors.colorPalette['on-surface-variant'] ??
//                                       Colors.black,
//                             ),
//                           ),
//                           contentPadding: const EdgeInsets.only(left: 8.0),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: TextFormField(
//                         controller: _feeController,
//                         decoration: InputDecoration(
//                           labelText: 'Procedure Fee',
//                           labelStyle: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on-surface-variant']),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(8.0)),
//                             borderSide: BorderSide(
//                               color: MyColors.colorPalette['primary'] ??
//                                   Colors.black,
//                             ),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(8.0)),
//                             borderSide: BorderSide(
//                               color:
//                                   MyColors.colorPalette['on-surface-variant'] ??
//                                       Colors.black,
//                             ),
//                           ),
//                           contentPadding: const EdgeInsets.only(left: 8.0),
//                         ),
//                         keyboardType:
//                             TextInputType.numberWithOptions(decimal: true),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: TextFormField(
//                         controller: _doctorNoteController,
//                         decoration: InputDecoration(
//                           labelText: 'Doctor Note',
//                           labelStyle: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on-surface-variant']),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(8.0)),
//                             borderSide: BorderSide(
//                               color: MyColors.colorPalette['primary'] ??
//                                   Colors.black,
//                             ),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(8.0)),
//                             borderSide: BorderSide(
//                               color:
//                                   MyColors.colorPalette['on-surface-variant'] ??
//                                       Colors.black,
//                             ),
//                           ),
//                           contentPadding: const EdgeInsets.only(left: 8.0),
//                         ),
//                         maxLines: 3,
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         children: [
//                           Text(
//                             'Toothwise Procedure',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                                     color: MyColors
//                                         .colorPalette['on-surface-variant']),
//                           ),
//                           // Switch(
//                           //   value: isToothwise,
//                           //   onChanged: (value) {
//                           //     setState(() {
//                           //       isToothwise = value;
//                           //     });
//                           //   },
//                           // ),
//                           Switch(
//                             value: isToothwise,
//                             onChanged: (value) {
//                               setState(() {
//                                 isToothwise = value;
//                               });
//                             },
//                             activeColor: MyColors.colorPalette[
//                                 'primary'], // Set the primary color here
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (isToothwise)
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Wrap(
//                           spacing: 8.0,
//                           runSpacing: 8.0,
//                           children: List.generate(48, (index) {
//                             int toothNumber =
//                                 index + 11; // Calculate tooth number
//                             return GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   if (selectedTeeth.contains(toothNumber)) {
//                                     selectedTeeth.remove(toothNumber);
//                                   } else {
//                                     selectedTeeth.add(toothNumber);
//                                   }
//                                 });
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.all(8.0),
//                                 decoration: BoxDecoration(
//                                   color: selectedTeeth.contains(toothNumber)
//                                       ? MyColors.colorPalette['primary']
//                                       : MyColors.colorPalette['surface'],
//                                   border: Border.all(
//                                     color: MyColors.colorPalette['outline'] ??
//                                         Colors.black,
//                                   ),
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 child: Text(
//                                   toothNumber.toString(),
//                                   style: MyTextStyle.textStyleMap['label-large']
//                                       ?.copyWith(color: Colors.white),
//                                 ),
//                               ),
//                             );
//                           }),
//                         ),
//                       ),
//                     const SizedBox(height: 20),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         children: [
//                           SizedBox(
//                             height: 48,
//                             width: 144,
//                             child: ElevatedButton(
//                               style: ButtonStyle(
//                                 backgroundColor: MaterialStateProperty.all(
//                                     MyColors.colorPalette['primary']!),
//                                 shape: MaterialStateProperty.all(
//                                   RoundedRectangleBorder(
//                                     side: BorderSide(
//                                       color: MyColors.colorPalette['primary']!,
//                                       width: 1.0,
//                                     ),
//                                     borderRadius: BorderRadius.circular(24.0),
//                                   ),
//                                 ),
//                               ),
//                               onPressed: _updateProcedure,
//                               child: Text(
//                                 'Update',
//                                 style: MyTextStyle.textStyleMap['label-large']
//                                     ?.copyWith(
//                                         color: MyColors
//                                             .colorPalette['on-primary']),
//                               ),
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             child: const Text('Cancel'),
//                           ),
//                           if (isUpdatingProcedure)
//                             const Center(
//                               child: CircularProgressIndicator(),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
