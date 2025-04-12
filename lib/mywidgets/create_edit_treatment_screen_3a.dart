//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/firestore/medicine_service.dart';
import 'package:neocaresmileapp/mywidgets/create_edit_treatment_screen_4.dart';
import 'package:neocaresmileapp/mywidgets/medicine.dart';
import 'package:neocaresmileapp/mywidgets/my_bottom_navigation_bar.dart';
import 'package:neocaresmileapp/mywidgets/pre_defined_courses.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/prescription_data.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as devtools show log;
import 'user_data_provider.dart';
import 'image_cache_provider.dart';

class CreateEditTreatmentScreen3A extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String patientId;
  final int age;
  final String gender;
  final String patientName;
  final String patientMobileNumber;
  final String? patientPicUrl;
  final PageController pageController;
  final UserDataProvider userData;
  final String doctorName;
  final String? uhid;
  final Map<String, dynamic>? treatmentData;
  final String? treatmentId;
  final bool isEditMode;
  final List<String>? originalProcedures;
  final List<Map<String, dynamic>> currentProcedures;
  final ImageCacheProvider imageCacheProvider;
  final List<Map<String, dynamic>> pictureData11;
  final String? chiefComplaint;

  const CreateEditTreatmentScreen3A({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.patientId,
    required this.age,
    required this.gender,
    required this.patientName,
    required this.patientMobileNumber,
    required this.patientPicUrl,
    required this.pageController,
    required this.userData,
    required this.doctorName,
    required this.uhid,
    required this.treatmentData,
    required this.treatmentId,
    required this.isEditMode,
    required this.originalProcedures,
    required this.currentProcedures,
    required this.imageCacheProvider,
    required this.pictureData11,
    required this.chiefComplaint,
  });

  @override
  State<CreateEditTreatmentScreen3A> createState() =>
      _CreateEditTreatmentScreen3AState();
}

