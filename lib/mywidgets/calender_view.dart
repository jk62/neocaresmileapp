import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/firestore/appointment_service.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import 'package:neocaresmileapp/mywidgets/appointment_provider.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/common_app_bar.dart';
import 'package:neocaresmileapp/mywidgets/treatment_landing_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:developer' as devtools show log;
import 'package:neocaresmileapp/mywidgets/mycolors.dart';

class CalenderView extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String clinicId;
  final bool showBottomNavigationBar;

  const CalenderView({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
    required this.showBottomNavigationBar,
  });

  @override
  State<CalenderView> createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  late DateTime _selectedDate;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;

  //bool _isLoading = false;
  List<Appointment>? _appointments;
  String? selectedAppointmentId;
  Timer? _debounce;
  bool _appointmentsFetched = false;
  Timer? _fetchDebounce; // Debounce for fetchAppointmentsForDate

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.week;

    // Fetch appointments after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAppointmentsForDateOnce(_selectedDate);
    });

    // Listen for clinic changes and re-fetch appointments
    ClinicSelection.instance.addListener(_onClinicChanged);
  }

  @override
  void dispose() {
    // Remove listener to avoid memory leaks
    ClinicSelection.instance.removeListener(_onClinicChanged);
    super.dispose();
  }

  void _onClinicChanged() {
    devtools.log('#### _onClinicChanged triggered in CalenderView');

    if (_appointments != null &&
        ClinicSelection.instance.selectedClinicId == widget.clinicId) {
      devtools.log('#### Skipping appointment fetch: Clinic has not changed.');
      return; // Skip fetching if the clinic hasn't changed
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        devtools.log('#### Re-fetching appointments for clinic change.');
        _fetchAppointmentsForDate(_selectedDate);
      }
    });
  }

  //------------------------------------------------------//
  void _fetchAppointmentsForDateOnce(DateTime date) {
    if (_appointmentsFetched) return;
    _appointmentsFetched = true;
    _fetchAppointmentsForDate(date);
  }
  //------------------------------------------------------//

  Future<void> _fetchAppointmentsForDate(DateTime date) async {
    devtools.log(
        '!!!! This is from inside _fetchAppointmentsForDate defined inside CalenderView. appointmentProvider.fetchAppointmentsForDate called for $date');

    // Debounce to avoid multiple rapid calls
    if (_fetchDebounce?.isActive ?? false) {
      devtools.log('Debounce active. Skipping fetch.');
      return;
    }

    // Start debounce timer
    _fetchDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;

      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);

      try {
        // Fetch appointments for the date
        await appointmentProvider.fetchAppointmentsForDate(date);
        devtools.log('Appointments fetched for $date');

        if (mounted) {
          // Compare fetched appointments with the current state to avoid redundant updates
          final fetchedAppointments = appointmentProvider.appointments;

          if (_appointments != fetchedAppointments) {
            setState(() {
              _appointments = fetchedAppointments;
            });
            devtools.log('Appointments updated for the selected date.');
          } else {
            devtools.log('No changes in appointments. Skipping update.');
          }
        }
      } catch (e) {
        devtools.log('Error fetching appointments: $e');
        if (mounted) {
          setState(() {
            _appointments = [];
          });
        }
      }
    });
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.utc(
          _focusedDay.year + 1, _focusedDay.month, _focusedDay.day),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
          _focusedDay = focusedDay;
        });

        // Fetch appointments for the selected day
        _fetchAppointmentsForDate(selectedDay);
      },
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
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
          color: MyColors.colorPalette['primary'],
        ),
      ),
    );
  }

  //----------------------------------------------------------------------------//
  Widget _buildAppointmentsList() {
    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, child) {
        if (appointmentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (appointmentProvider.appointments == null ||
            appointmentProvider.appointments!.isEmpty) {
          return const Center(
            child: Text(
              'No appointments for the selected date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }

        return ListView.builder(
          itemCount: appointmentProvider.appointments!.length,
          itemBuilder: (context, index) {
            final appointment = appointmentProvider.appointments![index];
            final isSelected = appointmentProvider.selectedAppointmentId ==
                appointment.appointmentId;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TreatmentLandingScreen(
                      clinicId: ClinicSelection.instance.selectedClinicId,
                      doctorId: ClinicSelection.instance.doctorId,
                      doctorName: ClinicSelection.instance.selectedClinicName,
                      patientId: appointment.patientId,
                      age: appointment.age,
                      gender: appointment.gender,
                      patientName: appointment.patientName,
                      patientMobileNumber: appointment.patientMobileNumber,
                      patientPicUrl: appointment.patientPicUrl,
                      uhid: appointment.uhid,
                    ),
                  ),
                );
              },
              onLongPress: () {
                appointmentProvider.selectedAppointmentId =
                    appointment.appointmentId;
                _showSelectionSnackbar(context, appointment);
              },
              child: _buildAppointmentCard(appointment, isSelected),
            );
          },
        );
      },
    );
  }

  //----------------------------------------------------------------------------//

  void _showSelectionSnackbar(
      BuildContext context, Appointment selectedAppointment) {
    // Set the selectedAppointmentId and show snackbar
    setState(() {
      selectedAppointmentId = selectedAppointment.appointmentId;
    });

    final snackBar = SnackBar(
      content: const Text('Appointment selected'),
      action: SnackBarAction(
        label: 'Delete',
        onPressed: () async {
          devtools.log('Delete button pressed for $selectedAppointment');

          try {
            await AppointmentService().deleteAppointmentAndUpdateSlot(
              ClinicSelection.instance.selectedClinicId,
              ClinicSelection.instance.selectedClinicName,
              selectedAppointment.appointmentId,
              selectedAppointment.appointmentDate,
              selectedAppointment.slot,
              () {
                devtools.log('Appointment and slot successfully deleted.');
                setState(() {
                  selectedAppointmentId = null; // Reset selection
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            );
          } catch (e) {
            devtools.log('Error deleting appointment: $e');
          }
        },
      ),
      behavior: SnackBarBehavior.fixed,
      duration: const Duration(seconds: 5), // Snackbar duration

      // Dismiss snackbar automatically after the duration
      onVisible: () async {
        await Future.delayed(const Duration(seconds: 5));
        if (mounted) {
          setState(() {
            selectedAppointmentId = null; // Reset selection on timeout
          });
        }
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //-----------------------------------------------------------------------------//

  // Widget _buildAppointmentCard(Appointment appointment, bool isSelected) {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Container(
  //       padding: const EdgeInsets.all(8.0),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(8.0),
  //         border: Border.all(
  //           width: 1.0,
  //           color: isSelected ? Colors.red : Colors.grey,
  //         ),
  //       ),
  //       child: Row(
  //         children: [
  //           CircleAvatar(
  //             radius: 24,
  //             backgroundColor: MyColors.colorPalette['surface'],
  //             backgroundImage: appointment.patientPicUrl != null &&
  //                     appointment.patientPicUrl!.isNotEmpty
  //                 ? NetworkImage(appointment.patientPicUrl!)
  //                 : Image.asset(
  //                     'assets/images/default-image.png',
  //                     color: MyColors.colorPalette['primary'],
  //                     colorBlendMode: BlendMode.color,
  //                   ).image,
  //           ),
  //           const SizedBox(width: 10),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(appointment.patientName),
  //               Text(DateFormat('HH:mm').format(appointment.appointmentDate)),
  //             ],
  //           ),
  //           const Spacer(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAppointmentCard(Appointment appointment, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            width: 1.0,
            color: isSelected ? Colors.red : Colors.grey,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: MyColors.colorPalette['surface'],
              backgroundImage: appointment.patientPicUrl != null &&
                      appointment.patientPicUrl!.isNotEmpty
                  ? NetworkImage(appointment.patientPicUrl!)
                  : Image.asset(
                      'assets/images/default-image.png',
                      color: MyColors.colorPalette['primary'],
                      colorBlendMode: BlendMode.color,
                    ).image,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.patientName),
                Text(DateFormat('hh:mm a')
                    .format(appointment.appointmentDate)), // Updated format
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  //----------------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 10),
          Expanded(child: _buildAppointmentsList()),
        ],
      ),
    );
  }
}

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/common_app_bar.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';

