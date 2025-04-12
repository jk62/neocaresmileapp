import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

import 'dart:developer' as devtools show log;

class SuccessPatient extends StatelessWidget {
  final String clinicId;
  final String doctorId;
  final String patientId;
  final int age;
  final String gender;
  final String patientName;
  final String patientMobileNumber;
  final String? patientPicUrl;
  final String doctorName;
  final String? uhid;

  const SuccessPatient({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.patientId,
    required this.age,
    required this.gender,
    required this.patientName,
    required this.patientMobileNumber,
    required this.patientPicUrl,
    required this.doctorName,
    required this.uhid,
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

            Text(
              'Patient Added',
              style: MyTextStyle.textStyleMap['title-large']
                  ?.copyWith(color: MyColors.colorPalette['secondary']),
            ),

            const SizedBox(height: 40), // Add spacing

            // "Go to Treatment" button
            ElevatedButton(
              onPressed: () {
                // Use Navigator.pop to go back to the previous screen
                Navigator.pop(context);
              },
              style: ButtonStyle(
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
                'Ok',
                style: MyTextStyle.textStyleMap['title-large']
                    ?.copyWith(color: MyColors.colorPalette['on-primary']),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
