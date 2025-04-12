import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/appointment_service.dart';
import 'package:neocaresmileapp/mywidgets/appointment_provider.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/patient.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as devtools show log;
import 'package:neocaresmileapp/mywidgets/success_appointment_current_patient.dart';
import 'package:provider/provider.dart';

class UIBookAppointmentForCurrentPatient extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String clinicId;
  final String? selectedSlot;
  final DateTime selectedDate;
  final Patient? currentPatient;
  final List<Map<String, dynamic>> slotsForSelectedDayList;
  final VoidCallback? onAppointmentCreated;

  const UIBookAppointmentForCurrentPatient({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
    required this.selectedSlot,
    required this.selectedDate,
    required this.currentPatient,
    required this.slotsForSelectedDayList,
    required this.onAppointmentCreated,
  });

  @override
  State<UIBookAppointmentForCurrentPatient> createState() =>
      _UIBookAppointmentForCurrentPatientState();
}

class _UIBookAppointmentForCurrentPatientState
    extends State<UIBookAppointmentForCurrentPatient> with RouteAware {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Patient? currentPatient;

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _slotsForSelectedDay = [];
  String? selectedSlot = '';
  bool isBookingAppointment = false;
  bool _showProgressIndicator = false;

  @override
  void initState() {
    devtools.log('Welcome to initState method inside BookAppointment');
    super.initState();
    _selectedDate = widget.selectedDate;
    currentPatient = widget.currentPatient;
  }

  Future<void> _bookAppointmentForCurrentPatient(
      String slot, DateTime selectedDate) async {
    if (isBookingAppointment) return; // Prevent multiple booking attempts

    _slotsForSelectedDay = widget.slotsForSelectedDayList;
    devtools.log(
        '@@@@ Inside _bookAppointmentForCurrentPatient. Slots: $_slotsForSelectedDay');

    setState(() {
      isBookingAppointment = true;
      _showProgressIndicator = true;
    });

    try {
      // Convert slot to DateTime
      TimeOfDay slotTime =
          TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(slot));
      DateTime completeDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        slotTime.hour,
        slotTime.minute,
      );
      DateTime completeDateTimeInIst = completeDateTime.toUtc().toLocal();

      // Use AppointmentService to create the appointment
      final appointmentService = AppointmentService();
      await appointmentService.createAppointment(
        doctorId: widget.doctorId,
        clinicId: widget.clinicId,
        patientName: currentPatient!.patientName,
        patientMobileNumber: currentPatient!.patientMobileNumber,
        date: completeDateTimeInIst.toIso8601String(),
        slot: slot,
        age: currentPatient!.age,
        gender: currentPatient!.gender,
        uhid: currentPatient!.uhid ?? '',
        patientPicUrl: currentPatient!.patientPicUrl ?? '',
      );

      // Mark the slot as booked locally
      setState(() {
        for (var slotData in _slotsForSelectedDay) {
          for (var slotEntry in slotData['slots']) {
            if (slotEntry['slot'] == slot) {
              slotEntry['isBooked'] = true; // Mark as booked
            }
          }
        }
      });

      // Update slot availability
      await appointmentService.updateSlotAvailability(
        clinicId: widget.clinicId,
        doctorName: widget.doctorName,
        selectedDate: selectedDate,
        updatedSlots: _slotsForSelectedDay,
      );

      // Notify AppointmentProvider (no need to explicitly fetch next appointment)
      Provider.of<AppointmentProvider>(context, listen: false);

      // Success: Navigate to the success screen
      if (widget.onAppointmentCreated != null) {
        widget.onAppointmentCreated!();
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SuccessAppointmentCurrentPatient(
              clinicId: widget.clinicId,
              doctorId: widget.doctorId,
              patientId: currentPatient!.patientId,
            ),
          ),
        );
      }
    } catch (e) {
      devtools.log('Error booking appointment: $e');
    } finally {
      setState(() {
        isBookingAppointment = false;
        _showProgressIndicator = false;
      });
    }
  }

  // Widget _buildCurrentPatientContainer() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.only(left: 8),
  //               child: Text(
  //                 'Selected Date',
  //                 style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
  //                   color: MyColors.colorPalette['on-surface'],
  //                 ),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(right: 8),
  //               child: Text(
  //                 'Selected Slot',
  //                 style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
  //                   color: MyColors.colorPalette['on-surface'],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Text(
  //                 DateFormat('EEE, MMM d').format(widget.selectedDate),
  //                 style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
  //                   color: MyColors.colorPalette['on-surface'],
  //                 ),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Text(
  //                 widget.selectedSlot ?? 'No Slot Selected',
  //                 style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
  //                   color: MyColors.colorPalette['on-surface'],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 20),
  //         ElevatedButton(
  //           onPressed: widget.selectedSlot != null
  //               ? () {
  //                   _bookAppointmentForCurrentPatient(
  //                       widget.selectedSlot!, widget.selectedDate);
  //                 }
  //               : null,
  //           child: const Text('Create Appointment'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  //-----------------------------------------------------------------------//
  Widget _buildCurrentPatientContainer() {
    currentPatient = widget.currentPatient;
    devtools.log('Welcome to _buildCurrentPatientContainer.');
    devtools.log('currentPatient is $currentPatient');
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selected Date',
                    style: MyTextStyle.textStyleMap['title-medium']
                        ?.copyWith(color: MyColors.colorPalette['on-surface']),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selected Slot',
                    style: MyTextStyle.textStyleMap['title-medium']
                        ?.copyWith(color: MyColors.colorPalette['on-surface']),
                  ),
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    DateFormat('EEE, MMM d').format(widget.selectedDate),
                    style: MyTextStyle.textStyleMap['title-medium']
                        ?.copyWith(color: MyColors.colorPalette['ib-surface']),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.selectedSlot.toString(),
                  style: MyTextStyle.textStyleMap['title-medium']
                      ?.copyWith(color: MyColors.colorPalette['on-surface']),
                ),
              ),
            ],
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color:
                        MyColors.colorPalette['outline'] ?? Colors.blueAccent,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: MyColors.colorPalette['surface'],
                          backgroundImage:
                              currentPatient!.patientPicUrl != null &&
                                      currentPatient!.patientPicUrl!.isNotEmpty
                                  ? NetworkImage(currentPatient!.patientPicUrl!)
                                  : Image.asset(
                                      'assets/images/default-image.png',
                                      color: MyColors.colorPalette['primary'],
                                      colorBlendMode: BlendMode.color,
                                    ).image,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentPatient!.patientName,
                              style: MyTextStyle.textStyleMap['label-medium']
                                  ?.copyWith(
                                      color:
                                          MyColors.colorPalette['on-surface']),
                            ),
                            Row(
                              children: [
                                Text(
                                  currentPatient!.age.toString(),
                                  style: MyTextStyle
                                      .textStyleMap['label-medium']
                                      ?.copyWith(
                                          color: MyColors.colorPalette[
                                              'on-surface-variant']),
                                ),
                                Text(
                                  '/',
                                  style: MyTextStyle
                                      .textStyleMap['label-medium']
                                      ?.copyWith(
                                          color: MyColors.colorPalette[
                                              'on-surface-variant']),
                                ),
                                Text(
                                  currentPatient!.gender,
                                  style: MyTextStyle
                                      .textStyleMap['label-medium']
                                      ?.copyWith(
                                          color: MyColors.colorPalette[
                                              'on-surface-variant']),
                                ),
                              ],
                            ),
                            Text(
                              currentPatient!.patientMobileNumber,
                              style: MyTextStyle.textStyleMap['label-medium']
                                  ?.copyWith(
                                      color: MyColors
                                          .colorPalette['on-surface-variant']),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          //-------------------------------------------------//
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  height: 48,
                  // width: 144,
                  width: 200,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey;
                          } else {
                            return MyColors.colorPalette['primary']!;
                          }
                        },
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
                    onPressed: () {
                      // _bookAppointmentForSelectedPatient(slot, _selectedDate);
                      _bookAppointmentForCurrentPatient(
                          widget.selectedSlot!, widget.selectedDate);
                    },
                    child: Text(
                      'Create Appointment',
                      style: MyTextStyle.textStyleMap['label-large']?.copyWith(
                        color: MyColors.colorPalette['on-primary'],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          //-------------------------------------------------//
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  //-----------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Book Appointment',
          style: MyTextStyle.textStyleMap['title-large']?.copyWith(
            color: MyColors.colorPalette['on-surface'],
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildCurrentPatientContainer(),
          if (_showProgressIndicator)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE BEFORE ALIGNING IT WITH APPOINTMENTPROVIDER WHICH LISTENS TO getNextAppointmentStream
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:intl/intl.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/success_appointment_current_patient.dart';
// import 'package:provider/provider.dart';

// class UIBookAppointmentForCurrentPatient extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final String? selectedSlot;
//   final DateTime selectedDate;
//   final Patient? currentPatient;
//   final List<Map<String, dynamic>> slotsForSelectedDayList;
//   final VoidCallback? onAppointmentCreated;

//   const UIBookAppointmentForCurrentPatient({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.selectedSlot,
//     required this.selectedDate,
//     required this.currentPatient,
//     required this.slotsForSelectedDayList,
//     required this.onAppointmentCreated,
//   });

//   @override
//   State<UIBookAppointmentForCurrentPatient> createState() =>
//       _UIBookAppointmentForCurrentPatientState();
// }

// //----------------------------------------------------------------------//

// //----------------------------------------------------------------------//

// class _UIBookAppointmentForCurrentPatientState
//     extends State<UIBookAppointmentForCurrentPatient> with RouteAware {
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//   Patient? currentPatient;

//   DateTime _selectedDate = DateTime.now(); // Add this line
//   List<Map<String, dynamic>> _slotsForSelectedDay = [];

//   late DateTime now;
//   String? selectedSlot = '';
//   bool isBookingAppointment = false;
//   bool isSlotSelected = false;
//   bool _showProgressIndicator = false;

//   @override
//   void initState() {
//     devtools.log('Welcome to initState method inside BookAppointment');
//     super.initState();
//     now = DateTime.now();
//     _selectedDate = DateTime.now(); // Set the selected date to the current date
//   }

//   // void _bookAppointmentForCurrentPatient(
//   //     String slot, DateTime selectedDate) async {
//   //   if (isBookingAppointment) return; // Prevent multiple booking attempts

//   //   _slotsForSelectedDay = widget.slotsForSelectedDayList;
//   //   devtools.log(
//   //       '@@@@ Welcome inside _bookAppointmentForCurrentPatient defined inside UI. _slotsForSelectedDay just populated and is $_slotsForSelectedDay');

//   //   setState(() {
//   //     isBookingAppointment = true;
//   //     _showProgressIndicator = true;
//   //   });

//   //   try {
//   //     // Convert slot to TimeOfDay and then to a DateTime
//   //     TimeOfDay slotTime =
//   //         TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(slot));
//   //     DateTime completeDateTime = DateTime(
//   //       selectedDate.year,
//   //       selectedDate.month,
//   //       selectedDate.day,
//   //       slotTime.hour,
//   //       slotTime.minute,
//   //     );
//   //     DateTime completeDateTimeInIst = completeDateTime.toUtc().toLocal();

//   //     // Capture the AppointmentProvider before the async call
//   //     final appointmentProvider =
//   //         Provider.of<AppointmentProvider>(context, listen: false);

//   //     // Use AppointmentService to create the appointment
//   //     final appointmentService = AppointmentService();
//   //     await appointmentService.createAppointment(
//   //       doctorId: widget.doctorId,
//   //       clinicId: widget.clinicId,
//   //       patientName: currentPatient!.patientName,
//   //       patientMobileNumber: currentPatient!.patientMobileNumber,
//   //       date:
//   //           completeDateTimeInIst.toIso8601String(), // Pass date as ISO string
//   //       slot: slot,
//   //     );

//   //     // *** Update slot as booked locally first ***
//   //     setState(() {
//   //       for (var slotData in _slotsForSelectedDay) {
//   //         for (var slotEntry in slotData['slots']) {
//   //           if (slotEntry['slot'] == slot) {
//   //             slotEntry['isBooked'] = true; // Mark as booked
//   //           }
//   //         }
//   //       }
//   //     });

//   //     // Update slot availability
//   //     //await updateSlotAvailability(selectedDate, _slotsForSelectedDay);

//   //     await appointmentService.updateSlotAvailability(
//   //       clinicId: widget.clinicId,
//   //       doctorName: widget.doctorName,
//   //       selectedDate: selectedDate,
//   //       updatedSlots: _slotsForSelectedDay,
//   //     );

//   //     // Notify AppointmentProvider to refresh appointments
//   //     await appointmentProvider.fetchNextAppointment();

//   //     // Success: Navigate to the success screen
//   //     if (widget.onAppointmentCreated != null) {
//   //       widget.onAppointmentCreated!();
//   //     }

//   //     if (mounted) {
//   //       Navigator.of(context).push(
//   //         MaterialPageRoute(
//   //           builder: (context) => SuccessAppointmentCurrentPatient(
//   //             clinicId: widget.clinicId,
//   //             doctorId: widget.doctorId,
//   //             patientId: currentPatient!.patientId,
//   //           ),
//   //         ),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     devtools.log('Error booking appointment: $e');
//   //   } finally {
//   //     setState(() {
//   //       isBookingAppointment = false;
//   //       _showProgressIndicator = false;
//   //     });
//   //   }
//   // }

//   void _bookAppointmentForCurrentPatient(
//       String slot, DateTime selectedDate) async {
//     if (isBookingAppointment) return; // Prevent multiple booking attempts

//     _slotsForSelectedDay = widget.slotsForSelectedDayList;
//     devtools.log(
//         '@@@@ Welcome inside _bookAppointmentForCurrentPatient defined inside UI. _slotsForSelectedDay just populated and is $_slotsForSelectedDay');

//     setState(() {
//       isBookingAppointment = true;
//       _showProgressIndicator = true;
//     });

//     try {
//       // Convert slot to TimeOfDay and then to a DateTime
//       TimeOfDay slotTime =
//           TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(slot));
//       DateTime completeDateTime = DateTime(
//         selectedDate.year,
//         selectedDate.month,
//         selectedDate.day,
//         slotTime.hour,
//         slotTime.minute,
//       );
//       DateTime completeDateTimeInIst = completeDateTime.toUtc().toLocal();

//       // Capture the AppointmentProvider before the async call
//       final appointmentProvider =
//           Provider.of<AppointmentProvider>(context, listen: false);

//       // Use AppointmentService to create the appointment, passing all patient details
//       final appointmentService = AppointmentService();
//       await appointmentService.createAppointment(
//         doctorId: widget.doctorId,
//         clinicId: widget.clinicId,
//         patientName: currentPatient!.patientName,
//         patientMobileNumber: currentPatient!.patientMobileNumber,
//         date:
//             completeDateTimeInIst.toIso8601String(), // Pass date as ISO string
//         slot: slot,
//         age: currentPatient!.age, // Add age
//         gender: currentPatient!.gender, // Add gender
//         uhid: currentPatient!.uhid ?? '', // Add uhid (use empty string if null)
//         patientPicUrl: currentPatient!.patientPicUrl ?? '', // Add patientPicUrl
//       );

//       // *** Update slot as booked locally first ***
//       setState(() {
//         for (var slotData in _slotsForSelectedDay) {
//           for (var slotEntry in slotData['slots']) {
//             if (slotEntry['slot'] == slot) {
//               slotEntry['isBooked'] = true; // Mark as booked
//             }
//           }
//         }
//       });

//       // Update slot availability using AppointmentService
//       await appointmentService.updateSlotAvailability(
//         clinicId: widget.clinicId,
//         doctorName: widget.doctorName,
//         selectedDate: selectedDate,
//         updatedSlots: _slotsForSelectedDay,
//       );

//       // Notify AppointmentProvider to refresh appointments
//       await appointmentProvider.fetchNextAppointment();

//       // Success: Navigate to the success screen
//       if (widget.onAppointmentCreated != null) {
//         widget.onAppointmentCreated!();
//       }

//       if (mounted) {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => SuccessAppointmentCurrentPatient(
//               clinicId: widget.clinicId,
//               doctorId: widget.doctorId,
//               patientId: currentPatient!.patientId,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       devtools.log('Error booking appointment: $e');
//     } finally {
//       setState(() {
//         isBookingAppointment = false;
//         _showProgressIndicator = false;
//       });
//     }
//   }

//   //-------------------------------------------------------------------------------//

//   Widget _buildCurrentPatientContainer() {
//     currentPatient = widget.currentPatient;
//     devtools.log('Welcome to _buildCurrentPatientContainer.');
//     devtools.log('currentPatient is $currentPatient');
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Selected Date',
//                     style: MyTextStyle.textStyleMap['title-medium']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Selected Slot',
//                     style: MyTextStyle.textStyleMap['title-medium']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     DateFormat('EEE, MMM d').format(widget.selectedDate),
//                     style: MyTextStyle.textStyleMap['title-medium']
//                         ?.copyWith(color: MyColors.colorPalette['ib-surface']),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   widget.selectedSlot.toString(),
//                   style: MyTextStyle.textStyleMap['title-medium']
//                       ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                 ),
//               ),
//             ],
//           ),

//           Align(
//             alignment: Alignment.topCenter,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     width: 1,
//                     color:
//                         MyColors.colorPalette['outline'] ?? Colors.blueAccent,
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: IntrinsicHeight(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Align(
//                         alignment: Alignment.topLeft,
//                         child: CircleAvatar(
//                           radius: 24,
//                           backgroundColor: MyColors.colorPalette['surface'],
//                           backgroundImage:
//                               currentPatient!.patientPicUrl != null &&
//                                       currentPatient!.patientPicUrl!.isNotEmpty
//                                   ? NetworkImage(currentPatient!.patientPicUrl!)
//                                   : Image.asset(
//                                       'assets/images/default-image.png',
//                                       color: MyColors.colorPalette['primary'],
//                                       colorBlendMode: BlendMode.color,
//                                     ).image,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               currentPatient!.patientName,
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-surface']),
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   currentPatient!.age.toString(),
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant']),
//                                 ),
//                                 Text(
//                                   '/',
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant']),
//                                 ),
//                                 Text(
//                                   currentPatient!.gender,
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant']),
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               currentPatient!.patientMobileNumber,
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                       color: MyColors
//                                           .colorPalette['on-surface-variant']),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),

//           //-------------------------------------------------//
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 SizedBox(
//                   height: 48,
//                   // width: 144,
//                   width: 200,
//                   child: ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.resolveWith<Color>(
//                         (Set<MaterialState> states) {
//                           if (states.contains(MaterialState.disabled)) {
//                             return Colors.grey;
//                           } else {
//                             return MyColors.colorPalette['primary']!;
//                           }
//                         },
//                       ),
//                       shape: MaterialStateProperty.all(
//                         RoundedRectangleBorder(
//                           side: BorderSide(
//                             color: MyColors.colorPalette['primary']!,
//                             width: 1.0,
//                           ),
//                           borderRadius: BorderRadius.circular(24.0),
//                         ),
//                       ),
//                     ),
//                     onPressed: () {
//                       // _bookAppointmentForSelectedPatient(slot, _selectedDate);
//                       _bookAppointmentForCurrentPatient(
//                           widget.selectedSlot!, widget.selectedDate);
//                     },
//                     child: Text(
//                       'Create Appointment',
//                       style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                         color: MyColors.colorPalette['on-primary'],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           //-------------------------------------------------//
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log(
//         'slotsForSelectedDayList received inside UIBookAppointmentForSelectedPatient are: ${widget.slotsForSelectedDayList}');
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Book Appointment',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//       ),
//       body: Stack(
//         children: [
//           _buildCurrentPatientContainer(),
//           // Circular progress indicator
//           if (_showProgressIndicator)
//             const Center(
//               child: CircularProgressIndicator(),
//             ),
//         ],
//       ),
//     );
//   }
// }

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW STABLE WITH DIRECT BACKEND CALLS TOO
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:intl/intl.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/success_appointment_current_patient.dart';
// import 'package:provider/provider.dart';

// class UIBookAppointmentForCurrentPatient extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final String? selectedSlot;
//   final DateTime selectedDate;
//   final Patient? currentPatient;
//   final List<Map<String, dynamic>> slotsForSelectedDayList;
//   final VoidCallback? onAppointmentCreated;

//   const UIBookAppointmentForCurrentPatient({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.selectedSlot,
//     required this.selectedDate,
//     required this.currentPatient,
//     required this.slotsForSelectedDayList,
//     required this.onAppointmentCreated,
//   });

//   @override
//   State<UIBookAppointmentForCurrentPatient> createState() =>
//       _UIBookAppointmentForCurrentPatientState();
// }

// //----------------------------------------------------------------------//

// //----------------------------------------------------------------------//

// class _UIBookAppointmentForCurrentPatientState
//     extends State<UIBookAppointmentForCurrentPatient> with RouteAware {
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//   Patient? currentPatient;

//   DateTime _selectedDate = DateTime.now(); // Add this line
//   List<Map<String, dynamic>> _slotsForSelectedDay = [];

//   late DateTime now;
//   String? selectedSlot = '';
//   bool isBookingAppointment = false;
//   bool isSlotSelected = false;
//   bool _showProgressIndicator = false;

//   @override
//   void initState() {
//     devtools.log('Welcome to initState method inside BookAppointment');
//     super.initState();
//     now = DateTime.now();
//     _selectedDate = DateTime.now(); // Set the selected date to the current date
//   }

//   void _bookAppointmentForCurrentPatient(
//       String slot, DateTime selectedDate) async {
//     _slotsForSelectedDay = widget.slotsForSelectedDayList;
//     devtools.log(
//         'Welcome to _bookAppointmentForSelectedPatient. _slotsForSelectedDay after being populated are $_slotsForSelectedDay');
//     if (isBookingAppointment) {
//       return; // Prevent multiple button presses while booking is in progress
//     }
//     setState(() {
//       isBookingAppointment = true;
//       _showProgressIndicator = true; // Set the flag to true when booking starts
//     });

//     devtools.log('selected slot is $slot');
//     devtools.log('selected date  is $selectedDate');

//     try {
//       TimeOfDay slotTime =
//           TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(slot));

//       devtools.log('convertd slotTime is $slotTime');

//       DateTime completeDateTime = DateTime(selectedDate.year,
//           selectedDate.month, selectedDate.day, slotTime.hour, slotTime.minute);

//       devtools.log('convertd completeDateTime is $completeDateTime');

//       DateTime completeDateTimeInUtc = completeDateTime.toUtc();

//       devtools.log('convertd completeDateTimeInUtc is $completeDateTimeInUtc');

//       DateTime completeDateTimeInIst = completeDateTimeInUtc.toLocal();

//       devtools.log('convertd completeDateTimeInIst is $completeDateTimeInIst');

//       // Capture the AppointmentProvider before the async call
//       final appointmentProvider =
//           Provider.of<AppointmentProvider>(context, listen: false);

//       //CAPTURE treatmentId here//
//       final patientRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(currentPatient!.patientId);

//       // Check if the patient document has a 'treatments' sub-collection
//       final treatmentsSnapshot =
//           await patientRef.collection('treatments').get();

//       String? treatmentId;
//       if (treatmentsSnapshot.docs.isNotEmpty) {
//         final latestTreatmentDoc = treatmentsSnapshot.docs.last;
//         treatmentId = latestTreatmentDoc['treatmentId'];
//       }
//       final appointmentData = {
//         'patientName': currentPatient!.patientName,
//         'age': currentPatient!.age,
//         'gender': currentPatient!.gender,
//         'patientMobileNumber': currentPatient!.patientMobileNumber,
//         'patientId': currentPatient!.patientId,
//         'doctorId': widget.doctorId,
//         'uhid': currentPatient!.uhid,
//         'slot': slot,
//         'date':
//             Timestamp.fromDate(completeDateTimeInIst), // Convert to Timestamp
//         'treatmentId': treatmentId,
//         'patientPicUrl': currentPatient!.patientPicUrl,
//       };

//       devtools.log('completeDateTime is $completeDateTime');
//       devtools.log('completeDateTimeInUtc is $completeDateTimeInUtc');

//       final clinicRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('appointments');

//       // Add the appointment data to the clinic's appointments sub-collection
//       final clinicAppointmentDocRef = await clinicRef.add(appointmentData);

//       final appointmentId = clinicAppointmentDocRef
//           .id; // Assign appointmentId to the instance variable

//       // Update the appointment document with the obtained appointmentId
//       await clinicAppointmentDocRef.update({'appointmentId': appointmentId});

//       // Update the patient's document with the appointment data

//       await patientRef.collection('appointments').add({
//         'date':
//             Timestamp.fromDate(completeDateTimeInIst), // Convert to Timestamp
//         'treatmentId': treatmentId,
//         'appointmentId':
//             appointmentId, // Add appointmentId to patient's appointment document
//       });

//       devtools.log(
//           'Appointment booked successfully. Appointment Id is $appointmentId');

//       List<Map<String, dynamic>> updatedSlots =
//           List.from(_slotsForSelectedDay); // Make a copy of the existing slots
//       devtools.log('***********************************************');
//       devtools.log('_slotsForSelectedDay are $_slotsForSelectedDay');
//       devtools.log('***********************************************');

//       setState(() {
//         devtools.log('Inside setState block');
//         for (var slotData in _slotsForSelectedDay) {
//           devtools.log('Entering outer for loop');
//           for (var slotEntry in slotData['slots']) {
//             devtools.log('Entering inner for loop');
//             if (slotEntry['slot'] == slot) {
//               slotEntry['isBooked'] = true;
//               slotEntry['isCancelled'] = false;
//               devtools
//                   .log('-----------------------------------------------------');
//               devtools
//                   .log('Updated slotData for $slot: ${slotEntry['isBooked']}');
//               devtools
//                   .log('-----------------------------------------------------');
//             }
//           }
//         }
//         devtools.log('Exiting setState block');
//       });
//       // Update the state with the updated slots
//       setState(() {
//         updatedSlots = List.from(_slotsForSelectedDay);
//       });

//       await updateSlotAvailability(selectedDate, updatedSlots);
//       // -------------------------------------------------------------------//
//       // Call the onAppointmentCreated callback if it is provided
//       if (widget.onAppointmentCreated != null) {
//         devtools.log(
//             'onAppointmentCreated invoked from inside UIBookAppointmentForCurrentPatien. ');
//         widget.onAppointmentCreated!();
//       }

//       //-------------------------------------------------------------------//
//       // Notify AppointmentProvider to refresh appointments

//       await appointmentProvider.fetchNextAppointment();
//       //--------------------------------------------------------------------//

//       // Navigate to the SuccessAppointment screen

//       // ignore: use_build_context_synchronously
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => SuccessAppointmentCurrentPatient(
//             clinicId: widget.clinicId,
//             doctorId: widget.doctorId,
//             patientId: currentPatient!.patientId,
//           ),
//         ),
//       );

//       //-------------------------------------------------------------------//
//     } catch (e) {
//       // Handle any errors
//       devtools.log('Error booking appointment: $e');
//     } finally {
//       // Set the flag back to false when booking is complete
//       setState(() {
//         isBookingAppointment = false;
//         _showProgressIndicator = false;
//       });
//     }
//   }

//   Future<void> updateSlotAvailability(
//       DateTime selectedDate, List<Map<String, dynamic>> updatedSlots) async {
//     devtools.log('Welcome to updateSlotAvailability');
//     devtools.log('updatedSlots are $updatedSlots');
//     try {
//       final selectedDateFormatted = DateFormat('d-MMMM')
//           .format(selectedDate); // Format the selected date as 'day-month'
//       final doctorDocumentRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('availableSlots')
//           .doc('Dr${widget.doctorName}')
//           .collection('selectedDateSlots')
//           .doc(selectedDateFormatted);

//       final slotsData = <String, dynamic>{
//         'slots': updatedSlots,
//       };

//       await doctorDocumentRef.set(slotsData);
//     } catch (error) {
//       devtools.log('Error updating slot availability: $error');
//     }
//   }

//   Widget _buildCurrentPatientContainer() {
//     currentPatient = widget.currentPatient;
//     devtools.log('Welcome to _buildCurrentPatientContainer.');
//     devtools.log('currentPatient is $currentPatient');
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Selected Date',
//                     style: MyTextStyle.textStyleMap['title-medium']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Selected Slot',
//                     style: MyTextStyle.textStyleMap['title-medium']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     DateFormat('EEE, MMM d').format(widget.selectedDate),
//                     style: MyTextStyle.textStyleMap['title-medium']
//                         ?.copyWith(color: MyColors.colorPalette['ib-surface']),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   widget.selectedSlot.toString(),
//                   style: MyTextStyle.textStyleMap['title-medium']
//                       ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                 ),
//               ),
//             ],
//           ),

//           Align(
//             alignment: Alignment.topCenter,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     width: 1,
//                     color:
//                         MyColors.colorPalette['outline'] ?? Colors.blueAccent,
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: IntrinsicHeight(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Align(
//                         alignment: Alignment.topLeft,
//                         child: CircleAvatar(
//                           radius: 24,
//                           backgroundColor: MyColors.colorPalette['surface'],
//                           backgroundImage:
//                               currentPatient!.patientPicUrl != null &&
//                                       currentPatient!.patientPicUrl!.isNotEmpty
//                                   ? NetworkImage(currentPatient!.patientPicUrl!)
//                                   : Image.asset(
//                                       'assets/images/default-image.png',
//                                       color: MyColors.colorPalette['primary'],
//                                       colorBlendMode: BlendMode.color,
//                                     ).image,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               currentPatient!.patientName,
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-surface']),
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   currentPatient!.age.toString(),
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant']),
//                                 ),
//                                 Text(
//                                   '/',
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant']),
//                                 ),
//                                 Text(
//                                   currentPatient!.gender,
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant']),
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               currentPatient!.patientMobileNumber,
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                       color: MyColors
//                                           .colorPalette['on-surface-variant']),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),

//           //-------------------------------------------------//
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 SizedBox(
//                   height: 48,
//                   // width: 144,
//                   width: 200,
//                   child: ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.resolveWith<Color>(
//                         (Set<MaterialState> states) {
//                           if (states.contains(MaterialState.disabled)) {
//                             return Colors.grey;
//                           } else {
//                             return MyColors.colorPalette['primary']!;
//                           }
//                         },
//                       ),
//                       shape: MaterialStateProperty.all(
//                         RoundedRectangleBorder(
//                           side: BorderSide(
//                             color: MyColors.colorPalette['primary']!,
//                             width: 1.0,
//                           ),
//                           borderRadius: BorderRadius.circular(24.0),
//                         ),
//                       ),
//                     ),
//                     onPressed: () {
//                       // _bookAppointmentForSelectedPatient(slot, _selectedDate);
//                       _bookAppointmentForCurrentPatient(
//                           widget.selectedSlot!, widget.selectedDate);
//                     },
//                     child: Text(
//                       'Create Appointment',
//                       style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                         color: MyColors.colorPalette['on-primary'],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           //-------------------------------------------------//
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log(
//         'slotsForSelectedDayList received inside UIBookAppointmentForSelectedPatient are: ${widget.slotsForSelectedDayList}');
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Book Appointment',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//       ),
//       body: Stack(
//         children: [
//           _buildCurrentPatientContainer(),
//           // Circular progress indicator
//           if (_showProgressIndicator)
//             const Center(
//               child: CircularProgressIndicator(),
//             ),
//         ],
//       ),
//     );
//   }
// }
