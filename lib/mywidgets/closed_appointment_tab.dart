import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/firestore/appointment_service.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;

class ClosedAppointmentTab extends StatefulWidget {
  final String clinicId;
  final String patientId;

  const ClosedAppointmentTab({
    super.key,
    required this.clinicId,
    required this.patientId,
  });

  @override
  State<ClosedAppointmentTab> createState() => _ClosedAppointmentTabState();
}

class _ClosedAppointmentTabState extends State<ClosedAppointmentTab> {
  final AppointmentService _appointmentService = AppointmentService();
  List<Map<String, dynamic>> appointments = [];
  bool appointmentsFetched = false;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      List<Appointment> fetchedAppointments =
          await _appointmentService.fetchPatientFutureAppointments(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
      );

      setState(() {
        appointments = fetchedAppointments.map((appointment) {
          return {
            'appointmentDate': appointment.appointmentDate,
            'appointmentSlot': appointment.slot,
          };
        }).toList();
        appointmentsFetched = true;
      });
    } catch (e) {
      devtools.log('Failed to fetch appointments: $e');
    }
  }

  String _formatDate(DateTime appointmentDate) {
    return DateFormat('MMMM d, EEEE').format(appointmentDate.toLocal());
  }

  String _formatTime(DateTime appointmentDate) {
    return DateFormat.jm().format(appointmentDate.toLocal());
  }

  Widget _buildAppointmentList() {
    return SingleChildScrollView(
      child: Column(
        children: appointments.map((appointment) {
          DateTime appointmentDate = appointment['appointmentDate'];
          String formattedDate = _formatDate(appointmentDate);
          String formattedTime = _formatTime(appointmentDate);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: MyTextStyle.textStyleMap['title-large']?.copyWith(
                      color: MyColors.colorPalette['secondary'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedTime,
                    style: MyTextStyle.textStyleMap['body-large']?.copyWith(
                      color: MyColors.colorPalette['primary'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Slot: ${appointment['appointmentSlot']}',
                    style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
                      color: MyColors.colorPalette['on-surface'],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!appointmentsFetched) {
      return const Center(child: CircularProgressIndicator());
    } else if (appointments.isEmpty) {
      return Center(
        child: Text(
          'No appointments available',
          style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
            color: MyColors.colorPalette['on-surface-variant'],
          ),
        ),
      );
    } else {
      return _buildAppointmentList();
    }
  }
}
