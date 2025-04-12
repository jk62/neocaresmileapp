import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/examination_service.dart';
import 'package:neocaresmileapp/mywidgets/condition.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

class EditConditionScreen extends StatefulWidget {
  final String clinicId;
  final Condition condition;
  final ExaminationService examinationService;

  const EditConditionScreen({
    super.key,
    required this.clinicId,
    required this.condition,
    required this.examinationService,
  });

  @override
  State<EditConditionScreen> createState() => _EditConditionScreenState();
}

class _EditConditionScreenState extends State<EditConditionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  bool isUpdatingCondition = false;
  bool isToothTable = true; // New field to manage tooth-specific conditions

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.condition.conditionName);
    isToothTable =
        widget.condition.isToothTable; // Initialize with existing value
  }

  void _updateCondition() async {
    if (_nameController.text.isEmpty) {
      _showAlertDialog('Invalid Input', 'Please fill in the condition name.');
      return;
    }

    if (isUpdatingCondition) {
      return;
    }

    setState(() {
      isUpdatingCondition = true;
    });

    try {
      // Populate the tooth tables with default values if they are empty
      List<int> updatedToothTable1 = widget.condition.toothTable1.isNotEmpty
          ? widget.condition.toothTable1
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
      List<int> updatedToothTable2 = widget.condition.toothTable2.isNotEmpty
          ? widget.condition.toothTable2
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
      List<int> updatedToothTable3 = widget.condition.toothTable3.isNotEmpty
          ? widget.condition.toothTable3
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
      List<int> updatedToothTable4 = widget.condition.toothTable4.isNotEmpty
          ? widget.condition.toothTable4
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

      Condition updatedCondition = Condition(
        conditionId: widget.condition.conditionId,
        conditionName: _nameController.text,
        toothTable1: updatedToothTable1,
        toothTable2: updatedToothTable2,
        toothTable3: updatedToothTable3,
        toothTable4: updatedToothTable4,
        doctorNote: widget.condition.doctorNote,
        isToothTable: isToothTable, // Update the isToothTable field
      );

      await widget.examinationService.updateCondition(updatedCondition);

      setState(() {
        isUpdatingCondition = false;
      });

      _showAlertDialog('Success', 'Condition updated successfully.', () {
        Navigator.pop(context, updatedCondition);
      });
    } catch (error) {
      setState(() {
        isUpdatingCondition = false;
      });
      _showAlertDialog(
          'Error', 'An error occurred while updating the condition.');
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
        title: const Text('Edit Condition'),
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
                          labelText: 'Condition Name',
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
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Is Tooth-Specific?',
                            style: MyTextStyle.textStyleMap['label-large']
                                ?.copyWith(
                                    color: MyColors.colorPalette['on-surface']),
                          ),
                          Switch(
                            value: isToothTable,
                            onChanged: (bool value) {
                              setState(() {
                                isToothTable = value;
                              });
                            },
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
                              onPressed: _updateCondition,
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
                          if (isUpdatingCondition)
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

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// code below stable with single toothtable
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/examination_service.dart';
// import 'package:neocare_dental_app/mywidgets/condition.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class EditConditionScreen extends StatefulWidget {
//   final String clinicId;
//   final Condition condition;
//   final ExaminationService examinationService;

//   const EditConditionScreen({
//     super.key,
//     required this.clinicId,
//     required this.condition,
//     required this.examinationService,
//   });

//   @override
//   State<EditConditionScreen> createState() => _EditConditionScreenState();
// }

// class _EditConditionScreenState extends State<EditConditionScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   late TextEditingController _nameController;
//   bool isUpdatingCondition = false;
//   bool isToothTable = true; // New field to manage tooth-specific conditions

//   @override
//   void initState() {
//     super.initState();
//     _nameController =
//         TextEditingController(text: widget.condition.conditionName);
//     isToothTable =
//         widget.condition.isToothTable; // Initialize with existing value
//   }

//   void _updateCondition() async {
//     if (_nameController.text.isEmpty) {
//       _showAlertDialog('Invalid Input', 'Please fill in the condition name.');
//       return;
//     }

//     if (isUpdatingCondition) {
//       return;
//     }

//     setState(() {
//       isUpdatingCondition = true;
//     });

//     try {
//       // If the condition is not tooth-specific, clear the toothTable
//       List<int> updatedToothTable =
//           isToothTable ? widget.condition.toothTable : [];

//       Condition updatedCondition = Condition(
//         conditionId: widget.condition.conditionId,
//         conditionName: _nameController.text,
//         toothTable: updatedToothTable,
//         doctorNote: widget.condition.doctorNote,
//         isToothTable: isToothTable, // Update the isToothTable field
//       );

//       await widget.examinationService.updateCondition(updatedCondition);

//       setState(() {
//         isUpdatingCondition = false;
//       });

//       _showAlertDialog('Success', 'Condition updated successfully.', () {
//         Navigator.pop(context, updatedCondition);
//       });
//     } catch (error) {
//       setState(() {
//         isUpdatingCondition = false;
//       });
//       _showAlertDialog(
//           'Error', 'An error occurred while updating the condition.');
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
//         title: const Text('Edit Condition'),
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
//                           labelText: 'Condition Name',
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
//                     const SizedBox(height: 20),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Is Tooth-Specific?',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on-surface']),
//                           ),
//                           Switch(
//                             value: isToothTable,
//                             onChanged: (bool value) {
//                               setState(() {
//                                 isToothTable = value;
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
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
//                               onPressed: _updateCondition,
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
//                           if (isUpdatingCondition)
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
