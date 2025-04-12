import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/patient.dart';
import 'package:neocaresmileapp/mywidgets/success_patient.dart';
import 'package:neocaresmileapp/mywidgets/treatment_landing_screen.dart';
import '../firestore/patient_service.dart';
import 'dart:developer' as devtools show log;

class AddNewPatient extends StatefulWidget {
  final String doctorId;
  final String clinicId;
  final String doctorName;
  //final PatientService patientService;
  final String appBarTitle;

  const AddNewPatient({
    super.key,
    required this.doctorId,
    required this.clinicId,
    required this.doctorName,
    //required this.patientService,
    required this.appBarTitle,
  });

  @override
  State<AddNewPatient> createState() => AddNewPatientState();
}

class AddNewPatientState extends State<AddNewPatient> {
  late PatientService _patientService;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _patientMobileController =
      TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  // Store user search input for mobile number and name
  String _userMobileInput = '';
  String _userNameInput = '';

  List<Patient> matchingPatients = []; // Store matching patients

  bool addingNewPatient = false; // Track if the user is adding a new patient
  bool isAddingPatient = false; // Track if the patient is already being added

  bool hasUserInput = false; // Track if the user has entered input
  bool showNoMatchingPatientMessage = false;

  String? gender = '';
  File? _pickedImage;
  String previousSearchInput = '';
  String? _newPatientMobileError;

