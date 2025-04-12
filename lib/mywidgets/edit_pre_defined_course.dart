import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neocaresmileapp/firestore/medicine_service.dart';
import 'package:neocaresmileapp/mywidgets/medicine.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;

import 'package:neocaresmileapp/mywidgets/pre_defined_courses.dart';

class EditPreDefinedCourse extends StatefulWidget {
  final String clinicId;
  final PreDefinedCourse course;
  final MedicineService medicineService;

  const EditPreDefinedCourse({
    super.key,
    required this.clinicId,
    required this.course,
    required this.medicineService,
  });

  @override
  State<EditPreDefinedCourse> createState() => _EditPreDefinedCourseState();
}

class _EditPreDefinedCourseState extends State<EditPreDefinedCourse> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;

  bool isUpdatingCourse = false;
  List<Medicine> selectedMedicines = [];
  List<bool> _morningCheckboxValues = [];
  List<bool> _afternoonCheckboxValues = [];
  List<bool> _eveningCheckboxValues = [];
  List<bool> _sosRadioValues = [];
  List<TextEditingController> _daysControllers = [];
  List<TextEditingController> _instructionsControllers = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.course.name);
    selectedMedicines = widget.course.medicines.map((med) {
      return Medicine(
        medId: med['medId'],
        medName: med['medName'],
        composition: med['composition'],
      );
    }).toList();

    for (var med in widget.course.medicines) {
      _morningCheckboxValues.add(med['dose']['morning']);
      _afternoonCheckboxValues.add(med['dose']['afternoon']);
      _eveningCheckboxValues.add(med['dose']['evening']);
      _sosRadioValues.add(med['dose']['sos']);
      _daysControllers.add(TextEditingController(text: med['days']));
      _instructionsControllers
          .add(TextEditingController(text: med['instructions']));
    }
  }

  // void _updateCourse() async {
  //   if (_nameController.text.isEmpty) {
  //     _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
  //     return;
  //   }

  //   if (isUpdatingCourse) {
  //     return;
  //   }

  //   setState(() {
  //     isUpdatingCourse = true;
  //   });

  //   try {
  //     List<Map<String, dynamic>> updatedMedicines = [];
  //     for (int i = 0; i < selectedMedicines.length; i++) {
  //       updatedMedicines.add({
  //         'medId': selectedMedicines[i].medId,
  //         'medName': selectedMedicines[i].medName,
  //         'dose': {
  //           'morning': _morningCheckboxValues[i],
  //           'afternoon': _afternoonCheckboxValues[i],
  //           'evening': _eveningCheckboxValues[i],
  //           'sos': _sosRadioValues[i],
  //         },
  //         'days': _daysControllers[i].text,
  //         'instructions': _instructionsControllers[i].text,
  //       });
  //     }

  //     PreDefinedCourse updatedCourse = PreDefinedCourse(
  //       id: widget.course.id,
  //       name: _nameController.text,
  //       medicines: updatedMedicines,
  //     );

  //     await widget.medicineService.updatePreDefinedCourse(updatedCourse);

  //     setState(() {
  //       isUpdatingCourse = false;
  //     });

  //     _showAlertDialog('Success', 'Course updated successfully.', () {
  //       Navigator.pop(context, updatedCourse);
  //     });
  //   } catch (error) {
  //     setState(() {
  //       isUpdatingCourse = false;
  //     });
  //     _showAlertDialog('Error', 'An error occurred while updating the course.');
  //   }
  // }

  void _updateCourse() async {
    if (_nameController.text.isEmpty) {
      _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
      return;
    }

    if (isUpdatingCourse) {
      return;
    }

    setState(() {
      isUpdatingCourse = true;
    });

    try {
      List<Map<String, dynamic>> updatedMedicines = [];
      for (int i = 0; i < selectedMedicines.length; i++) {
        updatedMedicines.add({
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

      PreDefinedCourse updatedCourse = PreDefinedCourse(
        id: widget.course.id, // Use course.id here
        name: _nameController.text,
        medicines: updatedMedicines,
      );

      devtools.log('Updating course: ${updatedCourse.toJson()}');

      await widget.medicineService.updatePreDefinedCourse(updatedCourse);

      setState(() {
        isUpdatingCourse = false;
      });

      _showAlertDialog('Success', 'Course updated successfully.', () {
        Navigator.pop(context, updatedCourse);
      });
    } catch (error) {
      devtools.log('Error updating course: $error');
      setState(() {
        isUpdatingCourse = false;
      });
      _showAlertDialog('Error', 'An error occurred while updating the course.');
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

  void _selectMedicine() async {
    final selected = await showDialog<List<Medicine>>(
      context: context,
      builder: (context) => SelectMedicineDialog(
        clinicId: widget.clinicId,
      ),
    );

    if (selected != null) {
      setState(() {
        selectedMedicines = selected;
        _morningCheckboxValues = List.filled(selected.length, false);
        _afternoonCheckboxValues = List.filled(selected.length, false);
        _eveningCheckboxValues = List.filled(selected.length, false);
        _sosRadioValues = List.filled(selected.length, false);
        _daysControllers =
            List.generate(selected.length, (_) => TextEditingController());
        _instructionsControllers =
            List.generate(selected.length, (_) => TextEditingController());
      });
    }
  }

  // Widget _buildMedicineTile(int index) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //     child: Column(
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
  //                 child: Text(
  //                   selectedMedicines[index].medName,
  //                   style: MyTextStyle.textStyleMap['label-large']
  //                       ?.copyWith(color: MyColors.colorPalette['secondary']),
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   Column(
  //                     children: [
  //                       SquareCheckboxWithLabel(
  //                         initialValue: _morningCheckboxValues[index],
  //                         onChanged: (value) {
  //                           setState(() {
  //                             if (value) {
  //                               _sosRadioValues[index] = false;
  //                             }
  //                             _morningCheckboxValues[index] = value;
  //                           });
  //                         },
  //                       ),
  //                       Text(
  //                         'Morning',
  //                         style: MyTextStyle.textStyleMap['label-medium']
  //                             ?.copyWith(
  //                                 color: MyColors.colorPalette['primary']),
  //                       ),
  //                     ],
  //                   ),
  //                   Column(
  //                     children: [
  //                       SquareCheckboxWithLabel(
  //                         initialValue: _afternoonCheckboxValues[index],
  //                         onChanged: (value) {
  //                           setState(() {
  //                             if (value) {
  //                               _sosRadioValues[index] = false;
  //                             }
  //                             _afternoonCheckboxValues[index] = value;
  //                           });
  //                         },
  //                       ),
  //                       Text(
  //                         'Afternoon',
  //                         style: MyTextStyle.textStyleMap['label-medium']
  //                             ?.copyWith(
  //                                 color: MyColors.colorPalette['primary']),
  //                       ),
  //                     ],
  //                   ),
  //                   Column(
  //                     children: [
  //                       SquareCheckboxWithLabel(
  //                         initialValue: _eveningCheckboxValues[index],
  //                         onChanged: (value) {
  //                           setState(() {
  //                             if (value) {
  //                               _sosRadioValues[index] = false;
  //                             }
  //                             _eveningCheckboxValues[index] = value;
  //                           });
  //                         },
  //                       ),
  //                       Text(
  //                         'Evening',
  //                         style: MyTextStyle.textStyleMap['label-medium']
  //                             ?.copyWith(
  //                                 color: MyColors.colorPalette['primary']),
  //                       ),
  //                     ],
  //                   ),
  //                   Container(
  //                     height: 50.0,
  //                     width: 2.0,
  //                     color: Colors.grey,
  //                   ),
  //                   Column(
  //                     children: [
  //                       RadioWithLabel(
  //                         initialValue: _sosRadioValues[index],
  //                         onChanged: (value) {
  //                           setState(() {
  //                             if (value) {
  //                               _morningCheckboxValues[index] = false;
  //                               _afternoonCheckboxValues[index] = false;
  //                               _eveningCheckboxValues[index] = false;
  //                             }
  //                             _sosRadioValues[index] = value;
  //                           });
  //                         },
  //                       ),
  //                       Text(
  //                         'SOS',
  //                         style: MyTextStyle.textStyleMap['label-medium']
  //                             ?.copyWith(
  //                                 color: MyColors.colorPalette['primary']),
  //                       ),
  //                     ],
  //                   ),
  //                   Container(
  //                     decoration: BoxDecoration(border: Border.all(width: 2)),
  //                     width: 54,
  //                     child: TextFormField(
  //                       controller: _daysControllers[index],
  //                       keyboardType: TextInputType.number,
  //                       maxLength: 1,
  //                       decoration: const InputDecoration(
  //                         counterText: '',
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: TextFormField(
  //                   controller: _instructionsControllers[index],
  //                   decoration: InputDecoration(
  //                     labelText: 'Instructions',
  //                     labelStyle: MyTextStyle.textStyleMap['label-medium']
  //                         ?.copyWith(
  //                             color:
  //                                 MyColors.colorPalette['on-surface-variant']),
  //                     focusedBorder: OutlineInputBorder(
  //                       borderRadius:
  //                           const BorderRadius.all(Radius.circular(8.0)),
  //                       borderSide: BorderSide(
  //                         color:
  //                             MyColors.colorPalette['primary'] ?? Colors.black,
  //                       ),
  //                     ),
  //                     border: OutlineInputBorder(
  //                       borderRadius:
  //                           const BorderRadius.all(Radius.circular(8.0)),
  //                       borderSide: BorderSide(
  //                         color: MyColors.colorPalette['on-surface-variant'] ??
  //                             Colors.black,
  //                       ),
  //                     ),
  //                     contentPadding: const EdgeInsets.only(left: 8.0),
  //                   ),
  //                   onChanged: (_) => setState(() {}),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //       ],
  //     ),
  //   );
  // }

  //------------------------------------------------------------------------- //
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
  // ------------------------------------------------------------------------ //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Edit Pre-defined Course',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
                          onPressed: _updateCourse,
                          child: Text(
                            'Update',
                            style: MyTextStyle.textStyleMap['label-large']
                                ?.copyWith(
                              color: MyColors.colorPalette['on-primary'],
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      if (isUpdatingCourse)
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
}

class SelectMedicineDialog extends StatefulWidget {
  final String clinicId;

  const SelectMedicineDialog({super.key, required this.clinicId});

  @override
  _SelectMedicineDialogState createState() => _SelectMedicineDialogState();
}

class _SelectMedicineDialogState extends State<SelectMedicineDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Medicine> matchingMedicines = [];
  List<Medicine> selectedMedicines = [];
  late MedicineService medicineService;

  @override
  void initState() {
    super.initState();
    medicineService = MedicineService(widget.clinicId);
  }

  void handleSearchInput(String userInput) async {
    if (userInput.isEmpty) {
      setState(() {
        matchingMedicines.clear();
        return;
      });
    }

    setState(() {
      matchingMedicines.clear();
    });

    matchingMedicines = await medicineService.searchMedicines(userInput);
    setState(() {});
  }

  void handleSelectedMedicine(Medicine medicine) {
    setState(() {
      if (selectedMedicines.contains(medicine)) {
        selectedMedicines.remove(medicine);
      } else {
        selectedMedicines.add(medicine);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Medicines'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              handleSearchInput(value);
            },
            decoration: const InputDecoration(
              labelText: 'Search Medicines',
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: matchingMedicines.length,
              itemBuilder: (context, index) {
                final medicine = matchingMedicines[index];
                final isSelected = selectedMedicines.contains(medicine);

                return ListTile(
                  title: Text(medicine.medName),
                  trailing: isSelected
                      ? const Icon(Icons.check_box)
                      : const Icon(Icons.check_box_outline_blank),
                  onTap: () {
                    handleSelectedMedicine(medicine);
                  },
                );
              },
            ),
          ),
        ],
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
            Navigator.pop(context, selectedMedicines);
          },
          child: const Text('Select'),
        ),
      ],
    );
  }
}

class SquareCheckboxWithLabel extends StatefulWidget {
  final bool initialValue;
  final Function(bool) onChanged;
  final bool showLabel;

  const SquareCheckboxWithLabel({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.showLabel = true,
  });

  @override
  State<SquareCheckboxWithLabel> createState() =>
      _SquareCheckboxWithLabelState();
}

class _SquareCheckboxWithLabelState extends State<SquareCheckboxWithLabel> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant SquareCheckboxWithLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _isChecked = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isChecked = !_isChecked;
              widget.onChanged(_isChecked);
            });
          },
          child: Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                color:
                    MyColors.colorPalette['surface-container'] ?? Colors.black,
                width: 2.0,
              ),
            ),
            child: _isChecked
                ? Icon(
                    Icons.check,
                    size: 16.0,
                    color: MyColors.colorPalette['primary'],
                  )
                : null,
          ),
        ),
        if (widget.showLabel) ...[
          const SizedBox(width: 8.0),
          Text(
            'Label',
            style: TextStyle(color: MyColors.colorPalette['on-surface']),
          ),
        ],
      ],
    );
  }
}

