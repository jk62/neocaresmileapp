import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

import 'dart:developer' as devtools show log;

import 'package:neocaresmileapp/mywidgets/patient.dart';
import 'package:neocaresmileapp/mywidgets/ui_book_appointment_for_new_patient.dart';

class UISuccessPatientAddedForAppointment extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  final String clinicId;
  final PatientService patientService;
  final String? selectedSlot;
  final DateTime selectedDate;
  final Patient? newlyAddedPatient;
  final List<Map<String, dynamic>> slotsForSelectedDayList;

  const UISuccessPatientAddedForAppointment({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
    required this.patientService,
    required this.selectedSlot,
    required this.selectedDate,
    required this.newlyAddedPatient,
    required this.slotsForSelectedDayList,
  });

  @override
  Widget build(BuildContext context) {
    devtools.log(
        'Welcome to UISuccessPatientAddedForAppointment. widget.newlyAddedPatient is $newlyAddedPatient');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 91,
              height: 91,
              decoration: BoxDecoration(
                color: MyColors.colorPalette['primary'],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: MyColors.colorPalette['on-primary'],
                size: 72,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Success',
              style: MyTextStyle.textStyleMap['display-medium']
                  ?.copyWith(color: MyColors.colorPalette['primary']),
            ),
            const SizedBox(height: 10),
            Text(
              'Patient Added',
              style: MyTextStyle.textStyleMap['title-large']
                  ?.copyWith(color: MyColors.colorPalette['secondary']),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UIBookAppointmentForNewPatient(
                      doctorId: doctorId,
                      doctorName: doctorName,
                      clinicId: clinicId,
                      patientService: patientService,
                      selectedSlot: selectedSlot,
                      selectedDate: selectedDate,
                      addedPatient: newlyAddedPatient,
                      slotsForSelectedDayList: slotsForSelectedDayList,
                    ),
                  ),
                );
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