// class CalenderView extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   //final PatientService patientService;
//   final bool showBottomNavigationBar;

//   const CalenderView({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     //required this.patientService,
//     required this.showBottomNavigationBar,
//   });

//   @override
//   State<CalenderView> createState() => _CalenderViewState();
// }

// class _CalenderViewState extends State<CalenderView> {
//   late DateTime _selectedDate;
//   late DateTime _focusedDay;
//   late CalendarFormat _calendarFormat;

//   //bool _isLoading = false;
//   List<Appointment>? _appointments;
//   String? selectedAppointmentId;
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     _selectedDate = DateTime.now();
//     _focusedDay = DateTime.now();
//     _calendarFormat = CalendarFormat.week;

//     // Fetch appointments after the first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchAppointmentsForDate(_selectedDate);
//     });

//     // Listen for clinic changes and re-fetch appointments
//     ClinicSelection.instance.addListener(_onClinicChanged);
//   }

//   @override
//   void dispose() {
//     // Remove listener to avoid memory leaks
//     ClinicSelection.instance.removeListener(_onClinicChanged);
//     super.dispose();
//   }

//   // void _onClinicChanged() {
//   //   devtools.log('Clinic changed, refreshing appointments.');
//   //   Future.delayed(const Duration(milliseconds: 50), () {
//   //     _fetchAppointmentsForDate(_selectedDate);
//   //   });
//   // }

