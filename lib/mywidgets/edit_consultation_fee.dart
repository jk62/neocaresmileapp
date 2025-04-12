import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/consultation_service.dart';
import 'package:neocaresmileapp/mywidgets/consultation.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

class EditConsultationFee extends StatefulWidget {
  final String clinicId;
  final Consultation consultation;
  final ConsultationService consultationService;

  const EditConsultationFee({
    super.key,
    required this.clinicId,
    required this.consultation,
    required this.consultationService,
  });

  @override
  State<EditConsultationFee> createState() => _EditConsultationFeeState();
}

class _EditConsultationFeeState extends State<EditConsultationFee> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _feeController;

  bool isUpdatingConsultation = false;

  @override
  void initState() {
    super.initState();
    _feeController = TextEditingController(
      text: widget.consultation.consultationFee.toString(),
    );
  }

  void _updateConsultation() async {
    if (_feeController.text.isEmpty ||
        double.tryParse(_feeController.text) == null) {
      _showAlertDialog(
          'Invalid Input', 'Please enter a valid consultation fee.');
      return;
    }

    if (isUpdatingConsultation) {
      return;
    }

    setState(() {
      isUpdatingConsultation = true;
    });

    try {
      Consultation updatedConsultation = Consultation(
        consultationId: widget.consultation.consultationId,
        doctorId: widget.consultation.doctorId,
        doctorName: widget.consultation.doctorName,
        consultationFee: double.parse(_feeController.text),
      );

      await widget.consultationService.updateConsultation(updatedConsultation);

      setState(() {
        isUpdatingConsultation = false;
      });

      _showAlertDialog('Success', 'Consultation fee updated successfully.', () {
        Navigator.pop(context, updatedConsultation);
      });
    } catch (error) {
      setState(() {
        isUpdatingConsultation = false;
      });
      _showAlertDialog(
          'Error', 'An error occurred while updating the consultation fee.');
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
        title: const Text('Edit Consultation Fee'),
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
                        controller: _feeController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Consultation Fee',
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
                              onPressed: _updateConsultation,
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
                          if (isUpdatingConsultation)
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