class RadioWithLabel extends StatefulWidget {
  final bool initialValue;
  final Function(bool) onChanged;
  final bool showLabel;

  const RadioWithLabel({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.showLabel = true,
  });

  @override
  State<RadioWithLabel> createState() => _RadioWithLabelState();
}

class _RadioWithLabelState extends State<RadioWithLabel> {
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant RadioWithLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _isSelected = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isSelected = !_isSelected;
              widget.onChanged(_isSelected);
            });
          },
          child: Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    MyColors.colorPalette['surface-container'] ?? Colors.black,
                width: 2.0,
              ),
            ),
            child: _isSelected
                ? Icon(
                    Icons.radio_button_checked,
                    size: 16.0,
                    color: MyColors.colorPalette['primary'],
                  )
                : Icon(Icons.radio_button_unchecked,
                    size: 16.0, color: MyColors.colorPalette['primary']),
          ),
        ),
        if (widget.showLabel) ...[
          const SizedBox(width: 8.0),
          Text(
            'Label',
            style: TextStyle(color: MyColors.colorPalette['on-surface']),
          ),
        ],
      ],
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/medicine_service.dart';
// import 'package:neocare_dental_app/mywidgets/medicine.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:developer' as devtools show log;

// import 'package:neocare_dental_app/mywidgets/pre_defined_courses.dart';

