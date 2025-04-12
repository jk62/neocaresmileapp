import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/examination_service.dart';
import 'package:neocaresmileapp/firestore/medical_history_service.dart';
import 'package:neocaresmileapp/mywidgets/add_condition_overlay.dart';
import 'package:neocaresmileapp/mywidgets/condition.dart';
import 'package:neocaresmileapp/mywidgets/create_edit_treatment_screen_2.dart';
import 'package:neocaresmileapp/mywidgets/image_cache_provider.dart';
import 'package:neocaresmileapp/mywidgets/medical_condition.dart';
import 'package:neocaresmileapp/mywidgets/my_bottom_navigation_bar.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/procedure_cache_provider.dart';
import 'package:neocaresmileapp/mywidgets/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

class CreateEditTreatmentScreen1 extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String patientId;
  final int age;
  final String gender;
  final String patientName;
  final String patientMobileNumber;
  final String? patientPicUrl;
  final PageController pageController;
  final String doctorName;
  final String? uhid;
  final UserDataProvider? userData;
  final Map<String, dynamic>? treatmentData;
  final String? treatmentId;
  final bool isEditMode;
  final List<String>? originalProcedures;
  final String? chiefComplaint;
  final ImageCacheProvider imageCacheProvider;

  const CreateEditTreatmentScreen1({
    super.key,
    required this.patientId,
    required this.age,
    required this.gender,
    required this.patientName,
    required this.patientMobileNumber,
    required this.patientPicUrl,
    required this.pageController,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
    required this.uhid,
    required this.userData,
    required this.treatmentData,
    required this.treatmentId,
    required this.isEditMode,
    required this.originalProcedures,
    this.chiefComplaint,
    required this.imageCacheProvider,
  });

  @override
  State<CreateEditTreatmentScreen1> createState() =>
      _CreateEditTreatmentScreen1State();
}