class _CreateEditTreatmentScreen3AState
    extends State<CreateEditTreatmentScreen3A> {
  bool isEditMode = false;
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  late MedicineService _medicineService;

  List<Medicine> matchingMedicines = [];

  bool _showMedicineInput = false;
  bool _showAddNewButton = true;
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
  final List<PrescriptionData> _prescriptionDataList = [];

  // @override
  // void initState() {
  //   super.initState();
  //   _medicineService = MedicineService(widget.clinicId);
  //   _showMedicineInput = false;
  //   _selectedMedicine = null;
  //   _loadPreDefinedCourses();
  //   devtools.log(
  //       'This is coming from inside initState of CreateEditTreatmentScreen3A. userData is ${widget.userData}');
  // }

  @override
  void initState() {
    super.initState();
    _medicineService = MedicineService(widget.clinicId);
    _showMedicineInput = false;
    _selectedMedicine = null;
    _loadPreDefinedCourses();

    // Check if userData already holds prescriptions
    if (widget.userData.prescriptions.isNotEmpty) {
      devtools.log(
          'Found existing prescriptions in userData, regenerating prescription cards...');
      _populatePrescriptionsFromUserData();
    }

    devtools.log(
        'This is coming from inside initState of CreateEditTreatmentScreen3A. userData is ${widget.userData}');
  }

  void _populatePrescriptionsFromUserData() {
    // Create a single PrescriptionData object to accumulate medicines
    if (widget.userData.prescriptions.isNotEmpty) {
      final prescriptionData = PrescriptionData(
        prescriptionId: const Uuid().v4(),
        prescriptionDate: DateTime.now(), // Adjust the date if needed
        medicines: [],
      );

      for (var prescription in widget.userData.prescriptions) {
        devtools.log('Processing prescription: $prescription');

        // Add each prescription's medicine to the medicines list
        prescriptionData.medicines.add({
          'medId': prescription['medId'] ?? '',
          'medName': prescription['medName'] ?? 'Unknown Medicine',
          'dose': {
            'morning': prescription['dose']?['morning'] ?? false,
            'afternoon': prescription['dose']?['afternoon'] ?? false,
            'evening': prescription['dose']?['evening'] ?? false,
            'sos': prescription['dose']?['sos'] ?? false,
          },
          'days':
              prescription['days']?.toString() ?? '1', // Ensure it's a string
          'instructions':
              prescription['instructions'] ?? '', // Default empty if null
        });
      }

      // Now add this single PrescriptionData object containing all medicines
      _prescriptionDataList.add(prescriptionData);

      setState(() {
        _showMedicineInput = false;
        _showAddNewButton = false;
        _showRecentPrescriptions = true; // Show the recent prescription
      });
    } else {
      devtools.log("No prescriptions found in userData.");
    }
  }

  @override
  void dispose() {
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

  // void updateMatchingMedicines(String userInput) async {
  //   matchingMedicines.clear();

  //   if (userInput.isEmpty) {
  //     setState(() {});
  //     return;
  //   }

  //   final firstChar = userInput[0];
  //   final convertedInput = firstChar.toLowerCase() == firstChar
  //       ? firstChar.toUpperCase() + userInput.substring(1)
  //       : userInput;

  //   final medicinesCollection = FirebaseFirestore.instance
  //       .collection('clinics')
  //       .doc(widget.clinicId)
  //       .collection('medicines');

  //   final querySnapshot = await medicinesCollection
  //       .where('medName', isGreaterThanOrEqualTo: convertedInput)
  //       .where('medName', isLessThan: '${convertedInput}z')
  //       .get();

  //   for (var doc in querySnapshot.docs) {
  //     final data = doc.data();
  //     final medicine = Medicine(
  //       medId: doc.id,
  //       medName: data['medName'],
  //       composition: '',
  //     );
  //     matchingMedicines.add(medicine);
  //   }

  //   setState(() {});
  // }
  //--------------------------------------------------------------------------//
  void updateMatchingMedicines(String userInput) async {
    matchingMedicines.clear();

    if (userInput.isEmpty) {
      setState(() {});
      return;
    }

    try {
      final medicines =
          await _medicineService.fetchMatchingMedicines(userInput);

      setState(() {
        matchingMedicines = medicines;
      });
    } catch (error) {
      devtools.log('Error fetching matching medicines: $error');
    }
  }

  //--------------------------------------------------------------------------//

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

  //-----------------------------------------------------------------------//

  Future<void> updateUserData() async {
    try {
      devtools.log(
          '@@@@@@@@@@@@@@@@@   Welcome to updateUserData defined inside CreateEditTreatmentScreen3A !');

      // Create PrescriptionData object first
      final prescriptionData = PrescriptionData(
        prescriptionId: const Uuid().v4(),
        prescriptionDate: DateTime.now(),
        medicines: List<Map<String, dynamic>>.from(
            prescriptions), // Make sure you pass the prescriptions before clearing them
      );
      devtools.log('@@@@@@@ prescriptionData is $prescriptionData');

      // Add prescriptionData to the list
      setState(() {
        _prescriptionDataList.add(prescriptionData);
        devtools.log('_prescriptionDataList is $_prescriptionDataList');
        _showMedicineInput = false;
        _showAddNewButton = false;
      });

      // Update userData
      widget.userData.updatePrescriptions(prescriptions);
      devtools.log('userData is ${widget.userData}');

      // Reset state after updating the userData and PrescriptionData
      setState(() {
        prescriptions.clear();
        _daysControllers.clear();
        _instructionsControllers.clear();
        _selectedMedicine = null;
        _showRecentPrescriptions = true;
      });
    } catch (error) {
      devtools.log('Error updating prescription data: $error');
    }
  }

  //-----------------------------------------------------------------------//
  Widget _buildPrescriptionCard(PrescriptionData prescriptionData) {
    devtools.log(
        'This is coming from inside _buildPrescriptionCard. medicines in prescriptionData are ${prescriptionData.medicines}');
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
                    _showShareAlertDialog();
                  },
                  icon: Icon(
                    Icons.share,
                    size: 24,
                    color: MyColors.colorPalette['secondary'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------//
  // Method to delete a prescription and update UI
  void _deletePrescription(PrescriptionData prescriptionData) {
    devtools.log('Close icon inside prescription card pressed !');
    setState(() {
      // Remove the prescription from the list
      _prescriptionDataList.remove(prescriptionData);

      // Also, remove the prescription from userData
      widget.userData.clearPrescriptions();

      // Show the "Add New" button again after the prescription is removed
      _showAddNewButton = true;
    });

    devtools.log('Prescription deleted: ${prescriptionData.prescriptionId}');
  }

  // ----------------------------------------------------------------------//
  // Method to show an alert dialog when share icon is pressed
  void _showShareAlertDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.info_outline,
                    color: MyColors.colorPalette['primary']),
                title: Text(
                  'Prescription can be shared after treatment creation',
                  style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
                    color: MyColors.colorPalette['on-surface'],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text(
                    'OK',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  // ----------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    devtools.log(
        '@@@@@@@ This is coming from inside build widget of CreateEditTreatmentScreen3A. userData is ${widget.userData}');

    //---------------//
    // Check if there are existing prescriptions in userData and populate them into _prescriptionDataList
    if (_prescriptionDataList.isEmpty &&
        widget.userData.prescriptions.isNotEmpty) {
      devtools.log('Regenerating prescription cards from userData...');
      _populatePrescriptionsFromUserData();
    }
    //---------------//
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          widget.isEditMode ? 'Edit Treatment' : 'Create Treatment',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        iconTheme: IconThemeData(
          color: MyColors.colorPalette['on-surface'],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Patient info section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color:
                        MyColors.colorPalette['outline'] ?? Colors.blueAccent,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: MyColors.colorPalette['surface'],
                          backgroundImage: widget.patientPicUrl != null &&
                                  widget.patientPicUrl!.isNotEmpty
                              ? NetworkImage(widget.patientPicUrl!)
                              : Image.asset(
                                  'assets/images/default-image.png',
                                  color: MyColors.colorPalette['primary'],
                                  colorBlendMode: BlendMode.color,
                                ).image,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.patientName,
                                style: MyTextStyle.textStyleMap['label-medium']
                                    ?.copyWith(
                                        color: MyColors
                                            .colorPalette['on-surface']),
                              ),
                              Row(
                                children: [
                                  Text(
                                    widget.age.toString(),
                                    style: MyTextStyle
                                        .textStyleMap['label-small']
                                        ?.copyWith(
                                            color: MyColors.colorPalette[
                                                'on-surface-variant']),
                                  ),
                                  Text(
                                    '/',
                                    style: MyTextStyle
                                        .textStyleMap['label-small']
                                        ?.copyWith(
                                            color: MyColors.colorPalette[
                                                'on-surface-variant']),
                                  ),
                                  Text(
                                    widget.gender,
                                    style: MyTextStyle
                                        .textStyleMap['label-small']
                                        ?.copyWith(
                                            color: MyColors.colorPalette[
                                                'on-surface-variant']),
                                  ),
                                ],
                              ),
                              Text(
                                widget.patientMobileNumber,
                                style: MyTextStyle.textStyleMap['label-small']
                                    ?.copyWith(
                                        color: MyColors.colorPalette[
                                            'on-surface-variant']),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Prescription title
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Prescription ',
                  style: MyTextStyle.textStyleMap['title-large']
                      ?.copyWith(color: MyColors.colorPalette['on-surface']),
                ),
              ),
              const SizedBox(height: 16),
              // Medicine input section
              if (_showMedicineInput)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
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
                              color:
                                  MyColors.colorPalette['on-surface-variant'] ??
                                      Colors.black),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
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
              if (!_showMedicineInput && _showAddNewButton)
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
                                          color:
                                              MyColors.colorPalette['primary']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              // Medicine suggestions
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
              // Prescribed medicines with checkboxes
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

                                      await updateUserData();

                                      setState(() {
                                        _isGenerating = false;
                                      });
                                    },
                              child: _isGenerating
                                  ? CircularProgressIndicator(
                                      color:
                                          MyColors.colorPalette['on-primary'],
                                    )
                                  : Text(
                                      'Generate',
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
                            onPressed: _isGenerating
                                ? null
                                : () {
                                    cancelPrescription();
                                  },
                            child: Text(
                              'Cancel',
                              style: MyTextStyle.textStyleMap['label-large']
                                  ?.copyWith(
                                      color:
                                          MyColors.colorPalette['on-surface']),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              // Display generated prescription cards
              if (_prescriptionDataList.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _prescriptionDataList.length,
                  itemBuilder: (context, index) {
                    return _buildPrescriptionCard(_prescriptionDataList[index]);
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: '',
          ),
        ],
        currentIndex: 2,
        nextIconSelectable: true,
        onTap: (int navIndex) {
          if (navIndex == 0) {
            Navigator.of(context).pop();
          } else if (navIndex == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CreateEditTreatmentScreen4(
                  clinicId: widget.clinicId,
                  doctorId: widget.doctorId,
                  patientId: widget.patientId,
                  age: widget.age,
                  gender: widget.gender,
                  patientName: widget.patientName,
                  patientMobileNumber: widget.patientMobileNumber,
                  patientPicUrl: widget.patientPicUrl,
                  pageController: widget.pageController,
                  userData: widget.userData,
                  doctorName: widget.doctorName,
                  uhid: widget.uhid,
                  treatmentData: widget.treatmentData,
                  treatmentId: widget.treatmentId,
                  isEditMode: widget.isEditMode,
                  originalProcedures: widget.originalProcedures,
                  currentProcedures: widget.currentProcedures,
                  pictureData11: widget.imageCacheProvider.pictures,
                  imageCacheProvider: widget.imageCacheProvider,
                  chiefComplaint: widget.chiefComplaint,
                ),
                settings:
                    const RouteSettings(name: 'CreateEditTreatmentScreen4'),
              ),
            );
          }
        },
      ),
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
