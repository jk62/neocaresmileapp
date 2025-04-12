import 'package:flutter/material.dart';
import 'package:neocaresmileapp/home_page.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;

class SuccessAppointmentCurrentPatient extends StatelessWidget {
  final String clinicId;
  final String doctorId;
  final String patientId;

  const SuccessAppointmentCurrentPatient({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.patientId,
  });

//   @override
//   State<SuccessAppointment> createState() => _SuccessAppointmentState();
// }

// class _SuccessAppointmentState extends State<SuccessAppointment> {

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
              'Appointment Created',
              style: MyTextStyle.textStyleMap['title-large']
                  ?.copyWith(color: MyColors.colorPalette['secondary']),
            ),

            const SizedBox(height: 40), // Add spacing

            // "Go to Treatment" button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              //------------------//

              //------------------//
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
