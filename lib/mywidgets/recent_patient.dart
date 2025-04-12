import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/appointment_provider.dart';
import 'package:provider/provider.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/search_and_display_all_patients.dart';
import 'package:neocaresmileapp/mywidgets/treatment_landing_screen.dart';
import 'recent_patient_provider.dart';
import 'dart:developer' as devtools show log;

// class RecentPatient extends StatelessWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const RecentPatient({
//     super.key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   });

//   void logNavigatorStack(BuildContext context) {
//     Navigator.popUntil(context, (route) {
//       devtools.log('Route in stack: ${route.settings.name}');
//       return true; // This allows the function to iterate through all routes
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<RecentPatientProvider>(context);
//     devtools.log('**** Welcome to build widget of RecentPatient !');

//     if (provider.isLoading) {
//       return const CircularProgressIndicator();
//     }

//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       'Recent Patients',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                         color: MyColors.colorPalette['on_surface'],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => SearchAndDisplayAllPatients(
//                         clinicId: clinicId,
//                         doctorId: doctorId,
//                         doctorName: doctorName,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     'View More',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: MyColors.colorPalette['on-surface-variant'],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Align(
//             alignment: Alignment.topLeft,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Padding(
//                 padding: const EdgeInsets.all(30.0),
//                 child: Row(
//                   children: [
//                     for (final patientInfo in provider.recentPatients.take(4))
//                       Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: GestureDetector(
//                           onTap: () {
//                             logNavigatorStack(
//                                 context); // Log the stack before navigating
//                             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => TreatmentLandingScreen(
//                                   clinicId: clinicId,
//                                   doctorId: doctorId,
//                                   doctorName: doctorName,
//                                   patientId: patientInfo['patientId'],
//                                   patientName: patientInfo['patientName'],
//                                   patientMobileNumber:
//                                       patientInfo['patientMobileNumber'],
//                                   age: patientInfo['age'],
//                                   gender: patientInfo['gender'],
//                                   patientPicUrl: patientInfo['patientPicUrl'],
//                                   uhid: patientInfo['uhid'],
//                                 ),
//                                 settings: const RouteSettings(
//                                     name: 'TreatmentLandingScreen'),
//                               ),
//                             );
//                           },
//                           onLongPress: () async {
//                             final scaffoldMessenger =
//                                 ScaffoldMessenger.of(context);

//                             // Capture AppointmentProvider before the async call
//                             final appointmentProvider =
//                                 Provider.of<AppointmentProvider>(context,
//                                     listen: false);

//                             final shouldDelete = await _confirmDelete(
//                                 context, patientInfo['patientName']);

//                             if (shouldDelete) {
//                               try {
//                                 // Call deletePatient without passing the BuildContext after the async gap
//                                 await provider.deletePatient(
//                                     patientInfo['patientId'],
//                                     doctorName,
//                                     appointmentProvider);

//                                 scaffoldMessenger.showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                         'Patient ${patientInfo['patientName']} deleted'),
//                                   ),
//                                 );
//                               } catch (e) {
//                                 scaffoldMessenger.showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Error deleting patient'),
//                                   ),
//                                 );
//                               }
//                             }
//                           },
//                           child: Column(
//                             children: [
//                               CircleAvatar(
//                                 radius: 24,
//                                 backgroundColor:
//                                     MyColors.colorPalette['surface'],
//                                 backgroundImage: patientInfo['patientPicUrl'] !=
//                                             null &&
//                                         patientInfo['patientPicUrl'].isNotEmpty
//                                     ? NetworkImage(
//                                         patientInfo['patientPicUrl']!)
//                                     : Image.asset(
//                                         'assets/images/default-image.png',
//                                         color: MyColors.colorPalette['primary'],
//                                         colorBlendMode: BlendMode.color,
//                                       ).image,
//                               ),
//                               const SizedBox(
//                                 height: 8,
//                               ),
//                               Text(
//                                 patientInfo['patientName'],
//                                 style: MyTextStyle.textStyleMap['label-small']
//                                     ?.copyWith(
//                                   color: MyColors.colorPalette['on_surface'],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _confirmDelete(BuildContext context, String patientName) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Delete Patient'),
//           content: Text('Are you sure you want to delete $patientName?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//     return result ?? false;
//   }
// }
//---------------------------------------------------------------------------//
class RecentPatient extends StatelessWidget {
  final String doctorId;
  final String clinicId;
  final String doctorName;
  final PatientService patientService;
  final bool showViewMoreButton; // Add this property

