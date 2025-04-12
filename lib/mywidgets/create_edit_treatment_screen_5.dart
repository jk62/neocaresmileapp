//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neocaresmileapp/constants/routes.dart';
import 'package:neocaresmileapp/firestore/treatment_service.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/render_treatment_data.dart'; // Updated import
import 'package:neocaresmileapp/mywidgets/success_treatment.dart';
import 'dart:developer' as devtools show log;
import 'package:neocaresmileapp/mywidgets/treatment_landing_screen.dart';

class CreateEditTreatmentScreen5 extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String patientId;
  final int age;
  final String gender;
  final String patientName;
  final String patientMobileNumber;
  final String? patientPicUrl;
  final PageController pageController;
  final String? treatmentId;
  final String doctorName;
  final String? uhid;
  //final Map<String, dynamic>? pictureData;
  final List<Map<String, dynamic>> pictureData11;

  const CreateEditTreatmentScreen5({
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
    required this.treatmentId,
    required this.doctorName,
    required this.uhid,
    required this.pictureData11,
    //required this.pictureData,
  });

  @override
  State<CreateEditTreatmentScreen5> createState() =>
      _CreateEditTreatmentScreen5State();
}

class _CreateEditTreatmentScreen5State
    extends State<CreateEditTreatmentScreen5> {
  // Define a variable to hold the treatment data
  Map<String, dynamic>? treatmentData;
  bool isConsentTaken = false; // Step 1: Add the variable and initialize it
  late TreatmentService _treatmentService;

  @override
  void initState() {
    super.initState();
    _treatmentService = TreatmentService(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
    );

    // Call a function to fetch treatment data
    fetchTreatmentData();
  }

  // Future<void> fetchTreatmentData() async {
  //   devtools.log(
  //       '@@@@@@@@@@@@@@@@ Welcome to fetchTreatmentData defined inside CreateEditTreatmentScreen5 ! @@@@@@@@@@@@@@@@');
  //   try {
  //     final clinicId = widget.clinicId;
  //     final patientId = widget.patientId;
  //     final treatmentId = widget.treatmentId;

  //     // Reference to the treatments sub-collection
  //     final treatmentsRef = FirebaseFirestore.instance
  //         .collection('clinics')
  //         .doc(clinicId)
  //         .collection('patients')
  //         .doc(patientId)
  //         .collection('treatments');

  //     // Get the specific treatment document based on treatmentId
  //     final treatmentDoc = await treatmentsRef.doc(treatmentId).get();

  //     if (treatmentDoc.exists) {
  //       // Extract the treatment data
  //       final data = treatmentDoc.data() as Map<String, dynamic>;
  //       devtools.log(
  //           '@@@@@@@@@@@@@@. This is coming from inside fetchTreatmentData defined inside CreateEditTreatmentScreen5. treatment data fetched from backend is $data');

  //       setState(() {
  //         treatmentData = data; // Assign treatment data to the state variable
  //       });
  //       devtools.log(
  //           '******************** treatmentData fetched from backend is $treatmentData');
  //     } else {
  //       devtools.log('Treatment document with ID $treatmentId not found.');
  //     }
  //   } catch (error) {
  //     devtools.log('Error fetching treatment data: $error');
  //   }
  // }

  // void updateConsent(bool newValue) async {
  //   // Update the local state variable
  //   setState(() {
  //     isConsentTaken = newValue;
  //   });

  //   try {
  //     final clinicId = widget.clinicId;
  //     final patientId = widget.patientId;
  //     final treatmentId = widget.treatmentId;

  //     devtools.log(
  //         'Updating consent for clinicId: $clinicId, patientId: $patientId, treatmentId: $treatmentId');

  //     // Reference to the treatment document
  //     final treatmentDocRef = FirebaseFirestore.instance
  //         .collection('clinics')
  //         .doc(clinicId)
  //         .collection('patients')
  //         .doc(patientId)
  //         .collection('treatments')
  //         .doc(treatmentId);

  //     devtools.log('Reference to document: ${treatmentDocRef.path}');

  //     // Update the isConsentTaken field in the document
  //     await treatmentDocRef.update({'isConsentTaken': newValue});
  //     devtools.log('isConsentTaken updated successfully to $newValue');
  //   } catch (error) {
  //     devtools.log('Error updating isConsentTaken: $error');
  //     // Handle any errors that occur during the update
  //   }
  // }
  //------------------------------------------------------------------//
  Future<void> fetchTreatmentData() async {
    devtools.log('Fetching treatment data...');

    try {
      final data =
          await _treatmentService.fetchTreatmentData(widget.treatmentId!);

      if (data != null) {
        setState(() {
          treatmentData = data;
        });
      } else {
        devtools.log('No treatment data found.');
      }
    } catch (error) {
      devtools.log('Error fetching treatment data: $error');
    }
  }

  void updateConsent(bool newValue) async {
    setState(() {
      isConsentTaken = newValue;
    });

    try {
      await _treatmentService.updateConsent(widget.treatmentId!, newValue);
    } catch (error) {
      devtools.log('Error updating consent: $error');
    }
  }

  //-----------------------------------------------------------------//

  void handleNotIsConsentTaken() {
    devtools.log('Welcome to handleNotIsConsentTaken');

    //Navigator.push(
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => TreatmentLandingScreen(
          doctorId: widget.doctorId,
          clinicId: widget.clinicId,
          patientId: widget.patientId,
          age: widget.age,
          gender: widget.gender,
          patientName: widget.patientName,
          patientMobileNumber: widget.patientMobileNumber,
          patientPicUrl: widget.patientPicUrl,
          doctorName: widget.doctorName,
          uhid: widget.uhid,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  // --------------------------------------------------------------- //
  void _showPictureGallery() {
    // Implement your picture gallery overlay or screen navigation here
  }
  //-----------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    // Check if treatmentData is available
    if (treatmentData != null) {
      // Check if any procedures are selected in the treatment data
      bool hasProcedures = treatmentData!['procedures'] != null &&
          (treatmentData!['procedures'] as List).isNotEmpty;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.colorPalette['surface-container-lowest'],
          title: Text(
            'Treatment',
            style: MyTextStyle.textStyleMap['title-large']
                ?.copyWith(color: MyColors.colorPalette['on-surface']),
          ),
          iconTheme: IconThemeData(
            color: MyColors.colorPalette['on-surface'],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              handleNotIsConsentTaken();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      left: 16.0, top: 24.0, bottom: 24.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color:
                          MyColors.colorPalette['outline'] ?? Colors.blueAccent,
                    ),
                    borderRadius: BorderRadius.circular(3),
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
                                  style: MyTextStyle
                                      .textStyleMap['label-medium']
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

                // Render the treatment data
                RenderTreatmentData(
                  treatmentData: treatmentData,
                  onGalleryButtonPressed: _showPictureGallery,
                  pictureData: widget.pictureData11,
                ),

                if (hasProcedures)
                  Container(
                    decoration: BoxDecoration(
                      color: MyColors.colorPalette['outline-variant'],
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isConsentTaken,
                          activeColor: MyColors.colorPalette['primary'],
                          onChanged: (newValue) {
                            setState(() {
                              isConsentTaken = newValue ?? false;
                            });
                            updateConsent(isConsentTaken);
                          },
                        ),
                        Text(
                          'Consent taken',
                          style: MyTextStyle.textStyleMap['title-medium']
                              ?.copyWith(
                                  color: MyColors.colorPalette['secondary']),
                        ),
                      ],
                    ),
                  ),
                if (!hasProcedures)
                  Container(
                    decoration: BoxDecoration(
                      color: MyColors.colorPalette['outline-variant'],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.info, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Consent not required',
                          style: MyTextStyle.textStyleMap['title-medium']
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        //--------------------------------------------------------------------//

        // bottomNavigationBar: BottomNavigationBar(
        //   showSelectedLabels: false,
        //   showUnselectedLabels: false,
        //   backgroundColor: Colors.white,
        //   selectedItemColor: Colors.blue, // Always enable the button now
        //   items: <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(
        //       icon: ElevatedButton(
        //         onPressed: !hasProcedures ||
        //                 isConsentTaken // Enable button if no procedures or consent is taken
        //             ? () {
        //                 // Navigate to the Success widget when the button is pressed
        //                 // Navigator.of(context).push(
        //                 //   MaterialPageRoute(
        //                 //     builder: (context) => SuccessTreatment(
        //                 //       doctorId: widget.doctorId,
        //                 //       clinicId: widget.clinicId,
        //                 //       patientId: widget.patientId,
        //                 //       age: widget.age,
        //                 //       gender: widget.gender,
        //                 //       patientName: widget.patientName,
        //                 //       patientMobileNumber: widget.patientMobileNumber,
        //                 //       patientPicUrl: widget.patientPicUrl,
        //                 //       doctorName: widget.doctorName,
        //                 //       uhid: widget.uhid,
        //                 //       treatmentId: widget.treatmentId,
        //                 //     ),
        //                 //   ),
        //                 // );
        //                 Navigator.of(context).pushAndRemoveUntil(
        //                   MaterialPageRoute(
        //                     builder: (context) => SuccessTreatment(
        //                       doctorId: widget.doctorId,
        //                       clinicId: widget.clinicId,
        //                       patientId: widget.patientId,
        //                       age: widget.age,
        //                       gender: widget.gender,
        //                       patientName: widget.patientName,
        //                       patientMobileNumber: widget.patientMobileNumber,
        //                       patientPicUrl: widget.patientPicUrl,
        //                       doctorName: widget.doctorName,
        //                       uhid: widget.uhid,
        //                       treatmentId: widget.treatmentId,
        //                     ),
        //                   ),
        //                   (Route<dynamic> route) =>
        //                       false, // This removes all previous routes
        //                 );
        //               }
        //             : null, // Disabled only if procedures exist and consent is not taken
        //         style: ButtonStyle(
        //           fixedSize: MaterialStateProperty.all(const Size(152, 48)),
        //           backgroundColor: MaterialStateProperty.all(
        //             !hasProcedures || isConsentTaken
        //                 ? MyColors.colorPalette['primary'] ??
        //                     Colors.blue // Enabled color
        //                 : Colors.grey, // Disabled color
        //           ),
        //           shape: MaterialStateProperty.all(
        //             RoundedRectangleBorder(
        //               side: BorderSide(
        //                 color: MyColors.colorPalette['primary']!,
        //                 width: 1.0,
        //               ),
        //               borderRadius: BorderRadius.circular(24.0),
        //             ),
        //           ),
        //         ),
        //         child: Text(
        //           'Start Treatment',
        //           style: MyTextStyle.textStyleMap['label-large']
        //               ?.copyWith(color: MyColors.colorPalette['on-primary']),
        //         ),
        //       ),
        //       label: '',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Container(),
        //       label: '',
        //     ),
        //   ],
        //   currentIndex: 0,
        // ),
        //--------------------------------------------------------------------//
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: ElevatedButton(
                onPressed: !hasProcedures || isConsentTaken
                    ? () {
                        Navigator.of(context).popUntil((route) {
                          devtools.log(
                              'Route in stack before navigating to SuccessTreatment: ${route.settings.name}');
                          return true; // Log all routes
                        });

                        // Navigate to SuccessTreatment, keeping HomePage in the stack
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => SuccessTreatment(
                              doctorId: widget.doctorId,
                              clinicId: widget.clinicId,
                              patientId: widget.patientId,
                              age: widget.age,
                              gender: widget.gender,
                              patientName: widget.patientName,
                              patientMobileNumber: widget.patientMobileNumber,
                              patientPicUrl: widget.patientPicUrl,
                              doctorName: widget.doctorName,
                              uhid: widget.uhid,
                              treatmentId: widget.treatmentId,
                            ),
                            settings: const RouteSettings(
                                name: 'SuccessTreatment'),
                          ),
                          (Route<dynamic> route) =>
                              route.settings.name == homePageRoute,
                        );
                        Navigator.of(context).popUntil((route) {
                          devtools.log(
                              'Route in stack before navigating to SuccessTreatment: ${route.settings.name}');
                          return true; // Log all routes
                        });
                      }
                    : null,
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(const Size(152, 48)),
                  backgroundColor: MaterialStateProperty.all(
                    !hasProcedures || isConsentTaken
                        ? MyColors.colorPalette['primary'] ?? Colors.blue
                        : Colors.grey,
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
                child: Text(
                  'Start Treatment',
                  style: MyTextStyle.textStyleMap['label-large']
                      ?.copyWith(color: MyColors.colorPalette['on-primary']),
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Container(),
              label: '',
            ),
          ],
          currentIndex: 0,
        ),

        //--------------------------------------------------------------------//
      );
    } else {
      // If treatmentData is not available yet, display a loading indicator or handle the loading state.
      return const Center(
        child: CircularProgressIndicator(), // Display a loading indicator
      );
    }
  }
}
