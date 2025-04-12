import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/examination_service.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/condition.dart';
import 'package:neocaresmileapp/mywidgets/edit_condition.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;
import 'package:uuid/uuid.dart';

class AddExaminationCondition extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String doctorName;

  const AddExaminationCondition({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<AddExaminationCondition> createState() =>
      _AddExaminationConditionState();
}

class _AddExaminationConditionState extends State<AddExaminationCondition> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<Condition> allConditions = [];
  List<Condition> displayedConditions = [];
  bool addingNewCondition = false;
  bool isAddingCondition = false;
  bool hasUserInput = false;
  bool isToothTable = true; // New field to manage tooth-specific conditions

  late ExaminationService examinationService;

  // @override
  // void initState() {
  //   super.initState();
  //   addingNewCondition = false;
  //   examinationService = ExaminationService(widget.clinicId);
  //   _fetchAllConditions(); // Fetch all conditions on init
  // }

  // Future<void> _fetchAllConditions() async {
  //   allConditions = await examinationService.getAllConditions();
  //   allConditions.sort((a, b) => a.conditionName.compareTo(b.conditionName));
  //   setState(() {
  //     displayedConditions = allConditions;
  //   });
  //   devtools.log(
  //       'Welcome to _fetchAllConditions. Fetched Conditions are $displayedConditions');
  // }

  //---------------------------------------------------------------------------//
  @override
  void initState() {
    super.initState();

    // Initialize ExaminationService with the initial clinicId
    examinationService =
        ExaminationService(ClinicSelection.instance.selectedClinicId);

    // Add listener for clinic selection changes
    ClinicSelection.instance.addListener(_onClinicChanged);

    // Fetch conditions for the initial clinic
    _fetchAllConditions();
  }

  @override
  void dispose() {
    ClinicSelection.instance.removeListener(_onClinicChanged);
    super.dispose();
  }

  void _onClinicChanged() {
    // Update the ExaminationService with the new clinicId
    examinationService
        .updateClinicId(ClinicSelection.instance.selectedClinicId);

    // Re-fetch the conditions based on the new clinic
    _fetchAllConditions();
  }

  Future<void> _fetchAllConditions() async {
    allConditions = await examinationService.getAllConditions();
    setState(() {
      displayedConditions = allConditions;
    });
  }

  //---------------------------------------------------------------------------//

  void handleSearchInput(String userInput) {
    setState(() {
      hasUserInput = userInput.isNotEmpty;
      if (userInput.isEmpty) {
        displayedConditions = allConditions;
      } else {
        displayedConditions = allConditions
            .where((condition) => condition.conditionName
                .toLowerCase()
                .startsWith(userInput.toLowerCase()))
            .toList();
      }
    });
  }

  void handleSelectedCondition(Condition condition) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditConditionScreen(
          clinicId: widget.clinicId,
          condition: condition,
          examinationService: examinationService,
        ),
      ),
    ).then((updatedCondition) {
      if (updatedCondition != null) {
        setState(() {
          int index = displayedConditions
              .indexWhere((c) => c.conditionId == updatedCondition.conditionId);
          if (index != -1) {
            displayedConditions[index] = updatedCondition;
          }
        });
      }
    });
  }

  void deleteCondition(Condition condition) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Condition'),
        content:
            Text('Are you sure you want to delete ${condition.conditionName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await examinationService.deleteCondition(condition.conditionId);
              Navigator.pop(context);
              setState(() {
                displayedConditions.remove(condition);
              });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addNewCondition() async {
    devtools.log('Adding new condition');

    if (_nameController.text.isEmpty) {
      _showAlertDialog('Invalid Input', 'Please fill in the condition name.');
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

      List<int> flatToothTable1 = isToothTable
          ? [
              14,
              13,
              12,
              11,
              18,
              17,
              16,
              15,
            ]
          : [];
      List<int> flatToothTable2 = isToothTable
          ? [
              21,
              22,
              23,
              24,
              25,
              26,
              27,
              28,
            ]
          : [];
      List<int> flatToothTable3 = isToothTable
          ? [
              44,
              43,
              42,
              41,
              48,
              47,
              46,
              45,
            ]
          : [];
      List<int> flatToothTable4 = isToothTable
          ? [
              31,
              32,
              33,
              34,
              35,
              36,
              37,
              38,
            ]
          : [];

      Condition newCondition = Condition(
        conditionId: conditionId,
        conditionName: _nameController.text,
        toothTable1: flatToothTable1,
        toothTable2: flatToothTable2,
        toothTable3: flatToothTable3,
        toothTable4: flatToothTable4,
        doctorNote: '',
        isToothTable: isToothTable, // Add isToothTable field here
      );

      await examinationService.addCondition(newCondition);

      setState(() {
        isAddingCondition = false;
        addingNewCondition = false;
        _nameController.clear();
        _fetchAllConditions(); // Refresh the list after adding a new condition
      });

      _showAlertDialog('Success', 'Condition added successfully.');
    } catch (error) {
      devtools.log('Error adding new condition: $error');
      _showAlertDialog(
          'Error', 'An error occurred while adding the condition.');
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

  Widget buildAddNewConditionUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Add Condition',
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
                      labelText: 'Condition Name',
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

  // Widget buildSearchUI() {
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: MyColors.colorPalette['surface-container-lowest'],
  //       title: Text(
  //         'Search Condition',
  //         style: MyTextStyle.textStyleMap['title-large']
  //             ?.copyWith(color: MyColors.colorPalette['on-surface']),
  //       ),
  //       leading: IconButton(
  //         icon: const Icon(Icons.close),
  //         onPressed: () {
  //           setState(() {
  //             addingNewCondition = false;
  //             _searchController.clear();
  //             Navigator.pop(context);
  //           });
  //         },
  //       ),
  //     ),
  //     body: Column(
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.only(
  //               left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
  //           child: SizedBox(
  //             child: TextField(
  //               controller: _searchController,
  //               onChanged: (value) {
  //                 handleSearchInput(value);
  //               },
  //               decoration: InputDecoration(
  //                 labelText: 'Enter condition name',
  //                 labelStyle: MyTextStyle.textStyleMap['label-large']?.copyWith(
  //                     color: MyColors.colorPalette['on-surface-variant']),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: const BorderRadius.all(Radius.circular(8.0)),
  //                   borderSide: BorderSide(
  //                     color: MyColors.colorPalette['primary'] ?? Colors.black,
  //                   ),
  //                 ),
  //                 border: OutlineInputBorder(
  //                   borderRadius: const BorderRadius.all(Radius.circular(8.0)),
  //                   borderSide: BorderSide(
  //                       color: MyColors.colorPalette['on-surface-variant'] ??
  //                           Colors.black),
  //                 ),
  //                 contentPadding: const EdgeInsets.symmetric(
  //                     vertical: 8.0, horizontal: 8.0),
  //               ),
  //             ),
  //           ),
  //         ),
  //         if (displayedConditions.isNotEmpty) ...[
  //           Expanded(
  //             child: SingleChildScrollView(
  //               child: Padding(
  //                 padding: const EdgeInsets.only(
  //                     left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Align(
  //                       alignment: Alignment.topLeft,
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Text(
  //                           'Existing Conditions',
  //                           style: MyTextStyle.textStyleMap['title-large']
  //                               ?.copyWith(
  //                                   color: MyColors.colorPalette['on-surface']),
  //                         ),
  //                       ),
  //                     ),
  //                     Column(
  //                       children: [
  //                         for (var condition in displayedConditions)
  //                           InkWell(
  //                             onLongPress: () {
  //                               deleteCondition(condition);
  //                             },
  //                             child: Card(
  //                               child: ListTile(
  //                                 title: Text(
  //                                   condition.conditionName,
  //                                   style: MyTextStyle
  //                                       .textStyleMap['label-medium']
  //                                       ?.copyWith(
  //                                           color: MyColors
  //                                               .colorPalette['on_surface']),
  //                                 ),
  //                                 subtitle: Text(
  //                                   'Condition ID: ${condition.conditionId}',
  //                                   style: MyTextStyle
  //                                       .textStyleMap['label-medium']
  //                                       ?.copyWith(
  //                                           color: MyColors
  //                                               .colorPalette['on_surface']),
  //                                 ),
  //                                 trailing: GestureDetector(
  //                                   onTap: () {
  //                                     handleSelectedCondition(condition);
  //                                   },
  //                                   child: CircleAvatar(
  //                                     radius: 13.33,
  //                                     backgroundColor:
  //                                         MyColors.colorPalette['surface'] ??
  //                                             Colors.blueAccent,
  //                                     child: const Icon(
  //                                       Icons.arrow_forward_ios_rounded,
  //                                       size: 16,
  //                                       color: Colors.white,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Align(
  //                             alignment: Alignment.topLeft,
  //                             child: ElevatedButton(
  //                               style: ButtonStyle(
  //                                 backgroundColor: MaterialStateProperty.all(
  //                                     MyColors.colorPalette['on-primary']!),
  //                                 shape: MaterialStateProperty.all(
  //                                   RoundedRectangleBorder(
  //                                     side: BorderSide(
  //                                         color:
  //                                             MyColors.colorPalette['primary']!,
  //                                         width: 1.0),
  //                                     borderRadius: BorderRadius.circular(24.0),
  //                                   ),
  //                                 ),
  //                               ),
  //                               onPressed: () {
  //                                 setState(() {
  //                                   addingNewCondition = true;
  //                                   hasUserInput = false;
  //                                   displayedConditions.clear();
  //                                 });
  //                               },
  //                               child: Wrap(
  //                                 children: [
  //                                   Icon(
  //                                     Icons.add,
  //                                     color: MyColors.colorPalette['primary'],
  //                                   ),
  //                                   Text(
  //                                     'Add New',
  //                                     style: MyTextStyle
  //                                         .textStyleMap['label-large']
  //                                         ?.copyWith(
  //                                             color: MyColors
  //                                                 .colorPalette['primary']),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ] else if (hasUserInput && displayedConditions.isEmpty) ...[
  //           Padding(
  //             padding: const EdgeInsets.only(
  //                 left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
  //             child: Align(
  //               alignment: Alignment.topLeft,
  //               child: Text(
  //                 'No matching condition found',
  //                 style: MyTextStyle.textStyleMap['label-medium']
  //                     ?.copyWith(color: MyColors.colorPalette['on_surface']),
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Align(
  //               alignment: Alignment.topLeft,
  //               child: ElevatedButton(
  //                 style: ButtonStyle(
  //                   backgroundColor: MaterialStateProperty.all(
  //                       MyColors.colorPalette['on-primary']!),
  //                   shape: MaterialStateProperty.all(
  //                     RoundedRectangleBorder(
  //                       side: BorderSide(
  //                           color: MyColors.colorPalette['primary']!,
  //                           width: 1.0),
  //                       borderRadius: BorderRadius.circular(24.0),
  //                     ),
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   setState(() {
  //                     addingNewCondition = true;
  //                     hasUserInput = false;
  //                     displayedConditions.clear();
  //                   });
  //                 },
  //                 child: Wrap(
  //                   children: [
  //                     Icon(
  //                       Icons.add,
  //                       color: MyColors.colorPalette['primary'],
  //                     ),
  //                     Text(
  //                       'Add New',
  //                       style: MyTextStyle.textStyleMap['label-large']
  //                           ?.copyWith(color: MyColors.colorPalette['primary']),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ]
  //       ],
  //     ),
  //   );
  // }

  Widget buildSearchUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Search Condition',
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
                  labelText: 'Enter condition name',
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
                            'Existing Conditions',
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
                                deleteCondition(condition);
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text(
                                    condition.conditionName,
                                    style: MyTextStyle
                                        .textStyleMap['label-medium']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['on_surface']),
                                  ),
                                  subtitle: Text(
                                    'Condition ID: ${condition.conditionId}',
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
                  'No matching condition found',
                  style: MyTextStyle.textStyleMap['label-medium']
                      ?.copyWith(color: MyColors.colorPalette['on_surface']),
                ),
              ),
            ),
          ],
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
                          color: MyColors.colorPalette['primary']!, width: 1.0),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (addingNewCondition) {
      return buildAddNewConditionUI();
    }

    return buildSearchUI();
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// code below stable with single toothtable 
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/examination_service.dart';
// import 'package:neocare_dental_app/mywidgets/condition.dart';
// import 'package:neocare_dental_app/mywidgets/edit_condition.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:developer' as devtools show log;
// import 'package:uuid/uuid.dart';

// class AddExaminationCondition extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;

//   const AddExaminationCondition({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//   });

//   @override
//   State<AddExaminationCondition> createState() =>
//       _AddExaminationConditionState();
// }

// class _AddExaminationConditionState extends State<AddExaminationCondition> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();

//   List<Condition> allConditions = [];
//   List<Condition> displayedConditions = [];
//   bool addingNewCondition = false;
//   bool isAddingCondition = false;
//   bool hasUserInput = false;
//   bool isToothTable = true; // New field to manage tooth-specific conditions

//   late ExaminationService examinationService;

//   @override
//   void initState() {
//     super.initState();
//     addingNewCondition = false;
//     examinationService = ExaminationService(widget.clinicId);
//     _fetchAllConditions(); // Fetch all conditions on init
//   }

//   Future<void> _fetchAllConditions() async {
//     allConditions = await examinationService.getAllConditions();
//     allConditions.sort((a, b) => a.conditionName.compareTo(b.conditionName));
//     setState(() {
//       displayedConditions = allConditions;
//     });
//   }

//   void handleSearchInput(String userInput) {
//     setState(() {
//       hasUserInput = userInput.isNotEmpty;
//       if (userInput.isEmpty) {
//         displayedConditions = allConditions;
//       } else {
//         displayedConditions = allConditions
//             .where((condition) => condition.conditionName
//                 .toLowerCase()
//                 .startsWith(userInput.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   void handleSelectedCondition(Condition condition) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditConditionScreen(
//           clinicId: widget.clinicId,
//           condition: condition,
//           examinationService: examinationService,
//         ),
//       ),
//     ).then((updatedCondition) {
//       if (updatedCondition != null) {
//         setState(() {
//           int index = displayedConditions
//               .indexWhere((c) => c.conditionId == updatedCondition.conditionId);
//           if (index != -1) {
//             displayedConditions[index] = updatedCondition;
//           }
//         });
//       }
//     });
//   }

//   void deleteCondition(Condition condition) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Condition'),
//         content:
//             Text('Are you sure you want to delete ${condition.conditionName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               await examinationService.deleteCondition(condition.conditionId);
//               Navigator.pop(context);
//               setState(() {
//                 displayedConditions.remove(condition);
//               });
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _addNewCondition() async {
//     devtools.log('Adding new condition');

//     if (_nameController.text.isEmpty) {
//       _showAlertDialog('Invalid Input', 'Please fill in the condition name.');
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

//       // List<int> flatToothTable = isToothTable
//       //     ? [
//       //         11,
//       //         12,
//       //         13,
//       //         14,
//       //         15,
//       //         16,
//       //         17,
//       //         18,
//       //         21,
//       //         22,
//       //         23,
//       //         24,
//       //         25,
//       //         26,
//       //         27,
//       //         28,
//       //         31,
//       //         32,
//       //         33,
//       //         34,
//       //         35,
//       //         36,
//       //         37,
//       //         38,
//       //         41,
//       //         42,
//       //         43,
//       //         44,
//       //         45,
//       //         46,
//       //         47,
//       //         48
//       //       ]
//       //     : [];
//       List<int> flatToothTable = isToothTable
//           ? [
//               14,
//               13,
//               12,
//               11,
//               21,
//               22,
//               23,
//               24,
//               18,
//               17,
//               16,
//               15,
//               25,
//               26,
//               27,
//               28,
//               44,
//               43,
//               42,
//               41,
//               31,
//               32,
//               33,
//               34,
//               48,
//               47,
//               46,
//               45,
//               35,
//               36,
//               37,
//               38,
//             ]
//           : [];
//       // List<int> flatToothTable1 = isToothTable
//       //     ? [
//       //         14,
//       //         13,
//       //         12,
//       //         11,
//       //         18,
//       //         17,
//       //         16,
//       //         15,
//       //       ]
//       //     : [];
//       // List<int> flatToothTable2 = isToothTable
//       //     ? [
//       //         21,
//       //         22,
//       //         23,
//       //         24,
//       //         25,
//       //         26,
//       //         27,
//       //         28,
//       //       ]
//       //     : [];
//       // List<int> flatToothTable3 = isToothTable
//       //     ? [
//       //         44,
//       //         43,
//       //         42,
//       //         41,
//       //         48,
//       //         47,
//       //         46,
//       //         45,
//       //       ]
//       //     : [];
//       // List<int> flatToothTable4 = isToothTable
//       //     ? [
//       //         31,
//       //         32,
//       //         33,
//       //         34,
//       //         35,
//       //         36,
//       //         37,
//       //         38,
//       //       ]
//       //     : [];

//       Condition newCondition = Condition(
//         conditionId: conditionId,
//         conditionName: _nameController.text,
//         toothTable: flatToothTable,
//         doctorNote: '',
//         isToothTable: isToothTable, // Add isToothTable field here
//       );

//       await examinationService.addCondition(newCondition);

//       setState(() {
//         isAddingCondition = false;
//         addingNewCondition = false;
//         _nameController.clear();
//         _fetchAllConditions(); // Refresh the list after adding a new condition
//       });

//       _showAlertDialog('Success', 'Condition added successfully.');
//     } catch (error) {
//       devtools.log('Error adding new condition: $error');
//       _showAlertDialog(
//           'Error', 'An error occurred while adding the condition.');
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

//   Widget buildAddNewConditionUI() {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Add Condition',
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
//                       labelText: 'Condition Name',
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
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Is Tooth-Specific?',
//                         style: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['on-surface']),
//                       ),
//                       Switch(
//                         value: isToothTable,
//                         onChanged: (bool value) {
//                           setState(() {
//                             isToothTable = value;
//                           });
//                         },
//                       ),
//                     ],
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
//           'Search Condition',
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
//                   labelText: 'Enter condition name',
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
//                             'Existing Conditions',
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
//                                 deleteCondition(condition);
//                               },
//                               child: Card(
//                                 child: ListTile(
//                                   title: Text(
//                                     condition.conditionName,
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['on_surface']),
//                                   ),
//                                   subtitle: Text(
//                                     'Condition ID: ${condition.conditionId}',
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
//                   'No matching condition found',
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
//       return buildAddNewConditionUI();
//     }

//     return buildSearchUI();
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/examination_service.dart';
// import 'package:neocare_dental_app/mywidgets/condition.dart';
// import 'package:neocare_dental_app/mywidgets/edit_condition.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:developer' as devtools show log;
// import 'package:uuid/uuid.dart';

// class AddExaminationCondition extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;

//   const AddExaminationCondition({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//   });

//   @override
//   State<AddExaminationCondition> createState() =>
//       _AddExaminationConditionState();
// }

// class _AddExaminationConditionState extends State<AddExaminationCondition> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();

//   List<Condition> allConditions = [];
//   List<Condition> displayedConditions = [];
//   bool addingNewCondition = false;
//   bool isAddingCondition = false;
//   bool hasUserInput = false;
//   bool isToothTable = true; // New field to manage tooth-specific conditions

//   late ExaminationService examinationService;

//   @override
//   void initState() {
//     super.initState();
//     addingNewCondition = false;
//     examinationService = ExaminationService(widget.clinicId);
//     _fetchAllConditions(); // Fetch all conditions on init
//   }

//   Future<void> _fetchAllConditions() async {
//     allConditions = await examinationService.getAllConditions();
//     allConditions.sort((a, b) => a.conditionName.compareTo(b.conditionName));
//     setState(() {
//       displayedConditions = allConditions;
//     });
//   }

//   void handleSearchInput(String userInput) {
//     setState(() {
//       hasUserInput = userInput.isNotEmpty;
//       if (userInput.isEmpty) {
//         displayedConditions = allConditions;
//       } else {
//         displayedConditions = allConditions
//             .where((condition) => condition.conditionName
//                 .toLowerCase()
//                 .startsWith(userInput.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   void handleSelectedCondition(Condition condition) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditConditionScreen(
//           clinicId: widget.clinicId,
//           condition: condition,
//           examinationService: examinationService,
//         ),
//       ),
//     ).then((updatedCondition) {
//       if (updatedCondition != null) {
//         setState(() {
//           int index = displayedConditions
//               .indexWhere((c) => c.conditionId == updatedCondition.conditionId);
//           if (index != -1) {
//             displayedConditions[index] = updatedCondition;
//           }
//         });
//       }
//     });
//   }

//   void deleteCondition(Condition condition) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Condition'),
//         content:
//             Text('Are you sure you want to delete ${condition.conditionName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               await examinationService.deleteCondition(condition.conditionId);
//               Navigator.pop(context);
//               setState(() {
//                 displayedConditions.remove(condition);
//               });
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _addNewCondition() async {
//     devtools.log('Adding new condition');

//     if (_nameController.text.isEmpty) {
//       _showAlertDialog('Invalid Input', 'Please fill in the condition name.');
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

//       // List<int> flatToothTable = isToothTable
//       //     ? [
//       //         11,
//       //         12,
//       //         13,
//       //         14,
//       //         15,
//       //         16,
//       //         17,
//       //         18,
//       //         21,
//       //         22,
//       //         23,
//       //         24,
//       //         25,
//       //         26,
//       //         27,
//       //         28,
//       //         31,
//       //         32,
//       //         33,
//       //         34,
//       //         35,
//       //         36,
//       //         37,
//       //         38,
//       //         41,
//       //         42,
//       //         43,
//       //         44,
//       //         45,
//       //         46,
//       //         47,
//       //         48
//       //       ]
//       //     : [];
//       List<int> flatToothTable = isToothTable
//           ? [
//               14,
//               13,
//               12,
//               11,
//               21,
//               22,
//               23,
//               24,
//               18,
//               17,
//               16,
//               15,
//               25,
//               26,
//               27,
//               28,
//               44,
//               43,
//               42,
//               41,
//               31,
//               32,
//               33,
//               34,
//               48,
//               47,
//               46,
//               45,
//               35,
//               36,
//               37,
//               38,
//             ]
//           : [];

//       Condition newCondition = Condition(
//         conditionId: conditionId,
//         conditionName: _nameController.text,
//         toothTable: flatToothTable,
//         doctorNote: '',
//         isToothTable: isToothTable, // Add isToothTable field here
//       );

//       await examinationService.addCondition(newCondition);

//       setState(() {
//         isAddingCondition = false;
//         addingNewCondition = false;
//         _nameController.clear();
//         _fetchAllConditions(); // Refresh the list after adding a new condition
//       });

//       _showAlertDialog('Success', 'Condition added successfully.');
//     } catch (error) {
//       devtools.log('Error adding new condition: $error');
//       _showAlertDialog(
//           'Error', 'An error occurred while adding the condition.');
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

//   Widget buildAddNewConditionUI() {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Add Condition',
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
//                       labelText: 'Condition Name',
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
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Is Tooth-Specific?',
//                         style: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['on-surface']),
//                       ),
//                       Switch(
//                         value: isToothTable,
//                         onChanged: (bool value) {
//                           setState(() {
//                             isToothTable = value;
//                           });
//                         },
//                       ),
//                     ],
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
//           'Search Condition',
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
//                   labelText: 'Enter condition name',
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
//                             'Existing Conditions',
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
//                                 deleteCondition(condition);
//                               },
//                               child: Card(
//                                 child: ListTile(
//                                   title: Text(
//                                     condition.conditionName,
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['on_surface']),
//                                   ),
//                                   subtitle: Text(
//                                     'Condition ID: ${condition.conditionId}',
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
//                   'No matching condition found',
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
//       return buildAddNewConditionUI();
//     }

//     return buildSearchUI();
//   }
// }
