import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/treatment_service.dart';
import 'dart:developer' as devtools show log;
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/success_treatment.dart';

class ConsentWidget extends StatefulWidget {
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
  final String? treatmentId;

  const ConsentWidget({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.patientId,
    required this.age,
    required this.gender,
    required this.patientName,
    required this.patientMobileNumber,
    this.patientPicUrl,
    required this.doctorName,
    this.uhid,
    this.treatmentId,
  });

  @override
  State<ConsentWidget> createState() => _ConsentWidgetState();
}

class _ConsentWidgetState extends State<ConsentWidget> {
  bool isConsentTaken = false;

  late TreatmentService _treatmentService;

  @override
  void initState() {
    super.initState();
    _treatmentService = TreatmentService(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
    );
  }

  void updateConsent(bool newValue) async {
    final BuildContext currentContext = context;

    setState(() {
      isConsentTaken = newValue;
    });

    try {
      await _treatmentService.updateTreatment(
        treatmentId: widget.treatmentId!,
        chiefComplaint: '', // Assuming you pass actual data here
        oralExamination: [], // Assuming you pass actual data here
        procedures: [], // Assuming you pass actual data here
      );

      devtools.log('isConsentTaken updated successfully');

      if (mounted) {
        Navigator.of(currentContext).pushReplacement(
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
          ),
        );
      }
    } catch (error) {
      devtools.log('Error updating isConsentTaken: $error');
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text('Error updating consent: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Patient Consent'),
      content: const Text('Please confirm that the patient has given consent.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            updateConsent(true);
          },
          child: Text(
            'Confirm',
            style: MyTextStyle.textStyleMap['title-Small']
                ?.copyWith(color: MyColors.colorPalette['primary']),
          ),
        ),
      ],
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE WITH DIRECT BACKEND CALL
// import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/success_treatment.dart';

// class ConsentWidget extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String patientId;
//   final int age;
//   final String gender;
//   final String patientName;
//   final String patientMobileNumber;
//   final String? patientPicUrl;
//   final String doctorName;
//   final String? uhid;
//   final String? treatmentId;

//   const ConsentWidget({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.patientId,
//     required this.age,
//     required this.gender,
//     required this.patientName,
//     required this.patientMobileNumber,
//     this.patientPicUrl,
//     required this.doctorName,
//     this.uhid,
//     this.treatmentId,
//   });

//   @override
//   State<ConsentWidget> createState() => _ConsentWidgetState();
// }

// class _ConsentWidgetState extends State<ConsentWidget> {
//   bool isConsentTaken = false;

//   void updateConsent(bool newValue) async {
//     // Capture the context before the async operation
//     final BuildContext currentContext = context;

//     setState(() {
//       isConsentTaken = newValue;
//     });

//     try {
//       final clinicId = widget.clinicId;
//       final patientId = widget.patientId;
//       final treatmentId = widget.treatmentId;

//       final treatmentDocRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId)
//           .collection('treatments')
//           .doc(treatmentId);

//       await treatmentDocRef.update({'isConsentTaken': newValue});
//       devtools.log('isConsentTaken updated successfully');

//       // Ensure the context is still valid before navigating
//       if (mounted) {
//         Navigator.of(currentContext).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) => SuccessTreatment(
//               doctorId: widget.doctorId,
//               clinicId: widget.clinicId,
//               patientId: widget.patientId,
//               age: widget.age,
//               gender: widget.gender,
//               patientName: widget.patientName,
//               patientMobileNumber: widget.patientMobileNumber,
//               patientPicUrl: widget.patientPicUrl,
//               doctorName: widget.doctorName,
//               uhid: widget.uhid,
//               treatmentId: widget.treatmentId,
//             ),
//           ),
//         );
//       }
//     } catch (error) {
//       devtools.log('Error updating isConsentTaken: $error');
//       // Ensure the context is still valid before showing the snackbar
//       if (mounted) {
//         ScaffoldMessenger.of(currentContext).showSnackBar(
//           SnackBar(content: Text('Error updating consent: $error')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Patient Consent'),
//       content: const Text('Please confirm that the patient has given consent.'),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () {
//             updateConsent(true);
//           },
//           child: Text(
//             'Confirm',
//             style: MyTextStyle.textStyleMap['title-Small']
//                 ?.copyWith(color: MyColors.colorPalette['primary']),
//           ),
//         ),
//       ],
//     );
//   }
// }
