import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/appointment_service.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/mywidgets/ui_search_and_add_patient.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:developer' as devtools show log;

class UICalendarSlots extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String clinicId;

  const UICalendarSlots({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
  });

  @override
  State<UICalendarSlots> createState() => _UICalendarSlotsState();
}

class _UICalendarSlotsState extends State<UICalendarSlots> with RouteAware {
  late PatientService _patientService;

  DateTime _focusedDay = DateTime.now(); // Initial date in IST

  CalendarFormat _calendarFormat =
      CalendarFormat.week; // Choose your desired format

  DateTime _selectedDate = DateTime.now(); // Add this line
  List<Map<String, dynamic>> _slotsForSelectedDay = [];
  List<Map<String, dynamic>> slotsForSelectedDayList = [];

  bool _isDateSelected = false;

  final List<Map<String, dynamic>> _appointmentsForSelectedDate = [];
  late DateTime now;

  String? selectedSlot = '';

  bool isSlotSelected = false;

  @override
  void initState() {
    devtools.log('Welcome to initState method inside BookAppointment');
    super.initState();
    now = DateTime.now();
    _selectedDate = DateTime.now();
    _patientService = PatientService(widget.clinicId, widget.doctorId);

    // Fetch the slots for the initial selected date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchSlotsForSelectedDay(_selectedDate);
    });
  }

  //---------------------------------------------------------------------------//

  Future<void> fetchSlotsForSelectedDay(DateTime selectedDate) async {
    try {
      devtools.log('**** Fetching slots for selected date: $selectedDate');

      // Access the current clinic from ClinicSelection
      final clinicSelection = ClinicSelection.instance;
      final selectedClinicId = clinicSelection.selectedClinicId;

      // Fetch the slots using the AppointmentService
      final appointmentService = AppointmentService();
      List<Map<String, dynamic>> slotsForSelectedDay =
          await appointmentService.fetchSlotsForSelectedDay(
        clinicId: selectedClinicId,
        doctorId: widget.doctorId,
        doctorName: widget.doctorName,
        selectedDate: selectedDate,
      );

      devtools.log('**** Slots fetched: $slotsForSelectedDay');

      final segregatedAndSortedSlots =
          segregateAndSortSlots(slotsForSelectedDay);
      setState(() {
        _slotsForSelectedDay = segregatedAndSortedSlots;
        slotsForSelectedDayList = _slotsForSelectedDay;
      });
    } catch (error) {
      devtools.log('**** Error in fetchSlotsForSelectedDay: $error');
    }
  }

  //--------------------------------------------------------------------------------------------//

  List<Map<String, dynamic>> segregateAndSortSlots(
      List<Map<String, dynamic>> slots) {
    // Separate slots into morning, afternoon, and evening lists
    List<Map<String, dynamic>> morningSlots = [];
    List<Map<String, dynamic>> afternoonSlots = [];
    List<Map<String, dynamic>> eveningSlots = [];

    // Sort function for slots based on time
    slots.sort((a, b) => a['slot'].compareTo(b['slot']));

    // Custom sorting function for morning slots
    void sortMorningSlots(List<Map<String, dynamic>> slots) {
      slots.sort((a, b) {
        final aTime = DateFormat('h:mm a').parse(a['slot']);
        final bTime = DateFormat('h:mm a').parse(b['slot']);
        return aTime.hour * 60 +
            aTime.minute -
            (bTime.hour * 60 + bTime.minute);
      });
    }

    // Iterate through slots and segregate them based on time
    for (var slotData in slots) {
      final slotTime = DateFormat('h:mm a').parse(slotData['slot']);

      if (slotTime.hour < 13) {
        morningSlots.add(slotData);
      } else if (slotTime.hour >= 13 && slotTime.hour < 17) {
        afternoonSlots.add(slotData);
      } else {
        eveningSlots.add(slotData);
      }
    }

    // Sort morning, afternoon, and evening slots by time
    sortMorningSlots(morningSlots);
    afternoonSlots.sort((a, b) => a['slot'].compareTo(b['slot']));
    eveningSlots.sort((a, b) => a['slot'].compareTo(b['slot']));

    // Return the segregated and sorted slots with labels
    return [
      {'label': 'Morning', 'slots': morningSlots},
      {'label': 'Afternoon', 'slots': afternoonSlots},
      {'label': 'Evening', 'slots': eveningSlots},
    ];
  }

  Widget _buildCalendar() {
    devtools.log('Welcome to _buildCalendar');
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.utc(now.year + 1, now.month, now.day).toLocal(),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDay = focusedDay;
                _isDateSelected = true;
                fetchSlotsForSelectedDay(selectedDay);

                // Reset selected slot and flag when the date changes
                selectedSlot = null;
                isSlotSelected = false;
              });
            },
            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {
              CalendarFormat.week: 'Week',
              CalendarFormat.month: 'Month',
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
                if (format == CalendarFormat.week) {
                  fetchSlotsForSelectedDay(_focusedDay);
                }
              });
            },
            calendarStyle: CalendarStyle(
              todayTextStyle: TextStyle(
                color: MyColors.colorPalette['primary'],
                fontWeight: FontWeight.bold,
              ),
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2.0,
                  color: MyColors.colorPalette['primary'] ?? Colors.blue,
                ),
              ),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MyColors.colorPalette[
                    'primary'], // Change selected date's circle color
              ),
            ),
          ),
          if (_slotsForSelectedDay.isNotEmpty) _buildSlotsList(),
          // if (_slotsForSelectedDay.isNotEmpty)
          //   _buildSlotsList(selectedDate: _selectedDate),
        ],
      ),
    );
  }

  Widget _buildSlotsList() {
    devtools.log('Welcome to _buildSlotsList. _selectedDate is $_selectedDate');
    // Get the current time
    final currentTime = DateTime.now();
    // Use ClinicSelection provider to fetch the latest clinic data
    final clinicSelection = context.read<ClinicSelection>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var timePeriodData in _slotsForSelectedDay)
          if (timePeriodData['slots'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      timePeriodData['label'],
                      style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
                        color: MyColors.colorPalette['on-surface'],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: (timePeriodData['slots'].length / 4).ceil(),
                  itemBuilder: (context, rowIndex) {
                    final startIdx = rowIndex * 4;
                    final endIdx = (rowIndex + 1) * 4;
                    final rowSlots = timePeriodData['slots'].sublist(
                      startIdx,
                      endIdx < timePeriodData['slots'].length
                          ? endIdx
                          : timePeriodData['slots'].length,
                    );

                    return Row(
                      children: rowSlots.map<Widget>((slotData) {
                        final slot = slotData['slot'];
                        final isBooked = slotData['isBooked'];
                        final isAlreadyBooked =
                            _appointmentsForSelectedDate.any(
                          (appointment) => appointment['slot'] == slot,
                        );

                        // Splitting the slot time
                        final parts = slot.split(':');
                        final hours = int.parse(parts[0]);
                        final minutes = int.parse(parts[1].split(' ')[0]);
                        final amOrPm = parts[1].split(' ')[1];

                        DateTime slotTime;
                        if (amOrPm == 'AM') {
                          slotTime = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            hours == 12 ? 0 : hours,
                            minutes,
                          );
                          devtools.log('if AM then slotTime is $slotTime');
                        } else {
                          slotTime = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            hours == 12 ? 12 : hours + 12,
                            minutes,
                          );
                          devtools.log('if PM then slotTime is $slotTime');
                        }

                        // Checking if the slot is in the past
                        //final isPastSlot = slotTime.isBefore(_selectedDate);
                        // Check if the slot is in the past relative to the current time and selected date
                        final isPastSlot = slotTime.isBefore(currentTime) ||
                            slotTime.isBefore(_selectedDate);

                        devtools.log('isPastSlot is $isPastSlot');

                        final backgroundColor = isAlreadyBooked
                            ? MyColors.colorPalette['on-primary']
                            : (isBooked
                                ? MyColors.colorPalette['on-secondary']
                                : (isPastSlot
                                    ? MyColors.colorPalette[
                                        'tertiary'] // Color for past slots
                                    : MyColors.colorPalette['on-primary']));

                        final onTap = isAlreadyBooked || isBooked || isPastSlot
                            ? null
                            : () {
                                setState(() {
                                  selectedSlot = slot;
                                  isSlotSelected = true;
                                });
                              };

                        return SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          child: GestureDetector(
                            onTap: onTap,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedSlot == slot
                                        ? MyColors.colorPalette['primary'] ??
                                            const Color(0xFF008D90)
                                        : MyColors.colorPalette['on-surface'] ??
                                            Colors.black,
                                    width: 1,
                                  ),
                                  color: selectedSlot == slot
                                      ? MyColors.colorPalette['primary'] ??
                                          const Color(0xFF008D90)
                                      : null,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8.0),
                                    child: Text(
                                      slot,
                                      style: MyTextStyle
                                          .textStyleMap['title-small']
                                          ?.copyWith(
                                        color: selectedSlot == slot
                                            ? MyColors
                                                .colorPalette['on-primary']
                                            : isBooked ||
                                                    isAlreadyBooked ||
                                                    isPastSlot
                                                ? MyColors
                                                    .colorPalette['outline']
                                                : MyColors
                                                    .colorPalette['on-surface'],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
        //---------------------------------------------------------------------//
        const SizedBox(
          height: 20.0,
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topLeft,
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
              onPressed: isSlotSelected
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UISearchAndAddPatient(
                            //-------------------------------------------------//
                            doctorId: widget.doctorId,
                            doctorName: widget.doctorName,
                            clinicId: clinicSelection.selectedClinicId,
                            patientService: _patientService,
                            selectedDate: _selectedDate,
                            selectedSlot: selectedSlot,
                            slotsForSelectedDayList: slotsForSelectedDayList,
                            //-------------------------------------------------//
                          ),
                        ),
                      );
                    }
                  : null,
              child: Wrap(
                children: [
                  Text(
                    'Continue',
                    style: MyTextStyle.textStyleMap['label-large']?.copyWith(
                      color: MyColors.colorPalette['on-primary'],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        //---------------------------------------------------------------------//
      ],
    );
  }

  void refreshCalendar() {
    // Implementation of refreshCalendar method
    // For example, you can setState here to trigger a rebuild of the calendar widget
    setState(() {
      // Update state variables or perform any necessary operations to refresh the calendar
    });
  }

  @override
  Widget build(BuildContext context) {
    devtools.log('Welcome to BookAppointment');
    return Scaffold(
        //key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: MyColors.colorPalette['surface-container-lowest'],
          title: Text(
            'Book Appointment',
            style: MyTextStyle.textStyleMap['title-large']
                ?.copyWith(color: MyColors.colorPalette['on-surface']),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close), // Replace the close icon here
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          // Other app bar configurations...
        ),
        // body: _buildBody(),
        body: _buildCalendar());
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// ############################################################################ //
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/ui_search_and_add_patient.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'dart:developer' as devtools show log;

// class UICalendarSlots extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;
//   const UICalendarSlots({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.patientService,
//   });

//   @override
//   State<UICalendarSlots> createState() => _UICalendarSlotsState();
// }

// class _UICalendarSlotsState extends State<UICalendarSlots> with RouteAware {
//   //final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//   DateTime _focusedDay = DateTime.now(); // Initial date in IST

//   CalendarFormat _calendarFormat =
//       CalendarFormat.week; // Choose your desired format

//   DateTime _selectedDate = DateTime.now(); // Add this line
//   List<Map<String, dynamic>> _slotsForSelectedDay = [];
//   List<Map<String, dynamic>> slotsForSelectedDayList = [];

//   bool _isDateSelected = false;

//   final List<Map<String, dynamic>> _appointmentsForSelectedDate = [];
//   late DateTime now;

//   String? selectedSlot = '';

//   bool isSlotSelected = false;

//   // @override
//   // void initState() {
//   //   devtools.log('Welcome to initState method inside BookAppointment');
//   //   super.initState();
//   //   now = DateTime.now();
//   //   _selectedDate = DateTime.now();
//   //   fetchSlotsForSelectedDay(_selectedDate);
//   // }

//   @override
//   void initState() {
//     devtools.log('Welcome to initState method inside BookAppointment');
//     super.initState();
//     now = DateTime.now();
//     _selectedDate = DateTime.now();

//     // Fetch the slots for the initial selected date
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       fetchSlotsForSelectedDay(_selectedDate);
//     });
//   }

//   //---------------------------------------------------------------------------//
//   // Future<void> fetchSlotsForSelectedDay(DateTime selectedDate) async {
//   //   try {
//   //     devtools.log('Fetching slots for selected date: $selectedDate');

//   //     // Use AppointmentService to fetch the slots
//   //     final appointmentService = AppointmentService();

//   //     // Fetch the slots using the service
//   //     List<Map<String, dynamic>> slotsForSelectedDay =
//   //         await appointmentService.fetchSlotsForSelectedDay(
//   //       clinicId: widget.clinicId,
//   //       doctorId: widget.doctorId,
//   //       doctorName: widget.doctorName,
//   //       selectedDate: selectedDate,
//   //     );

//   //     devtools.log('Slots fetched: $slotsForSelectedDay');

//   //     // Segregate and sort the slots (using your existing segregation function)
//   //     final segregatedAndSortedSlots =
//   //         segregateAndSortSlots(slotsForSelectedDay);
//   //     devtools.log('Segregated and sorted slots: $segregatedAndSortedSlots');

//   //     // Update the state with the segregated and sorted slots
//   //     setState(() {
//   //       _slotsForSelectedDay = segregatedAndSortedSlots;
//   //       slotsForSelectedDayList = _slotsForSelectedDay;
//   //     });
//   //   } catch (error) {
//   //     devtools.log('Error in fetchSlotsForSelectedDay: $error');
//   //     // Handle any exceptions or errors that occur during the execution of this function
//   //   }
//   // }

//   Future<void> fetchSlotsForSelectedDay(DateTime selectedDate) async {
//     try {
//       devtools.log('**** Fetching slots for selected date: $selectedDate');

//       // Access the current clinic from ClinicSelection
//       final clinicSelection = ClinicSelection.instance;
//       final selectedClinicId = clinicSelection.selectedClinicId;

//       // Fetch the slots using the AppointmentService
//       final appointmentService = AppointmentService();
//       List<Map<String, dynamic>> slotsForSelectedDay =
//           await appointmentService.fetchSlotsForSelectedDay(
//         clinicId: selectedClinicId,
//         doctorId: widget.doctorId,
//         doctorName: widget.doctorName,
//         selectedDate: selectedDate,
//       );

//       devtools.log('**** Slots fetched: $slotsForSelectedDay');

//       final segregatedAndSortedSlots =
//           segregateAndSortSlots(slotsForSelectedDay);
//       setState(() {
//         _slotsForSelectedDay = segregatedAndSortedSlots;
//         slotsForSelectedDayList = _slotsForSelectedDay;
//       });
//     } catch (error) {
//       devtools.log('**** Error in fetchSlotsForSelectedDay: $error');
//     }
//   }

//   //--------------------------------------------------------------------------------------------//

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
//     // Use ClinicSelection provider to fetch the latest clinic data
//     final clinicSelection = context.read<ClinicSelection>();

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
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => UISearchAndAddPatient(
//                             // doctorId: widget.doctorId,
//                             // doctorName: widget.doctorName,
//                             // clinicId: widget.clinicId,
//                             // patientService: widget.patientService,
//                             // selectedDate: _selectedDate,
//                             // selectedSlot: selectedSlot,
//                             // slotsForSelectedDayList: slotsForSelectedDayList,
//                             //-------------------------------------------------//
//                             doctorId: widget.doctorId,
//                             doctorName: widget.doctorName,
//                             clinicId: clinicSelection.selectedClinicId,
//                             patientService: PatientService(
//                               clinicSelection.selectedClinicId,
//                               clinicSelection.doctorId,
//                             ),
//                             selectedDate: _selectedDate,
//                             selectedSlot: selectedSlot,
//                             slotsForSelectedDayList: slotsForSelectedDayList,
//                             //-------------------------------------------------//
//                           ),
//                         ),
//                       );
//                     }
//                   : null,
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

//   void refreshCalendar() {
//     // Implementation of refreshCalendar method
//     // For example, you can setState here to trigger a rebuild of the calendar widget
//     setState(() {
//       // Update state variables or perform any necessary operations to refresh the calendar
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to BookAppointment');
//     return Scaffold(
//         //key: scaffoldKey,
//         appBar: AppBar(
//           backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//           title: Text(
//             'Book Appointment',
//             style: MyTextStyle.textStyleMap['title-large']
//                 ?.copyWith(color: MyColors.colorPalette['on-surface']),
//           ),
//           leading: IconButton(
//             icon: const Icon(Icons.close), // Replace the close icon here
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           // Other app bar configurations...
//         ),
//         // body: _buildBody(),
//         body: _buildCalendar());
//   }
// }

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// import 'package:neocare_dental_app/mywidgets/search_and_add_patient.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/ui_search_and_add_patient.dart';

// import 'package:table_calendar/table_calendar.dart';
// import 'dart:developer' as devtools show log;

// class UICalendarSlots extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;
//   const UICalendarSlots({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.patientService,
//   });

//   @override
//   State<UICalendarSlots> createState() => _UICalendarSlotsState();
// }

// class _UICalendarSlotsState extends State<UICalendarSlots> with RouteAware {
//   //final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//   DateTime _focusedDay = DateTime.now(); // Initial date in IST

//   CalendarFormat _calendarFormat =
//       CalendarFormat.week; // Choose your desired format

//   DateTime _selectedDate = DateTime.now(); // Add this line
//   List<Map<String, dynamic>> _slotsForSelectedDay = [];
//   List<Map<String, dynamic>> slotsForSelectedDayList = [];

//   bool _isDateSelected = false;

//   final List<Map<String, dynamic>> _appointmentsForSelectedDate = [];
//   late DateTime now;

//   String? selectedSlot = '';

//   bool isSlotSelected = false;

//   @override
//   void initState() {
//     devtools.log('Welcome to initState method inside BookAppointment');
//     super.initState();
//     now = DateTime.now();
//     _selectedDate = DateTime.now();
//     fetchSlotsForSelectedDay(_selectedDate);
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
//             slotsForSelectedDayList = _slotsForSelectedDay;
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
//             slotsForSelectedDayList = _slotsForSelectedDay;
//             devtools.log(
//                 'slotsForSelectedDayList to be passed on further from inside UICalendarSlots are: $slotsForSelectedDayList');
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
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => UISearchAndAddPatient(
//                             doctorId: widget.doctorId,
//                             doctorName: widget.doctorName,
//                             clinicId: widget.clinicId,
//                             patientService: widget.patientService,
//                             selectedDate: _selectedDate,
//                             selectedSlot: selectedSlot,
//                             slotsForSelectedDayList: slotsForSelectedDayList,
//                           ),
//                         ),
//                       );
//                     }
//                   : null,
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
// // Define refreshCalendar method
//   void refreshCalendar() {
//     // Implementation of refreshCalendar method
//     // For example, you can setState here to trigger a rebuild of the calendar widget
//     setState(() {
//       // Update state variables or perform any necessary operations to refresh the calendar
//     });
//   }

// //******* ********************************************************************//
// // START OF updateSlotAvailability FUNCTION //
//   // Future<void> updateSlotAvailability(
//   //     DateTime selectedDate, List<Map<String, dynamic>> updatedSlots) async {
//   //   devtools.log('Welcome to updateSlotAvailability');
//   //   devtools.log('updatedSlots are $updatedSlots');
//   //   try {
//   //     final selectedDateFormatted = DateFormat('d-MMMM')
//   //         .format(selectedDate); // Format the selected date as 'day-month'
//   //     final doctorDocumentRef = FirebaseFirestore.instance
//   //         .collection('clinics')
//   //         .doc(widget.clinicId)
//   //         .collection('availableSlots')
//   //         .doc('Dr${widget.doctorName}')
//   //         .collection('selectedDateSlots')
//   //         .doc(selectedDateFormatted);

//   //     final slotsData = <String, dynamic>{
//   //       'slots': updatedSlots,
//   //     };

//   //     await doctorDocumentRef.set(slotsData);
//   //   } catch (error) {
//   //     devtools.log('Error updating slot availability: $error');
//   //   }
//   // }

//   //-----------------------------------------------------------------------------//

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to BookAppointment');
//     return Scaffold(
//         //key: scaffoldKey,
//         appBar: AppBar(
//           backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//           title: Text(
//             'Book Appointment',
//             style: MyTextStyle.textStyleMap['title-large']
//                 ?.copyWith(color: MyColors.colorPalette['on-surface']),
//           ),
//           leading: IconButton(
//             icon: const Icon(Icons.close), // Replace the close icon here
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           // Other app bar configurations...
//         ),
//         // body: _buildBody(),
//         body: _buildCalendar());
//   }
// }
// //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  

