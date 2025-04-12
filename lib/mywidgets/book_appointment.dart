// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/success_appointment.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'dart:developer' as devtools show log;

// class BookAppointment extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;
//   const BookAppointment({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.patientService,
//   });

//   @override
//   State<BookAppointment> createState() => _BookAppointmentState();
// }

// class _BookAppointmentState extends State<BookAppointment> with RouteAware {
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//   Map<String, dynamic>? selectedPatient;
//   Map<String, dynamic>? addedPatient;

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
//   //bool _showCalendar = false;
//   bool isSearchAndAddPatientOpened = false;

//   // Define a GlobalKey for the BookAppointment widget
//   final GlobalKey<_BookAppointmentState> bookAppointmentKey = GlobalKey();

//   @override
//   void initState() {
//     devtools.log('Welcome to initState method inside BookAppointment');
//     super.initState();
//     now = DateTime.now();
//     _selectedDate = DateTime.now(); // Set the selected date to the current date
//     fetchSlotsForSelectedDay(_selectedDate); // Fetch slots for the current day
//     // Set _showCalendar to true to ensure _buildCalendar() is invoked
//     //_showCalendar = true;
//     //_buildCalendar();
//   }

//   //******* ********************************************************//
//   // START OF fetchSlotsForSelectedDay FUNCTION //

//   Future<void> fetchSlotsForSelectedDay(DateTime selectedDate) async {
//     try {
//       devtools.log('selectedDate is $selectedDate');
//       devtools.log('This is coming from inside fetchSlotsForSelectedDay');
//       final selectedDayOfWeek = DateFormat('EEEE').format(selectedDate);
//       devtools.log('selectedDayOfWeek is $selectedDayOfWeek');

//       final selectedDateFormatted = DateFormat('d-MMMM')
//           .format(selectedDate); // Format the selected date as 'day-month'
//       //final selectedDayOfWeek = DateFormat('EEEE').format(selectedDate);

//       final doctorDocumentRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('availableSlots')
//           .doc('Dr${widget.doctorName}');

//       final selectedDateSlotsRef = doctorDocumentRef
//           .collection('selectedDateSlots')
//           .doc(selectedDateFormatted);

//       final selectedDateSlotsDoc = await selectedDateSlotsRef.get();

//       if (selectedDateSlotsDoc.exists) {
//         final slotsData = selectedDateSlotsDoc.data();
//         devtools.log(
//             'This is coming from if (selectedDateSlotsDoc.exists) inside fetchSlotsForSelectedDay. slotsData is $slotsData');
//         if (slotsData != null && slotsData.containsKey('slots')) {
//           final List<dynamic> allSlotsData = slotsData['slots'];
//           final List<Map<String, dynamic>> slotsForSelectedDate = [];
//           for (var slotsPeriodData in allSlotsData) {
//             final List<Map<String, dynamic>> slotsForPeriod =
//                 List<Map<String, dynamic>>.from(slotsPeriodData['slots']);
//             slotsForSelectedDate.addAll(slotsForPeriod);
//           }

//           // Segregate and sort the slots into morning, afternoon, and evening
//           final segregatedAndSortedSlots =
//               segregateAndSortSlots(slotsForSelectedDate);
//           devtools
//               .log('segregatedAndSortedSlots are $segregatedAndSortedSlots');

//           // Update the state with the segregated and sorted slots
//           setState(() {
//             _slotsForSelectedDay = segregatedAndSortedSlots;
//             devtools.log('_slotsForSelectedDay are $_slotsForSelectedDay');
//           });

//           return;
//         }
//       }

//       // If selectedDateSlots subcollection or selected date document not found, fetch slots from the 'DrJai' document
//       final doctorDocument = await doctorDocumentRef.get();
//       devtools.log('doctorDocument found which is $doctorDocument');

//       // final doctorDocument = await doctorDocumentRef.get();

//       if (doctorDocument.exists) {
//         devtools.log('This is coming from inside if (doctorDocument.exists) {');
//         final slotsData = doctorDocument.data();
//         devtools.log(
//             'This is coming from inside if (doctorDocument.exists) {---fetchSlotsForSelectedDay(). slotsData is $slotsData');

