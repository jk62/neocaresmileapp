import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/firestore/medicine_service.dart';
import 'package:neocaresmileapp/firestore/prescription_service.dart';
import 'dart:developer' as devtools show log;
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/pre_defined_courses.dart';
import 'package:neocaresmileapp/mywidgets/prescription_data.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share/share.dart';
import 'medicine.dart';
import 'package:pdf/pdf.dart';

class PrescriptionTab extends StatefulWidget {
  final String clinicId;
  final VoidCallback navigateToPrescriptionTab;
  final String patientId;
  final String? treatmentId;
  final String? uhid;
  final String patientName;
  final String doctorName;

  const PrescriptionTab({
    super.key,
    required this.clinicId,
    required this.navigateToPrescriptionTab,
    required this.patientId,
    required this.treatmentId,
    required this.uhid,
    required this.patientName,
    required this.doctorName,
  });

  @override
  State<PrescriptionTab> createState() => _PrescriptionTabState();
}

class _PrescriptionTabState extends State<PrescriptionTab> {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  late MedicineService _medicineService;

  List<Medicine> matchingMedicines = [];

  bool _showMedicineInput = false;
  bool _showCheckboxContainer = false;
  List<Map<String, dynamic>> prescriptions = [];
  final List<TextEditingController> _daysControllers = [];
  final List<TextEditingController> _instructionsControllers = [];

  bool _showRecentPrescriptions = false;
  String _recentPrescriptionDate = '';
  bool _morningCheckboxValue = false;
  bool _afternoonCheckboxValue = false;
  bool _eveningCheckboxValue = false;
  bool _sosRadioValue = false;
  bool _isGenerating = false;
  bool _isPrintSummaryEnabled = false;
  bool _isSharingPrescription = false;

  List<String> _recentPrescriptionMedicines = [];
  Medicine? _selectedMedicine;
  List<PrescriptionData> _recentPrescriptionList = [];
  final GlobalKey letterheadKey = GlobalKey();
  String? pdfPath = '';
  List<Map<String, dynamic>> recentMedicines = [];

  List<PreDefinedCourse> preDefinedCourses = [];
  late PrescriptionService _prescriptionService;

  // ------------------------------------------------------------------------ //

  // ------------------------------------------------------------------------ //

  @override
  void initState() {
    super.initState();
    _medicineService = MedicineService(widget.clinicId);
    _showMedicineInput = false;
    _selectedMedicine = null;

    // Initialize _prescriptionService first
    _prescriptionService = PrescriptionService(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      treatmentId: widget.treatmentId,
    );

    // Now, it is safe to call these functions
    _loadExistingPrescriptions();
    _loadPreDefinedCourses();
  }

