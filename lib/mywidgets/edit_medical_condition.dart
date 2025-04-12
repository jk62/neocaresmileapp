import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/medical_history_service.dart';
import 'package:neocaresmileapp/mywidgets/medical_condition.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

class EditMedicalCondition extends StatefulWidget {
  final String clinicId;
  final MedicalCondition condition;
  final MedicalHistoryService medicalHistoryService;

  const EditMedicalCondition({
    super.key,
    required this.clinicId,
    required this.condition,
    required this.medicalHistoryService,
  });

  @override
  State<EditMedicalCondition> createState() =>
      _EditMedicalConditionScreenState();
}

class _EditMedicalConditionScreenState extends State<EditMedicalCondition> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  bool isUpdatingCondition = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.condition.medicalConditionName);
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
      MedicalCondition updatedCondition = MedicalCondition(
        medicalConditionId: widget.condition.medicalConditionId,
        medicalConditionName: _nameController.text,
        doctorNote: widget.condition.doctorNote,
      );

      await widget.medicalHistoryService
          .updateMedicalCondition(updatedCondition);

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
        title: const Text('Edit Medical Condition'),
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
