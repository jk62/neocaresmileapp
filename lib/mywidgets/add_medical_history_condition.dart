import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/medical_history_service.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/edit_medical_condition.dart';
import 'package:neocaresmileapp/mywidgets/medical_condition.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;
import 'package:uuid/uuid.dart';

class AddMedicalHistoryCondition extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String doctorName;

  const AddMedicalHistoryCondition({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<AddMedicalHistoryCondition> createState() =>
      _AddMedicalHistoryConditionState();
}

class _AddMedicalHistoryConditionState
    extends State<AddMedicalHistoryCondition> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<MedicalCondition> allConditions = [];
  List<MedicalCondition> displayedConditions = [];
  bool addingNewCondition = false;
  bool isAddingCondition = false;
  bool hasUserInput = false;

  late MedicalHistoryService medicalHistoryService;

  // @override
  // void initState() {
  //   super.initState();
  //   addingNewCondition = false;
  //   medicalHistoryService = MedicalHistoryService(widget.clinicId);
  //   _fetchAllMedicalConditions();
  // }
  //---------------------------------//
  @override
  void initState() {
    super.initState();
    medicalHistoryService = MedicalHistoryService(
        widget.clinicId); // Initialize with passed clinicId
    _fetchAllMedicalConditions(); // Initial fetch for conditions

    // Listen for clinic changes
    ClinicSelection.instance.addListener(_onClinicChanged);
  }

  @override
  void dispose() {
    ClinicSelection.instance
        .removeListener(_onClinicChanged); // Prevent memory leaks
    super.dispose();
  }

// Called when the selected clinic changes
  void _onClinicChanged() {
    setState(() {
      displayedConditions.clear(); // Clear the displayed conditions list
    });
    _fetchAllMedicalConditions(); // Fetch conditions for the new clinic
  }

  //---------------------------------//

  Future<void> _fetchAllMedicalConditions() async {
    allConditions = await medicalHistoryService.getAllMedicalConditions();
    allConditions.sort(
        (a, b) => a.medicalConditionName.compareTo(b.medicalConditionName));
    setState(() {
      displayedConditions = allConditions;
    });
    devtools.log(
        'Welcome to _fetchAllMedicalConditions. Fetched Medical Conditions are $displayedConditions');
  }

  void handleSearchInput(String userInput) {
    setState(() {
      hasUserInput = userInput.isNotEmpty;
      if (userInput.isEmpty) {
        displayedConditions = allConditions;
      } else {
        displayedConditions = allConditions
            .where((condition) => condition.medicalConditionName
                .toLowerCase()
                .startsWith(userInput.toLowerCase()))
            .toList();
      }
    });
  }

  void handleSelectedCondition(MedicalCondition condition) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicalCondition(
          clinicId: widget.clinicId,
          condition: condition,
          medicalHistoryService: medicalHistoryService,
        ),
      ),
    ).then((updatedCondition) {
      if (updatedCondition != null) {
        setState(() {
          int index = displayedConditions.indexWhere((c) =>
              c.medicalConditionId == updatedCondition.medicalConditionId);
          if (index != -1) {
            displayedConditions[index] = updatedCondition;
          }
        });
      }
    });
  }

  void deleteMedicalCondition(MedicalCondition condition) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medical Condition'),
        content: Text(
            'Are you sure you want to delete ${condition.medicalConditionName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // User cancels
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // User confirms
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // If the user confirms deletion
    if (shouldDelete == true) {
      await medicalHistoryService
          .deleteMedicalCondition(condition.medicalConditionId);

      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        displayedConditions.remove(condition);
      });

      // Only pop the navigator if the widget is still mounted
      Navigator.pop(context);
    }
  }

  void _addNewCondition() async {
    devtools.log('Adding new medical condition');

    if (_nameController.text.isEmpty) {
      _showAlertDialog(
          'Invalid Input', 'Please fill in the medical condition name.');
      return;
    }

    if (isAddingCondition) {
      return;
    }

    setState(() {
      isAddingCondition = true;
    });

    try {
      var uuid = const Uuid();
      String conditionId = uuid.v4();

      MedicalCondition newCondition = MedicalCondition(
        medicalConditionId: conditionId,
        medicalConditionName: _nameController.text,
        doctorNote: '',
      );

      await medicalHistoryService.addMedicalCondition(newCondition);

      setState(() {
        isAddingCondition = false;
        addingNewCondition = false;
        _nameController.clear();
        _fetchAllMedicalConditions();
      });

      _showAlertDialog('Success', 'Medical Condition added successfully.');
    } catch (error) {
      devtools.log('Error adding new medical condition: $error');
      _showAlertDialog(
          'Error', 'An error occurred while adding the medical condition.');
      setState(() {
        isAddingCondition = false;
      });
    }
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget buildAddNewMedicalConditionUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Add Medical Condition',
          style: MyTextStyle.textStyleMap['title-large']?.copyWith(
            color: MyColors.colorPalette['on-surface'],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              addingNewCondition = false;
            });
          },
          color: MyColors.colorPalette['on-surface'],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Medical Condition Name',
                      labelStyle:
                          MyTextStyle.textStyleMap['label-large']?.copyWith(
                        color: MyColors.colorPalette['on-surface-variant'],
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(
                          color:
                              MyColors.colorPalette['primary'] ?? Colors.black,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(
                          color: MyColors.colorPalette['on-surface-variant'] ??
                              Colors.black,
                        ),
                      ),
                      contentPadding: const EdgeInsets.only(left: 8.0),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
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
                          onPressed: _addNewCondition,
                          child: Text(
                            'Add',
                            style: MyTextStyle.textStyleMap['label-large']
                                ?.copyWith(
                              color: MyColors.colorPalette['on-primary'],
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            addingNewCondition = false;
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                      if (isAddingCondition)
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
    );
  }

  Widget buildSearchUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Search Medical Condition',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              addingNewCondition = false;
              _searchController.clear();
              Navigator.pop(context);
            });
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
            child: SizedBox(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  handleSearchInput(value);
                },
                decoration: InputDecoration(
                  labelText: 'Enter Medical condition name',
                  labelStyle: MyTextStyle.textStyleMap['label-large']?.copyWith(
                      color: MyColors.colorPalette['on-surface-variant']),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                      color: MyColors.colorPalette['primary'] ?? Colors.black,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                        color: MyColors.colorPalette['on-surface-variant'] ??
                            Colors.black),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
                ),
              ),
            ),
          ),
          if (displayedConditions.isNotEmpty) ...[
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Existing Medical Conditions',
                            style: MyTextStyle.textStyleMap['title-large']
                                ?.copyWith(
                                    color: MyColors.colorPalette['on-surface']),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          for (var condition in displayedConditions)
                            InkWell(
                              onLongPress: () {
                                deleteMedicalCondition(condition);
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text(
                                    condition.medicalConditionName,
                                    style: MyTextStyle
                                        .textStyleMap['label-medium']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['on_surface']),
                                  ),
                                  subtitle: Text(
                                    'Medical Condition ID: ${condition.medicalConditionId}',
                                    style: MyTextStyle
                                        .textStyleMap['label-medium']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['on_surface']),
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      handleSelectedCondition(condition);
                                    },
                                    child: CircleAvatar(
                                      radius: 13.33,
                                      backgroundColor:
                                          MyColors.colorPalette['surface'] ??
                                              Colors.blueAccent,
                                      child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      MyColors.colorPalette['on-primary']!),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      side: BorderSide(
                                          color:
                                              MyColors.colorPalette['primary']!,
                                          width: 1.0),
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    addingNewCondition = true;
                                    hasUserInput = false;
                                    displayedConditions.clear();
                                  });
                                },
                                child: Wrap(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: MyColors.colorPalette['primary'],
                                    ),
                                    Text(
                                      'Add New',
                                      style: MyTextStyle
                                          .textStyleMap['label-large']
                                          ?.copyWith(
                                              color: MyColors
                                                  .colorPalette['primary']),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else if (hasUserInput && displayedConditions.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'No matching medical condition found',
                  style: MyTextStyle.textStyleMap['label-medium']
                      ?.copyWith(color: MyColors.colorPalette['on_surface']),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        MyColors.colorPalette['on-primary']!),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        side: BorderSide(
                            color: MyColors.colorPalette['primary']!,
                            width: 1.0),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      addingNewCondition = true;
                      hasUserInput = false;
                      displayedConditions.clear();
                    });
                  },
                  child: Wrap(
                    children: [
                      Icon(
                        Icons.add,
                        color: MyColors.colorPalette['primary'],
                      ),
                      Text(
                        'Add New',
                        style: MyTextStyle.textStyleMap['label-large']
                            ?.copyWith(color: MyColors.colorPalette['primary']),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (addingNewCondition) {
      return buildAddNewMedicalConditionUI();
    }

    return buildSearchUI();
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/medical_history_service.dart';
// import 'package:neocare_dental_app/mywidgets/edit_medical_condition.dart';
// import 'package:neocare_dental_app/mywidgets/medical_condition.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:developer' as devtools show log;
// import 'package:uuid/uuid.dart';

// class AddMedicalHistoryCondition extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;

//   const AddMedicalHistoryCondition({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//   });

//   @override
//   State<AddMedicalHistoryCondition> createState() =>
//       _AddMedicalHistoryConditionState();
// }

// class _AddMedicalHistoryConditionState
//     extends State<AddMedicalHistoryCondition> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();

//   List<MedicalCondition> allConditions = [];
//   List<MedicalCondition> displayedConditions = [];
//   bool addingNewCondition = false;
//   bool isAddingCondition = false;
//   bool hasUserInput = false;

//   late MedicalHistoryService medicalHistoryService;

//   @override
//   void initState() {
//     super.initState();
//     addingNewCondition = false;
//     medicalHistoryService = MedicalHistoryService(widget.clinicId);
//     _fetchAllMedicalConditions();
//   }

//   Future<void> _fetchAllMedicalConditions() async {
//     allConditions = await medicalHistoryService.getAllMedicalConditions();
//     allConditions.sort(
//         (a, b) => a.medicalConditionName.compareTo(b.medicalConditionName));
//     setState(() {
//       displayedConditions = allConditions;
//     });
//     devtools.log(
//         'Welcome to _fetchAllMedicalConditions. Fetched Medical Conditions are $displayedConditions');
//   }

//   void handleSearchInput(String userInput) {
//     setState(() {
//       hasUserInput = userInput.isNotEmpty;
//       if (userInput.isEmpty) {
//         displayedConditions = allConditions;
//       } else {
//         displayedConditions = allConditions
//             .where((condition) => condition.medicalConditionName
//                 .toLowerCase()
//                 .startsWith(userInput.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   void handleSelectedCondition(MedicalCondition condition) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditMedicalCondition(
//           clinicId: widget.clinicId,
//           condition: condition,
//           medicalHistoryService: medicalHistoryService,
//         ),
//       ),
//     ).then((updatedCondition) {
//       if (updatedCondition != null) {
//         setState(() {
//           int index = displayedConditions.indexWhere((c) =>
//               c.medicalConditionId == updatedCondition.medicalConditionId);
//           if (index != -1) {
//             displayedConditions[index] = updatedCondition;
//           }
//         });
//       }
//     });
//   }

//   void deleteMedicalCondition(MedicalCondition condition) async {
//     bool? shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Medical Condition'),
//         content: Text(
//             'Are you sure you want to delete ${condition.medicalConditionName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false), // User cancels
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true), // User confirms
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     // If the user confirms deletion
//     if (shouldDelete == true) {
//       await medicalHistoryService
//           .deleteMedicalCondition(condition.medicalConditionId);

//       if (!mounted) return; // Check if the widget is still mounted

//       setState(() {
//         displayedConditions.remove(condition);
//       });

//       // Only pop the navigator if the widget is still mounted
//       Navigator.pop(context);
//     }
//   }

//   void _addNewCondition() async {
//     devtools.log('Adding new medical condition');

//     if (_nameController.text.isEmpty) {
//       _showAlertDialog(
//           'Invalid Input', 'Please fill in the medical condition name.');
//       return;
//     }

//     if (isAddingCondition) {
//       return;
//     }

//     setState(() {
//       isAddingCondition = true;
//     });

//     try {
//       var uuid = const Uuid();
//       String conditionId = uuid.v4();

//       MedicalCondition newCondition = MedicalCondition(
//         medicalConditionId: conditionId,
//         medicalConditionName: _nameController.text,
//         doctorNote: '',
//       );

//       await medicalHistoryService.addMedicalCondition(newCondition);

//       setState(() {
//         isAddingCondition = false;
//         addingNewCondition = false;
//         _nameController.clear();
//         _fetchAllMedicalConditions();
//       });

//       _showAlertDialog('Success', 'Medical Condition added successfully.');
//     } catch (error) {
//       devtools.log('Error adding new medical condition: $error');
//       _showAlertDialog(
//           'Error', 'An error occurred while adding the medical condition.');
//       setState(() {
//         isAddingCondition = false;
//       });
//     }
//   }

//   void _showAlertDialog(String title, String content) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildAddNewMedicalConditionUI() {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Add Medical Condition',
//           style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//             color: MyColors.colorPalette['on-surface'],
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             setState(() {
//               addingNewCondition = false;
//             });
//           },
//           color: MyColors.colorPalette['on-surface'],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextFormField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       labelText: 'Medical Condition Name',
//                       labelStyle:
//                           MyTextStyle.textStyleMap['label-large']?.copyWith(
//                         color: MyColors.colorPalette['on-surface-variant'],
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(8.0)),
//                         borderSide: BorderSide(
//                           color:
//                               MyColors.colorPalette['primary'] ?? Colors.black,
//                         ),
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(8.0)),
//                         borderSide: BorderSide(
//                           color: MyColors.colorPalette['on-surface-variant'] ??
//                               Colors.black,
//                         ),
//                       ),
//                       contentPadding: const EdgeInsets.only(left: 8.0),
//                     ),
//                     onChanged: (_) => setState(() {}),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         height: 48,
//                         width: 144,
//                         child: ElevatedButton(
//                           style: ButtonStyle(
//                             backgroundColor: MaterialStateProperty.all(
//                                 MyColors.colorPalette['primary']!),
//                             shape: MaterialStateProperty.all(
//                               RoundedRectangleBorder(
//                                 side: BorderSide(
//                                   color: MyColors.colorPalette['primary']!,
//                                   width: 1.0,
//                                 ),
//                                 borderRadius: BorderRadius.circular(24.0),
//                               ),
//                             ),
//                           ),
//                           onPressed: _addNewCondition,
//                           child: Text(
//                             'Add',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                               color: MyColors.colorPalette['on-primary'],
//                             ),
//                           ),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           setState(() {
//                             addingNewCondition = false;
//                           });
//                         },
//                         child: const Text('Cancel'),
//                       ),
//                       if (isAddingCondition)
//                         const Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildSearchUI() {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Search Medical Condition',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () {
//             setState(() {
//               addingNewCondition = false;
//               _searchController.clear();
//               Navigator.pop(context);
//             });
//           },
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(
//                 left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//             child: SizedBox(
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: (value) {
//                   handleSearchInput(value);
//                 },
//                 decoration: InputDecoration(
//                   labelText: 'Enter Medical condition name',
//                   labelStyle: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                       color: MyColors.colorPalette['on-surface-variant']),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: const BorderRadius.all(Radius.circular(8.0)),
//                     borderSide: BorderSide(
//                       color: MyColors.colorPalette['primary'] ?? Colors.black,
//                     ),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: const BorderRadius.all(Radius.circular(8.0)),
//                     borderSide: BorderSide(
//                         color: MyColors.colorPalette['on-surface-variant'] ??
//                             Colors.black),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                       vertical: 8.0, horizontal: 8.0),
//                 ),
//               ),
//             ),
//           ),
//           if (displayedConditions.isNotEmpty) ...[
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                       left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Align(
//                         alignment: Alignment.topLeft,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'Existing Medical Conditions',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on-surface']),
//                           ),
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           for (var condition in displayedConditions)
//                             InkWell(
//                               onLongPress: () {
//                                 deleteMedicalCondition(condition);
//                               },
//                               child: Card(
//                                 child: ListTile(
//                                   title: Text(
//                                     condition.medicalConditionName,
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['on_surface']),
//                                   ),
//                                   subtitle: Text(
//                                     'Medical Condition ID: ${condition.medicalConditionId}',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['on_surface']),
//                                   ),
//                                   trailing: GestureDetector(
//                                     onTap: () {
//                                       handleSelectedCondition(condition);
//                                     },
//                                     child: CircleAvatar(
//                                       radius: 13.33,
//                                       backgroundColor:
//                                           MyColors.colorPalette['surface'] ??
//                                               Colors.blueAccent,
//                                       child: const Icon(
//                                         Icons.arrow_forward_ios_rounded,
//                                         size: 16,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Align(
//                               alignment: Alignment.topLeft,
//                               child: ElevatedButton(
//                                 style: ButtonStyle(
//                                   backgroundColor: MaterialStateProperty.all(
//                                       MyColors.colorPalette['on-primary']!),
//                                   shape: MaterialStateProperty.all(
//                                     RoundedRectangleBorder(
//                                       side: BorderSide(
//                                           color:
//                                               MyColors.colorPalette['primary']!,
//                                           width: 1.0),
//                                       borderRadius: BorderRadius.circular(24.0),
//                                     ),
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     addingNewCondition = true;
//                                     hasUserInput = false;
//                                     displayedConditions.clear();
//                                   });
//                                 },
//                                 child: Wrap(
//                                   children: [
//                                     Icon(
//                                       Icons.add,
//                                       color: MyColors.colorPalette['primary'],
//                                     ),
//                                     Text(
//                                       'Add New',
//                                       style: MyTextStyle
//                                           .textStyleMap['label-large']
//                                           ?.copyWith(
//                                               color: MyColors
//                                                   .colorPalette['primary']),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ] else if (hasUserInput && displayedConditions.isEmpty) ...[
//             Padding(
//               padding: const EdgeInsets.only(
//                   left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//               child: Align(
//                 alignment: Alignment.topLeft,
//                 child: Text(
//                   'No matching medical condition found',
//                   style: MyTextStyle.textStyleMap['label-medium']
//                       ?.copyWith(color: MyColors.colorPalette['on_surface']),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Align(
//                 alignment: Alignment.topLeft,
//                 child: ElevatedButton(
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all(
//                         MyColors.colorPalette['on-primary']!),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         side: BorderSide(
//                             color: MyColors.colorPalette['primary']!,
//                             width: 1.0),
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       addingNewCondition = true;
//                       hasUserInput = false;
//                       displayedConditions.clear();
//                     });
//                   },
//                   child: Wrap(
//                     children: [
//                       Icon(
//                         Icons.add,
//                         color: MyColors.colorPalette['primary'],
//                       ),
//                       Text(
//                         'Add New',
//                         style: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(color: MyColors.colorPalette['primary']),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ]
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (addingNewCondition) {
//       return buildAddNewMedicalConditionUI();
//     }

//     return buildSearchUI();
//   }
// }