  @override
  void dispose() {
    for (var controller in _daysControllers) {
      controller.dispose();
    }
    for (var controller in _instructionsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPreDefinedCourses() async {
    try {
      List<PreDefinedCourse> courses =
          await _medicineService.getPreDefinedCourses();
      setState(() {
        preDefinedCourses = courses;
      });
    } catch (error) {
      devtools.log('Error loading pre-defined courses: $error');
    }
  }
  //---------------------------------------------------------------------------//

  // Modified function to use PrescriptionService
  void updateMatchingMedicines(String userInput) async {
    if (userInput.isEmpty) {
      setState(() {
        matchingMedicines.clear(); // Clear the list if input is empty
      });
      return;
    }

    // Call the function from PrescriptionService
    List<Medicine> fetchedMedicines =
        await _prescriptionService.updateMatchingMedicines(userInput);

    setState(() {
      matchingMedicines = fetchedMedicines; // Update the UI with the result
    });
  }
  //---------------------------------------------------------------------//

  Padding _buildCheckboxContainer(Map<String, dynamic> prescription) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
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
                  child: Text(
                    _medicineNameController.text,
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        SquareCheckboxWithLabel(
                          initialValue: _morningCheckboxValue,
                          onChanged: (value) {
                            setState(() {
                              if (value) {
                                _sosRadioValue = false;
                              }
                              _morningCheckboxValue = value;
                            });
                          },
                        ),
                        Text(
                          'Morning',
                          style: MyTextStyle.textStyleMap['label-medium']
                              ?.copyWith(
                                  color: MyColors.colorPalette['primary']),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SquareCheckboxWithLabel(
                          initialValue: _afternoonCheckboxValue,
                          onChanged: (value) {
                            setState(() {
                              if (value) {
                                _sosRadioValue = false;
                              }
                              _afternoonCheckboxValue = value;
                            });
                          },
                        ),
                        Text(
                          'Afternoon',
                          style: MyTextStyle.textStyleMap['label-medium']
                              ?.copyWith(
                                  color: MyColors.colorPalette['primary']),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SquareCheckboxWithLabel(
                          initialValue: _eveningCheckboxValue,
                          onChanged: (value) {
                            setState(() {
                              if (value) {
                                _sosRadioValue = false;
                              }
                              _eveningCheckboxValue = value;
                            });
                          },
                        ),
                        Text(
                          'Evening',
                          style: MyTextStyle.textStyleMap['label-medium']
                              ?.copyWith(
                                  color: MyColors.colorPalette['primary']),
                        ),
                      ],
                    ),
                    Container(
                      height: 50.0,
                      width: 2.0,
                      color: Colors.grey,
                    ),
                    Column(
                      children: [
                        RadioWithLabel(
                          initialValue: _sosRadioValue,
                          onChanged: (value) {
                            setState(() {
                              if (value) {
                                _morningCheckboxValue = false;
                                _afternoonCheckboxValue = false;
                                _eveningCheckboxValue = false;
                              }
                              _sosRadioValue = value;
                            });
                          },
                        ),
                        Text(
                          'SOS',
                          style: MyTextStyle.textStyleMap['label-medium']
                              ?.copyWith(
                                  color: MyColors.colorPalette['primary']),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(border: Border.all(width: 2)),
                      width: 54,
                      child: TextFormField(
                        controller: _daysController,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: const InputDecoration(
                          counterText: '',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void selectMedicine(Medicine medicine) {
    final prescriptionDate = DateTime.now();
    final formattedDate = DateFormat('MMMM dd, EEEE').format(prescriptionDate);
    setState(() {
      _selectedMedicine = medicine;

      final newPrescription = {
        'medId': medicine.medId,
        'medName': medicine.medName,
        'dose': {
          'morning': _morningCheckboxValue,
          'afternoon': _afternoonCheckboxValue,
          'evening': _eveningCheckboxValue,
          'sos': _sosRadioValue,
        },
        'days': '',
        'instructions': '',
        'prescriptionDate': prescriptionDate,
      };

      prescriptions.add(newPrescription);
      _daysControllers.add(TextEditingController());
      _instructionsControllers.add(TextEditingController());

      _selectedMedicine = null;

      _medicineNameController.clear();
      matchingMedicines.clear();
      _showCheckboxContainer = false;
      _recentPrescriptionDate = formattedDate;
    });
  }

  void cancelPrescription() {
    setState(() {
      prescriptions.clear();
      _daysControllers.clear();
      _instructionsControllers.clear();
      _showCheckboxContainer = false;
      _medicineNameController.clear();
      _selectedMedicine = null;
    });
  }
  //-----------------------------------------------------------------------//

  Future<String?> generateAndSavePrescriptions() async {
    try {
      final prescriptionData = {
        'treatmentId': widget.treatmentId,
        'medPrescribed': prescriptions,
      };
      devtools.log('prescriptionData is $prescriptionData');

      // Call the savePrescription function from PrescriptionService
      await _prescriptionService.savePrescription(prescriptionData);

      devtools
          .log('Prescription data has been successfully generated and saved.');

      // After saving, load the existing prescriptions
      await _loadExistingPrescriptions();

      setState(() {
        _showMedicineInput = false;
        prescriptions.clear();
        _daysControllers.clear();
        _instructionsControllers.clear();
        _selectedMedicine = null;
        _showRecentPrescriptions = true;
      });

      // Cast 'treatmentId' as String? before returning
      return prescriptionData['treatmentId'] as String?;
    } catch (error) {
      devtools.log('Error generating and saving prescription data: $error');
      return null;
    }
  }
  //----------------------------------------------------------------------//

  void clearSelectedMedicine() {
    setState(() {
      _selectedMedicine = null;
    });
  }

  Widget _buildPrescribedMedicine(
      Map<String, dynamic> prescription, int index) {
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
                        prescription['medName'],
                        style: MyTextStyle.textStyleMap['label-large']
                            ?.copyWith(
                                color: MyColors.colorPalette['secondary']),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          prescriptions.removeAt(index);
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
                                initialValue: prescription['dose']['morning'],
                                onChanged: (value) {
                                  setState(() {
                                    if (value) {
                                      prescription['dose']['sos'] = false;
                                    }
                                    prescription['dose']['morning'] = value;
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
                                initialValue: prescription['dose']['afternoon'],
                                onChanged: (value) {
                                  setState(() {
                                    if (value) {
                                      prescription['dose']['sos'] = false;
                                    }
                                    prescription['dose']['afternoon'] = value;
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
                                initialValue: prescription['dose']['evening'],
                                onChanged: (value) {
                                  setState(() {
                                    if (value) {
                                      prescription['dose']['sos'] = false;
                                    }
                                    prescription['dose']['evening'] = value;
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
                            initialValue: prescription['dose']['sos'],
                            onChanged: (value) {
                              setState(() {
                                if (value) {
                                  prescription['dose']['morning'] = false;
                                  prescription['dose']['afternoon'] = false;
                                  prescription['dose']['evening'] = false;
                                }
                                prescription['dose']['sos'] = value;
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
                                  prescription['days'] = value;
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
                          prescription['instructions'] = value;
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
  //-----------------------------------------------------------------------------//

  Future<void> _loadExistingPrescriptions() async {
    try {
      devtools.log('!!!! Welcome to _loadExistingPrescriptions !!!!!');
      // Fetch the existing prescriptions from the service
      final List<PrescriptionData> existingPrescriptionList =
          await _prescriptionService.fetchExistingPrescriptions();

      DateTime latestPrescriptionDate = DateTime(1900);

      for (final prescriptionData in existingPrescriptionList) {
        if (prescriptionData.prescriptionDate.isAfter(latestPrescriptionDate)) {
          latestPrescriptionDate = prescriptionData.prescriptionDate;
        }
      }

      if (existingPrescriptionList.isNotEmpty) {
        devtools.log(
            '!!! existingPrescriptionList is $existingPrescriptionList !!!!');
        setState(() {
          _showRecentPrescriptions = true;
          _recentPrescriptionDate =
              DateFormat('MMMM dd, EEEE').format(latestPrescriptionDate);
          _recentPrescriptionList = existingPrescriptionList;
        });
      }
    } catch (error) {
      devtools.log('Error loading existing prescriptions: $error');
    }
  }

  //------------------------------------------------------------------------------//

  Widget _buildRecentPrescriptionsContainer() {
    if (!_showRecentPrescriptions) {
      return Container();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Recent Prescriptions',
              style: MyTextStyle.textStyleMap['title-large']
                  ?.copyWith(color: MyColors.colorPalette['on-surface']),
            ),
          ),
        ),
        for (final prescriptionData in _recentPrescriptionList)
          _buildPrescriptionContainer(prescriptionData),
      ],
    );
  }

  Widget _buildPrescriptionContainer(PrescriptionData prescriptionData) {
    devtools.log(
        'This is coming from inside _buildPrescriptionContainer. medicines in prescriptionData are ${prescriptionData.medicines}');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM dd, EEEE')
                      .format(prescriptionData.prescriptionDate),
                  style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
                    color: MyColors.colorPalette['outline'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    devtools.log('Delete operation triggered');
                    _deletePrescription(prescriptionData);
                  },
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: MyColors.colorPalette['on-surface'],
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade300),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: prescriptionData.medicines.map((medicine) {
                  final dose = medicine['dose'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${medicine['medName']}',
                          style: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors.colorPalette['secondary'],
                                  fontWeight: FontWeight.w600),
                        ),
                        if (dose != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Wrap(
                              spacing: 8.0,
                              children: [
                                if (dose['morning'])
                                  Text(
                                    'Morning',
                                    style: MyTextStyle
                                        .textStyleMap['label-large']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['outline']),
                                  ),
                                Text(
                                  '-',
                                  style: MyTextStyle.textStyleMap['label-large']
                                      ?.copyWith(
                                          color:
                                              MyColors.colorPalette['outline']),
                                ),
                                if (dose['afternoon'])
                                  Text(
                                    'Afternoon',
                                    style: MyTextStyle
                                        .textStyleMap['label-large']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['outline']),
                                  ),
                                Text(
                                  '-',
                                  style: MyTextStyle.textStyleMap['label-large']
                                      ?.copyWith(
                                          color:
                                              MyColors.colorPalette['outline']),
                                ),
                                if (dose['evening'])
                                  Text(
                                    'Evening',
                                    style: MyTextStyle
                                        .textStyleMap['label-large']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['outline']),
                                  ),
                                if (dose['sos'])
                                  Text(
                                    'SOS',
                                    style: MyTextStyle
                                        .textStyleMap['label-large']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['outline']),
                                  ),
                                Text(
                                  'x ${medicine['days']} days',
                                  style: MyTextStyle.textStyleMap['label-large']
                                      ?.copyWith(
                                          color:
                                              MyColors.colorPalette['outline']),
                                ),
                              ],
                            ),
                          ),
                        if (medicine['instructions'] != null &&
                            medicine['instructions'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Instructions: ${medicine['instructions']}',
                              style: MyTextStyle.textStyleMap['label-large']
                                  ?.copyWith(
                                      color: MyColors.colorPalette['outline']),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    // _sharePrescriptionTableViaWhatsApp(prescriptionData);
                    // devtools.log('_sharePrescriptionTableViaWhatsApp invoked');
                    _showShareOptionsDialog(prescriptionData);
                  },
                  icon: Icon(
                    Icons.share,
                    size: 24,
                    color: MyColors.colorPalette['primary'],
                  ),
                ),
              ],
            ),
            // -------------------------------------------------------------- //

            // -------------------------------------------------------------- //
          ],
        ),
      ),
    );
  }

  void _showShareOptionsDialog(PrescriptionData prescriptionData) {
    bool printSummary = false;
    bool isSharing = false; // Track if sharing is ongoing

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                'Share Prescription',
                style: MyTextStyle.textStyleMap['title-large']?.copyWith(
                  color: MyColors.colorPalette['on-surface'],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: printSummary,
                        onChanged: (bool? value) {
                          setState(() {
                            printSummary = value ?? false;
                          });
                        },
                        activeColor: MyColors.colorPalette['primary'],
                        visualDensity: const VisualDensity(horizontal: -4.0),
                      ),
                      const SizedBox(width: 0),
                      Expanded(
                        child: Text(
                          'Include Summary',
                          style:
                              MyTextStyle.textStyleMap['label-large']?.copyWith(
                            color: MyColors.colorPalette['on-surface'],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isSharing)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        MyColors.colorPalette['primary']!,
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (!isSharing) {
                      Navigator.of(context)
                          .pop(); // Close the dialog if not sharing
                    }
                  },
                  child: Text(
                    'Cancel',
                    style: MyTextStyle.textStyleMap['label-large']?.copyWith(
                      color: MyColors.colorPalette['on-surface'],
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    // backgroundColor: MaterialStateProperty.all(
                    //     MyColors.colorPalette['primary']!),
                    backgroundColor: MaterialStateProperty.all(isSharing
                        ? Colors.grey
                        : MyColors.colorPalette['primary']!),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        side: BorderSide(
                            color: MyColors.colorPalette['primary']!,
                            width: 1.0),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                  onPressed: isSharing
                      ? null // Disable the button while sharing
                      : () async {
                          setState(() {
                            isSharing =
                                true; // Start showing progress indicator
                          });

                          // Run heavy task asynchronously without blocking UI thread
                          // await Future.delayed(
                          //     const Duration(milliseconds: 50000));
                          try {
                            if (printSummary) {
                              final combinedData =
                                  await fetchTreatmentAndPatientData();
                              if (combinedData != null) {
                                await _generateAndShareTreatmentSummaryPDF(
                                    combinedData, prescriptionData);
                              } else {
                                devtools.log(
                                    'Treatment or patient data not found.');
                              }
                            } else {
                              await _sharePrescriptionTableViaWhatsApp(
                                  prescriptionData);
                            }
                          } catch (error) {
                            devtools.log('Error while sharing: $error');
                          }

                          if (mounted) {
                            setState(() {
                              isSharing =
                                  false; // Stop showing progress indicator
                            });
                            Navigator.of(context)
                                .pop(); // Close the dialog after sharing
                          }
                        },
                  child: Text(
                    'OK',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['on-primary']),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------------------ //

  Future<Map<String, dynamic>?> fetchTreatmentAndPatientData() async {
    try {
      final combinedData =
          await _prescriptionService.fetchTreatmentAndPatientData();

      if (combinedData == null) {
        devtools.log('Treatment or patient data not found');
        return null;
      }

      devtools.log('Fetched combinedData: $combinedData');
      return combinedData;
    } catch (error) {
      devtools.log('Error fetching treatment or patient data: $error');
      return null;
    }
  }
  //--------------------------------------------------------------------------//

  Future<void> _generateAndShareTreatmentSummaryPDF(
      Map<String, dynamic> combinedData,
      PrescriptionData prescriptionData) async {
    final ByteData letterheadData =
        await rootBundle.load('assets/images/letterhead.png');
    final Uint8List letterheadBytes = letterheadData.buffer.asUint8List();

    final pdf = pw.Document();
    const int maxRowsPerPage = 36; // Limit rows per page

    // (1) Prepare list of individual rows from combinedData
    final List<pw.Widget> allRows = [];

    // Add static rows first
    allRows.add(_buildTreatmentSummaryRow());

    allRows.add(_buildRow('UHID: ${combinedData['patientData']['uhid']}',
        'Date: ${DateFormat('MMM dd, yyyy').format(combinedData['treatmentData']['treatmentDate'].toDate())}'));
    allRows.add(_buildTextRow(
        'Patient: ${combinedData['patientData']['patientName']}'));
    allRows.add(_buildTextRow(
        'Age/Gender: ${combinedData['patientData']['age']}/ ${combinedData['patientData']['gender']}'));

    // Add Chief Complaint section (mandatory)
    final chiefComplaintRows = _buildSectionRows(
        'Chief Complaint', combinedData['treatmentData']['chiefComplaint']);
    allRows.addAll(chiefComplaintRows);

    // Conditionally add Medical History section if it exists
    if (combinedData['treatmentData']['medicalHistory']?.isNotEmpty == true) {
      final medicalHistoryRows = _buildSectionRows(
          'Medical History', combinedData['treatmentData']['medicalHistory']);
      allRows.addAll(medicalHistoryRows);
    }

    // Conditionally add Oral Examination section if it exists
    if (combinedData['treatmentData']['oralExamination']?.isNotEmpty == true) {
      final oralExaminationRows = _buildOralExaminationRows(
          combinedData['treatmentData']['oralExamination']);
      allRows.addAll(oralExaminationRows);
    }

    // Conditionally add Procedures section if it exists
    if (combinedData['treatmentData']['procedures']?.isNotEmpty == true) {
      final proceduresRows =
          _buildProceduresRows(combinedData['treatmentData']['procedures']);
      allRows.addAll(proceduresRows);
    }

    // (2) Split rows into pages for the PDF
    List<pw.Widget> page1Rows = [];
    List<pw.Widget> page2Rows = [];

    if (allRows.length > maxRowsPerPage) {
      page1Rows = allRows.sublist(0, maxRowsPerPage);
      page2Rows = allRows.sublist(maxRowsPerPage);
    } else {
      page1Rows = allRows;
    }

    // (3) Prepare Page 1
    final List<pw.Widget> processedPage1Rows = _wrapWithBorders(page1Rows);

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(
                  pw.MemoryImage(letterheadBytes),
                  fit: pw.BoxFit.fill,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(60, 240, 40, 20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: processedPage1Rows,
                ),
              ),
            ],
          );
        },
      ),
    );

    // (4) Prepare Page 2 (if needed)
    if (page2Rows.isNotEmpty) {
      final List<pw.Widget> processedPage2Rows =
          _wrapPage2WithBorders(page2Rows);

      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Positioned.fill(
                  child: pw.Image(
                    pw.MemoryImage(letterheadBytes),
                    fit: pw.BoxFit.fill,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(60, 240, 40, 20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: processedPage2Rows,
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // Add the prescription to the PDF after the summary
    await _addPrescriptionToPdf(pdf, prescriptionData, letterheadBytes);

    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final pdfFile = File('$tempPath/treatment_summary_with_prescription.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    await Share.shareFiles([pdfFile.path],
        text: 'Treatment Summary and Prescription PDF');
    await pdfFile.delete();
  }

  List<pw.Widget> _buildOralExaminationRows(List<dynamic> oralExaminations) {
    List<pw.Widget> rows = [];

    // Add the title 'Oral Examination' once before the loop
    if (oralExaminations.isNotEmpty) {
      rows.add(_buildTextRow('Oral Examination')); // Font size 10 for title
    }

    for (var exam in oralExaminations) {
      rows.add(_buildTextRow(
          '${exam['conditionName']}')); // Font size 10 for condition name
      rows.addAll(_splitContentIntoRows(
          'Affected Teeth: ${exam['affectedTeeth'].join(', ')}',
          fontSize: 8)); // Font size 8 for affected teeth

      if (exam['doctorNote'] != null) {
        rows.addAll(_splitNoteIntoRows('${exam['doctorNote']}',
            fontSize: 8)); // Font size 8 for doctor note
      }
    }

    return rows;
  }

  // Helper method to create a text row with customizable font size
  pw.Widget _buildTextRow(String text, {double fontSize = 10}) {
    return pw.Text(text, style: pw.TextStyle(fontSize: fontSize));
  }

// Helper method to create a center-aligned 'Treatment Summary' row with font size 12
  pw.Widget _buildTreatmentSummaryRow() {
    return pw.Align(
      alignment: pw.Alignment.center, // Center-align the text
      child: pw.Text(
        'Treatment Summary',
        style: const pw.TextStyle(fontSize: 12), // Set the font size to 12
      ),
    );
  }

// Helper method to create a two-column row
  pw.Widget _buildRow(String leftText, String rightText) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(leftText, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(rightText, style: const pw.TextStyle(fontSize: 10)),
          ),
        ),
      ],
    );
  }

// Helper method to split content into rows

  List<pw.Widget> _buildSectionRows(String title, String content) {
    List<pw.Widget> rows = [];

    // Add the title (Chief Complaint or Medical History) with default font size
    rows.add(_buildTextRow(title));

    // Add the doctor note with font size 8
    rows.addAll(_splitContentIntoRows(content, fontSize: 8));

    return rows;
  }

// Helper method to split content into rows (e.g., for long text)

  List<pw.Widget> _splitContentIntoRows(String content,
      {double fontSize = 10}) {
    devtools.log(
        'Welcome to _splitContentIntoRows.  length of  content is ${content.length}');
    const int maxLength = 150; // Example max length per row
    List<pw.Widget> rows = [];

    // Add 50 spaces to the content
    //content = content + ' ' * 50;
    devtools
        .log('length of content after adding 50 spaces is ${content.length}');

    for (int i = 0; i < content.length; i += maxLength) {
      rows.add(pw.Text(
          content.substring(i,
              i + maxLength > content.length ? content.length : i + maxLength),
          style: pw.TextStyle(
              fontSize:
                  fontSize))); // Use the font size passed in the parameter
    }

    return rows;
  }

  List<pw.Widget> _splitNoteIntoRows(String content, {double fontSize = 10}) {
    devtools.log(
        'Welcome to _splitContentIntoRows.  length of  content is ${content.length}');
    const int maxLength = 150; // Example max length per row
    List<pw.Widget> rows = [];

    // Add 50 spaces to the content
    //content = content + '-' * 150;

    content =
        "$content.                                                                                                                                                 ."; // Using string interpolation

    devtools
        .log('length of content after adding 150 spaces is ${content.length}');

    for (int i = 0; i < content.length; i += maxLength) {
      rows.add(pw.Text(
          content.substring(i,
              i + maxLength > content.length ? content.length : i + maxLength),
          style: pw.TextStyle(
              fontSize:
                  fontSize))); // Use the font size passed in the parameter
    }

    return rows;
  }

  List<pw.Widget> _buildProceduresRows(List<dynamic> procedures) {
    List<pw.Widget> rows = [];

    // Add the title 'Procedures' once before the loop
    if (procedures.isNotEmpty) {
      rows.add(_buildTextRow('Procedures')); // Font size 10 for title
    }

    for (var procedure in procedures) {
      rows.add(_buildTextRow(
          '${procedure['procName']}')); // Font size 10 for procedure name
      rows.addAll(_splitContentIntoRows(
          'Affected Teeth: ${procedure['affectedTeeth'].join(', ')}',
          fontSize: 8)); // Font size 8 for affected teeth

      if (procedure['doctorNote'] != null) {
        rows.addAll(_splitNoteIntoRows('${procedure['doctorNote']}',
            fontSize: 8)); // Font size 8 for doctor note
        rows.add(pw.Padding(padding: const pw.EdgeInsets.only(bottom: 4)));
      }
    }

    return rows;
  }

  List<pw.Widget> _wrapWithBorders(List<pw.Widget> pageRows) {
    devtools.log('Welcome to _wrapWithBorders !');
    const int staticRowsCount = 4;
    List<pw.Widget> wrappedRows = [];

    // First, add the first 4 static rows without any wrapping
    wrappedRows.addAll(pageRows.sublist(0, staticRowsCount));
    devtools.log('Added first 4 static rows to wrappedRows');

    List<pw.Widget> currentSectionRows = [];
    String currentSection = "";

    for (int i = staticRowsCount; i < pageRows.length; i++) {
      final row = pageRows[i];
      if (row is pw.Text) {
        String textContent = _extractTextFromInlineSpan(row.text);

        // Check for section boundaries
        if (textContent == 'Chief Complaint') {
          // Handle Chief Complaint
          if (currentSectionRows.isNotEmpty) {
            wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
            currentSectionRows = [];
          }
          currentSection = 'Chief Complaint';
          currentSectionRows.add(row);
        } else if (textContent == 'Medical History') {
          // Handle Medical History
          if (currentSectionRows.isNotEmpty) {
            wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
            currentSectionRows = [];
          }
          currentSection = 'Medical History';
          currentSectionRows.add(row);
        } else if (textContent.contains('Oral Examination')) {
          // Handle Oral Examination
          if (currentSection == 'Oral Examination') {
            // We are still in the Oral Examination section, so add to the same container
            currentSectionRows.add(row);
          } else {
            // If we were in a different section, wrap the previous section
            if (currentSectionRows.isNotEmpty) {
              wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
              currentSectionRows = [];
            }
            currentSection =
                'Oral Examination'; // Now we're in the Oral Examination section
            currentSectionRows
                .add(row); // Add the first row of Oral Examination
          }
        } else if (textContent.contains('Procedure')) {
          // Handle Procedures
          if (currentSection == 'Procedure') {
            // We are still in the Procedures section, so add to the same container
            currentSectionRows.add(row);
          } else {
            // If we were in a different section, wrap the previous section
            if (currentSectionRows.isNotEmpty) {
              wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
              currentSectionRows = [];
            }
            currentSection = 'Procedure'; // Now we're in the Procedures section
            currentSectionRows.add(row); // Add the first row of Procedures
          }
        } else {
          // Add rows to the current section
          currentSectionRows.add(row);
        }
      }
    }

    // Wrap any remaining section at the end
    if (currentSectionRows.isNotEmpty) {
      wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
    }

    devtools.log('Final wrappedRows length: ${wrappedRows.length}');
    return wrappedRows;
  }

// Helper function to extract text from InlineSpan or TextSpan
  String _extractTextFromInlineSpan(pw.InlineSpan span) {
    if (span is pw.TextSpan) {
      if (span.text != null) {
        return span.text!;
      } else if (span.children != null) {
        // Concatenate the text from all children
        return span.children!.map((child) {
          if (child is pw.InlineSpan) {
            return _extractTextFromInlineSpan(
                child); // Recursively extract text from children
          }
          return '';
        }).join('');
      }
    }
    return '';
  }

// Helper function to wrap a section with border
  pw.Widget _wrapSectionWithBorder(List<pw.Widget> sectionRows) {
    devtools.log('Wrapping section with border for ${sectionRows.length} rows');
    return pw.Container(
      width: double.infinity,
      decoration:
          pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
      padding: const pw.EdgeInsets.all(4),
      margin: const pw.EdgeInsets.only(bottom: 4, top: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: sectionRows,
      ),
    );
  }

  //-------------------------------------------------------------------------//

  List<pw.Widget> _wrapPage2WithBorders(List<pw.Widget> pageRows) {
    devtools.log('Processing Page 2 content');
    List<pw.Widget> wrappedRows = [];

    List<pw.Widget> currentSectionRows = [];
    String currentSection = "";

    for (final row in pageRows) {
      if (row is pw.Text) {
        String textContent = _extractTextFromInlineSpan(row.text);

        // Handle Oral Examination section on Page 2
        if (textContent.contains('Oral Examination')) {
          if (currentSection == 'Oral Examination') {
            currentSectionRows.add(row);
          } else {
            // Wrap the previous section (if any)
            if (currentSectionRows.isNotEmpty) {
              wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
              currentSectionRows = [];
            }
            currentSection = 'Oral Examination';
            currentSectionRows
                .add(_buildTextRow('Oral Examination')); // Add title
            currentSectionRows.add(row);
          }
        }
        // Handle Procedures section on Page 2
        else if (textContent.contains('Procedure')) {
          if (currentSection == 'Procedure') {
            currentSectionRows.add(row);
          } else {
            // Wrap the previous section (if any)
            if (currentSectionRows.isNotEmpty) {
              wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
              currentSectionRows = [];
            }
            currentSection = 'Procedure';
            currentSectionRows.add(_buildTextRow('Procedures')); // Add title
            currentSectionRows.add(row);
          }
        } else {
          // Add rows to the current section
          currentSectionRows.add(row);
        }
      }
    }

    // Wrap any remaining rows for the last section
    if (currentSectionRows.isNotEmpty) {
      wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
    }

    devtools.log('Page 2 processedRows length: ${wrappedRows.length}');
    return wrappedRows;
  }

// -------------------------------------------------------------------------//

// ---------------------------------------------------------------------------//

  // ---------------------------------------------------------------------- //
  Future<void> _addPrescriptionToPdf(pw.Document pdf,
      PrescriptionData prescriptionData, Uint8List letterheadBytes) async {
    final ByteData rxSymbolData =
        await rootBundle.load('assets/images/rx_image.png');
    final Uint8List rxSymbolBytes = rxSymbolData.buffer.asUint8List();

    const int maxRowsPerPage = 10;
    final int totalRows = prescriptionData.medicines.length;
    final int totalPages = (totalRows / maxRowsPerPage).ceil();

    for (int page = 0; page < totalPages; page++) {
      final startRow = page * maxRowsPerPage;
      final endRow = (startRow + maxRowsPerPage).clamp(0, totalRows);

      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Positioned.fill(
                  child: pw.Image(pw.MemoryImage(letterheadBytes),
                      fit: pw.BoxFit.fill),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(40, 240, 20, 20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (page == 0) ...[
                        pw.Row(children: [
                          pw.Text(
                            'UHID :',
                            style: pw.TextStyle(
                              fontSize: 10.0,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(width: 8.0),
                          pw.Text(
                            '${widget.uhid}',
                            style: pw.TextStyle(
                              fontSize: 10.0,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                        ]),
                        pw.SizedBox(height: 8.0),
                        pw.Row(children: [
                          pw.Text(
                            'Patient :',
                            style: pw.TextStyle(
                              fontSize: 10.0,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(width: 8.0),
                          pw.Text(
                            widget.patientName,
                            style: pw.TextStyle(
                              fontSize: 10.0,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                        ]),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                DateFormat('MMM dd, yyyy')
                                    .format(prescriptionData.prescriptionDate),
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Row(
                                  mainAxisSize: pw.MainAxisSize.min,
                                  children: [
                                    pw.Text(
                                      'By',
                                      style: pw.TextStyle(
                                        fontSize: 10.0,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.SizedBox(width: 8.0),
                                    pw.Text(
                                      'Dr. ${widget.doctorName}',
                                      style: pw.TextStyle(
                                        fontSize: 10.0,
                                        fontWeight: pw.FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 16.0),
                        pw.Image(pw.MemoryImage(rxSymbolBytes),
                            width: 30, height: 30),
                        pw.SizedBox(height: 16.0),
                      ],
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey),
                        columnWidths: const {
                          0: pw.FlexColumnWidth(3),
                          1: pw.FlexColumnWidth(5),
                          2: pw.FlexColumnWidth(2),
                        },
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.all(4),
                                alignment: pw.Alignment.centerLeft,
                                child: _buildPdfTableCellWithoutBorder(
                                  'Medicine',
                                  3,
                                  bold: true,
                                  align: pw.TextAlign.left,
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(4),
                                alignment: pw.Alignment.center,
                                child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildPdfTableCellWithoutBorder(
                                      'Morning',
                                      1,
                                      bold: true,
                                    ),
                                    _buildPdfTableCellWithoutBorder(
                                      'Afternoon',
                                      1,
                                      bold: true,
                                    ),
                                    _buildPdfTableCellWithoutBorder(
                                      'Evening',
                                      1,
                                      bold: true,
                                    ),
                                    _buildPdfTableCellWithoutBorder(
                                      ' ',
                                      1,
                                      bold: true,
                                    ),
                                    _buildPdfTableCellWithoutBorder(
                                      'Days',
                                      1,
                                      bold: true,
                                    ),
                                  ],
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(4),
                                alignment: pw.Alignment.centerLeft,
                                child: _buildPdfTableCellWithoutBorder(
                                  'Instructions',
                                  2,
                                  bold: true,
                                  align: pw.TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          for (var medicine in prescriptionData.medicines
                              .sublist(startRow, endRow))
                            _buildPdfTableRow(medicine),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  // ------------------------------------------------------------------------ //

  void _deletePrescription(PrescriptionData prescriptionData) async {
    try {
      await _prescriptionService
          .deletePrescription(prescriptionData.prescriptionId);

      setState(() {
        _recentPrescriptionList.remove(prescriptionData);
        if (_recentPrescriptionList.isEmpty) {
          _showRecentPrescriptions = false;
        }
      });
    } catch (error) {
      devtools.log('Error deleting prescription: $error');
    }
  }
  //---------------------------------------------------------------------------//

  pw.Widget _buildPdfTableCellWithoutBorder(String content, int flex,
      {pw.TextAlign align = pw.TextAlign.center, bool bold = false}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        alignment: align == pw.TextAlign.left
            ? pw.Alignment.centerLeft
            : align == pw.TextAlign.right
                ? pw.Alignment.centerRight
                : pw.Alignment.center,
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(
          content,
          style: pw.TextStyle(
              fontSize: 8,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
          textAlign: align,
        ),
      ),
    );
  }

  pw.Widget _buildPdfTableCell(String content, int flex,
      {bool bold = false,
      pw.TextAlign align = pw.TextAlign.center,
      bool noBorder = false}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        alignment: align == pw.TextAlign.left
            ? pw.Alignment.centerLeft
            : align == pw.TextAlign.right
                ? pw.Alignment.centerRight
                : pw.Alignment.center,
        padding: const pw.EdgeInsets.all(4),
        decoration: noBorder
            ? null
            : pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
              ),
        child: pw.Text(
          content,
          style: pw.TextStyle(
              fontSize: 8,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
          textAlign: align,
        ),
      ),
    );
  }

  pw.TableRow _buildPdfTableRow(Map<String, dynamic> medicine) {
    final xValue = medicine['dose']['x'] ?? 'x';
    final isSOS = medicine['dose']['sos'] ?? false;

    return pw.TableRow(
      children: [
        _buildPdfTableCell(medicine['medName'], 3,
            align: pw.TextAlign.left, noBorder: true),
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              _buildPdfTableCellWithoutBorder(
                  isSOS ? '' : (medicine['dose']['morning'] ? '1' : '0'), 1),
              _buildPdfTableCellWithoutBorder(
                  isSOS ? '' : (medicine['dose']['afternoon'] ? '1' : '0'), 1),
              _buildPdfTableCellWithoutBorder(
                  isSOS ? '' : (medicine['dose']['evening'] ? '1' : '0'), 1),
              _buildPdfTableCellWithoutBorder(isSOS ? '' : xValue, 1),
              _buildPdfTableCellWithoutBorder(
                  isSOS ? 'sos' : medicine['days'], 1),
            ],
          ),
        ),
        _buildPdfTableCell(medicine['instructions'], 2,
            align: pw.TextAlign.left, noBorder: true),
      ],
    );
  }

  //void _sharePrescriptionTableViaWhatsApp(
  //PrescriptionData prescriptionData) async {
  Future<void> _sharePrescriptionTableViaWhatsApp(
      PrescriptionData prescriptionData) async {
    final ByteData letterheadData =
        await rootBundle.load('assets/images/letterhead.png');
    final Uint8List letterheadBytes = letterheadData.buffer.asUint8List();

    final ByteData rxSymbolData =
        await rootBundle.load('assets/images/rx_image.png');
    final Uint8List rxSymbolBytes = rxSymbolData.buffer.asUint8List();

    final pdf = pw.Document();

    const int maxRowsPerPage =
        10; // Set this based on the available space on your letterhead
    final int totalRows = prescriptionData.medicines.length;
    devtools.log(
        'No of totalRows of selected medicines turns out to be $totalRows');
    final int totalPages = (totalRows / maxRowsPerPage).ceil();
    devtools.log(
        'It is going to be printed on  $totalPages pages of the letterhead');

    for (int page = 0; page < totalPages; page++) {
      final startRow = page * maxRowsPerPage;
      final endRow = (startRow + maxRowsPerPage).clamp(0, totalRows);

      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Positioned.fill(
                  child: pw.Image(pw.MemoryImage(letterheadBytes),
                      fit: pw.BoxFit.cover),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(40, 240, 20, 20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(children: [
                        pw.Text(
                          'UHID :',
                          style: pw.TextStyle(
                            fontSize: 10.0,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(width: 8.0),
                        pw.Text(
                          '${widget.uhid}',
                          style: pw.TextStyle(
                            fontSize: 10.0,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                      ]),
                      pw.SizedBox(height: 8.0),
                      pw.Row(children: [
                        pw.Text(
                          'Patient :',
                          style: pw.TextStyle(
                            fontSize: 10.0,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(width: 8.0),
                        pw.Text(
                          widget.patientName,
                          style: pw.TextStyle(
                            fontSize: 10.0,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                      ]),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              DateFormat('MMM dd, yyyy')
                                  .format(prescriptionData.prescriptionDate),
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Row(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Text(
                                    'By',
                                    style: pw.TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.SizedBox(width: 8.0),
                                  pw.Text(
                                    'Dr. ${widget.doctorName}',
                                    style: pw.TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: pw.FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 16.0),
                      pw.Image(pw.MemoryImage(rxSymbolBytes),
                          width: 30, height: 30),
                      pw.SizedBox(height: 16.0),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey),
                        columnWidths: const {
                          0: pw.FlexColumnWidth(3),
                          1: pw.FlexColumnWidth(5),
                          2: pw.FlexColumnWidth(2),
                        },
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.all(4),
                                alignment: pw.Alignment.centerLeft,
                                child: _buildPdfTableCellWithoutBorder(
                                  'Medicine',
                                  3,
                                  bold: true,
                                  align: pw.TextAlign.left,
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(4),
                                alignment: pw.Alignment.center,
                                child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildPdfTableCellWithoutBorder(
                                      'Morning',
                                      1,
                                      bold: true,
                                    ),
                                    _buildPdfTableCellWithoutBorder(
                                      'Afternoon',
                                      1,
                                      bold: true,
                                    ),
                                    _buildPdfTableCellWithoutBorder(
                                      'Evening',
                                      1,
                                      bold: true,
                                    ),
                                    _buildPdfTableCellWithoutBorder(
                                      ' ',
                                      1,
                                      bold: true,
                                    ),
                                    _buildPdfTableCellWithoutBorder(
                                      'Days',
                                      1,
                                      bold: true,
                                    ),
                                  ],
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(4),
                                alignment: pw.Alignment.centerLeft,
                                child: _buildPdfTableCellWithoutBorder(
                                  'Instructions',
                                  2,
                                  bold: true,
                                  align: pw.TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          for (var medicine in prescriptionData.medicines
                              .sublist(startRow, endRow))
                            _buildPdfTableRow(medicine),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final pdfFile = File('$tempPath/prescription_table.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    await Share.shareFiles([pdfFile.path], text: 'Prescription Table PDF');
    await pdfFile.delete();
  }

  // ------------------------------------------------------------------------ //

  // ------------------------------------------------------------------------ //

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_showRecentPrescriptions)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'New Prescriptions',
                style: MyTextStyle.textStyleMap['title-large']
                    ?.copyWith(color: MyColors.colorPalette['on-surface']),
              ),
            ),
          ),
        if (_showMedicineInput)
          Container(
            //decoration: BoxDecoration(border: Border.all(width: 1.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          DateFormat('MMMM dd, EEEE').format(DateTime.now()),
                          style: MyTextStyle.textStyleMap['title-medium']
                              ?.copyWith(
                                  color: MyColors
                                      .colorPalette['on-surface-variant']),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showMedicineInput = false;
                          if (_recentPrescriptionList.isNotEmpty) {
                            _showRecentPrescriptions = true;
                            widget.navigateToPrescriptionTab();
                          }
                          // _showRecentPrescriptions = true;
                          // widget.navigateToPrescriptionTab();
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: TextField(
                        controller: _medicineNameController,
                        onChanged: (value) {
                          updateMatchingMedicines(value);
                        },
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
                                color: MyColors
                                        .colorPalette['on-surface-variant'] ??
                                    Colors.black),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _showCourseSelectionOverlay(context);
                        },
                        child: Text(
                          'Select Course',
                          style: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors.colorPalette['primary']),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                )
              ],
            ),
          ),
        if (_showRecentPrescriptions) _buildRecentPrescriptionsContainer(),
        if (!_showMedicineInput)
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  bottom: 8.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 144,
                    height: 48,
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
                          _showMedicineInput = true;
                          _showRecentPrescriptions = false;
                          widget.navigateToPrescriptionTab();
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
                                ?.copyWith(
                                    color: MyColors.colorPalette['primary']),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: matchingMedicines.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(matchingMedicines[index].medName,
                        textAlign: TextAlign.left),
                    const Icon(Icons.add, color: Colors.blue),
                  ],
                ),
                onTap: () {
                  selectMedicine(matchingMedicines[index]);
                },
              ),
            );
          },
        ),
        if (_showCheckboxContainer)
          _buildCheckboxContainer({
            'dose': {
              'morning': false,
              'afternoon': false,
              'evening': false,
              'sos': false,
            }
          }),
        if (prescriptions.isNotEmpty)
          Column(
            children: [
              for (int index = 0; index < prescriptions.length; index++)
                _buildPrescribedMedicine(prescriptions[index], index),

              // ----------------------------------------------------------- //
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 48,
                      width: 144,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            MyColors.colorPalette['primary']!,
                          ),
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
                        onPressed: _isGenerating
                            ? null
                            : () async {
                                setState(() {
                                  _isGenerating = true;
                                });

                                await generateAndSavePrescriptions();

                                setState(() {
                                  _isGenerating = false;
                                });
                              },
                        child: _isGenerating
                            ? CircularProgressIndicator(
                                color: MyColors.colorPalette['on-primary'],
                              )
                            : Text(
                                'Generate',
                                style: MyTextStyle.textStyleMap['label-large']
                                    ?.copyWith(
                                  color: MyColors.colorPalette['on-primary'],
                                ),
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed: _isGenerating
                          ? null
                          : () {
                              cancelPrescription();
                            },
                      child: Text(
                        'Cancel',
                        style: MyTextStyle.textStyleMap['label-large']
                            ?.copyWith(
                                color: MyColors.colorPalette['on-surface']),
                      ),
                    ),
                  ],
                ),
              ),

              // ----------------------------------------------------------- //
            ],
          ),
        if (_selectedMedicine != null)
          _buildCheckboxContainer({
            'dose': {
              'morning': false,
              'afternoon': false,
              'evening': false,
              'sos': false,
            }
          }),
      ],
    );
  }

  void _showCourseSelectionOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing by tapping outside the dialog
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              Colors.transparent, // Make the dialog background transparent
          insetPadding: const EdgeInsets.all(0), // Remove default padding
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white, // Set app bar color to white
              leading: IconButton(
                icon: Icon(Icons.close,
                    color: MyColors.colorPalette['on-surface']),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              title: Text(
                'Select a Course',
                style: MyTextStyle.textStyleMap['title-large']
                    ?.copyWith(color: MyColors.colorPalette['on-surface']),
              ),
            ),
            body: Container(
              color: Colors.white, // Set the overall background color to white
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: preDefinedCourses.length,
                itemBuilder: (context, index) {
                  PreDefinedCourse course = preDefinedCourses[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: MyColors.colorPalette[
                            'surface-container'], // Set individual template color
                        border: Border.all(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Course ${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: MyColors.colorPalette['primary'],
                              ),
                            ),
                            ...course.medicines.map((medicine) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${medicine['medName']} x ${medicine['days']} Days${medicine['dose']['sos'] ? ' x sos' : ''}',
                                    style: MyTextStyle
                                        .textStyleMap['label-large']!
                                        .copyWith(
                                            color: MyColors
                                                .colorPalette['on-surface']),
                                  ),
                                  Text(
                                    'Instructions: ${medicine['instructions']}',
                                    style: MyTextStyle
                                        .textStyleMap['label-small']!
                                        .copyWith(
                                            color: MyColors
                                                .colorPalette['on-surface']),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _showMedicineInput = true;
                            _showRecentPrescriptions = false;
                            for (var medicine in course.medicines) {
                              final newPrescription = {
                                'medId': medicine['medId'],
                                'medName': medicine['medName'],
                                'dose': {
                                  'morning': medicine['dose']['morning'],
                                  'afternoon': medicine['dose']['afternoon'],
                                  'evening': medicine['dose']['evening'],
                                  'sos': medicine['dose']['sos'],
                                },
                                'days': medicine['days'],
                                'instructions': medicine['instructions'],
                              };
                              prescriptions.add(newPrescription);
                              _daysControllers.add(TextEditingController(
                                  text: medicine['days']));
                              _instructionsControllers.add(
                                  TextEditingController(
                                      text: medicine['instructions']));
                            }
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
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
                : Icon(
                    Icons.radio_button_unchecked,
                    size: 16.0,
                    color: MyColors.colorPalette['primary'],
                  ),
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

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW IS STABLE WITH DIRECT BACKEND CALLS
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/medicine_service.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/pre_defined_courses.dart';
// import 'package:neocare_dental_app/mywidgets/prescription_data.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:share/share.dart';
// import 'medicine.dart';
// import 'package:pdf/pdf.dart';

// class PrescriptionTab extends StatefulWidget {
//   final String clinicId;
//   final VoidCallback navigateToPrescriptionTab;
//   final String patientId;
//   final String? treatmentId;
//   final String? uhid;
//   final String patientName;
//   final String doctorName;

//   const PrescriptionTab({
//     super.key,
//     required this.clinicId,
//     required this.navigateToPrescriptionTab,
//     required this.patientId,
//     required this.treatmentId,
//     required this.uhid,
//     required this.patientName,
//     required this.doctorName,
//   });

//   @override
//   State<PrescriptionTab> createState() => _PrescriptionTabState();
// }

// class _PrescriptionTabState extends State<PrescriptionTab> {
//   final TextEditingController _medicineNameController = TextEditingController();
//   final TextEditingController _daysController = TextEditingController();
//   late MedicineService _medicineService;

//   List<Medicine> matchingMedicines = [];

//   bool _showMedicineInput = false;
//   bool _showCheckboxContainer = false;
//   List<Map<String, dynamic>> prescriptions = [];
//   final List<TextEditingController> _daysControllers = [];
//   final List<TextEditingController> _instructionsControllers = [];

//   bool _showRecentPrescriptions = false;
//   String _recentPrescriptionDate = '';
//   bool _morningCheckboxValue = false;
//   bool _afternoonCheckboxValue = false;
//   bool _eveningCheckboxValue = false;
//   bool _sosRadioValue = false;
//   bool _isGenerating = false;
//   bool _isPrintSummaryEnabled = false;
//   bool _isSharingPrescription = false;

//   List<String> _recentPrescriptionMedicines = [];
//   Medicine? _selectedMedicine;
//   List<PrescriptionData> _recentPrescriptionList = [];
//   final GlobalKey letterheadKey = GlobalKey();
//   String? pdfPath = '';
//   List<Map<String, dynamic>> recentMedicines = [];

//   List<PreDefinedCourse> preDefinedCourses = [];

//   // ------------------------------------------------------------------------ //

//   // ------------------------------------------------------------------------ //

//   @override
//   void initState() {
//     super.initState();
//     _medicineService = MedicineService(widget.clinicId);
//     _showMedicineInput = false;
//     _selectedMedicine = null;
//     _loadExistingPrescriptions();
//     _loadPreDefinedCourses();
//   }

//   @override
//   void dispose() {
//     for (var controller in _daysControllers) {
//       controller.dispose();
//     }
//     for (var controller in _instructionsControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _loadPreDefinedCourses() async {
//     try {
//       List<PreDefinedCourse> courses =
//           await _medicineService.getPreDefinedCourses();
//       setState(() {
//         preDefinedCourses = courses;
//       });
//     } catch (error) {
//       devtools.log('Error loading pre-defined courses: $error');
//     }
//   }

//   void updateMatchingMedicines(String userInput) async {
//     matchingMedicines.clear();

//     if (userInput.isEmpty) {
//       setState(() {});
//       return;
//     }

//     final firstChar = userInput[0];
//     final convertedInput = firstChar.toLowerCase() == firstChar
//         ? firstChar.toUpperCase() + userInput.substring(1)
//         : userInput;

//     final medicinesCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(widget.clinicId)
//         .collection('medicines');

//     final querySnapshot = await medicinesCollection
//         .where('medName', isGreaterThanOrEqualTo: convertedInput)
//         .where('medName', isLessThan: '${convertedInput}z')
//         .get();

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data();
//       final medicine = Medicine(
//         medId: doc.id,
//         medName: data['medName'],
//         composition: '',
//       );
//       matchingMedicines.add(medicine);
//     }

//     setState(() {});
//   }

//   Padding _buildCheckboxContainer(Map<String, dynamic> prescription) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8.0),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//             child: Column(
//               children: [
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: Text(
//                     _medicineNameController.text,
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['secondary']),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Column(
//                       children: [
//                         SquareCheckboxWithLabel(
//                           initialValue: _morningCheckboxValue,
//                           onChanged: (value) {
//                             setState(() {
//                               if (value) {
//                                 _sosRadioValue = false;
//                               }
//                               _morningCheckboxValue = value;
//                             });
//                           },
//                         ),
//                         Text(
//                           'Morning',
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['primary']),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         SquareCheckboxWithLabel(
//                           initialValue: _afternoonCheckboxValue,
//                           onChanged: (value) {
//                             setState(() {
//                               if (value) {
//                                 _sosRadioValue = false;
//                               }
//                               _afternoonCheckboxValue = value;
//                             });
//                           },
//                         ),
//                         Text(
//                           'Afternoon',
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['primary']),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         SquareCheckboxWithLabel(
//                           initialValue: _eveningCheckboxValue,
//                           onChanged: (value) {
//                             setState(() {
//                               if (value) {
//                                 _sosRadioValue = false;
//                               }
//                               _eveningCheckboxValue = value;
//                             });
//                           },
//                         ),
//                         Text(
//                           'Evening',
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['primary']),
//                         ),
//                       ],
//                     ),
//                     Container(
//                       height: 50.0,
//                       width: 2.0,
//                       color: Colors.grey,
//                     ),
//                     Column(
//                       children: [
//                         RadioWithLabel(
//                           initialValue: _sosRadioValue,
//                           onChanged: (value) {
//                             setState(() {
//                               if (value) {
//                                 _morningCheckboxValue = false;
//                                 _afternoonCheckboxValue = false;
//                                 _eveningCheckboxValue = false;
//                               }
//                               _sosRadioValue = value;
//                             });
//                           },
//                         ),
//                         Text(
//                           'SOS',
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['primary']),
//                         ),
//                       ],
//                     ),
//                     Container(
//                       decoration: BoxDecoration(border: Border.all(width: 2)),
//                       width: 54,
//                       child: TextFormField(
//                         controller: _daysController,
//                         keyboardType: TextInputType.number,
//                         maxLength: 1,
//                         decoration: const InputDecoration(
//                           counterText: '',
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }

//   void selectMedicine(Medicine medicine) {
//     final prescriptionDate = DateTime.now();
//     final formattedDate = DateFormat('MMMM dd, EEEE').format(prescriptionDate);
//     setState(() {
//       _selectedMedicine = medicine;

//       final newPrescription = {
//         'medId': medicine.medId,
//         'medName': medicine.medName,
//         'dose': {
//           'morning': _morningCheckboxValue,
//           'afternoon': _afternoonCheckboxValue,
//           'evening': _eveningCheckboxValue,
//           'sos': _sosRadioValue,
//         },
//         'days': '',
//         'instructions': '',
//         'prescriptionDate': prescriptionDate,
//       };

//       prescriptions.add(newPrescription);
//       _daysControllers.add(TextEditingController());
//       _instructionsControllers.add(TextEditingController());

//       _selectedMedicine = null;

//       _medicineNameController.clear();
//       matchingMedicines.clear();
//       _showCheckboxContainer = false;
//       _recentPrescriptionDate = formattedDate;
//     });
//   }

//   void cancelPrescription() {
//     setState(() {
//       prescriptions.clear();
//       _daysControllers.clear();
//       _instructionsControllers.clear();
//       _showCheckboxContainer = false;
//       _medicineNameController.clear();
//       _selectedMedicine = null;
//     });
//   }

//   Future<String?> generateAndSavePrescriptions() async {
//     try {
//       final prescriptionData = {
//         'treatmentId': widget.treatmentId,
//         'medPrescribed': prescriptions,
//       };
//       devtools.log('prescriptionData is $prescriptionData');

//       final prescriptionCollectionRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(widget.patientId)
//           .collection('treatments')
//           .doc(widget.treatmentId)
//           .collection('prescriptions');

//       final prescriptionDocRef =
//           await prescriptionCollectionRef.add(prescriptionData);

//       final prescriptionId = prescriptionDocRef.id;

//       await prescriptionDocRef.update({'prescriptionId': prescriptionId});

//       devtools
//           .log('Prescription data has been successfully generated and saved.');
//       await _loadExistingPrescriptions();
//       setState(() {
//         _showMedicineInput = false;
//         prescriptions.clear();
//         _daysControllers.clear();
//         _instructionsControllers.clear();
//         _selectedMedicine = null;

//         _showRecentPrescriptions = true;
//       });

//       return prescriptionId;
//     } catch (error) {
//       devtools.log('Error generating and saving prescription data: $error');
//       return null;
//     }
//   }

//   void clearSelectedMedicine() {
//     setState(() {
//       _selectedMedicine = null;
//     });
//   }

//   Widget _buildPrescribedMedicine(
//       Map<String, dynamic> prescription, int index) {
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
//                         prescription['medName'],
//                         style: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['secondary']),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           prescriptions.removeAt(index);
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
//                                 initialValue: prescription['dose']['morning'],
//                                 onChanged: (value) {
//                                   setState(() {
//                                     if (value) {
//                                       prescription['dose']['sos'] = false;
//                                     }
//                                     prescription['dose']['morning'] = value;
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
//                                 initialValue: prescription['dose']['afternoon'],
//                                 onChanged: (value) {
//                                   setState(() {
//                                     if (value) {
//                                       prescription['dose']['sos'] = false;
//                                     }
//                                     prescription['dose']['afternoon'] = value;
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
//                                 initialValue: prescription['dose']['evening'],
//                                 onChanged: (value) {
//                                   setState(() {
//                                     if (value) {
//                                       prescription['dose']['sos'] = false;
//                                     }
//                                     prescription['dose']['evening'] = value;
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
//                             initialValue: prescription['dose']['sos'],
//                             onChanged: (value) {
//                               setState(() {
//                                 if (value) {
//                                   prescription['dose']['morning'] = false;
//                                   prescription['dose']['afternoon'] = false;
//                                   prescription['dose']['evening'] = false;
//                                 }
//                                 prescription['dose']['sos'] = value;
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
//                                   prescription['days'] = value;
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
//                           prescription['instructions'] = value;
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

//   Future<void> _loadExistingPrescriptions() async {
//     try {
//       final existingPrescriptionsSnapshot = await FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(widget.patientId)
//           .collection('treatments')
//           .doc(widget.treatmentId)
//           .collection('prescriptions')
//           .get();

//       final List<PrescriptionData> existingPrescriptionList = [];

//       DateTime latestPrescriptionDate = DateTime(1900);

//       for (final doc in existingPrescriptionsSnapshot.docs) {
//         final data = doc.data();

//         final prescriptions =
//             List<Map<String, dynamic>>.from(data['medPrescribed'] ?? []);
//         final prescriptionList = <Map<String, dynamic>>[];

//         for (final prescription in prescriptions) {
//           final prescriptionDate =
//               (prescription['prescriptionDate'] as Timestamp?)?.toDate() ??
//                   DateTime.now();

//           if (prescriptionDate.isAfter(latestPrescriptionDate)) {
//             latestPrescriptionDate = prescriptionDate;
//           }

//           prescriptionList.add({
//             'medName': prescription['medName'],
//             'days': prescription['days'],
//             'instructions': prescription['instructions'] ?? '',
//             'dose': prescription['dose'] ??
//                 {
//                   'morning': false,
//                   'afternoon': false,
//                   'evening': false,
//                   'sos': false,
//                 }
//           });
//         }

//         existingPrescriptionList.add(PrescriptionData(
//           prescriptionId: doc.id,
//           prescriptionDate: latestPrescriptionDate,
//           medicines: prescriptionList,
//         ));
//       }

//       if (existingPrescriptionList.isNotEmpty) {
//         devtools.log('existingPrescriptionList is $existingPrescriptionList');
//         setState(() {
//           _showRecentPrescriptions = true;
//           _recentPrescriptionDate =
//               DateFormat('MMMM dd, EEEE').format(latestPrescriptionDate);
//           _recentPrescriptionList = existingPrescriptionList;
//         });
//       }
//     } catch (error) {
//       devtools.log('Error loading existing prescriptions: $error');
//     }
//   }

//   Widget _buildRecentPrescriptionsContainer() {
//     if (!_showRecentPrescriptions) {
//       return Container();
//     }

//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//           child: Align(
//             alignment: Alignment.topLeft,
//             child: Text(
//               'Recent Prescriptions',
//               style: MyTextStyle.textStyleMap['title-large']
//                   ?.copyWith(color: MyColors.colorPalette['on-surface']),
//             ),
//           ),
//         ),
//         for (final prescriptionData in _recentPrescriptionList)
//           _buildPrescriptionContainer(prescriptionData),
//       ],
//     );
//   }

//   Widget _buildPrescriptionContainer(PrescriptionData prescriptionData) {
//     devtools.log(
//         'This is coming from inside _buildPrescriptionContainer. medicines in prescriptionData are ${prescriptionData.medicines}');
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(12.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               spreadRadius: 2,
//               blurRadius: 5,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   DateFormat('MMMM dd, EEEE')
//                       .format(prescriptionData.prescriptionDate),
//                   style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                     color: MyColors.colorPalette['outline'],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     devtools.log('Delete operation triggered');
//                     _deletePrescription(prescriptionData);
//                   },
//                   child: Icon(
//                     Icons.close,
//                     size: 24,
//                     color: MyColors.colorPalette['on-surface'],
//                   ),
//                 ),
//               ],
//             ),
//             Divider(color: Colors.grey.shade300),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: prescriptionData.medicines.map((medicine) {
//                   final dose = medicine['dose'];
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '${medicine['medName']}',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary'],
//                                   fontWeight: FontWeight.w600),
//                         ),
//                         if (dose != null)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4.0),
//                             child: Wrap(
//                               spacing: 8.0,
//                               children: [
//                                 if (dose['morning'])
//                                   Text(
//                                     'Morning',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-large']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['outline']),
//                                   ),
//                                 Text(
//                                   '-',
//                                   style: MyTextStyle.textStyleMap['label-large']
//                                       ?.copyWith(
//                                           color:
//                                               MyColors.colorPalette['outline']),
//                                 ),
//                                 if (dose['afternoon'])
//                                   Text(
//                                     'Afternoon',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-large']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['outline']),
//                                   ),
//                                 Text(
//                                   '-',
//                                   style: MyTextStyle.textStyleMap['label-large']
//                                       ?.copyWith(
//                                           color:
//                                               MyColors.colorPalette['outline']),
//                                 ),
//                                 if (dose['evening'])
//                                   Text(
//                                     'Evening',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-large']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['outline']),
//                                   ),
//                                 if (dose['sos'])
//                                   Text(
//                                     'SOS',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-large']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['outline']),
//                                   ),
//                                 Text(
//                                   'x ${medicine['days']} days',
//                                   style: MyTextStyle.textStyleMap['label-large']
//                                       ?.copyWith(
//                                           color:
//                                               MyColors.colorPalette['outline']),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         if (medicine['instructions'] != null &&
//                             medicine['instructions'].isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4.0),
//                             child: Text(
//                               'Instructions: ${medicine['instructions']}',
//                               style: MyTextStyle.textStyleMap['label-large']
//                                   ?.copyWith(
//                                       color: MyColors.colorPalette['outline']),
//                             ),
//                           ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     // _sharePrescriptionTableViaWhatsApp(prescriptionData);
//                     // devtools.log('_sharePrescriptionTableViaWhatsApp invoked');
//                     _showShareOptionsDialog(prescriptionData);
//                   },
//                   icon: Icon(
//                     Icons.share,
//                     size: 24,
//                     color: MyColors.colorPalette['primary'],
//                   ),
//                 ),
//               ],
//             ),
//             // -------------------------------------------------------------- //

//             // -------------------------------------------------------------- //
//           ],
//         ),
//       ),
//     );
//   }

//   void _showShareOptionsDialog(PrescriptionData prescriptionData) {
//     bool printSummary = false;
//     bool isSharing = false; // Track if sharing is ongoing

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return AlertDialog(
//               title: Text(
//                 'Share Prescription',
//                 style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                   color: MyColors.colorPalette['on-surface'],
//                 ),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Checkbox(
//                         value: printSummary,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             printSummary = value ?? false;
//                           });
//                         },
//                         activeColor: MyColors.colorPalette['primary'],
//                         visualDensity: const VisualDensity(horizontal: -4.0),
//                       ),
//                       const SizedBox(width: 0),
//                       Expanded(
//                         child: Text(
//                           'Include Summary',
//                           style:
//                               MyTextStyle.textStyleMap['label-large']?.copyWith(
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   if (isSharing)
//                     CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         MyColors.colorPalette['primary']!,
//                       ),
//                     ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     if (!isSharing) {
//                       Navigator.of(context)
//                           .pop(); // Close the dialog if not sharing
//                     }
//                   },
//                   child: Text(
//                     'Cancel',
//                     style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   style: ButtonStyle(
//                     // backgroundColor: MaterialStateProperty.all(
//                     //     MyColors.colorPalette['primary']!),
//                     backgroundColor: MaterialStateProperty.all(isSharing
//                         ? Colors.grey
//                         : MyColors.colorPalette['primary']!),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         side: BorderSide(
//                             color: MyColors.colorPalette['primary']!,
//                             width: 1.0),
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   onPressed: isSharing
//                       ? null // Disable the button while sharing
//                       : () async {
//                           setState(() {
//                             isSharing =
//                                 true; // Start showing progress indicator
//                           });

//                           // Run heavy task asynchronously without blocking UI thread
//                           // await Future.delayed(
//                           //     const Duration(milliseconds: 50000));
//                           try {
//                             if (printSummary) {
//                               final combinedData =
//                                   await fetchTreatmentAndPatientData();
//                               if (combinedData != null) {
//                                 await _generateAndShareTreatmentSummaryPDF(
//                                     combinedData, prescriptionData);
//                               } else {
//                                 devtools.log(
//                                     'Treatment or patient data not found.');
//                               }
//                             } else {
//                               await _sharePrescriptionTableViaWhatsApp(
//                                   prescriptionData);
//                             }
//                           } catch (error) {
//                             devtools.log('Error while sharing: $error');
//                           }

//                           if (mounted) {
//                             setState(() {
//                               isSharing =
//                                   false; // Stop showing progress indicator
//                             });
//                             Navigator.of(context)
//                                 .pop(); // Close the dialog after sharing
//                           }
//                         },
//                   child: Text(
//                     'OK',
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['on-primary']),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // ------------------------------------------------------------------------ //

//   Future<Map<String, dynamic>?> fetchTreatmentAndPatientData() async {
//     try {
//       // Reference to the treatment document in Firestore
//       final treatmentRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(widget.patientId)
//           .collection('treatments')
//           .doc(widget.treatmentId);

//       // Fetch the treatment document snapshot
//       final DocumentSnapshot treatmentSnapshot = await treatmentRef.get();

//       if (!treatmentSnapshot.exists) {
//         devtools.log(
//             'Treatment data not found for treatmentId: ${widget.treatmentId}');
//         return null;
//       }

//       // Fetch the patient document snapshot
//       final patientRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(widget.patientId);
//       final DocumentSnapshot patientSnapshot = await patientRef.get();

//       if (!patientSnapshot.exists) {
//         devtools
//             .log('Patient data not found for patientId: ${widget.patientId}');
//         return null;
//       }

//       // Combine the treatment and patient data into a single map
//       final Map<String, dynamic> combinedData = {
//         'treatmentData': treatmentSnapshot.data(),
//         'patientData': patientSnapshot.data(),
//       };
//       devtools.log('@@@@@@@@@@@ combinedData is $combinedData');

//       return combinedData;
//     } catch (error) {
//       // Handle any errors that occur during the fetch
//       devtools.log('Error fetching treatment or patient data: $error');
//       return null;
//     }
//   }

//   Future<void> _generateAndShareTreatmentSummaryPDF(
//       Map<String, dynamic> combinedData,
//       PrescriptionData prescriptionData) async {
//     final ByteData letterheadData =
//         await rootBundle.load('assets/images/letterhead.png');
//     final Uint8List letterheadBytes = letterheadData.buffer.asUint8List();

//     final pdf = pw.Document();
//     const int maxRowsPerPage = 36; // Limit rows per page

//     // (1) Prepare list of individual rows from combinedData
//     final List<pw.Widget> allRows = [];

//     // Add static rows first
//     allRows.add(_buildTreatmentSummaryRow());

//     allRows.add(_buildRow('UHID: ${combinedData['patientData']['uhid']}',
//         'Date: ${DateFormat('MMM dd, yyyy').format(combinedData['treatmentData']['treatmentDate'].toDate())}'));
//     allRows.add(_buildTextRow(
//         'Patient: ${combinedData['patientData']['patientName']}'));
//     allRows.add(_buildTextRow(
//         'Age/Gender: ${combinedData['patientData']['age']}/ ${combinedData['patientData']['gender']}'));

//     // Add Chief Complaint section (mandatory)
//     final chiefComplaintRows = _buildSectionRows(
//         'Chief Complaint', combinedData['treatmentData']['chiefComplaint']);
//     allRows.addAll(chiefComplaintRows);

//     // Conditionally add Medical History section if it exists
//     if (combinedData['treatmentData']['medicalHistory']?.isNotEmpty == true) {
//       final medicalHistoryRows = _buildSectionRows(
//           'Medical History', combinedData['treatmentData']['medicalHistory']);
//       allRows.addAll(medicalHistoryRows);
//     }

//     // Conditionally add Oral Examination section if it exists
//     if (combinedData['treatmentData']['oralExamination']?.isNotEmpty == true) {
//       final oralExaminationRows = _buildOralExaminationRows(
//           combinedData['treatmentData']['oralExamination']);
//       allRows.addAll(oralExaminationRows);
//     }

//     // Conditionally add Procedures section if it exists
//     if (combinedData['treatmentData']['procedures']?.isNotEmpty == true) {
//       final proceduresRows =
//           _buildProceduresRows(combinedData['treatmentData']['procedures']);
//       allRows.addAll(proceduresRows);
//     }

//     // (2) Split rows into pages for the PDF
//     List<pw.Widget> page1Rows = [];
//     List<pw.Widget> page2Rows = [];

//     if (allRows.length > maxRowsPerPage) {
//       page1Rows = allRows.sublist(0, maxRowsPerPage);
//       page2Rows = allRows.sublist(maxRowsPerPage);
//     } else {
//       page1Rows = allRows;
//     }

//     // (3) Prepare Page 1
//     final List<pw.Widget> processedPage1Rows = _wrapWithBorders(page1Rows);

//     pdf.addPage(
//       pw.Page(
//         margin: pw.EdgeInsets.zero,
//         build: (pw.Context context) {
//           return pw.Stack(
//             children: [
//               pw.Positioned.fill(
//                 child: pw.Image(
//                   pw.MemoryImage(letterheadBytes),
//                   fit: pw.BoxFit.fill,
//                 ),
//               ),
//               pw.Padding(
//                 padding: const pw.EdgeInsets.fromLTRB(60, 240, 40, 20),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: processedPage1Rows,
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     // (4) Prepare Page 2 (if needed)
//     if (page2Rows.isNotEmpty) {
//       final List<pw.Widget> processedPage2Rows =
//           _wrapPage2WithBorders(page2Rows);

//       pdf.addPage(
//         pw.Page(
//           margin: pw.EdgeInsets.zero,
//           build: (pw.Context context) {
//             return pw.Stack(
//               children: [
//                 pw.Positioned.fill(
//                   child: pw.Image(
//                     pw.MemoryImage(letterheadBytes),
//                     fit: pw.BoxFit.fill,
//                   ),
//                 ),
//                 pw.Padding(
//                   padding: const pw.EdgeInsets.fromLTRB(60, 240, 40, 20),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: processedPage2Rows,
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       );
//     }

//     // Add the prescription to the PDF after the summary
//     await _addPrescriptionToPdf(pdf, prescriptionData, letterheadBytes);

//     final tempDir = await getTemporaryDirectory();
//     final tempPath = tempDir.path;
//     final pdfFile = File('$tempPath/treatment_summary_with_prescription.pdf');
//     await pdfFile.writeAsBytes(await pdf.save());

//     await Share.shareFiles([pdfFile.path],
//         text: 'Treatment Summary and Prescription PDF');
//     await pdfFile.delete();
//   }

//   List<pw.Widget> _buildOralExaminationRows(List<dynamic> oralExaminations) {
//     List<pw.Widget> rows = [];

//     // Add the title 'Oral Examination' once before the loop
//     if (oralExaminations.isNotEmpty) {
//       rows.add(_buildTextRow('Oral Examination')); // Font size 10 for title
//     }

//     for (var exam in oralExaminations) {
//       rows.add(_buildTextRow(
//           '${exam['conditionName']}')); // Font size 10 for condition name
//       rows.addAll(_splitContentIntoRows(
//           'Affected Teeth: ${exam['affectedTeeth'].join(', ')}',
//           fontSize: 8)); // Font size 8 for affected teeth

//       if (exam['doctorNote'] != null) {
//         rows.addAll(_splitNoteIntoRows('${exam['doctorNote']}',
//             fontSize: 8)); // Font size 8 for doctor note
//       }
//     }

//     return rows;
//   }

//   // Helper method to create a text row with customizable font size
//   pw.Widget _buildTextRow(String text, {double fontSize = 10}) {
//     return pw.Text(text, style: pw.TextStyle(fontSize: fontSize));
//   }

// // Helper method to create a center-aligned 'Treatment Summary' row with font size 12
//   pw.Widget _buildTreatmentSummaryRow() {
//     return pw.Align(
//       alignment: pw.Alignment.center, // Center-align the text
//       child: pw.Text(
//         'Treatment Summary',
//         style: const pw.TextStyle(fontSize: 12), // Set the font size to 12
//       ),
//     );
//   }

// // Helper method to create a two-column row
//   pw.Widget _buildRow(String leftText, String rightText) {
//     return pw.Row(
//       children: [
//         pw.Expanded(
//           child: pw.Text(leftText, style: const pw.TextStyle(fontSize: 10)),
//         ),
//         pw.Expanded(
//           child: pw.Align(
//             alignment: pw.Alignment.centerRight,
//             child: pw.Text(rightText, style: const pw.TextStyle(fontSize: 10)),
//           ),
//         ),
//       ],
//     );
//   }

// // Helper method to split content into rows

//   List<pw.Widget> _buildSectionRows(String title, String content) {
//     List<pw.Widget> rows = [];

//     // Add the title (Chief Complaint or Medical History) with default font size
//     rows.add(_buildTextRow(title));

//     // Add the doctor note with font size 8
//     rows.addAll(_splitContentIntoRows(content, fontSize: 8));

//     return rows;
//   }

// // Helper method to split content into rows (e.g., for long text)

//   List<pw.Widget> _splitContentIntoRows(String content,
//       {double fontSize = 10}) {
//     devtools.log(
//         'Welcome to _splitContentIntoRows.  length of  content is ${content.length}');
//     const int maxLength = 150; // Example max length per row
//     List<pw.Widget> rows = [];

//     // Add 50 spaces to the content
//     //content = content + ' ' * 50;
//     devtools
//         .log('length of content after adding 50 spaces is ${content.length}');

//     for (int i = 0; i < content.length; i += maxLength) {
//       rows.add(pw.Text(
//           content.substring(i,
//               i + maxLength > content.length ? content.length : i + maxLength),
//           style: pw.TextStyle(
//               fontSize:
//                   fontSize))); // Use the font size passed in the parameter
//     }

//     return rows;
//   }

//   List<pw.Widget> _splitNoteIntoRows(String content, {double fontSize = 10}) {
//     devtools.log(
//         'Welcome to _splitContentIntoRows.  length of  content is ${content.length}');
//     const int maxLength = 150; // Example max length per row
//     List<pw.Widget> rows = [];

//     // Add 50 spaces to the content
//     //content = content + '-' * 150;

//     content =
//         "$content.                                                                                                                                                 ."; // Using string interpolation

//     devtools
//         .log('length of content after adding 150 spaces is ${content.length}');

//     for (int i = 0; i < content.length; i += maxLength) {
//       rows.add(pw.Text(
//           content.substring(i,
//               i + maxLength > content.length ? content.length : i + maxLength),
//           style: pw.TextStyle(
//               fontSize:
//                   fontSize))); // Use the font size passed in the parameter
//     }

//     return rows;
//   }

//   List<pw.Widget> _buildProceduresRows(List<dynamic> procedures) {
//     List<pw.Widget> rows = [];

//     // Add the title 'Procedures' once before the loop
//     if (procedures.isNotEmpty) {
//       rows.add(_buildTextRow('Procedures')); // Font size 10 for title
//     }

//     for (var procedure in procedures) {
//       rows.add(_buildTextRow(
//           '${procedure['procName']}')); // Font size 10 for procedure name
//       rows.addAll(_splitContentIntoRows(
//           'Affected Teeth: ${procedure['affectedTeeth'].join(', ')}',
//           fontSize: 8)); // Font size 8 for affected teeth

//       if (procedure['doctorNote'] != null) {
//         rows.addAll(_splitNoteIntoRows('${procedure['doctorNote']}',
//             fontSize: 8)); // Font size 8 for doctor note
//         rows.add(pw.Padding(padding: const pw.EdgeInsets.only(bottom: 4)));
//       }
//     }

//     return rows;
//   }

//   List<pw.Widget> _wrapWithBorders(List<pw.Widget> pageRows) {
//     devtools.log('Welcome to _wrapWithBorders !');
//     const int staticRowsCount = 4;
//     List<pw.Widget> wrappedRows = [];

//     // First, add the first 4 static rows without any wrapping
//     wrappedRows.addAll(pageRows.sublist(0, staticRowsCount));
//     devtools.log('Added first 4 static rows to wrappedRows');

//     List<pw.Widget> currentSectionRows = [];
//     String currentSection = "";

//     for (int i = staticRowsCount; i < pageRows.length; i++) {
//       final row = pageRows[i];
//       if (row is pw.Text) {
//         String textContent = _extractTextFromInlineSpan(row.text);

//         // Check for section boundaries
//         if (textContent == 'Chief Complaint') {
//           // Handle Chief Complaint
//           if (currentSectionRows.isNotEmpty) {
//             wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
//             currentSectionRows = [];
//           }
//           currentSection = 'Chief Complaint';
//           currentSectionRows.add(row);
//         } else if (textContent == 'Medical History') {
//           // Handle Medical History
//           if (currentSectionRows.isNotEmpty) {
//             wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
//             currentSectionRows = [];
//           }
//           currentSection = 'Medical History';
//           currentSectionRows.add(row);
//         } else if (textContent.contains('Oral Examination')) {
//           // Handle Oral Examination
//           if (currentSection == 'Oral Examination') {
//             // We are still in the Oral Examination section, so add to the same container
//             currentSectionRows.add(row);
//           } else {
//             // If we were in a different section, wrap the previous section
//             if (currentSectionRows.isNotEmpty) {
//               wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
//               currentSectionRows = [];
//             }
//             currentSection =
//                 'Oral Examination'; // Now we're in the Oral Examination section
//             currentSectionRows
//                 .add(row); // Add the first row of Oral Examination
//           }
//         } else if (textContent.contains('Procedure')) {
//           // Handle Procedures
//           if (currentSection == 'Procedure') {
//             // We are still in the Procedures section, so add to the same container
//             currentSectionRows.add(row);
//           } else {
//             // If we were in a different section, wrap the previous section
//             if (currentSectionRows.isNotEmpty) {
//               wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
//               currentSectionRows = [];
//             }
//             currentSection = 'Procedure'; // Now we're in the Procedures section
//             currentSectionRows.add(row); // Add the first row of Procedures
//           }
//         } else {
//           // Add rows to the current section
//           currentSectionRows.add(row);
//         }
//       }
//     }

//     // Wrap any remaining section at the end
//     if (currentSectionRows.isNotEmpty) {
//       wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
//     }

//     devtools.log('Final wrappedRows length: ${wrappedRows.length}');
//     return wrappedRows;
//   }

// // Helper function to extract text from InlineSpan or TextSpan
//   String _extractTextFromInlineSpan(pw.InlineSpan span) {
//     if (span is pw.TextSpan) {
//       if (span.text != null) {
//         return span.text!;
//       } else if (span.children != null) {
//         // Concatenate the text from all children
//         return span.children!.map((child) {
//           if (child is pw.InlineSpan) {
//             return _extractTextFromInlineSpan(
//                 child); // Recursively extract text from children
//           }
//           return '';
//         }).join('');
//       }
//     }
//     return '';
//   }

// // Helper function to wrap a section with border
//   pw.Widget _wrapSectionWithBorder(List<pw.Widget> sectionRows) {
//     devtools.log('Wrapping section with border for ${sectionRows.length} rows');
//     return pw.Container(
//       width: double.infinity,
//       decoration:
//           pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
//       padding: const pw.EdgeInsets.all(4),
//       margin: const pw.EdgeInsets.only(bottom: 4, top: 4),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: sectionRows,
//       ),
//     );
//   }

//   //-------------------------------------------------------------------------//

//   List<pw.Widget> _wrapPage2WithBorders(List<pw.Widget> pageRows) {
//     devtools.log('Processing Page 2 content');
//     List<pw.Widget> wrappedRows = [];

//     List<pw.Widget> currentSectionRows = [];
//     String currentSection = "";

//     for (final row in pageRows) {
//       if (row is pw.Text) {
//         String textContent = _extractTextFromInlineSpan(row.text);

//         // Handle Oral Examination section on Page 2
//         if (textContent.contains('Oral Examination')) {
//           if (currentSection == 'Oral Examination') {
//             currentSectionRows.add(row);
//           } else {
//             // Wrap the previous section (if any)
//             if (currentSectionRows.isNotEmpty) {
//               wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
//               currentSectionRows = [];
//             }
//             currentSection = 'Oral Examination';
//             currentSectionRows
//                 .add(_buildTextRow('Oral Examination')); // Add title
//             currentSectionRows.add(row);
//           }
//         }
//         // Handle Procedures section on Page 2
//         else if (textContent.contains('Procedure')) {
//           if (currentSection == 'Procedure') {
//             currentSectionRows.add(row);
//           } else {
//             // Wrap the previous section (if any)
//             if (currentSectionRows.isNotEmpty) {
//               wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
//               currentSectionRows = [];
//             }
//             currentSection = 'Procedure';
//             currentSectionRows.add(_buildTextRow('Procedures')); // Add title
//             currentSectionRows.add(row);
//           }
//         } else {
//           // Add rows to the current section
//           currentSectionRows.add(row);
//         }
//       }
//     }

//     // Wrap any remaining rows for the last section
//     if (currentSectionRows.isNotEmpty) {
//       wrappedRows.add(_wrapSectionWithBorder(currentSectionRows));
//     }

//     devtools.log('Page 2 processedRows length: ${wrappedRows.length}');
//     return wrappedRows;
//   }

// // -------------------------------------------------------------------------//

// // ---------------------------------------------------------------------------//

//   // ---------------------------------------------------------------------- //
//   Future<void> _addPrescriptionToPdf(pw.Document pdf,
//       PrescriptionData prescriptionData, Uint8List letterheadBytes) async {
//     final ByteData rxSymbolData =
//         await rootBundle.load('assets/images/rx_image.png');
//     final Uint8List rxSymbolBytes = rxSymbolData.buffer.asUint8List();

//     const int maxRowsPerPage = 10;
//     final int totalRows = prescriptionData.medicines.length;
//     final int totalPages = (totalRows / maxRowsPerPage).ceil();

//     for (int page = 0; page < totalPages; page++) {
//       final startRow = page * maxRowsPerPage;
//       final endRow = (startRow + maxRowsPerPage).clamp(0, totalRows);

//       pdf.addPage(
//         pw.Page(
//           margin: pw.EdgeInsets.zero,
//           build: (pw.Context context) {
//             return pw.Stack(
//               children: [
//                 pw.Positioned.fill(
//                   child: pw.Image(pw.MemoryImage(letterheadBytes),
//                       fit: pw.BoxFit.fill),
//                 ),
//                 pw.Padding(
//                   padding: const pw.EdgeInsets.fromLTRB(40, 240, 20, 20),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       if (page == 0) ...[
//                         pw.Row(children: [
//                           pw.Text(
//                             'UHID :',
//                             style: pw.TextStyle(
//                               fontSize: 10.0,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                           pw.SizedBox(width: 8.0),
//                           pw.Text(
//                             '${widget.uhid}',
//                             style: pw.TextStyle(
//                               fontSize: 10.0,
//                               fontWeight: pw.FontWeight.normal,
//                             ),
//                           ),
//                         ]),
//                         pw.SizedBox(height: 8.0),
//                         pw.Row(children: [
//                           pw.Text(
//                             'Patient :',
//                             style: pw.TextStyle(
//                               fontSize: 10.0,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                           pw.SizedBox(width: 8.0),
//                           pw.Text(
//                             widget.patientName,
//                             style: pw.TextStyle(
//                               fontSize: 10.0,
//                               fontWeight: pw.FontWeight.normal,
//                             ),
//                           ),
//                         ]),
//                         pw.SizedBox(height: 10),
//                         pw.Row(
//                           children: [
//                             pw.Expanded(
//                               child: pw.Text(
//                                 DateFormat('MMM dd, yyyy')
//                                     .format(prescriptionData.prescriptionDate),
//                                 style: const pw.TextStyle(fontSize: 10),
//                               ),
//                             ),
//                             pw.Expanded(
//                               child: pw.Align(
//                                 alignment: pw.Alignment.centerRight,
//                                 child: pw.Row(
//                                   mainAxisSize: pw.MainAxisSize.min,
//                                   children: [
//                                     pw.Text(
//                                       'By',
//                                       style: pw.TextStyle(
//                                         fontSize: 10.0,
//                                         fontWeight: pw.FontWeight.bold,
//                                       ),
//                                     ),
//                                     pw.SizedBox(width: 8.0),
//                                     pw.Text(
//                                       'Dr. ${widget.doctorName}',
//                                       style: pw.TextStyle(
//                                         fontSize: 10.0,
//                                         fontWeight: pw.FontWeight.normal,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 16.0),
//                         pw.Image(pw.MemoryImage(rxSymbolBytes),
//                             width: 30, height: 30),
//                         pw.SizedBox(height: 16.0),
//                       ],
//                       pw.Table(
//                         border: pw.TableBorder.all(color: PdfColors.grey),
//                         columnWidths: const {
//                           0: pw.FlexColumnWidth(3),
//                           1: pw.FlexColumnWidth(5),
//                           2: pw.FlexColumnWidth(2),
//                         },
//                         children: [
//                           pw.TableRow(
//                             children: [
//                               pw.Container(
//                                 padding: const pw.EdgeInsets.all(4),
//                                 alignment: pw.Alignment.centerLeft,
//                                 child: _buildPdfTableCellWithoutBorder(
//                                   'Medicine',
//                                   3,
//                                   bold: true,
//                                   align: pw.TextAlign.left,
//                                 ),
//                               ),
//                               pw.Container(
//                                 padding: const pw.EdgeInsets.all(4),
//                                 alignment: pw.Alignment.center,
//                                 child: pw.Row(
//                                   mainAxisAlignment:
//                                       pw.MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     _buildPdfTableCellWithoutBorder(
//                                       'Morning',
//                                       1,
//                                       bold: true,
//                                     ),
//                                     _buildPdfTableCellWithoutBorder(
//                                       'Afternoon',
//                                       1,
//                                       bold: true,
//                                     ),
//                                     _buildPdfTableCellWithoutBorder(
//                                       'Evening',
//                                       1,
//                                       bold: true,
//                                     ),
//                                     _buildPdfTableCellWithoutBorder(
//                                       ' ',
//                                       1,
//                                       bold: true,
//                                     ),
//                                     _buildPdfTableCellWithoutBorder(
//                                       'Days',
//                                       1,
//                                       bold: true,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               pw.Container(
//                                 padding: const pw.EdgeInsets.all(4),
//                                 alignment: pw.Alignment.centerLeft,
//                                 child: _buildPdfTableCellWithoutBorder(
//                                   'Instructions',
//                                   2,
//                                   bold: true,
//                                   align: pw.TextAlign.left,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           for (var medicine in prescriptionData.medicines
//                               .sublist(startRow, endRow))
//                             _buildPdfTableRow(medicine),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       );
//     }
//   }

//   // ------------------------------------------------------------------------ //

//   void _deletePrescription(PrescriptionData prescriptionData) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(widget.patientId)
//           .collection('treatments')
//           .doc(widget.treatmentId)
//           .collection('prescriptions')
//           .doc(prescriptionData.prescriptionId)
//           .delete();

//       setState(() {
//         _recentPrescriptionList.remove(prescriptionData);
//         if (_recentPrescriptionList.isEmpty) {
//           _showRecentPrescriptions = false;
//         }
//       });
//     } catch (error) {
//       devtools.log('Error deleting prescription: $error');
//     }
//   }

//   pw.Widget _buildPdfTableCellWithoutBorder(String content, int flex,
//       {pw.TextAlign align = pw.TextAlign.center, bool bold = false}) {
//     return pw.Expanded(
//       flex: flex,
//       child: pw.Container(
//         alignment: align == pw.TextAlign.left
//             ? pw.Alignment.centerLeft
//             : align == pw.TextAlign.right
//                 ? pw.Alignment.centerRight
//                 : pw.Alignment.center,
//         padding: const pw.EdgeInsets.all(4),
//         child: pw.Text(
//           content,
//           style: pw.TextStyle(
//               fontSize: 8,
//               fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
//           textAlign: align,
//         ),
//       ),
//     );
//   }

//   pw.Widget _buildPdfTableCell(String content, int flex,
//       {bool bold = false,
//       pw.TextAlign align = pw.TextAlign.center,
//       bool noBorder = false}) {
//     return pw.Expanded(
//       flex: flex,
//       child: pw.Container(
//         alignment: align == pw.TextAlign.left
//             ? pw.Alignment.centerLeft
//             : align == pw.TextAlign.right
//                 ? pw.Alignment.centerRight
//                 : pw.Alignment.center,
//         padding: const pw.EdgeInsets.all(4),
//         decoration: noBorder
//             ? null
//             : pw.BoxDecoration(
//                 border: pw.Border.all(color: PdfColors.grey),
//               ),
//         child: pw.Text(
//           content,
//           style: pw.TextStyle(
//               fontSize: 8,
//               fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
//           textAlign: align,
//         ),
//       ),
//     );
//   }

//   pw.TableRow _buildPdfTableRow(Map<String, dynamic> medicine) {
//     final xValue = medicine['dose']['x'] ?? 'x';
//     final isSOS = medicine['dose']['sos'] ?? false;

//     return pw.TableRow(
//       children: [
//         _buildPdfTableCell(medicine['medName'], 3,
//             align: pw.TextAlign.left, noBorder: true),
//         pw.Container(
//           padding: const pw.EdgeInsets.all(4),
//           child: pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildPdfTableCellWithoutBorder(
//                   isSOS ? '' : (medicine['dose']['morning'] ? '1' : '0'), 1),
//               _buildPdfTableCellWithoutBorder(
//                   isSOS ? '' : (medicine['dose']['afternoon'] ? '1' : '0'), 1),
//               _buildPdfTableCellWithoutBorder(
//                   isSOS ? '' : (medicine['dose']['evening'] ? '1' : '0'), 1),
//               _buildPdfTableCellWithoutBorder(isSOS ? '' : xValue, 1),
//               _buildPdfTableCellWithoutBorder(
//                   isSOS ? 'sos' : medicine['days'], 1),
//             ],
//           ),
//         ),
//         _buildPdfTableCell(medicine['instructions'], 2,
//             align: pw.TextAlign.left, noBorder: true),
//       ],
//     );
//   }

//   //void _sharePrescriptionTableViaWhatsApp(
//   //PrescriptionData prescriptionData) async {
//   Future<void> _sharePrescriptionTableViaWhatsApp(
//       PrescriptionData prescriptionData) async {
//     final ByteData letterheadData =
//         await rootBundle.load('assets/images/letterhead.png');
//     final Uint8List letterheadBytes = letterheadData.buffer.asUint8List();

//     final ByteData rxSymbolData =
//         await rootBundle.load('assets/images/rx_image.png');
//     final Uint8List rxSymbolBytes = rxSymbolData.buffer.asUint8List();

//     final pdf = pw.Document();

//     const int maxRowsPerPage =
//         10; // Set this based on the available space on your letterhead
//     final int totalRows = prescriptionData.medicines.length;
//     devtools.log(
//         'No of totalRows of selected medicines turns out to be $totalRows');
//     final int totalPages = (totalRows / maxRowsPerPage).ceil();
//     devtools.log(
//         'It is going to be printed on  $totalPages pages of the letterhead');

//     for (int page = 0; page < totalPages; page++) {
//       final startRow = page * maxRowsPerPage;
//       final endRow = (startRow + maxRowsPerPage).clamp(0, totalRows);

//       pdf.addPage(
//         pw.Page(
//           margin: pw.EdgeInsets.zero,
//           build: (pw.Context context) {
//             return pw.Stack(
//               children: [
//                 pw.Positioned.fill(
//                   child: pw.Image(pw.MemoryImage(letterheadBytes),
//                       fit: pw.BoxFit.cover),
//                 ),
//                 pw.Padding(
//                   padding: const pw.EdgeInsets.fromLTRB(40, 240, 20, 20),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Row(children: [
//                         pw.Text(
//                           'UHID :',
//                           style: pw.TextStyle(
//                             fontSize: 10.0,
//                             fontWeight: pw.FontWeight.bold,
//                           ),
//                         ),
//                         pw.SizedBox(width: 8.0),
//                         pw.Text(
//                           '${widget.uhid}',
//                           style: pw.TextStyle(
//                             fontSize: 10.0,
//                             fontWeight: pw.FontWeight.normal,
//                           ),
//                         ),
//                       ]),
//                       pw.SizedBox(height: 8.0),
//                       pw.Row(children: [
//                         pw.Text(
//                           'Patient :',
//                           style: pw.TextStyle(
//                             fontSize: 10.0,
//                             fontWeight: pw.FontWeight.bold,
//                           ),
//                         ),
//                         pw.SizedBox(width: 8.0),
//                         pw.Text(
//                           widget.patientName,
//                           style: pw.TextStyle(
//                             fontSize: 10.0,
//                             fontWeight: pw.FontWeight.normal,
//                           ),
//                         ),
//                       ]),
//                       pw.SizedBox(height: 10),
//                       pw.Row(
//                         children: [
//                           pw.Expanded(
//                             child: pw.Text(
//                               DateFormat('MMM dd, yyyy')
//                                   .format(prescriptionData.prescriptionDate),
//                               style: const pw.TextStyle(fontSize: 10),
//                             ),
//                           ),
//                           pw.Expanded(
//                             child: pw.Align(
//                               alignment: pw.Alignment.centerRight,
//                               child: pw.Row(
//                                 mainAxisSize: pw.MainAxisSize.min,
//                                 children: [
//                                   pw.Text(
//                                     'By',
//                                     style: pw.TextStyle(
//                                       fontSize: 10.0,
//                                       fontWeight: pw.FontWeight.bold,
//                                     ),
//                                   ),
//                                   pw.SizedBox(width: 8.0),
//                                   pw.Text(
//                                     'Dr. ${widget.doctorName}',
//                                     style: pw.TextStyle(
//                                       fontSize: 10.0,
//                                       fontWeight: pw.FontWeight.normal,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       pw.SizedBox(height: 16.0),
//                       pw.Image(pw.MemoryImage(rxSymbolBytes),
//                           width: 30, height: 30),
//                       pw.SizedBox(height: 16.0),
//                       pw.Table(
//                         border: pw.TableBorder.all(color: PdfColors.grey),
//                         columnWidths: const {
//                           0: pw.FlexColumnWidth(3),
//                           1: pw.FlexColumnWidth(5),
//                           2: pw.FlexColumnWidth(2),
//                         },
//                         children: [
//                           pw.TableRow(
//                             children: [
//                               pw.Container(
//                                 padding: const pw.EdgeInsets.all(4),
//                                 alignment: pw.Alignment.centerLeft,
//                                 child: _buildPdfTableCellWithoutBorder(
//                                   'Medicine',
//                                   3,
//                                   bold: true,
//                                   align: pw.TextAlign.left,
//                                 ),
//                               ),
//                               pw.Container(
//                                 padding: const pw.EdgeInsets.all(4),
//                                 alignment: pw.Alignment.center,
//                                 child: pw.Row(
//                                   mainAxisAlignment:
//                                       pw.MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     _buildPdfTableCellWithoutBorder(
//                                       'Morning',
//                                       1,
//                                       bold: true,
//                                     ),
//                                     _buildPdfTableCellWithoutBorder(
//                                       'Afternoon',
//                                       1,
//                                       bold: true,
//                                     ),
//                                     _buildPdfTableCellWithoutBorder(
//                                       'Evening',
//                                       1,
//                                       bold: true,
//                                     ),
//                                     _buildPdfTableCellWithoutBorder(
//                                       ' ',
//                                       1,
//                                       bold: true,
//                                     ),
//                                     _buildPdfTableCellWithoutBorder(
//                                       'Days',
//                                       1,
//                                       bold: true,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               pw.Container(
//                                 padding: const pw.EdgeInsets.all(4),
//                                 alignment: pw.Alignment.centerLeft,
//                                 child: _buildPdfTableCellWithoutBorder(
//                                   'Instructions',
//                                   2,
//                                   bold: true,
//                                   align: pw.TextAlign.left,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           for (var medicine in prescriptionData.medicines
//                               .sublist(startRow, endRow))
//                             _buildPdfTableRow(medicine),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       );
//     }

//     final tempDir = await getTemporaryDirectory();
//     final tempPath = tempDir.path;
//     final pdfFile = File('$tempPath/prescription_table.pdf');
//     await pdfFile.writeAsBytes(await pdf.save());

//     await Share.shareFiles([pdfFile.path], text: 'Prescription Table PDF');
//     await pdfFile.delete();
//   }

//   // ------------------------------------------------------------------------ //

//   // ------------------------------------------------------------------------ //

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         if (!_showRecentPrescriptions)
//           Padding(
//             padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Text(
//                 'New Prescriptions',
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//             ),
//           ),
//         if (_showMedicineInput)
//           Container(
//             //decoration: BoxDecoration(border: Border.all(width: 1.0)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           DateFormat('MMMM dd, EEEE').format(DateTime.now()),
//                           style: MyTextStyle.textStyleMap['title-medium']
//                               ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on-surface-variant']),
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _showMedicineInput = false;
//                           if (_recentPrescriptionList.isNotEmpty) {
//                             _showRecentPrescriptions = true;
//                             widget.navigateToPrescriptionTab();
//                           }
//                           // _showRecentPrescriptions = true;
//                           // widget.navigateToPrescriptionTab();
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
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       child: TextField(
//                         controller: _medicineNameController,
//                         onChanged: (value) {
//                           updateMatchingMedicines(value);
//                         },
//                         decoration: InputDecoration(
//                           labelText: 'Medicine Name',
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
//                                 color: MyColors
//                                         .colorPalette['on-surface-variant'] ??
//                                     Colors.black),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 8.0, horizontal: 8.0),
//                         ),
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {
//                           _showCourseSelectionOverlay(context);
//                         },
//                         child: Text(
//                           'Select Course',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['primary']),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 8.0,
//                 )
//               ],
//             ),
//           ),
//         if (_showRecentPrescriptions) _buildRecentPrescriptionsContainer(),
//         if (!_showMedicineInput)
//           Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(
//                   top: 16.0,
//                   bottom: 8.0,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: SizedBox(
//                     width: 144,
//                     height: 48,
//                     child: ElevatedButton(
//                       style: ButtonStyle(
//                         backgroundColor: MaterialStateProperty.all(
//                             MyColors.colorPalette['on-primary']!),
//                         shape: MaterialStateProperty.all(
//                           RoundedRectangleBorder(
//                             side: BorderSide(
//                                 color: MyColors.colorPalette['primary']!,
//                                 width: 1.0),
//                             borderRadius: BorderRadius.circular(24.0),
//                           ),
//                         ),
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _showMedicineInput = true;
//                           _showRecentPrescriptions = false;
//                           widget.navigateToPrescriptionTab();
//                         });
//                       },
//                       child: Wrap(
//                         children: [
//                           Icon(
//                             Icons.add,
//                             color: MyColors.colorPalette['primary'],
//                           ),
//                           Text(
//                             'Add New',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['primary']),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ListView.builder(
//           shrinkWrap: true,
//           itemCount: matchingMedicines.length,
//           itemBuilder: (context, index) {
//             return Container(
//               margin: const EdgeInsets.symmetric(vertical: 4.0),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey, width: 1.0),
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//               child: ListTile(
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(matchingMedicines[index].medName,
//                         textAlign: TextAlign.left),
//                     const Icon(Icons.add, color: Colors.blue),
//                   ],
//                 ),
//                 onTap: () {
//                   selectMedicine(matchingMedicines[index]);
//                 },
//               ),
//             );
//           },
//         ),
//         if (_showCheckboxContainer)
//           _buildCheckboxContainer({
//             'dose': {
//               'morning': false,
//               'afternoon': false,
//               'evening': false,
//               'sos': false,
//             }
//           }),
//         if (prescriptions.isNotEmpty)
//           Column(
//             children: [
//               for (int index = 0; index < prescriptions.length; index++)
//                 _buildPrescribedMedicine(prescriptions[index], index),

//               // ----------------------------------------------------------- //
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       height: 48,
//                       width: 144,
//                       child: ElevatedButton(
//                         style: ButtonStyle(
//                           backgroundColor: MaterialStateProperty.all(
//                             MyColors.colorPalette['primary']!,
//                           ),
//                           shape: MaterialStateProperty.all(
//                             RoundedRectangleBorder(
//                               side: BorderSide(
//                                 color: MyColors.colorPalette['primary']!,
//                                 width: 1.0,
//                               ),
//                               borderRadius: BorderRadius.circular(24.0),
//                             ),
//                           ),
//                         ),
//                         onPressed: _isGenerating
//                             ? null
//                             : () async {
//                                 setState(() {
//                                   _isGenerating = true;
//                                 });

//                                 await generateAndSavePrescriptions();

//                                 setState(() {
//                                   _isGenerating = false;
//                                 });
//                               },
//                         child: _isGenerating
//                             ? CircularProgressIndicator(
//                                 color: MyColors.colorPalette['on-primary'],
//                               )
//                             : Text(
//                                 'Generate',
//                                 style: MyTextStyle.textStyleMap['label-large']
//                                     ?.copyWith(
//                                   color: MyColors.colorPalette['on-primary'],
//                                 ),
//                               ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: _isGenerating
//                           ? null
//                           : () {
//                               cancelPrescription();
//                             },
//                       child: Text(
//                         'Cancel',
//                         style: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['on-surface']),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // ----------------------------------------------------------- //
//             ],
//           ),
//         if (_selectedMedicine != null)
//           _buildCheckboxContainer({
//             'dose': {
//               'morning': false,
//               'afternoon': false,
//               'evening': false,
//               'sos': false,
//             }
//           }),
//       ],
//     );
//   }

//   void _showCourseSelectionOverlay(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible:
//           false, // Prevent dismissing by tapping outside the dialog
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor:
//               Colors.transparent, // Make the dialog background transparent
//           insetPadding: const EdgeInsets.all(0), // Remove default padding
//           child: Scaffold(
//             appBar: AppBar(
//               backgroundColor: Colors.white, // Set app bar color to white
//               leading: IconButton(
//                 icon: Icon(Icons.close,
//                     color: MyColors.colorPalette['on-surface']),
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Close the dialog
//                 },
//               ),
//               title: Text(
//                 'Select a Course',
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//             ),
//             body: Container(
//               color: Colors.white, // Set the overall background color to white
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(8.0),
//                 itemCount: preDefinedCourses.length,
//                 itemBuilder: (context, index) {
//                   PreDefinedCourse course = preDefinedCourses[index];
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: MyColors.colorPalette[
//                             'surface-container'], // Set individual template color
//                         border: Border.all(color: Colors.grey, width: 1.0),
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       child: ListTile(
//                         title: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Course ${index + 1}',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: MyColors.colorPalette['primary'],
//                               ),
//                             ),
//                             ...course.medicines.map((medicine) {
//                               return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     '${medicine['medName']} x ${medicine['days']} Days${medicine['dose']['sos'] ? ' x sos' : ''}',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-large']!
//                                         .copyWith(
//                                             color: MyColors
//                                                 .colorPalette['on-surface']),
//                                   ),
//                                   Text(
//                                     'Instructions: ${medicine['instructions']}',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-small']!
//                                         .copyWith(
//                                             color: MyColors
//                                                 .colorPalette['on-surface']),
//                                   ),
//                                 ],
//                               );
//                             }).toList(),
//                           ],
//                         ),
//                         onTap: () {
//                           setState(() {
//                             _showMedicineInput = true;
//                             _showRecentPrescriptions = false;
//                             for (var medicine in course.medicines) {
//                               final newPrescription = {
//                                 'medId': medicine['medId'],
//                                 'medName': medicine['medName'],
//                                 'dose': {
//                                   'morning': medicine['dose']['morning'],
//                                   'afternoon': medicine['dose']['afternoon'],
//                                   'evening': medicine['dose']['evening'],
//                                   'sos': medicine['dose']['sos'],
//                                 },
//                                 'days': medicine['days'],
//                                 'instructions': medicine['instructions'],
//                               };
//                               prescriptions.add(newPrescription);
//                               _daysControllers.add(TextEditingController(
//                                   text: medicine['days']));
//                               _instructionsControllers.add(
//                                   TextEditingController(
//                                       text: medicine['instructions']));
//                             }
//                           });
//                           Navigator.pop(context);
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         );
//       },
//     );
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
//     this.showLabel = true,
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
//     this.showLabel = true,
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
//                 : Icon(
//                     Icons.radio_button_unchecked,
//                     size: 16.0,
//                     color: MyColors.colorPalette['primary'],
//                   ),
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