//         if (slotsData != null && slotsData.containsKey(selectedDayOfWeek)) {
//           final slotsForSelectedDay = slotsData[selectedDayOfWeek];
//           final List<Map<String, dynamic>> allSlots = [];

//           // Combine slots from all time periods into a single list
//           slotsForSelectedDay.forEach((timePeriod, slots) {
//             allSlots.addAll(List<Map<String, dynamic>>.from(slots));
//           });

//           // Fetch appointments for the selected date and doctor
//           final appointmentsSnapshot = await FirebaseFirestore.instance
//               .collection('clinics')
//               .doc(widget.clinicId)
//               .collection('appointments')
//               .where('doctorId', isEqualTo: widget.doctorId)
//               .where('date', isEqualTo: selectedDate)
//               .get();

//           // Capture all booked slots
//           List<String> bookedSlots = [];
//           if (appointmentsSnapshot.docs.isNotEmpty) {
//             bookedSlots = appointmentsSnapshot.docs
//                 .map((doc) => doc['slot'] as String)
//                 .toList();
//           }

//           // Update the 'isBooked' status of slots based on bookedSlots
//           final updatedSlots = allSlots.map((slotData) {
//             final isBooked = bookedSlots.contains(slotData['slot']);
//             return {
//               ...slotData,
//               'isBooked': isBooked,
//             };
//           }).toList();
//           devtools.log('updatedSlots are $updatedSlots');

//           //START OF MODIFIED VERSION //
//           // Segregate and sort the slots into morning, afternoon, and evening
//           final segregatedAndSortedSlots = segregateAndSortSlots(updatedSlots);
//           devtools
//               .log('segregatedAndSortedSlots are $segregatedAndSortedSlots');

//           // Update the state with the segregated and sorted slots
//           setState(() {
//             _slotsForSelectedDay = segregatedAndSortedSlots;
//             devtools.log('_slotsForSelectedDay are $_slotsForSelectedDay');
//           });

//           // END OF MODIFIED VERSION //
//         } else {
//           setState(() {
//             _slotsForSelectedDay =
//                 []; // No slots available for the selected day
//           });
//         }
//       } else {
//         devtools.log(
//             'Doctor document does not exist'); // Handle the case where the doctor document doesn't exist
//       }
//     } catch (error) {
//       devtools.log('Error in fetchSlotsForSelectedDay: $error');
//       // Handle any exceptions or errors that occur during the execution of this function
//     }
//   }
//   // END OF fetchSlotsForSelectedDay FUNCTION //
//   //********** *******************************************************//

//   //***************************************************************** *//
//   // START OF segregateAndSortSlots FUNCTION //

//   List<Map<String, dynamic>> segregateAndSortSlots(
//       List<Map<String, dynamic>> slots) {
//     // Separate slots into morning, afternoon, and evening lists
//     List<Map<String, dynamic>> morningSlots = [];
//     List<Map<String, dynamic>> afternoonSlots = [];
//     List<Map<String, dynamic>> eveningSlots = [];

//     // Sort function for slots based on time
//     slots.sort((a, b) => a['slot'].compareTo(b['slot']));

//     // Custom sorting function for morning slots
//     void sortMorningSlots(List<Map<String, dynamic>> slots) {
//       slots.sort((a, b) {
//         final aTime = DateFormat('h:mm a').parse(a['slot']);
//         final bTime = DateFormat('h:mm a').parse(b['slot']);
//         return aTime.hour * 60 +
//             aTime.minute -
//             (bTime.hour * 60 + bTime.minute);
//       });
//     }

//     // Iterate through slots and segregate them based on time
//     for (var slotData in slots) {
//       final slotTime = DateFormat('h:mm a').parse(slotData['slot']);

//       if (slotTime.hour < 13) {
//         morningSlots.add(slotData);
//       } else if (slotTime.hour >= 13 && slotTime.hour < 17) {
//         afternoonSlots.add(slotData);
//       } else {
//         eveningSlots.add(slotData);
//       }
//     }

