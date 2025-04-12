import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/firestore/appointment_service.dart';
import 'package:neocaresmileapp/mywidgets/book_appoinment_current_patient.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;

class AppointmentTab extends StatefulWidget {
  final String clinicId;
  final String patientId;
  final String? treatmentId;
  final String doctorId;
  final String doctorName;
  final String patientName;
  final String patientMobileNumber;
  final int age;
  final String gender;
  final String? patientPicUrl;
  final String? uhid;

  const AppointmentTab({
    super.key,
    required this.clinicId,
    required this.patientId,
    required this.treatmentId,
    required this.doctorId,
    required this.doctorName,
    required this.age,
    required this.gender,
    required this.patientMobileNumber,
    required this.patientName,
    required this.patientPicUrl,
    required this.uhid,
  });

  @override
  State<AppointmentTab> createState() => _AppointmentTabState();
}

class _AppointmentTabState extends State<AppointmentTab> {
  final AppointmentService _appointmentService = AppointmentService();
  List<DateTime> appointmentDates = []; // Store fetched appointment dates
  List<Map<String, dynamic>> appointmentData = [];

  Map<DateTime, Map<String, String>> appointmentIdAndSlot = {};
  //bool _isDeleting = false;
  Map<DateTime, bool> _isDeletingForAppointment = {};

  @override
  void initState() {
    super.initState();
    // Fetch and update the appointment dates when the widget is initialized
    //fetchAndDisplayAppointments();
    fetchAndDisplayPatientFutureAppointments();
  }

  // ########################################################################### //
  // START fetchAndDisplayAppointments FUNCTION //
  // Function to fetch patient appointments and update the UI
  Future<void> fetchAndDisplayAppointments() async {
    try {
      // Fetch patient appointments
      List<DateTime> fetchedDates =
          await _appointmentService.fetchPatientAppointments(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
      );

      // Update the UI with fetched appointment dates
      setState(() {
        appointmentDates = fetchedDates;
      });
    } catch (e) {
      // Handle error here if needed
      devtools.log('Failed to fetch and display appointments: $e');
    }
  }

  // END fetchAndDisplayAppointments FUNCTION //

  Future<void> fetchAndDisplayPatientFutureAppointments() async {
    try {
      List<Appointment> patientFutureAppointments =
          await _appointmentService.fetchPatientFutureAppointments(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
      );

      setState(() {
        // Clear existing appointment dates and IDs
        appointmentDates.clear();
        appointmentIdAndSlot.clear();
        _isDeletingForAppointment.clear();

        // Populate appointmentDates and appointmentIds from appointmentData
        for (Appointment appointment in patientFutureAppointments) {
          DateTime appointmentDateTime = appointment.appointmentDate;
          String appointmentId = appointment.appointmentId;
          String slot = appointment.slot;

          appointmentDates.add(appointmentDateTime);
          appointmentIdAndSlot[appointmentDateTime] = {
            'appointmentId': appointmentId,
            'slot': slot
          };
          _isDeletingForAppointment[appointmentDateTime] = false;
        }
      });
    } catch (e) {
      // Handle error here if needed
      devtools
          .log('Failed to fetch and display patient future appointments: $e');
    }
  }