  @override
  void initState() {
    super.initState();
    _patientService = PatientService(widget.clinicId, widget.doctorId);
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

  void handleSearchInput(String userInput) async {
    // Store user search input (reintroduce this logic)
    setState(() {
      if (_isNumeric(userInput)) {
        _userMobileInput = userInput;
        _patientMobileController.text =
            _userMobileInput; // Pre-populate mobile field
        _patientNameController.text = ''; // Clear the name field
      } else {
        _userNameInput = userInput;
        _patientNameController.text = _userNameInput; // Pre-populate name field
        _patientMobileController.text = ''; // Clear the mobile field
      }
    });

    // Clear previous search results
    setState(() {
      matchingPatients.clear();
    });

    try {
      // Use getPatientsBySearch from PatientService to fetch matching patients
      List<Patient> fetchedPatients =
          //await widget.patientService.getPatientsBySearch(userInput);
          await _patientService.getPatientsBySearch(userInput);

      setState(() {
        matchingPatients =
            fetchedPatients; // Update state with the fetched patients
      });
    } catch (e) {
      // Handle errors (optional)
      devtools.log('Error searching for patients: $e');
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
  //
  //####################################################################################//
  // START OF handleSelectedPatient Function//
  void handleSelectedPatient(Patient patient) {
    devtools.log('Welcome to handleSelectedPatient');
    //widget.patientService.incrementSearchCount(patient.patientId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreatmentLandingScreen(
          clinicId: widget.clinicId,
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
          patientId: patient.patientId,
          patientName: patient.patientName,
          patientMobileNumber: patient.patientMobileNumber,
          age: patient.age,
          gender: patient.gender,
          patientPicUrl: patient.patientPicUrl,
          uhid: patient.uhid,
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
  // function below push the patient picture to the backend //
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
      final int age = int.tryParse(_ageController.text) ?? 0;
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

        if (newPatient != null) {
          // ignore: use_build_context_synchronously
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessPatient(
                clinicId: widget.clinicId,
                doctorId: widget.doctorId,
                patientId: newPatient['patientId'],
                age: newPatient['age'],
                gender: newPatient['gender'],
                patientName: newPatient['patientName'],
                patientMobileNumber: newPatient['patientMobileNumber'],
                patientPicUrl: newPatient['patientPicUrl'] ?? '',
                doctorName: widget.doctorName,
                uhid: newPatient['uhid'] ?? '',
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
        devtools.log(
            'After execution of SuccessPatient previousSearchInput is $previousSearchInput');
        devtools.log(
            'After execution of SuccessPatient _searchController.text is ${_searchController.text}');
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

  // Modify the fetchAndDisplayMatchingPatients function to use PatientService
  Future<List<Patient>> fetchAndDisplayMatchingPatients(
      String previousSearchInput) async {
    devtools.log('Welcome to fetchAndDisplayMatchingPatients !');

    try {
      // Fetch patients through PatientService
      List<Patient> matchingPatients =
          // await widget.patientService.getPatientsBySearch(previousSearchInput);
          await _patientService.getPatientsBySearch(previousSearchInput);

      devtools.log(
          'This is coming from inside fetchAndDisplayMatchingPatients. matchingPatients are: $matchingPatients');

      return matchingPatients;
    } catch (e) {
      devtools.log('Error fetching patients through PatientService: $e');
      return [];
    }
  }

  //END OF fetchAndDisplayMatchingPatients FUNCTION//
  //###########################################################################//

  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
  // START OF buildAddNewPatientUI WIDGET //
  Widget buildAddNewPatientUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          //'Patient', // Update the title to reflect the current screen
          widget.appBarTitle,
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Instead of popping the context, rebuild the search UI
            rebuildSearchUI(); // You need to define this function
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
                  //padding: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
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
//********************************************************************************* *//
//
//********************************************************************************* */
// START OF buildSearchUI WIDGET //
  Widget buildSearchUI() {
    devtools
        .log('Welcome to buildSearchUI. addingNewPatient is $addingNewPatient');
    devtools.log('_searchController.text is ${_searchController.text}');
    devtools.log('hasUserInput is $hasUserInput');
    devtools.log('previousSearchInput is $previousSearchInput');
    devtools.log('matchingPatients is $matchingPatients');

    if (_searchController.text.isEmpty && !addingNewPatient && !hasUserInput) {
      previousSearchInput = '';
      matchingPatients.clear();
      devtools.log(
          'previousSearchInput inside if statement is $previousSearchInput');
      devtools.log('and matchingPatients is $matchingPatients');
      // If search input is empty and we are not adding a new patient and there's no user input,
      // render the default search UI
      return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Patient'),
        //   // App bar configurations...
        // ),

        appBar: AppBar(
          // title: const Text(
          //   'Patient',
          // ),
          title: Text(
            widget.appBarTitle,
            style: MyTextStyle.textStyleMap['title-large']
                ?.copyWith(color: MyColors.colorPalette['on-surface']),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close), // Replace the close icon here
            onPressed: () {
              setState(() {
                // Reset any state variables or clear any data related to search
                // and return to the previous screen
                // Example:
                addingNewPatient = false;
                _searchController.clear(); // Clear the search text field
                // Additional state resets if needed
                // Navigate back to the previous screen
                Navigator.pop(context);
              });
            },
          ),
          // Other app bar configurations...
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
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
      if (previousSearchInput.isNotEmpty) {
        return Scaffold(
          // appBar: AppBar(
          //   title: const Text('Patient'),
          //   // App bar configurations...
          // ),
          appBar: AppBar(
            //title: const Text('Patient'),
            title: Text(
              widget.appBarTitle,
              style: MyTextStyle.textStyleMap['title-large']
                  ?.copyWith(color: MyColors.colorPalette['on-surface']),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close), // Replace the close icon here
              onPressed: () {
                setState(() {
                  // Reset any state variables or clear any data related to search
                  // and return to the previous screen
                  // Example:
                  addingNewPatient = false;
                  _searchController.clear(); // Clear the search text field
                  // Additional state resets if needed
                  // Navigate back to the previous screen
                  Navigator.pop(context);
                });
              },
            ),
            // Other app bar configurations...
          ),
          body: buildPreviousSearchUI(previousSearchInput),
        );
      } else {
        // Render the search UI with matching patients and Add New button
        return Scaffold(
          // appBar: AppBar(
          //   title: const Text('Patient'),
          //   // App bar configurations...
          // ),
          appBar: AppBar(
            //title: const Text('Patient'),
            title: Text(
              widget.appBarTitle,
              style: MyTextStyle.textStyleMap['title-large']
                  ?.copyWith(color: MyColors.colorPalette['on-surface']),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close), // Replace the close icon here
              onPressed: () {
                setState(() {
                  // Reset any state variables or clear any data related to search
                  // and return to the previous screen
                  // Example:
                  addingNewPatient = false;
                  _searchController.clear(); // Clear the search text field
                  // Additional state resets if needed
                  // Navigate back to the previous screen
                  Navigator.pop(context);
                });
              },
            ),
            // Other app bar configurations...
          ),
          body: Column(
            children: [
              Padding(
                //padding: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
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
              if (hasUserInput && matchingPatients.isNotEmpty) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      //padding: const EdgeInsets.all(8.0),
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
                                'Existing Patients',
                                style: MyTextStyle.textStyleMap['title-large']
                                    ?.copyWith(
                                        color: MyColors
                                            .colorPalette['on-surface']),
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                for (var patient in matchingPatients)
                                  InkWell(
                                    onTap: () {
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
                                                  colorBlendMode:
                                                      BlendMode.color,
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
                                        trailing: CircleAvatar(
                                          radius: 13.33,
                                          backgroundColor: MyColors
                                                  .colorPalette['surface'] ??
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
                                            color: MyColors
                                                .colorPalette['primary'],
                                          ),
                                          Text(
                                            'Add New',
                                            style: MyTextStyle
                                                .textStyleMap['label-large']
                                                ?.copyWith(
                                                    color:
                                                        MyColors.colorPalette[
                                                            'primary']),
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
                ),
              ] else if (hasUserInput && matchingPatients.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                  child: Column(
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
                        padding: const EdgeInsets.only(top: 8.0),
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
                ),
              ]
            ],
          ),
        );
      }
    }
  }

  // END OF buildSearchUI WIDGET //
  void rebuildSearchUI() {
    setState(() {
      // Set addingNewPatient to false to indicate that we're returning to the search UI
      addingNewPatient = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (addingNewPatient) {
      // Render the UI for adding a new patient
      return buildAddNewPatientUI();
    }

    return buildSearchUI();
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// ############################################################################//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/success_patient.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import '../firestore/patient_service.dart';
// import 'dart:developer' as devtools show log;

// class AddNewPatient extends StatefulWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;
//   final String appBarTitle;

//   const AddNewPatient({
//     super.key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//     required this.appBarTitle,
//   });

//   @override
//   State<AddNewPatient> createState() => AddNewPatientState();
// }

// class AddNewPatientState extends State<AddNewPatient> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _searchController = TextEditingController();

//   final TextEditingController _patientMobileController =
//       TextEditingController();
//   final TextEditingController _patientNameController = TextEditingController();
//   final TextEditingController _ageController = TextEditingController();
//   // Store user search input for mobile number and name
//   String _userMobileInput = '';
//   String _userNameInput = '';

//   List<Patient> matchingPatients = []; // Store matching patients

//   bool addingNewPatient = false; // Track if the user is adding a new patient
//   bool isAddingPatient = false; // Track if the patient is already being added

//   bool hasUserInput = false; // Track if the user has entered input
//   bool showNoMatchingPatientMessage = false;

//   String? gender = '';
//   File? _pickedImage;
//   String previousSearchInput = '';
//   String? _newPatientMobileError;

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

//   void handleSearchInput(String userInput) async {
//     // Store user search input (reintroduce this logic)
//     setState(() {
//       if (_isNumeric(userInput)) {
//         _userMobileInput = userInput;
//         _patientMobileController.text =
//             _userMobileInput; // Pre-populate mobile field
//         _patientNameController.text = ''; // Clear the name field
//       } else {
//         _userNameInput = userInput;
//         _patientNameController.text = _userNameInput; // Pre-populate name field
//         _patientMobileController.text = ''; // Clear the mobile field
//       }
//     });

//     // Clear previous search results
//     setState(() {
//       matchingPatients.clear();
//     });

//     try {
//       // Use getPatientsBySearch from PatientService to fetch matching patients
//       List<Patient> fetchedPatients =
//           await widget.patientService.getPatientsBySearch(userInput);

//       setState(() {
//         matchingPatients =
//             fetchedPatients; // Update state with the fetched patients
//       });
//     } catch (e) {
//       // Handle errors (optional)
//       devtools.log('Error searching for patients: $e');
//     }
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
//   //
//   //####################################################################################//
//   // START OF handleSelectedPatient Function//
//   void handleSelectedPatient(Patient patient) {
//     devtools.log('Welcome to handleSelectedPatient');
//     //widget.patientService.incrementSearchCount(patient.patientId);
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TreatmentLandingScreen(
//           clinicId: widget.clinicId,
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           patientId: patient.patientId,
//           patientName: patient.patientName,
//           patientMobileNumber: patient.patientMobileNumber,
//           age: patient.age,
//           gender: patient.gender,
//           patientPicUrl: patient.patientPicUrl,
//           uhid: patient.uhid,
//         ),
//       ),
//     );
//   }

//   // END OF handleSelectedPatient Function//
//   //####################################################################################//

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
//   // function below push the patient picture to the backend //
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
//       final int age = int.tryParse(_ageController.text) ?? 0;
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

//         if (newPatient != null) {
//           // ignore: use_build_context_synchronously
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SuccessPatient(
//                 clinicId: widget.clinicId,
//                 doctorId: widget.doctorId,
//                 patientId: newPatient['patientId'],
//                 age: newPatient['age'],
//                 gender: newPatient['gender'],
//                 patientName: newPatient['patientName'],
//                 patientMobileNumber: newPatient['patientMobileNumber'],
//                 patientPicUrl: newPatient['patientPicUrl'] ?? '',
//                 doctorName: widget.doctorName,
//                 uhid: newPatient['uhid'] ?? '',
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
//         devtools.log(
//             'After execution of SuccessPatient previousSearchInput is $previousSearchInput');
//         devtools.log(
//             'After execution of SuccessPatient _searchController.text is ${_searchController.text}');
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

//   // Modify the fetchAndDisplayMatchingPatients function to use PatientService
//   Future<List<Patient>> fetchAndDisplayMatchingPatients(
//       String previousSearchInput) async {
//     devtools.log('Welcome to fetchAndDisplayMatchingPatients !');

//     try {
//       // Fetch patients through PatientService
//       List<Patient> matchingPatients =
//           await widget.patientService.getPatientsBySearch(previousSearchInput);

//       devtools.log(
//           'This is coming from inside fetchAndDisplayMatchingPatients. matchingPatients are: $matchingPatients');

//       return matchingPatients;
//     } catch (e) {
//       devtools.log('Error fetching patients through PatientService: $e');
//       return [];
//     }
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
//           //'Patient', // Update the title to reflect the current screen
//           widget.appBarTitle,
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             // Instead of popping the context, rebuild the search UI
//             rebuildSearchUI(); // You need to define this function
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
//                   //padding: const EdgeInsets.all(8.0),
//                   padding: const EdgeInsets.only(
//                       left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
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
// //********************************************************************************* *//
// //
// //********************************************************************************* */
// // START OF buildSearchUI WIDGET //
//   Widget buildSearchUI() {
//     devtools
//         .log('Welcome to buildSearchUI. addingNewPatient is $addingNewPatient');
//     devtools.log('_searchController.text is ${_searchController.text}');
//     devtools.log('hasUserInput is $hasUserInput');
//     devtools.log('previousSearchInput is $previousSearchInput');
//     devtools.log('matchingPatients is $matchingPatients');

//     if (_searchController.text.isEmpty && !addingNewPatient && !hasUserInput) {
//       previousSearchInput = '';
//       matchingPatients.clear();
//       devtools.log(
//           'previousSearchInput inside if statement is $previousSearchInput');
//       devtools.log('and matchingPatients is $matchingPatients');
//       // If search input is empty and we are not adding a new patient and there's no user input,
//       // render the default search UI
//       return Scaffold(
//         // appBar: AppBar(
//         //   title: const Text('Patient'),
//         //   // App bar configurations...
//         // ),

//         appBar: AppBar(
//           // title: const Text(
//           //   'Patient',
//           // ),
//           title: Text(
//             widget.appBarTitle,
//             style: MyTextStyle.textStyleMap['title-large']
//                 ?.copyWith(color: MyColors.colorPalette['on-surface']),
//           ),
//           leading: IconButton(
//             icon: const Icon(Icons.close), // Replace the close icon here
//             onPressed: () {
//               setState(() {
//                 // Reset any state variables or clear any data related to search
//                 // and return to the previous screen
//                 // Example:
//                 addingNewPatient = false;
//                 _searchController.clear(); // Clear the search text field
//                 // Additional state resets if needed
//                 // Navigate back to the previous screen
//                 Navigator.pop(context);
//               });
//             },
//           ),
//           // Other app bar configurations...
//         ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(
//                   left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
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
//       if (previousSearchInput.isNotEmpty) {
//         return Scaffold(
//           // appBar: AppBar(
//           //   title: const Text('Patient'),
//           //   // App bar configurations...
//           // ),
//           appBar: AppBar(
//             //title: const Text('Patient'),
//             title: Text(
//               widget.appBarTitle,
//               style: MyTextStyle.textStyleMap['title-large']
//                   ?.copyWith(color: MyColors.colorPalette['on-surface']),
//             ),
//             leading: IconButton(
//               icon: const Icon(Icons.close), // Replace the close icon here
//               onPressed: () {
//                 setState(() {
//                   // Reset any state variables or clear any data related to search
//                   // and return to the previous screen
//                   // Example:
//                   addingNewPatient = false;
//                   _searchController.clear(); // Clear the search text field
//                   // Additional state resets if needed
//                   // Navigate back to the previous screen
//                   Navigator.pop(context);
//                 });
//               },
//             ),
//             // Other app bar configurations...
//           ),
//           body: buildPreviousSearchUI(previousSearchInput),
//         );
//       } else {
//         // Render the search UI with matching patients and Add New button
//         return Scaffold(
//           // appBar: AppBar(
//           //   title: const Text('Patient'),
//           //   // App bar configurations...
//           // ),
//           appBar: AppBar(
//             //title: const Text('Patient'),
//             title: Text(
//               widget.appBarTitle,
//               style: MyTextStyle.textStyleMap['title-large']
//                   ?.copyWith(color: MyColors.colorPalette['on-surface']),
//             ),
//             leading: IconButton(
//               icon: const Icon(Icons.close), // Replace the close icon here
//               onPressed: () {
//                 setState(() {
//                   // Reset any state variables or clear any data related to search
//                   // and return to the previous screen
//                   // Example:
//                   addingNewPatient = false;
//                   _searchController.clear(); // Clear the search text field
//                   // Additional state resets if needed
//                   // Navigate back to the previous screen
//                   Navigator.pop(context);
//                 });
//               },
//             ),
//             // Other app bar configurations...
//           ),
//           body: Column(
//             children: [
//               Padding(
//                 //padding: const EdgeInsets.all(8.0),
//                 padding: const EdgeInsets.only(
//                     left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
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
//               if (hasUserInput && matchingPatients.isNotEmpty) ...[
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       //padding: const EdgeInsets.all(8.0),
//                       padding: const EdgeInsets.only(
//                           left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Align(
//                             alignment: Alignment.topLeft,
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text(
//                                 'Existing Patients',
//                                 style: MyTextStyle.textStyleMap['title-large']
//                                     ?.copyWith(
//                                         color: MyColors
//                                             .colorPalette['on-surface']),
//                               ),
//                             ),
//                           ),
//                           SingleChildScrollView(
//                             child: Column(
//                               children: [
//                                 for (var patient in matchingPatients)
//                                   InkWell(
//                                     onTap: () {
//                                       handleSelectedPatient(patient);
//                                     },
//                                     child: Card(
//                                       child: ListTile(
//                                         leading: CircleAvatar(
//                                           radius: 24,
//                                           backgroundColor:
//                                               MyColors.colorPalette['surface'],
//                                           backgroundImage: patient
//                                                           .patientPicUrl !=
//                                                       null &&
//                                                   patient
//                                                       .patientPicUrl!.isNotEmpty
//                                               ? NetworkImage(
//                                                   patient.patientPicUrl!)
//                                               : Image.asset(
//                                                   'assets/images/default-image.png',
//                                                   color: MyColors
//                                                       .colorPalette['primary'],
//                                                   colorBlendMode:
//                                                       BlendMode.color,
//                                                 ).image,
//                                         ),
//                                         title: Text(
//                                           patient.patientName,
//                                           style: MyTextStyle
//                                               .textStyleMap['label-medium']
//                                               ?.copyWith(
//                                                   color: MyColors.colorPalette[
//                                                       'on_surface']),
//                                         ),
//                                         subtitle: Text(
//                                           '${patient.age}, ${patient.gender}, ${patient.patientMobileNumber}',
//                                           style: MyTextStyle
//                                               .textStyleMap['label-medium']
//                                               ?.copyWith(
//                                                   color: MyColors.colorPalette[
//                                                       'on_surface']),
//                                         ),
//                                         trailing: CircleAvatar(
//                                           radius: 13.33,
//                                           backgroundColor: MyColors
//                                                   .colorPalette['surface'] ??
//                                               Colors.blueAccent,
//                                           child: const Icon(
//                                             Icons.arrow_forward_ios_rounded,
//                                             size: 16,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Align(
//                                     alignment: Alignment.topLeft,
//                                     child: ElevatedButton(
//                                       style: ButtonStyle(
//                                         backgroundColor:
//                                             MaterialStateProperty.all(MyColors
//                                                 .colorPalette['on-primary']!),
//                                         shape: MaterialStateProperty.all(
//                                           RoundedRectangleBorder(
//                                             side: BorderSide(
//                                                 color: MyColors
//                                                     .colorPalette['primary']!,
//                                                 width: 1.0),
//                                             borderRadius:
//                                                 BorderRadius.circular(24.0),
//                                           ),
//                                         ),
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           addingNewPatient = true;
//                                           hasUserInput = false;
//                                           matchingPatients.clear();
//                                         });
//                                       },
//                                       child: Wrap(
//                                         children: [
//                                           Icon(
//                                             Icons.add,
//                                             color: MyColors
//                                                 .colorPalette['primary'],
//                                           ),
//                                           Text(
//                                             'Add New',
//                                             style: MyTextStyle
//                                                 .textStyleMap['label-large']
//                                                 ?.copyWith(
//                                                     color:
//                                                         MyColors.colorPalette[
//                                                             'primary']),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ] else if (hasUserInput && matchingPatients.isEmpty) ...[
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Align(
//                           alignment: Alignment.topLeft,
//                           child: Text(
//                             'No matching patient found',
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on_surface']),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Align(
//                           alignment: Alignment.topLeft,
//                           child: ElevatedButton(
//                             style: ButtonStyle(
//                               backgroundColor: MaterialStateProperty.all(
//                                   MyColors.colorPalette['on-primary']!),
//                               shape: MaterialStateProperty.all(
//                                 RoundedRectangleBorder(
//                                   side: BorderSide(
//                                       color: MyColors.colorPalette['primary']!,
//                                       width: 1.0),
//                                   borderRadius: BorderRadius.circular(24.0),
//                                 ),
//                               ),
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 addingNewPatient = true;
//                                 hasUserInput = false;
//                                 matchingPatients.clear();
//                                 //_searchController.text = '';
//                               });
//                             },
//                             child: Wrap(
//                               children: [
//                                 Icon(
//                                   Icons.add,
//                                   color: MyColors.colorPalette['primary'],
//                                 ),
//                                 Text(
//                                   'Add New',
//                                   style: MyTextStyle.textStyleMap['label-large']
//                                       ?.copyWith(
//                                           color:
//                                               MyColors.colorPalette['primary']),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ]
//             ],
//           ),
//         );
//       }
//     }
//   }

//   // END OF buildSearchUI WIDGET //
//   void rebuildSearchUI() {
//     setState(() {
//       // Set addingNewPatient to false to indicate that we're returning to the search UI
//       addingNewPatient = false;
//       _searchController.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (addingNewPatient) {
//       // Render the UI for adding a new patient
//       return buildAddNewPatientUI();
//     }

//     return buildSearchUI();
//   }
// }