//     // Sort morning, afternoon, and evening slots by time
//     sortMorningSlots(morningSlots);
//     afternoonSlots.sort((a, b) => a['slot'].compareTo(b['slot']));
//     eveningSlots.sort((a, b) => a['slot'].compareTo(b['slot']));

//     // Return the segregated and sorted slots with labels
//     return [
//       {'label': 'Morning', 'slots': morningSlots},
//       {'label': 'Afternoon', 'slots': afternoonSlots},
//       {'label': 'Evening', 'slots': eveningSlots},
//     ];
//   }

//   Widget _buildCalendar() {
//     devtools.log('Welcome to _buildCalendar');
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           const SizedBox(height: 20),
//           TableCalendar(
//             firstDay: DateTime.now(),
//             lastDay: DateTime.utc(now.year + 1, now.month, now.day).toLocal(),
//             focusedDay: _focusedDay,
//             selectedDayPredicate: (day) {
//               return isSameDay(_selectedDate, day);
//             },
//             onDaySelected: (selectedDay, focusedDay) {
//               setState(() {
//                 _selectedDate = selectedDay;
//                 _focusedDay = focusedDay;
//                 _isDateSelected = true;
//                 fetchSlotsForSelectedDay(selectedDay);

//                 // Reset selected slot and flag when the date changes
//                 selectedSlot = null;
//                 isSlotSelected = false;
//               });
//             },
//             calendarFormat: _calendarFormat,
//             availableCalendarFormats: const {
//               CalendarFormat.week: 'Week',
//               CalendarFormat.month: 'Month',
//             },
//             onPageChanged: (focusedDay) {
//               _focusedDay = focusedDay;
//             },
//             onFormatChanged: (format) {
//               setState(() {
//                 _calendarFormat = format;
//                 if (format == CalendarFormat.week) {
//                   fetchSlotsForSelectedDay(_focusedDay);
//                 }
//               });
//             },
//             calendarStyle: CalendarStyle(
//               todayTextStyle: TextStyle(
//                 color: MyColors.colorPalette['primary'],
//                 fontWeight: FontWeight.bold,
//               ),
//               todayDecoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   width: 2.0,
//                   color: MyColors.colorPalette['primary'] ?? Colors.blue,
//                 ),
//               ),
//               selectedDecoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: MyColors.colorPalette[
//                     'primary'], // Change selected date's circle color
//               ),
//             ),
//           ),
//           if (_slotsForSelectedDay.isNotEmpty) _buildSlotsList(),
//           // if (_slotsForSelectedDay.isNotEmpty)
//           //   _buildSlotsList(selectedDate: _selectedDate),
//         ],
//       ),
//     );
//   }

//   Widget _buildSlotsList() {
//     devtools.log('Welcome to _buildSlotsList. _selectedDate is $_selectedDate');
//     // Get the current time
//     final currentTime = DateTime.now();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         for (var timePeriodData in _slotsForSelectedDay)
//           if (timePeriodData['slots'].isNotEmpty)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 10),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       timePeriodData['label'],
//                       style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: (timePeriodData['slots'].length / 4).ceil(),
//                   itemBuilder: (context, rowIndex) {
//                     final startIdx = rowIndex * 4;
//                     final endIdx = (rowIndex + 1) * 4;
//                     final rowSlots = timePeriodData['slots'].sublist(
//                       startIdx,
//                       endIdx < timePeriodData['slots'].length
//                           ? endIdx
//                           : timePeriodData['slots'].length,
//                     );

//                     return Row(
//                       children: rowSlots.map<Widget>((slotData) {
//                         final slot = slotData['slot'];
//                         final isBooked = slotData['isBooked'];
//                         final isAlreadyBooked =
//                             _appointmentsForSelectedDate.any(
//                           (appointment) => appointment['slot'] == slot,
//                         );

//                         // Splitting the slot time
//                         final parts = slot.split(':');
//                         final hours = int.parse(parts[0]);
//                         final minutes = int.parse(parts[1].split(' ')[0]);
//                         final amOrPm = parts[1].split(' ')[1];