  // ########################################################################### //
  //
  // ########################################################################### //
  // START _buildAppointmentContainer FUNCTION //
  Widget _buildAppointmentContainer() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'All Appointments',
              style: MyTextStyle.textStyleMap['title-large']
                  ?.copyWith(color: MyColors.colorPalette['on-surface']),
            ),
          ),
        ),
        for (final appointmentDate in appointmentDates)
          _buildContainer(appointmentDate),
      ],
    );
  }

  // END _buildAppointmentContainer FUNCTION //
  // ########################################################################### //
  void _deleteAppointmentContainer(DateTime appointmentDate) {
    setState(() {
      // Remove the appointment date from the list
      appointmentDates.remove(appointmentDate);
    });
  }

  //void _deleteAppointmentAndUpdateSlot(
  Future<void> _deleteAppointmentAndUpdateSlot(
    String clinicId,
    String doctorName,
    String appointmentId,
    DateTime appointmentDate,
    String appointmentSlot,
  ) async {
    try {
      // Other deletion logic

      // Invoke delete appointment and slot function with callback
      await _appointmentService.deleteAppointmentAndUpdateSlot(
        clinicId,
        doctorName,
        appointmentId,
        appointmentDate,
        appointmentSlot,
        _onDeleteAppointmentAndUpdateSlotCallback,
      );

      // Optionally, you can add code to update the UI or show a confirmation message
    } catch (e) {
      // Handle any errors that occur during the deletion process
      devtools.log('Error deleting appointment and slot: $e');
      // Optionally, you can show an error message to the user
    }
  }

  void _onDeleteAppointmentAndUpdateSlotCallback() {
    // Fetch and display appointments
    setState(() {
      // Fetch appointments again or update the existing data
      //fetchAppointments(_selectedDate);
      fetchAndDisplayPatientFutureAppointments();
    });
  }

  // ########################################################################### //

  Widget _buildContainer(DateTime appointmentDate) {
    final formattedDate =
        DateFormat('MMMM d, EEEE').format(appointmentDate.toLocal());
    final formattedTime = DateFormat.jm().format(appointmentDate.toLocal());

    // Retrieve appointment ID and slot from appointmentIds map using appointmentDate as key
    Map<String, String>? appointmentData =
        appointmentIdAndSlot[appointmentDate];
    String appointmentId = appointmentData?['appointmentId'] ?? '';
    String appointmentSlot = appointmentData?['slot'] ?? '';
    bool isDeleting = _isDeletingForAppointment[appointmentDate] ?? false;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        // Set the flag to indicate the delete operation is ongoing for this appointment
                        _isDeletingForAppointment[appointmentDate] = true;
                      });
                      // Call the delete function
                      _deleteAppointmentAndUpdateSlot(
                        widget.clinicId,
                        widget.doctorName,
                        appointmentId,
                        appointmentDate,
                        appointmentSlot,
                      ).then((_) {
                        // After the delete operation is completed, set the flag to false
                        setState(() {
                          //_isDeleting = false;
                          _isDeletingForAppointment[appointmentDate] = false;
                        });
                      });
                    },
                    child: Stack(
                      children: [
                        Icon(
                          Icons.close,
                          size: 24,
                          color: MyColors.colorPalette['on-surface'],
                        ),
                        if (isDeleting)
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              formattedDate,
              style: MyTextStyle.textStyleMap['title-large']
                  ?.copyWith(color: MyColors.colorPalette['secondary']),
            ),
          ),
          Text(
            formattedTime,
            style: MyTextStyle.textStyleMap['body-large']
                ?.copyWith(color: MyColors.colorPalette['primary']),
          ),
        ],
      ),
    );
  }

  // END _buildContainer FUNCTION //
  // ########################################################################### //
  // Define a method to handle the callback
  void _handleAppointmentCreated() {
    devtools.log('Welcome to _handleAppointmentCreated. ');
    // Fetch and display appointments

    fetchAndDisplayPatientFutureAppointments();
  }

  //-----------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (appointmentDates.isNotEmpty) _buildAppointmentContainer(),
        Container(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          MyColors.colorPalette['on-primary']!),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          side: BorderSide(
                              color: MyColors.colorPalette['primary']!,
                              width: 1.0),
                          borderRadius: BorderRadius.circular(
                              24.0), // Adjust the radius as needed
                        ),
                      ),
                    ),
                    onPressed: () {
                      //Navigate to the BookAppointment screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookAppointmentCurrentPatient(
                            doctorId: widget.doctorId,
                            patientId: widget.patientId,
                            clinicId: widget.clinicId,
                            doctorName: widget.doctorName,
                            treatmentId: widget.treatmentId,
                            patientName: widget.patientName,
                            patientMobileNumber: widget.patientMobileNumber,
                            age: widget.age,
                            gender: widget.gender,
                            patientPicUrl: widget.patientPicUrl,
                            uhid: widget.uhid,
                            onAppointmentCreated: _handleAppointmentCreated,
                          ),
                        ),
                      );
                    },
                    child: Wrap(
                      children: [
                        Icon(
                          Icons.add,
                          color: MyColors.colorPalette['primary'],
                        ),
                        Text(
                          'Add New',
                          style: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors.colorPalette['primary']),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  //-----------------------------------------------------------------------//
}
