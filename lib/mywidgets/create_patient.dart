// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/success_patient.dart';
// import '../firestore/patient_service.dart';
// import 'dart:developer' as devtools show log;

// class CreatePatient extends StatefulWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final String userInput;
//   final Function(Map<String, dynamic>?) updateNewAddedPatient;

//   const CreatePatient({
//     super.key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.userInput,
//     required this.updateNewAddedPatient,
//   });

//   @override
//   State<CreatePatient> createState() => _CreatePatientState();
// }

// class _CreatePatientState extends State<CreatePatient> {
//   final TextEditingController _patientMobileController =
//       TextEditingController();
//   final TextEditingController _patientNameController = TextEditingController();
//   final TextEditingController _ageController = TextEditingController();
//   //Map<String, dynamic>? selectedPatient;
//   Map<String, dynamic>? newAddedPatient;
//   String patientName = '';
//   int age = 0;
//   String gender = '';
//   String patientMobileNumber = '';

//   File? _pickedImage;
//   bool addingNewPatient = false; // Track if the user is adding a new patient
//   bool isAddingPatient = false; // Track if the patient is already being added

//   @override
//   void initState() {
//     super.initState();

//     if (isValidPhoneNumber(widget.userInput)) {
//       patientMobileNumber = widget.userInput;
//     } else {
//       patientName = widget.userInput;
//     }
//   }

//   //##############################################################################//
//   // START OF isValidPhoneNumber FUNCTION //
//   bool isValidPhoneNumber(String patientMobileNumber) {
//     bool containsOnlyDigits = RegExp(r'^[0-9]+$').hasMatch(patientMobileNumber);
//     bool isLengthValid = patientMobileNumber.trim().length >= 8;
//     return containsOnlyDigits && isLengthValid;
//   }

//   // END OF isValidPhoneNumber FUNCTION //
//   //##############################################################################//
//   //
//   //##############################################################################//
//   // START OF _showAlertDialog FUNCTION //
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

//   // END OF _showAlertDialog FUNCTION //
//   //##############################################################################//
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
//     }
//   }
//   // END OF _pickImage Function//
//   //####################################################################################//

//   // FUNCTION BELOW IS STABLE //
//   // void _addNewPatient() async {
//   //   devtools.log('Welcome to _addNewPatient');
//   //   try {
//   //     // Validate the required fields
//   //     if (_patientMobileController.text.trim().isEmpty ||
//   //         _patientNameController.text.trim().isEmpty ||
//   //         _ageController.text.trim().isEmpty ||
//   //         gender.isEmpty ||
//   //         (!isValidPhoneNumber(_patientMobileController.text))) {
//   //       _showAlertDialog(
//   //           'Invalid Input', 'Please fill in all required fields.');
//   //       return;
//   //     }

//   //     // Collect user input data
//   //     final String patientMobileNumber = _patientMobileController.text;
//   //     final String patientName = _patientNameController.text;
//   //     final int age = int.tryParse(_ageController.text) ?? 0;
//   //     final String selectedGender = gender;

//   //     // Add patient to Firestore
//   //     PatientService patientService =
//   //         PatientService(widget.clinicId, widget.doctorId);
//   //     String newPatientId = await patientService.addPatient(
//   //       patientName,
//   //       selectedGender,
//   //       age,
//   //       patientMobileNumber,
//   //       '',
//   //     );

//   //     if (newPatientId.isNotEmpty) {
//   //       // Fetch details of the new patient
//   //       Map<String, dynamic>? newPatient =
//   //           await patientService.getPatientById(newPatientId);