//                         DateTime slotTime;
//                         if (amOrPm == 'AM') {
//                           slotTime = DateTime(
//                             _selectedDate.year,
//                             _selectedDate.month,
//                             _selectedDate.day,
//                             hours == 12 ? 0 : hours,
//                             minutes,
//                           );
//                           devtools.log('if AM then slotTime is $slotTime');
//                         } else {
//                           slotTime = DateTime(
//                             _selectedDate.year,
//                             _selectedDate.month,
//                             _selectedDate.day,
//                             hours == 12 ? 12 : hours + 12,
//                             minutes,
//                           );
//                           devtools.log('if PM then slotTime is $slotTime');
//                         }

//                         // Checking if the slot is in the past
//                         //final isPastSlot = slotTime.isBefore(_selectedDate);
//                         // Check if the slot is in the past relative to the current time and selected date
//                         final isPastSlot = slotTime.isBefore(currentTime) ||
//                             slotTime.isBefore(_selectedDate);

//                         devtools.log('isPastSlot is $isPastSlot');

//                         final backgroundColor = isAlreadyBooked
//                             ? MyColors.colorPalette['on-primary']
//                             : (isBooked
//                                 ? MyColors.colorPalette['on-secondary']
//                                 : (isPastSlot
//                                     ? MyColors.colorPalette[
//                                         'tertiary'] // Color for past slots
//                                     : MyColors.colorPalette['on-primary']));

//                         final onTap = isAlreadyBooked || isBooked || isPastSlot
//                             ? null
//                             : () {
//                                 setState(() {
//                                   selectedSlot = slot;
//                                   isSlotSelected = true;
//                                 });
//                               };

