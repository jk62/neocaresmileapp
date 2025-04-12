import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/clinic_service.dart';
import 'package:neocaresmileapp/firestore/consultation_service.dart';
import 'package:neocaresmileapp/firestore/doctor_service.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/consultation.dart';
import 'package:neocaresmileapp/mywidgets/edit_consultation_fee.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;

class AddConsultationFee extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String doctorName;

  const AddConsultationFee({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<AddConsultationFee> createState() => _AddConsultationFeeState();
}

class _AddConsultationFeeState extends State<AddConsultationFee> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();

  List<Consultation> matchingConsultations = [];
  bool addingNewConsultation = false;
  bool isAddingConsultation = false;
  bool hasUserInput = false;
  bool showNoMatchingConsultationMessage = false;
  String previousSearchInput = '';

  late ConsultationService consultationService;
  // ------------------------------------------------------------------------- //
  late DoctorService doctorService;
  List<Map<String, String>> doctorNamesAndIds = [];
  String? selectedDoctorName;
  String? selectedDoctorId;
  // ------------------------------------------------------------------------- //

  // @override
  // void initState() {
  //   super.initState();
  //   addingNewConsultation = false;
  //   consultationService = ConsultationService(widget.clinicId);
  //   doctorService = DoctorService();
  //   fetchDoctorNames();
  // }

  // ------------------------------------------------------------------------ //
  @override
  void initState() {
    super.initState();
    consultationService =
        ConsultationService(widget.clinicId); // Initialize with passed clinicId
    doctorService = DoctorService();

    fetchDoctorNames(); // Fetch initial doctor names
    fetchConsultationsForClinic(); // Fetch consultations for the initial clinic

    // Listen for clinic changes and update consultations when it changes
    ClinicSelection.instance.addListener(_onClinicChanged);
  }

  @override
  void dispose() {
    ClinicSelection.instance
        .removeListener(_onClinicChanged); // Prevent memory leaks
    super.dispose();
  }

// Fetch consultations for the selected clinic
  void fetchConsultationsForClinic() async {
    consultationService
        .updateClinicId(ClinicSelection.instance.selectedClinicId);
    final consultations = await consultationService.getAllConsultations();
    setState(() {
      matchingConsultations = consultations;
    });
  }

// Called when the clinic selection changes
  void _onClinicChanged() {
    setState(() {
      matchingConsultations.clear(); // Clear current consultations
    });
    fetchConsultationsForClinic(); // Fetch consultations for new clinic
  }

  //---------------------------------------------------------------------------//
  Future<void> fetchDoctorNames() async {
    doctorNamesAndIds = await doctorService.getDoctorNames();
    setState(() {});
  }

  void handleSearchInput(String userInput) async {
    setState(() {
      hasUserInput = userInput.isNotEmpty;
      previousSearchInput = userInput;
    });

    if (userInput.isEmpty) {
      setState(() {
        matchingConsultations.clear();
        return;
      });
    }

    setState(() {
      matchingConsultations.clear();
    });

    final consultations =
        await consultationService.searchConsultations(userInput);
    if (consultations.isNotEmpty) {
      setState(() {
        matchingConsultations.addAll(consultations);
      });
    } else {
      setState(() {
        // Optionally show a message that no consultations were found
      });
    }
  }

  void handleSelectedConsultation(Consultation consultation) {
    // Navigate to edit screen with selected consultation details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditConsultationFee(
          clinicId: widget.clinicId,
          consultation: consultation,
          consultationService: consultationService,
        ),
      ),
    ).then((updatedConsultation) {
      if (updatedConsultation != null) {
        setState(() {
          int index = matchingConsultations.indexWhere(
              (c) => c.consultationId == updatedConsultation.consultationId);
          if (index != -1) {
            matchingConsultations[index] = updatedConsultation;
          }
        });
      }
    });
  }

  void deleteConsultation(Consultation consultation) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Consultation'),
        content: Text(
            'Are you sure you want to delete the consultation for ${consultation.doctorName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await consultationService
                  .deleteConsultation(consultation.consultationId);
              Navigator.pop(context);
              setState(() {
                matchingConsultations.remove(consultation);
              });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------- //
  void _addNewConsultation() async {
    if (_feeController.text.isEmpty ||
        double.tryParse(_feeController.text) == null ||
        selectedDoctorName == null) {
      _showAlertDialog('Invalid Input',
          'Please select a doctor and enter a valid consultation fee.');
      return;
    }

    if (isAddingConsultation) {
      return;
    }

    setState(() {
      isAddingConsultation = true;
    });

    try {
      double consultationFee = double.parse(_feeController.text);
      selectedDoctorId = doctorNamesAndIds.firstWhere(
          (doc) => doc['doctorName'] == selectedDoctorName)['doctorId'];

      await consultationService.addConsultation(
          selectedDoctorId!, selectedDoctorName!, consultationFee);

      setState(() {
        isAddingConsultation = false;
        addingNewConsultation = false;
        _feeController.clear();
        matchingConsultations.clear();
        handleSearchInput(previousSearchInput);
      });

      _showAlertDialog('Success', 'Consultation fee added successfully.');
    } catch (error) {
      _showAlertDialog(
          'Error', 'An error occurred while adding the consultation.');
      setState(() {
        isAddingConsultation = false;
      });
    }
  }
  // ----------------------------------------------------------------------- //

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

  // ------------------------------------------------------------------------ //
  Widget buildAddNewConsultationUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Add Consultation Fee',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              addingNewConsultation = false;
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
                  child: DropdownButtonFormField<String>(
                    value: selectedDoctorName,
                    items: doctorNamesAndIds.map((doc) {
                      return DropdownMenuItem(
                        value: doc['doctorName'],
                        child: Text(doc['doctorName']!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDoctorName = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Doctor',
                      labelStyle: MyTextStyle.textStyleMap['label-large']
                          ?.copyWith(
                              color:
                                  MyColors.colorPalette['on-surface-variant']),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        borderSide: BorderSide(
                          color: MyColors.colorPalette['on-surface-variant'] ??
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
                    controller: _feeController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Consultation Fee',
                      labelStyle: MyTextStyle.textStyleMap['label-large']
                          ?.copyWith(
                              color:
                                  MyColors.colorPalette['on-surface-variant']),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8.0),
                        ),
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
                      SizedBox(
                        height: 48,
                        width: 144,
                        child: ElevatedButton(
                          onPressed: _addNewConsultation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.colorPalette[
                                'primary'], // Set the background color
                          ),
                          child: Text(
                            'Add',
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
                            addingNewConsultation = false;
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                      if (isAddingConsultation)
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
  // ------------------------------------------------------------------------ //

  Widget buildSearchUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Search Consultation Fee',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              addingNewConsultation = false;
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
                  setState(() {
                    handleSearchInput(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Enter Doctor Name',
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
          if (hasUserInput && matchingConsultations.isNotEmpty) ...[
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
                            'Existing Consultation Fees',
                            style: MyTextStyle.textStyleMap['title-large']
                                ?.copyWith(
                                    color: MyColors.colorPalette['on-surface']),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          for (var consultation in matchingConsultations)
                            InkWell(
                              onLongPress: () {
                                deleteConsultation(consultation);
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text(
                                    'Doctor: ${consultation.doctorName}',
                                    style: MyTextStyle
                                        .textStyleMap['label-medium']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['on_surface']),
                                  ),
                                  subtitle: Text(
                                    'Fee: ${consultation.consultationFee.toStringAsFixed(2)}',
                                    style: MyTextStyle
                                        .textStyleMap['label-medium']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['on_surface']),
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      handleSelectedConsultation(consultation);
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
                                    addingNewConsultation = true;
                                    hasUserInput = false;
                                    matchingConsultations.clear();
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
          ] else if (hasUserInput && matchingConsultations.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'No matching consultation fee found',
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
                      addingNewConsultation = true;
                      hasUserInput = false;
                      matchingConsultations.clear();
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
    if (addingNewConsultation) {
      return buildAddNewConsultationUI();
    }

    return buildSearchUI();
  }
}
