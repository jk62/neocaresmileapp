import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/procedure_service.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/edit_procedure.dart';
import 'package:neocaresmileapp/mywidgets/procedure.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;
import 'package:uuid/uuid.dart';

class AddProcedure extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String doctorName;

  const AddProcedure({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<AddProcedure> createState() => _AddProcedureState();
}

class _AddProcedureState extends State<AddProcedure> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();

  List<Procedure> allProcedures = [];
  List<Procedure> displayedProcedures = [];
  bool addingNewProcedure = false;
  bool isAddingProcedure = false;
  bool hasUserInput = false;
  bool isToothwise = true; // Manage tooth-specific procedures

  late ProcedureService procedureService;

  // @override
  // void initState() {
  //   super.initState();
  //   addingNewProcedure = false;
  //   procedureService = ProcedureService(widget.clinicId);
  //   _fetchAllProcedures(); // Fetch all procedures on init
  // }
  //-----------------------------------------------------------//
  @override
  void initState() {
    super.initState();

    procedureService =
        ProcedureService(ClinicSelection.instance.selectedClinicId);
    ClinicSelection.instance.addListener(_onClinicChanged);
    _fetchAllProcedures();
  }

  void _onClinicChanged() {
    procedureService.updateClinicId(ClinicSelection.instance.selectedClinicId);
    _fetchAllProcedures();
  }

  @override
  void dispose() {
    ClinicSelection.instance.removeListener(_onClinicChanged);
    super.dispose();
  }

  //-----------------------------------------------------------//

  Future<void> _fetchAllProcedures() async {
    allProcedures = await procedureService.getAllProcedures();
    allProcedures.sort((a, b) => a.procName.compareTo(b.procName));
    setState(() {
      displayedProcedures = allProcedures;
    });
  }

  void handleSearchInput(String userInput) {
    setState(() {
      hasUserInput = userInput.isNotEmpty;
      if (userInput.isEmpty) {
        displayedProcedures = allProcedures;
      } else {
        displayedProcedures = allProcedures
            .where((procedure) => procedure.procName
                .toLowerCase()
                .startsWith(userInput.toLowerCase()))
            .toList();
      }
    });
  }

  void handleSelectedProcedure(Procedure procedure) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProcedureScreen(
          clinicId: widget.clinicId,
          procedure: procedure,
          procedureService: procedureService,
        ),
      ),
    ).then((updatedProcedure) {
      if (updatedProcedure != null) {
        setState(() {
          int index = displayedProcedures
              .indexWhere((p) => p.procId == updatedProcedure.procId);
          if (index != -1) {
            displayedProcedures[index] = updatedProcedure;
          }
        });
      }
    });
  }

  void deleteProcedure(Procedure procedure) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Procedure'),
        content: Text('Are you sure you want to delete ${procedure.procName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await procedureService.deleteProcedure(procedure.procId);
              Navigator.pop(context);
              setState(() {
                displayedProcedures.remove(procedure);
              });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addNewProcedure() async {
    devtools.log('Adding new procedure');
    // Check if the fee is empty, and if so, set it to 0
    double fee =
        _feeController.text.isEmpty ? 0.0 : double.parse(_feeController.text);

    if (_nameController.text.isEmpty || _feeController.text.isEmpty) {
      _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
      return;
    }

    if (isAddingProcedure) {
      return;
    }

    setState(() {
      isAddingProcedure = true;
    });

    try {
      var uuid = const Uuid();
      String procId = uuid.v4();

      List<int> flatToothTable1 = isToothwise
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
      List<int> flatToothTable2 = isToothwise
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
      List<int> flatToothTable3 = isToothwise
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
      List<int> flatToothTable4 = isToothwise
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

      Procedure newProcedure = Procedure(
        procId: procId,
        procName: _nameController.text,
        procFee: fee,
        toothTable1: flatToothTable1,
        toothTable2: flatToothTable2,
        toothTable3: flatToothTable3,
        toothTable4: flatToothTable4,
        doctorNote: '', // Leave doctorNote empty at this stage
        isToothwise: isToothwise, // Add isToothwise field here
      );

      await procedureService.addProcedure(newProcedure);

      setState(() {
        isAddingProcedure = false;
        addingNewProcedure = false;
        _nameController.clear();
        _feeController.clear();
        _fetchAllProcedures(); // Refresh the list after adding a new procedure
      });

      _showAlertDialog('Success', 'Procedure added successfully.');
    } catch (error) {
      devtools.log('Error adding new procedure: $error');
      _showAlertDialog(
          'Error', 'An error occurred while adding the procedure.');
      setState(() {
        isAddingProcedure = false;
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
  //------------------------------------------//

  //------------------------------------------//

  Widget buildAddNewProcedureUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Add Procedure',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              addingNewProcedure = false;
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
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: 1,
                        color: MyColors.colorPalette['outline'] ??
                            Colors.blueAccent,
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
                              labelStyle: MyTextStyle
                                  .textStyleMap['label-large']
                                  ?.copyWith(
                                      color: MyColors
                                          .colorPalette['on-surface-variant']),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                  color: MyColors.colorPalette['primary'] ??
                                      Colors.black,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                  color: MyColors
                                          .colorPalette['on-surface-variant'] ??
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
                          child: TextFormField(
                            controller: _feeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Fee',
                              labelStyle: MyTextStyle
                                  .textStyleMap['label-large']
                                  ?.copyWith(
                                      color: MyColors
                                          .colorPalette['on-surface-variant']),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                  color: MyColors.colorPalette['primary'] ??
                                      Colors.black,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                  color: MyColors
                                          .colorPalette['on-surface-variant'] ??
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
                                        color: MyColors
                                            .colorPalette['on-surface']),
                              ),
                              Switch(
                                value: isToothwise,
                                onChanged: (bool value) {
                                  setState(() {
                                    isToothwise = value;
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
                                          color:
                                              MyColors.colorPalette['primary']!,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: _addNewProcedure,
                                  child: Text(
                                    'Add',
                                    style: MyTextStyle
                                        .textStyleMap['label-large']
                                        ?.copyWith(
                                      color:
                                          MyColors.colorPalette['on-primary'],
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    addingNewProcedure = false;
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                              if (isAddingProcedure)
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
              ],
            ),
          ),
        ),
      ),
    );
  }
  //---------------------------------------------//

  //---------------------------------------------//

  Widget buildSearchUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Search Procedure',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              addingNewProcedure = false;
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
                  labelText: 'Enter procedure name',
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
          if (displayedProcedures.isNotEmpty) ...[
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
                            'Existing Procedures',
                            style: MyTextStyle.textStyleMap['title-large']
                                ?.copyWith(
                                    color: MyColors.colorPalette['on-surface']),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          for (var procedure in displayedProcedures)
                            InkWell(
                              onLongPress: () {
                                deleteProcedure(procedure);
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text(
                                    procedure.procName,
                                    style: MyTextStyle
                                        .textStyleMap['label-medium']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['on_surface']),
                                  ),
                                  subtitle: Text(
                                    procedure.procFee.toString(),
                                    style: MyTextStyle
                                        .textStyleMap['label-medium']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['on_surface']),
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      handleSelectedProcedure(procedure);
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
                                    addingNewProcedure = true;
                                    hasUserInput = false;
                                    displayedProcedures.clear();
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
          ] else if (hasUserInput && displayedProcedures.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'No matching procedure found',
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
                      addingNewProcedure = true;
                      hasUserInput = false;
                      displayedProcedures.clear();
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
  //-----------------------------------------------------------------------------//

  //-----------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    if (addingNewProcedure) {
      return buildAddNewProcedureUI();
    }

    return buildSearchUI();
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// code below stable with single tooth table
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/procedure_service.dart';
// import 'package:neocare_dental_app/mywidgets/edit_procedure.dart';
// import 'package:neocare_dental_app/mywidgets/procedure.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:developer' as devtools show log;

// class AddProcedure extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;

//   const AddProcedure({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//   });

//   @override
//   State<AddProcedure> createState() => _AddProcedureState();
// }

// class _AddProcedureState extends State<AddProcedure> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _feeController = TextEditingController();

//   List<Procedure> allProcedures = [];
//   List<Procedure> displayedProcedures = [];
//   List<int> toothTable = [];
//   bool addingNewProcedure = false;
//   bool isAddingProcedure = false;
//   bool hasUserInput = false;

//   late ProcedureService procedureService;

//   @override
//   void initState() {
//     super.initState();
//     addingNewProcedure = false;
//     procedureService = ProcedureService(widget.clinicId);
//     _fetchAllProcedures(); // Fetch all procedures on init

//     // Initialize toothTable with a flat list of tooth numbers (can be customized as needed)
//     toothTable = [
//       11,
//       12,
//       13,
//       14,
//       15,
//       16,
//       17,
//       18,
//       21,
//       22,
//       23,
//       24,
//       25,
//       26,
//       27,
//       28,
//       31,
//       32,
//       33,
//       34,
//       35,
//       36,
//       37,
//       38,
//       41,
//       42,
//       43,
//       44,
//       45,
//       46,
//       47,
//       48
//     ];
//   }

//   Future<void> _fetchAllProcedures() async {
//     allProcedures = await procedureService.getAllProcedures();
//     allProcedures.sort((a, b) => a.procName.compareTo(b.procName));
//     setState(() {
//       displayedProcedures = allProcedures;
//     });
//   }

//   void handleSearchInput(String userInput) {
//     setState(() {
//       hasUserInput = userInput.isNotEmpty;
//       if (userInput.isEmpty) {
//         displayedProcedures = allProcedures;
//       } else {
//         displayedProcedures = allProcedures
//             .where((procedure) => procedure.procName
//                 .toLowerCase()
//                 .startsWith(userInput.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   void handleSelectedProcedure(Procedure procedure) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditProcedureScreen(
//           clinicId: widget.clinicId,
//           procedure: procedure,
//           procedureService: procedureService,
//         ),
//       ),
//     ).then((updatedProcedure) {
//       if (updatedProcedure != null) {
//         setState(() {
//           int index = displayedProcedures
//               .indexWhere((p) => p.procId == updatedProcedure.procId);
//           if (index != -1) {
//             displayedProcedures[index] = updatedProcedure;
//           }
//         });
//       }
//     });
//   }

//   void deleteProcedure(Procedure procedure) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete Procedure'),
//         content: Text('Are you sure you want to delete ${procedure.procName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               await procedureService.deleteProcedure(procedure.procId);
//               Navigator.pop(context);
//               setState(() {
//                 displayedProcedures.remove(procedure);
//               });
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _addNewProcedure() async {
//     devtools.log('Adding new procedure');
//     // Check if the fee is empty, and if so, set it to 0
//     double fee =
//         _feeController.text.isEmpty ? 0.0 : double.parse(_feeController.text);

//     if (_nameController.text.isEmpty || _feeController.text.isEmpty) {
//       _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
//       return;
//     }

//     if (isAddingProcedure) {
//       return;
//     }

//     setState(() {
//       isAddingProcedure = true;
//     });

//     try {
//       Procedure newProcedure = Procedure(
//         procId: '',
//         procName: _nameController.text,
//         //procFee: double.parse(_feeController.text),
//         procFee: fee,
//         toothTable: toothTable,
//         doctorNote: '', // Leave doctorNote empty at this stage
//       );

//       await procedureService.addProcedure(newProcedure);

//       setState(() {
//         isAddingProcedure = false;
//         addingNewProcedure = false;
//         _nameController.clear();
//         _feeController.clear();
//         _fetchAllProcedures(); // Refresh the list after adding a new procedure
//       });

//       _showAlertDialog('Success', 'Procedure added successfully.');
//     } catch (error) {
//       devtools.log('Error adding new procedure: $error');
//       _showAlertDialog(
//           'Error', 'An error occurred while adding the procedure.');
//       setState(() {
//         isAddingProcedure = false;
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

//   Widget buildAddNewProcedureUI() {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Add Procedure',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             setState(() {
//               addingNewProcedure = false;
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
//                   padding: const EdgeInsets.only(
//                       left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         width: 1,
//                         color: MyColors.colorPalette['outline'] ??
//                             Colors.blueAccent,
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: TextFormField(
//                             controller: _nameController,
//                             decoration: InputDecoration(
//                               labelText: 'Procedure Name',
//                               labelStyle: MyTextStyle
//                                   .textStyleMap['label-large']
//                                   ?.copyWith(
//                                       color: MyColors
//                                           .colorPalette['on-surface-variant']),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(
//                                     Radius.circular(8.0)),
//                                 borderSide: BorderSide(
//                                   color: MyColors.colorPalette['primary'] ??
//                                       Colors.black,
//                                 ),
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(
//                                     Radius.circular(8.0)),
//                                 borderSide: BorderSide(
//                                   color: MyColors
//                                           .colorPalette['on-surface-variant'] ??
//                                       Colors.black,
//                                 ),
//                               ),
//                               contentPadding: const EdgeInsets.only(left: 8.0),
//                             ),
//                             onChanged: (_) => setState(() {}),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: TextFormField(
//                             controller: _feeController,
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               labelText: 'Fee',
//                               labelStyle: MyTextStyle
//                                   .textStyleMap['label-large']
//                                   ?.copyWith(
//                                       color: MyColors
//                                           .colorPalette['on-surface-variant']),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(
//                                     Radius.circular(8.0)),
//                                 borderSide: BorderSide(
//                                   color: MyColors.colorPalette['primary'] ??
//                                       Colors.black,
//                                 ),
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(
//                                     Radius.circular(8.0)),
//                                 borderSide: BorderSide(
//                                   color: MyColors
//                                           .colorPalette['on-surface-variant'] ??
//                                       Colors.black,
//                                 ),
//                               ),
//                               contentPadding: const EdgeInsets.only(left: 8.0),
//                             ),
//                             onChanged: (_) => setState(() {}),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: [
//                               SizedBox(
//                                 height: 48,
//                                 width: 144,
//                                 child: ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor: MaterialStateProperty.all(
//                                         MyColors.colorPalette['primary']!),
//                                     shape: MaterialStateProperty.all(
//                                       RoundedRectangleBorder(
//                                         side: BorderSide(
//                                           color:
//                                               MyColors.colorPalette['primary']!,
//                                           width: 1.0,
//                                         ),
//                                         borderRadius:
//                                             BorderRadius.circular(24.0),
//                                       ),
//                                     ),
//                                   ),
//                                   onPressed: _addNewProcedure,
//                                   child: Text(
//                                     'Add',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-large']
//                                         ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-primary'],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     addingNewProcedure = false;
//                                   });
//                                 },
//                                 child: const Text('Cancel'),
//                               ),
//                               if (isAddingProcedure)
//                                 const Center(
//                                   child: CircularProgressIndicator(),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
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
//           'Search Procedure',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () {
//             setState(() {
//               addingNewProcedure = false;
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
//                   labelText: 'Enter procedure name',
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
//           if (displayedProcedures.isNotEmpty) ...[
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
//                             'Existing Procedures',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on-surface']),
//                           ),
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           for (var procedure in displayedProcedures)
//                             InkWell(
//                               onLongPress: () {
//                                 deleteProcedure(procedure);
//                               },
//                               child: Card(
//                                 child: ListTile(
//                                   title: Text(
//                                     procedure.procName,
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['on_surface']),
//                                   ),
//                                   subtitle: Text(
//                                     procedure.procFee.toString(),
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['on_surface']),
//                                   ),
//                                   trailing: GestureDetector(
//                                     onTap: () {
//                                       handleSelectedProcedure(procedure);
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
//                                     addingNewProcedure = true;
//                                     hasUserInput = false;
//                                     displayedProcedures.clear();
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
//           ] else if (hasUserInput && displayedProcedures.isEmpty) ...[
//             Padding(
//               padding: const EdgeInsets.only(
//                   left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//               child: Align(
//                 alignment: Alignment.topLeft,
//                 child: Text(
//                   'No matching procedure found',
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
//                       addingNewProcedure = true;
//                       hasUserInput = false;
//                       displayedProcedures.clear();
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
//     if (addingNewProcedure) {
//       return buildAddNewProcedureUI();
//     }

//     return buildSearchUI();
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