  const RecentPatient({
    super.key,
    required this.doctorId,
    required this.clinicId,
    required this.doctorName,
    required this.patientService,
    this.showViewMoreButton = true, // Default to true
  });

  void logNavigatorStack(BuildContext context) {
    Navigator.popUntil(context, (route) {
      devtools.log('Route in stack: ${route.settings.name}');
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecentPatientProvider>(context);
    devtools.log('**** Welcome to build widget of RecentPatient !');

    if (provider.isLoading) {
      return const CircularProgressIndicator();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Recent Patients',
                      style: MyTextStyle.textStyleMap['title-large']?.copyWith(
                        color: MyColors.colorPalette['on_surface'],
                      ),
                    ),
                  ),
                ),
              ),
              // Only show "View More" button if the property is true
              if (showViewMoreButton)
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SearchAndDisplayAllPatients(
                          clinicId: clinicId,
                          doctorId: doctorId,
                          doctorName: doctorName,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'View More',
                      style: TextStyle(
                        fontSize: 14,
                        color: MyColors.colorPalette['on-surface-variant'],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Row(
                  children: [
                    for (final patientInfo in provider.recentPatients.take(4))
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () {
                            logNavigatorStack(context);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TreatmentLandingScreen(
                                  clinicId: clinicId,
                                  doctorId: doctorId,
                                  doctorName: doctorName,
                                  patientId: patientInfo['patientId'],
                                  patientName: patientInfo['patientName'],
                                  patientMobileNumber:
                                      patientInfo['patientMobileNumber'],
                                  age: patientInfo['age'],
                                  gender: patientInfo['gender'],
                                  patientPicUrl: patientInfo['patientPicUrl'],
                                  uhid: patientInfo['uhid'],
                                ),
                                settings: const RouteSettings(
                                    name: 'TreatmentLandingScreen'),
                              ),
                            );
                          },
                          onLongPress: () async {
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);

                            final appointmentProvider =
                                Provider.of<AppointmentProvider>(context,
                                    listen: false);

                            final shouldDelete = await _confirmDelete(
                                context, patientInfo['patientName']);

                            if (shouldDelete) {
                              try {
                                await provider.deletePatient(
                                    patientInfo['patientId'],
                                    doctorName,
                                    appointmentProvider);

                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Patient ${patientInfo['patientName']} deleted'),
                                  ),
                                );
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Error deleting patient'),
                                  ),
                                );
                              }
                            }
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    MyColors.colorPalette['surface'],
                                backgroundImage: patientInfo['patientPicUrl'] !=
                                            null &&
                                        patientInfo['patientPicUrl'].isNotEmpty
                                    ? NetworkImage(
                                        patientInfo['patientPicUrl']!)
                                    : Image.asset(
                                        'assets/images/default-image.png',
                                        color: MyColors.colorPalette['primary'],
                                        colorBlendMode: BlendMode.color,
                                      ).image,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                patientInfo['patientName'],
                                style: MyTextStyle.textStyleMap['label-small']
                                    ?.copyWith(
                                  color: MyColors.colorPalette['on_surface'],
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
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String patientName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Patient'),
          content: Text('Are you sure you want to delete $patientName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}


// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE WITHOUT LONG PRESS TO DELETE
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'recent_patient_provider.dart';

// class RecentPatient extends StatelessWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const RecentPatient({
//     Key? key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<RecentPatientProvider>(context);

//     if (provider.isLoading) {
//       return const CircularProgressIndicator();
//     }

//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       'Recent Patients',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                         color: MyColors.colorPalette['on_surface'],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => SearchAndDisplayAllPatients(
//                         clinicId: clinicId,
//                         doctorId: doctorId,
//                         doctorName: doctorName,
//                         patientService: patientService,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     'View More',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: MyColors.colorPalette['on-surface-variant'],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Align(
//             alignment: Alignment.topLeft,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Padding(
//                 padding: const EdgeInsets.all(30.0),
//                 child: Row(
//                   children: [
//                     for (final patientInfo in provider.recentPatients)
//                       Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: GestureDetector(
//                           onTap: () {
//                             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => TreatmentLandingScreen(
//                                   clinicId: clinicId,
//                                   doctorId: doctorId,
//                                   doctorName: doctorName,
//                                   patientId: patientInfo['patientId'],
//                                   patientName: patientInfo['patientName'],
//                                   patientMobileNumber:
//                                       patientInfo['patientMobileNumber'],
//                                   age: patientInfo['age'],
//                                   gender: patientInfo['gender'],
//                                   patientPicUrl: patientInfo['patientPicUrl'],
//                                   uhid: patientInfo['uhid'],
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Column(
//                             children: [
//                               CircleAvatar(
//                                 radius: 24,
//                                 backgroundColor:
//                                     MyColors.colorPalette['surface'],
//                                 backgroundImage: patientInfo['patientPicUrl'] !=
//                                             null &&
//                                         patientInfo['patientPicUrl'].isNotEmpty
//                                     ? NetworkImage(
//                                         patientInfo['patientPicUrl']!)
//                                     : Image.asset(
//                                         'assets/images/default-image.png',
//                                         color: MyColors.colorPalette['primary'],
//                                         colorBlendMode: BlendMode.color,
//                                       ).image,
//                               ),
//                               const SizedBox(
//                                 height: 8,
//                               ),
//                               Text(
//                                 patientInfo['patientName'],
//                                 style: MyTextStyle.textStyleMap['label-small']
//                                     ?.copyWith(
//                                   color: MyColors.colorPalette['on_surface'],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//-------------------------------------------------------------------------//

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'recent_patient_provider.dart'; // Import the RecentPatientProvider class

// class RecentPatient extends StatelessWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const RecentPatient({
//     Key? key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<RecentPatientProvider>(context);

//     if (provider.isLoading) {
//       return const CircularProgressIndicator();
//     }

//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       'Recent Patients',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                         color: MyColors.colorPalette['on_surface'],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => SearchAndDisplayAllPatients(
//                         clinicId: clinicId,
//                         doctorId: doctorId,
//                         doctorName: doctorName,
//                         patientService: patientService,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     'View More',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: MyColors.colorPalette['on-surface-variant'],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Align(
//             alignment: Alignment.topLeft,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Padding(
//                 padding: const EdgeInsets.all(30.0),
//                 child: Row(
//                   children: [
//                     for (final patientInfo in provider.recentPatients)
//                       Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => TreatmentLandingScreen(
//                                   clinicId: clinicId,
//                                   doctorId: doctorId,
//                                   doctorName: doctorName,
//                                   patientId: patientInfo['patientId'],
//                                   patientName: patientInfo['patientName'],
//                                   patientMobileNumber:
//                                       patientInfo['patientMobileNumber'],
//                                   age: patientInfo['age'],
//                                   gender: patientInfo['gender'],
//                                   patientPicUrl: patientInfo['patientPicUrl'],
//                                   uhid: patientInfo['uhid'],
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Column(
//                             children: [
//                               CircleAvatar(
//                                 radius: 24,
//                                 backgroundColor:
//                                     MyColors.colorPalette['surface'],
//                                 backgroundImage: patientInfo['patientPicUrl'] !=
//                                             null &&
//                                         patientInfo['patientPicUrl'].isNotEmpty
//                                     ? NetworkImage(
//                                         patientInfo['patientPicUrl']!)
//                                     : Image.asset(
//                                         'assets/images/default-image.png',
//                                         color: MyColors.colorPalette['primary'],
//                                         colorBlendMode: BlendMode.color,
//                                       ).image,
//                               ),
//                               const SizedBox(
//                                 height: 8,
//                               ),
//                               Text(
//                                 patientInfo['patientName'],
//                                 style: MyTextStyle.textStyleMap['label-small']
//                                     ?.copyWith(
//                                         color: MyColors
//                                             .colorPalette['on_surface']),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//---------------------------------------------------------//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'recent_patient_provider.dart'; // Import the RecentPatientProvider class

// class RecentPatient extends StatelessWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const RecentPatient({
//     Key? key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   }) : super(key: key);

  

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<RecentPatientProvider>(context);

//     if (provider.isLoading) {
//       return const CircularProgressIndicator();
//     }

//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       'Recent Patients',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                         color: MyColors.colorPalette['on_surface'],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => SearchAndDisplayAllPatients(
//                         clinicId: clinicId,
//                         doctorId: doctorId,
//                         doctorName: doctorName,
//                         patientService: patientService,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     'View More',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: MyColors.colorPalette['on-surface-variant'],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Align(
//             alignment: Alignment.topLeft,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Padding(
//                 padding: const EdgeInsets.all(30.0),
//                 child: Row(
//                   children: [
//                     for (final patientInfo in provider.recentPatients)
//                       Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => TreatmentLandingScreen(
//                                   clinicId: clinicId,
//                                   doctorId: doctorId,
//                                   doctorName: doctorName,
//                                   patientId: patientInfo['patientId'],
//                                   patientName: patientInfo['patientName'],
//                                   patientMobileNumber:
//                                       patientInfo['patientMobileNumber'],
//                                   age: patientInfo['age'],
//                                   gender: patientInfo['gender'],
//                                   patientPicUrl: patientInfo['patientPicUrl'],
//                                   uhid: patientInfo['uhid'],
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Column(
//                             children: [
//                               CircleAvatar(
//                                 radius: 24,
//                                 backgroundColor:
//                                     MyColors.colorPalette['surface'],
//                                 backgroundImage: patientInfo['patientPicUrl'] !=
//                                             null &&
//                                         patientInfo['patientPicUrl'].isNotEmpty
//                                     ? NetworkImage(
//                                         patientInfo['patientPicUrl']!)
//                                     : Image.asset(
//                                         'assets/images/default-image.png',
//                                         color: MyColors.colorPalette['primary'],
//                                         colorBlendMode: BlendMode.color,
//                                       ).image,
//                               ),
//                               const SizedBox(
//                                 height: 8,
//                               ),
//                               Text(
//                                 patientInfo['patientName'],
//                                 style: MyTextStyle.textStyleMap['label-small']
//                                     ?.copyWith(
//                                         color: MyColors
//                                             .colorPalette['on_surface']),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//--------------------------------------------------------------//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'recent_patient_provider.dart'; // Import the RecentPatientProvider class

// class RecentPatient extends StatelessWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const RecentPatient({
//     Key? key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => RecentPatientProvider(
//         doctorId: doctorId,
//         clinicId: clinicId,
//         patientService: patientService,
//       ),
//       child: Consumer<RecentPatientProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return const CircularProgressIndicator();
//           }

//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Align(
//                         alignment: Alignment.topLeft,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'Recent Patients',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                               color: MyColors.colorPalette['on_surface'],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => SearchAndDisplayAllPatients(
//                               clinicId: clinicId,
//                               doctorId: doctorId,
//                               doctorName: doctorName,
//                               patientService: patientService,
//                             ),
//                           ),
//                         );
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'View More',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: MyColors.colorPalette['on-surface-variant'],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Padding(
//                       padding: const EdgeInsets.all(30.0),
//                       child: Row(
//                         children: [
//                           for (final patientInfo in provider.recentPatients)
//                             Padding(
//                               padding: const EdgeInsets.all(10.0),
//                               child: GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           TreatmentLandingScreen(
//                                         clinicId: clinicId,
//                                         doctorId: doctorId,
//                                         doctorName: doctorName,
//                                         patientId: patientInfo['patientId'],
//                                         patientName: patientInfo['patientName'],
//                                         patientMobileNumber:
//                                             patientInfo['patientMobileNumber'],
//                                         age: patientInfo['age'],
//                                         gender: patientInfo['gender'],
//                                         patientPicUrl:
//                                             patientInfo['patientPicUrl'],
//                                         uhid: patientInfo['uhid'],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: Column(
//                                   children: [
//                                     CircleAvatar(
//                                       radius: 24,
//                                       backgroundColor:
//                                           MyColors.colorPalette['surface'],
//                                       backgroundImage:
//                                           patientInfo['patientPicUrl'] !=
//                                                       null &&
//                                                   patientInfo['patientPicUrl']
//                                                       .isNotEmpty
//                                               ? NetworkImage(
//                                                   patientInfo['patientPicUrl']!)
//                                               : Image.asset(
//                                                   'assets/images/default-image.png',
//                                                   color: MyColors
//                                                       .colorPalette['primary'],
//                                                   colorBlendMode:
//                                                       BlendMode.color,
//                                                 ).image,
//                                     ),
//                                     const SizedBox(
//                                       height: 8,
//                                     ),
//                                     Text(
//                                       patientInfo['patientName'],
//                                       style: MyTextStyle
//                                           .textStyleMap['label-small']
//                                           ?.copyWith(
//                                               color: MyColors
//                                                   .colorPalette['on_surface']),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// CODE BELOW STABLE BEFORE USE OF PROVIDER
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;

// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';

// class RecentPatient extends StatefulWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const RecentPatient({
//     Key? key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   }) : super(key: key);

//   @override
//   State<RecentPatient> createState() => _RecentPatientState();
// }

// class _RecentPatientState extends State<RecentPatient> {
//   @override
//   void initState() {
//     super.initState();

//     _fetchRecentPatients();
//   }

//   Future<List<Map<String, dynamic>>> _fetchRecentPatients() async {
//     devtools.log('_fetchRecentPatients invoked');
//     try {
//       final clinicRef =
//           FirebaseFirestore.instance.collection('clinics').doc(widget.clinicId);
//       final patientsQuerySnapshot = await clinicRef
//           .collection('patients')
//           .orderBy('searchCount', descending: true)
//           .limit(4)
//           .get();

//       final recentPatientsData = <Map<String, dynamic>>[];

//       for (final patientDoc in patientsQuerySnapshot.docs) {
//         final patientData = patientDoc.data();
//         if (patientData.isNotEmpty) {
//           recentPatientsData.add(patientData);
//         }
//       }

//       return recentPatientsData;
//     } catch (e) {
//       // Handle error
//       devtools.log('Error fetching recent patients: $e');
//       return []; // Return an empty list in case of an error
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       //future: _recentPatientsFuture,
//       future: _fetchRecentPatients(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         }

//         if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         }

//         final recentPatients = snapshot.data;
//         devtools.log(
//             'recentPatients fetched successfully which are $recentPatients');

//         if (recentPatients != null && recentPatients.isNotEmpty) {
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Align(
//                         alignment: Alignment.topLeft,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'Recent Patients',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['on_surface']),
//                           ),
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         // Handle View More button action
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => SearchAndDisplayAllPatients(
//                               clinicId: widget.clinicId,
//                               doctorId: widget.doctorId,
//                               doctorName: widget.doctorName,
//                               patientService: widget.patientService,
//                               //showBottomNavBar: widget.showBottomNavBar,
//                             ),
//                           ),
//                         );
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'View More',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: MyColors.colorPalette['on-surface-variant'],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Padding(
//                       padding: const EdgeInsets.all(30.0),
//                       child: Row(
//                         children: [
//                           for (final patientInfo in recentPatients)
//                             Row(
//                               children: [
//                                 Padding(
//                                   key: UniqueKey(),
//                                   padding: const EdgeInsets.all(10.0),
//                                   child: Row(
//                                     children: [
//                                       Column(
//                                         children: [
//                                           GestureDetector(
//                                             onTap: () {
//                                               Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       TreatmentLandingScreen(
//                                                     clinicId: widget.clinicId,
//                                                     doctorId: widget.doctorId,
//                                                     doctorName:
//                                                         widget.doctorName,
//                                                     patientId: patientInfo[
//                                                         'patientId'],
//                                                     patientName: patientInfo[
//                                                         'patientName'],
//                                                     patientMobileNumber:
//                                                         patientInfo[
//                                                             'patientMobileNumber'],
//                                                     age: patientInfo['age'],
//                                                     gender:
//                                                         patientInfo['gender'],
//                                                     patientPicUrl: patientInfo[
//                                                         'patientPicUrl'],
//                                                     uhid: patientInfo['uhid'],
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                             child: CircleAvatar(
//                                               radius: 24,
//                                               backgroundColor: MyColors
//                                                   .colorPalette['surface'],
//                                               backgroundImage: patientInfo[
//                                                               'patientPicUrl'] !=
//                                                           null &&
//                                                       patientInfo[
//                                                               'patientPicUrl']
//                                                           .isNotEmpty
//                                                   ? NetworkImage(patientInfo[
//                                                       'patientPicUrl']!)
//                                                   : Image.asset(
//                                                       'assets/images/default-image.png',
//                                                       color:
//                                                           MyColors.colorPalette[
//                                                               'primary'],
//                                                       colorBlendMode:
//                                                           BlendMode.color,
//                                                     ).image,
//                                             ),
//                                           ),
//                                           const SizedBox(
//                                             height: 8,
//                                           ),
//                                           Text(
//                                             patientInfo['patientName'],
//                                             style: MyTextStyle
//                                                 .textStyleMap['label-small']
//                                                 ?.copyWith(
//                                                     color:
//                                                         MyColors.colorPalette[
//                                                             'on_surface']),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(
//                                         width: 16,
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         } else {
//           return Container(); // Render an empty container when there are no recent patients
//         }
//       },
//     );
//   }
// }


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW IS STABLE BUT DO NOT RETURN FUTURE BUILDER AND USE CIRCULAR PROGRESS INDICATOR
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;

// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';

// class RecentPatient extends StatefulWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;
//   //final bool showBottomNavBar;

//   const RecentPatient({
//     Key? key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//     //required this.showBottomNavBar,
//   }) : super(key: key);

//   @override
//   State<RecentPatient> createState() => _RecentPatientState();
// }

// class _RecentPatientState extends State<RecentPatient> {
//   //late Future<List<Map<String, dynamic>>> _recentPatientsFuture;
//   List<Map<String, dynamic>> recentPatients = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchRecentPatients();
//   }

//   Future<List<Map<String, dynamic>>> _fetchRecentPatients() async {
//     try {
//       final clinicRef =
//           FirebaseFirestore.instance.collection('clinics').doc(widget.clinicId);
//       final patientsQuerySnapshot = await clinicRef
//           .collection('patients')
//           .orderBy('searchCount', descending: true)
//           .limit(4)
//           .get();

//       final recentPatientsData = <Map<String, dynamic>>[];

//       for (final patientDoc in patientsQuerySnapshot.docs) {
//         final patientData = patientDoc.data();
//         devtools.log('Patient data: $patientData'); // Add this line for logging

//         if (patientData.isNotEmpty) {
//           recentPatientsData.add(patientData);
//         }
//       }

//       devtools.log(
//           'Recent patients data: $recentPatientsData'); // Add this line for logging
//       setState(() {
//         recentPatients = recentPatientsData;
//         devtools.log('Recent patients data: $recentPatients');
//       });

//       return recentPatientsData;
//     } catch (e) {
//       // Handle error
//       devtools.log('Error fetching recent patients: $e');
//       return []; // Return an empty list in case of an error
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     //devtools.log('This is coming from inside build widget of RecentPatient.');

//     if (recentPatients.isEmpty) {
//       return Container(); // Render an empty container when there are no recent patients
//     }

//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       'Recent Patients',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                           color: MyColors.colorPalette['on_surface']),
//                     ),
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Handle View More button action
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => SearchAndDisplayAllPatients(
//                         clinicId: widget.clinicId,
//                         doctorId: widget.doctorId,
//                         doctorName: widget.doctorName,
//                         patientService: widget.patientService,
//                         //showBottomNavBar: widget.showBottomNavBar,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     'View More',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: MyColors.colorPalette['on-surface-variant'],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Align(
//             alignment: Alignment.topLeft,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Padding(
//                 padding: const EdgeInsets.all(30.0),
//                 child: Row(
//                   children: [
//                     for (final patientInfo in recentPatients)
//                       Row(
//                         children: [
//                           Padding(
//                             key: UniqueKey(),
//                             padding: const EdgeInsets.all(10.0),
//                             child: Row(
//                               children: [
//                                 Column(
//                                   children: [
//                                     GestureDetector(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 TreatmentLandingScreen(
//                                               clinicId: widget.clinicId,
//                                               doctorId: widget.doctorId,
//                                               doctorName: widget.doctorName,
//                                               patientId:
//                                                   patientInfo['patientId'],
//                                               patientName:
//                                                   patientInfo['patientName'],
//                                               patientMobileNumber: patientInfo[
//                                                   'patientMobileNumber'],
//                                               age: patientInfo['age'],
//                                               gender: patientInfo['gender'],
//                                               patientPicUrl:
//                                                   patientInfo['patientPicUrl'],
//                                               uhid: patientInfo['uhid'],
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       child: CircleAvatar(
//                                         radius: 24,
//                                         backgroundColor:
//                                             MyColors.colorPalette['surface'],
//                                         backgroundImage: patientInfo[
//                                                         'patientPicUrl'] !=
//                                                     null &&
//                                                 patientInfo['patientPicUrl']
//                                                     .isNotEmpty
//                                             ? NetworkImage(
//                                                 patientInfo['patientPicUrl']!)
//                                             : Image.asset(
//                                                 'assets/images/default-image.png',
//                                                 color: MyColors
//                                                     .colorPalette['primary'],
//                                                 colorBlendMode: BlendMode.color,
//                                               ).image,
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 8,
//                                     ),
//                                     Text(
//                                       patientInfo['patientName'],
//                                       style: MyTextStyle
//                                           .textStyleMap['label-small']
//                                           ?.copyWith(
//                                               color: MyColors
//                                                   .colorPalette['on_surface']),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   width: 16,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