//   // void _onClinicChanged() {
//   //   devtools.log('Clinic changed, refreshing appointments.');

//   //   _fetchAppointmentsForDate(_selectedDate);
//   // }

//   void _onClinicChanged() {
//     devtools.log('Clinic changed, refreshing appointments.');

//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 300), () {
//       if (mounted) {
//         _fetchAppointmentsForDate(_selectedDate);
//       }
//     });
//   }

//   //------------------------------------------------------//

//   // Future<void> _fetchAppointmentsForDate(DateTime date) async {
//   //   if (!mounted) return; // Ensure the widget is still mounted

//   //   setState(() {
//   //     _isLoading = true; // Start loading
//   //   });

//   //   try {
//   //     final clinicId = ClinicSelection.instance.selectedClinicId;
//   //     final doctorId = ClinicSelection.instance.doctorId;

//   //     devtools.log(
//   //         'Fetching appointments for $date, clinic: $clinicId, doctor: $doctorId');

//   //     _appointments = await AppointmentService().fetchAppointmentsForDate(
//   //       clinicId: clinicId,
//   //       doctorId: doctorId,
//   //       selectedDate: date,
//   //     );

//   //     devtools.log('Appointments fetched: ${_appointments?.length}');
//   //   } catch (e) {
//   //     devtools.log('Error fetching appointments: $e');
//   //     _appointments = []; // Handle error gracefully
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() {
//   //         _isLoading = false; // Stop loading
//   //       });
//   //     }
//   //   }
//   // }

//   // Future<void> _fetchAppointmentsForDate(DateTime date) async {
//   //   if (!mounted) return; // Ensure the widget is still mounted

//   //   final appointmentProvider =
//   //       Provider.of<AppointmentProvider>(context, listen: false);

//   //   try {
//   //     await appointmentProvider.fetchAppointmentsForDate(date);
//   //     devtools.log('Appointments fetched for $date');

//   //     setState(() {
//   //       _appointments = appointmentProvider.appointments;
//   //       // Stop loading
//   //     });
//   //   } catch (e) {
//   //     devtools.log('Error fetching appointments: $e');
//   //     _appointments = []; // Handle error gracefully
//   //   }
//   // }

//   Future<void> _fetchAppointmentsForDate(DateTime date) async {
//     if (!mounted) return;

//     final appointmentProvider =
//         Provider.of<AppointmentProvider>(context, listen: false);

//     try {
//       await appointmentProvider.fetchAppointmentsForDate(date);
//       devtools.log('Appointments fetched for $date');

//       if (mounted) {
//         setState(() {
//           _appointments = appointmentProvider.appointments;
//         });
//       }
//     } catch (e) {
//       devtools.log('Error fetching appointments: $e');
//       if (mounted) {
//         setState(() {
//           _appointments = [];
//         });
//       }
//     }
//   }

//   Widget _buildCalendar() {
//     return TableCalendar(
//       firstDay: DateTime.now(),
//       lastDay: DateTime.utc(
//           _focusedDay.year + 1, _focusedDay.month, _focusedDay.day),
//       focusedDay: _focusedDay,
//       selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
//       onDaySelected: (selectedDay, focusedDay) {
//         setState(() {
//           _selectedDate = selectedDay;
//           _focusedDay = focusedDay;
//         });

//         // Fetch appointments for the selected day
//         _fetchAppointmentsForDate(selectedDay);
//       },
//       calendarFormat: _calendarFormat,
//       onFormatChanged: (format) {
//         setState(() {
//           _calendarFormat = format;
//         });
//       },
//       onPageChanged: (focusedDay) {
//         _focusedDay = focusedDay;
//       },
//       calendarStyle: CalendarStyle(
//         todayTextStyle: TextStyle(
//           color: MyColors.colorPalette['primary'],
//           fontWeight: FontWeight.bold,
//         ),
//         todayDecoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(
//             width: 2.0,
//             color: MyColors.colorPalette['primary'] ?? Colors.blue,
//           ),
//         ),
//         selectedDecoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: MyColors.colorPalette['primary'],
//         ),
//       ),
//     );
//   }

//   //----------------------------------------------------------------------------//

//   //----------------------------------------------------------------------------//
//   Widget _buildAppointmentsList() {
//     // if (_isLoading) {
//     //   return const Center(child: CircularProgressIndicator());
//     // }
//     final appointmentProvider = context.watch<AppointmentProvider>();

//     if (appointmentProvider.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_appointments == null || _appointments!.isEmpty) {
//       return const Center(
//         child: Text(
//           'No appointments for the selected date',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//       );
//     }

//     return ListView.builder(
//       itemCount: _appointments!.length,
//       itemBuilder: (context, index) {
//         final appointment = _appointments![index];
//         final isSelected = selectedAppointmentId == appointment.appointmentId;

//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => TreatmentLandingScreen(
//                   clinicId: ClinicSelection.instance.selectedClinicId,
//                   doctorId: ClinicSelection.instance.doctorId,
//                   doctorName: ClinicSelection.instance.selectedClinicName,
//                   patientId: appointment.patientId,
//                   age: appointment.age,
//                   gender: appointment.gender,
//                   patientName: appointment.patientName,
//                   patientMobileNumber: appointment.patientMobileNumber,
//                   patientPicUrl: appointment.patientPicUrl,
//                   uhid: appointment.uhid,
//                 ),
//               ),
//             );
//           },
//           onLongPress: () {
//             setState(() {
//               selectedAppointmentId = appointment.appointmentId;
//             });
//             _showSelectionSnackbar(context, appointment);
//           },
//           child: _buildAppointmentCard(appointment, isSelected),
//         );
//       },
//     );
//   }

//   void _showSelectionSnackbar(
//       BuildContext context, Appointment selectedAppointment) {
//     // Set the selectedAppointmentId and show snackbar
//     setState(() {
//       selectedAppointmentId = selectedAppointment.appointmentId;
//     });

//     final snackBar = SnackBar(
//       content: const Text('Appointment selected'),
//       action: SnackBarAction(
//         label: 'Delete',
//         onPressed: () async {
//           devtools.log('Delete button pressed for $selectedAppointment');

//           try {
//             await AppointmentService().deleteAppointmentAndUpdateSlot(
//               ClinicSelection.instance.selectedClinicId,
//               ClinicSelection.instance.selectedClinicName,
//               selectedAppointment.appointmentId,
//               selectedAppointment.appointmentDate,
//               selectedAppointment.slot,
//               () {
//                 devtools.log('Appointment and slot successfully deleted.');
//                 setState(() {
//                   selectedAppointmentId = null; // Reset selection
//                 });
//                 ScaffoldMessenger.of(context).hideCurrentSnackBar();
//               },
//             );
//           } catch (e) {
//             devtools.log('Error deleting appointment: $e');
//           }
//         },
//       ),
//       behavior: SnackBarBehavior.fixed,
//       duration: const Duration(seconds: 5), // Snackbar duration

//       // Dismiss snackbar automatically after the duration
//       onVisible: () async {
//         await Future.delayed(const Duration(seconds: 5));
//         if (mounted) {
//           setState(() {
//             selectedAppointmentId = null; // Reset selection on timeout
//           });
//         }
//       },
//     );

//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }

//   //-----------------------------------------------------------------------------//

//   Widget _buildAppointmentCard(Appointment appointment, bool isSelected) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         padding: const EdgeInsets.all(8.0),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8.0),
//           border: Border.all(
//             width: 1.0,
//             color: isSelected ? Colors.red : Colors.grey,
//           ),
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 24,
//               backgroundColor: MyColors.colorPalette['surface'],
//               backgroundImage: appointment.patientPicUrl != null &&
//                       appointment.patientPicUrl!.isNotEmpty
//                   ? NetworkImage(appointment.patientPicUrl!)
//                   : Image.asset(
//                       'assets/images/default-image.png',
//                       color: MyColors.colorPalette['primary'],
//                       colorBlendMode: BlendMode.color,
//                     ).image,
//             ),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(appointment.patientName),
//                 Text(DateFormat('HH:mm').format(appointment.appointmentDate)),
//               ],
//             ),
//             const Spacer(),
//           ],
//         ),
//       ),
//     );
//   }

//   //----------------------------------------------------------------------------//

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: const CommonAppBar(
//       //   isLandingScreen: false,
//       //   additionalContent: null,
//       // ),
//       body: Column(
//         children: [
//           _buildCalendar(),
//           const SizedBox(height: 10),
//           Expanded(child: _buildAppointmentsList()),
//         ],
//       ),
//     );
//   }
// }


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// code below stable with direct implementation of CommonAppBar
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/common_app_bar.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';

// class CalenderView extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;
//   final bool showBottomNavigationBar;

//   const CalenderView({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.patientService,
//     required this.showBottomNavigationBar,
//   });

//   @override
//   State<CalenderView> createState() => _CalenderViewState();
// }

// class _CalenderViewState extends State<CalenderView> {
//   late DateTime _selectedDate;
//   late DateTime _focusedDay;
//   late CalendarFormat _calendarFormat;

//   bool _isLoading = false;
//   List<Appointment>? _appointments;
//   String? selectedAppointmentId;

//   @override
//   void initState() {
//     super.initState();
//     _selectedDate = DateTime.now();
//     _focusedDay = DateTime.now();
//     _calendarFormat = CalendarFormat.week;

//     // Fetch appointments after the first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchAppointmentsForDate(_selectedDate);
//     });

//     // Listen for clinic changes and re-fetch appointments
//     ClinicSelection.instance.addListener(_onClinicChanged);
//   }

//   @override
//   void dispose() {
//     // Remove listener to avoid memory leaks
//     ClinicSelection.instance.removeListener(_onClinicChanged);
//     super.dispose();
//   }

//   void _onClinicChanged() {
//     devtools.log('Clinic changed, refreshing appointments.');
//     _fetchAppointmentsForDate(_selectedDate);
//   }

//   Future<void> _fetchAppointmentsForDate(DateTime date) async {
//     if (!mounted) return; // Ensure the widget is still mounted

//     setState(() {
//       _isLoading = true; // Start loading
//     });

//     try {
//       final clinicId = ClinicSelection.instance.selectedClinicId;
//       final doctorId = ClinicSelection.instance.doctorId;

//       devtools.log(
//           'Fetching appointments for $date, clinic: $clinicId, doctor: $doctorId');

//       _appointments = await AppointmentService().fetchAppointmentsForDate(
//         clinicId: clinicId,
//         doctorId: doctorId,
//         selectedDate: date,
//       );

//       devtools.log('Appointments fetched: ${_appointments?.length}');
//     } catch (e) {
//       devtools.log('Error fetching appointments: $e');
//       _appointments = []; // Handle error gracefully
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false; // Stop loading
//         });
//       }
//     }
//   }

//   Widget _buildCalendar() {
//     return TableCalendar(
//       firstDay: DateTime.now(),
//       lastDay: DateTime.utc(
//           _focusedDay.year + 1, _focusedDay.month, _focusedDay.day),
//       focusedDay: _focusedDay,
//       selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
//       onDaySelected: (selectedDay, focusedDay) {
//         setState(() {
//           _selectedDate = selectedDay;
//           _focusedDay = focusedDay;
//         });

//         // Fetch appointments for the selected day
//         _fetchAppointmentsForDate(selectedDay);
//       },
//       calendarFormat: _calendarFormat,
//       onFormatChanged: (format) {
//         setState(() {
//           _calendarFormat = format;
//         });
//       },
//       onPageChanged: (focusedDay) {
//         _focusedDay = focusedDay;
//       },
//       calendarStyle: CalendarStyle(
//         todayTextStyle: TextStyle(
//           color: MyColors.colorPalette['primary'],
//           fontWeight: FontWeight.bold,
//         ),
//         todayDecoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(
//             width: 2.0,
//             color: MyColors.colorPalette['primary'] ?? Colors.blue,
//           ),
//         ),
//         selectedDecoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: MyColors.colorPalette['primary'],
//         ),
//       ),
//     );
//   }

//   //----------------------------------------------------------------------------//

//   //----------------------------------------------------------------------------//
//   Widget _buildAppointmentsList() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_appointments == null || _appointments!.isEmpty) {
//       return const Center(
//         child: Text(
//           'No appointments for the selected date',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//       );
//     }

//     return ListView.builder(
//       itemCount: _appointments!.length,
//       itemBuilder: (context, index) {
//         final appointment = _appointments![index];
//         final isSelected = selectedAppointmentId == appointment.appointmentId;

//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => TreatmentLandingScreen(
//                   clinicId: ClinicSelection.instance.selectedClinicId,
//                   doctorId: ClinicSelection.instance.doctorId,
//                   doctorName: ClinicSelection.instance.selectedClinicName,
//                   patientId: appointment.patientId,
//                   age: appointment.age,
//                   gender: appointment.gender,
//                   patientName: appointment.patientName,
//                   patientMobileNumber: appointment.patientMobileNumber,
//                   patientPicUrl: appointment.patientPicUrl,
//                   uhid: appointment.uhid,
//                 ),
//               ),
//             );
//           },
//           onLongPress: () {
//             setState(() {
//               selectedAppointmentId = appointment.appointmentId;
//             });
//             _showSelectionSnackbar(context, appointment);
//           },
//           child: _buildAppointmentCard(appointment, isSelected),
//         );
//       },
//     );
//   }

//   void _showSelectionSnackbar(
//       BuildContext context, Appointment selectedAppointment) {
//     // Set the selectedAppointmentId and show snackbar
//     setState(() {
//       selectedAppointmentId = selectedAppointment.appointmentId;
//     });

//     final snackBar = SnackBar(
//       content: const Text('Appointment selected'),
//       action: SnackBarAction(
//         label: 'Delete',
//         onPressed: () async {
//           devtools.log('Delete button pressed for $selectedAppointment');

//           try {
//             await AppointmentService().deleteAppointmentAndUpdateSlot(
//               ClinicSelection.instance.selectedClinicId,
//               ClinicSelection.instance.selectedClinicName,
//               selectedAppointment.appointmentId,
//               selectedAppointment.appointmentDate,
//               selectedAppointment.slot,
//               () {
//                 devtools.log('Appointment and slot successfully deleted.');
//                 setState(() {
//                   selectedAppointmentId = null; // Reset selection
//                 });
//                 ScaffoldMessenger.of(context).hideCurrentSnackBar();
//               },
//             );
//           } catch (e) {
//             devtools.log('Error deleting appointment: $e');
//           }
//         },
//       ),
//       behavior: SnackBarBehavior.fixed,
//       duration: const Duration(seconds: 5), // Snackbar duration

//       // Dismiss snackbar automatically after the duration
//       onVisible: () async {
//         await Future.delayed(const Duration(seconds: 5));
//         if (mounted) {
//           setState(() {
//             selectedAppointmentId = null; // Reset selection on timeout
//           });
//         }
//       },
//     );

//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }

//   //-----------------------------------------------------------------------------//

//   Widget _buildAppointmentCard(Appointment appointment, bool isSelected) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         padding: const EdgeInsets.all(8.0),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8.0),
//           border: Border.all(
//             width: 1.0,
//             color: isSelected ? Colors.red : Colors.grey,
//           ),
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 24,
//               backgroundColor: MyColors.colorPalette['surface'],
//               backgroundImage: appointment.patientPicUrl != null &&
//                       appointment.patientPicUrl!.isNotEmpty
//                   ? NetworkImage(appointment.patientPicUrl!)
//                   : Image.asset(
//                       'assets/images/default-image.png',
//                       color: MyColors.colorPalette['primary'],
//                       colorBlendMode: BlendMode.color,
//                     ).image,
//             ),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(appointment.patientName),
//                 Text(DateFormat('HH:mm').format(appointment.appointmentDate)),
//               ],
//             ),
//             const Spacer(),
//           ],
//         ),
//       ),
//     );
//   }

//   //----------------------------------------------------------------------------//

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CommonAppBar(
//         isLandingScreen: false,
//         additionalContent: null,
//       ),
//       body: Column(
//         children: [
//           _buildCalendar(),
//           const SizedBox(height: 10),
//           Expanded(child: _buildAppointmentsList()),
//         ],
//       ),
//     );
//   }
// }

