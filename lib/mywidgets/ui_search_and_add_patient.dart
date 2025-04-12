import 'dart:io';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/mywidgets/book_appointment.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/patient.dart';
import 'package:neocaresmileapp/mywidgets/ui_success_patient_added_for_appointment.dart';
import 'package:neocaresmileapp/mywidgets/ui_book_appointment_for_new_patient.dart';
import 'package:neocaresmileapp/mywidgets/ui_book_appointment_for_selected_patient.dart';
import '../firestore/patient_service.dart';
import 'dart:developer' as devtools show log;

class UISearchAndAddPatient extends StatefulWidget {
  final String doctorId;
  final String clinicId;
  final String doctorName;
  final PatientService patientService;
  final String? selectedSlot;
  final DateTime selectedDate;
  final List<Map<String, dynamic>> slotsForSelectedDayList;

  const UISearchAndAddPatient({
    super.key,
    required this.doctorId,
    required this.clinicId,
    required this.doctorName,
    required this.patientService,
    required this.selectedSlot,
    required this.selectedDate,
    required this.slotsForSelectedDayList,
  });

  @override
  State<UISearchAndAddPatient> createState() => _UISearchAndAddPatientState();
}

class _UISearchAndAddPatientState extends State<UISearchAndAddPatient> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _patientMobileController =
      TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _userMobileInput = '';
  String _userNameInput = '';

  List<Patient> matchingPatients = [];

  bool addingNewPatient = false;
  bool isAddingPatient = false;

  bool hasUserInput = false;
  bool showNoMatchingPatientMessage = false;

  String? gender = '';
  File? _pickedImage;
  String previousSearchInput = '';
  String? _newPatientMobileError;
  Patient? newlyAddedPatient;

  @override
  void initState() {
    super.initState();
    addingNewPatient = false;
  }

  // Function to determine whether the button should be disabled or not
  bool isButtonDisabled() {
    return _patientMobileController.text.trim().isEmpty ||
        _patientNameController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty ||
        gender!.isEmpty ||
        (!isValidPhoneNumber(_patientMobileController.text));
  }

  //####################################################################################//
  // START OF handleSearchInput Function//

  void handleSearchInput(String userInput) async {
    // Ensure the widget is still mounted
    if (!mounted) return;

    setState(() {
      if (_isNumeric(userInput)) {
        _userMobileInput = userInput;
      } else {
        _userNameInput = userInput;
      }
      matchingPatients.clear();
    });

    try {
      // Use PatientService to search for matching patients
      final searchResults = await widget.patientService
          .getPatientsBySearchForCurrentUser(userInput);

      if (!mounted) return; // Ensure the widget is still mounted
      setState(() {
        matchingPatients = searchResults;
      });
    } catch (e) {
      devtools.log('Error fetching matching patients: $e');
    }
  }

  // END OF handleSearchInput Function//
  //####################################################################################//
  //
  //####################################################################################//
  // START OF _isNumeric Function//
  // Function to check if a string is numeric
  bool _isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  // END OF _isNumeric Function//
  //####################################################################################//

  //#####################################################################################//

  // void handleSelectedPatient(Patient patient) {
  //   devtools.log(
  //       'Welcome to handleSelectedPatient defined inside SearchAndAddPatient. Patient just been selected is $patient');
  //   widget.patientService.incrementSearchCount(patient.patientId);
  // }
  void handleSelectedPatient(Patient patient) {
    devtools.log('clinicId is ${widget.clinicId}');
    devtools.log(
        'Welcome to handleSelectedPatient defined inside UISearchAndAddPatient. Patient just been selected is $patient');
    devtools.log('patient id is ${patient.patientId}');
    devtools.log('Incrementing search count for patient: ${patient.patientId}');
    widget.patientService.incrementSearchCount(patient.patientId);
    //widget.patientService.testIncrementSearchCount('4o0xzWh9yrmABSlcNfU9');

    // Navigate to UIBookAppointment with selected patient's details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UIBookAppointmentForSelectedPatient(
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
          clinicId: widget.clinicId,
          patientService: widget.patientService,
          selectedSlot: widget.selectedSlot,
          selectedDate: widget.selectedDate,
          selectedPatient: patient,
          slotsForSelectedDayList: widget.slotsForSelectedDayList,
        ),
      ),
    );
  }

  // END OF handleSelectedPatient Function//
  //####################################################################################//

  //####################################################################################//
  // START OF isValidPhoneNumber Function//
  bool isValidPhoneNumber(String patientMobileNumber) {
    devtools.log('Welcome to isValidPhoneNumber');
    bool containsOnlyDigits = RegExp(r'^[0-9]+$').hasMatch(patientMobileNumber);
    //bool isLengthValid = patientMobileNumber.trim().length >= 8;
    bool isLengthValid = patientMobileNumber.trim().length == 10;
    return containsOnlyDigits && isLengthValid;
  }

  // END OF isValidPhoneNumber Function//
  //####################################################################################//
  //
  //####################################################################################//
  // START OF _showAlertDialog Function//
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

  // END OF _showAlertDialog Function//
  //####################################################################################//
  //
  //####################################################################################//
  // START OF _pickImage Function//
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    } else {
      // If the user cancels the image picking, clear the picked image
      setState(() {
        _pickedImage = null;
      });
    }
  }

  // END OF _pickImage Function//
  //####################################################################################//
  //
  //####################################################################################//
  // START OF _addNewPatient FUNCTION //

  void _addNewPatient() async {
    devtools.log('Welcome to _addNewPatient');

    if (!isValidPhoneNumber(_patientMobileController.text)) {
      setState(() {
        _newPatientMobileError = 'Mobile number must be 10 digits long';
      });
      return;
    } else {
      setState(() {
        _newPatientMobileError = null;
      });
    }

    // Check if patient is already being added
    if (isAddingPatient) {
      return; // Do nothing if patient is already being added
    }

    // Set the flag to indicate that the patient is being added
    setState(() {
      isAddingPatient = true;
    });

    try {
      // Validate the required fields
      if (_patientMobileController.text.trim().isEmpty ||
          _patientNameController.text.trim().isEmpty ||
          _ageController.text.trim().isEmpty ||
          gender!.isEmpty ||
          (!isValidPhoneNumber(_patientMobileController.text))) {
        _showAlertDialog(
            'Invalid Input', 'Please fill in all required fields.');
        return;
      }

      // Collect user input data
      final String patientMobileNumber = _patientMobileController.text;
      final String patientName = _patientNameController.text;
      //--------------------------------------------------------//
      //final int age = int.tryParse(_ageController.text) ?? 0;

      final String ageText = _ageController.text.trim();

      // Validate age text
      if (ageText.isEmpty) {
        // Show an error message or handle the case where age is empty
        return;
      }

      // Attempt to parse age text into an integer
      final int? age = int.tryParse(ageText);

      if (age == null) {
        // Show an error message or handle the case where age is not a valid integer
        return;
      }

      //---------------------------------------------------------//
      final String selectedGender = gender ?? '';

      // Add patient to Firestore
      PatientService patientService =
          PatientService(widget.clinicId, widget.doctorId);
      String newPatientId = await patientService.addPatient(
        patientName,
        selectedGender,
        age,
        patientMobileNumber,
        '',
      );

      if (newPatientId.isNotEmpty) {
        // Upload the patient image to Firebase Storage
        if (_pickedImage != null) {
          final imageUrl = await patientService.uploadPatientImage(
              _pickedImage!, newPatientId);

          // Update the patient document in Firestore with the image URL
          await patientService.updatePatientImage(newPatientId, imageUrl);
        }

        // Fetch details of the new patient
        Map<String, dynamic>? newPatient =
            await patientService.getPatientById(newPatientId);
        //devtools.log('Details of newPatient just been added is $newPatient');

        if (newPatient != null) {
          newlyAddedPatient = Patient.fromJson(newPatient);

          // ignore: use_build_context_synchronously
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UISuccessPatientAddedForAppointment(
                doctorId: widget.doctorId,
                doctorName: widget.doctorName,
                clinicId: widget.clinicId,
                patientService: widget.patientService,
                selectedSlot: widget.selectedSlot,
                selectedDate: widget.selectedDate,
                newlyAddedPatient: newlyAddedPatient,
                slotsForSelectedDayList: widget.slotsForSelectedDayList,
              ),
            ),
          );
        } else {
          _showAlertDialog('Error', 'Failed to fetch new patient details.');
        }
      } else {
        devtools.log('Error creating a new patient: newPatientId is empty');
        _showAlertDialog('Error', 'Failed to create a new patient.');
      }

      // Clear the controllers and reset the UI
      setState(() {
        if (_isNumeric(_searchController.text)) {
          previousSearchInput = patientMobileNumber;
          _searchController.text = previousSearchInput;
        } else {
          previousSearchInput = patientName;
          _searchController.text = previousSearchInput;
        }
        //_searchController.clear();
        _patientMobileController.clear();
        _patientNameController.clear();
        _ageController.clear();
        gender = '';
        _pickedImage = null;
        matchingPatients.clear();
        hasUserInput = false;
        addingNewPatient = false;
        isAddingPatient = false;

        handleSearchInput(previousSearchInput);
      });

      // Additional logic (if needed) for pushing patientData to the backend
    } catch (error) {
      // Handle unexpected errors

      devtools.log('Unexpected error: $error');
      _showAlertDialog('Error', 'An unexpected error occurred.');
    }
  }

  //END OF _addNewPatient FUNCTION//
  //###########################################################################//

  // START OF fetchAndDisplayMatchingPatients FUNCTION //

  Future<List<Patient>> fetchAndDisplayMatchingPatients(
      String previousSearchInput) async {
    devtools.log('Fetching matching patients for input: $previousSearchInput');

    try {
      // Use PatientService to fetch matching patients
      final searchResults = await widget.patientService
          .getPatientsBySearchForCurrentUser(previousSearchInput);

      devtools.log('Fetched patients: $searchResults');
      return searchResults;
    } catch (e) {
      devtools.log('Error fetching matching patients: $e');
      return [];
    }
  }

  //END OF fetchAndDisplayMatchingPatients FUNCTION//
  //###########################################################################//

  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
  // START OF buildAddNewPatientUI WIDGET //

  Widget buildAddNewPatientUI() {
    //---------------------------//
    // Prepopulate patient fields with the contents of the search bar if available
    if (_searchController.text.isNotEmpty) {
      if (_isNumeric(_searchController.text)) {
        // If input is numeric, assume it's a phone number
        _patientMobileController.text = _searchController.text;
      } else {
        // Otherwise, assume it's a name
        _patientNameController.text = _searchController.text;
      }
    }
    //---------------------------//
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Book Appointment', // Update the title to reflect the current screen
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Selected Date',
                          style: MyTextStyle.textStyleMap['title-medium']
                              ?.copyWith(
                                  color: MyColors.colorPalette['on-surface']),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Selected Slot',
                          style: MyTextStyle.textStyleMap['title-medium']
                              ?.copyWith(
                                  color: MyColors.colorPalette['on-surface']),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          DateFormat('EEE, MMM d').format(widget.selectedDate),
                          style: MyTextStyle.textStyleMap['title-medium']
                              ?.copyWith(
                                  color: MyColors.colorPalette['on-surface']),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        //'slot',
                        widget.selectedSlot ?? " ",
                        style: MyTextStyle.textStyleMap['title-medium']
                            ?.copyWith(
                                color: MyColors.colorPalette['on-surface']),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                            controller: _patientMobileController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')), // Allow only digits
                              LengthLimitingTextInputFormatter(
                                  10), // Limit input to 10 characters
                            ],
                            decoration: InputDecoration(
                              labelText: 'Enter phone number here',
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
                              errorText:
                                  _patientMobileController.text.length == 10
                                      ? null
                                      : 'Mobile number must be 10 digits long',
                            ),
                            onChanged: (_) => setState(() {
                              _isButtonEnabled();
                              bool isButtonEnabled = _isButtonEnabled();
                              devtools.log(
                                  'After input for mobile number _isButtonEnabled is $isButtonEnabled');
                            }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                backgroundColor:
                                    MyColors.colorPalette['secondary'],
                                radius: 28,
                                child: _pickedImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(28),
                                        child: Image.file(
                                          _pickedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.camera_alt),
                                        iconSize: 32,
                                        color: MyColors
                                            .colorPalette['on-secondary'],
                                        onPressed: () {
                                          _pickImage();
                                        },
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _patientNameController,
                            decoration: InputDecoration(
                              labelText: 'Enter patient name here',
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
                                    color: MyColors.colorPalette[
                                            'on-surface-variant'] ??
                                        Colors.black),
                              ),
                              contentPadding: const EdgeInsets.only(left: 8.0),
                            ),
                            onChanged: (_) => setState(() {
                              _isButtonEnabled();
                              bool isButtonEnabled =
                                  _isButtonEnabled(); // Call the function to get its return value
                              devtools.log(
                                  'After input for patient name _isButtonEnabled is $isButtonEnabled');
                            }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                width:
                                    60, // Adjusted width to accommodate 2 digits
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: MyColors.colorPalette[
                                            'surface-container'] ??
                                        Colors.black,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType
                                      .number, // Use numeric keyboard
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly, // Allow only digits
                                    LengthLimitingTextInputFormatter(
                                        2), // Limit input to 2 characters
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Age',
                                    labelStyle: MyTextStyle
                                        .textStyleMap['label-large']
                                        ?.copyWith(
                                      color:
                                          MyColors.colorPalette['on-surface'],
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical:
                                            10), // Adjust vertical padding
                                    isDense:
                                        true, // Reduces the vertical padding
                                  ),
                                  textAlign: TextAlign
                                      .center, // Center-align the text input
                                  onChanged: (_) => setState(() {
                                    _isButtonEnabled();
                                    bool isButtonEnabled =
                                        _isButtonEnabled(); // Call the function to get its return value
                                    devtools.log(
                                        'After input for age _isButtonEnabled is $isButtonEnabled');
                                  }),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Years',
                                  style: MyTextStyle.textStyleMap['label-large']
                                      ?.copyWith(
                                          color: MyColors
                                              .colorPalette['on-surface']),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Radio(
                                    value: 'male',
                                    groupValue: gender,
                                    onChanged: (value) {
                                      devtools.log(
                                          'Before setState in male radio button gender is $gender');
                                      setState(() {
                                        if (value == 'male' ||
                                            value == 'female') {
                                          gender = value;
                                        } else {
                                          gender = '';
                                        }
                                      });
                                    },
                                    visualDensity:
                                        VisualDensity.adaptivePlatformDensity,
                                    activeColor:
                                        MyColors.colorPalette['primary'] ??
                                            const Color(0xFF008D90),
                                  ),
                                  Text(
                                    'Male',
                                    style: MyTextStyle
                                        .textStyleMap['label-medium']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['on-surface']),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  Radio(
                                    value: 'female',
                                    groupValue: gender,
                                    onChanged: (value) {
                                      devtools.log(
                                          'Before setState inside female radio button gender is $gender');
                                      setState(() {
                                        if (value == 'male' ||
                                            value == 'female') {
                                          gender = value;
                                        } else {
                                          gender = '';
                                        }
                                      });
                                    },
                                    visualDensity:
                                        VisualDensity.adaptivePlatformDensity,
                                    activeColor:
                                        MyColors.colorPalette['primary'] ??
                                            const Color(0xFF008D90),
                                  ),
                                  Text(
                                    'Female',
                                    style: MyTextStyle
                                        .textStyleMap['label-medium']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['on-surface']),
                                  ),
                                ],
                              ),
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
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.disabled)) {
                                          return Colors.grey;
                                        } else {
                                          return MyColors
                                              .colorPalette['primary']!;
                                        }
                                      },
                                    ),
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
                                  // onPressed:
                                  //     _isButtonEnabled() && gender == 'male' ||
                                  //             gender == 'female'
                                  //         ? _addNewPatient
                                  //         : null,
                                  onPressed: _isButtonEnabled()
                                      ? _addNewPatient
                                      : null,

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
                                    // Toggle the addingNewPatient state to switch between screens
                                    _searchController.clear();
                                    addingNewPatient = !addingNewPatient;
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                              if (isAddingPatient)
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
  // END OF buildAddNewPatientUI WIDGET //
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

  bool _isButtonEnabled() {
    // Check if patient name, age, and gender are not empty
    bool isNameNotEmpty = _patientNameController.text.isNotEmpty;
    bool isAgeNotEmpty = _ageController.text.isNotEmpty;
    bool isGenderSelected = gender!.isNotEmpty;

    // Check if patient mobile number is not empty and contains exactly 10 digits
    bool isMobileValid = _patientMobileController.text.length == 10 &&
        RegExp(r'^[0-9]+$').hasMatch(_patientMobileController.text);

    // Return true only if all conditions are met
    return isNameNotEmpty && isAgeNotEmpty && isMobileValid && isGenderSelected;
  }

  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  // START OF buildPreviousSearchUI WIDGET //
  Widget buildPreviousSearchUI(String previousSearchInput) {
    devtools.log('Welcome to buildPreviousSearchUI');
    bool dataFetched = false; // Flag to indicate if data fetching is complete

    // return FutureBuilder<void>(
    return FutureBuilder<List<Patient>>(
      future: fetchAndDisplayMatchingPatients(previousSearchInput),
      builder: (context, snapshot) {
        // Print the context
        devtools.log('BuildContext: $context');

        // Print the snapshot
        devtools.log('AsyncSnapshot: $snapshot');
        devtools
            .log('This is coming from inside builder: (context, snapshot) {');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.connectionState == ConnectionState.done) {
          // Set dataFetched to true only when data fetching is complete
          // Update the state with the new list of matching patients

          dataFetched = true;

          devtools.log(
              'snapshot.connectionState is now ${snapshot.connectionState}');
          devtools.log('dataFetched is now $dataFetched');

          devtools.log('snapshot.data! is  ${snapshot.data!}');

          // Update the state with the new list of matching patients

          List<Patient> matchingPatients = snapshot.data!;
          devtools
              .log('local variable matchingPatients is now $matchingPatients');

          return Column(
            children: [
              if (dataFetched && matchingPatients.isNotEmpty) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          child: TextField(
                            controller: _searchController,
                            onTap: () {
                              // Set addingNewPatient to false when the search bar is tapped
                              setState(() {
                                _searchController.clear();
                              });
                            },
                            onChanged: (value) {
                              setState(() {
                                if (value.isEmpty) {
                                  matchingPatients.clear();
                                  previousSearchInput = '';
                                  addingNewPatient = true;
                                }
                                // Update search input value and handle search
                                _searchController.text = value;
                                handleSearchInput(value);
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Enter name or phone number',
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
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 8.0),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Existing Patients',
                            style: MyTextStyle.textStyleMap['title-large']
                                ?.copyWith(
                                    color: MyColors.colorPalette['on-surface']),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            for (var patient in matchingPatients)
                              InkWell(
                                //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
                                onTap: () {
                                  handleSelectedPatient(patient);
                                },
                                //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
                                child: Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          MyColors.colorPalette['surface'],
                                      backgroundImage: patient.patientPicUrl !=
                                                  null &&
                                              patient.patientPicUrl!.isNotEmpty
                                          ? NetworkImage(patient.patientPicUrl!)
                                          : Image.asset(
                                              'assets/images/default-image.png',
                                              color: MyColors
                                                  .colorPalette['primary'],
                                              colorBlendMode: BlendMode.color,
                                            ).image,
                                    ),
                                    title: Text(
                                      patient.patientName,
                                      style: MyTextStyle
                                          .textStyleMap['label-medium']
                                          ?.copyWith(
                                              color: MyColors
                                                  .colorPalette['on_surface']),
                                    ),
                                    subtitle: Text(
                                      '${patient.age}, ${patient.gender}, ${patient.patientMobileNumber}',
                                      style: MyTextStyle
                                          .textStyleMap['label-medium']
                                          ?.copyWith(
                                              color: MyColors
                                                  .colorPalette['on_surface']),
                                    ),
                                    trailing: CircleAvatar(
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
                                            color: MyColors
                                                .colorPalette['primary']!,
                                            width: 1.0),
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_isNumeric(_searchController.text)) {
                                        _patientMobileController.text =
                                            _searchController.text;
                                      } else {
                                        _patientNameController.text =
                                            _searchController.text;
                                      }

                                      addingNewPatient = true;
                                      hasUserInput = false;
                                      matchingPatients.clear();
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
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // No matching patients found
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No matching patient found',
                        style: MyTextStyle.textStyleMap['label-medium']
                            ?.copyWith(
                                color: MyColors.colorPalette['on_surface']),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Clear search input and set addingNewPatient to true
                            _searchController.clear();
                            addingNewPatient = true;
                          });
                        },
                        child: const Text('Add New'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        } else {
          // Return an empty widget if none of the conditions are met
          return const SizedBox();
        }
      },
    );
  }

// END OF buildPreviousSearchUI WIDGET //
//******************************************************************************** */

//********************************************************************************* *//

  Widget buildSearchUI() {
    devtools.log(
        'Welcome to UISearchAndAddPatient -buildSearchUI. addingNewPatient is $addingNewPatient');
    devtools.log('_searchController.text is ${_searchController.text}');
    devtools.log('hasUserInput is $hasUserInput');
    devtools.log('previousSearchInput is $previousSearchInput');
    devtools.log('matchingPatients is $matchingPatients');
    devtools.log('newlyAddedPatient is $newlyAddedPatient');

    // if (newlyAddedPatient != null) {
    //   devtools.log(
    //       'Welcome to if (newlyAddedPatient != null) { inside buildSearchUI');
    //   handleAddedPatient(newlyAddedPatient!);

    //   return const SizedBox.shrink();
    // } else if (_searchController.text.isEmpty &&
    if (_searchController.text.isEmpty && !addingNewPatient && !hasUserInput) {
      devtools.log(
          'This is coming from inside if (_searchController.text.isEmpty && !addingNewPatient && !hasUserInput) {');
      previousSearchInput = '';
      matchingPatients.clear();
      devtools.log(
          'previousSearchInput inside if statement is $previousSearchInput');
      devtools.log('and matchingPatients is $matchingPatients');
      // If search input is empty and we are not adding a new patient and there's no user input,
      // render the default search UI
      return Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.colorPalette['surface-container-lowest'],
          title: Text(
            'Book Appointment', // Update the title to reflect the current screen
            style: MyTextStyle.textStyleMap['title-large']
                ?.copyWith(color: MyColors.colorPalette['on-surface']),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous screen
              //widget.onNavigationBack();
              //widget.bookAppointmentKey.currentState?.refreshCalendar();
              devtools.log('backarrow icon pressed');
            },
            color: MyColors.colorPalette['on-surface'],
          ),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Selected Date',
                      style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
                          color: MyColors.colorPalette['on-surface']),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Selected Slot',
                      style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
                          color: MyColors.colorPalette['on-surface']),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      DateFormat('EEE, MMM d').format(widget.selectedDate),
                      style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
                          color: MyColors.colorPalette['on-surface']),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    //'slot',
                    widget.selectedSlot ?? " ",
                    style: MyTextStyle.textStyleMap['title-medium']
                        ?.copyWith(color: MyColors.colorPalette['on-surface']),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                child: TextField(
                  //focusNode: _searchFocusNode,
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      hasUserInput = value.isNotEmpty;
                      if (value.isEmpty) {
                        matchingPatients.clear();
                      }

                      if (_isNumeric(value)) {
                        _userMobileInput = value;
                      } else {
                        _userNameInput = value;
                      }

                      handleSearchInput(value);
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter name or phone number',
                    labelStyle: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(
                            color: MyColors.colorPalette['on-surface-variant']),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(
                        color: MyColors.colorPalette['primary'] ?? Colors.black,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
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
          ],
        ),
      );
    } else {
      // If previousSearchInput is not empty, render previous search results
      // if (previousSearchInput.isNotEmpty && newlyAddedPatient == null) {
      if (previousSearchInput.isNotEmpty && newlyAddedPatient != null) {
        devtools.log(
            'You are inside -if (previousSearchInput.isNotEmpty) {- which invokes buildPreviousSearchUI');
        return Scaffold(
          appBar: AppBar(
            backgroundColor: MyColors.colorPalette['surface-container-lowest'],
            title: Text(
              'Search and Add Patient', // Update the title to reflect the current screen
              style: MyTextStyle.textStyleMap['title-large']
                  ?.copyWith(color: MyColors.colorPalette['on-surface']),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
              color: MyColors.colorPalette['on-surface'],
            ),
          ),
          body: buildPreviousSearchUI(previousSearchInput),
        );
      } else {
        // Render the search UI with matching patients and Add New button
        return Scaffold(
          appBar: AppBar(
            backgroundColor: MyColors.colorPalette['surface-container-lowest'],
            title: Text(
              'Search and Add Patient', // Update the title to reflect the current screen
              style: MyTextStyle.textStyleMap['title-large']
                  ?.copyWith(color: MyColors.colorPalette['on-surface']),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
              color: MyColors.colorPalette['on-surface'],
            ),
          ),
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Selected Date',
                        style: MyTextStyle.textStyleMap['title-medium']
                            ?.copyWith(
                                color: MyColors.colorPalette['on-surface']),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Selected Slot',
                        style: MyTextStyle.textStyleMap['title-medium']
                            ?.copyWith(
                                color: MyColors.colorPalette['on-surface']),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat('EEE, MMM d').format(widget.selectedDate),
                        style: MyTextStyle.textStyleMap['title-medium']
                            ?.copyWith(
                                color: MyColors.colorPalette['on-surface']),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      //'slot',
                      widget.selectedSlot ?? " ",
                      style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
                          color: MyColors.colorPalette['on-surface']),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        hasUserInput = value.isNotEmpty;
                        if (value.isEmpty) {
                          matchingPatients.clear();
                        }

                        if (_isNumeric(value)) {
                          _userMobileInput = value;
                        } else {
                          _userNameInput = value;
                        }

                        handleSearchInput(value);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter name or phone number',
                      labelStyle: MyTextStyle.textStyleMap['label-large']
                          ?.copyWith(
                              color:
                                  MyColors.colorPalette['on-surface-variant']),
                      // prefixIcon: Icon(Icons.search,
                      //     color: MyColors.colorPalette['on-surface-variant']),
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
                            color:
                                MyColors.colorPalette['on-surface-variant'] ??
                                    Colors.black),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0),
                    ),
                  ),
                ),
              ),
              if (hasUserInput &&
                  matchingPatients.isNotEmpty &&
                  newlyAddedPatient == null) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Existing Patients',
                              style: MyTextStyle.textStyleMap['title-large']
                                  ?.copyWith(
                                      color:
                                          MyColors.colorPalette['on-surface']),
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              for (var patient in matchingPatients)
                                InkWell(
                                  onTap: () {
                                    devtools.log(
                                        'patient being passed to handleSelectedPatient is $patient');
                                    handleSelectedPatient(patient);
                                  },
                                  child: Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                            MyColors.colorPalette['surface'],
                                        backgroundImage: patient
                                                        .patientPicUrl !=
                                                    null &&
                                                patient
                                                    .patientPicUrl!.isNotEmpty
                                            ? NetworkImage(
                                                patient.patientPicUrl!)
                                            : Image.asset(
                                                'assets/images/default-image.png',
                                                color: MyColors
                                                    .colorPalette['primary'],
                                                colorBlendMode: BlendMode.color,
                                              ).image,
                                      ),
                                      title: Text(
                                        patient.patientName,
                                        style: MyTextStyle
                                            .textStyleMap['label-medium']
                                            ?.copyWith(
                                                color: MyColors.colorPalette[
                                                    'on_surface']),
                                      ),
                                      subtitle: Text(
                                        '${patient.age}, ${patient.gender}, ${patient.patientMobileNumber}',
                                        style: MyTextStyle
                                            .textStyleMap['label-medium']
                                            ?.copyWith(
                                                color: MyColors.colorPalette[
                                                    'on_surface']),
                                      ),
                                      // trailing: CircleAvatar(
                                      //   radius: 13.33,
                                      //   backgroundColor:
                                      //       MyColors.colorPalette['surface'] ??
                                      //           Colors.blueAccent,
                                      //   child: const Icon(
                                      //     Icons.arrow_forward_ios_rounded,
                                      //     size: 16,
                                      //     color: Colors.white,
                                      //   ),
                                      // ),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(MyColors
                                              .colorPalette['on-primary']!),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: MyColors
                                                  .colorPalette['primary']!,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        addingNewPatient = true;
                                        hasUserInput = false;
                                        matchingPatients.clear();
                                      });
                                    },
                                    child: Wrap(
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color:
                                              MyColors.colorPalette['primary'],
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
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (hasUserInput && matchingPatients.isEmpty) ...[
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'No matching patient found',
                          style: MyTextStyle.textStyleMap['label-medium']
                              ?.copyWith(
                                  color: MyColors.colorPalette['on_surface']),
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
                              addingNewPatient = true;
                              hasUserInput = false;
                              matchingPatients.clear();
                              //_searchController.text = '';
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
                  ],
                ),
              ]
            ],
          ),
        );
      }
    }
  }

  // END OF buildSearchUI WIDGET //

  @override
  Widget build(BuildContext context) {
    devtools.log(
        'slotsForSelectedDayList received inside UISearchAndAddPatient are: ${widget.slotsForSelectedDayList}');
    if (addingNewPatient) {
      // Render the UI for adding a new patient
      return buildAddNewPatientUI();
    }

    return buildSearchUI();
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW IS STABLE WITH DIRECT BACEKEND CALLS
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/ui_success_patient_added_for_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/ui_book_appointment_for_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/ui_book_appointment_for_selected_patient.dart';
// import '../firestore/patient_service.dart';
// import 'dart:developer' as devtools show log;

// class UISearchAndAddPatient extends StatefulWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;
//   final String? selectedSlot;
//   final DateTime selectedDate;
//   final List<Map<String, dynamic>> slotsForSelectedDayList;

//   const UISearchAndAddPatient({
//     super.key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//     required this.selectedSlot,
//     required this.selectedDate,
//     required this.slotsForSelectedDayList,
//   });

//   @override
//   State<UISearchAndAddPatient> createState() => _UISearchAndAddPatientState();
// }

// class _UISearchAndAddPatientState extends State<UISearchAndAddPatient> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _patientMobileController =
//       TextEditingController();
//   final TextEditingController _patientNameController = TextEditingController();
//   final TextEditingController _ageController = TextEditingController();

//   String _userMobileInput = '';
//   String _userNameInput = '';

//   List<Patient> matchingPatients = [];

//   bool addingNewPatient = false;
//   bool isAddingPatient = false;

//   bool hasUserInput = false;
//   bool showNoMatchingPatientMessage = false;

//   String? gender = '';
//   File? _pickedImage;
//   String previousSearchInput = '';
//   String? _newPatientMobileError;
//   Patient? newlyAddedPatient;

//   @override
//   void initState() {
//     super.initState();
//     addingNewPatient = false;
//   }

//   // Function to determine whether the button should be disabled or not
//   bool isButtonDisabled() {
//     return _patientMobileController.text.trim().isEmpty ||
//         _patientNameController.text.trim().isEmpty ||
//         _ageController.text.trim().isEmpty ||
//         gender!.isEmpty ||
//         (!isValidPhoneNumber(_patientMobileController.text));
//   }

//   //####################################################################################//
//   // START OF handleSearchInput Function//

//   void handleSearchInput(String userInput) async {
//     // Store user search input
//     if (!mounted) return; // Check if widget is still mounted
//     setState(() {
//       if (_isNumeric(userInput)) {
//         _userMobileInput = userInput;
//       } else {
//         _userNameInput = userInput;
//       }
//     });

//     // Update the controllers with the user input
//     _patientNameController.text =
//         _isNumeric(userInput) ? _userNameInput : userInput;
//     _patientMobileController.text =
//         _isNumeric(userInput) ? userInput : _userMobileInput;

//     // Clear the previous search results
//     devtools.log("User Input: $userInput"); // Debugging line
//     if (!mounted) return; // Check if widget is still mounted
//     setState(() {
//       matchingPatients.clear();
//     });

//     // Search for matching patients in Firestore
//     final patientsCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(widget.clinicId)
//         .collection('patients');

//     final querySnapshot = await patientsCollection
//         .where('doctorId', isEqualTo: widget.doctorId)
//         .get();

//     // Process documents in the query snapshot
//     querySnapshot.docs.forEach((doc) {
//       final data = doc.data();

//       // Check if patientName or patientMobileNumber matches the user input
//       final patientName = data['patientName'].toString().toLowerCase();
//       final patientMobileNumber = data['patientMobileNumber'].toString();

//       if (patientName.contains(userInput.toLowerCase()) ||
//           patientMobileNumber.contains(userInput)) {
//         // Filter the matching patients
//         final existingPatients = matchingPatients
//             .where((patient) => patient.patientId == doc.id)
//             .toList();

//         if (existingPatients.isEmpty) {
//           if (!mounted) return; // Check if widget is still mounted
//           setState(() {
//             matchingPatients.add(Patient(
//               patientId: doc.id,
//               age: data['age'],
//               gender: data['gender'],
//               patientName: data['patientName'],
//               patientMobileNumber: data['patientMobileNumber'],
//               patientPicUrl: data['patientPicUrl'],
//               uhid: data['uhid'],
//               clinicId: '',
//               doctorId: '',
//               searchCount: data['searchCount'] ?? 0,
//             ));
//           });
//         }
//       }
//     });
//   }

//   // END OF handleSearchInput Function//
//   //####################################################################################//
//   //
//   //####################################################################################//
//   // START OF _isNumeric Function//
//   // Function to check if a string is numeric
//   bool _isNumeric(String str) {
//     return double.tryParse(str) != null;
//   }

//   // END OF _isNumeric Function//
//   //####################################################################################//

//   //#####################################################################################//

//   // void handleSelectedPatient(Patient patient) {
//   //   devtools.log(
//   //       'Welcome to handleSelectedPatient defined inside SearchAndAddPatient. Patient just been selected is $patient');
//   //   widget.patientService.incrementSearchCount(patient.patientId);
//   // }
//   void handleSelectedPatient(Patient patient) {
//     devtools.log('clinicId is ${widget.clinicId}');
//     devtools.log(
//         'Welcome to handleSelectedPatient defined inside UISearchAndAddPatient. Patient just been selected is $patient');
//     devtools.log('patient id is ${patient.patientId}');
//     devtools.log('Incrementing search count for patient: ${patient.patientId}');
//     widget.patientService.incrementSearchCount(patient.patientId);
//     //widget.patientService.testIncrementSearchCount('4o0xzWh9yrmABSlcNfU9');

//     // Navigate to UIBookAppointment with selected patient's details
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => UIBookAppointmentForSelectedPatient(
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           clinicId: widget.clinicId,
//           patientService: widget.patientService,
//           selectedSlot: widget.selectedSlot,
//           selectedDate: widget.selectedDate,
//           selectedPatient: patient,
//           slotsForSelectedDayList: widget.slotsForSelectedDayList,
//         ),
//       ),
//     );
//   }

//   // END OF handleSelectedPatient Function//
//   //####################################################################################//
//   // void handleAddedPatient(Patient patient) {
//   //   devtools.log(
//   //       'Welcome to handleAddedPatient defined inside SearchAndAddPatient. Patient just been added is $patient');
//   //   widget.patientService.incrementSearchCount(patient.patientId);
//   // }

//   // void handleAddedPatient(Patient patient) {
//   //   devtools.log(
//   //       'Welcome to handleAddedPatient defined inside SearchAndAddPatient. Patient just been added is $patient');
//   //   widget.patientService.incrementSearchCount(patient.patientId);

//   //   // Navigate to UIBookAppointment with newly added patient's details
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => UIBookAppointmentForNewPatient(
//   //         doctorId: widget.doctorId,
//   //         doctorName: widget.doctorName,
//   //         clinicId: widget.clinicId,
//   //         patientService: widget.patientService,
//   //         selectedSlot: widget.selectedSlot,
//   //         selectedDate: widget.selectedDate,
//   //         addedPatient: addedPatient,
//   //         slotsForSelectedDayList: widget.slotsForSelectedDayList,
//   //       ),
//   //     ),
//   //   );
//   // }

//   //####################################################################################//
//   // START OF isValidPhoneNumber Function//
//   bool isValidPhoneNumber(String patientMobileNumber) {
//     devtools.log('Welcome to isValidPhoneNumber');
//     bool containsOnlyDigits = RegExp(r'^[0-9]+$').hasMatch(patientMobileNumber);
//     //bool isLengthValid = patientMobileNumber.trim().length >= 8;
//     bool isLengthValid = patientMobileNumber.trim().length == 10;
//     return containsOnlyDigits && isLengthValid;
//   }

//   // END OF isValidPhoneNumber Function//
//   //####################################################################################//
//   //
//   //####################################################################################//
//   // START OF _showAlertDialog Function//
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

//   // END OF _showAlertDialog Function//
//   //####################################################################################//
//   //
//   //####################################################################################//
//   // START OF _pickImage Function//
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedImage = await picker.pickImage(source: ImageSource.camera);

//     if (pickedImage != null) {
//       setState(() {
//         _pickedImage = File(pickedImage.path);
//       });
//     } else {
//       // If the user cancels the image picking, clear the picked image
//       setState(() {
//         _pickedImage = null;
//       });
//     }
//   }

//   // END OF _pickImage Function//
//   //####################################################################################//
//   //
//   //####################################################################################//
//   // START OF _addNewPatient FUNCTION //

//   void _addNewPatient() async {
//     devtools.log('Welcome to _addNewPatient');

//     if (!isValidPhoneNumber(_patientMobileController.text)) {
//       setState(() {
//         _newPatientMobileError = 'Mobile number must be 10 digits long';
//       });
//       return;
//     } else {
//       setState(() {
//         _newPatientMobileError = null;
//       });
//     }

//     // Check if patient is already being added
//     if (isAddingPatient) {
//       return; // Do nothing if patient is already being added
//     }

//     // Set the flag to indicate that the patient is being added
//     setState(() {
//       isAddingPatient = true;
//     });

//     try {
//       // Validate the required fields
//       if (_patientMobileController.text.trim().isEmpty ||
//           _patientNameController.text.trim().isEmpty ||
//           _ageController.text.trim().isEmpty ||
//           gender!.isEmpty ||
//           (!isValidPhoneNumber(_patientMobileController.text))) {
//         _showAlertDialog(
//             'Invalid Input', 'Please fill in all required fields.');
//         return;
//       }

//       // Collect user input data
//       final String patientMobileNumber = _patientMobileController.text;
//       final String patientName = _patientNameController.text;
//       //--------------------------------------------------------//
//       //final int age = int.tryParse(_ageController.text) ?? 0;

//       final String ageText = _ageController.text.trim();

//       // Validate age text
//       if (ageText.isEmpty) {
//         // Show an error message or handle the case where age is empty
//         return;
//       }

//       // Attempt to parse age text into an integer
//       final int? age = int.tryParse(ageText);

//       if (age == null) {
//         // Show an error message or handle the case where age is not a valid integer
//         return;
//       }

//       //---------------------------------------------------------//
//       final String selectedGender = gender ?? '';

//       // Add patient to Firestore
//       PatientService patientService =
//           PatientService(widget.clinicId, widget.doctorId);
//       String newPatientId = await patientService.addPatient(
//         patientName,
//         selectedGender,
//         age,
//         patientMobileNumber,
//         '',
//       );

//       if (newPatientId.isNotEmpty) {
//         // Upload the patient image to Firebase Storage
//         if (_pickedImage != null) {
//           final imageUrl = await patientService.uploadPatientImage(
//               _pickedImage!, newPatientId);

//           // Update the patient document in Firestore with the image URL
//           await patientService.updatePatientImage(newPatientId, imageUrl);
//         }

//         // Fetch details of the new patient
//         Map<String, dynamic>? newPatient =
//             await patientService.getPatientById(newPatientId);
//         //devtools.log('Details of newPatient just been added is $newPatient');

//         if (newPatient != null) {
//           newlyAddedPatient = Patient.fromJson(newPatient);

//           // ignore: use_build_context_synchronously
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => UISuccessPatientAddedForAppointment(
//                 doctorId: widget.doctorId,
//                 doctorName: widget.doctorName,
//                 clinicId: widget.clinicId,
//                 patientService: widget.patientService,
//                 selectedSlot: widget.selectedSlot,
//                 selectedDate: widget.selectedDate,
//                 newlyAddedPatient: newlyAddedPatient,
//                 slotsForSelectedDayList: widget.slotsForSelectedDayList,
//               ),
//             ),
//           );
//         } else {
//           _showAlertDialog('Error', 'Failed to fetch new patient details.');
//         }
//       } else {
//         devtools.log('Error creating a new patient: newPatientId is empty');
//         _showAlertDialog('Error', 'Failed to create a new patient.');
//       }

//       // Clear the controllers and reset the UI
//       setState(() {
//         if (_isNumeric(_searchController.text)) {
//           previousSearchInput = patientMobileNumber;
//           _searchController.text = previousSearchInput;
//         } else {
//           previousSearchInput = patientName;
//           _searchController.text = previousSearchInput;
//         }
//         //_searchController.clear();
//         _patientMobileController.clear();
//         _patientNameController.clear();
//         _ageController.clear();
//         gender = '';
//         _pickedImage = null;
//         matchingPatients.clear();
//         hasUserInput = false;
//         addingNewPatient = false;
//         isAddingPatient = false;

//         handleSearchInput(previousSearchInput);
//       });

//       // Additional logic (if needed) for pushing patientData to the backend
//     } catch (error) {
//       // Handle unexpected errors

//       devtools.log('Unexpected error: $error');
//       _showAlertDialog('Error', 'An unexpected error occurred.');
//     }
//   }

//   //END OF _addNewPatient FUNCTION//
//   //###########################################################################//

//   // START OF fetchAndDisplayMatchingPatients FUNCTION //

//   Future<List<Patient>> fetchAndDisplayMatchingPatients(
//       String previousSearchInput) async {
//     devtools.log('Welcome to fetchAndDisplayMatchingPatients !');
//     // Create an empty list to store matching patients
//     List<Patient> matchingPatients = [];

//     // Search for matching patients in Firestore
//     final patientsCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(widget.clinicId)
//         .collection('patients');

//     final querySnapshot = await patientsCollection
//         .where('doctorId', isEqualTo: widget.doctorId)
//         .get();

//     // Process documents in the query snapshot
//     querySnapshot.docs.forEach((doc) {
//       final data = doc.data();

//       // Check if patientName or patientMobileNumber matches the previous search input
//       final patientName = data['patientName'].toString().toLowerCase();
//       final patientMobileNumber = data['patientMobileNumber'].toString();

//       if (patientName.contains(previousSearchInput.toLowerCase()) ||
//           patientMobileNumber.contains(previousSearchInput)) {
//         // Filter the matching patients
//         final existingPatients = matchingPatients
//             .where((patient) => patient.patientId == doc.id)
//             .toList();

//         if (existingPatients.isEmpty) {
//           matchingPatients.add(Patient(
//             patientId: doc.id,
//             age: data['age'],
//             gender: data['gender'],
//             patientName: data['patientName'],
//             patientMobileNumber: data['patientMobileNumber'],
//             patientPicUrl: data['patientPicUrl'],
//             uhid: data['uhid'],
//             clinicId: '',
//             doctorId: '',
//             searchCount: data['searchCount'] ?? 0,
//           ));
//         }
//       }
//     });
//     devtools.log(
//         'This is coming from inside fetchAndDisplayMatchingPatients. matchingPatients are: $matchingPatients');

//     // Return the list of matching patients
//     return matchingPatients;
//   }
//   //END OF fetchAndDisplayMatchingPatients FUNCTION//
//   //###########################################################################//

//   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
//   // START OF buildAddNewPatientUI WIDGET //

//   Widget buildAddNewPatientUI() {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Book Appointment', // Update the title to reflect the current screen
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context); // Navigate back to the previous screen
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
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 8),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Selected Date',
//                           style: MyTextStyle.textStyleMap['title-medium']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['on-surface']),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Selected Slot',
//                           style: MyTextStyle.textStyleMap['title-medium']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['on-surface']),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Align(
//                       alignment: Alignment.topLeft,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           DateFormat('EEE, MMM d').format(widget.selectedDate),
//                           style: MyTextStyle.textStyleMap['title-medium']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['on-surface']),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         //'slot',
//                         widget.selectedSlot ?? " ",
//                         style: MyTextStyle.textStyleMap['title-medium']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['on-surface']),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
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
//                             controller: _patientMobileController,
//                             keyboardType: TextInputType.number,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.allow(
//                                   RegExp(r'[0-9]')), // Allow only digits
//                               LengthLimitingTextInputFormatter(
//                                   10), // Limit input to 10 characters
//                             ],
//                             decoration: InputDecoration(
//                               labelText: 'Enter phone number here',
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
//                               errorText:
//                                   _patientMobileController.text.length == 10
//                                       ? null
//                                       : 'Mobile number must be 10 digits long',
//                             ),
//                             onChanged: (_) => setState(() {
//                               _isButtonEnabled();
//                               bool isButtonEnabled = _isButtonEnabled();
//                               devtools.log(
//                                   'After input for mobile number _isButtonEnabled is $isButtonEnabled');
//                             }),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Align(
//                             alignment: Alignment.topLeft,
//                             child: GestureDetector(
//                               onTap: _pickImage,
//                               child: CircleAvatar(
//                                 backgroundColor:
//                                     MyColors.colorPalette['secondary'],
//                                 radius: 28,
//                                 child: _pickedImage != null
//                                     ? ClipRRect(
//                                         borderRadius: BorderRadius.circular(28),
//                                         child: Image.file(
//                                           _pickedImage!,
//                                           fit: BoxFit.cover,
//                                         ),
//                                       )
//                                     : IconButton(
//                                         icon: const Icon(Icons.camera_alt),
//                                         iconSize: 32,
//                                         color: MyColors
//                                             .colorPalette['on-secondary'],
//                                         onPressed: () {
//                                           _pickImage();
//                                         },
//                                       ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: TextFormField(
//                             controller: _patientNameController,
//                             decoration: InputDecoration(
//                               labelText: 'Enter patient name here',
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
//                                     color: MyColors.colorPalette[
//                                             'on-surface-variant'] ??
//                                         Colors.black),
//                               ),
//                               contentPadding: const EdgeInsets.only(left: 8.0),
//                             ),
//                             onChanged: (_) => setState(() {
//                               _isButtonEnabled();
//                               bool isButtonEnabled =
//                                   _isButtonEnabled(); // Call the function to get its return value
//                               devtools.log(
//                                   'After input for patient name _isButtonEnabled is $isButtonEnabled');
//                             }),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width:
//                                     60, // Adjusted width to accommodate 2 digits
//                                 height: 40,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     width: 1,
//                                     color: MyColors.colorPalette[
//                                             'surface-container'] ??
//                                         Colors.black,
//                                   ),
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                                 child: TextFormField(
//                                   controller: _ageController,
//                                   keyboardType: TextInputType
//                                       .number, // Use numeric keyboard
//                                   inputFormatters: [
//                                     FilteringTextInputFormatter
//                                         .digitsOnly, // Allow only digits
//                                     LengthLimitingTextInputFormatter(
//                                         2), // Limit input to 2 characters
//                                   ],
//                                   decoration: InputDecoration(
//                                     hintText: 'Age',
//                                     labelStyle: MyTextStyle
//                                         .textStyleMap['label-large']
//                                         ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-surface'],
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         vertical:
//                                             10), // Adjust vertical padding
//                                     isDense:
//                                         true, // Reduces the vertical padding
//                                   ),
//                                   textAlign: TextAlign
//                                       .center, // Center-align the text input
//                                   onChanged: (_) => setState(() {
//                                     _isButtonEnabled();
//                                     bool isButtonEnabled =
//                                         _isButtonEnabled(); // Call the function to get its return value
//                                     devtools.log(
//                                         'After input for age _isButtonEnabled is $isButtonEnabled');
//                                   }),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 8.0),
//                                 child: Text(
//                                   'Years',
//                                   style: MyTextStyle.textStyleMap['label-large']
//                                       ?.copyWith(
//                                           color: MyColors
//                                               .colorPalette['on-surface']),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: [
//                               Row(
//                                 children: [
//                                   Radio(
//                                     value: 'male',
//                                     groupValue: gender,
//                                     onChanged: (value) {
//                                       devtools.log(
//                                           'Before setState in male radio button gender is $gender');
//                                       setState(() {
//                                         if (value == 'male' ||
//                                             value == 'female') {
//                                           gender = value;
//                                         } else {
//                                           gender = '';
//                                         }
//                                       });
//                                     },
//                                     visualDensity:
//                                         VisualDensity.adaptivePlatformDensity,
//                                     activeColor:
//                                         MyColors.colorPalette['primary'] ??
//                                             const Color(0xFF008D90),
//                                   ),
//                                   Text(
//                                     'Male',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['on-surface']),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(width: 16),
//                               Row(
//                                 children: [
//                                   Radio(
//                                     value: 'female',
//                                     groupValue: gender,
//                                     onChanged: (value) {
//                                       devtools.log(
//                                           'Before setState inside female radio button gender is $gender');
//                                       setState(() {
//                                         if (value == 'male' ||
//                                             value == 'female') {
//                                           gender = value;
//                                         } else {
//                                           gender = '';
//                                         }
//                                       });
//                                     },
//                                     visualDensity:
//                                         VisualDensity.adaptivePlatformDensity,
//                                     activeColor:
//                                         MyColors.colorPalette['primary'] ??
//                                             const Color(0xFF008D90),
//                                   ),
//                                   Text(
//                                     'Female',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['on-surface']),
//                                   ),
//                                 ],
//                               ),
//                             ],
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
//                                     backgroundColor: MaterialStateProperty
//                                         .resolveWith<Color>(
//                                       (Set<MaterialState> states) {
//                                         if (states
//                                             .contains(MaterialState.disabled)) {
//                                           return Colors.grey;
//                                         } else {
//                                           return MyColors
//                                               .colorPalette['primary']!;
//                                         }
//                                       },
//                                     ),
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
//                                   // onPressed:
//                                   //     _isButtonEnabled() && gender == 'male' ||
//                                   //             gender == 'female'
//                                   //         ? _addNewPatient
//                                   //         : null,
//                                   onPressed: _isButtonEnabled()
//                                       ? _addNewPatient
//                                       : null,

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
//                                     // Toggle the addingNewPatient state to switch between screens
//                                     _searchController.clear();
//                                     addingNewPatient = !addingNewPatient;
//                                   });
//                                 },
//                                 child: const Text('Cancel'),
//                               ),
//                               if (isAddingPatient)
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
//   // END OF buildAddNewPatientUI WIDGET //
//   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

//   bool _isButtonEnabled() {
//     // Check if patient name, age, and gender are not empty
//     bool isNameNotEmpty = _patientNameController.text.isNotEmpty;
//     bool isAgeNotEmpty = _ageController.text.isNotEmpty;
//     bool isGenderSelected = gender!.isNotEmpty;

//     // Check if patient mobile number is not empty and contains exactly 10 digits
//     bool isMobileValid = _patientMobileController.text.length == 10 &&
//         RegExp(r'^[0-9]+$').hasMatch(_patientMobileController.text);

//     // Return true only if all conditions are met
//     return isNameNotEmpty && isAgeNotEmpty && isMobileValid && isGenderSelected;
//   }

//   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

//   // START OF buildPreviousSearchUI WIDGET //
//   Widget buildPreviousSearchUI(String previousSearchInput) {
//     devtools.log('Welcome to buildPreviousSearchUI');
//     bool dataFetched = false; // Flag to indicate if data fetching is complete

//     // return FutureBuilder<void>(
//     return FutureBuilder<List<Patient>>(
//       future: fetchAndDisplayMatchingPatients(previousSearchInput),
//       builder: (context, snapshot) {
//         // Print the context
//         devtools.log('BuildContext: $context');

//         // Print the snapshot
//         devtools.log('AsyncSnapshot: $snapshot');
//         devtools
//             .log('This is coming from inside builder: (context, snapshot) {');

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         } else if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         } else if (snapshot.connectionState == ConnectionState.done) {
//           // Set dataFetched to true only when data fetching is complete
//           // Update the state with the new list of matching patients

//           dataFetched = true;

//           devtools.log(
//               'snapshot.connectionState is now ${snapshot.connectionState}');
//           devtools.log('dataFetched is now $dataFetched');

//           devtools.log('snapshot.data! is  ${snapshot.data!}');

//           // Update the state with the new list of matching patients

//           List<Patient> matchingPatients = snapshot.data!;
//           devtools
//               .log('local variable matchingPatients is now $matchingPatients');

//           return Column(
//             children: [
//               if (dataFetched && matchingPatients.isNotEmpty) ...[
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: SizedBox(
//                           child: TextField(
//                             controller: _searchController,
//                             onTap: () {
//                               // Set addingNewPatient to false when the search bar is tapped
//                               setState(() {
//                                 _searchController.clear();
//                               });
//                             },
//                             onChanged: (value) {
//                               setState(() {
//                                 if (value.isEmpty) {
//                                   matchingPatients.clear();
//                                   previousSearchInput = '';
//                                   addingNewPatient = true;
//                                 }
//                                 // Update search input value and handle search
//                                 _searchController.text = value;
//                                 handleSearchInput(value);
//                               });
//                             },
//                             decoration: InputDecoration(
//                               labelText: 'Enter name or phone number',
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
//                       ),
//                       Align(
//                         alignment: Alignment.topLeft,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'Existing Patients',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on-surface']),
//                           ),
//                         ),
//                       ),
//                       SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             for (var patient in matchingPatients)
//                               InkWell(
//                                 //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
//                                 onTap: () {
//                                   handleSelectedPatient(patient);
//                                 },
//                                 //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
//                                 child: Card(
//                                   child: ListTile(
//                                     leading: CircleAvatar(
//                                       radius: 24,
//                                       backgroundColor:
//                                           MyColors.colorPalette['surface'],
//                                       backgroundImage: patient.patientPicUrl !=
//                                                   null &&
//                                               patient.patientPicUrl!.isNotEmpty
//                                           ? NetworkImage(patient.patientPicUrl!)
//                                           : Image.asset(
//                                               'assets/images/default-image.png',
//                                               color: MyColors
//                                                   .colorPalette['primary'],
//                                               colorBlendMode: BlendMode.color,
//                                             ).image,
//                                     ),
//                                     title: Text(
//                                       patient.patientName,
//                                       style: MyTextStyle
//                                           .textStyleMap['label-medium']
//                                           ?.copyWith(
//                                               color: MyColors
//                                                   .colorPalette['on_surface']),
//                                     ),
//                                     subtitle: Text(
//                                       '${patient.age}, ${patient.gender}, ${patient.patientMobileNumber}',
//                                       style: MyTextStyle
//                                           .textStyleMap['label-medium']
//                                           ?.copyWith(
//                                               color: MyColors
//                                                   .colorPalette['on_surface']),
//                                     ),
//                                     trailing: CircleAvatar(
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
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Align(
//                                 alignment: Alignment.topLeft,
//                                 child: ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor: MaterialStateProperty.all(
//                                         MyColors.colorPalette['on-primary']!),
//                                     shape: MaterialStateProperty.all(
//                                       RoundedRectangleBorder(
//                                         side: BorderSide(
//                                             color: MyColors
//                                                 .colorPalette['primary']!,
//                                             width: 1.0),
//                                         borderRadius:
//                                             BorderRadius.circular(24.0),
//                                       ),
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     setState(() {
//                                       if (_isNumeric(_searchController.text)) {
//                                         _patientMobileController.text =
//                                             _searchController.text;
//                                       } else {
//                                         _patientNameController.text =
//                                             _searchController.text;
//                                       }

//                                       addingNewPatient = true;
//                                       hasUserInput = false;
//                                       matchingPatients.clear();
//                                     });
//                                   },
//                                   child: Wrap(
//                                     children: [
//                                       Icon(
//                                         Icons.add,
//                                         color: MyColors.colorPalette['primary'],
//                                       ),
//                                       Text(
//                                         'Add New',
//                                         style: MyTextStyle
//                                             .textStyleMap['label-large']
//                                             ?.copyWith(
//                                                 color: MyColors
//                                                     .colorPalette['primary']),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ] else ...[
//                 // No matching patients found
//                 Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         'No matching patient found',
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
//                             // Clear search input and set addingNewPatient to true
//                             _searchController.clear();
//                             addingNewPatient = true;
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
//           // Return an empty widget if none of the conditions are met
//           return const SizedBox();
//         }
//       },
//     );
//   }

// // END OF buildPreviousSearchUI WIDGET //
// //******************************************************************************** */

// //********************************************************************************* *//

//   Widget buildSearchUI() {
//     devtools.log(
//         'Welcome to UISearchAndAddPatient -buildSearchUI. addingNewPatient is $addingNewPatient');
//     devtools.log('_searchController.text is ${_searchController.text}');
//     devtools.log('hasUserInput is $hasUserInput');
//     devtools.log('previousSearchInput is $previousSearchInput');
//     devtools.log('matchingPatients is $matchingPatients');
//     devtools.log('newlyAddedPatient is $newlyAddedPatient');

//     // if (newlyAddedPatient != null) {
//     //   devtools.log(
//     //       'Welcome to if (newlyAddedPatient != null) { inside buildSearchUI');
//     //   handleAddedPatient(newlyAddedPatient!);

//     //   return const SizedBox.shrink();
//     // } else if (_searchController.text.isEmpty &&
//     if (_searchController.text.isEmpty && !addingNewPatient && !hasUserInput) {
//       devtools.log(
//           'This is coming from inside if (_searchController.text.isEmpty && !addingNewPatient && !hasUserInput) {');
//       previousSearchInput = '';
//       matchingPatients.clear();
//       devtools.log(
//           'previousSearchInput inside if statement is $previousSearchInput');
//       devtools.log('and matchingPatients is $matchingPatients');
//       // If search input is empty and we are not adding a new patient and there's no user input,
//       // render the default search UI
//       return Scaffold(
//         appBar: AppBar(
//           backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//           title: Text(
//             'Book Appointment', // Update the title to reflect the current screen
//             style: MyTextStyle.textStyleMap['title-large']
//                 ?.copyWith(color: MyColors.colorPalette['on-surface']),
//           ),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pop(context); // Navigate back to the previous screen
//               //widget.onNavigationBack();
//               //widget.bookAppointmentKey.currentState?.refreshCalendar();
//               devtools.log('backarrow icon pressed');
//             },
//             color: MyColors.colorPalette['on-surface'],
//           ),
//         ),
//         body: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 8),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'Selected Date',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface']),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'Selected Slot',
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface']),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       DateFormat('EEE, MMM d').format(widget.selectedDate),
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface']),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     //'slot',
//                     widget.selectedSlot ?? " ",
//                     style: MyTextStyle.textStyleMap['title-medium']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: SizedBox(
//                 child: TextField(
//                   //focusNode: _searchFocusNode,
//                   controller: _searchController,
//                   onChanged: (value) {
//                     setState(() {
//                       hasUserInput = value.isNotEmpty;
//                       if (value.isEmpty) {
//                         matchingPatients.clear();
//                       }

//                       if (_isNumeric(value)) {
//                         _userMobileInput = value;
//                       } else {
//                         _userNameInput = value;
//                       }

//                       handleSearchInput(value);
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Enter name or phone number',
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
//       // If previousSearchInput is not empty, render previous search results
//       // if (previousSearchInput.isNotEmpty && newlyAddedPatient == null) {
//       if (previousSearchInput.isNotEmpty && newlyAddedPatient != null) {
//         devtools.log(
//             'You are inside -if (previousSearchInput.isNotEmpty) {- which invokes buildPreviousSearchUI');
//         return Scaffold(
//           appBar: AppBar(
//             backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//             title: Text(
//               'Search and Add Patient', // Update the title to reflect the current screen
//               style: MyTextStyle.textStyleMap['title-large']
//                   ?.copyWith(color: MyColors.colorPalette['on-surface']),
//             ),
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () {
//                 Navigator.pop(context); // Navigate back to the previous screen
//               },
//               color: MyColors.colorPalette['on-surface'],
//             ),
//           ),
//           body: buildPreviousSearchUI(previousSearchInput),
//         );
//       } else {
//         // Render the search UI with matching patients and Add New button
//         return Scaffold(
//           appBar: AppBar(
//             backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//             title: Text(
//               'Search and Add Patient', // Update the title to reflect the current screen
//               style: MyTextStyle.textStyleMap['title-large']
//                   ?.copyWith(color: MyColors.colorPalette['on-surface']),
//             ),
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () {
//                 Navigator.pop(context); // Navigate back to the previous screen
//               },
//               color: MyColors.colorPalette['on-surface'],
//             ),
//           ),
//           body: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Selected Date',
//                         style: MyTextStyle.textStyleMap['title-medium']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['on-surface']),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Selected Slot',
//                         style: MyTextStyle.textStyleMap['title-medium']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['on-surface']),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         DateFormat('EEE, MMM d').format(widget.selectedDate),
//                         style: MyTextStyle.textStyleMap['title-medium']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['on-surface']),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       //'slot',
//                       widget.selectedSlot ?? " ",
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface']),
//                     ),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: SizedBox(
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: (value) {
//                       setState(() {
//                         hasUserInput = value.isNotEmpty;
//                         if (value.isEmpty) {
//                           matchingPatients.clear();
//                         }

//                         if (_isNumeric(value)) {
//                           _userMobileInput = value;
//                         } else {
//                           _userNameInput = value;
//                         }

//                         handleSearchInput(value);
//                       });
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Enter name or phone number',
//                       labelStyle: MyTextStyle.textStyleMap['label-large']
//                           ?.copyWith(
//                               color:
//                                   MyColors.colorPalette['on-surface-variant']),
//                       // prefixIcon: Icon(Icons.search,
//                       //     color: MyColors.colorPalette['on-surface-variant']),
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
//               if (hasUserInput &&
//                   matchingPatients.isNotEmpty &&
//                   newlyAddedPatient == null) ...[
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Align(
//                           alignment: Alignment.topLeft,
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               'Existing Patients',
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
//                               for (var patient in matchingPatients)
//                                 InkWell(
//                                   onTap: () {
//                                     devtools.log(
//                                         'patient being passed to handleSelectedPatient is $patient');
//                                     handleSelectedPatient(patient);
//                                   },
//                                   child: Card(
//                                     child: ListTile(
//                                       leading: CircleAvatar(
//                                         radius: 24,
//                                         backgroundColor:
//                                             MyColors.colorPalette['surface'],
//                                         backgroundImage: patient
//                                                         .patientPicUrl !=
//                                                     null &&
//                                                 patient
//                                                     .patientPicUrl!.isNotEmpty
//                                             ? NetworkImage(
//                                                 patient.patientPicUrl!)
//                                             : Image.asset(
//                                                 'assets/images/default-image.png',
//                                                 color: MyColors
//                                                     .colorPalette['primary'],
//                                                 colorBlendMode: BlendMode.color,
//                                               ).image,
//                                       ),
//                                       title: Text(
//                                         patient.patientName,
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on_surface']),
//                                       ),
//                                       subtitle: Text(
//                                         '${patient.age}, ${patient.gender}, ${patient.patientMobileNumber}',
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on_surface']),
//                                       ),
//                                       trailing: CircleAvatar(
//                                         radius: 13.33,
//                                         backgroundColor:
//                                             MyColors.colorPalette['surface'] ??
//                                                 Colors.blueAccent,
//                                         child: const Icon(
//                                           Icons.arrow_forward_ios_rounded,
//                                           size: 16,
//                                           color: Colors.white,
//                                         ),
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
//                                         addingNewPatient = true;
//                                         hasUserInput = false;
//                                         matchingPatients.clear();
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
//               ] else if (hasUserInput && matchingPatients.isEmpty) ...[
//                 Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Align(
//                         alignment: Alignment.topLeft,
//                         child: Text(
//                           'No matching patient found',
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
//                               addingNewPatient = true;
//                               hasUserInput = false;
//                               matchingPatients.clear();
//                               //_searchController.text = '';
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

//   // END OF buildSearchUI WIDGET //

//   @override
//   Widget build(BuildContext context) {
//     devtools.log(
//         'slotsForSelectedDayList received inside UISearchAndAddPatient are: ${widget.slotsForSelectedDayList}');
//     if (addingNewPatient) {
//       // Render the UI for adding a new patient
//       return buildAddNewPatientUI();
//     }

//     return buildSearchUI();
//   }
// }
