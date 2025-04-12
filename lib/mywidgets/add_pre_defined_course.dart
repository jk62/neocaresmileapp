import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neocaresmileapp/firestore/medicine_service.dart';
import 'package:neocaresmileapp/mywidgets/medicine.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/pre_defined_courses.dart';
import 'package:neocaresmileapp/mywidgets/edit_pre_defined_course.dart';
import 'dart:developer' as devtools show log;

import 'package:uuid/uuid.dart';

class AddPreDefinedCourse extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String doctorName;

  const AddPreDefinedCourse({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<AddPreDefinedCourse> createState() => _AddPreDefinedCourseState();
}

class _AddPreDefinedCourseState extends State<AddPreDefinedCourse> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _daysControllers = [];
  final List<TextEditingController> _instructionsControllers = [];

  bool isAddingCourse = false;
  bool addingNewCourse = false;
  bool hasUserInput = false;

  List<Medicine> selectedMedicines = [];
  List<PreDefinedCourse> allCourses = [];
  List<PreDefinedCourse> displayedCourses = [];
  late MedicineService medicineService;

  final List<bool> _morningCheckboxValues = [];
  final List<bool> _afternoonCheckboxValues = [];
  final List<bool> _eveningCheckboxValues = [];
  final List<bool> _sosRadioValues = [];

  @override
  // void initState() {
  //   super.initState();
  //   addingNewCourse = false;
  //   medicineService = MedicineService(widget.clinicId);
  //   _fetchAllCourses(); // Fetch all courses on init
  // }
  @override
  void initState() {
    super.initState();
    medicineService = MedicineService(widget.clinicId);
    devtools
        .log("Initialized MedicineService with clinicId: ${widget.clinicId}");
    _fetchAllCourses(); // Initial fetch
  }

  // void _fetchAllCourses() async {
  //   allCourses = await medicineService.getPreDefinedCourses();
  //   setState(() {
  //     displayedCourses = allCourses;
  //   });
  // }
  //--------------------------------------------//
  // void _fetchAllCourses() async {
  //   // Fetch courses specifically for the selected clinic
  //   allCourses = await MedicineService(widget.clinicId).getPreDefinedCourses();
  //   setState(() {
  //     displayedCourses = allCourses;
  //   });
  // }

  void _fetchAllCourses() async {
    // Log the current clinicId before fetching courses
    devtools.log("Fetching courses for clinicId: ${medicineService.clinicId}");

    // Fetch courses specifically for the selected clinic
    allCourses = await medicineService.getPreDefinedCourses();

    setState(() {
      displayedCourses = allCourses;
      // Log the number of courses fetched to confirm if the data is updated
      devtools.log("Number of courses fetched: ${allCourses.length}");
    });
  }

  void onClinicChanged(String newClinicId) {
    setState(() {
      // Update medicineService with the new clinic ID
      medicineService = MedicineService(newClinicId);
      devtools.log("Updated clinic ID in MedicineService: $newClinicId");

      // Fetch courses for the new clinic immediately after updating
      _fetchAllCourses();
    });
  }

  //--------------------------------------------//

  void handleSearchInput(String userInput) {
    setState(() {
      hasUserInput = userInput.isNotEmpty;
      if (userInput.isEmpty) {
        displayedCourses = allCourses;
      } else {
        displayedCourses = allCourses
            .where((course) =>
                course.name.toLowerCase().contains(userInput.toLowerCase()))
            .toList();
      }
    });
  }

  // void handleSelectedCourse(PreDefinedCourse course) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => EditPreDefinedCourse(
  //         clinicId: widget.clinicId,
  //         course: course,
  //         medicineService: medicineService,
  //       ),
  //     ),
  //   ).then((updatedCourse) {
  //     if (updatedCourse != null) {
  //       setState(() {
  //         int index =
  //             displayedCourses.indexWhere((c) => c.id == updatedCourse.id);
  //         if (index != -1) {
  //           displayedCourses[index] = updatedCourse;
  //         }
  //       });
  //     }
  //   });
  // }

  void handleSelectedCourse(PreDefinedCourse course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPreDefinedCourse(
          clinicId:
              medicineService.clinicId, // Use current medicineService clinicId
          course: course,
          medicineService: medicineService,
        ),
      ),
    ).then((updatedCourse) {
      if (updatedCourse != null) {
        setState(() {
          int index =
              displayedCourses.indexWhere((c) => c.id == updatedCourse.id);
          if (index != -1) {
            displayedCourses[index] = updatedCourse;
          }
        });
      }
    });
  }

  void deleteCourse(PreDefinedCourse course) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete ${course.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await medicineService.deletePreDefinedCourse(course.id);
              Navigator.pop(context);
              setState(() {
                displayedCourses.remove(course);
              });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addNewCourse() async {
    if (_nameController.text.isEmpty) {
      _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
      return;
    }

    if (isAddingCourse) {
      return;
    }

    setState(() {
      isAddingCourse = true;
    });

    try {
      List<Map<String, dynamic>> medicines = [];
      String courseId = const Uuid().v4();
      for (int i = 0; i < selectedMedicines.length; i++) {
        medicines.add({
          'medId': selectedMedicines[i].medId,
          'medName': selectedMedicines[i].medName,
          'dose': {
            'morning': _morningCheckboxValues[i],
            'afternoon': _afternoonCheckboxValues[i],
            'evening': _eveningCheckboxValues[i],
            'sos': _sosRadioValues[i],
          },
          'days': _daysControllers[i].text,
          'instructions': _instructionsControllers[i].text,
        });
      }

      PreDefinedCourse newCourse = PreDefinedCourse(
        id: courseId,
        name: _nameController.text,
        medicines: medicines,
      );

      await medicineService.addPreDefinedCourse(newCourse);

      setState(() {
        isAddingCourse = false;
        addingNewCourse = false;
        _nameController.clear();
        _daysControllers.forEach((controller) => controller.clear());
        _instructionsControllers.forEach((controller) => controller.clear());
        selectedMedicines.clear();
        _morningCheckboxValues.clear();
        _afternoonCheckboxValues.clear();
        _eveningCheckboxValues.clear();
        _sosRadioValues.clear();
        _fetchAllCourses(); // Refresh the list after adding a new course
      });

      _showAlertDialog('Success', 'Pre-defined course added successfully.');
    } catch (error) {
      devtools.log('Error adding new course: $error');
      _showAlertDialog('Error', 'An error occurred while adding the course.');
      setState(() {
        isAddingCourse = false;
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

  void _selectMedicine() async {
    List<Medicine> allMedicines = await medicineService.getAllMedicines();

    if (!mounted) return; // Ensure context is still valid
    final selected = await showDialog<List<Medicine>>(
      context: context,
      builder: (BuildContext context) {
        List<Medicine> tempSelectedMedicines = List.from(selectedMedicines);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Medicines'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (allMedicines.isNotEmpty) ...[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Existing Medicines',
                                      style: MyTextStyle
                                          .textStyleMap['title-large']
                                          ?.copyWith(
                                              color: MyColors
                                                  .colorPalette['on-surface']),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: allMedicines.map((medicine) {
                                    final isSelected = tempSelectedMedicines
                                        .contains(medicine);
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            tempSelectedMedicines
                                                .remove(medicine);
                                          } else {
                                            tempSelectedMedicines.add(medicine);
                                          }
                                        });
                                      },
                                      child: Card(
                                        child: ListTile(
                                          title: Text(
                                            medicine.medName,
                                            style: MyTextStyle
                                                .textStyleMap['label-medium']
                                                ?.copyWith(
                                                    color:
                                                        MyColors.colorPalette[
                                                            'on_surface']),
                                          ),
                                          subtitle: Text(
                                            medicine.composition ?? '',
                                            style: MyTextStyle
                                                .textStyleMap['label-medium']
                                                ?.copyWith(
                                                    color:
                                                        MyColors.colorPalette[
                                                            'on_surface']),
                                          ),
                                          trailing: isSelected
                                              ? const Icon(Icons.check_box)
                                              : const Icon(Icons
                                                  .check_box_outline_blank),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ] else ...[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'No medicines available',
                                      style: MyTextStyle
                                          .textStyleMap['label-medium']
                                          ?.copyWith(
                                              color: MyColors
                                                  .colorPalette['on_surface']),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, tempSelectedMedicines);
                  },
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedMedicines = selected;
        _daysControllers.clear();
        _instructionsControllers.clear();
        _morningCheckboxValues.clear();
        _afternoonCheckboxValues.clear();
        _eveningCheckboxValues.clear();
        _sosRadioValues.clear();
        for (var med in selectedMedicines) {
          _daysControllers.add(TextEditingController());
          _instructionsControllers.add(TextEditingController());
          _morningCheckboxValues.add(false);
          _afternoonCheckboxValues.add(false);
          _eveningCheckboxValues.add(false);
          _sosRadioValues.add(false);
        }
      });
    }
  }

  Widget buildAddNewCourseUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Add Pre-defined Course',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              addingNewCourse = false;
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
                      labelText: 'Course Name',
                      labelStyle: MyTextStyle.textStyleMap['label-large']
                          ?.copyWith(
                              color:
                                  MyColors.colorPalette['on-surface-variant']),
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
                      Expanded(
                        child: TextButton(
                          onPressed: _selectMedicine,
                          child: Text(
                            'Select Medicines',
                            style: MyTextStyle.textStyleMap['label-large']
                                ?.copyWith(
                                    color: MyColors.colorPalette['primary']),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedMedicines.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < selectedMedicines.length; i++)
                          _buildMedicineTile(i),
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
                          onPressed: _addNewCourse,
                          child: Text(
                            'Generate',
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
                            addingNewCourse = false;
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                      if (isAddingCourse)
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
  //         'Search Pre-defined Course',
  //         style: MyTextStyle.textStyleMap['title-large']
  //             ?.copyWith(color: MyColors.colorPalette['on-surface']),
  //       ),
  //       leading: IconButton(
  //         icon: const Icon(Icons.close),
  //         onPressed: () {
  //           setState(() {
  //             addingNewCourse = false;
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
  //                 labelText: 'Enter course name',
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
  //         if (displayedCourses.isNotEmpty) ...[
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
  //                           'Existing Courses',
  //                           style: MyTextStyle.textStyleMap['title-large']
  //                               ?.copyWith(
  //                                   color: MyColors.colorPalette['on-surface']),
  //                         ),
  //                       ),
  //                     ),
  //                     Column(
  //                       children: [
  //                         for (var course in displayedCourses)
  //                           InkWell(
  //                             onLongPress: () {
  //                               deleteCourse(course);
  //                             },
  //                             child: Card(
  //                               child: ListTile(
  //                                 title: Text(
  //                                   course.name,
  //                                   style: MyTextStyle
  //                                       .textStyleMap['label-medium']
  //                                       ?.copyWith(
  //                                           color: MyColors
  //                                               .colorPalette['on_surface']),
  //                                 ),
  //                                 trailing: GestureDetector(
  //                                   onTap: () {
  //                                     handleSelectedCourse(course);
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
  //                                   addingNewCourse = true;
  //                                   hasUserInput = false;
  //                                   displayedCourses.clear();
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
  //         ] else if (hasUserInput && displayedCourses.isEmpty) ...[
  //           Padding(
  //             padding: const EdgeInsets.only(
  //                 left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
  //             child: Align(
  //               alignment: Alignment.topLeft,
  //               child: Text(
  //                 'No matching course found',
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
  //                     addingNewCourse = true;
  //                     hasUserInput = false;
  //                     displayedCourses.clear();
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
//------------------------------------------------------------------------------//
  Widget buildSearchUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Search Pre-defined Course',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              addingNewCourse = false;
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
                  labelText: 'Enter course name',
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
          if (displayedCourses.isNotEmpty) ...[
            // Display list of existing courses if any are found
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Existing Courses',
                        style: MyTextStyle.textStyleMap['title-large']
                            ?.copyWith(
                                color: MyColors.colorPalette['on-surface']),
                      ),
                      ...displayedCourses
                          .map((course) => _buildCourseCard(course)),
                    ],
                  ),
                ),
              ),
            ),
          ] else if (displayedCourses.isEmpty && !hasUserInput) ...[
            // Show "Add New" button when no courses exist and no search input
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'No matching course found',
                style: MyTextStyle.textStyleMap['label-medium']
                    ?.copyWith(color: MyColors.colorPalette['on_surface']),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.add, color: MyColors.colorPalette['primary']),
                label: Text(
                  'Add New',
                  style: MyTextStyle.textStyleMap['label-large']
                      ?.copyWith(color: MyColors.colorPalette['primary']),
                ),
                style: ElevatedButton.styleFrom(
                  primary: MyColors.colorPalette['on-primary'],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    side: BorderSide(
                        color: MyColors.colorPalette['primary']!, width: 1.0),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    addingNewCourse = true;
                    hasUserInput = false;
                    displayedCourses.clear();
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCourseCard(PreDefinedCourse course) {
    return InkWell(
      onLongPress: () {
        deleteCourse(course);
      },
      child: Card(
        child: ListTile(
          title: Text(
            course.name,
            style: MyTextStyle.textStyleMap['label-medium']
                ?.copyWith(color: MyColors.colorPalette['on_surface']),
          ),
          trailing: GestureDetector(
            onTap: () {
              handleSelectedCourse(course);
            },
            child: CircleAvatar(
              radius: 13.33,
              backgroundColor:
                  MyColors.colorPalette['surface'] ?? Colors.blueAccent,
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
//------------------------------------------------------------------------------//

  Widget _buildMedicineTile(int index) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        selectedMedicines[index].medName,
                        style: MyTextStyle.textStyleMap['label-large']
                            ?.copyWith(
                                color: MyColors.colorPalette['secondary']),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMedicines.removeAt(index);
                          _morningCheckboxValues.removeAt(index);
                          _afternoonCheckboxValues.removeAt(index);
                          _eveningCheckboxValues.removeAt(index);
                          _sosRadioValues.removeAt(index);
                          _daysControllers.removeAt(index);
                          _instructionsControllers.removeAt(index);
                        });
                      },
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: MyColors.colorPalette['on-surface'],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SquareCheckboxWithLabel(
                                initialValue: _morningCheckboxValues[index],
                                onChanged: (value) {
                                  setState(() {
                                    if (value) {
                                      _sosRadioValues[index] = false;
                                    }
                                    _morningCheckboxValues[index] = value;
                                  });
                                },
                                showLabel: false,
                              ),
                              Container(
                                height: 2.0,
                                width: 62.0,
                                color: Colors.grey,
                              ),
                              SquareCheckboxWithLabel(
                                initialValue: _afternoonCheckboxValues[index],
                                onChanged: (value) {
                                  setState(() {
                                    if (value) {
                                      _sosRadioValues[index] = false;
                                    }
                                    _afternoonCheckboxValues[index] = value;
                                  });
                                },
                                showLabel: false,
                              ),
                              Container(
                                height: 2.0,
                                width: 62.0,
                                color: Colors.grey,
                              ),
                              SquareCheckboxWithLabel(
                                initialValue: _eveningCheckboxValues[index],
                                onChanged: (value) {
                                  setState(() {
                                    if (value) {
                                      _sosRadioValues[index] = false;
                                    }
                                    _eveningCheckboxValues[index] = value;
                                  });
                                },
                                showLabel: false,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Morning',
                                style: MyTextStyle.textStyleMap['label-medium']
                                    ?.copyWith(
                                        color:
                                            MyColors.colorPalette['secondary']),
                              ),
                              Text(
                                'Afternoon',
                                style: MyTextStyle.textStyleMap['label-medium']
                                    ?.copyWith(
                                        color:
                                            MyColors.colorPalette['secondary']),
                              ),
                              Text(
                                'Evening',
                                style: MyTextStyle.textStyleMap['label-medium']
                                    ?.copyWith(
                                        color:
                                            MyColors.colorPalette['secondary']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40.0,
                      width: 2.0,
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        children: [
                          RadioWithLabel(
                            initialValue: _sosRadioValues[index],
                            onChanged: (value) {
                              setState(() {
                                if (value) {
                                  _morningCheckboxValues[index] = false;
                                  _afternoonCheckboxValues[index] = false;
                                  _eveningCheckboxValues[index] = false;
                                }
                                _sosRadioValues[index] = value;
                              });
                            },
                            showLabel: false,
                          ),
                          Text(
                            'SOS',
                            style: MyTextStyle.textStyleMap['label-medium']
                                ?.copyWith(
                                    color: MyColors.colorPalette['secondary']),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: MyColors
                                        .colorPalette['surface-container'] ??
                                    Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextFormField(
                              controller: _daysControllers[index],
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              decoration: InputDecoration(
                                labelStyle: MyTextStyle
                                    .textStyleMap['label-large']
                                    ?.copyWith(
                                  color: MyColors.colorPalette['on-surface'],
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                isDense: true,
                                hintText: 'days',
                                hintStyle: MyTextStyle
                                    .textStyleMap['label-large']
                                    ?.copyWith(
                                        color: MyColors.colorPalette[
                                            'on-surface-variant']),
                              ),
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                setState(() {
                                  _daysControllers[index].text = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 1.0,
                      width: double.infinity,
                      color: MyColors.colorPalette['on-surface-variant'],
                    ),
                    TextFormField(
                      controller: _instructionsControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Instructions',
                        labelStyle: MyTextStyle.textStyleMap['label-medium']
                            ?.copyWith(
                                color: MyColors.colorPalette['secondary']),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _instructionsControllers[index].text = value;
                        });
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (addingNewCourse) {
      return buildAddNewCourseUI();
    }

    return buildSearchUI();
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:neocare_dental_app/firestore/medicine_service.dart';
// import 'package:neocare_dental_app/mywidgets/medicine.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/pre_defined_courses.dart';
// import 'package:neocare_dental_app/mywidgets/edit_pre_defined_course.dart';
// import 'dart:developer' as devtools show log;

// import 'package:uuid/uuid.dart';

// class AddPreDefinedCourse extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;

//   const AddPreDefinedCourse({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//   });

//   @override
//   State<AddPreDefinedCourse> createState() => _AddPreDefinedCourseState();
// }

// class _AddPreDefinedCourseState extends State<AddPreDefinedCourse> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final List<TextEditingController> _daysControllers = [];
//   final List<TextEditingController> _instructionsControllers = [];

//   bool isAddingCourse = false;
//   bool addingNewCourse = false;
//   bool hasUserInput = false;
//   bool showNoMatchingCourseMessage = false;
//   String previousSearchInput = '';

//   List<Medicine> selectedMedicines = [];
//   List<PreDefinedCourse> matchingCourses = [];
//   late MedicineService medicineService;

//   final List<bool> _morningCheckboxValues = [];
//   final List<bool> _afternoonCheckboxValues = [];
//   final List<bool> _eveningCheckboxValues = [];
//   final List<bool> _sosRadioValues = [];

//   @override
//   void initState() {
//     super.initState();
//     addingNewCourse = false;
//     medicineService = MedicineService(widget.clinicId);
//   }

//   void handleSearchInput(String userInput) async {
//     setState(() {
//       hasUserInput = userInput.isNotEmpty;
//       previousSearchInput = userInput;
//     });

//     if (userInput.isEmpty) {
//       setState(() {
//         matchingCourses.clear();
//         return;
//       });
//     }

//     setState(() {
//       matchingCourses.clear();
//     });

//     matchingCourses = await medicineService.searchPreDefinedCourses(userInput);
//     setState(() {});
//   }

//   void handleSelectedCourse(PreDefinedCourse course) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditPreDefinedCourse(
//           clinicId: widget.clinicId,
//           course: course,
//           medicineService: medicineService,
//         ),
//       ),
//     ).then((updatedCourse) {
//       if (updatedCourse != null) {
//         setState(() {
//           int index =
//               matchingCourses.indexWhere((c) => c.id == updatedCourse.id);
//           if (index != -1) {
//             matchingCourses[index] = updatedCourse;
//           }
//         });
//       }
//     });
//   }

//   void deleteCourse(PreDefinedCourse course) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Course'),
//         content: Text('Are you sure you want to delete ${course.name}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               await medicineService.deletePreDefinedCourse(course.id);
//               Navigator.pop(context);
//               setState(() {
//                 matchingCourses.remove(course);
//               });
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _addNewCourse() async {
//     if (_nameController.text.isEmpty) {
//       _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
//       return;
//     }

//     if (isAddingCourse) {
//       return;
//     }

//     setState(() {
//       isAddingCourse = true;
//     });

//     try {
//       List<Map<String, dynamic>> medicines = [];
//       String courseId = const Uuid().v4();
//       for (int i = 0; i < selectedMedicines.length; i++) {
//         medicines.add({
//           'medId': selectedMedicines[i].medId,
//           'medName': selectedMedicines[i].medName,
//           'dose': {
//             'morning': _morningCheckboxValues[i],
//             'afternoon': _afternoonCheckboxValues[i],
//             'evening': _eveningCheckboxValues[i],
//             'sos': _sosRadioValues[i],
//           },
//           'days': _daysControllers[i].text,
//           'instructions': _instructionsControllers[i].text,
//         });
//       }

//       PreDefinedCourse newCourse = PreDefinedCourse(
//         id: courseId,
//         name: _nameController.text,
//         medicines: medicines,
//       );

//       await medicineService.addPreDefinedCourse(newCourse);

//       setState(() {
//         isAddingCourse = false;
//         addingNewCourse = false;
//         _nameController.clear();
//         _daysControllers.forEach((controller) => controller.clear());
//         _instructionsControllers.forEach((controller) => controller.clear());
//         selectedMedicines.clear();
//         _morningCheckboxValues.clear();
//         _afternoonCheckboxValues.clear();
//         _eveningCheckboxValues.clear();
//         _sosRadioValues.clear();
//         handleSearchInput(previousSearchInput);
//       });

//       _showAlertDialog('Success', 'Pre-defined course added successfully.');
//     } catch (error) {
//       devtools.log('Error adding new course: $error');
//       _showAlertDialog('Error', 'An error occurred while adding the course.');
//       setState(() {
//         isAddingCourse = false;
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

//   void _selectMedicine() async {
//     List<Medicine> allMedicines = await medicineService.getAllMedicines();

//     if (!mounted) return; // Ensure context is still valid
//     final selected = await showDialog<List<Medicine>>(
//       context: context,
//       builder: (BuildContext context) {
//         List<Medicine> tempSelectedMedicines = List.from(selectedMedicines);
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return AlertDialog(
//               title: const Text('Select Medicines'),
//               content: SizedBox(
//                 width: double.maxFinite,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (allMedicines.isNotEmpty) ...[
//                                 Align(
//                                   alignment: Alignment.topLeft,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       'Existing Medicines',
//                                       style: MyTextStyle
//                                           .textStyleMap['title-large']
//                                           ?.copyWith(
//                                               color: MyColors
//                                                   .colorPalette['on-surface']),
//                                     ),
//                                   ),
//                                 ),
//                                 Column(
//                                   children: allMedicines.map((medicine) {
//                                     final isSelected = tempSelectedMedicines
//                                         .contains(medicine);
//                                     return InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           if (isSelected) {
//                                             tempSelectedMedicines
//                                                 .remove(medicine);
//                                           } else {
//                                             tempSelectedMedicines.add(medicine);
//                                           }
//                                         });
//                                       },
//                                       child: Card(
//                                         child: ListTile(
//                                           title: Text(
//                                             medicine.medName,
//                                             style: MyTextStyle
//                                                 .textStyleMap['label-medium']
//                                                 ?.copyWith(
//                                                     color:
//                                                         MyColors.colorPalette[
//                                                             'on_surface']),
//                                           ),
//                                           subtitle: Text(
//                                             medicine.composition ?? '',
//                                             style: MyTextStyle
//                                                 .textStyleMap['label-medium']
//                                                 ?.copyWith(
//                                                     color:
//                                                         MyColors.colorPalette[
//                                                             'on_surface']),
//                                           ),
//                                           trailing: isSelected
//                                               ? const Icon(Icons.check_box)
//                                               : const Icon(Icons
//                                                   .check_box_outline_blank),
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ] else ...[
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Align(
//                                     alignment: Alignment.topLeft,
//                                     child: Text(
//                                       'No medicines available',
//                                       style: MyTextStyle
//                                           .textStyleMap['label-medium']
//                                           ?.copyWith(
//                                               color: MyColors
//                                                   .colorPalette['on_surface']),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context, tempSelectedMedicines);
//                   },
//                   child: const Text('Select'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     if (selected != null) {
//       setState(() {
//         selectedMedicines = selected;
//         _daysControllers.clear();
//         _instructionsControllers.clear();
//         _morningCheckboxValues.clear();
//         _afternoonCheckboxValues.clear();
//         _eveningCheckboxValues.clear();
//         _sosRadioValues.clear();
//         for (var med in selectedMedicines) {
//           _daysControllers.add(TextEditingController());
//           _instructionsControllers.add(TextEditingController());
//           _morningCheckboxValues.add(false);
//           _afternoonCheckboxValues.add(false);
//           _eveningCheckboxValues.add(false);
//           _sosRadioValues.add(false);
//         }
//       });
//     }
//   }

//   Widget buildAddNewCourseUI() {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Add Pre-defined Course',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             setState(() {
//               addingNewCourse = false;
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
//                       labelText: 'Course Name',
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
//                       Expanded(
//                         child: TextButton(
//                           onPressed: _selectMedicine,
//                           child: Text(
//                             'Select Medicines',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['primary']),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (selectedMedicines.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         for (int i = 0; i < selectedMedicines.length; i++)
//                           _buildMedicineTile(i),
//                       ],
//                     ),
//                   ),
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
//                           onPressed: _addNewCourse,
//                           child: Text(
//                             'Generate',
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
//                             addingNewCourse = false;
//                           });
//                         },
//                         child: const Text('Cancel'),
//                       ),
//                       if (isAddingCourse)
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
//           'Search Pre-defined Course',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () {
//             setState(() {
//               addingNewCourse = false;
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
//                   labelText: 'Enter course name',
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
//           if (hasUserInput && matchingCourses.isNotEmpty) ...[
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
//                             'Existing Courses',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on-surface']),
//                           ),
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           for (var course in matchingCourses)
//                             InkWell(
//                               onLongPress: () {
//                                 deleteCourse(course);
//                               },
//                               child: Card(
//                                 child: ListTile(
//                                   title: Text(
//                                     course.name,
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
//                                   //     handleSelectedCourse(course);
//                                   //   },
//                                   // ),
//                                   trailing: GestureDetector(
//                                     onTap: () {
//                                       handleSelectedCourse(course);
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
//                                     addingNewCourse = true;
//                                     hasUserInput = false;
//                                     matchingCourses.clear();
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
//           ] else if (hasUserInput && matchingCourses.isEmpty) ...[
//             Padding(
//               padding: const EdgeInsets.only(
//                   left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//               child: Align(
//                 alignment: Alignment.topLeft,
//                 child: Text(
//                   'No matching course found',
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
//                       addingNewCourse = true;
//                       hasUserInput = false;
//                       matchingCourses.clear();
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

//   Widget _buildMedicineTile(int index) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8.0),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(10.0),
//           ),
//           child: Column(
//             children: [
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0),
//                       child: Text(
//                         selectedMedicines[index].medName,
//                         style: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['secondary']),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           selectedMedicines.removeAt(index);
//                           _morningCheckboxValues.removeAt(index);
//                           _afternoonCheckboxValues.removeAt(index);
//                           _eveningCheckboxValues.removeAt(index);
//                           _sosRadioValues.removeAt(index);
//                           _daysControllers.removeAt(index);
//                           _instructionsControllers.removeAt(index);
//                         });
//                       },
//                       child: Icon(
//                         Icons.close,
//                         size: 24,
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Padding(
//                 padding: const EdgeInsets.only(left: 0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SquareCheckboxWithLabel(
//                                 initialValue: _morningCheckboxValues[index],
//                                 onChanged: (value) {
//                                   setState(() {
//                                     if (value) {
//                                       _sosRadioValues[index] = false;
//                                     }
//                                     _morningCheckboxValues[index] = value;
//                                   });
//                                 },
//                                 showLabel: false,
//                               ),
//                               Container(
//                                 height: 2.0,
//                                 width: 62.0,
//                                 color: Colors.grey,
//                               ),
//                               SquareCheckboxWithLabel(
//                                 initialValue: _afternoonCheckboxValues[index],
//                                 onChanged: (value) {
//                                   setState(() {
//                                     if (value) {
//                                       _sosRadioValues[index] = false;
//                                     }
//                                     _afternoonCheckboxValues[index] = value;
//                                   });
//                                 },
//                                 showLabel: false,
//                               ),
//                               Container(
//                                 height: 2.0,
//                                 width: 62.0,
//                                 color: Colors.grey,
//                               ),
//                               SquareCheckboxWithLabel(
//                                 initialValue: _eveningCheckboxValues[index],
//                                 onChanged: (value) {
//                                   setState(() {
//                                     if (value) {
//                                       _sosRadioValues[index] = false;
//                                     }
//                                     _eveningCheckboxValues[index] = value;
//                                   });
//                                 },
//                                 showLabel: false,
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Text(
//                                 'Morning',
//                                 style: MyTextStyle.textStyleMap['label-medium']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary']),
//                               ),
//                               Text(
//                                 'Afternoon',
//                                 style: MyTextStyle.textStyleMap['label-medium']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary']),
//                               ),
//                               Text(
//                                 'Evening',
//                                 style: MyTextStyle.textStyleMap['label-medium']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary']),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       height: 40.0,
//                       width: 2.0,
//                       color: Colors.grey,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0),
//                       child: Column(
//                         children: [
//                           RadioWithLabel(
//                             initialValue: _sosRadioValues[index],
//                             onChanged: (value) {
//                               setState(() {
//                                 if (value) {
//                                   _morningCheckboxValues[index] = false;
//                                   _afternoonCheckboxValues[index] = false;
//                                   _eveningCheckboxValues[index] = false;
//                                 }
//                                 _sosRadioValues[index] = value;
//                               });
//                             },
//                             showLabel: false,
//                           ),
//                           Text(
//                             'SOS',
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['secondary']),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0, right: 8.0),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 60,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 width: 1,
//                                 color: MyColors
//                                         .colorPalette['surface-container'] ??
//                                     Colors.black,
//                               ),
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: TextFormField(
//                               controller: _daysControllers[index],
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                                 LengthLimitingTextInputFormatter(2),
//                               ],
//                               decoration: InputDecoration(
//                                 labelStyle: MyTextStyle
//                                     .textStyleMap['label-large']
//                                     ?.copyWith(
//                                   color: MyColors.colorPalette['on-surface'],
//                                 ),
//                                 contentPadding:
//                                     const EdgeInsets.symmetric(vertical: 10),
//                                 isDense: true,
//                                 hintText: 'days',
//                                 hintStyle: MyTextStyle
//                                     .textStyleMap['label-large']
//                                     ?.copyWith(
//                                         color: MyColors.colorPalette[
//                                             'on-surface-variant']),
//                               ),
//                               textAlign: TextAlign.center,
//                               onChanged: (value) {
//                                 setState(() {
//                                   _daysControllers[index].text = value;
//                                 });
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       height: 1.0,
//                       width: double.infinity,
//                       color: MyColors.colorPalette['on-surface-variant'],
//                     ),
//                     TextFormField(
//                       controller: _instructionsControllers[index],
//                       decoration: InputDecoration(
//                         labelText: 'Instructions',
//                         labelStyle: MyTextStyle.textStyleMap['label-medium']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['secondary']),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 8.0,
//                           vertical: 8.0,
//                         ),
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           _instructionsControllers[index].text = value;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (addingNewCourse) {
//       return buildAddNewCourseUI();
//     }

//     return buildSearchUI();
//   }
// }

// class SquareCheckboxWithLabel extends StatefulWidget {
//   final bool initialValue;
//   final Function(bool) onChanged;
//   final bool showLabel;

//   const SquareCheckboxWithLabel({
//     super.key,
//     required this.initialValue,
//     required this.onChanged,
//     this.showLabel = false,
//   });

//   @override
//   State<SquareCheckboxWithLabel> createState() =>
//       _SquareCheckboxWithLabelState();
// }

// class _SquareCheckboxWithLabelState extends State<SquareCheckboxWithLabel> {
//   bool _isChecked = false;

//   @override
//   void initState() {
//     super.initState();
//     _isChecked = widget.initialValue;
//   }

//   @override
//   void didUpdateWidget(covariant SquareCheckboxWithLabel oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.initialValue != oldWidget.initialValue) {
//       _isChecked = widget.initialValue;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               _isChecked = !_isChecked;
//               widget.onChanged(_isChecked);
//             });
//           },
//           child: Container(
//             width: 24.0,
//             height: 24.0,
//             decoration: BoxDecoration(
//               shape: BoxShape.rectangle,
//               border: Border.all(
//                 color:
//                     MyColors.colorPalette['surface-container'] ?? Colors.black,
//                 width: 2.0,
//               ),
//             ),
//             child: _isChecked
//                 ? Icon(
//                     Icons.check,
//                     size: 16.0,
//                     color: MyColors.colorPalette['primary'],
//                   )
//                 : null,
//           ),
//         ),
//         if (widget.showLabel) ...[
//           const SizedBox(width: 8.0),
//           Text(
//             'Label',
//             style: TextStyle(color: MyColors.colorPalette['on-surface']),
//           ),
//         ],
//       ],
//     );
//   }
// }

// class RadioWithLabel extends StatefulWidget {
//   final bool initialValue;
//   final Function(bool) onChanged;
//   final bool showLabel;

//   const RadioWithLabel({
//     super.key,
//     required this.initialValue,
//     required this.onChanged,
//     this.showLabel = false,
//   });

//   @override
//   State<RadioWithLabel> createState() => _RadioWithLabelState();
// }

// class _RadioWithLabelState extends State<RadioWithLabel> {
//   bool _isSelected = false;

//   @override
//   void initState() {
//     super.initState();
//     _isSelected = widget.initialValue;
//   }

//   @override
//   void didUpdateWidget(covariant RadioWithLabel oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.initialValue != oldWidget.initialValue) {
//       _isSelected = widget.initialValue;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               _isSelected = !_isSelected;
//               widget.onChanged(_isSelected);
//             });
//           },
//           child: Container(
//             width: 24.0,
//             height: 24.0,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color:
//                     MyColors.colorPalette['surface-container'] ?? Colors.black,
//                 width: 2.0,
//               ),
//             ),
//             child: _isSelected
//                 ? Icon(
//                     Icons.radio_button_checked,
//                     size: 16.0,
//                     color: MyColors.colorPalette['primary'],
//                   )
//                 : Icon(Icons.radio_button_unchecked,
//                     size: 16.0, color: MyColors.colorPalette['primary']),
//           ),
//         ),
//         if (widget.showLabel) ...[
//           const SizedBox(width: 8.0),
//           Text(
//             'Label',
//             style: TextStyle(color: MyColors.colorPalette['on-surface']),
//           ),
//         ],
//       ],
//     );
//   }
// }

// class SelectMedicineDialog extends StatefulWidget {
//   final String clinicId;

//   const SelectMedicineDialog({super.key, required this.clinicId});

//   @override
//   _SelectMedicineDialogState createState() => _SelectMedicineDialogState();
// }

// class _SelectMedicineDialogState extends State<SelectMedicineDialog> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Medicine> matchingMedicines = [];
//   List<Medicine> selectedMedicines = [];
//   late MedicineService medicineService;

//   @override
//   void initState() {
//     super.initState();
//     medicineService = MedicineService(widget.clinicId);
//   }

//   void handleSearchInput(String userInput) async {
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
//     setState(() {
//       if (selectedMedicines.contains(medicine)) {
//         selectedMedicines.remove(medicine);
//       } else {
//         selectedMedicines.add(medicine);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Select Medicines'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: _searchController,
//             onChanged: (value) {
//               handleSearchInput(value);
//             },
//             decoration: const InputDecoration(
//               labelText: 'Search Medicines',
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: matchingMedicines.length,
//               itemBuilder: (context, index) {
//                 final medicine = matchingMedicines[index];
//                 final isSelected = selectedMedicines.contains(medicine);

//                 return ListTile(
//                   title: Text(medicine.medName),
//                   trailing: isSelected
//                       ? const Icon(Icons.check_box)
//                       : const Icon(Icons.check_box_outline_blank),
//                   onTap: () {
//                     handleSelectedMedicine(medicine);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context, selectedMedicines);
//           },
//           child: const Text('Select'),
//         ),
//       ],
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE WITHOUT DELETE, EDIT 
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:neocare_dental_app/firestore/medicine_service.dart';
// import 'package:neocare_dental_app/mywidgets/medicine.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/pre_defined_courses.dart';
// import 'package:neocare_dental_app/mywidgets/edit_pre_defined_course.dart';
// import 'dart:developer' as devtools show log;

// import 'package:uuid/uuid.dart';

// class AddPreDefinedCourse extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;

//   const AddPreDefinedCourse({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//   });

//   @override
//   State<AddPreDefinedCourse> createState() => _AddPreDefinedCourseState();
// }

// class _AddPreDefinedCourseState extends State<AddPreDefinedCourse> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final List<TextEditingController> _daysControllers = [];
//   final List<TextEditingController> _instructionsControllers = [];

//   bool isAddingCourse = false;
//   bool addingNewCourse = false;
//   bool hasUserInput = false;
//   bool showNoMatchingCourseMessage = false;
//   String previousSearchInput = '';

//   List<Medicine> selectedMedicines = [];
//   List<PreDefinedCourse> matchingCourses = [];
//   late MedicineService medicineService;

//   List<bool> _morningCheckboxValues = [];
//   List<bool> _afternoonCheckboxValues = [];
//   List<bool> _eveningCheckboxValues = [];
//   List<bool> _sosRadioValues = [];

//   @override
//   void initState() {
//     super.initState();
//     addingNewCourse = false;
//     medicineService = MedicineService(widget.clinicId);
//   }

//   void handleSearchInput(String userInput) async {
//     setState(() {
//       hasUserInput = userInput.isNotEmpty;
//       previousSearchInput = userInput;
//     });

//     if (userInput.isEmpty) {
//       setState(() {
//         matchingCourses.clear();
//         return;
//       });
//     }

//     setState(() {
//       matchingCourses.clear();
//     });

//     matchingCourses = await medicineService.searchPreDefinedCourses(userInput);
//     setState(() {});
//   }

//   void handleSelectedCourse(PreDefinedCourse course) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditPreDefinedCourse(
//           clinicId: widget.clinicId,
//           course: course,
//           medicineService: medicineService,
//         ),
//       ),
//     ).then((updatedCourse) {
//       if (updatedCourse != null) {
//         setState(() {
//           int index =
//               matchingCourses.indexWhere((c) => c.id == updatedCourse.id);
//           if (index != -1) {
//             matchingCourses[index] = updatedCourse;
//           }
//         });
//       }
//     });
//   }

//   void deleteCourse(PreDefinedCourse course) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Course'),
//         content: Text('Are you sure you want to delete ${course.name}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               await medicineService.deletePreDefinedCourse(course.id);
//               Navigator.pop(context);
//               setState(() {
//                 matchingCourses.remove(course);
//               });
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _addNewCourse() async {
//     if (_nameController.text.isEmpty) {
//       _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
//       return;
//     }

//     if (isAddingCourse) {
//       return;
//     }

//     setState(() {
//       isAddingCourse = true;
//     });

//     try {
//       List<Map<String, dynamic>> medicines = [];
//       String courseId = const Uuid().v4();
//       for (int i = 0; i < selectedMedicines.length; i++) {
//         medicines.add({
//           'medId': selectedMedicines[i].medId,
//           'medName': selectedMedicines[i].medName,
//           'dose': {
//             'morning': _morningCheckboxValues[i],
//             'afternoon': _afternoonCheckboxValues[i],
//             'evening': _eveningCheckboxValues[i],
//             'sos': _sosRadioValues[i],
//           },
//           'days': _daysControllers[i].text,
//           'instructions': _instructionsControllers[i].text,
//         });
//       }

//       PreDefinedCourse newCourse = PreDefinedCourse(
//         id: courseId,
//         name: _nameController.text,
//         medicines: medicines,
//       );

//       await medicineService.addPreDefinedCourse(newCourse);

//       setState(() {
//         isAddingCourse = false;
//         addingNewCourse = false;
//         _nameController.clear();
//         _daysControllers.forEach((controller) => controller.clear());
//         _instructionsControllers.forEach((controller) => controller.clear());
//         selectedMedicines.clear();
//         _morningCheckboxValues.clear();
//         _afternoonCheckboxValues.clear();
//         _eveningCheckboxValues.clear();
//         _sosRadioValues.clear();
//       });

//       _showAlertDialog('Success', 'Pre-defined course added successfully.');
//     } catch (error) {
//       devtools.log('Error adding new course: $error');
//       _showAlertDialog('Error', 'An error occurred while adding the course.');
//       setState(() {
//         isAddingCourse = false;
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

//   void _selectMedicine() async {
//     List<Medicine> allMedicines = await medicineService.getAllMedicines();

//     if (!mounted) return; // Ensure context is still valid
//     final selected = await showDialog<List<Medicine>>(
//       context: context,
//       builder: (BuildContext context) {
//         List<Medicine> tempSelectedMedicines = List.from(selectedMedicines);
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return AlertDialog(
//               title: const Text('Select Medicines'),
//               content: Container(
//                 width: double.maxFinite,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (allMedicines.isNotEmpty) ...[
//                                 Align(
//                                   alignment: Alignment.topLeft,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       'Existing Medicines',
//                                       style: MyTextStyle
//                                           .textStyleMap['title-large']
//                                           ?.copyWith(
//                                               color: MyColors
//                                                   .colorPalette['on-surface']),
//                                     ),
//                                   ),
//                                 ),
//                                 Column(
//                                   children: allMedicines.map((medicine) {
//                                     final isSelected = tempSelectedMedicines
//                                         .contains(medicine);
//                                     return InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           if (isSelected) {
//                                             tempSelectedMedicines
//                                                 .remove(medicine);
//                                           } else {
//                                             tempSelectedMedicines.add(medicine);
//                                           }
//                                         });
//                                       },
//                                       child: Card(
//                                         child: ListTile(
//                                           title: Text(
//                                             medicine.medName,
//                                             style: MyTextStyle
//                                                 .textStyleMap['label-medium']
//                                                 ?.copyWith(
//                                                     color:
//                                                         MyColors.colorPalette[
//                                                             'on_surface']),
//                                           ),
//                                           subtitle: Text(
//                                             medicine.composition ?? '',
//                                             style: MyTextStyle
//                                                 .textStyleMap['label-medium']
//                                                 ?.copyWith(
//                                                     color:
//                                                         MyColors.colorPalette[
//                                                             'on_surface']),
//                                           ),
//                                           trailing: isSelected
//                                               ? const Icon(Icons.check_box)
//                                               : const Icon(Icons
//                                                   .check_box_outline_blank),
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ] else ...[
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Align(
//                                     alignment: Alignment.topLeft,
//                                     child: Text(
//                                       'No medicines available',
//                                       style: MyTextStyle
//                                           .textStyleMap['label-medium']
//                                           ?.copyWith(
//                                               color: MyColors
//                                                   .colorPalette['on_surface']),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context, tempSelectedMedicines);
//                   },
//                   child: const Text('Select'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     if (selected != null) {
//       setState(() {
//         selectedMedicines = selected;
//         _daysControllers.clear();
//         _instructionsControllers.clear();
//         _morningCheckboxValues.clear();
//         _afternoonCheckboxValues.clear();
//         _eveningCheckboxValues.clear();
//         _sosRadioValues.clear();
//         for (var med in selectedMedicines) {
//           _daysControllers.add(TextEditingController());
//           _instructionsControllers.add(TextEditingController());
//           _morningCheckboxValues.add(false);
//           _afternoonCheckboxValues.add(false);
//           _eveningCheckboxValues.add(false);
//           _sosRadioValues.add(false);
//         }
//       });
//     }
//   }

//   Widget buildAddNewCourseUI() {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Add Pre-defined Course',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             setState(() {
//               addingNewCourse = false;
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
//                       labelText: 'Course Name',
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
//                       Expanded(
//                         child: TextButton(
//                           onPressed: _selectMedicine,
//                           child: Text(
//                             'Select Medicines',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['primary']),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (selectedMedicines.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         for (int i = 0; i < selectedMedicines.length; i++)
//                           _buildMedicineTile(i),
//                       ],
//                     ),
//                   ),
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
//                           onPressed: _addNewCourse,
//                           child: Text(
//                             'Generate',
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
//                             addingNewCourse = false;
//                           });
//                         },
//                         child: const Text('Cancel'),
//                       ),
//                       if (isAddingCourse)
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
//           'Search Pre-defined Course',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () {
//             setState(() {
//               addingNewCourse = false;
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
//                   labelText: 'Enter course name',
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
//           if (hasUserInput && matchingCourses.isNotEmpty) ...[
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
//                             'Existing Courses',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on-surface']),
//                           ),
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           for (var course in matchingCourses)
//                             InkWell(
//                               onLongPress: () {
//                                 deleteCourse(course);
//                               },
//                               child: Card(
//                                 child: ListTile(
//                                   title: Text(
//                                     course.name,
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['on_surface']),
//                                   ),
//                                   trailing: IconButton(
//                                     icon: const Icon(
//                                       Icons.arrow_forward_ios_rounded,
//                                       size: 16,
//                                       color: Colors.white,
//                                     ),
//                                     onPressed: () {
//                                       handleSelectedCourse(course);
//                                     },
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
//                                     addingNewCourse = true;
//                                     hasUserInput = false;
//                                     matchingCourses.clear();
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
//           ] else if (hasUserInput && matchingCourses.isEmpty) ...[
//             Padding(
//               padding: const EdgeInsets.only(
//                   left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//               child: Align(
//                 alignment: Alignment.topLeft,
//                 child: Text(
//                   'No matching course found',
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
//                       addingNewCourse = true;
//                       hasUserInput = false;
//                       matchingCourses.clear();
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

//   Widget _buildMedicineTile(int index) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8.0),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(10.0),
//           ),
//           child: Column(
//             children: [
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0),
//                       child: Text(
//                         selectedMedicines[index].medName,
//                         style: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['secondary']),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           selectedMedicines.removeAt(index);
//                           _morningCheckboxValues.removeAt(index);
//                           _afternoonCheckboxValues.removeAt(index);
//                           _eveningCheckboxValues.removeAt(index);
//                           _sosRadioValues.removeAt(index);
//                           _daysControllers.removeAt(index);
//                           _instructionsControllers.removeAt(index);
//                         });
//                       },
//                       child: Icon(
//                         Icons.close,
//                         size: 24,
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Padding(
//                 padding: const EdgeInsets.only(left: 0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SquareCheckboxWithLabel(
//                                 initialValue: _morningCheckboxValues[index],
//                                 onChanged: (value) {
//                                   setState(() {
//                                     if (value) {
//                                       _sosRadioValues[index] = false;
//                                     }
//                                     _morningCheckboxValues[index] = value;
//                                   });
//                                 },
//                                 showLabel: false,
//                               ),
//                               Container(
//                                 height: 2.0,
//                                 width: 62.0,
//                                 color: Colors.grey,
//                               ),
//                               SquareCheckboxWithLabel(
//                                 initialValue: _afternoonCheckboxValues[index],
//                                 onChanged: (value) {
//                                   setState(() {
//                                     if (value) {
//                                       _sosRadioValues[index] = false;
//                                     }
//                                     _afternoonCheckboxValues[index] = value;
//                                   });
//                                 },
//                                 showLabel: false,
//                               ),
//                               Container(
//                                 height: 2.0,
//                                 width: 62.0,
//                                 color: Colors.grey,
//                               ),
//                               SquareCheckboxWithLabel(
//                                 initialValue: _eveningCheckboxValues[index],
//                                 onChanged: (value) {
//                                   setState(() {
//                                     if (value) {
//                                       _sosRadioValues[index] = false;
//                                     }
//                                     _eveningCheckboxValues[index] = value;
//                                   });
//                                 },
//                                 showLabel: false,
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Text(
//                                 'Morning',
//                                 style: MyTextStyle.textStyleMap['label-medium']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary']),
//                               ),
//                               Text(
//                                 'Afternoon',
//                                 style: MyTextStyle.textStyleMap['label-medium']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary']),
//                               ),
//                               Text(
//                                 'Evening',
//                                 style: MyTextStyle.textStyleMap['label-medium']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary']),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       height: 40.0,
//                       width: 2.0,
//                       color: Colors.grey,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0),
//                       child: Column(
//                         children: [
//                           RadioWithLabel(
//                             initialValue: _sosRadioValues[index],
//                             onChanged: (value) {
//                               setState(() {
//                                 if (value) {
//                                   _morningCheckboxValues[index] = false;
//                                   _afternoonCheckboxValues[index] = false;
//                                   _eveningCheckboxValues[index] = false;
//                                 }
//                                 _sosRadioValues[index] = value;
//                               });
//                             },
//                             showLabel: false,
//                           ),
//                           Text(
//                             'SOS',
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['secondary']),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0, right: 8.0),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 60,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 width: 1,
//                                 color: MyColors
//                                         .colorPalette['surface-container'] ??
//                                     Colors.black,
//                               ),
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: TextFormField(
//                               controller: _daysControllers[index],
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.digitsOnly,
//                                 LengthLimitingTextInputFormatter(2),
//                               ],
//                               decoration: InputDecoration(
//                                 labelStyle: MyTextStyle
//                                     .textStyleMap['label-large']
//                                     ?.copyWith(
//                                   color: MyColors.colorPalette['on-surface'],
//                                 ),
//                                 contentPadding:
//                                     const EdgeInsets.symmetric(vertical: 10),
//                                 isDense: true,
//                                 hintText: 'days',
//                                 hintStyle: MyTextStyle
//                                     .textStyleMap['label-large']
//                                     ?.copyWith(
//                                         color: MyColors.colorPalette[
//                                             'on-surface-variant']),
//                               ),
//                               textAlign: TextAlign.center,
//                               onChanged: (value) {
//                                 setState(() {
//                                   _daysControllers[index].text = value;
//                                 });
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       height: 1.0,
//                       width: double.infinity,
//                       color: MyColors.colorPalette['on-surface-variant'],
//                     ),
//                     TextFormField(
//                       controller: _instructionsControllers[index],
//                       decoration: InputDecoration(
//                         labelText: 'Instructions',
//                         labelStyle: MyTextStyle.textStyleMap['label-medium']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['secondary']),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 8.0,
//                           vertical: 8.0,
//                         ),
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           _instructionsControllers[index].text = value;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (addingNewCourse) {
//       return buildAddNewCourseUI();
//     }

//     return buildSearchUI();
//   }
// }

// class SquareCheckboxWithLabel extends StatefulWidget {
//   final bool initialValue;
//   final Function(bool) onChanged;
//   final bool showLabel;

//   const SquareCheckboxWithLabel({
//     super.key,
//     required this.initialValue,
//     required this.onChanged,
//     this.showLabel = false,
//   });

//   @override
//   State<SquareCheckboxWithLabel> createState() =>
//       _SquareCheckboxWithLabelState();
// }

// class _SquareCheckboxWithLabelState extends State<SquareCheckboxWithLabel> {
//   bool _isChecked = false;

//   @override
//   void initState() {
//     super.initState();
//     _isChecked = widget.initialValue;
//   }

//   @override
//   void didUpdateWidget(covariant SquareCheckboxWithLabel oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.initialValue != oldWidget.initialValue) {
//       _isChecked = widget.initialValue;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               _isChecked = !_isChecked;
//               widget.onChanged(_isChecked);
//             });
//           },
//           child: Container(
//             width: 24.0,
//             height: 24.0,
//             decoration: BoxDecoration(
//               shape: BoxShape.rectangle,
//               border: Border.all(
//                 color:
//                     MyColors.colorPalette['surface-container'] ?? Colors.black,
//                 width: 2.0,
//               ),
//             ),
//             child: _isChecked
//                 ? Icon(
//                     Icons.check,
//                     size: 16.0,
//                     color: MyColors.colorPalette['primary'],
//                   )
//                 : null,
//           ),
//         ),
//         if (widget.showLabel) ...[
//           const SizedBox(width: 8.0),
//           Text(
//             'Label',
//             style: TextStyle(color: MyColors.colorPalette['on-surface']),
//           ),
//         ],
//       ],
//     );
//   }
// }

// class RadioWithLabel extends StatefulWidget {
//   final bool initialValue;
//   final Function(bool) onChanged;
//   final bool showLabel;

//   const RadioWithLabel({
//     super.key,
//     required this.initialValue,
//     required this.onChanged,
//     this.showLabel = false,
//   });

//   @override
//   State<RadioWithLabel> createState() => _RadioWithLabelState();
// }

// class _RadioWithLabelState extends State<RadioWithLabel> {
//   bool _isSelected = false;

//   @override
//   void initState() {
//     super.initState();
//     _isSelected = widget.initialValue;
//   }

//   @override
//   void didUpdateWidget(covariant RadioWithLabel oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.initialValue != oldWidget.initialValue) {
//       _isSelected = widget.initialValue;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               _isSelected = !_isSelected;
//               widget.onChanged(_isSelected);
//             });
//           },
//           child: Container(
//             width: 24.0,
//             height: 24.0,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color:
//                     MyColors.colorPalette['surface-container'] ?? Colors.black,
//                 width: 2.0,
//               ),
//             ),
//             child: _isSelected
//                 ? Icon(
//                     Icons.radio_button_checked,
//                     size: 16.0,
//                     color: MyColors.colorPalette['primary'],
//                   )
//                 : Icon(Icons.radio_button_unchecked,
//                     size: 16.0, color: MyColors.colorPalette['primary']),
//           ),
//         ),
//         if (widget.showLabel) ...[
//           const SizedBox(width: 8.0),
//           Text(
//             'Label',
//             style: TextStyle(color: MyColors.colorPalette['on-surface']),
//           ),
//         ],
//       ],
//     );
//   }
// }

// class SelectMedicineDialog extends StatefulWidget {
//   final String clinicId;

//   const SelectMedicineDialog({super.key, required this.clinicId});

//   @override
//   _SelectMedicineDialogState createState() => _SelectMedicineDialogState();
// }

// class _SelectMedicineDialogState extends State<SelectMedicineDialog> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Medicine> matchingMedicines = [];
//   List<Medicine> selectedMedicines = [];
//   late MedicineService medicineService;

//   @override
//   void initState() {
//     super.initState();
//     medicineService = MedicineService(widget.clinicId);
//   }

//   void handleSearchInput(String userInput) async {
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
//     setState(() {
//       if (selectedMedicines.contains(medicine)) {
//         selectedMedicines.remove(medicine);
//       } else {
//         selectedMedicines.add(medicine);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Select Medicines'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: _searchController,
//             onChanged: (value) {
//               handleSearchInput(value);
//             },
//             decoration: const InputDecoration(
//               labelText: 'Search Medicines',
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: matchingMedicines.length,
//               itemBuilder: (context, index) {
//                 final medicine = matchingMedicines[index];
//                 final isSelected = selectedMedicines.contains(medicine);

//                 return ListTile(
//                   title: Text(medicine.medName),
//                   trailing: isSelected
//                       ? const Icon(Icons.check_box)
//                       : const Icon(Icons.check_box_outline_blank),
//                   onTap: () {
//                     handleSelectedMedicine(medicine);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context, selectedMedicines);
//           },
//           child: const Text('Select'),
//         ),
//       ],
//     );
//   }
// }
