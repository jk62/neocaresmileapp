import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/firestore/appointment_service.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import 'package:neocaresmileapp/mywidgets/appointment_provider.dart';
import 'package:neocaresmileapp/mywidgets/calender_view.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/treatment_landing_screen.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

class NextAppointment extends StatefulWidget {
  final String doctorId;
  final String clinicId;
  final String doctorName;
  final PatientService patientService;

  const NextAppointment({
    super.key,
    required this.doctorId,
    required this.clinicId,
    required this.doctorName,
    required this.patientService,
  });

  @override
  State<NextAppointment> createState() => _NextAppointmentState();
}

class _NextAppointmentState extends State<NextAppointment> {
  void logNavigatorStack(BuildContext context) {
    Navigator.popUntil(context, (route) {
      devtools.log('Route in stack: ${route.settings.name}');
      return true; // This allows the function to iterate through all routes
    });
  }

  @override
  Widget build(BuildContext context) {
    devtools.log('!!!! Welcome to NextAppointment.!!!!');
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    if (appointmentProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final nextAppointment = appointmentProvider.nextAppointment;
    devtools.log('Next appointment: $nextAppointment');

    if (nextAppointment == null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Appointment',
              style: MyTextStyle.textStyleMap['title-large']?.copyWith(
                color: MyColors.colorPalette['on_surface'],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No upcoming appointments!',
              style: MyTextStyle.textStyleMap['label-large']?.copyWith(
                color: MyColors.colorPalette['on_surface_variant'],
              ),
            ),
          ],
        ),
      );
    }

    final isSelected = appointmentProvider.selectedAppointmentId ==
        nextAppointment.appointmentId;

    return GestureDetector(
      onTap: () {
        logNavigatorStack(context); // Log the stack before navigating
        if (isSelected) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          appointmentProvider.selectedAppointmentId = null;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TreatmentLandingScreen(
                clinicId: widget.clinicId,
                patientId: nextAppointment.patientId,
                patientName: nextAppointment.patientName,
                patientMobileNumber: nextAppointment.patientMobileNumber,
                age: nextAppointment.age,
                gender: nextAppointment.gender,
                doctorId: widget.doctorId,
                doctorName: widget.doctorName,
                patientPicUrl: nextAppointment.patientPicUrl,
                uhid: nextAppointment.uhid,
              ),
            ),
          );
        }
      },
      onLongPress: () {
        _showSelectionSnackbar(context, appointmentProvider, nextAppointment);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Next Appointment',
                    style: MyTextStyle.textStyleMap['title-large']?.copyWith(
                      color: MyColors.colorPalette['on_surface'],
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CalenderView(
                        doctorId: widget.doctorId,
                        doctorName: widget.doctorName,
                        clinicId: widget.clinicId,
                        showBottomNavigationBar: true,
                        //patientService: widget.patientService,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
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
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    DateFormat('EEEE, d MMMM, h:mm a')
                        .format(nextAppointment.appointmentDate),
                    style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
                      color: MyColors.colorPalette['on_surface-variant'],
                    ),
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onLongPress: () {
              _showSelectionSnackbar(
                  context, appointmentProvider, nextAppointment);
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 1,
                    color: isSelected ? Colors.redAccent : Colors.blueAccent,
                  ),
                  color: isSelected
                      ? Colors.red.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: MyColors.colorPalette['surface'],
                      backgroundImage: nextAppointment.patientPicUrl != null &&
                              nextAppointment.patientPicUrl!.isNotEmpty
                          ? NetworkImage(nextAppointment.patientPicUrl!)
                          : Image.asset(
                              'assets/images/default-image.png',
                              color: MyColors.colorPalette['primary'],
                              colorBlendMode: BlendMode.color,
                            ).image,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextAppointment.patientName,
                            style: MyTextStyle.textStyleMap['label-medium']
                                ?.copyWith(
                              color: MyColors.colorPalette['on_surface'],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                nextAppointment.age.toString(),
                                style: MyTextStyle.textStyleMap['label-medium']
                                    ?.copyWith(
                                  color: MyColors
                                      .colorPalette['on-surface-variant'],
                                ),
                              ),
                              const Text('/'),
                              Text(
                                nextAppointment.gender,
                                style: MyTextStyle.textStyleMap['label-medium']
                                    ?.copyWith(
                                  color: MyColors
                                      .colorPalette['on-surface-variant'],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            nextAppointment.patientMobileNumber,
                            style: MyTextStyle.textStyleMap['label-medium']
                                ?.copyWith(
                              color:
                                  MyColors.colorPalette['on-surface-variant'],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TreatmentLandingScreen(
                              clinicId: widget.clinicId,
                              patientId: nextAppointment.patientId,
                              patientName: nextAppointment.patientName,
                              patientMobileNumber:
                                  nextAppointment.patientMobileNumber,
                              age: nextAppointment.age,
                              gender: nextAppointment.gender,
                              doctorId: widget.doctorId,
                              doctorName: widget.doctorName,
                              patientPicUrl: nextAppointment.patientPicUrl,
                              uhid: nextAppointment.uhid,
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 13.33,
                        backgroundColor: MyColors.colorPalette['primary'] ??
                            Colors.blueAccent,
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.white,
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

  void _showSelectionSnackbar(BuildContext context,
      AppointmentProvider appointmentProvider, Appointment nextAppointment) {
    appointmentProvider.selectedAppointmentId = nextAppointment.appointmentId;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Appointment selected'),
        action: SnackBarAction(
          label: 'Delete',
          onPressed: () {
            appointmentProvider.deleteAppointmentAndUpdateSlot(
              widget.clinicId,
              widget.doctorName,
              nextAppointment.appointmentId,
              nextAppointment.appointmentDate,
              nextAppointment.slot,
            );
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(days: 1),
      ),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW BEFORE IT LISTEN TO NEW SETUP OF APPOINTMENTPROVIDER ALIGNED WITH getNextAppointmentStream
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'package:provider/provider.dart';
// import 'dart:developer' as devtools show log;

// class NextAppointment extends StatefulWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const NextAppointment({
//     super.key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   });

//   @override
//   State<NextAppointment> createState() => _NextAppointmentState();
// }

// class _NextAppointmentState extends State<NextAppointment> {
//   void logNavigatorStack(BuildContext context) {
//     Navigator.popUntil(context, (route) {
//       devtools.log('Route in stack: ${route.settings.name}');
//       return true; // This allows the function to iterate through all routes
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to NextAppointment.');
//     final appointmentProvider = Provider.of<AppointmentProvider>(context);

//     if (appointmentProvider.isLoading) {
//       return const CircularProgressIndicator();
//     }

//     final nextAppointment = appointmentProvider.nextAppointment;
//     devtools.log(
//         'This is coming from inside NextAppointment. nextAppointment is ${nextAppointment.toString()}');
//     devtools.log(
//         'Age: ${nextAppointment?.age}, Gender: ${nextAppointment?.gender}, Mobile: ${nextAppointment?.patientMobileNumber}');

//     final isSelected = appointmentProvider.selectedAppointmentId ==
//         nextAppointment?.appointmentId;

//     return GestureDetector(
//       onTap: () {
//         logNavigatorStack(context); // Log the stack before navigating
//         if (isSelected) {
//           ScaffoldMessenger.of(context).hideCurrentSnackBar();
//           appointmentProvider.selectedAppointmentId = null;
//         } else {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => TreatmentLandingScreen(
//                 clinicId: widget.clinicId,
//                 patientId: nextAppointment!.patientId,
//                 patientName: nextAppointment.patientName,
//                 patientMobileNumber: nextAppointment.patientMobileNumber,
//                 age: nextAppointment.age,
//                 gender: nextAppointment.gender,
//                 doctorId: widget.doctorId,
//                 doctorName: widget.doctorName,
//                 patientPicUrl: nextAppointment.patientPicUrl,
//                 uhid: nextAppointment.uhid,
//               ),
//             ),
//           );
//         }
//       },
//       onLongPress: () {
//         _showSelectionSnackbar(context, appointmentProvider, nextAppointment!);
//       },
//       child: nextAppointment != null
//           ? SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'Next Appointment',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                               color: MyColors.colorPalette['on_surface'],
//                             ),
//                           ),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => CalenderView(
//                                 doctorId: widget.doctorId,
//                                 doctorName: widget.doctorName,
//                                 clinicId: widget.clinicId,
//                                 showBottomNavigationBar: true,
//                                 patientService: widget.patientService,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.only(
//                               left: 8.0, top: 8.0, bottom: 8.0),
//                           child: Text(
//                             'View More',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color:
//                                   MyColors.colorPalette['on-surface-variant'],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             DateFormat('EEEE, d MMMM, h:mm a')
//                                 .format(nextAppointment.appointmentDate),
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                               color:
//                                   MyColors.colorPalette['on_surface-variant'],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   GestureDetector(
//                     onLongPress: () {
//                       _showSelectionSnackbar(
//                           context, appointmentProvider, nextAppointment);
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(8),
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             width: 1,
//                             color: isSelected
//                                 ? Colors.redAccent
//                                 : Colors.blueAccent,
//                           ),
//                           color: isSelected
//                               ? Colors.red.withOpacity(0.1)
//                               : Colors.transparent,
//                         ),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 24,
//                               backgroundColor: MyColors.colorPalette['surface'],
//                               backgroundImage: nextAppointment.patientPicUrl !=
//                                           null &&
//                                       nextAppointment.patientPicUrl!.isNotEmpty
//                                   ? NetworkImage(
//                                       nextAppointment.patientPicUrl!,
//                                     )
//                                   : Image.asset(
//                                       'assets/images/default-image.png',
//                                       color: MyColors.colorPalette['primary'],
//                                       colorBlendMode: BlendMode.color,
//                                     ).image,
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     nextAppointment.patientName,
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on_surface'],
//                                     ),
//                                   ),
//                                   Row(
//                                     children: [
//                                       Text(
//                                         nextAppointment.age.toString(),
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on-surface-variant']),
//                                       ),
//                                       Text(
//                                         '/',
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on-surface-variant']),
//                                       ),
//                                       Text(
//                                         nextAppointment.gender,
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on-surface-variant']),
//                                       ),
//                                     ],
//                                   ),
//                                   Text(
//                                     nextAppointment.patientMobileNumber,
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                             color: MyColors.colorPalette[
//                                                 'on-surface-variant']),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const Spacer(),
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         TreatmentLandingScreen(
//                                       clinicId: widget.clinicId,
//                                       patientId: nextAppointment.patientId,
//                                       patientName: nextAppointment.patientName,
//                                       patientMobileNumber:
//                                           nextAppointment.patientMobileNumber,
//                                       age: nextAppointment.age,
//                                       gender: nextAppointment.gender,
//                                       doctorId: widget.doctorId,
//                                       doctorName: widget.doctorName,
//                                       patientPicUrl:
//                                           nextAppointment.patientPicUrl,
//                                       uhid: nextAppointment.uhid,
//                                     ),
//                                     settings: const RouteSettings(
//                                         name: 'TreatmentLandingScreen'),
//                                   ),
//                                 );
//                               },
//                               child: CircleAvatar(
//                                 radius: 13.33,
//                                 backgroundColor:
//                                     MyColors.colorPalette['primary'] ??
//                                         Colors.blueAccent,
//                                 child: const Icon(
//                                   Icons.arrow_forward_ios_rounded,
//                                   size: 16,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'Next Appointment',
//                           style:
//                               MyTextStyle.textStyleMap['title-large']?.copyWith(
//                             color: MyColors.colorPalette['on_surface'],
//                           ),
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => CalenderView(
//                               doctorId: widget.doctorId,
//                               doctorName: widget.doctorName,
//                               clinicId: widget.clinicId,
//                               showBottomNavigationBar: true,
//                               patientService: widget.patientService,
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
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'No appointments today!',
//                       style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                         color: MyColors.colorPalette['on_surface_variant'],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   void _showSelectionSnackbar(BuildContext context,
//       AppointmentProvider appointmentProvider, Appointment nextAppointment) {
//     appointmentProvider.selectedAppointmentId = nextAppointment.appointmentId;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Appointment selected'),
//         action: SnackBarAction(
//           label: 'Delete',
//           onPressed: () {
//             appointmentProvider.deleteAppointmentAndUpdateSlot(
//               widget.clinicId,
//               widget.doctorName,
//               nextAppointment.appointmentId,
//               nextAppointment.appointmentDate,
//               nextAppointment.slot,
//             );
//             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//           },
//         ),
//         behavior: SnackBarBehavior.fixed,
//         duration: const Duration(days: 1),
//       ),
//     );
//   }
// }

//Map<String, dynamic>? _treatmentData;

// @override
// void didChangeDependencies() {
//   super.didChangeDependencies();
//   final appointmentProvider =
//       Provider.of<AppointmentProvider>(context, listen: false);
//   final nextAppointment = appointmentProvider.nextAppointment;
//   if (nextAppointment != null) {
//     _fetchAndSetTreatmentData(widget.clinicId, nextAppointment.patientId);
//   }
// }

// Future<void> _fetchAndSetTreatmentData(
//     String clinicId, String patientId) async {
//   final treatmentData = await fetchTreatmentData(clinicId, patientId);
//   if (treatmentData != null) {
//     setState(() {
//       _treatmentData = treatmentData;
//     });
//   }
// }

// Future<Map<String, dynamic>?> fetchTreatmentData(
//     String clinicId, String patientId) async {
//   try {
//     final patientDocument = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('patients')
//         .doc(patientId);

//     final patientDocumentSnapshot = await patientDocument.get();

//     if (patientDocumentSnapshot.exists) {
//       final treatmentsCollection = patientDocument.collection('treatments');
//       final treatmentsQuerySnapshot = await treatmentsCollection.get();

//       if (treatmentsQuerySnapshot.docs.isNotEmpty) {
//         bool hasActiveTreatment = false;
//         Map<String, dynamic>? activeTreatmentData;

//         for (var treatmentDocument in treatmentsQuerySnapshot.docs) {
//           final treatmentData = treatmentDocument.data();
//           final isTreatmentClose = treatmentData['isTreatmentClose'] ?? false;

//           if (!isTreatmentClose) {
//             hasActiveTreatment = true;
//             activeTreatmentData = treatmentData;
//             break;
//           }
//         }

//         if (hasActiveTreatment) {
//           devtools.log('Active treatment data: $activeTreatmentData');
//           return activeTreatmentData;
//         }
//       } else {
//         devtools.log('No treatments found for patient');
//       }
//     } else {
//       devtools.log('Patient document does not exist');
//     }

//     return null;
//   } catch (error) {
//     devtools.log('Error fetching treatment data: $error');
//     return null;
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW IS STABLE WITHOUT ONTAP IMPLEMENTATION
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'package:provider/provider.dart';
// import 'dart:developer' as devtools show log;

// class NextAppointment extends StatefulWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const NextAppointment({
//     super.key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   });

//   @override
//   _NextAppointmentState createState() => _NextAppointmentState();
// }

// class _NextAppointmentState extends State<NextAppointment> {
//   // -----------------------------------------------------------------//
//   Map<String, dynamic>? _treatmentData;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final appointmentProvider =
//         Provider.of<AppointmentProvider>(context, listen: false);
//     final nextAppointment = appointmentProvider.nextAppointment;
//     if (nextAppointment != null) {
//       _fetchAndSetTreatmentData(widget.clinicId, nextAppointment.patientId);
//     }
//   }

//   Future<void> _fetchAndSetTreatmentData(
//       String clinicId, String patientId) async {
//     final treatmentData = await fetchTreatmentData(clinicId, patientId);
//     if (treatmentData != null) {
//       setState(() {
//         _treatmentData = treatmentData;
//       });
//     }
//   }

//   Future<Map<String, dynamic>?> fetchTreatmentData(
//       String clinicId, String patientId) async {
//     try {
//       final patientDocument = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId);

//       final patientDocumentSnapshot = await patientDocument.get();

//       if (patientDocumentSnapshot.exists) {
//         final treatmentsCollection = patientDocument.collection('treatments');
//         final treatmentsQuerySnapshot = await treatmentsCollection.get();

//         if (treatmentsQuerySnapshot.docs.isNotEmpty) {
//           bool hasActiveTreatment = false;
//           Map<String, dynamic>? activeTreatmentData;

//           for (var treatmentDocument in treatmentsQuerySnapshot.docs) {
//             final treatmentData = treatmentDocument.data();
//             final isTreatmentClose = treatmentData['isTreatmentClose'] ?? false;

//             if (!isTreatmentClose) {
//               hasActiveTreatment = true;
//               activeTreatmentData = treatmentData;
//               break;
//             }
//           }

//           if (hasActiveTreatment) {
//             devtools.log('Active treatment data: $activeTreatmentData');
//             return activeTreatmentData;
//           }
//         } else {
//           devtools.log('No treatments found for patient');
//         }
//       } else {
//         devtools.log('Patient document does not exist');
//       }

//       return null;
//     } catch (error) {
//       devtools.log('Error fetching treatment data: $error');
//       return null;
//     }
//   }

//   // -----------------------------------------------------------------//
//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to NextAppointment.');
//     final appointmentProvider = Provider.of<AppointmentProvider>(context);

//     if (appointmentProvider.isLoading) {
//       return const CircularProgressIndicator();
//     }

//     final nextAppointment = appointmentProvider.nextAppointment;
//     devtools.log('nextAppointment is $nextAppointment');

//     final isSelected = appointmentProvider.selectedAppointmentId ==
//         nextAppointment?.appointmentId;

//     return GestureDetector(
//       onTap: () {
//         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//         appointmentProvider.selectedAppointmentId = null;
//       },
//       child: nextAppointment != null
//           ? SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'Next Appointment',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                               color: MyColors.colorPalette['on_surface'],
//                             ),
//                           ),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => CalenderView(
//                                 doctorId: widget.doctorId,
//                                 doctorName: widget.doctorName,
//                                 clinicId: widget.clinicId,
//                                 showBottomNavigationBar: true,
//                                 patientService: widget.patientService,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.only(
//                               left: 8.0, top: 8.0, bottom: 8.0),
//                           child: Text(
//                             'View More',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color:
//                                   MyColors.colorPalette['on-surface-variant'],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             DateFormat('EEEE, d MMMM, h:mm a')
//                                 .format(nextAppointment.appointmentDate),
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                               color:
//                                   MyColors.colorPalette['on_surface-variant'],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   GestureDetector(
//                     onLongPress: () {
//                       _showSelectionSnackbar(
//                           context, appointmentProvider, nextAppointment);
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(8),
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             width: 1,
//                             color: isSelected
//                                 ? Colors.redAccent
//                                 : Colors.blueAccent,
//                           ),
//                           color: isSelected
//                               ? Colors.red.withOpacity(0.1)
//                               : Colors.transparent,
//                         ),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 24,
//                               backgroundColor: MyColors.colorPalette['surface'],
//                               backgroundImage: nextAppointment.patientPicUrl !=
//                                           null &&
//                                       nextAppointment.patientPicUrl!.isNotEmpty
//                                   ? NetworkImage(
//                                       nextAppointment.patientPicUrl!,
//                                     )
//                                   : Image.asset(
//                                       'assets/images/default-image.png',
//                                       color: MyColors.colorPalette['primary'],
//                                       colorBlendMode: BlendMode.color,
//                                     ).image,
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     nextAppointment.patientName,
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on_surface'],
//                                     ),
//                                   ),
//                                   Row(
//                                     children: [
//                                       Text(
//                                         nextAppointment.age.toString(),
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on-surface-variant']),
//                                       ),
//                                       Text(
//                                         '/',
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on-surface-variant']),
//                                       ),
//                                       Text(
//                                         nextAppointment.gender,
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on-surface-variant']),
//                                       ),
//                                     ],
//                                   ),
//                                   Text(
//                                     nextAppointment.patientMobileNumber,
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                             color: MyColors.colorPalette[
//                                                 'on-surface-variant']),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const Spacer(),
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         TreatmentLandingScreen(
//                                       clinicId: widget.clinicId,
//                                       patientId: nextAppointment.patientId,
//                                       patientName: nextAppointment.patientName,
//                                       patientMobileNumber:
//                                           nextAppointment.patientMobileNumber,
//                                       age: nextAppointment.age,
//                                       gender: nextAppointment.gender,
//                                       doctorId: widget.doctorId,
//                                       doctorName: widget.doctorName,
//                                       patientPicUrl:
//                                           nextAppointment.patientPicUrl,
//                                       uhid: nextAppointment.uhid,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: CircleAvatar(
//                                 radius: 13.33,
//                                 backgroundColor:
//                                     MyColors.colorPalette['primary'] ??
//                                         Colors.blueAccent,
//                                 child: const Icon(
//                                   Icons.arrow_forward_ios_rounded,
//                                   size: 16,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'Next Appointment',
//                           style:
//                               MyTextStyle.textStyleMap['title-large']?.copyWith(
//                             color: MyColors.colorPalette['on_surface'],
//                           ),
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => CalenderView(
//                               doctorId: widget.doctorId,
//                               doctorName: widget.doctorName,
//                               clinicId: widget.clinicId,
//                               showBottomNavigationBar: true,
//                               patientService: widget.patientService,
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
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'No appointments today!',
//                       style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                         color: MyColors.colorPalette['on_surface_variant'],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   void _showSelectionSnackbar(BuildContext context,
//       AppointmentProvider appointmentProvider, Appointment nextAppointment) {
//     appointmentProvider.selectedAppointmentId = nextAppointment.appointmentId;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Appointment selected'),
//         action: SnackBarAction(
//           label: 'Delete',
//           onPressed: () {
//             appointmentProvider.deleteAppointmentAndUpdateSlot(
//               widget.clinicId,
//               widget.doctorName,
//               nextAppointment.appointmentId,
//               nextAppointment.appointmentDate,
//               nextAppointment.slot,
//             );
//             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//           },
//         ),
//         behavior: SnackBarBehavior.fixed,
//         duration: const Duration(days: 1),
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW BEFORE FIXING LONG PRESS
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'package:provider/provider.dart';
// import 'dart:developer' as devtools show log;

// class NextAppointment extends StatelessWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const NextAppointment({
//     Key? key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to NextAppointment.');
//     final appointmentProvider = Provider.of<AppointmentProvider>(context);

//     if (appointmentProvider.isLoading) {
//       return const CircularProgressIndicator();
//     }

//     final nextAppointment = appointmentProvider.nextAppointment;
//     devtools.log('nextAppointment is $nextAppointment');

//     return GestureDetector(
//       onTap: () {
//         // Dismiss the SnackBar if user taps anywhere else
//         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//       },
//       child: nextAppointment != null
//           ? SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'Next Appointment',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                               color: MyColors.colorPalette['on_surface'],
//                             ),
//                           ),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => CalenderView(
//                                 doctorId: doctorId,
//                                 doctorName: doctorName,
//                                 clinicId: clinicId,
//                                 showBottomNavigationBar: true,
//                                 patientService: patientService,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'View More',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color:
//                                   MyColors.colorPalette['on-surface-variant'],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             DateFormat('EEEE, d MMMM, h:mm a')
//                                 .format(nextAppointment.appointmentDate),
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                               color:
//                                   MyColors.colorPalette['on_surface-variant'],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   GestureDetector(
//                     onLongPress: () {
//                       _showSelectionSnackbar(
//                           context, appointmentProvider, nextAppointment);
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(8),
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             width: 1,
//                             color: Colors.blueAccent,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 24,
//                               backgroundColor: MyColors.colorPalette['surface'],
//                               backgroundImage: nextAppointment.patientPicUrl !=
//                                           null &&
//                                       nextAppointment.patientPicUrl!.isNotEmpty
//                                   ? NetworkImage(
//                                       nextAppointment.patientPicUrl!,
//                                     )
//                                   : Image.asset(
//                                       'assets/images/default-image.png',
//                                       color: MyColors.colorPalette['primary'],
//                                       colorBlendMode: BlendMode.color,
//                                     ).image,
//                             ),
//                             const SizedBox(width: 10),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   nextAppointment.patientName,
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                     color: MyColors.colorPalette['on_surface'],
//                                   ),
//                                 ),
//                                 Text(
//                                   'Treatment',
//                                   style: MyTextStyle.textStyleMap['label-small']
//                                       ?.copyWith(
//                                     color: MyColors
//                                         .colorPalette['on_surface_variant'],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const Spacer(),
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         TreatmentLandingScreen(
//                                       clinicId: clinicId,
//                                       patientId: nextAppointment.patientId,
//                                       patientName: nextAppointment.patientName,
//                                       patientMobileNumber:
//                                           nextAppointment.patientMobileNumber,
//                                       age: nextAppointment.age,
//                                       gender: nextAppointment.gender,
//                                       doctorId: doctorId,
//                                       doctorName: doctorName,
//                                       patientPicUrl:
//                                           nextAppointment.patientPicUrl,
//                                       uhid: nextAppointment.uhid,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: CircleAvatar(
//                                 radius: 13.33,
//                                 backgroundColor:
//                                     MyColors.colorPalette['primary'] ??
//                                         Colors.blueAccent,
//                                 child: const Icon(
//                                   Icons.arrow_forward_ios_rounded,
//                                   size: 16,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'Next Appointment',
//                           style:
//                               MyTextStyle.textStyleMap['title-large']?.copyWith(
//                             color: MyColors.colorPalette['on_surface'],
//                           ),
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => CalenderView(
//                               doctorId: doctorId,
//                               doctorName: doctorName,
//                               clinicId: clinicId,
//                               showBottomNavigationBar: true,
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
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'No appointments today!',
//                       style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                         color: MyColors.colorPalette['on_surface_variant'],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   void _showSelectionSnackbar(BuildContext context,
//       AppointmentProvider appointmentProvider, Appointment nextAppointment) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Appointment selected'),
//         action: SnackBarAction(
//           label: 'Delete',
//           onPressed: () {
//             appointmentProvider.deleteAppointmentAndUpdateSlot(
//               clinicId,
//               doctorName,
//               nextAppointment.appointmentId,
//               nextAppointment.appointmentDate,
//               nextAppointment.slot,
//             );
//             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//           },
//         ),
//         behavior: SnackBarBehavior.fixed,
//         duration: const Duration(days: 1),
//       ),
//     );
//   }
// }

//-------------------------------------------------------------//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'package:provider/provider.dart';
// import 'dart:developer' as devtools show log;

// class NextAppointment extends StatelessWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const NextAppointment({
//     Key? key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to NextAppointment.');
//     final appointmentProvider = Provider.of<AppointmentProvider>(context);

//     if (appointmentProvider.isLoading) {
//       return const CircularProgressIndicator();
//     }

//     final nextAppointment = appointmentProvider.nextAppointment;
//     devtools.log('nextAppointment is $nextAppointment');

//     if (nextAppointment != null) {
//       return SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       'Next Appointment',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                         color: MyColors.colorPalette['on_surface'],
//                       ),
//                     ),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => CalenderView(
//                           doctorId: doctorId,
//                           doctorName: doctorName,
//                           clinicId: clinicId,
//                           showBottomNavigationBar: true,
//                           patientService: patientService,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       'View More',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: MyColors.colorPalette['on-surface-variant'],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       DateFormat('EEEE, d MMMM, h:mm a')
//                           .format(nextAppointment.appointmentDate),
//                       style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                         color: MyColors.colorPalette['on_surface-variant'],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             GestureDetector(
//               onLongPress: () {
//                 _showSelectionSnackbar(
//                     context, appointmentProvider, nextAppointment);
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       width: 1,
//                       color: Colors.blueAccent,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 24,
//                         backgroundColor: MyColors.colorPalette['surface'],
//                         backgroundImage:
//                             nextAppointment.patientPicUrl != null &&
//                                     nextAppointment.patientPicUrl!.isNotEmpty
//                                 ? NetworkImage(
//                                     nextAppointment.patientPicUrl!,
//                                   )
//                                 : Image.asset(
//                                     'assets/images/default-image.png',
//                                     color: MyColors.colorPalette['primary'],
//                                     colorBlendMode: BlendMode.color,
//                                   ).image,
//                       ),
//                       const SizedBox(width: 10),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             nextAppointment.patientName,
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                               color: MyColors.colorPalette['on_surface'],
//                             ),
//                           ),
//                           Text(
//                             'Treatment',
//                             style: MyTextStyle.textStyleMap['label-small']
//                                 ?.copyWith(
//                               color:
//                                   MyColors.colorPalette['on_surface_variant'],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Spacer(),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => TreatmentLandingScreen(
//                                 clinicId: clinicId,
//                                 patientId: nextAppointment.patientId,
//                                 patientName: nextAppointment.patientName,
//                                 patientMobileNumber:
//                                     nextAppointment.patientMobileNumber,
//                                 age: nextAppointment.age,
//                                 gender: nextAppointment.gender,
//                                 doctorId: doctorId,
//                                 doctorName: doctorName,
//                                 patientPicUrl: nextAppointment.patientPicUrl,
//                                 uhid: nextAppointment.uhid,
//                               ),
//                             ),
//                           );
//                         },
//                         child: CircleAvatar(
//                           radius: 13.33,
//                           backgroundColor: MyColors.colorPalette['primary'] ??
//                               Colors.blueAccent,
//                           child: const Icon(
//                             Icons.arrow_forward_ios_rounded,
//                             size: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     'Next Appointment',
//                     style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                       color: MyColors.colorPalette['on_surface'],
//                     ),
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => CalenderView(
//                         doctorId: doctorId,
//                         doctorName: doctorName,
//                         clinicId: clinicId,
//                         showBottomNavigationBar: true,
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
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Text(
//                 'No appointments today!',
//                 style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                   color: MyColors.colorPalette['on_surface_variant'],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//   }

//   void _showSelectionSnackbar(BuildContext context,
//       AppointmentProvider appointmentProvider, Appointment nextAppointment) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Appointment selected'),
//         action: SnackBarAction(
//           label: 'Delete',
//           onPressed: () {
//             appointmentProvider.deleteAppointmentAndUpdateSlot(
//               clinicId,
//               doctorName,
//               nextAppointment.appointmentId,
//               nextAppointment.appointmentDate,
//               nextAppointment.slot,
//             );
//             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//           },
//         ),
//         behavior: SnackBarBehavior.fixed,
//         duration: const Duration(days: 1),
//       ),
//     );
//   }
// }

//------------------------------------------------------//

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// //import 'package:neocare_dental_app/providers/appointment_provider.dart';
// import 'package:provider/provider.dart';
// import 'dart:developer' as devtools show log;

// class NextAppointment extends StatelessWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const NextAppointment({
//     Key? key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to NextAppointment.');
//     return ChangeNotifierProvider(
//       create: (_) => AppointmentProvider(
//         doctorId: doctorId,
//         clinicId: clinicId,
//         doctorName: doctorName,
//         patientService: patientService,
//       ),
//       child: Consumer<AppointmentProvider>(
//         builder: (context, appointmentProvider, child) {
//           if (appointmentProvider.isLoading) {
//             return const CircularProgressIndicator();
//           }

//           final nextAppointment = appointmentProvider.nextAppointment;
//           devtools.log('nextAppointment is $nextAppointment');

//           if (nextAppointment != null) {
//             return SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'Next Appointment',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                               color: MyColors.colorPalette['on_surface'],
//                             ),
//                           ),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => CalenderView(
//                                 doctorId: doctorId,
//                                 doctorName: doctorName,
//                                 clinicId: clinicId,
//                                 showBottomNavigationBar: true,
//                                 patientService: patientService,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'View More',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color:
//                                   MyColors.colorPalette['on-surface-variant'],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             DateFormat('EEEE, d MMMM, h:mm a')
//                                 .format(nextAppointment.appointmentDate),
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                               color:
//                                   MyColors.colorPalette['on_surface-variant'],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   GestureDetector(
//                     onLongPress: () {
//                       _showSelectionSnackbar(
//                           context, appointmentProvider, nextAppointment);
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(8),
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             width: 1,
//                             color: Colors.blueAccent,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 24,
//                               backgroundColor: MyColors.colorPalette['surface'],
//                               backgroundImage: nextAppointment.patientPicUrl !=
//                                           null &&
//                                       nextAppointment.patientPicUrl!.isNotEmpty
//                                   ? NetworkImage(
//                                       nextAppointment.patientPicUrl!,
//                                     )
//                                   : Image.asset(
//                                       'assets/images/default-image.png',
//                                       color: MyColors.colorPalette['primary'],
//                                       colorBlendMode: BlendMode.color,
//                                     ).image,
//                             ),
//                             const SizedBox(width: 10),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   nextAppointment.patientName,
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                     color: MyColors.colorPalette['on_surface'],
//                                   ),
//                                 ),
//                                 Text(
//                                   'Treatment',
//                                   style: MyTextStyle.textStyleMap['label-small']
//                                       ?.copyWith(
//                                     color: MyColors
//                                         .colorPalette['on_surface_variant'],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const Spacer(),
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         TreatmentLandingScreen(
//                                       clinicId: clinicId,
//                                       patientId: nextAppointment.patientId,
//                                       patientName: nextAppointment.patientName,
//                                       patientMobileNumber:
//                                           nextAppointment.patientMobileNumber,
//                                       age: nextAppointment.age,
//                                       gender: nextAppointment.gender,
//                                       doctorId: doctorId,
//                                       doctorName: doctorName,
//                                       patientPicUrl:
//                                           nextAppointment.patientPicUrl,
//                                       uhid: nextAppointment.uhid,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: CircleAvatar(
//                                 radius: 13.33,
//                                 backgroundColor:
//                                     MyColors.colorPalette['primary'] ??
//                                         Colors.blueAccent,
//                                 child: const Icon(
//                                   Icons.arrow_forward_ios_rounded,
//                                   size: 16,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           } else {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'Next Appointment',
//                           style:
//                               MyTextStyle.textStyleMap['title-large']?.copyWith(
//                             color: MyColors.colorPalette['on_surface'],
//                           ),
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => CalenderView(
//                               doctorId: doctorId,
//                               doctorName: doctorName,
//                               clinicId: clinicId,
//                               showBottomNavigationBar: true,
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
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'No appointments today!',
//                       style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                         color: MyColors.colorPalette['on_surface_variant'],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }

//   void _showSelectionSnackbar(BuildContext context,
//       AppointmentProvider appointmentProvider, Appointment nextAppointment) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Appointment selected'),
//         action: SnackBarAction(
//           label: 'Delete',
//           onPressed: () {
//             // appointmentProvider.deleteAppointmentAndUpdateSlot(
//             //   clinicId,
//             //   nextAppointment.doctorName,
//             //   nextAppointment.appointmentId,
//             //   nextAppointment.appointmentDate,
//             //   nextAppointment.slot,
//             // );
//             appointmentProvider.deleteAppointmentAndUpdateSlot(
//               clinicId,
//               doctorName,
//               //nextAppointment.doctorName,
//               nextAppointment.appointmentId,
//               nextAppointment.appointmentDate,
//               nextAppointment.slot,
//             );
//             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//           },
//         ),
//         behavior: SnackBarBehavior.fixed,
//         duration: const Duration(days: 1),
//       ),
//     );
//   }
// }

// CODE BELOW USER LISTENER
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'dart:developer' as devtools show log;

// class NextAppointment extends StatefulWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const NextAppointment({
//     Key? key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   }) : super(key: key);

//   @override
//   State<NextAppointment> createState() => _NextAppointmentState();
// }

// class _NextAppointmentState extends State<NextAppointment> {
//   final AppointmentService _appointmentService = AppointmentService();

//   bool _isSelected = false;
//   Appointment? _nextAppointment;
//   bool _dataFetched = false; // New state variable to track data fetch status

//   StreamSubscription<Appointment?>? _appointmentSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _listenForNextAppointment();
//   }

//   @override
//   void dispose() {
//     _appointmentSubscription?.cancel();
//     super.dispose();
//   }

//   void _listenForNextAppointment() {
//     _appointmentSubscription = _appointmentService
//         .getNextAppointmentStream(
//       doctorId: widget.doctorId,
//       clinicId: widget.clinicId,
//     )
//         .listen((appointment) {
//       setState(() {
//         _nextAppointment = appointment;
//         _dataFetched = true; // Update fetch status
//       });
//     }, onError: (error) {
//       // Handle error if needed
//       devtools.log('Error fetching next appointment: $error');
//     });
//   }

//   //CODE BELOW IMPLEMENTS LONGPRESS WITH SNACKBAR

//   void _showSelectionSnackbar(Appointment nextAppointment) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Appointment selected'),
//         action: SnackBarAction(
//           label: 'Delete',
//           onPressed: () {
//             // Handle delete action here
//             // For example, you can call a function to delete the appointment
//             _deleteAppointmentAndUpdateSlot(
//               widget.clinicId,
//               widget.doctorName,
//               nextAppointment.appointmentId,
//               nextAppointment.appointmentDate,
//               nextAppointment.slot,
//             );
//             setState(() {
//               _isSelected = false;
//             });
//             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//           },
//         ),
//         behavior: SnackBarBehavior.fixed,
//         duration: const Duration(days: 1),
//       ),
//     );
//   }

//   void _deleteAppointmentAndUpdateSlot(
//     String clinicId,
//     String doctorName,
//     String appointmentId,
//     DateTime appointmentDate,
//     String appointmentSlot,
//   ) async {
//     try {
//       // Other deletion logic

//       // Invoke delete appointment and slot function with callback
//       await _appointmentService.deleteAppointmentAndUpdateSlot(
//         clinicId,
//         doctorName,
//         appointmentId,
//         appointmentDate,
//         appointmentSlot,
//         _onDeleteAppointmentAndUpdateSlotCallback,
//       );

//       // Optionally, you can add code to update the UI or show a confirmation message
//     } catch (e) {
//       // Handle any errors that occur during the deletion process
//       devtools.log('Error deleting appointment and slot: $e');
//       // Optionally, you can show an error message to the user
//     }
//   }

//   void _onDeleteAppointmentAndUpdateSlotCallback() {
//     // Fetch and display appointments
//     setState(() {
//       // Fetch appointments again or update the existing data
//       _listenForNextAppointment();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to NextAppointment');
//     return StreamBuilder<Appointment?>(
//       stream: _appointmentService.getNextAppointmentStream(
//         doctorId: widget.doctorId,
//         clinicId: widget.clinicId,
//       ),
//       builder: (context, snapshot) {
//         devtools.log('This is coming from inside builder of StreamBuilder');
//         if (!_dataFetched) {
//           return const CircularProgressIndicator();
//         }

//         final nextAppointment = snapshot.data;
//         devtools.log(
//             'nextAppointment fetched successfully which is $nextAppointment');
//         devtools.log(
//             'nextAppointment.appointmentDate is ${nextAppointment?.appointmentDate}');
//         devtools.log(
//             'nextAppointment.appointmentId is ${nextAppointment?.appointmentId}');
//         devtools.log('nextAppointment.slot is ${nextAppointment?.slot}');

//         if (nextAppointment != null) {
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'Next Appointment',
//                           style:
//                               MyTextStyle.textStyleMap['title-large']?.copyWith(
//                             color: MyColors.colorPalette['on_surface'],
//                           ),
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         // Handle View More button action
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => CalenderView(
//                               doctorId: widget.doctorId,
//                               doctorName: widget.doctorName,
//                               clinicId: widget.clinicId,
//                               patientService: widget.patientService,
//                               showBottomNavigationBar: true,
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
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           DateFormat('EEEE, d MMMM, h:mm a')
//                               .format(nextAppointment.appointmentDate),
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['on_surface-variant'],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 GestureDetector(
//                   onLongPress: () {
//                     // Select the appointment
//                     setState(() {
//                       _isSelected = true;
//                     });
//                     // Show snackbar when selected
//                     _showSelectionSnackbar(nextAppointment);
//                   },
//                   onTap: () {
//                     if (_isSelected) {
//                       // Deselect the appointment
//                       setState(() {
//                         _isSelected = false;
//                       });
//                       ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(8),
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           width: 1,
//                           color: _isSelected
//                               ? Colors.red
//                               : MyColors.colorPalette['outline'] ??
//                                   Colors.blueAccent,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 24,
//                             backgroundColor: MyColors.colorPalette['surface'],
//                             backgroundImage: nextAppointment.patientPicUrl !=
//                                         null &&
//                                     nextAppointment.patientPicUrl!.isNotEmpty
//                                 ? NetworkImage(
//                                     nextAppointment.patientPicUrl!,
//                                   )
//                                 : Image.asset(
//                                     'assets/images/default-image.png',
//                                     color: MyColors.colorPalette['primary'],
//                                     colorBlendMode: BlendMode.color,
//                                   ).image,
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 nextAppointment.patientName,
//                                 style: MyTextStyle.textStyleMap['label-medium']
//                                     ?.copyWith(
//                                   color: MyColors.colorPalette['on_surface'],
//                                 ),
//                               ),
//                               Text(
//                                 'Treatment',
//                                 style: MyTextStyle.textStyleMap['label-small']
//                                     ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on_surface_variant'],
//                                 ),
//                               )
//                             ],
//                           ),
//                           const Spacer(),
//                           GestureDetector(
//                             onTap: () {
//                               // Navigate to treatment landing screen when tapped
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => TreatmentLandingScreen(
//                                     clinicId: widget.clinicId,
//                                     patientId: nextAppointment.patientId,
//                                     patientName: nextAppointment.patientName,
//                                     patientMobileNumber:
//                                         nextAppointment.patientMobileNumber,
//                                     age: nextAppointment.age,
//                                     gender: nextAppointment.gender,
//                                     doctorId: widget.doctorId,
//                                     doctorName: widget.doctorName,
//                                     patientPicUrl:
//                                         nextAppointment.patientPicUrl,
//                                     uhid: nextAppointment.uhid,
//                                     // appointmentDate: nextAppointment.appointmentDate,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: CircleAvatar(
//                               radius: 13.33,
//                               backgroundColor:
//                                   MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent,
//                               child: const Icon(
//                                 Icons.arrow_forward_ios_rounded,
//                                 size: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         } else {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         'Next Appointment',
//                         style:
//                             MyTextStyle.textStyleMap['title-large']?.copyWith(
//                           color: MyColors.colorPalette['on_surface'],
//                         ),
//                       ),
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       // Handle View More button action
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => CalenderView(
//                             doctorId: widget.doctorId,
//                             doctorName: widget.doctorName,
//                             clinicId: widget.clinicId,
//                             patientService: widget.patientService,
//                             showBottomNavigationBar: true,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         'View More',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: MyColors.colorPalette['on-surface-variant'],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: Text(
//                     'No appointments today !',
//                     style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                       color: MyColors.colorPalette['on_surface_variant'],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }
//       },
//     );
//   }
// }

// CODE BELOW IS WITH STREAM BUILDER
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'dart:developer' as devtools show log;

// class NextAppointment extends StatefulWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const NextAppointment({
//     super.key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   });

//   @override
//   State<NextAppointment> createState() => _NextAppointmentState();
// }

// class _NextAppointmentState extends State<NextAppointment> {
//   final AppointmentService _appointmentService = AppointmentService();

//   bool _isSelected = false;
//   Appointment? _nextAppointment;

//   //-------------------------------------------------------------------------//
//   StreamSubscription<Appointment?>? _appointmentSubscription;

//   @override
//   void initState() {
//     super.initState();
//     devtools.log('doctorId is ${widget.doctorId}');
//     devtools.log('clinicId is ${widget.clinicId}');
//     devtools.log('doctorName is ${widget.doctorName}');
//     devtools.log('patientService is ${widget.patientService}');
//     _listenForNextAppointment();
//   }

//   @override
//   void dispose() {
//     _appointmentSubscription?.cancel();
//     super.dispose();
//   }

//   void _listenForNextAppointment() {
//     _appointmentSubscription = _appointmentService
//         .getNextAppointmentStream(
//       doctorId: widget.doctorId,
//       clinicId: widget.clinicId,
//     )
//         .listen((appointment) {
//       if (appointment != null) {
//         // Handle the next appointment
//         setState(() {
//           // Update UI with the next appointment
//           _nextAppointment = appointment;
//         });
//       } else {
//         // Handle case where no upcoming appointment is found
//         setState(() {
//           // Update UI accordingly
//           _nextAppointment = null;
//         });
//       }
//     }, onError: (error) {
//       // Handle error if needed
//       devtools.log('Error fetching next appointment: $error');
//     });
//   }

//   //-------------------------------------------------------------------------//

//   //CODE BELOW IMPLEMENTS LONGPRESS WITH SNACKBAR

//   void _showSelectionSnackbar(Appointment nextAppointment) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Appointment selected'),
//         action: SnackBarAction(
//           label: 'Delete',
//           onPressed: () {
//             // Handle delete action here
//             // For example, you can call a function to delete the appointment
//             _deleteAppointmentAndUpdateSlot(
//               widget.clinicId,
//               widget.doctorName,
//               nextAppointment.appointmentId,
//               nextAppointment.appointmentDate,
//               nextAppointment.slot,
//             );
//             setState(() {
//               _isSelected = false;
//             });
//             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//           },
//         ),
//         behavior: SnackBarBehavior.fixed,
//         duration: const Duration(days: 1),
//       ),
//     );
//   }

//   void _deleteAppointmentAndUpdateSlot(
//     String clinicId,
//     String doctorName,
//     String appointmentId,
//     DateTime appointmentDate,
//     String appointmentSlot,
//   ) async {
//     try {
//       // Other deletion logic

//       // Invoke delete appointment and slot function with callback
//       await _appointmentService.deleteAppointmentAndUpdateSlot(
//         clinicId,
//         doctorName,
//         appointmentId,
//         appointmentDate,
//         appointmentSlot,
//         _onDeleteAppointmentAndUpdateSlotCallback,
//       );

//       // Optionally, you can add code to update the UI or show a confirmation message
//     } catch (e) {
//       // Handle any errors that occur during the deletion process
//       devtools.log('Error deleting appointment and slot: $e');
//       // Optionally, you can show an error message to the user
//     }
//   }

//   //--------------------------------------------------------------------//
//   void _onDeleteAppointmentAndUpdateSlotCallback() {
//     // Fetch and display appointments
//     setState(() {
//       // Fetch appointments again or update the existing data
//       _listenForNextAppointment();
//     });
//   }
//   //--------------------------------------------------------------------//

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to NextAppointment');
//     return StreamBuilder<Appointment?>(
//       stream: _appointmentService.getNextAppointmentStream(
//         doctorId: widget.doctorId,
//         clinicId: widget.clinicId,
//       ),
//       builder: (context, snapshot) {
//         devtools.log('This is coming from inside builder of StreamBuilder');
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         }

//         final nextAppointment = snapshot.data;
//         devtools.log(
//             'nextAppointment fetched successfully which is $nextAppointment');
//         devtools.log(
//             'nextAppointment.appointmentDate is ${nextAppointment?.appointmentDate}');
//         devtools.log(
//             'nextAppointment.appointmentId is ${nextAppointment?.appointmentId}');
//         devtools.log('nextAppointment.slot is ${nextAppointment?.slot}');

//         if (nextAppointment != null) {
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'Next Appointment',
//                           style:
//                               MyTextStyle.textStyleMap['title-large']?.copyWith(
//                             color: MyColors.colorPalette['on_surface'],
//                           ),
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         // Handle View More button action
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => CalenderView(
//                               doctorId: widget.doctorId,
//                               doctorName: widget.doctorName,
//                               clinicId: widget.clinicId,
//                               patientService: widget.patientService,
//                               showBottomNavigationBar: true,
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
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           DateFormat('EEEE, d MMMM, h:mm a')
//                               .format(nextAppointment.appointmentDate),
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['on_surface-variant'],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 GestureDetector(
//                   onLongPress: () {
//                     // Select the appointment
//                     setState(() {
//                       _isSelected = true;
//                     });
//                     // Show snackbar when selected
//                     _showSelectionSnackbar(nextAppointment);
//                   },
//                   onTap: () {
//                     if (_isSelected) {
//                       // Deselect the appointment
//                       setState(() {
//                         _isSelected = false;
//                       });
//                       ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(8),
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           width: 1,
//                           color: _isSelected
//                               ? Colors.red
//                               : MyColors.colorPalette['outline'] ??
//                                   Colors.blueAccent,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 24,
//                             backgroundColor: MyColors.colorPalette['surface'],
//                             backgroundImage: nextAppointment.patientPicUrl !=
//                                         null &&
//                                     nextAppointment.patientPicUrl!.isNotEmpty
//                                 ? NetworkImage(
//                                     nextAppointment.patientPicUrl!,
//                                   )
//                                 : Image.asset(
//                                     'assets/images/default-image.png',
//                                     color: MyColors.colorPalette['primary'],
//                                     colorBlendMode: BlendMode.color,
//                                   ).image,
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 nextAppointment.patientName,
//                                 style: MyTextStyle.textStyleMap['label-medium']
//                                     ?.copyWith(
//                                   color: MyColors.colorPalette['on_surface'],
//                                 ),
//                               ),
//                               Text(
//                                 'Treatment',
//                                 style: MyTextStyle.textStyleMap['label-small']
//                                     ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on_surface_variant'],
//                                 ),
//                               )
//                             ],
//                           ),
//                           const Spacer(),
//                           GestureDetector(
//                             onTap: () {
//                               // Navigate to treatment landing screen when tapped
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => TreatmentLandingScreen(
//                                     clinicId: widget.clinicId,
//                                     patientId: nextAppointment.patientId,
//                                     patientName: nextAppointment.patientName,
//                                     patientMobileNumber:
//                                         nextAppointment.patientMobileNumber,
//                                     age: nextAppointment.age,
//                                     gender: nextAppointment.gender,
//                                     doctorId: widget.doctorId,
//                                     doctorName: widget.doctorName,
//                                     patientPicUrl:
//                                         nextAppointment.patientPicUrl,
//                                     uhid: nextAppointment.uhid,
//                                     // appointmentDate: nextAppointment.appointmentDate,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: CircleAvatar(
//                               radius: 13.33,
//                               backgroundColor:
//                                   MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent,
//                               child: const Icon(
//                                 Icons.arrow_forward_ios_rounded,
//                                 size: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         } else {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         'Next Appointment',
//                         style:
//                             MyTextStyle.textStyleMap['title-large']?.copyWith(
//                           color: MyColors.colorPalette['on_surface'],
//                         ),
//                       ),
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       // Handle View More button action
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => CalenderView(
//                             doctorId: widget.doctorId,
//                             doctorName: widget.doctorName,
//                             clinicId: widget.clinicId,
//                             patientService: widget.patientService,
//                             showBottomNavigationBar: true,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         'View More',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: MyColors.colorPalette['on-surface-variant'],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: Text(
//                     'No appointments today !',
//                     style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                       color: MyColors.colorPalette['on_surface_variant'],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }
//       },
//     );
//   }
// }

// CDOE BELOW IS WITH NORMAL getNextAppointment FUNCTION
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'dart:developer' as devtools show log;

// class NextAppointment extends StatefulWidget {
//   final String doctorId;
//   final String clinicId;
//   final String doctorName;
//   final PatientService patientService;

//   const NextAppointment({
//     super.key,
//     required this.doctorId,
//     required this.clinicId,
//     required this.doctorName,
//     required this.patientService,
//   });

//   @override
//   State<NextAppointment> createState() => _NextAppointmentState();
// }

// class _NextAppointmentState extends State<NextAppointment> {
//   final AppointmentService _appointmentService = AppointmentService();
//   //bool showDeleteIcon = false;
//   bool _isSelected = false;
//   //Appointment? _nextAppointment;

//   @override
//   void initState() {
//     super.initState();
//     devtools.log('doctorId is ${widget.doctorId}');
//     devtools.log('clinicId is ${widget.clinicId}');
//     devtools.log('doctorName is ${widget.doctorName}');
//     devtools.log('patientService is ${widget.patientService}');
//     fetchNextAppointment(); // Call the async method here
//   }

//   Future<Appointment?> fetchNextAppointment() async {
//     final nextAppointment = await _appointmentService.getNextAppointment(
//       doctorId: widget.doctorId,
//       clinicId: widget.clinicId,
//     );

//     return nextAppointment;
//   }

//   //-------------------------------------------------------------------------//

//   //-------------------------------------------------------------------------//

//   //CODE BELOW IMPLEMENTS LONGPRESS WITH SNACKBAR

//   void _showSelectionSnackbar(Appointment nextAppointment) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Appointment selected'),
//         action: SnackBarAction(
//           label: 'Delete',
//           onPressed: () {
//             // Handle delete action here
//             // For example, you can call a function to delete the appointment
//             _deleteAppointmentAndUpdateSlot(
//               widget.clinicId,
//               widget.doctorName,
//               nextAppointment.appointmentId,
//               nextAppointment.appointmentDate,
//               nextAppointment.slot,
//             );
//             setState(() {
//               _isSelected = false;
//             });
//             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//           },
//         ),
//         behavior: SnackBarBehavior.fixed,
//         duration: const Duration(days: 1),
//       ),
//     );
//   }

//   void _deleteAppointmentAndUpdateSlot(
//     String clinicId,
//     String doctorName,
//     String appointmentId,
//     DateTime appointmentDate,
//     String appointmentSlot,
//   ) async {
//     try {
//       // Other deletion logic

//       // Invoke delete appointment and slot function with callback
//       await _appointmentService.deleteAppointmentAndUpdateSlot(
//         clinicId,
//         doctorName,
//         appointmentId,
//         appointmentDate,
//         appointmentSlot,
//         _onDeleteAppointmentAndUpdateSlotCallback,
//       );

//       // Optionally, you can add code to update the UI or show a confirmation message
//     } catch (e) {
//       // Handle any errors that occur during the deletion process
//       devtools.log('Error deleting appointment and slot: $e');
//       // Optionally, you can show an error message to the user
//     }
//   }

//   void _onDeleteAppointmentAndUpdateSlotCallback() {
//     // Fetch and display appointments
//     setState(() {
//       // Fetch appointments again or update the existing data
//       fetchNextAppointment();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to NextAppointment');
//     return FutureBuilder<Appointment?>(
//       future: fetchNextAppointment(),
//       builder: (context, appointmentSnapshot) {
//         if (appointmentSnapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         }

//         final nextAppointment = appointmentSnapshot.data;
//         devtools.log(
//             'nextAppointment fetched successfully which is $nextAppointment');
//         devtools.log(
//             'nextAppointment.appointmentDate is ${nextAppointment?.appointmentDate}');
//         devtools.log(
//             'nextAppointment.appointmentId is ${nextAppointment?.appointmentId}');
//         devtools.log('nextAppointment.slot is ${nextAppointment?.slot}');

//         if (nextAppointment != null) {
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'Next Appointment',
//                           style: MyTextStyle.textStyleMap['title-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['on_surface']),
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         // Handle View More button action
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => CalenderView(
//                               doctorId: widget.doctorId,
//                               doctorName: widget.doctorName,
//                               clinicId: widget.clinicId,
//                               patientService: widget.patientService,
//                               showBottomNavigationBar: true,
//                             ),
//                           ),
//                         );
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'View More',
//                           style: TextStyle(
//                               fontSize: 14,
//                               color:
//                                   MyColors.colorPalette['on-surface-variant']),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           DateFormat('EEEE, d MMMM, h:mm a')
//                               .format(nextAppointment.appointmentDate),
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on_surface-variant']),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 GestureDetector(
//                   onLongPress: () {
//                     // Select the appointment
//                     setState(() {
//                       _isSelected = true;
//                     });
//                     // Show snackbar when selected
//                     //_showSelectionSnackbar();
//                     _showSelectionSnackbar(nextAppointment);
//                   },
//                   onTap: () {
//                     if (_isSelected) {
//                       // Deselect the appointment
//                       setState(() {
//                         _isSelected = false;
//                       });
//                       ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(8),
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           width: 1,
//                           color: _isSelected
//                               ? Colors.red
//                               : MyColors.colorPalette['outline'] ??
//                                   Colors.blueAccent,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 24,
//                             backgroundColor: MyColors.colorPalette['surface'],
//                             backgroundImage: nextAppointment.patientPicUrl !=
//                                         null &&
//                                     nextAppointment.patientPicUrl!.isNotEmpty
//                                 ? NetworkImage(nextAppointment.patientPicUrl!)
//                                 : Image.asset(
//                                     'assets/images/default-image.png',
//                                     color: MyColors.colorPalette['primary'],
//                                     colorBlendMode: BlendMode.color,
//                                   ).image,
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 nextAppointment.patientName,
//                                 style: MyTextStyle.textStyleMap['label-medium']
//                                     ?.copyWith(
//                                         color: MyColors
//                                             .colorPalette['on_surface']),
//                               ),
//                               Text(
//                                 'Treatment',
//                                 style: MyTextStyle.textStyleMap['label-small']
//                                     ?.copyWith(
//                                         color: MyColors.colorPalette[
//                                             'on_surface_variant']),
//                               )
//                             ],
//                           ),
//                           const Spacer(),
//                           GestureDetector(
//                             onTap: () {
//                               // Navigate to treatment landing screen when tapped
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => TreatmentLandingScreen(
//                                     clinicId: widget.clinicId,
//                                     patientId: nextAppointment.patientId,
//                                     patientName: nextAppointment.patientName,
//                                     patientMobileNumber:
//                                         nextAppointment.patientMobileNumber,
//                                     age: nextAppointment.age,
//                                     gender: nextAppointment.gender,
//                                     doctorId: widget.doctorId,
//                                     doctorName: widget.doctorName,
//                                     patientPicUrl:
//                                         nextAppointment.patientPicUrl,
//                                     uhid: nextAppointment.uhid,
//                                     // appointmentDate: nextAppointment.appointmentDate,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: CircleAvatar(
//                               radius: 13.33,
//                               backgroundColor:
//                                   MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent,
//                               child: const Icon(
//                                 Icons.arrow_forward_ios_rounded,
//                                 size: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         } else {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         'Next Appointment',
//                         style: MyTextStyle.textStyleMap['title-large']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['on_surface']),
//                       ),
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       // Handle View More button action
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => CalenderView(
//                             doctorId: widget.doctorId,
//                             doctorName: widget.doctorName,
//                             clinicId: widget.clinicId,
//                             patientService: widget.patientService,
//                             showBottomNavigationBar: true,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         'View More',
//                         style: TextStyle(
//                             fontSize: 14,
//                             color: MyColors.colorPalette['on-surface-variant']),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: Text(
//                     'No appointments today !',
//                     style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                         color: MyColors.colorPalette['on_surface_variant']),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }
//       },
//     );
//   }
// }