class _CreateEditTreatmentScreen1State
    extends State<CreateEditTreatmentScreen1> {
  final TextEditingController _chiefComplaintController =
      TextEditingController();
  final TextEditingController _medicalHistoryController =
      TextEditingController();
  final TextEditingController _doctorNoteController = TextEditingController();

  String chiefComplaint = '';
  String medicalHistory = '';

  String? selectedConditionId;
  String? selectedConditionName;
  List<int> affectedTeeth = [];
  UserDataProvider? _userData;
  bool nextIconSelectable = false;

  List<Condition> conditions = [];
  bool isLoading = true;
  bool isDropdownExpanded = false;
  bool showToothTable = false;
  List<Map<String, dynamic>> selectedConditions = [];
  List<MedicalCondition> medicalConditions =
      []; // List to store fetched medical conditions
  bool isLoadingMedicalConditions =
      true; // Show a loading indicator while fetching
  List<MedicalCondition> selectedMedicalConditions = [];

  //----------------------------------//
  final TextEditingController _otherConditionController =
      TextEditingController(); // Controller for custom input

  bool isOtherConditionSelected = false;

  @override
  void initState() {
    super.initState();
    devtools.log(
        'Welcome to initState of CreateEditTreatmentScreen1. editMode is ${widget.isEditMode}');
    _userData = widget.userData;
    _fetchConditions();
    _fetchMedicalConditions();

    if (widget.isEditMode && widget.treatmentData != null) {
      _chiefComplaintController.text = widget.chiefComplaint ?? '';
      chiefComplaint = widget.chiefComplaint ?? '';

      _medicalHistoryController.text =
          widget.treatmentData?['medicalHistory'] ?? '';
      medicalHistory = widget.treatmentData?['medicalHistory'] ?? '';

      //---------------------//
      // Parse medical history string and convert it to MedicalCondition list
      if (medicalHistory.isNotEmpty) {
        setState(() {
          selectedMedicalConditions =
              medicalHistory.split(', ').map((conditionName) {
            return MedicalCondition(
              medicalConditionId: '', // No ID for now, adjust if needed
              medicalConditionName: conditionName,
              doctorNote: '',
            );
          }).toList();
        });
      }
      //---------------------//

      // Populate selectedConditions with existing oralExamination data
      final oralExamination =
          widget.treatmentData!['oralExamination'] as List<dynamic>?;
      if (oralExamination != null && oralExamination.isNotEmpty) {
        setState(() {
          selectedConditions = oralExamination.map((condition) {
            return {
              'conditionId': condition['conditionId'],
              'conditionName': condition['conditionName'],
              'affectedTeeth': List<int>.from(condition['affectedTeeth']),
              'doctorNote': condition['doctorNote'] ?? '',
            };
          }).toList();
        });
      }

      // Update next icon state based on the loaded data
      _updateNextIconState();
    }
  }

  Future<void> _fetchConditions() async {
    try {
      ExaminationService examinationService =
          ExaminationService(widget.clinicId);
      List<Condition> fetchedConditions =
          await examinationService.getAllConditions();

      // Sort conditions alphabetically by conditionName
      fetchedConditions
          .sort((a, b) => a.conditionName.compareTo(b.conditionName));

      setState(() {
        conditions = fetchedConditions;
        isLoading = false;
      });
    } catch (error) {
      devtools.log('Error fetching conditions: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  //-------------------------------------------------------------------------//
  // Function to fetch medical conditions from the backend
  Future<void> _fetchMedicalConditions() async {
    try {
      MedicalHistoryService medicalHistoryService =
          MedicalHistoryService(widget.clinicId);
      List<MedicalCondition> fetchedConditions =
          await medicalHistoryService.getAllMedicalConditions();

      // Sort conditions alphabetically by medicalConditionName
      fetchedConditions.sort(
          (a, b) => a.medicalConditionName.compareTo(b.medicalConditionName));

      setState(() {
        medicalConditions = fetchedConditions; // Store fetched conditions
        isLoadingMedicalConditions = false; // Stop loading indicator
      });
    } catch (error) {
      devtools.log('Error fetching medical conditions: $error');
      setState(() {
        isLoadingMedicalConditions =
            false; // Stop loading indicator even on error
      });
    }
  }

  void updateUserData() {
    if (_userData != null) {
      // Update chief complaint
      _userData!.updateChiefComplaint(chiefComplaint);

      // Update medical history
      _userData!.updateMedicalHistory(medicalHistory);

      // Clear any existing oral examination data before updating
      _userData!.clearOralExamination();

      // Ensure no duplicates before updating oral examination data
      final Set<String> addedConditionIds = {};

      for (var condition in selectedConditions) {
        if (!addedConditionIds.contains(condition['conditionId'])) {
          _userData!.addOralExamination({
            'conditionId': condition['conditionId'],
            'conditionName': condition['conditionName'],
            'affectedTeeth': condition['affectedTeeth'],
            'doctorNote': condition['doctorNote'],
          });
          addedConditionIds.add(condition['conditionId']);
        }
      }
    }
  }

  // void _showAddConditionOverlay({Map<String, dynamic>? condition, int? index}) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AddConditionOverlay(
  //         conditions: conditions,
  //         initialCondition:
  //             condition, // Prepopulate with the selected condition
  //         onConditionAdded: (Map<String, dynamic> updatedCondition) {
  //           setState(() {
  //             if (index != null) {
  //               // Update the existing condition
  //               selectedConditions[index] = updatedCondition;
  //             } else {
  //               // Add a new condition
  //               selectedConditions.add(updatedCondition);
  //             }
  //             _updateNextIconState();
  //           });
  //         },
  //       );
  //     },
  //   );
  // }

  void _showAddConditionOverlay({Map<String, dynamic>? condition, int? index}) {
    // Create an instance of ExaminationService using the clinicId
    final examinationService = ExaminationService(widget.clinicId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddConditionOverlay(
          examinationService: examinationService, // Pass the required service
          initialCondition:
              condition, // Prepopulate with the selected condition
          onConditionAdded: (Map<String, dynamic> updatedCondition) {
            setState(() {
              if (index != null) {
                // Update the existing condition
                selectedConditions[index] = updatedCondition;
              } else {
                // Add a new condition
                selectedConditions.add(updatedCondition);
              }
              _updateNextIconState();
            });
          },
        );
      },
    );
  }

  void _updateNextIconState() {
    setState(() {
      nextIconSelectable = chiefComplaint.isNotEmpty;
      // Allow navigation based on chiefComplaint alone, even in edit mode
      devtools.log(
          '@@@ Welcome to _updateNextIconState nextIconSelectable is $nextIconSelectable');
    });
  }

  Widget _buildConditionCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedConditions.isNotEmpty)
          ...selectedConditions.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> condition = entry.value;

            // Check if there are affected teeth and if there's a doctor note
            bool hasAffectedTeeth = condition['affectedTeeth'] != null &&
                (condition['affectedTeeth'] as List<int>).isNotEmpty;
            bool hasDoctorNote = condition['doctorNote'] != null &&
                condition['doctorNote'].trim().isNotEmpty;

            return GestureDetector(
              onTap: () {
                _showAddConditionOverlay(
                  condition: condition, // Pass the selected condition
                  index: index, // Pass the index to update the condition later
                );
              },
              child: Container(
                width:
                    double.infinity, // Make sure the card covers the full width
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
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
                                  // The card is now editable on tap
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${index + 1}. ${condition['conditionName']}',
                                      style: MyTextStyle
                                          .textStyleMap['label-large']
                                          ?.copyWith(
                                              color: MyColors
                                                  .colorPalette['primary']),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: MyColors.colorPalette['primary'],
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedConditions.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (hasAffectedTeeth) ...[
                          const Text('Affected Teeth'),
                          Wrap(
                            spacing: 4.0,
                            runSpacing: 4.0,
                            children: (condition['affectedTeeth'] as List<int>)
                                .map((tooth) {
                              return Chip(
                                label: Text(
                                  '$tooth',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor:
                                    MyColors.colorPalette['primary'],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (hasDoctorNote) ...[
                          const Text('Doctor Note'),
                          Text(
                            condition['doctorNote'] ?? '',
                            style: MyTextStyle.textStyleMap['label-large']
                                ?.copyWith(
                                    color: MyColors.colorPalette['on-surface']),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _doctorNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userData = Provider.of<UserDataProvider>(context);
    devtools.log(
        'Welcome to build widget of CreateEditTreatmentScreen1. _userData is $_userData');
    devtools.log(
        'This is coming from inside build widget of CreateEditTreatmentScreen1. originalProcedures are ${widget.originalProcedures}');

    return PopScope(
      onPopInvoked: (willPop) {
        if (willPop) {
          widget.imageCacheProvider.clearPictures();
          widget.userData?.clearState();
          context.read<ProcedureCacheProvider>().clearProcedures();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.colorPalette['surface-container-lowest'],
          title: Text(
            widget.isEditMode ? 'Edit Treatment' : 'New Treatment',
            style: MyTextStyle.textStyleMap['title-large']
                ?.copyWith(color: MyColors.colorPalette['on-surface']),
          ),
          iconTheme: IconThemeData(
            color: MyColors.colorPalette['on-surface'],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildPatientInfo(),
              _buildChiefComplaintSection(),
              _buildMedicalHistorySection(),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Oral Examination',
                    style: MyTextStyle.textStyleMap['title-large']
                        ?.copyWith(color: MyColors.colorPalette['on-surface']),
                  ),
                ),
              ),

              // Render the condition cards and title
              _buildConditionCards(),
              _buildAddConditionButton(),
            ],
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
          currentIndex: 0, // Set to 0 for CreateEditTreatmentScreen1
          nextIconSelectable: nextIconSelectable,
          onTap: (int navIndex) {
            if (navIndex == 0) {
              Navigator.of(context).pop();
            } else if (navIndex == 3 && nextIconSelectable) {
              updateUserData();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreateEditTreatmentScreen2(
                    clinicId: widget.clinicId,
                    doctorId: widget.doctorId,
                    patientId: widget.patientId,
                    age: widget.age,
                    gender: widget.gender,
                    patientName: widget.patientName,
                    patientMobileNumber: widget.patientMobileNumber,
                    patientPicUrl: widget.patientPicUrl,
                    pageController: widget.pageController,
                    userData: _userData!,
                    doctorName: widget.doctorName,
                    uhid: widget.uhid,
                    treatmentData: widget.treatmentData,
                    treatmentId: widget.treatmentId,
                    originalProcedures: widget.originalProcedures,
                    chiefComplaint: chiefComplaint,
                    imageCacheProvider: widget.imageCacheProvider,
                    isEditMode: widget.isEditMode,
                  ),
                  settings:
                      const RouteSettings(name: 'CreateEditTreatmentScreen2'),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, top: 24, bottom: 24),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: MyColors.colorPalette['outline'] ?? Colors.blueAccent,
          ),
          borderRadius: BorderRadius.circular(5),
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
                                color: MyColors.colorPalette['on-surface']),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.age.toString(),
                            style: MyTextStyle.textStyleMap['label-small']
                                ?.copyWith(
                                    color: MyColors
                                        .colorPalette['on-surface-variant']),
                          ),
                          Text(
                            '/',
                            style: MyTextStyle.textStyleMap['label-small']
                                ?.copyWith(
                                    color: MyColors
                                        .colorPalette['on-surface-variant']),
                          ),
                          Text(
                            widget.gender,
                            style: MyTextStyle.textStyleMap['label-small']
                                ?.copyWith(
                                    color: MyColors
                                        .colorPalette['on-surface-variant']),
                          ),
                        ],
                      ),
                      Text(
                        widget.patientMobileNumber,
                        style: MyTextStyle.textStyleMap['label-small']
                            ?.copyWith(
                                color: MyColors
                                    .colorPalette['on-surface-variant']),
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

  Widget _buildChiefComplaintSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chief Complaint',
            style: MyTextStyle.textStyleMap['title-large']
                ?.copyWith(color: MyColors.colorPalette['on-surface']),
          ),
          const SizedBox(height: 8),
          Container(
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: MyColors.colorPalette['on-surface'] ??
                    const Color(0xFF011718),
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: SingleChildScrollView(
              child: TextFormField(
                controller: _chiefComplaintController,
                onChanged: (value) {
                  setState(() {
                    chiefComplaint = value;
                    nextIconSelectable = value.isNotEmpty;
                  });
                  devtools.log('chiefComplaint is $chiefComplaint');
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0),
                ),
                maxLines: null, // Allow multiple lines of text
                style: MyTextStyle.textStyleMap['label-large']
                    ?.copyWith(color: MyColors.colorPalette['secondary']),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMedicalConditionOverlay() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setStateOverlay) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Select Medical Conditions'),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: medicalConditions.length,
                        itemBuilder: (BuildContext context, int index) {
                          final condition = medicalConditions[index];
                          bool isOtherCondition =
                              condition.medicalConditionName ==
                                  "Other (Please Mention)";
                          bool isSelected = isOtherCondition
                              ? isOtherConditionSelected // Ensure 'Other' checkbox reflects its actual state
                              : selectedMedicalConditions.contains(condition);

                          return CheckboxListTile(
                            title: Text(condition.medicalConditionName),
                            value: isSelected,
                            activeColor: MyColors.colorPalette['primary'],
                            onChanged: (bool? value) async {
                              if (isOtherCondition && value == true) {
                                // Show input dialog for custom input
                                String? customInput = await showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Enter Custom Condition',
                                        style: MyTextStyle
                                            .textStyleMap['title-medium']
                                            ?.copyWith(
                                                color: MyColors.colorPalette[
                                                    'on-surface']),
                                      ),
                                      content: TextField(
                                        controller: _otherConditionController,
                                        decoration: const InputDecoration(
                                          hintText:
                                              'Enter custom medical condition',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, null);
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: MyTextStyle
                                                .textStyleMap['title-medium']
                                                ?.copyWith(
                                                    color:
                                                        MyColors.colorPalette[
                                                            'on-surface']),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context,
                                                _otherConditionController.text);
                                          },
                                          child: Text(
                                            'OK',
                                            style: MyTextStyle
                                                .textStyleMap['title-medium']
                                                ?.copyWith(
                                                    color:
                                                        MyColors.colorPalette[
                                                            'primary']),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                // If user provided input, replace or add "Other" custom input
                                if (customInput != null &&
                                    customInput.isNotEmpty) {
                                  setStateOverlay(() {
                                    // Remove previous custom input if it exists
                                    selectedMedicalConditions.removeWhere(
                                        (condition) =>
                                            condition.medicalConditionId ==
                                            'custom');

                                    // Add the new custom input
                                    selectedMedicalConditions.add(
                                      MedicalCondition(
                                        medicalConditionId: 'custom',
                                        medicalConditionName: customInput,
                                        doctorNote: '',
                                      ),
                                    );

                                    // Ensure the 'Other' condition remains selected
                                    isOtherConditionSelected = true;
                                    _otherConditionController.clear();
                                  });
                                }
                              } else {
                                setStateOverlay(() {
                                  if (value == true) {
                                    selectedMedicalConditions.add(condition);
                                  } else {
                                    selectedMedicalConditions.remove(condition);

                                    if (isOtherCondition) {
                                      // Unselect 'Other (Please Mention)' and remove the custom input from the list
                                      isOtherConditionSelected = false;
                                      selectedMedicalConditions.removeWhere(
                                          (condition) =>
                                              condition.medicalConditionId ==
                                              'custom');
                                    }
                                  }
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: ElevatedButton(

                    //     onPressed: () {
                    //       setState(() {
                    //         // Update the medical history controller with selected conditions
                    //         medicalHistory = selectedMedicalConditions
                    //             .map((condition) =>
                    //                 condition.medicalConditionName)
                    //             .join(', ');
                    //         _medicalHistoryController.text = medicalHistory;
                    //       });
                    //       Navigator.pop(context); // Close the overlay
                    //     },
                    //     child: Text(
                    //       'OK',
                    //       style: MyTextStyle.textStyleMap['title-medium']
                    //           ?.copyWith(
                    //               color: MyColors.colorPalette['primary']),
                    //     ),
                    //   ),
                    // ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.colorPalette['primary'],
                        ),
                        onPressed: () {
                          setState(() {
                            // Update the medical history controller with selected conditions
                            medicalHistory = selectedMedicalConditions
                                .map((condition) =>
                                    condition.medicalConditionName)
                                .join(', ');
                            _medicalHistoryController.text = medicalHistory;
                          });
                          Navigator.pop(context); // Close the overlay
                        },
                        child: Text(
                          'OK',
                          style: MyTextStyle.textStyleMap['title-medium']
                              ?.copyWith(
                            color: MyColors.colorPalette['on-primary'],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMedicalHistorySection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medical History',
            style: MyTextStyle.textStyleMap['title-large']
                ?.copyWith(color: MyColors.colorPalette['on-surface']),
          ),
          const SizedBox(height: 8),

          // "Select Medical History Condition" button with expand more/expand less
          GestureDetector(
            onTap: () {
              _showMedicalConditionOverlay(); // Show overlay on press
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: MyColors.colorPalette['outline-variant'] ??
                      const Color(0xFF011718),
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Medical History Condition',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['on-surface']),
                  ),
                  Icon(
                    Icons.expand_more,
                    color: MyColors.colorPalette['primary'],
                  ),
                ],
              ),
            ),
          ),

          // Display selected conditions in Medical History container after user hits OK
          if (selectedMedicalConditions.isNotEmpty)
            _buildSelectedMedicalHistoryContainer(),
        ],
      ),
    );
  }

  // Widget _buildSelectedMedicalHistoryContainer() {
  //   return Container(
  //     margin: const EdgeInsets.only(top: 8.0),
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       // border: Border.all(
  //       //   width: 1,
  //       //   color: MyColors.colorPalette['on-surface'] ?? const Color(0xFF011718),
  //       // ),
  //       //color: MyColors.colorPalette['outline-variant'] ?? Colors.grey,
  //       borderRadius: BorderRadius.circular(5.0),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Wrap(
  //         spacing: 8.0, // Horizontal space between chips
  //         runSpacing: 8.0, // Vertical space between chips
  //         children: selectedMedicalConditions.map((condition) {
  //           return Chip(
  //             label: Text(
  //               condition.medicalConditionName,
  //               style: MyTextStyle.textStyleMap['label-small']?.copyWith(
  //                 color: MyColors.colorPalette['on-primary'],
  //               ),
  //             ),
  //             backgroundColor: MyColors.colorPalette['primary'],
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(24.0),
  //             ),
  //             visualDensity:
  //                 const VisualDensity(horizontal: 0.0, vertical: -4.0),
  //             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //             padding: const EdgeInsets.only(
  //                 top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }
  // Widget _buildSelectedMedicalHistoryContainer() {
  //   return Card(
  //     color: Theme.of(context)
  //         .colorScheme
  //         .surface, // Matches theme's surface color
  //     elevation: 2.0, // Add slight elevation for better visibility
  //     shape: RoundedRectangleBorder(
  //       borderRadius:
  //           BorderRadius.circular(5.0), // Match the container's border radius
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Wrap(
  //         spacing: 8.0, // Horizontal space between chips
  //         runSpacing: 8.0, // Vertical space between chips
  //         children: selectedMedicalConditions.map((condition) {
  //           return Chip(
  //             label: Text(
  //               condition.medicalConditionName,
  //               style: MyTextStyle.textStyleMap['label-small']?.copyWith(
  //                 color: MyColors.colorPalette['on-primary'],
  //               ),
  //             ),
  //             backgroundColor: MyColors.colorPalette['primary'],
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(24.0),
  //             ),
  //             visualDensity:
  //                 const VisualDensity(horizontal: 0.0, vertical: -4.0),
  //             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //             padding: const EdgeInsets.only(
  //                 top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildSelectedMedicalHistoryContainer() {
    return Container(
      width: double.infinity, // Ensures the Card takes up the full width
      child: Card(
        color: Theme.of(context)
            .colorScheme
            .surface, // Matches theme's surface color
        elevation: 2.0, // Add slight elevation for better visibility
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // Matches rounded design
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8.0, // Horizontal space between chips
            runSpacing: 8.0, // Vertical space between chips
            children: selectedMedicalConditions.map((condition) {
              return Chip(
                label: Text(
                  condition.medicalConditionName,
                  style: MyTextStyle.textStyleMap['label-small']?.copyWith(
                    color: MyColors.colorPalette['on-primary'],
                  ),
                ),
                backgroundColor: MyColors.colorPalette['primary'],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                visualDensity:
                    const VisualDensity(horizontal: 0.0, vertical: -4.0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.only(
                    top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  //-----------------------------------------------//
  // Chip(
  //                               label: Text(
  //                                 label,
  //                                 style: MyTextStyle.textStyleMap['label-small']
  //                                     ?.copyWith(
  //                                         color: MyColors
  //                                             .colorPalette['on-primary']),
  //                               ),
  //                               backgroundColor:
  //                                   MyColors.colorPalette['primary'],
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(24.0),
  //                               ),
  //                               visualDensity: const VisualDensity(
  //                                   horizontal: 0.0, vertical: -4.0),
  //                               materialTapTargetSize:
  //                                   MaterialTapTargetSize.shrinkWrap,
  //                             ))
  //----------------------------------------------//

  Widget _buildAddConditionButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 48,
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
            onPressed: _showAddConditionOverlay,
            child: Row(
              mainAxisSize: MainAxisSize
                  .min, // Ensures the button size matches its content
              children: [
                Icon(
                  Icons.add,
                  color: MyColors.colorPalette['primary'],
                ),
                const SizedBox(
                    width: 4), // Optional: space between icon and text
                Text(
                  'Add',
                  style: MyTextStyle.textStyleMap['label-large']
                      ?.copyWith(color: MyColors.colorPalette['primary']),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