//   //       if (newPatient != null) {
//   //         // Navigate to the SuccessPatient screen
//   //         // ignore: use_build_context_synchronously
//   //         Navigator.push(
//   //           context,
//   //           MaterialPageRoute(
//   //             builder: (context) => SuccessPatient(
//   //               clinicId: widget.clinicId,
//   //               doctorId: widget.doctorId,
//   //               patientId: newPatient['patientId'],
//   //               age: newPatient['age'],
//   //               gender: newPatient['gender'],
//   //               patientName: newPatient['patientName'],
//   //               patientMobileNumber: newPatient['patientMobileNumber'],
//   //               patientPicUrl:
//   //                   '', // You may need to modify this based on your use case
//   //               doctorName: widget.doctorName,
//   //               uhid: '', // You may need to modify this based on your use case
//   //             ),
//   //           ),
//   //         );

//   //         // Callback function (if needed)
//   //         widget.updateNewAddedPatient(newPatient);
//   //       } else {
//   //         _showAlertDialog('Error', 'Failed to fetch new patient details.');
//   //       }
//   //     } else {
//   //       devtools.log('Error creating a new patient: newPatientId is empty');
//   //       _showAlertDialog('Error', 'Failed to create a new patient.');
//   //     }

//   //     // Clear the controllers and reset the UI
//   //     setState(() {
//   //       //_searchController.clear();
//   //       _patientMobileController.clear();
//   //       _patientNameController.clear();
//   //       _ageController.clear();
//   //       gender = '';
//   //     });

//   //     // Additional logic (if needed) for pushing patientData to the backend
//   //   } catch (error) {
//   //     // Handle unexpected errors
//   //     devtools.log('Unexpected error: $error');
//   //     _showAlertDialog('Error', 'An unexpected error occurred.');
//   //   }
//   // }

//   //###########################################################################//
//   // START OF _addNewPatient FUNCTION //
//   // function below push the patient picture to the backend //
//   void _addNewPatient() async {
//     devtools.log('Welcome to _addNewPatient');
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
//           // Navigate to the SuccessPatient screen
//           // ignore: use_build_context_synchronously
//           Navigator.push(
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

//           // Callback function (if needed)
//           //widget.updateNewAddedPatient(newPatient);
//         } else {
//           _showAlertDialog('Error', 'Failed to fetch new patient details.');
//         }
//       } else {
//         devtools.log('Error creating a new patient: newPatientId is empty');
//         _showAlertDialog('Error', 'Failed to create a new patient.');
//       }

//       // Clear the controllers and reset the UI
//       setState(() {
//         //_searchController.clear();
//         _patientMobileController.clear();
//         _patientNameController.clear();
//         _ageController.clear();
//         gender = '';
//         _pickedImage = null; // Reset picked image
//         //matchingPatients.clear();
//         //hasUserInput = false;
//         addingNewPatient = false;
//         isAddingPatient = false; // Reset the flag after adding patient
//       });