// class EditPreDefinedCourse extends StatefulWidget {
//   final String clinicId;
//   final PreDefinedCourse course;
//   final MedicineService medicineService;

//   const EditPreDefinedCourse({
//     super.key,
//     required this.clinicId,
//     required this.course,
//     required this.medicineService,
//   });

//   @override
//   State<EditPreDefinedCourse> createState() => _EditPreDefinedCourseState();
// }

// class _EditPreDefinedCourseState extends State<EditPreDefinedCourse> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   late TextEditingController _nameController;
//   late TextEditingController _daysController;
//   late TextEditingController _instructionsController;

//   bool isUpdatingCourse = false;
//   bool morning = false;
//   bool afternoon = false;
//   bool evening = false;
//   bool sos = false;
//   List<Medicine> selectedMedicines = [];

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.course.name);
//     _daysController = TextEditingController(text: widget.course.days);
//     _instructionsController =
//         TextEditingController(text: widget.course.instructions);
//     morning = widget.course.morning;
//     afternoon = widget.course.afternoon;
//     evening = widget.course.evening;
//     sos = widget.course.sos;
//     selectedMedicines = widget.course.medicines;
//   }

//   void _updateCourse() async {
//     if (_nameController.text.isEmpty || _daysController.text.isEmpty) {
//       _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
//       return;
//     }

