import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/appointment_service.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import 'package:neocaresmileapp/mywidgets/appointment_provider.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/patient.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/mywidgets/success_appointment.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

class UIBookAppointmentForSelectedPatient extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String clinicId;
  final PatientService patientService;
  final String? selectedSlot;
  final DateTime selectedDate;
  final Patient? selectedPatient;
  final List<Map<String, dynamic>> slotsForSelectedDayList;

  const UIBookAppointmentForSelectedPatient({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
    required this.patientService,
    required this.selectedSlot,
    required this.selectedDate,
    required this.selectedPatient,
    required this.slotsForSelectedDayList,
  });

  @override
  State<UIBookAppointmentForSelectedPatient> createState() =>
      _UIBookAppointmentForSelectedPatientState();
}

class _UIBookAppointmentForSelectedPatientState
    extends State<UIBookAppointmentForSelectedPatient> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Patient? selectedPatient;
  bool isBookingAppointment = false;
  bool _showProgressIndicator = false;

  @override
  void initState() {
    devtools.log('Welcome to initState of UIBookAppointmentForSelectedPatient');
    super.initState();
    selectedPatient = widget.selectedPatient;
  }

  Future<void> _bookAppointmentForSelectedPatient(
      String slot, DateTime selectedDate) async {
    if (isBookingAppointment) return; // Prevent multiple booking attempts

    final slotsForSelectedDay = widget.slotsForSelectedDayList;

    setState(() {
      isBookingAppointment = true;
      _showProgressIndicator = true;
    });

    try {
      // Use AppointmentService to create the appointment
      final appointmentService = AppointmentService();
      await appointmentService.createAppointmentForSelectedPatient(
        clinicId: widget.clinicId,
        doctorId: widget.doctorId,
        selectedPatient: selectedPatient!,
        slot: slot,
        selectedDate: selectedDate,
      );

      // Mark the slot as booked locally
      setState(() {
        for (var slotData in slotsForSelectedDay) {
          for (var slotEntry in slotData['slots']) {
            if (slotEntry['slot'] == slot) {
              slotEntry['isBooked'] = true;
            }
          }
        }
      });

      // Update slot availability
      await appointmentService.updateSlotAvailability(
        clinicId: widget.clinicId,
        doctorName: widget.doctorName,
        selectedDate: selectedDate,
        updatedSlots: slotsForSelectedDay,
      );

      // Navigate to the success screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SuccessAppointment(
              clinicId: widget.clinicId,
              doctorId: widget.doctorId,
              patientId: selectedPatient!.patientId,
              doctorName: widget.doctorName,
              patientService: widget.patientService,
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

  // Widget _buildSelectedPatientContainer() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       children: [
  //         // Selected Date and Slot
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Text(
  //                 'Selected Date',
  //                 style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
  //                   color: MyColors.colorPalette['on-surface'],
  //                 ),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.all(8.0),
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
  //         // Patient Details
  //         Align(
  //           alignment: Alignment.topCenter,
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Container(
  //               padding: const EdgeInsets.all(16),
  //               decoration: BoxDecoration(
  //                 border: Border.all(
  //                   color:
  //                       MyColors.colorPalette['outline'] ?? Colors.blueAccent,
  //                 ),
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: Row(
  //                 children: [
  //                   CircleAvatar(
  //                     radius: 24,
  //                     backgroundImage: selectedPatient?.patientPicUrl != null &&
  //                             selectedPatient!.patientPicUrl!.isNotEmpty
  //                         ? NetworkImage(selectedPatient!.patientPicUrl!)
  //                         : const AssetImage('assets/images/default-image.png')
  //                             as ImageProvider,
  //                   ),
  //                   const SizedBox(width: 16),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         selectedPatient?.patientName ?? 'No Name',
  //                         style: MyTextStyle.textStyleMap['label-medium']
  //                             ?.copyWith(
  //                           color: MyColors.colorPalette['on-surface'],
  //                         ),
  //                       ),
  //                       Text(
  //                         '${selectedPatient?.age ?? '--'}/${selectedPatient?.gender ?? '--'}',
  //                         style: MyTextStyle.textStyleMap['label-medium']
  //                             ?.copyWith(
  //                           color: MyColors.colorPalette['on-surface-variant'],
  //                         ),
  //                       ),
  //                       Text(
  //                         selectedPatient?.patientMobileNumber ?? 'No Contact',
  //                         style: MyTextStyle.textStyleMap['label-medium']
  //                             ?.copyWith(
  //                           color: MyColors.colorPalette['on-surface-variant'],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //         // Create Appointment Button
  //         const SizedBox(height: 20),
  //         ElevatedButton(
  //           onPressed: widget.selectedSlot != null
  //               ? () {
  //                   _bookAppointmentForSelectedPatient(
  //                       widget.selectedSlot!, widget.selectedDate);
  //                 }
  //               : null,
  //           child: const Text('Create Appointment'),
  //         ),
  //         const SizedBox(height: 20),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSelectedPatientContainer() {
    selectedPatient = widget.selectedPatient;
    devtools.log('Welcome to _buildSelectedPatientContainer.');
    devtools.log('selectedPatient is $selectedPatient');
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
                    // DateFormat('EEE, MMM d').format(_selectedDate),
                    DateFormat('EEE, MMM d').format(widget.selectedDate),
                    style: MyTextStyle.textStyleMap['title-medium']
                        ?.copyWith(color: MyColors.colorPalette['ib-surface']),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  // slot,
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
                    //color: Colors.blueAccent,
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
                          // backgroundImage: selectedPatient!['patientPicUrl'] !=
                          //             null &&
                          //         selectedPatient!['patientPicUrl']!.isNotEmpty
                          //     ? NetworkImage(selectedPatient!['patientPicUrl']!)
                          backgroundImage: selectedPatient!.patientPicUrl !=
                                      null &&
                                  selectedPatient!.patientPicUrl!.isNotEmpty
                              ? NetworkImage(selectedPatient!.patientPicUrl!)
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
                              // '${selectedPatient!['patientName']}',
                              selectedPatient!.patientName,
                              style: MyTextStyle.textStyleMap['label-medium']
                                  ?.copyWith(
                                      color:
                                          MyColors.colorPalette['on-surface']),
                            ),
                            Row(
                              children: [
                                Text(
                                  // '${selectedPatient!['age']}',
                                  selectedPatient!.age.toString(),
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
                                  // '${selectedPatient!['gender']}',
                                  selectedPatient!.gender,
                                  style: MyTextStyle
                                      .textStyleMap['label-medium']
                                      ?.copyWith(
                                          color: MyColors.colorPalette[
                                              'on-surface-variant']),
                                ),
                              ],
                            ),
                            Text(
                              // '${selectedPatient!['patientMobileNumber']}',
                              selectedPatient!.patientMobileNumber,
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
                      _bookAppointmentForSelectedPatient(
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
          _buildSelectedPatientContainer(),
          if (_showProgressIndicator)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

// CODE BELOW STABLE BEFORE ALIGNMENT OF APPOINTMENTPROVIDER WITH getNextAppointmentStream
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/success_appointment.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'dart:developer' as devtools show log;

// class UIBookAppointmentForSelectedPatient extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;
//   final String? selectedSlot;
//   final DateTime selectedDate;
//   final Patient? selectedPatient;
//   final List<Map<String, dynamic>> slotsForSelectedDayList;

//   const UIBookAppointmentForSelectedPatient({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.patientService,
//     required this.selectedSlot,
//     required this.selectedDate,
//     required this.selectedPatient,
//     required this.slotsForSelectedDayList,
//   });

//   @override
//   State<UIBookAppointmentForSelectedPatient> createState() =>
//       _UIBookAppointmentForSelectedPatientState();
// }

// class _UIBookAppointmentForSelectedPatientState
//     extends State<UIBookAppointmentForSelectedPatient> with RouteAware {
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//   Patient? selectedPatient;

//   DateTime _focusedDay = DateTime.now(); // Initial date in IST

//   CalendarFormat _calendarFormat =
//       CalendarFormat.week; // Choose your desired format

//   DateTime _selectedDate = DateTime.now(); // Add this line
//   List<Map<String, dynamic>> _slotsForSelectedDay = [];

//   bool _isDateSelected = false;

//   final List<Map<String, dynamic>> _appointmentsForSelectedDate = [];
//   late DateTime now;
//   bool _showPatientSearchWidget = false;

//   String? selectedSlot = '';
//   bool isBookingAppointment = false;
//   bool isSlotSelected = false;
//   Patient? newPatient;
//   bool _showSelectedPatientDetails = false;
//   bool _showAddedPatientDetails = false;

//   bool isSearchAndAddPatientOpened = false;
//   bool _showProgressIndicator = false;

//   @override
//   void initState() {
//     devtools.log('Welcome to initState method inside BookAppointment');
//     super.initState();
//     now = DateTime.now();
//     _selectedDate = DateTime.now(); // Set the selected date to the current date
//   }

//   void _bookAppointmentForSelectedPatient(
//       String slot, DateTime selectedDate) async {
//     if (isBookingAppointment) return; // Prevent multiple booking attempts
//     _slotsForSelectedDay = widget.slotsForSelectedDayList;
//     devtools.log(
//         '@@@@ Welcome inside _bookAppointmentForSelectedPatient defined inside UI. _slotsForSelectedDay just populated and is $_slotsForSelectedDay');

//     setState(() {
//       isBookingAppointment = true;
//       _showProgressIndicator = true;
//     });

//     try {
//       // Use AppointmentService to handle backend logic
//       final appointmentService = AppointmentService();
//       await appointmentService.createAppointmentForSelectedPatient(
//         clinicId: widget.clinicId,
//         doctorId: widget.doctorId,
//         selectedPatient: selectedPatient!,
//         slot: slot,
//         selectedDate: selectedDate,
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

//       // Now call the service to update availability in Firestore
//       // await appointmentService.updateSlotAvailability(
//       await appointmentService.updateSlotAvailability(
//         clinicId: widget.clinicId,
//         doctorName: widget.doctorName,
//         selectedDate: selectedDate,
//         updatedSlots: _slotsForSelectedDay,
//       );

//       // Notify AppointmentProvider
//       final appointmentProvider =
//           Provider.of<AppointmentProvider>(context, listen: false);
//       await appointmentProvider.fetchNextAppointment();

//       // Navigate to success screen
//       if (mounted) {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => SuccessAppointment(
//               clinicId: widget.clinicId,
//               doctorId: widget.doctorId,
//               patientId: selectedPatient!.patientId,
//               doctorName: widget.doctorName,
//               patientService: widget.patientService,
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

//   // Future<void> updateSlotAvailability(
//   //     DateTime selectedDate, List<Map<String, dynamic>> updatedSlots) async {
//   //   devtools.log(
//   //       'Welcome to updateSlotAvailability defined inside UIBookAppoitmentForSelectedPatient. updatedSlots are $updatedSlots');

//   //   try {
//   //     // Capture AppointmentService instance
//   //     final appointmentService = AppointmentService();

//   //     // Use AppointmentService to update slot availability
//   //     await appointmentService.updateSlotAvailability(
//   //       clinicId: widget.clinicId,
//   //       doctorName: widget.doctorName,
//   //       selectedDate: selectedDate,
//   //       updatedSlots: updatedSlots,
//   //     );
//   //   } catch (e) {
//   //     devtools.log('Error updating slot availability: $e');
//   //   }
//   // }

//   //****************************************************************************//
//   // START OF _buildSelectedPatientContainer FUNCTION //
//   // Widget _buildSelectedPatientContainer(String slot) {
//   Widget _buildSelectedPatientContainer() {
//     selectedPatient = widget.selectedPatient;
//     devtools.log('Welcome to _buildSelectedPatientContainer.');
//     devtools.log('selectedPatient is $selectedPatient');
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
//                     // DateFormat('EEE, MMM d').format(_selectedDate),
//                     DateFormat('EEE, MMM d').format(widget.selectedDate),
//                     style: MyTextStyle.textStyleMap['title-medium']
//                         ?.copyWith(color: MyColors.colorPalette['ib-surface']),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   // slot,
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
//                     //color: Colors.blueAccent,
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
//                           // backgroundImage: selectedPatient!['patientPicUrl'] !=
//                           //             null &&
//                           //         selectedPatient!['patientPicUrl']!.isNotEmpty
//                           //     ? NetworkImage(selectedPatient!['patientPicUrl']!)
//                           backgroundImage: selectedPatient!.patientPicUrl !=
//                                       null &&
//                                   selectedPatient!.patientPicUrl!.isNotEmpty
//                               ? NetworkImage(selectedPatient!.patientPicUrl!)
//                               : Image.asset(
//                                   'assets/images/default-image.png',
//                                   color: MyColors.colorPalette['primary'],
//                                   colorBlendMode: BlendMode.color,
//                                 ).image,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               // '${selectedPatient!['patientName']}',
//                               selectedPatient!.patientName,
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-surface']),
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   // '${selectedPatient!['age']}',
//                                   selectedPatient!.age.toString(),
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
//                                   // '${selectedPatient!['gender']}',
//                                   selectedPatient!.gender,
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant']),
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               // '${selectedPatient!['patientMobileNumber']}',
//                               selectedPatient!.patientMobileNumber,
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
//                       _bookAppointmentForSelectedPatient(
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

//   // END OF _buildSelectedPatientContainer //

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
//       //body: _buildSelectedPatientContainer(),
//       body: Stack(
//         children: [
//           _buildSelectedPatientContainer(),
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

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW STABLE WITH DIRECT BACKEND CALLS
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/success_appointment.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'dart:developer' as devtools show log;

// class UIBookAppointmentForSelectedPatient extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;
//   final String? selectedSlot;
//   final DateTime selectedDate;
//   final Patient? selectedPatient;
//   final List<Map<String, dynamic>> slotsForSelectedDayList;

//   const UIBookAppointmentForSelectedPatient({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.patientService,
//     required this.selectedSlot,
//     required this.selectedDate,
//     required this.selectedPatient,
//     required this.slotsForSelectedDayList,
//   });

//   @override
//   State<UIBookAppointmentForSelectedPatient> createState() =>
//       _UIBookAppointmentForSelectedPatientState();
// }

// class _UIBookAppointmentForSelectedPatientState
//     extends State<UIBookAppointmentForSelectedPatient> with RouteAware {
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//   Patient? selectedPatient;

//   DateTime _focusedDay = DateTime.now(); // Initial date in IST

//   CalendarFormat _calendarFormat =
//       CalendarFormat.week; // Choose your desired format

//   DateTime _selectedDate = DateTime.now(); // Add this line
//   List<Map<String, dynamic>> _slotsForSelectedDay = [];

//   bool _isDateSelected = false;

//   final List<Map<String, dynamic>> _appointmentsForSelectedDate = [];
//   late DateTime now;
//   bool _showPatientSearchWidget = false;

//   String? selectedSlot = '';
//   bool isBookingAppointment = false;
//   bool isSlotSelected = false;
//   Patient? newPatient;
//   bool _showSelectedPatientDetails = false;
//   bool _showAddedPatientDetails = false;

//   bool isSearchAndAddPatientOpened = false;
//   bool _showProgressIndicator = false;

//   @override
//   void initState() {
//     devtools.log('Welcome to initState method inside BookAppointment');
//     super.initState();
//     now = DateTime.now();
//     _selectedDate = DateTime.now(); // Set the selected date to the current date
//   }

//   //******************************************************************************* */
//   // START OF _bookAppointmentForSelectedPatient FUNCTION //

//   void _bookAppointmentForSelectedPatient(
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

//       //*********************************** */
//       //CAPTURE treatmentId here//
//       final patientRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(selectedPatient!.patientId);
//       // .doc(selectedPatient!['patientId']);

//       // Check if the patient document has a 'treatments' sub-collection
//       final treatmentsSnapshot =
//           await patientRef.collection('treatments').get();

//       String? treatmentId;
//       if (treatmentsSnapshot.docs.isNotEmpty) {
//         // If 'treatments' sub-collection is found, retrieve the treatmentId
//         final latestTreatmentDoc = treatmentsSnapshot.docs.last;
//         treatmentId = latestTreatmentDoc['treatmentId'];
//       }
//       //************************************* */

//       final appointmentData = {
//         'patientName': selectedPatient!.patientName,
//         'age': selectedPatient!.age,
//         'gender': selectedPatient!.gender,
//         'patientMobileNumber': selectedPatient!.patientMobileNumber,
//         'patientId': selectedPatient!.patientId,
//         'doctorId': widget.doctorId,
//         'uhid': selectedPatient!.uhid,
//         'slot': slot,
//         'date':
//             Timestamp.fromDate(completeDateTimeInIst), // Convert to Timestamp
//         'treatmentId': treatmentId,
//         'patientPicUrl': selectedPatient!.patientPicUrl,
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

//       //List<Map<String, dynamic>> updatedSlots = [];
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
//         //_slotsForSelectedDay = updatedSlots;
//         updatedSlots = List.from(_slotsForSelectedDay);
//       });

//       // await updateSlotAvailability(selectedDate, updatedSlots);
//       await updateSlotAvailability(selectedDate, updatedSlots);

//       /// Notify AppointmentProvider to refresh appointments
//       await appointmentProvider.fetchNextAppointment();

//       //-------------------------------------------------------------------//

//       // Navigate to the SuccessAppointment screen

//       // ignore: use_build_context_synchronously
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => SuccessAppointment(
//             clinicId: widget.clinicId,
//             doctorId: widget.doctorId,
//             patientId: selectedPatient!.patientId,
//             // patientId: selectedPatient!['patientId'],
//           ),
//         ),
//       );

//       //-------------------------------------------------------------------//

//       // if (scaffoldKey.currentContext != null) {
//       //   Navigator.pop(scaffoldKey.currentContext!);
//       // }
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

// //******* ********************************************************************//
// // START OF updateSlotAvailability FUNCTION //
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
//   // END OF updateSlotAvailability FUNCTION //
//   //********* ********************************************************************//

//   //****************************************************************************//
//   // START OF _buildSelectedPatientContainer FUNCTION //
//   // Widget _buildSelectedPatientContainer(String slot) {
//   Widget _buildSelectedPatientContainer() {
//     selectedPatient = widget.selectedPatient;
//     devtools.log('Welcome to _buildSelectedPatientContainer.');
//     devtools.log('selectedPatient is $selectedPatient');
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
//                     // DateFormat('EEE, MMM d').format(_selectedDate),
//                     DateFormat('EEE, MMM d').format(widget.selectedDate),
//                     style: MyTextStyle.textStyleMap['title-medium']
//                         ?.copyWith(color: MyColors.colorPalette['ib-surface']),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   // slot,
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
//                     //color: Colors.blueAccent,
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
//                           // backgroundImage: selectedPatient!['patientPicUrl'] !=
//                           //             null &&
//                           //         selectedPatient!['patientPicUrl']!.isNotEmpty
//                           //     ? NetworkImage(selectedPatient!['patientPicUrl']!)
//                           backgroundImage: selectedPatient!.patientPicUrl !=
//                                       null &&
//                                   selectedPatient!.patientPicUrl!.isNotEmpty
//                               ? NetworkImage(selectedPatient!.patientPicUrl!)
//                               : Image.asset(
//                                   'assets/images/default-image.png',
//                                   color: MyColors.colorPalette['primary'],
//                                   colorBlendMode: BlendMode.color,
//                                 ).image,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               // '${selectedPatient!['patientName']}',
//                               selectedPatient!.patientName,
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-surface']),
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   // '${selectedPatient!['age']}',
//                                   selectedPatient!.age.toString(),
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
//                                   // '${selectedPatient!['gender']}',
//                                   selectedPatient!.gender,
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant']),
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               // '${selectedPatient!['patientMobileNumber']}',
//                               selectedPatient!.patientMobileNumber,
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
//                       _bookAppointmentForSelectedPatient(
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

//   // END OF _buildSelectedPatientContainer //

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
//       //body: _buildSelectedPatientContainer(),
//       body: Stack(
//         children: [
//           _buildSelectedPatientContainer(),
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