//                         return SizedBox(
//                           width: MediaQuery.of(context).size.width / 4,
//                           child: GestureDetector(
//                             onTap: onTap,
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.rectangle,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(
//                                     color: selectedSlot == slot
//                                         ? MyColors.colorPalette['primary'] ??
//                                             const Color(0xFF008D90)
//                                         : MyColors.colorPalette['on-surface'] ??
//                                             Colors.black,
//                                     width: 1,
//                                   ),
//                                   color: selectedSlot == slot
//                                       ? MyColors.colorPalette['primary'] ??
//                                           const Color(0xFF008D90)
//                                       : null,
//                                 ),
//                                 child: Center(
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(
//                                         top: 8.0, bottom: 8.0),
//                                     child: Text(
//                                       slot,
//                                       style: MyTextStyle
//                                           .textStyleMap['title-small']
//                                           ?.copyWith(
//                                         color: selectedSlot == slot
//                                             ? MyColors
//                                                 .colorPalette['on-primary']
//                                             : isBooked ||
//                                                     isAlreadyBooked ||
//                                                     isPastSlot
//                                                 ? MyColors
//                                                     .colorPalette['outline']
//                                                 : MyColors
//                                                     .colorPalette['on-surface'],
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     );
//                   },
//                 ),
//               ],
//             ),
//         //---------------------------------------------------------------------//
//         const SizedBox(
//           height: 20.0,
//         ),

//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Align(
//             alignment: Alignment.topLeft,
//             child: ElevatedButton(
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.resolveWith<Color>(
//                   (Set<MaterialState> states) {
//                     if (states.contains(MaterialState.disabled)) {
//                       return Colors.grey;
//                     } else {
//                       return MyColors.colorPalette['primary']!;
//                     }
//                   },
//                 ),
//                 shape: MaterialStateProperty.all(
//                   RoundedRectangleBorder(
//                     side: BorderSide(
//                       color: MyColors.colorPalette['primary']!,
//                       width: 1.0,
//                     ),
//                     borderRadius: BorderRadius.circular(24.0),
//                   ),
//                 ),
//               ),
//               onPressed: isSlotSelected
//                   ? () {
//                       setState(() {
//                         _showPatientSearchWidget = true;
//                       });
//                     }
//                   : null, // Disable button if no slot is selected
//               child: Wrap(
//                 children: [
//                   Text(
//                     'Continue',
//                     style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                       color: MyColors.colorPalette['on-primary'],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         //---------------------------------------------------------------------//
//       ],
//     );
//   }

//   //******************************************************************************* */

//   //******************************************************************************* */
//   // START OF _bookAppointment FUNCTION //

//   void _bookAppointment(String slot, DateTime selectedDate) async {
//     if (isBookingAppointment) {
//       return; // Prevent multiple button presses while booking is in progress
//     }
//     setState(() {
//       isBookingAppointment = true; // Set the flag to true when booking starts
//     });

//     devtools.log('selected slot is $slot');
//     devtools.log('selected date  is $selectedDate');

//     try {
//       TimeOfDay slotTime =
//           TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(slot));

//       devtools.log('convertd slotTime is $slotTime');

//       // DateTime completeDateTime = selectedDate
//       //     .add(Duration(hours: slotTime.hour, minutes: slotTime.minute));

//       DateTime completeDateTime = DateTime(selectedDate.year,
//           selectedDate.month, selectedDate.day, slotTime.hour, slotTime.minute);

//       devtools.log('convertd completeDateTime is $completeDateTime');

//       DateTime completeDateTimeInUtc = completeDateTime.toUtc();

//       devtools.log('convertd completeDateTimeInUtc is $completeDateTimeInUtc');

//       DateTime completeDateTimeInIst = completeDateTimeInUtc.toLocal();

//       devtools.log('convertd completeDateTimeInIst is $completeDateTimeInIst');

//       //*********************************** */
//       //CAPTURE treatmentId here//
//       final patientRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(selectedPatient!['patientId']);

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
//         'patientName': selectedPatient!['patientName'],
//         'age': selectedPatient!['age'],
//         'gender': selectedPatient!['gender'],
//         'patientMobileNumber': selectedPatient!['patientMobileNumber'],
//         'patientId': selectedPatient!['patientId'],
//         'doctorId': widget.doctorId,
//         'uhid': selectedPatient!['uhid'],
//         'slot': slot,
//         'date':
//             Timestamp.fromDate(completeDateTimeInIst), // Convert to Timestamp
//         'treatmentId': treatmentId,
//         'patientPicUrl': selectedPatient!['patientPicUrl'],
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

//       // Call fetchSlotsForSelectedDay again to refresh the slots list
//       fetchSlotsForSelectedDay(selectedDate);
//       // Show a dialog containing information about the booked appointment

//       // Update the backend Firestore subcollection for the selected date
//       // await updateSlotAvailability(selectedDate, updatedSlots);
//       await updateSlotAvailability(selectedDate, updatedSlots);
//       // Navigate back to the previous screen

//       //-------------------------------------------------------------------//

//       // Navigate to the SuccessAppointment screen

//       // ignore: use_build_context_synchronously
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => SuccessAppointment(
//             clinicId: widget.clinicId,
//             doctorId: widget.doctorId,
//             patientId: selectedPatient!['patientId'],
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
//       });
//     }
//   }

//   //----------------------------------------------------------------------------//
//   void _bookAppointmentForAddedPatient(
//       String slot, DateTime selectedDate) async {
//     if (isBookingAppointment) {
//       return; // Prevent multiple button presses while booking is in progress
//     }
//     setState(() {
//       isBookingAppointment = true; // Set the flag to true when booking starts
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

//       //*********************************** */
//       // CAPTURE treatmentId here//
//       final patientRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(addedPatient!['patientId']);

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
//         'patientName': addedPatient!['patientName'],
//         'age': addedPatient!['age'],
//         'gender': addedPatient!['gender'],
//         'patientMobileNumber': addedPatient!['patientMobileNumber'],
//         'patientId': addedPatient!['patientId'],
//         'doctorId': widget.doctorId,
//         'uhid': addedPatient!['uhid'],
//         'slot': slot,
//         'date':
//             Timestamp.fromDate(completeDateTimeInIst), // Convert to Timestamp
//         'treatmentId': treatmentId,
//         'patientPicUrl': addedPatient!['patientPicUrl'],
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

//       // List<Map<String, dynamic>> updatedSlots = [];
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

//       // Call fetchSlotsForSelectedDay again to refresh the slots list
//       fetchSlotsForSelectedDay(selectedDate);
//       // Show a dialog containing information about the booked appointment

//       // Update the backend Firestore subcollection for the selected date
//       // await updateSlotAvailability(selectedDate, updatedSlots);
//       await updateSlotAvailability(selectedDate, updatedSlots);
//       // Navigate back to the previous screen

//       //-------------------------------------------------------------------//

//       // Navigate to the SuccessAppointment screen

//       // ignore: use_build_context_synchronously
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => SuccessAppointment(
//             clinicId: widget.clinicId,
//             doctorId: widget.doctorId,
//             patientId: addedPatient!['patientId'],
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
//       });
//     }
//   }

//   //----------------------------------------------------------------------------//

//   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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
//   Widget _buildSelectedPatientContainer(String slot) {
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
//                     DateFormat('EEE, MMM d').format(_selectedDate),
//                     style: MyTextStyle.textStyleMap['title-medium']
//                         ?.copyWith(color: MyColors.colorPalette['ib-surface']),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   //'slot',
//                   slot,
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
//                           backgroundImage: selectedPatient!['patientPicUrl'] !=
//                                       null &&
//                                   selectedPatient!['patientPicUrl']!.isNotEmpty
//                               ? NetworkImage(selectedPatient!['patientPicUrl']!)
//                               : Image.asset(
//                                   'assets/images/default-image.png',
//                                   color: MyColors.colorPalette['primary'],
//                                   colorBlendMode: BlendMode.color,
//                                 ).image,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '${selectedPatient!['patientName']}',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-surface']),
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   '${selectedPatient!['age']}',
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
//                                   '${selectedPatient!['gender']}',
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant']),
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               '${selectedPatient!['patientMobileNumber']}',
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
//                       _bookAppointment(slot, _selectedDate);
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

//   // **************************************************************************//

//   void _showPatientSearch(BuildContext context) {
//     isSearchAndAddPatientOpened = true;
//     try {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SearchAndAddPatient(
//               bookAppointmentKey: bookAppointmentKey,
//               clinicId: widget.clinicId,
//               doctorId: widget.doctorId,
//               doctorName: widget.doctorName,
//               patientService: widget.patientService,
//               selectedSlot: selectedSlot,
//               selectedDate: _selectedDate,
//               // Pass the callback functions to SearchAndAddPatient
//               onPatientAddedForAppointment: (newPatient) {
//                 devtools.log(
//                     'newPatient received back inside onPatientAddedForAppointment in BookAppointment. newPatient is $newPatient');
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   setState(() {
//                     addedPatient = {
//                       'doctorId': widget.doctorId,
//                       'doctorName': widget.doctorName,
//                       'clinicId': widget.clinicId,
//                       'patientId': newPatient.patientId,
//                       'age': newPatient.age,
//                       'gender': newPatient.gender,
//                       'patientName': newPatient.patientName,
//                       'patientMobileNumber': newPatient.patientMobileNumber,
//                       'patientPicUrl': newPatient.patientPicUrl,
//                       'uhid': newPatient.uhid,
//                       // Additional parameters
//                     };
//                     _showAddedPatientDetails = true;
//                   });
//                 });
//               },
//               onPatientSelectedForAppointment: (patient) {
//                 devtools.log(
//                     '_showAddedPatientDetails is $_showAddedPatientDetails');
//                 if (!_showAddedPatientDetails) {
//                   setState(() {
//                     selectedPatient = {
//                       'doctorId': widget.doctorId,
//                       'doctorName': widget.doctorName,
//                       'clinicId': widget.clinicId,
//                       'patientId': patient.patientId,
//                       'age': patient.age,
//                       'gender': patient.gender,
//                       'patientName': patient.patientName,
//                       'patientMobileNumber': patient.patientMobileNumber,
//                       'patientPicUrl': patient.patientPicUrl,
//                       'uhid': patient.uhid,
//                       // Additional parameters
//                     };
//                     _showSelectedPatientDetails = true;
//                   });
//                 }
//               },
//               // Pass the onNavigationBack callback function to SearchAndAddPatient
//               onNavigationBack: restoreState,
//             ),
//           ),
//         ).then((_) {
//           // This code runs when the SearchAndAddPatient screen is popped (navigated back from).
//           // You can use this callback to update the state.
//           devtools.log(
//               'Welcome to .then code block. Before setting it false isSearchAndAddPatientOpened is $isSearchAndAddPatientOpened');
//           setState(() {
//             // Update state as needed
//             isSearchAndAddPatientOpened = false;
//           });
//         });
//       });
//     } catch (e, stackTrace) {
//       // Handle the exception
//       devtools.log('Error navigating to SearchAndAddPatient: $e');
//       devtools.log('Stack trace: $stackTrace');
//       // Optionally, perform fallback actions or show an error message to the user
//     }
//   }

//   // Callback function to restore state when navigating back from SearchAndAddPatient
//   void restoreState() {
//     devtools.log('Welcome to restoreState function');
//     setState(() {
//       devtools.log(
//           'Before setting it to false, isSearchAndAddPatientOpened is $isSearchAndAddPatientOpened');
//       isSearchAndAddPatientOpened = false;
//       _showPatientSearchWidget = false;
//       // Perform any additional state restoration if needed
//     });
//   }

//   //-----------------------------------------------------------------------------//
//   Widget _buildNewPatientContainer(String slot) {
//     devtools.log(
//         'Welcome to _buildNewPatientContainer. addedPatient is $addedPatient');

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
//                     DateFormat('EEE, MMM d').format(_selectedDate),
//                     style: MyTextStyle.textStyleMap['title-medium']
//                         ?.copyWith(color: MyColors.colorPalette['ib-surface']),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   //'slot',
//                   slot,
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
//                           backgroundImage: addedPatient != null &&
//                                   addedPatient?['patientPicUrl'] != null &&
//                                   addedPatient?['patientPicUrl']!.isNotEmpty
//                               ? NetworkImage(addedPatient?['patientPicUrl']!)
//                               : Image.asset(
//                                   'assets/images/default-image.png',
//                                   color: MyColors.colorPalette['primary'],
//                                   colorBlendMode: BlendMode.color,
//                                 ).image,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '${addedPatient!['patientName']}',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-surface']),
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   '${addedPatient!['age']}',

//                                   //newPatient!.age.toString(),
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
//                                   '${addedPatient!['gender']}',
//                                   //newPatient!.gender,
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant']),
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               '${addedPatient!['patientMobileNumber']}',
//                               //newPatient!.patientMobileNumber,
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
//                       _bookAppointmentForAddedPatient(slot, _selectedDate);
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
//   //-----------------------------------------------------------------------------//

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to BookAppointment');
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Book Appointment',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close), // Replace the close icon here
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         // Other app bar configurations...
//       ),
//       body: _buildBody(),
//     );
//   }

//   Widget _buildBody() {
//     // if (_showCalendar) {
//     //   _showCalendar = false; // Reset flag only when necessary

//     //   return _buildCalendar();
//     // } else if (isBookingAppointment) {
//     // Display circular progress indicator when booking is in progress
//     if (isBookingAppointment) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     } else if (_showPatientSearchWidget &&
//         selectedPatient == null &&
//         addedPatient == null) {
//       _showPatientSearch(context);
//       return Container();
//     } else if (selectedPatient != null && _showSelectedPatientDetails) {
//       return _buildSelectedPatientContainer(selectedSlot ?? "");
//     } else if (addedPatient != null && _showAddedPatientDetails) {
//       return _buildNewPatientContainer(selectedSlot ?? "");
//     } else {
//       return PopScope(
//         onPopInvoked: (bool value) async {
//           // Call restoreState when user tries to navigate back
//           restoreState();
//         },
//         child:
//             _buildCalendar(), // Show calendar when none of the other conditions are met
//       );
//     }
//   }
// }

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