//       // Additional logic (if needed) for pushing patientData to the backend
//     } catch (error) {
//       // Handle unexpected errors
//       devtools.log('Unexpected error: $error');
//       _showAlertDialog('Error', 'An unexpected error occurred.');
//     }
//   }
//   //END OF _addNewPatient FUNCTION//
//   //################################################################################//

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to BuildContext CreatePatient');
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Create Patient',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         iconTheme: IconThemeData(
//           color: MyColors.colorPalette['on-surface'],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     'New Patient',
//                     style: MyTextStyle.textStyleMap['title-medium']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                 ),
//                 // Add TextFormField for patient mobile number
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         width: 1,
//                         color: MyColors.colorPalette['outline'] ??
//                             Colors.blueAccent,
//                         //color: Colors.blueAccent,
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: TextFormField(
//                             // Add your TextFormField properties here
//                             controller: _patientMobileController,
//                             decoration: InputDecoration(
//                               labelText: 'Patient Mobile Number',
//                               labelStyle: MyTextStyle
//                                   .textStyleMap['label-large']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-surface']),
//                             ),
//                             // Add any other properties or validation you need
//                           ),
//                         ),
//                         // Padding(
//                         //   padding: const EdgeInsets.all(8.0),
//                         //   child: Align(
//                         //     alignment: Alignment.topLeft,
//                         //     child: CircleAvatar(
//                         //       backgroundColor: MyColors.colorPalette['primary'],
//                         //       radius: 28,
//                         //       child: IconButton(
//                         //         icon: const Icon(Icons.camera_alt),
//                         //         iconSize: 32,
//                         //         onPressed: () {
//                         //           // Handle camera icon click here
//                         //           // You can open the camera or perform any other action
//                         //         },
//                         //       ),
//                         //     ),
//                         //   ),
//                         // ),

//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Align(
//                             alignment: Alignment.topLeft,
//                             child: CircleAvatar(
//                               backgroundColor: MyColors.colorPalette['primary'],
//                               radius: 28,
//                               child: _pickedImage != null
//                                   ? ClipRRect(
//                                       borderRadius: BorderRadius.circular(28),
//                                       child: Image.file(
//                                         _pickedImage!,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     )
//                                   : IconButton(
//                                       icon: const Icon(Icons.camera_alt),
//                                       iconSize: 32,
//                                       onPressed: () {
//                                         // Handle camera icon click here
//                                         // You can open the camera or perform any other action
//                                         _pickImage(); // Call the _pickImage method to open the camera
//                                       },
//                                     ),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: TextFormField(
//                             // Add your TextFormField properties here
//                             controller: _patientNameController,
//                             decoration: InputDecoration(
//                               labelText: 'Enter patient name here',
//                               labelStyle: MyTextStyle
//                                   .textStyleMap['label-large']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-surface']),
//                             ),
//                             // Add any other properties or validation you need
//                           ),
//                         ),
//                         // Add Checkbox for 2-digit age entry
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 40,
//                                 height: 40,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     width: 1,
//                                     color: MyColors.colorPalette[
//                                             'surface-container'] ??
//                                         Colors.black, //Colors.black,
//                                   ),
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: TextFormField(
//                                     controller: _ageController,
//                                     // Add your TextFormField properties here
//                                     decoration: InputDecoration(
//                                       //labelText: 'Enter patient age',
//                                       labelStyle: MyTextStyle
//                                           .textStyleMap['label-large']
//                                           ?.copyWith(
//                                               color: MyColors
//                                                   .colorPalette['on-surface']),
//                                     ),
//                                     // Add any other properties or validation you need
//                                   ),
//                                 ),
//                               ),
//                               Text(
//                                 'Years',
//                                 style: MyTextStyle.textStyleMap['label-medium']
//                                     ?.copyWith(
//                                         color: MyColors
//                                             .colorPalette['on-surface']),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Add Row with radio buttons for gender selection
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
//                                       setState(() {
//                                         if (value == 'male' ||
//                                             value == 'female') {
//                                           gender = value!;
//                                         } else {
//                                           // Set a default value or handle the case where the value is not valid
//                                           gender =
//                                               ''; // You can choose another default value if needed
//                                         }
//                                       });
//                                     },
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
//                                       setState(() {
//                                         if (value == 'male' ||
//                                             value == 'female') {
//                                           gender = value!;
//                                         } else {
//                                           // Set a default value or handle the case where the value is not valid
//                                           gender =
//                                               ''; // You can choose another default value if needed
//                                         }
//                                       });
//                                     },
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
//                         // Row with buttons
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: [
//                               // ElevatedButton
//                               ElevatedButton(
//                                 style: ButtonStyle(
//                                   backgroundColor: MaterialStateProperty.all(
//                                       MyColors.colorPalette['primary']!),
//                                   shape: MaterialStateProperty.all(
//                                     RoundedRectangleBorder(
//                                       side: BorderSide(
//                                           color:
//                                               MyColors.colorPalette['primary']!,
//                                           width: 1.0),
//                                       borderRadius: BorderRadius.circular(
//                                           24.0), // Adjust the radius as needed
//                                     ),
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   // Handle the press of the ElevatedButton
//                                   _addNewPatient(); // Invoke the _addNewPatient function
//                                 },
//                                 child: const Text('Add'),
//                               ),

//                               // Spacer to add space between buttons
//                               const Spacer(),

//                               // Cancel TextButton
//                               TextButton(
//                                 onPressed: () {
//                                   // Handle the press of the TextButton
//                                 },
//                                 child: const Text('Cancel'),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//********** */
// void _addNewPatient(BuildContext context) async {
  //   if (patientName.trim().isEmpty ||
  //       age <= 0 ||
  //       gender.trim().isEmpty ||
  //       (!isValidPhoneNumber(patientMobileNumber) &&
  //           patientMobileNumber.trim().isEmpty)) {
  //     _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
  //     return;
  //   }

  //   PatientService patientService =
  //       PatientService(widget.clinicId, widget.doctorId);
  //   String newPatientId = await patientService.addPatient(
  //     patientName,
  //     gender,
  //     age,
  //     patientMobileNumber,
  //     '',
  //   );

  //   if (newPatientId.isNotEmpty) {
  //     Map<String, dynamic>? newPatient =
  //         await patientService.getPatientById(newPatientId);

  //     if (newPatient != null) {
  //       newPatient['patientId'] = newPatientId;

  //       // ignore: use_build_context_synchronously
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => SuccessPatient(
  //             clinicId: widget.clinicId,
  //             doctorId: widget.doctorId,
  //             patientId: newPatient['patientId'],
  //             age: newPatient['age'],
  //             gender: newPatient['gender'],
  //             patientName: newPatient['patientName'],
  //             patientMobileNumber: newPatient['patientMobileNumber'],
  //             patientPicUrl:
  //                 '', // You may need to modify this based on your use case
  //             doctorName: widget.doctorName ?? '',
  //             uhid: '', // You may need to modify this based on your use case
  //           ),
  //         ),
  //       );

  //       // Now, invoke the callback function after navigation
  //       widget.updateNewAddedPatient(newPatient);
  //     } else {
  //       _showAlertDialog('Error', 'Failed to fetch new patient details.');
  //     }
  //   } else {
  //     devtools.log('Error creating a new patient: newPatientId is empty');
  //     _showAlertDialog('Error', 'Failed to create a new patient.');
  //   }
  // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Create New Patient',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         iconTheme: IconThemeData(
//           color: MyColors.colorPalette['on-surface'],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextFormField(
//               decoration: const InputDecoration(labelText: 'Patient Name'),
//               initialValue: patientName,
//               onChanged: (value) {
//                 setState(() {
//                   patientName = value;
//                 });
//               },
//             ),
//             TextFormField(
//               decoration: const InputDecoration(labelText: 'Age'),
//               initialValue: age > 0 ? age.toString() : '',
//               keyboardType: TextInputType.number,
//               onChanged: (value) {
//                 setState(() {
//                   age = int.tryParse(value) ?? 0;
//                 });
//               },
//             ),
//             TextFormField(
//               decoration: const InputDecoration(labelText: 'Gender'),
//               initialValue: gender,
//               onChanged: (value) {
//                 setState(() {
//                   gender = value;
//                 });
//               },
//             ),
//             TextFormField(
//               decoration: const InputDecoration(labelText: 'Mobile Number'),
//               initialValue: patientMobileNumber,
//               onChanged: (value) {
//                 setState(() {
//                   patientMobileNumber = value;
//                 });
//               },
//             ),

//             // Camera Icon for taking a picture
//             IconButton(
//               icon: const Icon(Icons.camera),
//               onPressed: _pickImage,
//             ),

//             // Display the picked image if available
//             if (_pickedImage != null) ...[
//               const SizedBox(height: 16.0),
//               Image.file(
//                 _pickedImage!,
//                 height: 100.0,
//               ),
//             ],
//             ElevatedButton(
//               onPressed: () {
//                 _addNewPatient(context);
//               },
//               child: const Text('Add Patient'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// }


//*********** */


//   void _addNewPatient(BuildContext context) async {
//     if (patientName.trim().isEmpty ||
//         age <= 0 ||
//         gender.trim().isEmpty ||
//         (!isValidPhoneNumber(patientMobileNumber) &&
//             patientMobileNumber.trim().isEmpty)) {
//       _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
//       return;
//     }

//     PatientService patientService =
//         PatientService(widget.clinicId, widget.doctorId);
//     String newPatientId = await patientService.addPatient(
//       patientName,
//       gender,
//       age,
//       patientMobileNumber,
//       '',
//     );

//     if (newPatientId.isNotEmpty) {
//       Map<String, dynamic>? newPatient =
//           await patientService.getPatientById(newPatientId);

//       if (newPatient != null) {
//         newPatient['patientId'] = newPatientId;
//         setState(() {
//           newAddedPatient = newPatient;
//         });

//         // ignore: use_build_context_synchronously
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SuccessPatient(
//               clinicId: widget.clinicId,
//               doctorId: widget.doctorId,
//               patientId: newPatient['patientId'],
//               age: newPatient['age'],
//               gender: newPatient['gender'],
//               patientName: newPatient['patientName'],
//               patientMobileNumber: newPatient['patientMobileNumber'],
//               patientPicUrl:
//                   '', // You may need to modify this based on your use case
//               doctorName: widget.doctorName ?? '',
//               uhid: '', // You may need to modify this based on your use case
//             ),
//           ),
//         );
//       } else {
//         _showAlertDialog('Error', 'Failed to fetch new patient details.');
//       }
//     } else {
//       devtools.log('Error creating a new patient: newPatientId is empty');
//       _showAlertDialog('Error', 'Failed to create a new patient.');
//     }
//   }
// }

// code below is stable
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/success_patient.dart';
// import '../firestore/patient_service.dart';
// import 'dart:developer' as devtools show log;

// class CreatePatient extends StatefulWidget {
//   final String doctorId;
//   final String clinicId;
//   final String? doctorName;
//   final String userInput;
//   final Function(Map<String, dynamic>?) updateNewAddedPatient;

//   const CreatePatient({
//     Key? key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.userInput,
//     required this.updateNewAddedPatient,
//   }) : super(key: key);

//   @override
//   State<CreatePatient> createState() => _CreatePatientState();
// }

// class _CreatePatientState extends State<CreatePatient> {
//   //Map<String, dynamic>? selectedPatient;
//   Map<String, dynamic>? newAddedPatient;
//   String patientName = '';
//   int age = 0;
//   String gender = '';
//   String patientMobileNumber = '';

//   File? _pickedImage;

//   @override
//   void initState() {
//     super.initState();

//     if (isValidPhoneNumber(widget.userInput)) {
//       patientMobileNumber = widget.userInput;
//     } else {
//       patientName = widget.userInput;
//     }
//   }

//   bool isValidPhoneNumber(String patientMobileNumber) {
//     bool containsOnlyDigits = RegExp(r'^[0-9]+$').hasMatch(patientMobileNumber);
//     bool isLengthValid = patientMobileNumber.trim().length >= 8;
//     return containsOnlyDigits && isLengthValid;
//   }

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

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedImage = await picker.pickImage(source: ImageSource.camera);

//     if (pickedImage != null) {
//       setState(() {
//         _pickedImage = File(pickedImage.path);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Create New Patient',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         iconTheme: IconThemeData(
//           color: MyColors.colorPalette['on-surface'],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextFormField(
//               decoration: const InputDecoration(labelText: 'Patient Name'),
//               initialValue: patientName,
//               onChanged: (value) {
//                 setState(() {
//                   patientName = value;
//                 });
//               },
//             ),
//             TextFormField(
//               decoration: const InputDecoration(labelText: 'Age'),
//               initialValue: age > 0 ? age.toString() : '',
//               keyboardType: TextInputType.number,
//               onChanged: (value) {
//                 setState(() {
//                   age = int.tryParse(value) ?? 0;
//                 });
//               },
//             ),
//             TextFormField(
//               decoration: const InputDecoration(labelText: 'Gender'),
//               initialValue: gender,
//               onChanged: (value) {
//                 setState(() {
//                   gender = value;
//                 });
//               },
//             ),
//             TextFormField(
//               decoration: const InputDecoration(labelText: 'Mobile Number'),
//               initialValue: patientMobileNumber,
//               onChanged: (value) {
//                 setState(() {
//                   patientMobileNumber = value;
//                 });
//               },
//             ),

//             // Camera Icon for taking a picture
//             IconButton(
//               icon: const Icon(Icons.camera),
//               onPressed: _pickImage,
//             ),

//             // Display the picked image if available
//             if (_pickedImage != null) ...[
//               const SizedBox(height: 16.0),
//               Image.file(
//                 _pickedImage!,
//                 height: 100.0,
//               ),
//             ],
//             ElevatedButton(
//               onPressed: () {
//                 _addNewPatient(context);
//               },
//               child: const Text('Add Patient'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _addNewPatient(BuildContext context) async {
//     if (patientName.trim().isEmpty ||
//         age <= 0 ||
//         gender.trim().isEmpty ||
//         (!isValidPhoneNumber(patientMobileNumber) &&
//             patientMobileNumber.trim().isEmpty)) {
//       _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
//       return;
//     }

//     PatientService patientService =
//         PatientService(widget.clinicId, widget.doctorId);
//     String newPatientId = await patientService.addPatient(
//       patientName,
//       gender,
//       age,
//       patientMobileNumber,
//       '',
//     );

//     if (newPatientId.isNotEmpty) {
//       Map<String, dynamic>? newPatient =
//           await patientService.getPatientById(newPatientId);

//       if (newPatient != null) {
//         newPatient['patientId'] = newPatientId;
//         setState(() {
//           newAddedPatient = newPatient;
//         });

//         // ignore: use_build_context_synchronously
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SuccessPatient(
//               clinicId: widget.clinicId,
//               doctorId: widget.doctorId,
//               patientId: newPatient['patientId'],
//               age: newPatient['age'],
//               gender: newPatient['gender'],
//               patientName: newPatient['patientName'],
//               patientMobileNumber: newPatient['patientMobileNumber'],
//               patientPicUrl:
//                   '', // You may need to modify this based on your use case
//               doctorName: widget.doctorName ?? '',
//               uhid: '', // You may need to modify this based on your use case
//             ),
//           ),
//         );

//         // _showNewAddedPatientDialog(
//         //   'New Added Patient',
//         //   'ID: ${newPatient['patientId']}Name: ${newPatient['patientName']}\nAge: ${newPatient['age']}\nGender: ${newPatient['gender']}\nMobile: ${newPatient['patientMobileNumber']}',
//         //   () {
//         //     setState(() {
//         //       newAddedPatient = newPatient;
//         //     });

//         //     widget.updateNewAddedPatient(newAddedPatient);
//         //     Navigator.pop(context, newAddedPatient);
//         //   },
//         // );
//       } else {
//         _showAlertDialog('Error', 'Failed to fetch new patient details.');
//       }
//     } else {
//       devtools.log('Error creating a new patient: newPatientId is empty');
//       _showAlertDialog('Error', 'Failed to create a new patient.');
//     }
//   }

//   // void _showNewAddedPatientDialog(
//   //     String title, String content, VoidCallback onDialogClose) {
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) => AlertDialog(
//   //       title: Text(title),
//   //       content: Text(content),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () {
//   //             Navigator.pop(context);
//   //             onDialogClose();
//   //           },
//   //           child: const Text('OK'),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
// }
