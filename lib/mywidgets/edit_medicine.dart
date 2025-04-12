import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/medicine_service.dart';
import 'package:neocaresmileapp/mywidgets/medicine.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

class EditMedicineScreen extends StatefulWidget {
  final String clinicId;
  final Medicine medicine;
  final MedicineService medicineService;

  const EditMedicineScreen({
    super.key,
    required this.clinicId,
    required this.medicine,
    required this.medicineService,
  });

  @override
  State<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _compositionController;

  bool isUpdatingMedicine = false;
  bool updatingMedicine = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine.medName);
    _compositionController =
        TextEditingController(text: widget.medicine.composition);
  }

  void _updateMedicine() async {
    if (_nameController.text.isEmpty) {
      _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
      return;
    }

    if (isUpdatingMedicine) {
      return;
    }

    setState(() {
      isUpdatingMedicine = true;
    });

    try {
      Medicine updatedMedicine = Medicine(
        medId: widget.medicine.medId,
        medName: _nameController.text,
        composition: _compositionController.text.isNotEmpty
            ? _compositionController.text
            : null,
      );

      await widget.medicineService.updateMedicine(updatedMedicine);

      setState(() {
        isUpdatingMedicine = false;
      });

      _showAlertDialog('Success', 'Medicine updated successfully.', () {
        Navigator.pop(context, updatedMedicine);
      });
    } catch (error) {
      setState(() {
        isUpdatingMedicine = false;
      });
      _showAlertDialog(
          'Error', 'An error occurred while updating the medicine.');
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
        title: const Text('Edit Medicine'),
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
                        // decoration: const InputDecoration(
                        //   labelText: 'Medicine Name',
                        // ),
                        decoration: InputDecoration(
                          labelText: 'Medicine Name',
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
                        controller: _compositionController,
                        // decoration: const InputDecoration(
                        //   labelText: 'Composition',
                        // ),
                        decoration: InputDecoration(
                          labelText: 'Composition',
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
                    // ElevatedButton(
                    //   onPressed: _updateMedicine,
                    //   child: isUpdatingMedicine
                    //       ? const CircularProgressIndicator(
                    //           valueColor:
                    //               AlwaysStoppedAnimation<Color>(Colors.white),
                    //         )
                    //       : const Text('Update'),
                    // ),
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
                              onPressed: _updateMedicine,
                              child: Text(
                                'Update',
                                style: MyTextStyle.textStyleMap['label-large']
                                    ?.copyWith(
                                  color: MyColors.colorPalette['on-primary'],
                                ),
                              ),
                            ),
                          ),
                          // TextButton(
                          //   onPressed: () {
                          //     setState(() {
                          //       updatingMedicine = false;
                          //     });
                          //   },
                          //   child: const Text('Cancel'),
                          // ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),

                          if (isUpdatingMedicine)
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
