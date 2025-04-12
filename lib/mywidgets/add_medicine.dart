import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/medicine_service.dart';
import 'package:neocaresmileapp/mywidgets/edit_medicine.dart';
import 'package:neocaresmileapp/mywidgets/medicine.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;

class AddMedicine extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String doctorName;

  const AddMedicine({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<AddMedicine> createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _compositionController = TextEditingController();

  List<Medicine> allMedicines = [];
  List<Medicine> displayedMedicines = [];
  bool addingNewMedicine = false;
  bool isAddingMedicine = false;
  bool hasUserInput = false;
  bool showNoMatchingMedicineMessage = false;

  late MedicineService medicineService;

  @override
  void initState() {
    super.initState();
    addingNewMedicine = false;
    medicineService = MedicineService(widget.clinicId);
    _fetchAllMedicines(); // Fetch all medicines on init
  }

  Future<void> _fetchAllMedicines() async {
    allMedicines = await medicineService.getAllMedicines();
    allMedicines.sort((a, b) => a.medName.compareTo(b.medName));
    setState(() {
      displayedMedicines = allMedicines;
    });
  }

  void handleSearchInput(String userInput) {
    setState(() {
      hasUserInput = userInput.isNotEmpty;
      if (userInput.isEmpty) {
        displayedMedicines = allMedicines;
      } else {
        displayedMedicines = allMedicines
            .where((medicine) => medicine.medName
                .toLowerCase()
                .startsWith(userInput.toLowerCase()))
            .toList();
      }
    });
  }

  void handleSelectedMedicine(Medicine medicine) {
    // Navigate to edit screen with selected medicine details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicineScreen(
          clinicId: widget.clinicId,
          medicine: medicine,
          medicineService: medicineService,
        ),
      ),
    ).then((updatedMedicine) {
      if (updatedMedicine != null) {
        setState(() {
          int index = displayedMedicines
              .indexWhere((m) => m.medId == updatedMedicine.medId);
          if (index != -1) {
            displayedMedicines[index] = updatedMedicine;
          }
        });
      }
    });
  }

  void deleteMedicine(Medicine medicine) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Medicine'),
        content: Text('Are you sure you want to delete ${medicine.medName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await medicineService.deleteMedicine(medicine.medId);
              Navigator.pop(context);
              setState(() {
                displayedMedicines.remove(medicine);
              });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addNewMedicine() async {
    devtools.log('Adding new medicine');

    if (_nameController.text.isEmpty) {
      _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
      return;
    }

    if (isAddingMedicine) {
      return;
    }

    setState(() {
      isAddingMedicine = true;
    });

    try {
      Medicine newMedicine = Medicine(
        medId: '',
        medName: _nameController.text,
        composition: _compositionController.text.isNotEmpty
            ? _compositionController.text
            : null,
      );

      await medicineService.addMedicine(newMedicine);

      setState(() {
        isAddingMedicine = false;
        addingNewMedicine = false;
        _nameController.clear();
        _compositionController.clear();
        _fetchAllMedicines(); // Refresh the list after adding a new medicine
      });

      _showAlertDialog('Success', 'Medicine added successfully.');
    } catch (error) {
      devtools.log('Error adding new medicine: $error');
      _showAlertDialog('Error', 'An error occurred while adding the medicine.');
      setState(() {
        isAddingMedicine = false;
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

  Widget buildAddNewMedicineUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Add Medicine',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              addingNewMedicine = false;
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
                              labelText: 'Medicine Name',
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
                            controller: _compositionController,
                            decoration: InputDecoration(
                              labelText: 'Composition',
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
                                  onPressed: _addNewMedicine,
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
                                    addingNewMedicine = false;
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                              if (isAddingMedicine)
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

  Widget buildSearchUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Search Medicine',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              addingNewMedicine = false;
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
                  labelText: 'Enter medicine name',
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
          if (displayedMedicines.isNotEmpty) ...[
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
                            'Existing Medicines',
                            style: MyTextStyle.textStyleMap['title-large']
                                ?.copyWith(
                                    color: MyColors.colorPalette['on-surface']),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          for (var medicine in displayedMedicines)
                            InkWell(
                              onLongPress: () {
                                deleteMedicine(medicine);
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text(
                                    medicine.medName,
                                    style: MyTextStyle
                                        .textStyleMap['label-medium']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['on_surface']),
                                  ),
                                  subtitle: Text(
                                    medicine.composition ?? '',
                                    style: MyTextStyle
                                        .textStyleMap['label-medium']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['on_surface']),
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      handleSelectedMedicine(medicine);
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
                                    addingNewMedicine = true;
                                    hasUserInput = false;
                                    displayedMedicines.clear();
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
          ] else if (hasUserInput && displayedMedicines.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'No matching medicine found',
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
                      addingNewMedicine = true;
                      hasUserInput = false;
                      displayedMedicines.clear();
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
    if (addingNewMedicine) {
      return buildAddNewMedicineUI();
    }

    return buildSearchUI();
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/medicine_service.dart';
// import 'package:neocare_dental_app/mywidgets/edit_medicine.dart';
// import 'package:neocare_dental_app/mywidgets/medicine.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:developer' as devtools show log;

// class AddMedicine extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;

//   const AddMedicine({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//   });

//   @override
//   State<AddMedicine> createState() => _AddMedicineState();
// }

// class _AddMedicineState extends State<AddMedicine> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _compositionController = TextEditingController();

//   List<Medicine> matchingMedicines = [];
//   bool addingNewMedicine = false;
//   bool isAddingMedicine = false;
//   bool hasUserInput = false;
//   bool showNoMatchingMedicineMessage = false;
//   String previousSearchInput = '';

//   late MedicineService medicineService;

//   @override
//   void initState() {
//     super.initState();
//     addingNewMedicine = false;
//     medicineService = MedicineService(widget.clinicId);
//   }

//   void handleSearchInput(String userInput) async {
//     setState(() {
//       hasUserInput = userInput.isNotEmpty;
//       previousSearchInput = userInput;
//     });

//     if (userInput.isEmpty) {
//       setState(() {
//         matchingMedicines.clear();
//         return;
//       });
//     }

//     setState(() {
//       matchingMedicines.clear();
//     });

//     matchingMedicines = await medicineService.searchMedicines(userInput);
//     setState(() {});
//   }

//   void handleSelectedMedicine(Medicine medicine) {
//     // Navigate to edit screen with selected medicine details
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditMedicineScreen(
//           clinicId: widget.clinicId,
//           medicine: medicine,
//           medicineService: medicineService,
//         ),
//       ),
//     ).then((updatedMedicine) {
//       if (updatedMedicine != null) {
//         setState(() {
//           int index = matchingMedicines
//               .indexWhere((m) => m.medId == updatedMedicine.medId);
//           if (index != -1) {
//             matchingMedicines[index] = updatedMedicine;
//           }
//         });
//       }
//     });
//   }

//   void deleteMedicine(Medicine medicine) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete Medicine'),
//         content: Text('Are you sure you want to delete ${medicine.medName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               await medicineService.deleteMedicine(medicine.medId);
//               Navigator.pop(context);
//               setState(() {
//                 matchingMedicines.remove(medicine);
//               });
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _addNewMedicine() async {
//     devtools.log('Adding new medicine');

//     if (_nameController.text.isEmpty) {
//       _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
//       return;
//     }

//     if (isAddingMedicine) {
//       return;
//     }

//     setState(() {
//       isAddingMedicine = true;
//     });

//     try {
//       Medicine newMedicine = Medicine(
//         medId: '',
//         medName: _nameController.text,
//         composition: _compositionController.text.isNotEmpty
//             ? _compositionController.text
//             : null,
//       );

//       await medicineService.addMedicine(newMedicine);

//       setState(() {
//         isAddingMedicine = false;
//         addingNewMedicine = false;
//         _nameController.clear();
//         _compositionController.clear();
//         matchingMedicines.clear();
//         handleSearchInput(previousSearchInput);
//       });

//       _showAlertDialog('Success', 'Medicine added successfully.');
//     } catch (error) {
//       devtools.log('Error adding new medicine: $error');
//       _showAlertDialog('Error', 'An error occurred while adding the medicine.');
//       setState(() {
//         isAddingMedicine = false;
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

//   Widget buildAddNewMedicineUI() {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Add Medicine',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             setState(() {
//               addingNewMedicine = false;
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
//                               labelText: 'Medicine Name',
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
//                             controller: _compositionController,
//                             decoration: InputDecoration(
//                               labelText: 'Composition',
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
//                                   onPressed: _addNewMedicine,
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
//                                     addingNewMedicine = false;
//                                   });
//                                 },
//                                 child: const Text('Cancel'),
//                               ),
//                               if (isAddingMedicine)
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
//           'Search Medicine',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () {
//             setState(() {
//               addingNewMedicine = false;
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
//                   setState(() {
//                     handleSearchInput(value);
//                   });
//                 },
//                 decoration: InputDecoration(
//                   labelText: 'Enter medicine name',
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
//           if (hasUserInput && matchingMedicines.isNotEmpty) ...[
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
//                             'Existing Medicines',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on-surface']),
//                           ),
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           for (var medicine in matchingMedicines)
//                             InkWell(
//                               onLongPress: () {
//                                 deleteMedicine(medicine);
//                               },
//                               child: Card(
//                                 child: ListTile(
//                                   title: Text(
//                                     medicine.medName,
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['on_surface']),
//                                   ),
//                                   subtitle: Text(
//                                     medicine.composition ?? '',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['on_surface']),
//                                   ),
//                                   // trailing: IconButton(
//                                   //   icon: const Icon(
//                                   //     Icons.arrow_forward_ios_rounded,
//                                   //     size: 16,
//                                   //     color: Colors.white,
//                                   //   ),
//                                   //   onPressed: () {
//                                   //     handleSelectedMedicine(medicine);
//                                   //   },
//                                   // ),
//                                   trailing: GestureDetector(
//                                     onTap: () {
//                                       handleSelectedMedicine(medicine);
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
//                                     addingNewMedicine = true;
//                                     hasUserInput = false;
//                                     matchingMedicines.clear();
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
//           ] else if (hasUserInput && matchingMedicines.isEmpty) ...[
//             Padding(
//               padding: const EdgeInsets.only(
//                   left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//               child: Align(
//                 alignment: Alignment.topLeft,
//                 child: Text(
//                   'No matching medicine found',
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
//                       addingNewMedicine = true;
//                       hasUserInput = false;
//                       matchingMedicines.clear();
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
//     if (addingNewMedicine) {
//       return buildAddNewMedicineUI();
//     }

//     return buildSearchUI();
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW IS STABLE WITHOUT SEARCH BAR AND ADD NEW TOGETHER
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/medicine_service.dart';
// import 'package:neocare_dental_app/mywidgets/edit_medicine.dart';
// import 'package:neocare_dental_app/mywidgets/medicine.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:developer' as devtools show log;

// class AddMedicine extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;

//   const AddMedicine({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//   });

//   @override
//   State<AddMedicine> createState() => _AddMedicineState();
// }

// class _AddMedicineState extends State<AddMedicine> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _compositionController = TextEditingController();

//   List<Medicine> matchingMedicines = [];
//   bool addingNewMedicine = false;
//   bool isAddingMedicine = false;
//   bool hasUserInput = false;
//   bool showNoMatchingMedicineMessage = false;
//   String previousSearchInput = '';

//   late MedicineService medicineService;

//   @override
//   void initState() {
//     super.initState();
//     addingNewMedicine = false;
//     medicineService = MedicineService(widget.clinicId);
//   }

//   void handleSearchInput(String userInput) async {
//     setState(() {
//       hasUserInput = userInput.isNotEmpty;
//       previousSearchInput = userInput;
//     });

//     if (userInput.isEmpty) {
//       setState(() {
//         matchingMedicines.clear();
//         return;
//       });
//     }

//     setState(() {
//       matchingMedicines.clear();
//     });

//     matchingMedicines = await medicineService.searchMedicines(userInput);
//     setState(() {});
//   }

//   void handleSelectedMedicine(Medicine medicine) {
//     // Navigate to edit screen with selected medicine details
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditMedicineScreen(
//           clinicId: widget.clinicId,
//           medicine: medicine,
//           medicineService: medicineService,
//         ),
//       ),
//     ).then((updatedMedicine) {
//       if (updatedMedicine != null) {
//         setState(() {
//           int index = matchingMedicines
//               .indexWhere((m) => m.medId == updatedMedicine.medId);
//           if (index != -1) {
//             matchingMedicines[index] = updatedMedicine;
//           }
//         });
//       }
//     });
//   }

//   void deleteMedicine(Medicine medicine) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete Medicine'),
//         content: Text('Are you sure you want to delete ${medicine.medName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               await medicineService.deleteMedicine(medicine.medId);
//               Navigator.pop(context);
//               setState(() {
//                 matchingMedicines.remove(medicine);
//               });
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _addNewMedicine() async {
//     devtools.log('Adding new medicine');

//     if (_nameController.text.isEmpty) {
//       _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
//       return;
//     }

//     if (isAddingMedicine) {
//       return;
//     }

//     setState(() {
//       isAddingMedicine = true;
//     });

//     try {
//       Medicine newMedicine = Medicine(
//         medId: '',
//         medName: _nameController.text,
//         composition: _compositionController.text.isNotEmpty
//             ? _compositionController.text
//             : null,
//       );

//       await medicineService.addMedicine(newMedicine);

//       setState(() {
//         isAddingMedicine = false;
//         addingNewMedicine = false;
//         _nameController.clear();
//         _compositionController.clear();
//         matchingMedicines.clear();
//         handleSearchInput(previousSearchInput);
//       });

//       _showAlertDialog('Success', 'Medicine added successfully.');
//     } catch (error) {
//       devtools.log('Error adding new medicine: $error');
//       _showAlertDialog('Error', 'An error occurred while adding the medicine.');
//       setState(() {
//         isAddingMedicine = false;
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

//   // --------------------------------------------------------------------------- //
//   Widget buildAddNewMedicineUI() {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Add Medicine',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             setState(() {
//               addingNewMedicine = false;
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
//                               labelText: 'Medicine Name',
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
//                             controller: _compositionController,
//                             decoration: InputDecoration(
//                               labelText: 'Composition',
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
//                                   onPressed: _addNewMedicine,
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
//                                     addingNewMedicine = false;
//                                   });
//                                 },
//                                 child: const Text('Cancel'),
//                               ),
//                               if (isAddingMedicine)
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
//   // --------------------------------------------------------------------------- //

//   Widget buildSearchUI() {
//     if (_searchController.text.isEmpty && !addingNewMedicine && !hasUserInput) {
//       previousSearchInput = '';
//       matchingMedicines.clear();

//       return Scaffold(
//         appBar: AppBar(
//           backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//           title: Text(
//             'Search Medicine',
//             style: MyTextStyle.textStyleMap['title-large']
//                 ?.copyWith(color: MyColors.colorPalette['on-surface']),
//           ),
//           leading: IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () {
//               setState(() {
//                 addingNewMedicine = false;
//                 _searchController.clear();
//                 Navigator.pop(context);
//               });
//             },
//           ),
//         ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(
//                   left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//               child: SizedBox(
//                 child: TextField(
//                   controller: _searchController,
//                   onChanged: (value) {
//                     setState(() {
//                       handleSearchInput(value);
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Enter medicine name',
//                     labelStyle: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(
//                             color: MyColors.colorPalette['on-surface-variant']),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(8.0)),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['primary'] ?? Colors.black,
//                       ),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(8.0)),
//                       borderSide: BorderSide(
//                           color: MyColors.colorPalette['on-surface-variant'] ??
//                               Colors.black),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 8.0, horizontal: 8.0),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     } else {
//       if (previousSearchInput.isNotEmpty) {
//         return Scaffold(
//           appBar: AppBar(
//             backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//             title: Text(
//               'Search Medicine',
//               style: MyTextStyle.textStyleMap['title-large']
//                   ?.copyWith(color: MyColors.colorPalette['on-surface']),
//             ),
//             leading: IconButton(
//               icon: const Icon(Icons.close),
//               onPressed: () {
//                 setState(() {
//                   addingNewMedicine = false;
//                   _searchController.clear();
//                   Navigator.pop(context);
//                 });
//               },
//             ),
//           ),
//           body: buildPreviousSearchUI(previousSearchInput),
//         );
//       } else {
//         return Scaffold(
//           appBar: AppBar(
//             backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//             title: Text(
//               'Search Medicine',
//               style: MyTextStyle.textStyleMap['title-large']
//                   ?.copyWith(color: MyColors.colorPalette['on-surface']),
//             ),
//             leading: IconButton(
//               icon: const Icon(Icons.close),
//               onPressed: () {
//                 setState(() {
//                   addingNewMedicine = false;
//                   _searchController.clear();
//                   Navigator.pop(context);
//                 });
//               },
//             ),
//           ),
//           body: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(
//                     left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//                 child: SizedBox(
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: (value) {
//                       setState(() {
//                         handleSearchInput(value);
//                       });
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Enter medicine name',
//                       labelStyle: MyTextStyle.textStyleMap['label-large']
//                           ?.copyWith(
//                               color:
//                                   MyColors.colorPalette['on-surface-variant']),
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
//                             color:
//                                 MyColors.colorPalette['on-surface-variant'] ??
//                                     Colors.black),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 8.0, horizontal: 8.0),
//                     ),
//                   ),
//                 ),
//               ),
//               if (hasUserInput && matchingMedicines.isNotEmpty) ...[
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       padding: const EdgeInsets.only(
//                           left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Align(
//                             alignment: Alignment.topLeft,
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text(
//                                 'Existing Medicines',
//                                 style: MyTextStyle.textStyleMap['title-large']
//                                     ?.copyWith(
//                                         color: MyColors
//                                             .colorPalette['on-surface']),
//                               ),
//                             ),
//                           ),
//                           Column(
//                             children: [
//                               for (var medicine in matchingMedicines)
//                                 InkWell(
//                                   onLongPress: () {
//                                     deleteMedicine(medicine);
//                                   },
//                                   child: Card(
//                                     child: ListTile(
//                                       title: Text(
//                                         medicine.medName,
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on_surface']),
//                                       ),
//                                       subtitle: Text(
//                                         medicine.composition ?? '',
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on_surface']),
//                                       ),
//                                       trailing: IconButton(
//                                         icon: const Icon(
//                                           Icons.arrow_forward_ios_rounded,
//                                           size: 16,
//                                           color: Colors.white,
//                                         ),
//                                         onPressed: () {
//                                           handleSelectedMedicine(medicine);
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Align(
//                                   alignment: Alignment.topLeft,
//                                   child: ElevatedButton(
//                                     style: ButtonStyle(
//                                       backgroundColor:
//                                           MaterialStateProperty.all(MyColors
//                                               .colorPalette['on-primary']!),
//                                       shape: MaterialStateProperty.all(
//                                         RoundedRectangleBorder(
//                                           side: BorderSide(
//                                               color: MyColors
//                                                   .colorPalette['primary']!,
//                                               width: 1.0),
//                                           borderRadius:
//                                               BorderRadius.circular(24.0),
//                                         ),
//                                       ),
//                                     ),
//                                     onPressed: () {
//                                       setState(() {
//                                         addingNewMedicine = true;
//                                         hasUserInput = false;
//                                         matchingMedicines.clear();
//                                       });
//                                     },
//                                     child: Wrap(
//                                       children: [
//                                         Icon(
//                                           Icons.add,
//                                           color:
//                                               MyColors.colorPalette['primary'],
//                                         ),
//                                         Text(
//                                           'Add New',
//                                           style: MyTextStyle
//                                               .textStyleMap['label-large']
//                                               ?.copyWith(
//                                                   color: MyColors
//                                                       .colorPalette['primary']),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ] else if (hasUserInput && matchingMedicines.isEmpty) ...[
//                 Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//                       child: Align(
//                         alignment: Alignment.topLeft,
//                         child: Text(
//                           'No matching medicine found',
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['on_surface']),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Align(
//                         alignment: Alignment.topLeft,
//                         child: ElevatedButton(
//                           style: ButtonStyle(
//                             backgroundColor: MaterialStateProperty.all(
//                                 MyColors.colorPalette['on-primary']!),
//                             shape: MaterialStateProperty.all(
//                               RoundedRectangleBorder(
//                                 side: BorderSide(
//                                     color: MyColors.colorPalette['primary']!,
//                                     width: 1.0),
//                                 borderRadius: BorderRadius.circular(24.0),
//                               ),
//                             ),
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               addingNewMedicine = true;
//                               hasUserInput = false;
//                               matchingMedicines.clear();
//                             });
//                           },
//                           child: Wrap(
//                             children: [
//                               Icon(
//                                 Icons.add,
//                                 color: MyColors.colorPalette['primary'],
//                               ),
//                               Text(
//                                 'Add New',
//                                 style: MyTextStyle.textStyleMap['label-large']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['primary']),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ]
//             ],
//           ),
//         );
//       }
//     }
//   }

//   Widget buildPreviousSearchUI(String previousSearchInput) {
//     devtools.log('Fetching previous search results for: $previousSearchInput');

//     return FutureBuilder<List<Medicine>>(
//       future: medicineService.searchMedicines(previousSearchInput),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         } else if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         } else if (snapshot.hasData) {
//           List<Medicine> matchingMedicines = snapshot.data!;
//           return Column(
//             children: [
//               if (matchingMedicines.isNotEmpty) ...[
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: TextField(
//                             controller: _searchController,
//                             onChanged: (value) {
//                               setState(() {
//                                 handleSearchInput(value);
//                               });
//                             },
//                             decoration: InputDecoration(
//                               labelText: 'Enter medicine name',
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
//                               contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 8.0, horizontal: 8.0),
//                             ),
//                           ),
//                         ),
//                         Align(
//                           alignment: Alignment.topLeft,
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               'Existing Medicines',
//                               style: MyTextStyle.textStyleMap['title-large']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-surface']),
//                             ),
//                           ),
//                         ),
//                         SingleChildScrollView(
//                           child: Column(
//                             children: [
//                               for (var medicine in matchingMedicines)
//                                 InkWell(
//                                   onLongPress: () {
//                                     deleteMedicine(medicine);
//                                   },
//                                   child: Card(
//                                     child: ListTile(
//                                       title: Text(
//                                         medicine.medName,
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on_surface']),
//                                       ),
//                                       subtitle: Text(
//                                         medicine.composition ?? '',
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on_surface']),
//                                       ),
//                                       trailing: IconButton(
//                                         icon: const Icon(
//                                           Icons.arrow_forward_ios_rounded,
//                                           size: 16,
//                                           color: Colors.black,
//                                         ),
//                                         onPressed: () {
//                                           handleSelectedMedicine(medicine);
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Align(
//                                   alignment: Alignment.topLeft,
//                                   child: ElevatedButton(
//                                     style: ButtonStyle(
//                                       backgroundColor:
//                                           MaterialStateProperty.all(MyColors
//                                               .colorPalette['on-primary']!),
//                                       shape: MaterialStateProperty.all(
//                                         RoundedRectangleBorder(
//                                           side: BorderSide(
//                                               color: MyColors
//                                                   .colorPalette['primary']!,
//                                               width: 1.0),
//                                           borderRadius:
//                                               BorderRadius.circular(24.0),
//                                         ),
//                                       ),
//                                     ),
//                                     onPressed: () {
//                                       setState(() {
//                                         addingNewMedicine = true;
//                                         hasUserInput = false;
//                                         matchingMedicines.clear();
//                                       });
//                                     },
//                                     child: Wrap(
//                                       children: [
//                                         Icon(
//                                           Icons.add,
//                                           color:
//                                               MyColors.colorPalette['primary'],
//                                         ),
//                                         Text(
//                                           'Add New',
//                                           style: MyTextStyle
//                                               .textStyleMap['label-large']
//                                               ?.copyWith(
//                                                   color: MyColors
//                                                       .colorPalette['primary']),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ] else ...[
//                 Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         'No matching medicine found',
//                         style: MyTextStyle.textStyleMap['label-medium']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['on_surface']),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: ElevatedButton(
//                         onPressed: () {
//                           setState(() {
//                             addingNewMedicine = true;
//                             hasUserInput = false;
//                             matchingMedicines.clear();
//                           });
//                         },
//                         child: const Text('Add New'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//           );
//         } else {
//           return const SizedBox();
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (addingNewMedicine) {
//       return buildAddNewMedicineUI();
//     }

//     return buildSearchUI();
//   }
// }
