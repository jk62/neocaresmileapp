import 'package:flutter/material.dart';
import 'package:neocaresmileapp/constants/routes.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/treatment_landing_screen.dart';
import 'dart:developer' as devtools show log;

class SuccessTreatment extends StatelessWidget {
  final String clinicId;
  final String doctorId;
  final String patientId;
  final String? treatmentId;

  final int age;
  final String gender;
  final String patientName;
  final String patientMobileNumber;
  final String? patientPicUrl;
  final String doctorName;
  final String? uhid;
  // final PageController pageController;
  // final Map<String, dynamic>? treatmentData;

  const SuccessTreatment({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.patientId,
    required this.treatmentId,
    required this.age,
    required this.gender,
    required this.patientName,
    required this.patientMobileNumber,
    required this.patientPicUrl,
    required this.doctorName,
    required this.uhid,

    // required this.pageController,
    // this.treatmentData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Teal circle icon with a white tick mark
            Container(
              width: 91, // Adjust the size as needed
              height: 91, // Adjust the size as needed
              decoration: BoxDecoration(
                color: MyColors.colorPalette['primary'], //Colors.teal,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: MyColors.colorPalette['on-primary'], //Colors.white,
                size: 72, // Adjust the size as needed
              ),
            ),
            const SizedBox(height: 20), // Add spacing

            // "Success" text
            Text(
              'Success',
              style: MyTextStyle.textStyleMap['display-medium']
                  ?.copyWith(color: MyColors.colorPalette['primary']),
            ),

            const SizedBox(height: 10), // Add spacing

            // "Treatment Started" text
            Text(
              'Treatment Started',
              style: MyTextStyle.textStyleMap['title-large']
                  ?.copyWith(color: MyColors.colorPalette['on-secondary']),
            ),

            const SizedBox(height: 40), // Add spacing

            // "Go to Treatment" button
            // ElevatedButton(
            //   onPressed: () {

            //     Navigator.pushReplacement(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => TreatmentLandingScreen(
            //           clinicId: clinicId,
            //           patientId: patientId,
            //           patientName: patientName,
            //           patientMobileNumber: patientMobileNumber,
            //           age: age,
            //           gender: gender,
            //           doctorId: doctorId,
            //           doctorName: doctorName,
            //           patientPicUrl: patientPicUrl,
            //           uhid: uhid,
            //         ),
            //       ),
            //     );
            //   },
            //   style: ButtonStyle(
            //     fixedSize: MaterialStateProperty.all(
            //         const Size(152, 48)), // Set fixed width and height
            //     backgroundColor:
            //         MaterialStateProperty.all(MyColors.colorPalette['primary']),
            //     foregroundColor: MaterialStateProperty.all(
            //         MyColors.colorPalette['on-primary']),
            //     padding: MaterialStateProperty.all(
            //       const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            //     ),
            //     shape: MaterialStateProperty.all(
            //       RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(30),
            //       ),
            //     ),
            //   ),
            //   child: Text(
            //     'Go to Treatment',
            //     style: MyTextStyle.textStyleMap['label-large']
            //         ?.copyWith(color: MyColors.colorPalette['on-primary']),
            //   ),
            // ),

            ElevatedButton(
              onPressed: () {
                // Log the navigator stack before navigating
                Navigator.of(context).popUntil((route) {
                  devtools.log(
                      'Route in stack before navigating: ${route.settings.name}');
                  return true; // Log all routes
                });

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TreatmentLandingScreen(
                      clinicId: clinicId,
                      patientId: patientId,
                      patientName: patientName,
                      patientMobileNumber: patientMobileNumber,
                      age: age,
                      gender: gender,
                      doctorId: doctorId,
                      doctorName: doctorName,
                      patientPicUrl: patientPicUrl,
                      uhid: uhid,
                    ),
                    settings: const RouteSettings(name: 'TreatmentLandingScreen'),
                  ),
                  (route) =>
                      route.settings.name ==
                      homePageRoute, // Keep HomePage in the stack
                );
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(const Size(152, 48)),
                backgroundColor:
                    MaterialStateProperty.all(MyColors.colorPalette['primary']),
                foregroundColor: MaterialStateProperty.all(
                    MyColors.colorPalette['on-primary']),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              child: Text(
                'Go to Treatment',
                style: MyTextStyle.textStyleMap['label-large']
                    ?.copyWith(color: MyColors.colorPalette['on-primary']),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