//     if (isUpdatingCourse) {
//       return;
//     }

//     setState(() {
//       isUpdatingCourse = true;
//     });

//     try {
//       PreDefinedCourse updatedCourse = PreDefinedCourse(
//         id: widget.course.id,
//         name: _nameController.text,
//         medicines: selectedMedicines,
//         morning: morning,
//         afternoon: afternoon,
//         evening: evening,
//         sos: sos,
//         days: _daysController.text,
//         instructions: _instructionsController.text,
//       );

//       await widget.medicineService.updatePreDefinedCourse(updatedCourse);

//       setState(() {
//         isUpdatingCourse = false;
//       });

//       _showAlertDialog('Success', 'Course updated successfully.', () {
//         Navigator.pop(context, updatedCourse);
//       });
//     } catch (error) {
//       setState(() {
//         isUpdatingCourse = false;
//       });
//       _showAlertDialog('Error', 'An error occurred while updating the course.');
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

//   void _selectMedicine() async {
//     final selected = await showDialog<List<Medicine>>(
//       context: context,
//       builder: (context) => SelectMedicineDialog(
//         clinicId: widget.clinicId,
//       ),
//     );

//     if (selected != null) {
//       setState(() {
//         selectedMedicines = selected;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Edit Pre-defined Course',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
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
//                   child: TextFormField(
//                     controller: _daysController,
//                     decoration: InputDecoration(
//                       labelText: 'Days',
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
//                   child: TextFormField(
//                     controller: _instructionsController,
//                     decoration: InputDecoration(
//                       labelText: 'Instructions',
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
//                         for (var med in selectedMedicines)
//                           Text(
//                             med.medName,
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on-surface']),
//                           ),
//                       ],
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: CheckboxListTile(
//                           title: Text(
//                             'Morning',
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on-surface']),
//                           ),
//                           value: morning,
//                           onChanged: (value) {
//                             setState(() {
//                               morning = value!;
//                             });
//                           },
//                         ),
//                       ),
//                       Expanded(
//                         child: CheckboxListTile(
//                           title: Text(
//                             'Afternoon',
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on-surface']),
//                           ),
//                           value: afternoon,
//                           onChanged: (value) {
//                             setState(() {
//                               afternoon = value!;
//                             });
//                           },
//                         ),
//                       ),
//                       Expanded(
//                         child: CheckboxListTile(
//                           title: Text(
//                             'Evening',
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on-surface']),
//                           ),
//                           value: evening,
//                           onChanged: (value) {
//                             setState(() {
//                               evening = value!;
//                             });
//                           },
//                         ),
//                       ),
//                       Expanded(
//                         child: CheckboxListTile(
//                           title: Text(
//                             'SOS',
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on-surface']),
//                           ),
//                           value: sos,
//                           onChanged: (value) {
//                             setState(() {
//                               sos = value!;
//                             });
//                           },
//                         ),
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
//                           onPressed: _updateCourse,
//                           child: Text(
//                             'Update',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                               color: MyColors.colorPalette['on-primary'],
//                             ),
//                           ),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: const Text('Cancel'),
//                       ),
//                       if (isUpdatingCourse)
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
