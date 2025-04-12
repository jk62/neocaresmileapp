import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as devtools show log;
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/patient.dart';

// -----------------------------------------------------------------------//
class Appointment {
  final String patientName;
  final String patientId;
  final String patientMobileNumber;
  final DateTime appointmentDate;
  final String slot;
  final int age;
  final String gender;
  final String doctorName;
  final String? patientPicUrl;
  final String? uhid;
  final String appointmentId;
  final String doctorId; // Added doctorId
  final String clinicId; // Added clinicId

  Appointment({
    required this.patientName,
    required this.patientId,
    required this.patientMobileNumber,
    required this.appointmentDate,
    required this.slot,
    required this.age,
    required this.gender,
    required this.doctorName,
    required this.patientPicUrl,
    required this.uhid,
    required this.appointmentId,
    required this.doctorId, // Initialize doctorId
    required this.clinicId, // Initialize clinicId
  });

  // Updated fromMap to handle new fields
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      patientName: map['patientName'] as String? ?? 'Unknown Patient',
      patientId: map['patientId'] as String? ?? 'Unknown ID',
      patientMobileNumber:
          map['patientMobileNumber'] as String? ?? 'Unknown Number',
      appointmentDate: (map['date'] is Timestamp)
          ? (map['date'] as Timestamp).toDate()
          : DateTime.tryParse(map['date'] as String) ?? DateTime.now(),
      slot: map['slot'] as String? ?? 'No Slot',
      age: map['age'] as int? ?? 0,
      gender: map['gender'] as String? ?? 'Unknown',
      doctorName: map['doctorName'] as String? ?? 'Unknown Doctor',
      patientPicUrl: map['patientPicUrl'] as String?,
      uhid: map['uhid'] as String?,
      appointmentId: map['appointmentId'] as String? ?? 'Unknown ID',
      doctorId:
          map['doctorId'] as String? ?? 'Unknown Doctor ID', // Map doctorId
      clinicId:
          map['clinicId'] as String? ?? 'Unknown Clinic ID', // Map clinicId
    );
  }

  // Optional: Convert Appointment to a Map for Firestore updates
  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'patientId': patientId,
      'patientMobileNumber': patientMobileNumber,
      'date': appointmentDate,
      'slot': slot,
      'age': age,
      'gender': gender,
      'doctorName': doctorName,
      'patientPicUrl': patientPicUrl,
      'uhid': uhid,
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'clinicId': clinicId,
    };
  }
}

//-------------------------------------------------------------------------------//
// class AppointmentService {
//   final clinicsCollection = FirebaseFirestore.instance.collection('clinics');
//-------------------------------------------------------------------------------//
class AppointmentService {
  final FirebaseFirestore firestore;
  final CollectionReference clinicsCollection;

  AppointmentService({FirebaseFirestore? firestoreInstance})
      : firestore = firestoreInstance ?? FirebaseFirestore.instance,
        clinicsCollection = (firestoreInstance ?? FirebaseFirestore.instance)
            .collection('clinics');

// class AppointmentService {
//   final FirebaseFirestore firestore;
//   final CollectionReference clinicsCollection;
//   late String _clinicId;

//   // Constructor
//   AppointmentService({FirebaseFirestore? firestoreInstance})
//       : firestore = firestoreInstance ?? FirebaseFirestore.instance,
//         clinicsCollection = (firestoreInstance ?? FirebaseFirestore.instance)
//             .collection('clinics') {
//     // Initialize the clinicId from ClinicSelection
//     _clinicId = ClinicSelection.instance.selectedClinicId;

//     // Add a listener to update clinicId on clinic change
//     ClinicSelection.instance.addListener(_onClinicChanged);
//   }

//   // Method to handle clinic changes
//   void _onClinicChanged() {
//     final newClinicId = ClinicSelection.instance.selectedClinicId;
//     if (_clinicId != newClinicId) {
//       _clinicId = newClinicId;
//       devtools.log('AppointmentService: Clinic ID updated to $_clinicId');
//     }
//   }

//   // Dispose the listener when no longer needed
//   void dispose() {
//     ClinicSelection.instance.removeListener(_onClinicChanged);
//   }

//-------------------------------------------------------------------------------//

  //getAppointments function to fetch all appointments
  //of all patients
  //of all past and future dates
  Future<List<Appointment>> getAppointments({
    required String doctorId,
    required String clinicId,
  }) async {
    List<Appointment> appointments = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
          .doc(clinicId)
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
          in snapshot.docs) {
        Map<String, dynamic> appointmentData = documentSnapshot.data();

        // Debug print to see the appointment data
        devtools.log(
            'This is coming from inside getAppointments fucntion of NewAppointmentService. Fetched appointment data: $appointmentData');

        appointments.add(Appointment.fromMap(appointmentData));

        // Print the number of appointments found
        devtools.log('Total appointments found: ${appointments.length}');
      }
    } catch (e) {
      // Print the number of appointments found
      devtools.log(
          'This is coming from catch block of getAppointments() of NewAppointmentService. Failed to fetch appointment data');
      throw Exception('Failed to fetch appointments: $e');
    }

    return appointments;
  }

  Future<void> createAppointment(
      {required String doctorId,
      required String clinicId,
      required String patientName,
      required String patientMobileNumber,
      required String date,
      required String slot,
      required int age, // Add age
      required String gender, // Add gender
      required String uhid, // Add uhid
      required String patientPicUrl // Add patientPicUrl
      }) async {
    try {
      // final clinicsCollection =
      //     FirebaseFirestore.instance.collection('clinics');

      // Query for the patient with the given mobile number
      QuerySnapshot<Map<String, dynamic>> patientSnapshot =
          await clinicsCollection
              .doc(clinicId)
              .collection('patients')
              .where('patientMobileNumber', isEqualTo: patientMobileNumber)
              .limit(1)
              .get();
      print(
          '**** createAppointment invoked ! patientSnapshot is $patientSnapshot ****');

      String patientId;
      if (patientSnapshot.size > 0) {
        patientId = patientSnapshot.docs[0].id;
      } else {
        DocumentReference<Map<String, dynamic>> newPatientDocRef =
            await clinicsCollection.doc(clinicId).collection('patients').add({
          'patientName': patientName,
          'patientMobileNumber': patientMobileNumber,
          'age': age, // Store age
          'gender': gender, // Store gender
          'uhid': uhid, // Store uhid
          'patientPicUrl': patientPicUrl, // Store patientPicUrl
        });
        patientId = newPatientDocRef.id;
      }

      // Fetch latest treatment (if any) for the patient
      final patientRef =
          clinicsCollection.doc(clinicId).collection('patients').doc(patientId);
      final treatmentsSnapshot =
          await patientRef.collection('treatments').get();

      String? treatmentId;
      if (treatmentsSnapshot.docs.isNotEmpty) {
        treatmentId = treatmentsSnapshot.docs.last['treatmentId'];
      }

      DateTime completeDateTime = DateTime.parse(date);
      Timestamp appointmentDate = Timestamp.fromDate(completeDateTime);

      // Create a new appointment with the full patient data
      final appointmentData = {
        'patientName': patientName,
        'age': age, // Add age
        'gender': gender, // Add gender
        'patientMobileNumber': patientMobileNumber,
        'patientId': patientId,
        'doctorId': doctorId,
        'uhid': uhid, // Add uhid
        'slot': slot,
        'date': appointmentDate,
        'treatmentId': treatmentId,
        'patientPicUrl': patientPicUrl, // Add patientPicUrl
      };

      // Push appointmentData to Firestore
      DocumentReference<Map<String, dynamic>> appointmentRef =
          await clinicsCollection
              .doc(clinicId)
              .collection('appointments')
              .add(appointmentData);

      String appointmentId = appointmentRef.id;
      await appointmentRef.update({'appointmentId': appointmentId});

      // Add appointment reference to patient's appointments sub-collection
      await patientRef.collection('appointments').add({
        'appointmentId': appointmentId,
        'date': appointmentDate,
      });

      devtools.log('Appointment created successfully with ID: $appointmentId');
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  //---------------------------------------------------------------------//
  // Function to create an appointment for a new patient
  // Function to create an appointment for a new patient
  Future<void> createAppointmentForNewPatient({
    required String doctorId,
    required String clinicId,
    required Patient patient,
    required String date, // This should be passed as ISO string
    required String slot,
    String? treatmentId, // Add treatmentId as an optional parameter
  }) async {
    try {
      // final clinicsCollection =
      //     FirebaseFirestore.instance.collection('clinics');

      // Add the patient if necessary (assuming patient already exists here)
      final patientId = patient.patientId;

      // Convert date string to DateTime and then to Timestamp
      DateTime completeDateTime = DateTime.parse(date);
      Timestamp appointmentDate = Timestamp.fromDate(completeDateTime);

      // Create the appointment data
      final appointmentData = {
        'patientName': patient.patientName,
        'age': patient.age,
        'gender': patient.gender,
        'patientMobileNumber': patient.patientMobileNumber,
        'patientId': patientId,
        'doctorId': doctorId,
        'uhid': patient.uhid,
        'slot': slot,
        'date': appointmentDate,
        'treatmentId': treatmentId, // Use the treatmentId if provided
        'patientPicUrl': patient.patientPicUrl,
      };

      // Add the appointment to Firestore under the clinic's appointments sub-collection
      DocumentReference<Map<String, dynamic>> appointmentRef =
          await clinicsCollection
              .doc(clinicId)
              .collection('appointments')
              .add(appointmentData);

      // Add the appointmentId to the appointment document
      final appointmentId = appointmentRef.id;
      await appointmentRef.update({'appointmentId': appointmentId});

      // Update the patient's document with the new appointment
      await clinicsCollection
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('appointments')
          .add({
        'appointmentId': appointmentId,
        'date': appointmentDate,
      });

      devtools.log('Appointment created successfully with ID: $appointmentId');
    } catch (e) {
      devtools.log('Failed to create appointment: $e');
      throw Exception('Failed to create appointment: $e');
    }
  }

  //-------------------------------------------------------------------------//
  Future<void> createAppointmentForSelectedPatient({
    required String clinicId,
    required String doctorId,
    required Patient selectedPatient,
    required String slot,
    required DateTime selectedDate,
  }) async {
    try {
      // Directly parse the slot string into a DateTime object
      final completeDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        DateFormat('h:mm a').parse(slot).hour,
        DateFormat('h:mm a').parse(slot).minute,
      );

      // Convert to UTC and back to IST as needed
      DateTime completeDateTimeInUtc = completeDateTime.toUtc();
      DateTime completeDateTimeInIst = completeDateTimeInUtc.toLocal();

      // Fetch patient document reference
      // final patientRef = FirebaseFirestore.instance
      //     .collection('clinics')
      //     .doc(clinicId)
      //     .collection('patients')
      //     .doc(selectedPatient.patientId);
      final patientRef = clinicsCollection
          .doc(clinicId)
          .collection('patients')
          .doc(selectedPatient.patientId);

      // Check if there is an existing treatment for the patient
      final treatmentsSnapshot =
          await patientRef.collection('treatments').get();
      String? treatmentId;
      if (treatmentsSnapshot.docs.isNotEmpty) {
        final latestTreatmentDoc = treatmentsSnapshot.docs.last;
        treatmentId = latestTreatmentDoc['treatmentId'];
      }

      // Prepare appointment data
      final appointmentData = {
        'patientName': selectedPatient.patientName,
        'age': selectedPatient.age,
        'gender': selectedPatient.gender,
        'patientMobileNumber': selectedPatient.patientMobileNumber,
        'patientId': selectedPatient.patientId,
        'doctorId': doctorId,
        'uhid': selectedPatient.uhid,
        'slot': slot,
        'date': Timestamp.fromDate(completeDateTimeInIst),
        'treatmentId': treatmentId,
        'patientPicUrl': selectedPatient.patientPicUrl,
      };

      // Create the appointment in the clinic's appointments sub-collection
      // final clinicRef = FirebaseFirestore.instance
      //     .collection('clinics')
      //     .doc(clinicId)
      //     .collection('appointments');

      final clinicRef =
          clinicsCollection.doc(clinicId).collection('appointments');
      final clinicAppointmentDocRef = await clinicRef.add(appointmentData);

      // Update the appointment with appointmentId
      final appointmentId = clinicAppointmentDocRef.id;
      await clinicAppointmentDocRef.update({'appointmentId': appointmentId});

      // Update the patient's appointment list
      await patientRef.collection('appointments').add({
        'date': Timestamp.fromDate(completeDateTimeInIst),
        'treatmentId': treatmentId,
        'appointmentId': appointmentId,
      });
    } catch (e) {
      throw Exception('Error creating appointment for selected patient: $e');
    }
  }

  //-------------------------------------------------------------------------//

  // Function to fetch the latest treatmentId for a given patient
  Future<String?> fetchLatestTreatmentId({
    required String clinicId,
    required String patientId,
  }) async {
    try {
      // final patientRef = FirebaseFirestore.instance
      //     .collection('clinics')
      //     .doc(clinicId)
      //     .collection('patients')
      //     .doc(patientId);
      final patientRef =
          clinicsCollection.doc(clinicId).collection('patients').doc(patientId);

      // Fetch the treatments sub-collection
      final treatmentsSnapshot =
          await patientRef.collection('treatments').get();

      if (treatmentsSnapshot.docs.isNotEmpty) {
        // If treatments exist, return the treatmentId from the latest document
        final latestTreatmentDoc = treatmentsSnapshot.docs.last;
        return latestTreatmentDoc['treatmentId'] as String?;
      }
      return null;
    } catch (e) {
      devtools.log('Error fetching latest treatmentId: $e');
      throw Exception('Failed to fetch latest treatmentId: $e');
    }
  }
  //---------------------------------------------------------------------//

  Future<Map<String, Map<String, List<String>>>> fetchSlots({
    required String doctorName, // Use doctorName instead of doctorId
    required String clinicId,
  }) async {
    try {
      // Fetch the document for the logged-in doctor from the 'availableSlots' sub-collection
      DocumentSnapshot<Map<String, dynamic>> slotsSnapshot =
          await clinicsCollection
              .doc(clinicId)
              .collection('availableSlots')
              .doc(doctorName) // Use doctorName as the document ID
              .get();

      if (slotsSnapshot.exists) {
        // Parse and extract the available slots from the document data
        Map<String, dynamic> slotsData = slotsSnapshot.data()!;
        Map<String, Map<String, List<String>>> availableSlots = {};

        // Convert the data to the correct format
        slotsData.forEach((day, slots) {
          Map<String, List<String>> slotTypes = {};
          slots.forEach((slotType, timeSlots) {
            slotTypes[slotType] = List<String>.from(timeSlots);
          });
          availableSlots[day] = slotTypes;
        });

        return availableSlots;
      } else {
        // The document does not exist, return an empty map
        return {};
      }
    } catch (e) {
      throw Exception('Failed to fetch slots: $e');
    }
  }

  //fetchFutureAppointments to fetch all future appointment of all patient
  Future<List<Appointment>> fetchFutureAppointments({
    required String doctorId,
    required String clinicId,
  }) async {
    List<Appointment> futureAppointments = [];

    try {
      final now = DateTime.now();

      QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
          .doc(clinicId)
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThan: Timestamp.fromDate(now))
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
          in snapshot.docs) {
        Map<String, dynamic> appointmentData = documentSnapshot.data();

        final appointment = Appointment.fromMap(appointmentData);

        // Compare the appointment's date and time with the current date and time
        if (appointment.appointmentDate.isAfter(now)) {
          futureAppointments.add(appointment);
        }
      }

      // Sort the future appointments in ascending order
      futureAppointments
          .sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    } catch (e) {
      // Handle error here if needed
      devtools.log(
          'This is coming from catch block of fetchFutureAppointments() of AppointmentService. Failed to fetch future appointments');
      throw Exception('Failed to fetch future appointments: $e');
    }

    return futureAppointments;
  }

  Future<List<DateTime>> fetchPatientAppointments({
    required String clinicId,
    required String patientId,
  }) async {
    List<DateTime> appointmentDates = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('appointments')
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
          in snapshot.docs) {
        Map<String, dynamic> appointmentData = documentSnapshot.data();

        // Extract the 'date' field from the appointment data as a Timestamp
        Timestamp timestamp = appointmentData['date'] as Timestamp;

        // Convert the Timestamp to a DateTime object
        DateTime appointmentDateTime = timestamp.toDate();

        // Add the DateTime to the list
        appointmentDates.add(appointmentDateTime);
      }
    } catch (e) {
      // Handle error here if needed
      devtools.log(
          'This is coming from catch block of fetchPatientAppointments() of AppointmentService. Failed to fetch patient appointments');
      throw Exception('Failed to fetch patient appointments: $e');
    }

    return appointmentDates;
  }

  Future<List<Appointment>> fetchPatientFutureAppointments({
    required String clinicId,
    required String patientId,
  }) async {
    List<Appointment> patientFutureAppointments = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
          .doc(clinicId)
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where('date', isGreaterThan: Timestamp.now())
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
          in snapshot.docs) {
        Map<String, dynamic> appointmentData = documentSnapshot.data();
        Appointment appointment = Appointment.fromMap(appointmentData);
        patientFutureAppointments.add(appointment);
      }
    } catch (e) {
      devtools.log('Failed to fetch future appointments: $e');
      throw Exception('Failed to fetch future appointments: $e');
    }

    return patientFutureAppointments;
  }

  //-----------------------------------------------------------------------//

  Future<void> deleteAppointment(
    String clinicId,
    String appointmentId,
  ) async {
    try {
      devtools.log('Welcome to deleteAppointment() inside AppointmentService');
      final appointmentCollection =
          clinicsCollection.doc(clinicId).collection('appointments');

      // Delete the appointment from the main appointments collection
      await appointmentCollection.doc(appointmentId).delete();
      devtools.log(
          'appointmentId $appointmentId deleted successfully from appointments under clinics');

      // Now delete the appointment from each patient's appointments sub-collection
      QuerySnapshot<Map<String, dynamic>> patientsSnapshot =
          await clinicsCollection.doc(clinicId).collection('patients').get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> patientSnapshot
          in patientsSnapshot.docs) {
        // Query appointments sub-collection for each patient
        QuerySnapshot<Map<String, dynamic>> appointmentsSnapshot =
            await patientSnapshot.reference
                .collection('appointments')
                .where('appointmentId', isEqualTo: appointmentId)
                .get();

        // Delete appointment document if found
        if (appointmentsSnapshot.docs.isNotEmpty) {
          await appointmentsSnapshot.docs.first.reference.delete();
          devtools.log(
              'appointmentId $appointmentId deleted successfully from appointments under patient doc');
        }
      }
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  //-----------------------------------------------------------------------//

  Future<void> updateSlot(
      String clinicId, String doctorName, DateTime date, String slot) async {
    devtools.log('Welcome to updateSlot inside AppointmentService. ');
    devtools.log(
        'clinicId is $clinicId, doctorName is $doctorName, date is $date, slot is $slot');

    try {
      final selectedDateFormatted = DateFormat('d-MMMM').format(date);
      final availableSlotsCollection =
          clinicsCollection.doc(clinicId).collection('availableSlots');
      final doctorDoc = availableSlotsCollection.doc('Dr$doctorName');
      final selectedDateSlotsCollection =
          doctorDoc.collection('selectedDateSlots');

      // Check if selectedDateSlots collection exists
      final selectedDateSnapshot =
          await selectedDateSlotsCollection.doc(selectedDateFormatted).get();

      if (selectedDateSnapshot.exists) {
        // If selectedDateFormatted document exists, iterate over all slots
        final slotsData = selectedDateSnapshot.data() as Map<String, dynamic>;
        devtools.log('slotsData fetched inside updateSlot is $slotsData');

        for (final timePeriodData in slotsData['slots']) {
          final List<Map<String, dynamic>> slots =
              List<Map<String, dynamic>>.from(timePeriodData['slots']);
          devtools.log('slots is $slots');

          for (final slotData in slots) {
            devtools.log('slotData is $slotData');
            final slotValue = slotData['slot'] as String;
            devtools.log('slotValue is $slotValue');
            devtools.log('slot is $slot');
            if (slotValue == slot) {
              devtools.log('perfect matching slot found');
              slotData['isBooked'] = false;
              // Set isCancelled to true
              slotData['isCancelled'] = true;

              // After modifying the slot data, update the Firestore document
              await selectedDateSlotsCollection
                  .doc(selectedDateFormatted)
                  .set(slotsData);
              devtools.log(
                  'Slot $slotValue for $selectedDateFormatted updated successfully.');
              return; // Exit loop if slot is found and updated
            }
          }
        }
      } else {
        devtools.log(
            'No selectedDateSlots document found for $selectedDateFormatted.');
      }
    } catch (e) {
      throw Exception('Failed to update slot: $e');
    }
  }

  //-----------------------------------------------------------------------//

  Future<void> deleteAppointmentAndUpdateSlot(
    String clinicId,
    String doctorName,
    String appointmentId,
    DateTime appointmentDate,
    String appointmentSlot,
    Function onDeleteAppointmentAndUpdateSlotCallback,
  ) async {
    try {
      await deleteAppointment(clinicId, appointmentId);
      await updateSlot(clinicId, doctorName, appointmentDate, appointmentSlot);

      // Invoke callback after successful deletion and update
      onDeleteAppointmentAndUpdateSlotCallback();
    } catch (e) {
      devtools.log('Error deleting appointment and slot: $e');
      throw Exception('Failed to delete appointment and update slot: $e');
    }
  }

  //--------------------------------------------------------------------------//
  // Stream<Appointment?> getNextAppointmentStream({
  //   required String doctorId,
  //   required String clinicId,
  // }) async* {
  //   devtools.log(
  //       'Welcome to getNextAppointmentStream!doctorId receive is $doctorId and clinicId is $clinicId');

  //   final now = DateTime.now();
  //   final todayMidnight = DateTime(now.year, now.month, now.day);

  //   try {
  //     devtools.log(
  //         'This is coming from inside try block of getNextAppointmentStream');

  //     QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
  //         .doc(clinicId)
  //         .collection('appointments')
  //         .where('doctorId', isEqualTo: doctorId)
  //         .where('date', isGreaterThanOrEqualTo: todayMidnight)
  //         .orderBy('date')
  //         .get();

  //     devtools
  //         .log('snapshot found inside getNextAppointmentStream is $snapshot');

  //     List<Appointment> upcomingAppointments = [];

  //     //for (final documentSnapshot in snapshot.docs) {
  //     for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
  //         in snapshot.docs) {
  //       devtools.log(
  //           'This is coming from inside for loop of getNextAppointmentStream.');
  //       final appointmentData = documentSnapshot.data();
  //       devtools.log(
  //           'appointmentData found inside  getNextAppointmentStream is $appointmentData');

  //       final appointment = Appointment.fromMap(appointmentData);
  //       devtools.log(
  //           'next appointment found inside getNextAppointmentStream is $appointment');

  //       if (appointment.appointmentDate.isAfter(now)) {
  //         upcomingAppointments.add(appointment);
  //       }
  //     }

  //     upcomingAppointments
  //         .sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

  //     if (upcomingAppointments.isNotEmpty) {
  //       yield upcomingAppointments.first;
  //     }
  //   } catch (e) {
  //     // Handle error here if needed
  //     devtools
  //         .log('Error occurred: $e, doctorId: $doctorId, clinicId: $clinicId');
  //     throw Exception('Failed to fetch appointments: $e');
  //   }
  // }

  Stream<Appointment?> getNextAppointmentStream({
    required String doctorId,
    required String clinicId,
  }) {
    devtools.log(
        'Welcome to modified getNextAppointmentStream! doctorId: $doctorId, clinicId: $clinicId');

    // Get the current timestamp
    final now = DateTime.now();

    try {
      devtools.log(
          'Setting up Firestore snapshot listener for next appointment stream.');

      // Query Firestore with live snapshots for real-time updates
      Stream<QuerySnapshot<Map<String, dynamic>>> snapshotStream =
          clinicsCollection
              .doc(clinicId)
              .collection('appointments')
              .where('doctorId', isEqualTo: doctorId)
              .where('date',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(
                      now)) // Ensure only future appointments
              .orderBy('date') // Sort by date in ascending order
              .snapshots();

      // Map Firestore snapshot stream to Appointment stream
      return snapshotStream.map((snapshot) {
        devtools.log('Snapshot received for next appointment stream.');

        if (snapshot.docs.isEmpty) {
          devtools.log('No upcoming appointments found.');
          return null; // No upcoming appointments
        }

        // Get the first document (closest upcoming appointment)
        final appointmentData = snapshot.docs.first.data();
        final nextAppointment = Appointment.fromMap(appointmentData);

        devtools.log('Next appointment found: $nextAppointment');
        return nextAppointment;
      });
    } catch (e) {
      devtools.log(
          'Error occurred in modified getNextAppointmentStream: $e, doctorId: $doctorId, clinicId: $clinicId');
      throw Exception('Failed to fetch next appointment: $e');
    }
  }

  //--------------------------------------------------------------------------//
  //getNextAppointment function to fetch immediate next appointment from now
  // Future<Appointment?> getNextAppointment({
  //   required String doctorId,
  //   required String clinicId,
  // }) async {
  //   final now = DateTime.now();
  //   final todayMidnight = DateTime(now.year, now.month, now.day);

  //   try {
  //     devtools.log(
  //         'This is coming from inside try block of getNextAppointment function defined inside AppointmentService. doctorId: $doctorId, clinicId: $clinicId');

  //     QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
  //         .doc(clinicId)
  //         .collection('appointments')
  //         .where('doctorId', isEqualTo: doctorId)
  //         .where('date', isGreaterThanOrEqualTo: todayMidnight)
  //         .orderBy('date')
  //         .get();

  //     List<Appointment> upcomingAppointments = [];

  //     for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
  //         in snapshot.docs) {
  //       devtools
  //           .log('Inside for loop: doctorId: $doctorId, clinicId: $clinicId');

  //       Map<String, dynamic> appointmentData = documentSnapshot.data();

  //       final appointment = Appointment.fromMap(appointmentData);
  //       devtools.log(
  //           'This is coming from inside for loop.appointment after being populated from appointmentData is $appointment');

  //       // Compare the appointment's date and time with the current date and time
  //       if (appointment.appointmentDate.isAfter(now)) {
  //         upcomingAppointments.add(appointment);
  //       }
  //     }

  //     // Sort the upcoming appointments in ascending order
  //     upcomingAppointments
  //         .sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

  //     if (upcomingAppointments.isNotEmpty) {
  //       devtools.log(
  //           'This coming from inside if (upcomingAppointments.isNotEmpty) clause inside getNextAppointment function inside AppointmentService. Returning ${upcomingAppointments.first} ');
  //       return upcomingAppointments
  //           .first; // Return the first upcoming appointment
  //     }
  //   } catch (e) {
  //     // Handle error here if needed
  //     devtools.log(
  //         'This is coming from catch block of getNextAppointments() of NewAppointmentService. Failed to fetch appointment data');
  //     devtools
  //         .log('Error occurred: $e, doctorId: $doctorId, clinicId: $clinicId');

  //     throw Exception('Failed to fetch appointments: $e');
  //   }

  //   return null; // No upcoming appointments
  // }

  Future<Appointment?> getNextAppointment({
    required String doctorId,
    required String clinicId,
  }) async {
    final now = DateTime.now();

    try {
      devtools.log(
          'This is coming from inside try block of getNextAppointment function defined inside AppointmentService. doctorId: $doctorId, clinicId: $clinicId');

      // Query Firestore to fetch only appointments scheduled after the current time
      QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
          .doc(clinicId)
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date',
              isGreaterThan:
                  Timestamp.fromDate(now)) // Use now instead of todayMidnight
          .orderBy('date') // Ensure appointments are ordered by date
          .limit(1) // Fetch only the first upcoming appointment
          .get();

      if (snapshot.docs.isEmpty) {
        devtools.log(
            'This is coming from inside getNextAppointment function. No upcoming appointments found for doctorId: $doctorId, clinicId: $clinicId.');
        return null;
      }

      // Parse and return the first appointment
      final appointmentData = snapshot.docs.first.data();
      final nextAppointment = Appointment.fromMap(appointmentData);

      devtools.log(
          'This is coming from inside getNextAppointment function. Next appointment found: $nextAppointment');
      return nextAppointment;
    } catch (e) {
      devtools.log(
          'This is coming from catch block of getNextAppointment function. Failed to fetch appointment data: $e');
      throw Exception('Failed to fetch next appointment: $e');
    }
  }

  //-------------------------------------------------------//
  // This method now returns a Stream<List<Appointment>> instead of Firestore types

  Stream<List<Appointment>> listenToAppointments({
    required String doctorId,
    required String clinicId,
  }) {
    devtools.log(
        '**** This is coming from inside listenToAppointments defined inside AppointmentService. Listening to appointments for doctorId: $doctorId');
// Check if clinicId is empty
    if (clinicId.isEmpty) {
      devtools.log('Error: clinicId is empty. Cannot listen to appointments.');
      return const Stream<List<Appointment>>.empty();
    }
    return clinicsCollection
        .doc(clinicId)
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        devtools.log(
            '**** This is coming from inside listenToAppointments defined inside AppointmentService. No appointments found for doctorId: $doctorId');
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Appointment.fromMap(data);
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> fetchSlotsForSelectedDay({
    required String clinicId,
    required String doctorId,
    required String doctorName,
    required DateTime selectedDate,
  }) async {
    try {
      devtools.log(
          'Welcome inside fetchSlotsForSelectedDay defined inside AppointmentService. Fetching slots for selected date: $selectedDate');
      devtools.log(
          '@@@@@ clinicId is $clinicId, doctorName is $doctorName, doctorId is $doctorId, selectedDate is $selectedDate @@@@@');

      final selectedDateFormatted = DateFormat('d-MMMM').format(selectedDate);
      final selectedDayOfWeek = DateFormat('EEEE').format(selectedDate);

      // final doctorDocumentRef = FirebaseFirestore.instance
      //     .collection('clinics')
      //     .doc(clinicId)
      //     .collection('availableSlots')
      //     .doc('Dr$doctorName');
      final doctorDocumentRef = clinicsCollection
          .doc(clinicId)
          .collection('availableSlots')
          .doc('Dr$doctorName');

      final selectedDateSlotsRef = doctorDocumentRef
          .collection('selectedDateSlots')
          .doc(selectedDateFormatted);

      final selectedDateSlotsDoc = await selectedDateSlotsRef.get();

      List<Map<String, dynamic>> allSlots = [];

      if (selectedDateSlotsDoc.exists) {
        final slotsData = selectedDateSlotsDoc.data();
        devtools.log('Slots data for selected date: $slotsData');

        if (slotsData != null && slotsData.containsKey('slots')) {
          final List<dynamic> allSlotsData = slotsData['slots'];
          for (var slotsPeriodData in allSlotsData) {
            final List<Map<String, dynamic>> slotsForPeriod =
                List<Map<String, dynamic>>.from(slotsPeriodData['slots']);
            allSlots.addAll(slotsForPeriod);
          }
        }
      }

      if (allSlots.isEmpty) {
        devtools.log('Fetching slots for $selectedDayOfWeek as fallback');
        final doctorDocument = await doctorDocumentRef.get();

        if (doctorDocument.exists) {
          final slotsData = doctorDocument.data();
          devtools.log(
              'Slots data in doctorDocument: $slotsData'); // Log the full data
          if (slotsData != null && slotsData.containsKey(selectedDayOfWeek)) {
            devtools.log('Slots found for $selectedDayOfWeek');
            final slotsForSelectedDay = slotsData[selectedDayOfWeek];

            devtools.log('Slots for $selectedDayOfWeek: $slotsForSelectedDay');

            slotsForSelectedDay.forEach((timePeriod, slots) {
              allSlots.addAll(List<Map<String, dynamic>>.from(slots));
            });
          }
        }
      }

      if (allSlots.isEmpty) {
        devtools
            .log('No slots found for the selected date or day of the week.');
        return [];
      }

      // Create a range for the entire selected date
      final startOfDay =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Fetch booked appointments for the entire selected date
      devtools.log('Fetching appointments for $selectedDate (whole day)');
      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .get();

      List<String> bookedSlots = [];
      if (appointmentsSnapshot.docs.isNotEmpty) {
        devtools.log('@@@@@ appointmentsSnapshot is not empty @@@@@@');
        bookedSlots = appointmentsSnapshot.docs
            .map((doc) => doc['slot'] as String)
            .toList();
      }
      devtools.log(
          '@@@@ This is coming from inside fetchSlotsForSelectedDay defined inside AppointmentService. bookedSlots are $bookedSlots ');

      // Update the isBooked status based on booked slots
      final updatedSlots = allSlots.map((slotData) {
        final isBooked = bookedSlots.contains(slotData['slot']);
        return {
          ...slotData,
          'isBooked': isBooked,
        };
      }).toList();

      devtools.log('@@@@ Updated slots with isBooked flag: $updatedSlots');
      return updatedSlots;
    } catch (e) {
      devtools.log('Failed to fetch slots: $e');
      throw Exception('Failed to fetch slots: $e');
    }
  }

  //---------------------------------------------------------------------//

  Future<void> updateSlotAvailability({
    required String clinicId,
    required String doctorName,
    required DateTime selectedDate,
    required List<Map<String, dynamic>> updatedSlots,
  }) async {
    try {
      devtools.log(
          '@@@@@ Welcome to updateSlotAvailability defined inside AppointmentService. updatedSlots are $updatedSlots');
      final selectedDateFormatted = DateFormat('d-MMMM').format(selectedDate);
      final doctorDocumentRef = clinicsCollection
          .doc(clinicId)
          .collection('availableSlots')
          .doc('Dr$doctorName')
          .collection('selectedDateSlots')
          .doc(selectedDateFormatted);

      final slotsData = <String, dynamic>{'slots': updatedSlots};

      await doctorDocumentRef.set(slotsData);
    } catch (e) {
      devtools.log('Failed to update slot availability: $e');
      throw Exception('Failed to update slot availability: $e');
    }
  }

  Future<List<Appointment>> fetchAppointmentsForDate({
    required String clinicId,
    required String doctorId,
    required DateTime selectedDate,
  }) async {
    try {
      // Start of day
      final startOfDay = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );

      // End of day (Add 1 day then subtract 1 second for the end of the day)
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));

      QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
          .doc(clinicId)
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('date')
          .get();

      if (snapshot.docs.isEmpty) {
        devtools.log('No appointments found for the selected date.');
        return [];
      }

      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    } catch (e) {
      devtools.log('Error fetching appointments for date: $e');
      throw Exception('Failed to fetch appointments: $e');
    }
  }

  //--------------------------------------------------------//
  Future<DateTime?> updateTreatmentIdInAppointmentsAndFetchDate({
    required String clinicId,
    required String patientId,
    required String? treatmentId,
  }) async {
    // Create references to the appointment documents in both locations
    final clinicRef =
        clinicsCollection.doc(clinicId).collection('appointments');
    final patientRef = clinicsCollection
        .doc(clinicId)
        .collection('patients')
        .doc(patientId)
        .collection('appointments');

    // Fetch the appointments matching the patientId and future dates
    final clinicQuery = await clinicRef
        .where('patientId', isEqualTo: patientId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.now())
        .get();

    print(
        '**** clinicRef is $clinicRef, patientRef is $patientRef and clinicQuery is $clinicQuery');
    // Iterate over the clinic's appointments
    for (final clinicDoc in clinicQuery.docs) {
      final appointmentId = clinicDoc.id;
      devtools.log('appointmentId captured which is: $appointmentId');
      print('appointmentId captured which is: $appointmentId');

      try {
        // Update treatmentId for clinic appointments
        await clinicRef.doc(appointmentId).update({'treatmentId': treatmentId});

        // Fetch the corresponding patient appointment using appointmentId
        final patientQuery = await patientRef
            .where('appointmentId', isEqualTo: appointmentId)
            .get();

        print('patientQuery is $patientQuery');

        // Update treatmentId for patient appointments
        for (final patientDoc in patientQuery.docs) {
          final patientAppointmentId = patientDoc.id;
          print('patientAppointmentId is $patientAppointmentId');
          try {
            await patientRef
                .doc(patientAppointmentId)
                .update({'treatmentId': treatmentId});
          } catch (e) {
            devtools.log('Error updating patient appointment document: $e');
            print('Error updating patient appointment document: $e');
          }
        }
      } catch (e) {
        devtools.log('Error updating clinic appointment document: $e');
        print('Error updating clinic appointment document: $e');
      }
    }

    // Return the appointmentDate if available
    if (clinicQuery.docs.isNotEmpty) {
      final Timestamp appointmentTimestamp = clinicQuery.docs.first['date'];
      devtools.log('Appointment Timestamp: $appointmentTimestamp');
      return appointmentTimestamp.toDate();
    } else {
      devtools.log('No appointments found');
      return null;
    }
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW BEFORE IMPLEMENTING CLINIC SELECTION LISTENER
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:developer' as devtools show log;
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';

// // -----------------------------------------------------------------------//
// class Appointment {
//   final String patientName;
//   final String patientId;
//   final String patientMobileNumber;
//   final DateTime appointmentDate;
//   final String slot;
//   final int age;
//   final String gender;
//   final String doctorName;
//   final String? patientPicUrl;
//   final String? uhid;
//   final String appointmentId;
//   final String doctorId; // Added doctorId
//   final String clinicId; // Added clinicId

//   Appointment({
//     required this.patientName,
//     required this.patientId,
//     required this.patientMobileNumber,
//     required this.appointmentDate,
//     required this.slot,
//     required this.age,
//     required this.gender,
//     required this.doctorName,
//     required this.patientPicUrl,
//     required this.uhid,
//     required this.appointmentId,
//     required this.doctorId, // Initialize doctorId
//     required this.clinicId, // Initialize clinicId
//   });

//   // Updated fromMap to handle new fields
//   factory Appointment.fromMap(Map<String, dynamic> map) {
//     return Appointment(
//       patientName: map['patientName'] as String? ?? 'Unknown Patient',
//       patientId: map['patientId'] as String? ?? 'Unknown ID',
//       patientMobileNumber:
//           map['patientMobileNumber'] as String? ?? 'Unknown Number',
//       appointmentDate: (map['date'] is Timestamp)
//           ? (map['date'] as Timestamp).toDate()
//           : DateTime.tryParse(map['date'] as String) ?? DateTime.now(),
//       slot: map['slot'] as String? ?? 'No Slot',
//       age: map['age'] as int? ?? 0,
//       gender: map['gender'] as String? ?? 'Unknown',
//       doctorName: map['doctorName'] as String? ?? 'Unknown Doctor',
//       patientPicUrl: map['patientPicUrl'] as String?,
//       uhid: map['uhid'] as String?,
//       appointmentId: map['appointmentId'] as String? ?? 'Unknown ID',
//       doctorId:
//           map['doctorId'] as String? ?? 'Unknown Doctor ID', // Map doctorId
//       clinicId:
//           map['clinicId'] as String? ?? 'Unknown Clinic ID', // Map clinicId
//     );
//   }

//   // Optional: Convert Appointment to a Map for Firestore updates
//   Map<String, dynamic> toMap() {
//     return {
//       'patientName': patientName,
//       'patientId': patientId,
//       'patientMobileNumber': patientMobileNumber,
//       'date': appointmentDate,
//       'slot': slot,
//       'age': age,
//       'gender': gender,
//       'doctorName': doctorName,
//       'patientPicUrl': patientPicUrl,
//       'uhid': uhid,
//       'appointmentId': appointmentId,
//       'doctorId': doctorId,
//       'clinicId': clinicId,
//     };
//   }
// }

// //-------------------------------------------------------------------------------//
// // class AppointmentService {
// //   final clinicsCollection = FirebaseFirestore.instance.collection('clinics');
// //-------------------------------------------------------------------------------//
// class AppointmentService {
//   final FirebaseFirestore firestore;
//   final CollectionReference clinicsCollection;

//   AppointmentService({FirebaseFirestore? firestoreInstance})
//       : firestore = firestoreInstance ?? FirebaseFirestore.instance,
//         clinicsCollection = (firestoreInstance ?? FirebaseFirestore.instance)
//             .collection('clinics');

// //-------------------------------------------------------------------------------//

//   //getAppointments function to fetch all appointments
//   //of all patients
//   //of all past and future dates
//   Future<List<Appointment>> getAppointments({
//     required String doctorId,
//     required String clinicId,
//   }) async {
//     List<Appointment> appointments = [];

//     try {
//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('appointments')
//           .where('doctorId', isEqualTo: doctorId)
//           .get();

//       for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
//           in snapshot.docs) {
//         Map<String, dynamic> appointmentData = documentSnapshot.data();

//         // Debug print to see the appointment data
//         devtools.log(
//             'This is coming from inside getAppointments fucntion of NewAppointmentService. Fetched appointment data: $appointmentData');

//         appointments.add(Appointment.fromMap(appointmentData));

//         // Print the number of appointments found
//         devtools.log('Total appointments found: ${appointments.length}');
//       }
//     } catch (e) {
//       // Print the number of appointments found
//       devtools.log(
//           'This is coming from catch block of getAppointments() of NewAppointmentService. Failed to fetch appointment data');
//       throw Exception('Failed to fetch appointments: $e');
//     }

//     return appointments;
//   }

//   Future<void> createAppointment(
//       {required String doctorId,
//       required String clinicId,
//       required String patientName,
//       required String patientMobileNumber,
//       required String date,
//       required String slot,
//       required int age, // Add age
//       required String gender, // Add gender
//       required String uhid, // Add uhid
//       required String patientPicUrl // Add patientPicUrl
//       }) async {
//     try {
//       // final clinicsCollection =
//       //     FirebaseFirestore.instance.collection('clinics');

//       // Query for the patient with the given mobile number
//       QuerySnapshot<Map<String, dynamic>> patientSnapshot =
//           await clinicsCollection
//               .doc(clinicId)
//               .collection('patients')
//               .where('patientMobileNumber', isEqualTo: patientMobileNumber)
//               .limit(1)
//               .get();
//       print(
//           '**** createAppointment invoked ! patientSnapshot is $patientSnapshot ****');

//       String patientId;
//       if (patientSnapshot.size > 0) {
//         patientId = patientSnapshot.docs[0].id;
//       } else {
//         DocumentReference<Map<String, dynamic>> newPatientDocRef =
//             await clinicsCollection.doc(clinicId).collection('patients').add({
//           'patientName': patientName,
//           'patientMobileNumber': patientMobileNumber,
//           'age': age, // Store age
//           'gender': gender, // Store gender
//           'uhid': uhid, // Store uhid
//           'patientPicUrl': patientPicUrl, // Store patientPicUrl
//         });
//         patientId = newPatientDocRef.id;
//       }

//       // Fetch latest treatment (if any) for the patient
//       final patientRef =
//           clinicsCollection.doc(clinicId).collection('patients').doc(patientId);
//       final treatmentsSnapshot =
//           await patientRef.collection('treatments').get();

//       String? treatmentId;
//       if (treatmentsSnapshot.docs.isNotEmpty) {
//         treatmentId = treatmentsSnapshot.docs.last['treatmentId'];
//       }

//       DateTime completeDateTime = DateTime.parse(date);
//       Timestamp appointmentDate = Timestamp.fromDate(completeDateTime);

//       // Create a new appointment with the full patient data
//       final appointmentData = {
//         'patientName': patientName,
//         'age': age, // Add age
//         'gender': gender, // Add gender
//         'patientMobileNumber': patientMobileNumber,
//         'patientId': patientId,
//         'doctorId': doctorId,
//         'uhid': uhid, // Add uhid
//         'slot': slot,
//         'date': appointmentDate,
//         'treatmentId': treatmentId,
//         'patientPicUrl': patientPicUrl, // Add patientPicUrl
//       };

//       // Push appointmentData to Firestore
//       DocumentReference<Map<String, dynamic>> appointmentRef =
//           await clinicsCollection
//               .doc(clinicId)
//               .collection('appointments')
//               .add(appointmentData);

//       String appointmentId = appointmentRef.id;
//       await appointmentRef.update({'appointmentId': appointmentId});

//       // Add appointment reference to patient's appointments sub-collection
//       await patientRef.collection('appointments').add({
//         'appointmentId': appointmentId,
//         'date': appointmentDate,
//       });

//       devtools.log('Appointment created successfully with ID: $appointmentId');
//     } catch (e) {
//       throw Exception('Failed to create appointment: $e');
//     }
//   }

//   //---------------------------------------------------------------------//
//   // Function to create an appointment for a new patient
//   // Function to create an appointment for a new patient
//   Future<void> createAppointmentForNewPatient({
//     required String doctorId,
//     required String clinicId,
//     required Patient patient,
//     required String date, // This should be passed as ISO string
//     required String slot,
//     String? treatmentId, // Add treatmentId as an optional parameter
//   }) async {
//     try {
//       // final clinicsCollection =
//       //     FirebaseFirestore.instance.collection('clinics');

//       // Add the patient if necessary (assuming patient already exists here)
//       final patientId = patient.patientId;

//       // Convert date string to DateTime and then to Timestamp
//       DateTime completeDateTime = DateTime.parse(date);
//       Timestamp appointmentDate = Timestamp.fromDate(completeDateTime);

//       // Create the appointment data
//       final appointmentData = {
//         'patientName': patient.patientName,
//         'age': patient.age,
//         'gender': patient.gender,
//         'patientMobileNumber': patient.patientMobileNumber,
//         'patientId': patientId,
//         'doctorId': doctorId,
//         'uhid': patient.uhid,
//         'slot': slot,
//         'date': appointmentDate,
//         'treatmentId': treatmentId, // Use the treatmentId if provided
//         'patientPicUrl': patient.patientPicUrl,
//       };

//       // Add the appointment to Firestore under the clinic's appointments sub-collection
//       DocumentReference<Map<String, dynamic>> appointmentRef =
//           await clinicsCollection
//               .doc(clinicId)
//               .collection('appointments')
//               .add(appointmentData);

//       // Add the appointmentId to the appointment document
//       final appointmentId = appointmentRef.id;
//       await appointmentRef.update({'appointmentId': appointmentId});

//       // Update the patient's document with the new appointment
//       await clinicsCollection
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId)
//           .collection('appointments')
//           .add({
//         'appointmentId': appointmentId,
//         'date': appointmentDate,
//       });

//       devtools.log('Appointment created successfully with ID: $appointmentId');
//     } catch (e) {
//       devtools.log('Failed to create appointment: $e');
//       throw Exception('Failed to create appointment: $e');
//     }
//   }

//   //-------------------------------------------------------------------------//
//   Future<void> createAppointmentForSelectedPatient({
//     required String clinicId,
//     required String doctorId,
//     required Patient selectedPatient,
//     required String slot,
//     required DateTime selectedDate,
//   }) async {
//     try {
//       // Directly parse the slot string into a DateTime object
//       final completeDateTime = DateTime(
//         selectedDate.year,
//         selectedDate.month,
//         selectedDate.day,
//         DateFormat('h:mm a').parse(slot).hour,
//         DateFormat('h:mm a').parse(slot).minute,
//       );

//       // Convert to UTC and back to IST as needed
//       DateTime completeDateTimeInUtc = completeDateTime.toUtc();
//       DateTime completeDateTimeInIst = completeDateTimeInUtc.toLocal();

//       // Fetch patient document reference
//       // final patientRef = FirebaseFirestore.instance
//       //     .collection('clinics')
//       //     .doc(clinicId)
//       //     .collection('patients')
//       //     .doc(selectedPatient.patientId);
//       final patientRef = clinicsCollection
//           .doc(clinicId)
//           .collection('patients')
//           .doc(selectedPatient.patientId);

//       // Check if there is an existing treatment for the patient
//       final treatmentsSnapshot =
//           await patientRef.collection('treatments').get();
//       String? treatmentId;
//       if (treatmentsSnapshot.docs.isNotEmpty) {
//         final latestTreatmentDoc = treatmentsSnapshot.docs.last;
//         treatmentId = latestTreatmentDoc['treatmentId'];
//       }

//       // Prepare appointment data
//       final appointmentData = {
//         'patientName': selectedPatient.patientName,
//         'age': selectedPatient.age,
//         'gender': selectedPatient.gender,
//         'patientMobileNumber': selectedPatient.patientMobileNumber,
//         'patientId': selectedPatient.patientId,
//         'doctorId': doctorId,
//         'uhid': selectedPatient.uhid,
//         'slot': slot,
//         'date': Timestamp.fromDate(completeDateTimeInIst),
//         'treatmentId': treatmentId,
//         'patientPicUrl': selectedPatient.patientPicUrl,
//       };

//       // Create the appointment in the clinic's appointments sub-collection
//       // final clinicRef = FirebaseFirestore.instance
//       //     .collection('clinics')
//       //     .doc(clinicId)
//       //     .collection('appointments');

//       final clinicRef =
//           clinicsCollection.doc(clinicId).collection('appointments');
//       final clinicAppointmentDocRef = await clinicRef.add(appointmentData);

//       // Update the appointment with appointmentId
//       final appointmentId = clinicAppointmentDocRef.id;
//       await clinicAppointmentDocRef.update({'appointmentId': appointmentId});

//       // Update the patient's appointment list
//       await patientRef.collection('appointments').add({
//         'date': Timestamp.fromDate(completeDateTimeInIst),
//         'treatmentId': treatmentId,
//         'appointmentId': appointmentId,
//       });
//     } catch (e) {
//       throw Exception('Error creating appointment for selected patient: $e');
//     }
//   }

//   //-------------------------------------------------------------------------//

//   // Function to fetch the latest treatmentId for a given patient
//   Future<String?> fetchLatestTreatmentId({
//     required String clinicId,
//     required String patientId,
//   }) async {
//     try {
//       // final patientRef = FirebaseFirestore.instance
//       //     .collection('clinics')
//       //     .doc(clinicId)
//       //     .collection('patients')
//       //     .doc(patientId);
//       final patientRef =
//           clinicsCollection.doc(clinicId).collection('patients').doc(patientId);

//       // Fetch the treatments sub-collection
//       final treatmentsSnapshot =
//           await patientRef.collection('treatments').get();

//       if (treatmentsSnapshot.docs.isNotEmpty) {
//         // If treatments exist, return the treatmentId from the latest document
//         final latestTreatmentDoc = treatmentsSnapshot.docs.last;
//         return latestTreatmentDoc['treatmentId'] as String?;
//       }
//       return null;
//     } catch (e) {
//       devtools.log('Error fetching latest treatmentId: $e');
//       throw Exception('Failed to fetch latest treatmentId: $e');
//     }
//   }
//   //---------------------------------------------------------------------//

//   Future<Map<String, Map<String, List<String>>>> fetchSlots({
//     required String doctorName, // Use doctorName instead of doctorId
//     required String clinicId,
//   }) async {
//     try {
//       // Fetch the document for the logged-in doctor from the 'availableSlots' sub-collection
//       DocumentSnapshot<Map<String, dynamic>> slotsSnapshot =
//           await clinicsCollection
//               .doc(clinicId)
//               .collection('availableSlots')
//               .doc(doctorName) // Use doctorName as the document ID
//               .get();

//       if (slotsSnapshot.exists) {
//         // Parse and extract the available slots from the document data
//         Map<String, dynamic> slotsData = slotsSnapshot.data()!;
//         Map<String, Map<String, List<String>>> availableSlots = {};

//         // Convert the data to the correct format
//         slotsData.forEach((day, slots) {
//           Map<String, List<String>> slotTypes = {};
//           slots.forEach((slotType, timeSlots) {
//             slotTypes[slotType] = List<String>.from(timeSlots);
//           });
//           availableSlots[day] = slotTypes;
//         });

//         return availableSlots;
//       } else {
//         // The document does not exist, return an empty map
//         return {};
//       }
//     } catch (e) {
//       throw Exception('Failed to fetch slots: $e');
//     }
//   }

//   //fetchFutureAppointments to fetch all future appointment of all patient
//   Future<List<Appointment>> fetchFutureAppointments({
//     required String doctorId,
//     required String clinicId,
//   }) async {
//     List<Appointment> futureAppointments = [];

//     try {
//       final now = DateTime.now();

//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('appointments')
//           .where('doctorId', isEqualTo: doctorId)
//           .where('date', isGreaterThan: Timestamp.fromDate(now))
//           .get();

//       for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
//           in snapshot.docs) {
//         Map<String, dynamic> appointmentData = documentSnapshot.data();

//         final appointment = Appointment.fromMap(appointmentData);

//         // Compare the appointment's date and time with the current date and time
//         if (appointment.appointmentDate.isAfter(now)) {
//           futureAppointments.add(appointment);
//         }
//       }

//       // Sort the future appointments in ascending order
//       futureAppointments
//           .sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
//     } catch (e) {
//       // Handle error here if needed
//       devtools.log(
//           'This is coming from catch block of fetchFutureAppointments() of AppointmentService. Failed to fetch future appointments');
//       throw Exception('Failed to fetch future appointments: $e');
//     }

//     return futureAppointments;
//   }

//   Future<List<DateTime>> fetchPatientAppointments({
//     required String clinicId,
//     required String patientId,
//   }) async {
//     List<DateTime> appointmentDates = [];

//     try {
//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId)
//           .collection('appointments')
//           .get();

//       for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
//           in snapshot.docs) {
//         Map<String, dynamic> appointmentData = documentSnapshot.data();

//         // Extract the 'date' field from the appointment data as a Timestamp
//         Timestamp timestamp = appointmentData['date'] as Timestamp;

//         // Convert the Timestamp to a DateTime object
//         DateTime appointmentDateTime = timestamp.toDate();

//         // Add the DateTime to the list
//         appointmentDates.add(appointmentDateTime);
//       }
//     } catch (e) {
//       // Handle error here if needed
//       devtools.log(
//           'This is coming from catch block of fetchPatientAppointments() of AppointmentService. Failed to fetch patient appointments');
//       throw Exception('Failed to fetch patient appointments: $e');
//     }

//     return appointmentDates;
//   }

//   Future<List<Appointment>> fetchPatientFutureAppointments({
//     required String clinicId,
//     required String patientId,
//   }) async {
//     List<Appointment> patientFutureAppointments = [];

//     try {
//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('appointments')
//           .where('patientId', isEqualTo: patientId)
//           .where('date', isGreaterThan: Timestamp.now())
//           .get();

//       for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
//           in snapshot.docs) {
//         Map<String, dynamic> appointmentData = documentSnapshot.data();
//         Appointment appointment = Appointment.fromMap(appointmentData);
//         patientFutureAppointments.add(appointment);
//       }
//     } catch (e) {
//       devtools.log('Failed to fetch future appointments: $e');
//       throw Exception('Failed to fetch future appointments: $e');
//     }

//     return patientFutureAppointments;
//   }

//   //-----------------------------------------------------------------------//

//   Future<void> deleteAppointment(
//     String clinicId,
//     String appointmentId,
//   ) async {
//     try {
//       devtools.log('Welcome to deleteAppointment() inside AppointmentService');
//       final appointmentCollection =
//           clinicsCollection.doc(clinicId).collection('appointments');

//       // Delete the appointment from the main appointments collection
//       await appointmentCollection.doc(appointmentId).delete();
//       devtools.log(
//           'appointmentId $appointmentId deleted successfully from appointments under clinics');

//       // Now delete the appointment from each patient's appointments sub-collection
//       QuerySnapshot<Map<String, dynamic>> patientsSnapshot =
//           await clinicsCollection.doc(clinicId).collection('patients').get();

//       for (QueryDocumentSnapshot<Map<String, dynamic>> patientSnapshot
//           in patientsSnapshot.docs) {
//         // Query appointments sub-collection for each patient
//         QuerySnapshot<Map<String, dynamic>> appointmentsSnapshot =
//             await patientSnapshot.reference
//                 .collection('appointments')
//                 .where('appointmentId', isEqualTo: appointmentId)
//                 .get();

//         // Delete appointment document if found
//         if (appointmentsSnapshot.docs.isNotEmpty) {
//           await appointmentsSnapshot.docs.first.reference.delete();
//           devtools.log(
//               'appointmentId $appointmentId deleted successfully from appointments under patient doc');
//         }
//       }
//     } catch (e) {
//       throw Exception('Failed to delete appointment: $e');
//     }
//   }

//   //-----------------------------------------------------------------------//

//   Future<void> updateSlot(
//       String clinicId, String doctorName, DateTime date, String slot) async {
//     devtools.log('Welcome to updateSlot inside AppointmentService. ');
//     devtools.log(
//         'clinicId is $clinicId, doctorName is $doctorName, date is $date, slot is $slot');

//     try {
//       final selectedDateFormatted = DateFormat('d-MMMM').format(date);
//       final availableSlotsCollection =
//           clinicsCollection.doc(clinicId).collection('availableSlots');
//       final doctorDoc = availableSlotsCollection.doc('Dr$doctorName');
//       final selectedDateSlotsCollection =
//           doctorDoc.collection('selectedDateSlots');

//       // Check if selectedDateSlots collection exists
//       final selectedDateSnapshot =
//           await selectedDateSlotsCollection.doc(selectedDateFormatted).get();

//       if (selectedDateSnapshot.exists) {
//         // If selectedDateFormatted document exists, iterate over all slots
//         final slotsData = selectedDateSnapshot.data() as Map<String, dynamic>;
//         devtools.log('slotsData fetched inside updateSlot is $slotsData');

//         for (final timePeriodData in slotsData['slots']) {
//           final List<Map<String, dynamic>> slots =
//               List<Map<String, dynamic>>.from(timePeriodData['slots']);
//           devtools.log('slots is $slots');

//           for (final slotData in slots) {
//             devtools.log('slotData is $slotData');
//             final slotValue = slotData['slot'] as String;
//             devtools.log('slotValue is $slotValue');
//             devtools.log('slot is $slot');
//             if (slotValue == slot) {
//               devtools.log('perfect matching slot found');
//               slotData['isBooked'] = false;
//               // Set isCancelled to true
//               slotData['isCancelled'] = true;

//               // After modifying the slot data, update the Firestore document
//               await selectedDateSlotsCollection
//                   .doc(selectedDateFormatted)
//                   .set(slotsData);
//               devtools.log(
//                   'Slot $slotValue for $selectedDateFormatted updated successfully.');
//               return; // Exit loop if slot is found and updated
//             }
//           }
//         }
//       } else {
//         devtools.log(
//             'No selectedDateSlots document found for $selectedDateFormatted.');
//       }
//     } catch (e) {
//       throw Exception('Failed to update slot: $e');
//     }
//   }

//   //-----------------------------------------------------------------------//

//   Future<void> deleteAppointmentAndUpdateSlot(
//     String clinicId,
//     String doctorName,
//     String appointmentId,
//     DateTime appointmentDate,
//     String appointmentSlot,
//     Function onDeleteAppointmentAndUpdateSlotCallback,
//   ) async {
//     try {
//       await deleteAppointment(clinicId, appointmentId);
//       await updateSlot(clinicId, doctorName, appointmentDate, appointmentSlot);

//       // Invoke callback after successful deletion and update
//       onDeleteAppointmentAndUpdateSlotCallback();
//     } catch (e) {
//       devtools.log('Error deleting appointment and slot: $e');
//       throw Exception('Failed to delete appointment and update slot: $e');
//     }
//   }

//   //--------------------------------------------------------------------------//
//   Stream<Appointment?> getNextAppointmentStream({
//     required String doctorId,
//     required String clinicId,
//   }) async* {
//     devtools.log(
//         'Welcome to getNextAppointmentStream!doctorId receive is $doctorId and clinicId is $clinicId');

//     final now = DateTime.now();
//     final todayMidnight = DateTime(now.year, now.month, now.day);

//     try {
//       devtools.log(
//           'This is coming from inside try block of getNextAppointmentStream');

//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('appointments')
//           .where('doctorId', isEqualTo: doctorId)
//           .where('date', isGreaterThanOrEqualTo: todayMidnight)
//           .orderBy('date')
//           .get();

//       devtools
//           .log('snapshot found inside getNextAppointmentStream is $snapshot');

//       List<Appointment> upcomingAppointments = [];

//       //for (final documentSnapshot in snapshot.docs) {
//       for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
//           in snapshot.docs) {
//         devtools.log(
//             'This is coming from inside for loop of getNextAppointmentStream.');
//         final appointmentData = documentSnapshot.data();
//         devtools.log(
//             'appointmentData found inside  getNextAppointmentStream is $appointmentData');

//         final appointment = Appointment.fromMap(appointmentData);
//         devtools.log(
//             'next appointment found inside getNextAppointmentStream is $appointment');

//         if (appointment.appointmentDate.isAfter(now)) {
//           upcomingAppointments.add(appointment);
//         }
//       }

//       upcomingAppointments
//           .sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

//       if (upcomingAppointments.isNotEmpty) {
//         yield upcomingAppointments.first;
//       }
//     } catch (e) {
//       // Handle error here if needed
//       devtools
//           .log('Error occurred: $e, doctorId: $doctorId, clinicId: $clinicId');
//       throw Exception('Failed to fetch appointments: $e');
//     }
//   }

//   //--------------------------------------------------------------------------//
//   //getNextAppointment function to fetch immediate next appointment from now
//   Future<Appointment?> getNextAppointment({
//     required String doctorId,
//     required String clinicId,
//   }) async {
//     final now = DateTime.now();
//     final todayMidnight = DateTime(now.year, now.month, now.day);

//     try {
//       devtools.log(
//           'This is coming from inside try block of getNextAppointment function defined inside AppointmentService. doctorId: $doctorId, clinicId: $clinicId');

//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('appointments')
//           .where('doctorId', isEqualTo: doctorId)
//           .where('date', isGreaterThanOrEqualTo: todayMidnight)
//           .orderBy('date')
//           .get();

//       List<Appointment> upcomingAppointments = [];

//       for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
//           in snapshot.docs) {
//         devtools
//             .log('Inside for loop: doctorId: $doctorId, clinicId: $clinicId');

//         Map<String, dynamic> appointmentData = documentSnapshot.data();

//         final appointment = Appointment.fromMap(appointmentData);
//         devtools.log(
//             'This is coming from inside for loop.appointment after being populated from appointmentData is $appointment');

//         // Compare the appointment's date and time with the current date and time
//         if (appointment.appointmentDate.isAfter(now)) {
//           upcomingAppointments.add(appointment);
//         }
//       }

//       // Sort the upcoming appointments in ascending order
//       upcomingAppointments
//           .sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

//       if (upcomingAppointments.isNotEmpty) {
//         devtools.log(
//             'This coming from inside if (upcomingAppointments.isNotEmpty) clause inside getNextAppointment function inside AppointmentService. Returning ${upcomingAppointments.first} ');
//         return upcomingAppointments
//             .first; // Return the first upcoming appointment
//       }
//     } catch (e) {
//       // Handle error here if needed
//       devtools.log(
//           'This is coming from catch block of getNextAppointments() of NewAppointmentService. Failed to fetch appointment data');
//       devtools
//           .log('Error occurred: $e, doctorId: $doctorId, clinicId: $clinicId');

//       throw Exception('Failed to fetch appointments: $e');
//     }

//     return null; // No upcoming appointments
//   }

//   //-------------------------------------------------------//
//   // This method now returns a Stream<List<Appointment>> instead of Firestore types

//   Stream<List<Appointment>> listenToAppointments({
//     required String doctorId,
//     required String clinicId,
//   }) {
//     devtools.log(
//         '**** This is coming from inside listenToAppointments defined inside AppointmentService. Listening to appointments for doctorId: $doctorId');
// // Check if clinicId is empty
//     if (clinicId.isEmpty) {
//       devtools.log('Error: clinicId is empty. Cannot listen to appointments.');
//       return const Stream<List<Appointment>>.empty();
//     }
//     return clinicsCollection
//         .doc(clinicId)
//         .collection('appointments')
//         .where('doctorId', isEqualTo: doctorId)
//         .snapshots()
//         .map((snapshot) {
//       if (snapshot.docs.isEmpty) {
//         devtools.log(
//             '**** This is coming from inside listenToAppointments defined inside AppointmentService. No appointments found for doctorId: $doctorId');
//         return [];
//       }

//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         return Appointment.fromMap(data);
//       }).toList();
//     });
//   }

//   Future<List<Map<String, dynamic>>> fetchSlotsForSelectedDay({
//     required String clinicId,
//     required String doctorId,
//     required String doctorName,
//     required DateTime selectedDate,
//   }) async {
//     try {
//       devtools.log(
//           'Welcome inside fetchSlotsForSelectedDay defined inside AppointmentService. Fetching slots for selected date: $selectedDate');
//       devtools.log(
//           '@@@@@ clinicId is $clinicId, doctorName is $doctorName, doctorId is $doctorId, selectedDate is $selectedDate @@@@@');

//       final selectedDateFormatted = DateFormat('d-MMMM').format(selectedDate);
//       final selectedDayOfWeek = DateFormat('EEEE').format(selectedDate);

//       // final doctorDocumentRef = FirebaseFirestore.instance
//       //     .collection('clinics')
//       //     .doc(clinicId)
//       //     .collection('availableSlots')
//       //     .doc('Dr$doctorName');
//       final doctorDocumentRef = clinicsCollection
//           .doc(clinicId)
//           .collection('availableSlots')
//           .doc('Dr$doctorName');

//       final selectedDateSlotsRef = doctorDocumentRef
//           .collection('selectedDateSlots')
//           .doc(selectedDateFormatted);

//       final selectedDateSlotsDoc = await selectedDateSlotsRef.get();

//       List<Map<String, dynamic>> allSlots = [];

//       if (selectedDateSlotsDoc.exists) {
//         final slotsData = selectedDateSlotsDoc.data();
//         devtools.log('Slots data for selected date: $slotsData');

//         if (slotsData != null && slotsData.containsKey('slots')) {
//           final List<dynamic> allSlotsData = slotsData['slots'];
//           for (var slotsPeriodData in allSlotsData) {
//             final List<Map<String, dynamic>> slotsForPeriod =
//                 List<Map<String, dynamic>>.from(slotsPeriodData['slots']);
//             allSlots.addAll(slotsForPeriod);
//           }
//         }
//       }

//       if (allSlots.isEmpty) {
//         devtools.log('Fetching slots for $selectedDayOfWeek as fallback');
//         final doctorDocument = await doctorDocumentRef.get();

//         if (doctorDocument.exists) {
//           final slotsData = doctorDocument.data();
//           devtools.log(
//               'Slots data in doctorDocument: $slotsData'); // Log the full data
//           if (slotsData != null && slotsData.containsKey(selectedDayOfWeek)) {
//             devtools.log('Slots found for $selectedDayOfWeek');
//             final slotsForSelectedDay = slotsData[selectedDayOfWeek];

//             devtools.log('Slots for $selectedDayOfWeek: $slotsForSelectedDay');

//             slotsForSelectedDay.forEach((timePeriod, slots) {
//               allSlots.addAll(List<Map<String, dynamic>>.from(slots));
//             });
//           }
//         }
//       }

//       if (allSlots.isEmpty) {
//         devtools
//             .log('No slots found for the selected date or day of the week.');
//         return [];
//       }

//       // Create a range for the entire selected date
//       final startOfDay =
//           DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
//       final endOfDay = startOfDay.add(const Duration(days: 1));

//       // Fetch booked appointments for the entire selected date
//       devtools.log('Fetching appointments for $selectedDate (whole day)');
//       final appointmentsSnapshot = await FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('appointments')
//           .where('doctorId', isEqualTo: doctorId)
//           .where('date', isGreaterThanOrEqualTo: startOfDay)
//           .where('date', isLessThan: endOfDay)
//           .get();

//       List<String> bookedSlots = [];
//       if (appointmentsSnapshot.docs.isNotEmpty) {
//         devtools.log('@@@@@ appointmentsSnapshot is not empty @@@@@@');
//         bookedSlots = appointmentsSnapshot.docs
//             .map((doc) => doc['slot'] as String)
//             .toList();
//       }
//       devtools.log(
//           '@@@@ This is coming from inside fetchSlotsForSelectedDay defined inside AppointmentService. bookedSlots are $bookedSlots ');

//       // Update the isBooked status based on booked slots
//       final updatedSlots = allSlots.map((slotData) {
//         final isBooked = bookedSlots.contains(slotData['slot']);
//         return {
//           ...slotData,
//           'isBooked': isBooked,
//         };
//       }).toList();

//       devtools.log('@@@@ Updated slots with isBooked flag: $updatedSlots');
//       return updatedSlots;
//     } catch (e) {
//       devtools.log('Failed to fetch slots: $e');
//       throw Exception('Failed to fetch slots: $e');
//     }
//   }

//   //---------------------------------------------------------------------//

//   Future<void> updateSlotAvailability({
//     required String clinicId,
//     required String doctorName,
//     required DateTime selectedDate,
//     required List<Map<String, dynamic>> updatedSlots,
//   }) async {
//     try {
//       devtools.log(
//           '@@@@@ Welcome to updateSlotAvailability defined inside AppointmentService. updatedSlots are $updatedSlots');
//       final selectedDateFormatted = DateFormat('d-MMMM').format(selectedDate);
//       final doctorDocumentRef = clinicsCollection
//           .doc(clinicId)
//           .collection('availableSlots')
//           .doc('Dr$doctorName')
//           .collection('selectedDateSlots')
//           .doc(selectedDateFormatted);

//       final slotsData = <String, dynamic>{'slots': updatedSlots};

//       await doctorDocumentRef.set(slotsData);
//     } catch (e) {
//       devtools.log('Failed to update slot availability: $e');
//       throw Exception('Failed to update slot availability: $e');
//     }
//   }

//   Future<List<Appointment>> fetchAppointmentsForDate({
//     required String clinicId,
//     required String doctorId,
//     required DateTime selectedDate,
//   }) async {
//     try {
//       // Start of day
//       final startOfDay = DateTime(
//         selectedDate.year,
//         selectedDate.month,
//         selectedDate.day,
//       );

//       // End of day (Add 1 day then subtract 1 second for the end of the day)
//       final endOfDay = startOfDay
//           .add(const Duration(days: 1))
//           .subtract(const Duration(seconds: 1));

//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('appointments')
//           .where('doctorId', isEqualTo: doctorId)
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
//           .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
//           .orderBy('date')
//           .get();

//       if (snapshot.docs.isEmpty) {
//         devtools.log('No appointments found for the selected date.');
//         return [];
//       }

//       return snapshot.docs
//           .map((doc) => Appointment.fromMap(doc.data()))
//           .toList();
//     } catch (e) {
//       devtools.log('Error fetching appointments for date: $e');
//       throw Exception('Failed to fetch appointments: $e');
//     }
//   }

//   //--------------------------------------------------------//
//   Future<DateTime?> updateTreatmentIdInAppointmentsAndFetchDate({
//     required String clinicId,
//     required String patientId,
//     required String? treatmentId,
//   }) async {
//     // Create references to the appointment documents in both locations
//     final clinicRef =
//         clinicsCollection.doc(clinicId).collection('appointments');
//     final patientRef = clinicsCollection
//         .doc(clinicId)
//         .collection('patients')
//         .doc(patientId)
//         .collection('appointments');

//     // Fetch the appointments matching the patientId and future dates
//     final clinicQuery = await clinicRef
//         .where('patientId', isEqualTo: patientId)
//         .where('date', isGreaterThanOrEqualTo: Timestamp.now())
//         .get();

//     print(
//         '**** clinicRef is $clinicRef, patientRef is $patientRef and clinicQuery is $clinicQuery');
//     // Iterate over the clinic's appointments
//     for (final clinicDoc in clinicQuery.docs) {
//       final appointmentId = clinicDoc.id;
//       devtools.log('appointmentId captured which is: $appointmentId');
//       print('appointmentId captured which is: $appointmentId');

//       try {
//         // Update treatmentId for clinic appointments
//         await clinicRef.doc(appointmentId).update({'treatmentId': treatmentId});

//         // Fetch the corresponding patient appointment using appointmentId
//         final patientQuery = await patientRef
//             .where('appointmentId', isEqualTo: appointmentId)
//             .get();

//         print('patientQuery is $patientQuery');

//         // Update treatmentId for patient appointments
//         for (final patientDoc in patientQuery.docs) {
//           final patientAppointmentId = patientDoc.id;
//           print('patientAppointmentId is $patientAppointmentId');
//           try {
//             await patientRef
//                 .doc(patientAppointmentId)
//                 .update({'treatmentId': treatmentId});
//           } catch (e) {
//             devtools.log('Error updating patient appointment document: $e');
//             print('Error updating patient appointment document: $e');
//           }
//         }
//       } catch (e) {
//         devtools.log('Error updating clinic appointment document: $e');
//         print('Error updating clinic appointment document: $e');
//       }
//     }

//     // Return the appointmentDate if available
//     if (clinicQuery.docs.isNotEmpty) {
//       final Timestamp appointmentTimestamp = clinicQuery.docs.first['date'];
//       devtools.log('Appointment Timestamp: $appointmentTimestamp');
//       return appointmentTimestamp.toDate();
//     } else {
//       devtools.log('No appointments found');
//       return null;
//     }
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW IS STABLE WITHOUT DEPENDENCY INJECTION
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:developer' as devtools show log;
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';

// class Appointment {
//   final String patientName;
//   final String patientId;
//   final String patientMobileNumber;
//   final DateTime appointmentDate;
//   final String slot;
//   final int age;
//   final String gender;
//   final String doctorName;
//   final String? patientPicUrl;
//   final String? uhid;
//   final String appointmentId;

//   Appointment({
//     required this.patientName,
//     required this.patientId,
//     required this.patientMobileNumber,
//     required this.appointmentDate,
//     required this.slot,
//     required this.age,
//     required this.gender,
//     required this.doctorName,
//     required this.patientPicUrl,
//     required this.uhid,
//     required this.appointmentId,
//   });

//   // Safely handle null values and handle both Timestamp and String for the date
//   factory Appointment.fromMap(Map<String, dynamic> map) {
//     return Appointment(
//       patientName: map['patientName'] as String? ?? 'Unknown Patient',
//       patientId: map['patientId'] as String? ?? 'Unknown ID',
//       patientMobileNumber:
//           map['patientMobileNumber'] as String? ?? 'Unknown Number',
//       // Handle date as both Timestamp or String
//       appointmentDate: (map['date'] is Timestamp)
//           ? (map['date'] as Timestamp).toDate()
//           : DateTime.tryParse(map['date'] as String) ?? DateTime.now(),
//       slot: map['slot'] as String? ?? 'No Slot',
//       age: map['age'] as int? ?? 0,
//       gender: map['gender'] as String? ?? 'Unknown',
//       doctorName: map['doctorName'] as String? ?? 'Unknown Doctor',
//       patientPicUrl: map['patientPicUrl'] as String?,
//       uhid: map['uhid'] as String?,
//       appointmentId: map['appointmentId'] as String? ?? 'Unknown ID',
//     );
//   }
// }

// class AppointmentService {
//   final clinicsCollection = FirebaseFirestore.instance.collection('clinics');

//   //getAppointments function to fetch all appointments
//   //of all patients
//   //of all past and future dates
//   Future<List<Appointment>> getAppointments({
//     required String doctorId,
//     required String clinicId,
//   }) async {
//     List<Appointment> appointments = [];

//     try {
//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('appointments')
//           .where('doctorId', isEqualTo: doctorId)
//           .get();

//       for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
//           in snapshot.docs) {
//         Map<String, dynamic> appointmentData = documentSnapshot.data();

//         // Debug print to see the appointment data
//         devtools.log(
//             'This is coming from inside getAppointments fucntion of NewAppointmentService. Fetched appointment data: $appointmentData');

//         appointments.add(Appointment.fromMap(appointmentData));

//         // Print the number of appointments found
//         devtools.log('Total appointments found: ${appointments.length}');
//       }
//     } catch (e) {
//       // Print the number of appointments found
//       devtools.log(
//           'This is coming from catch block of getAppointments() of NewAppointmentService. Failed to fetch appointment data');
//       throw Exception('Failed to fetch appointments: $e');
//     }

//     return appointments;
//   }

//   Future<void> createAppointment(
//       {required String doctorId,
//       required String clinicId,
//       required String patientName,
//       required String patientMobileNumber,
//       required String date,
//       required String slot,
//       required int age, // Add age
//       required String gender, // Add gender
//       required String uhid, // Add uhid
//       required String patientPicUrl // Add patientPicUrl
//       }) async {
//     try {
//       final clinicsCollection =
//           FirebaseFirestore.instance.collection('clinics');

//       // Query for the patient with the given mobile number
//       QuerySnapshot<Map<String, dynamic>> patientSnapshot =
//           await clinicsCollection
//               .doc(clinicId)
//               .collection('patients')
//               .where('patientMobileNumber', isEqualTo: patientMobileNumber)
//               .limit(1)
//               .get();

//       String patientId;
//       if (patientSnapshot.size > 0) {
//         patientId = patientSnapshot.docs[0].id;
//       } else {
//         DocumentReference<Map<String, dynamic>> newPatientDocRef =
//             await clinicsCollection.doc(clinicId).collection('patients').add({
//           'patientName': patientName,
//           'patientMobileNumber': patientMobileNumber,
//           'age': age, // Store age
//           'gender': gender, // Store gender
//           'uhid': uhid, // Store uhid
//           'patientPicUrl': patientPicUrl, // Store patientPicUrl
//         });
//         patientId = newPatientDocRef.id;
//       }

//       // Fetch latest treatment (if any) for the patient
//       final patientRef =
//           clinicsCollection.doc(clinicId).collection('patients').doc(patientId);
//       final treatmentsSnapshot =
//           await patientRef.collection('treatments').get();

//       String? treatmentId;
//       if (treatmentsSnapshot.docs.isNotEmpty) {
//         treatmentId = treatmentsSnapshot.docs.last['treatmentId'];
//       }

//       DateTime completeDateTime = DateTime.parse(date);
//       Timestamp appointmentDate = Timestamp.fromDate(completeDateTime);

//       // Create a new appointment with the full patient data
//       final appointmentData = {
//         'patientName': patientName,
//         'age': age, // Add age
//         'gender': gender, // Add gender
//         'patientMobileNumber': patientMobileNumber,
//         'patientId': patientId,
//         'doctorId': doctorId,
//         'uhid': uhid, // Add uhid
//         'slot': slot,
//         'date': appointmentDate,
//         'treatmentId': treatmentId,
//         'patientPicUrl': patientPicUrl, // Add patientPicUrl
//       };

//       // Push appointmentData to Firestore
//       DocumentReference<Map<String, dynamic>> appointmentRef =
//           await clinicsCollection
//               .doc(clinicId)
//               .collection('appointments')
//               .add(appointmentData);

//       String appointmentId = appointmentRef.id;
//       await appointmentRef.update({'appointmentId': appointmentId});

//       // Add appointment reference to patient's appointments sub-collection
//       await patientRef.collection('appointments').add({
//         'appointmentId': appointmentId,
//         'date': appointmentDate,
//       });

//       devtools.log('Appointment created successfully with ID: $appointmentId');
//     } catch (e) {
//       throw Exception('Failed to create appointment: $e');
//     }
//   }

//   //---------------------------------------------------------------------//
//   // Function to create an appointment for a new patient
//   // Function to create an appointment for a new patient
//   Future<void> createAppointmentForNewPatient({
//     required String doctorId,
//     required String clinicId,
//     required Patient patient,
//     required String date, // This should be passed as ISO string
//     required String slot,
//     String? treatmentId, // Add treatmentId as an optional parameter
//   }) async {
//     try {
//       final clinicsCollection =
//           FirebaseFirestore.instance.collection('clinics');

//       // Add the patient if necessary (assuming patient already exists here)
//       final patientId = patient.patientId;

//       // Convert date string to DateTime and then to Timestamp
//       DateTime completeDateTime = DateTime.parse(date);
//       Timestamp appointmentDate = Timestamp.fromDate(completeDateTime);

//       // Create the appointment data
//       final appointmentData = {
//         'patientName': patient.patientName,
//         'age': patient.age,
//         'gender': patient.gender,
//         'patientMobileNumber': patient.patientMobileNumber,
//         'patientId': patientId,
//         'doctorId': doctorId,
//         'uhid': patient.uhid,
//         'slot': slot,
//         'date': appointmentDate,
//         'treatmentId': treatmentId, // Use the treatmentId if provided
//         'patientPicUrl': patient.patientPicUrl,
//       };

//       // Add the appointment to Firestore under the clinic's appointments sub-collection
//       DocumentReference<Map<String, dynamic>> appointmentRef =
//           await clinicsCollection
//               .doc(clinicId)
//               .collection('appointments')
//               .add(appointmentData);

//       // Add the appointmentId to the appointment document
//       final appointmentId = appointmentRef.id;
//       await appointmentRef.update({'appointmentId': appointmentId});

//       // Update the patient's document with the new appointment
//       await clinicsCollection
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId)
//           .collection('appointments')
//           .add({
//         'appointmentId': appointmentId,
//         'date': appointmentDate,
//       });

//       devtools.log('Appointment created successfully with ID: $appointmentId');
//     } catch (e) {
//       devtools.log('Failed to create appointment: $e');
//       throw Exception('Failed to create appointment: $e');
//     }
//   }

//   //-------------------------------------------------------------------------//
//   Future<void> createAppointmentForSelectedPatient({
//     required String clinicId,
//     required String doctorId,
//     required Patient selectedPatient,
//     required String slot,
//     required DateTime selectedDate,
//   }) async {
//     try {
//       // Directly parse the slot string into a DateTime object
//       final completeDateTime = DateTime(
//         selectedDate.year,
//         selectedDate.month,
//         selectedDate.day,
//         DateFormat('h:mm a').parse(slot).hour,
//         DateFormat('h:mm a').parse(slot).minute,
//       );

//       // Convert to UTC and back to IST as needed
//       DateTime completeDateTimeInUtc = completeDateTime.toUtc();
//       DateTime completeDateTimeInIst = completeDateTimeInUtc.toLocal();

//       // Fetch patient document reference
//       final patientRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('patients')
//           .doc(selectedPatient.patientId);

//       // Check if there is an existing treatment for the patient
//       final treatmentsSnapshot =
//           await patientRef.collection('treatments').get();
//       String? treatmentId;
//       if (treatmentsSnapshot.docs.isNotEmpty) {
//         final latestTreatmentDoc = treatmentsSnapshot.docs.last;
//         treatmentId = latestTreatmentDoc['treatmentId'];
//       }

//       // Prepare appointment data
//       final appointmentData = {
//         'patientName': selectedPatient.patientName,
//         'age': selectedPatient.age,
//         'gender': selectedPatient.gender,
//         'patientMobileNumber': selectedPatient.patientMobileNumber,
//         'patientId': selectedPatient.patientId,
//         'doctorId': doctorId,
//         'uhid': selectedPatient.uhid,
//         'slot': slot,
//         'date': Timestamp.fromDate(completeDateTimeInIst),
//         'treatmentId': treatmentId,
//         'patientPicUrl': selectedPatient.patientPicUrl,
//       };

//       // Create the appointment in the clinic's appointments sub-collection
//       final clinicRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('appointments');
//       final clinicAppointmentDocRef = await clinicRef.add(appointmentData);

//       // Update the appointment with appointmentId
//       final appointmentId = clinicAppointmentDocRef.id;
//       await clinicAppointmentDocRef.update({'appointmentId': appointmentId});

//       // Update the patient's appointment list
//       await patientRef.collection('appointments').add({
//         'date': Timestamp.fromDate(completeDateTimeInIst),
//         'treatmentId': treatmentId,
//         'appointmentId': appointmentId,
//       });
//     } catch (e) {
//       throw Exception('Error creating appointment for selected patient: $e');
//     }
//   }

//   //-------------------------------------------------------------------------//

//   // Function to fetch the latest treatmentId for a given patient
//   Future<String?> fetchLatestTreatmentId({
//     required String clinicId,
//     required String patientId,
//   }) async {
//     try {
//       final patientRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId);

//       // Fetch the treatments sub-collection
//       final treatmentsSnapshot =
//           await patientRef.collection('treatments').get();

//       if (treatmentsSnapshot.docs.isNotEmpty) {
//         // If treatments exist, return the treatmentId from the latest document
//         final latestTreatmentDoc = treatmentsSnapshot.docs.last;
//         return latestTreatmentDoc['treatmentId'] as String?;
//       }
//       return null;
//     } catch (e) {
//       devtools.log('Error fetching latest treatmentId: $e');
//       throw Exception('Failed to fetch latest treatmentId: $e');
//     }
//   }
//   //---------------------------------------------------------------------//

//   Future<Map<String, Map<String, List<String>>>> fetchSlots({
//     required String doctorName, // Use doctorName instead of doctorId
//     required String clinicId,
//   }) async {
//     try {
//       // Fetch the document for the logged-in doctor from the 'availableSlots' sub-collection
//       DocumentSnapshot<Map<String, dynamic>> slotsSnapshot =
//           await clinicsCollection
//               .doc(clinicId)
//               .collection('availableSlots')
//               .doc(doctorName) // Use doctorName as the document ID
//               .get();

//       if (slotsSnapshot.exists) {
//         // Parse and extract the available slots from the document data
//         Map<String, dynamic> slotsData = slotsSnapshot.data()!;
//         Map<String, Map<String, List<String>>> availableSlots = {};

//         // Convert the data to the correct format
//         slotsData.forEach((day, slots) {
//           Map<String, List<String>> slotTypes = {};
//           slots.forEach((slotType, timeSlots) {
//             slotTypes[slotType] = List<String>.from(timeSlots);
//           });
//           availableSlots[day] = slotTypes;
//         });

//         return availableSlots;
//       } else {
//         // The document does not exist, return an empty map
//         return {};
//       }
//     } catch (e) {
//       throw Exception('Failed to fetch slots: $e');
//     }
//   }

//   //fetchFutureAppointments to fetch all future appointment of all patient
//   Future<List<Appointment>> fetchFutureAppointments({
//     required String doctorId,
//     required String clinicId,
//   }) async {
//     List<Appointment> futureAppointments = [];

//     try {
//       final now = DateTime.now();

//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('appointments')
//           .where('doctorId', isEqualTo: doctorId)
//           .where('date', isGreaterThan: Timestamp.fromDate(now))
//           .get();

//       for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
//           in snapshot.docs) {
//         Map<String, dynamic> appointmentData = documentSnapshot.data();

//         final appointment = Appointment.fromMap(appointmentData);

//         // Compare the appointment's date and time with the current date and time
//         if (appointment.appointmentDate.isAfter(now)) {
//           futureAppointments.add(appointment);
//         }
//       }

//       // Sort the future appointments in ascending order
//       futureAppointments
//           .sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
//     } catch (e) {
//       // Handle error here if needed
//       devtools.log(
//           'This is coming from catch block of fetchFutureAppointments() of AppointmentService. Failed to fetch future appointments');
//       throw Exception('Failed to fetch future appointments: $e');
//     }

//     return futureAppointments;
//   }

//   Future<List<DateTime>> fetchPatientAppointments({
//     required String clinicId,
//     required String patientId,
//   }) async {
//     List<DateTime> appointmentDates = [];

//     try {
//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId)
//           .collection('appointments')
//           .get();

//       for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
//           in snapshot.docs) {
//         Map<String, dynamic> appointmentData = documentSnapshot.data();

//         // Extract the 'date' field from the appointment data as a Timestamp
//         Timestamp timestamp = appointmentData['date'] as Timestamp;

//         // Convert the Timestamp to a DateTime object
//         DateTime appointmentDateTime = timestamp.toDate();

//         // Add the DateTime to the list
//         appointmentDates.add(appointmentDateTime);
//       }
//     } catch (e) {
//       // Handle error here if needed
//       devtools.log(
//           'This is coming from catch block of fetchPatientAppointments() of AppointmentService. Failed to fetch patient appointments');
//       throw Exception('Failed to fetch patient appointments: $e');
//     }

//     return appointmentDates;
//   }

//   Future<List<Appointment>> fetchPatientFutureAppointments({
//     required String clinicId,
//     required String patientId,
//   }) async {
//     List<Appointment> patientFutureAppointments = [];

//     try {
//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('appointments')
//           .where('patientId', isEqualTo: patientId)
//           .where('date', isGreaterThan: Timestamp.now())
//           .get();

//       for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
//           in snapshot.docs) {
//         Map<String, dynamic> appointmentData = documentSnapshot.data();
//         Appointment appointment = Appointment.fromMap(appointmentData);
//         patientFutureAppointments.add(appointment);
//       }
//     } catch (e) {
//       devtools.log('Failed to fetch future appointments: $e');
//       throw Exception('Failed to fetch future appointments: $e');
//     }

//     return patientFutureAppointments;
//   }

//   //-----------------------------------------------------------------------//

//   Future<void> deleteAppointment(
//     String clinicId,
//     String appointmentId,
//   ) async {
//     try {
//       devtools.log('Welcome to deleteAppointment() inside AppointmentService');
//       final appointmentCollection =
//           clinicsCollection.doc(clinicId).collection('appointments');

//       // Delete the appointment from the main appointments collection
//       await appointmentCollection.doc(appointmentId).delete();
//       devtools.log(
//           'appointmentId $appointmentId deleted successfully from appointments under clinics');

//       // Now delete the appointment from each patient's appointments sub-collection
//       QuerySnapshot<Map<String, dynamic>> patientsSnapshot =
//           await clinicsCollection.doc(clinicId).collection('patients').get();

//       for (QueryDocumentSnapshot<Map<String, dynamic>> patientSnapshot
//           in patientsSnapshot.docs) {
//         // Query appointments sub-collection for each patient
//         QuerySnapshot<Map<String, dynamic>> appointmentsSnapshot =
//             await patientSnapshot.reference
//                 .collection('appointments')
//                 .where('appointmentId', isEqualTo: appointmentId)
//                 .get();

//         // Delete appointment document if found
//         if (appointmentsSnapshot.docs.isNotEmpty) {
//           await appointmentsSnapshot.docs.first.reference.delete();
//           devtools.log(
//               'appointmentId $appointmentId deleted successfully from appointments under patient doc');
//         }
//       }
//     } catch (e) {
//       throw Exception('Failed to delete appointment: $e');
//     }
//   }

//   //-----------------------------------------------------------------------//

//   Future<void> updateSlot(
//       String clinicId, String doctorName, DateTime date, String slot) async {
//     devtools.log('Welcome to updateSlot inside AppointmentService. ');
//     devtools.log(
//         'clinicId is $clinicId, doctorName is $doctorName, date is $date, slot is $slot');

//     try {
//       final selectedDateFormatted = DateFormat('d-MMMM').format(date);
//       final availableSlotsCollection =
//           clinicsCollection.doc(clinicId).collection('availableSlots');
//       final doctorDoc = availableSlotsCollection.doc('Dr$doctorName');
//       final selectedDateSlotsCollection =
//           doctorDoc.collection('selectedDateSlots');

//       // Check if selectedDateSlots collection exists
//       final selectedDateSnapshot =
//           await selectedDateSlotsCollection.doc(selectedDateFormatted).get();

//       if (selectedDateSnapshot.exists) {
//         // If selectedDateFormatted document exists, iterate over all slots
//         final slotsData = selectedDateSnapshot.data() as Map<String, dynamic>;
//         devtools.log('slotsData fetched inside updateSlot is $slotsData');

//         for (final timePeriodData in slotsData['slots']) {
//           final List<Map<String, dynamic>> slots =
//               List<Map<String, dynamic>>.from(timePeriodData['slots']);
//           devtools.log('slots is $slots');

//           for (final slotData in slots) {
//             devtools.log('slotData is $slotData');
//             final slotValue = slotData['slot'] as String;
//             devtools.log('slotValue is $slotValue');
//             devtools.log('slot is $slot');
//             if (slotValue == slot) {
//               devtools.log('perfect matching slot found');
//               slotData['isBooked'] = false;
//               // Set isCancelled to true
//               slotData['isCancelled'] = true;

//               // After modifying the slot data, update the Firestore document
//               await selectedDateSlotsCollection
//                   .doc(selectedDateFormatted)
//                   .set(slotsData);
//               devtools.log(
//                   'Slot $slotValue for $selectedDateFormatted updated successfully.');
//               return; // Exit loop if slot is found and updated
//             }
//           }
//         }
//       } else {
//         devtools.log(
//             'No selectedDateSlots document found for $selectedDateFormatted.');
//       }
//     } catch (e) {
//       throw Exception('Failed to update slot: $e');
//     }
//   }

//   //-----------------------------------------------------------------------//

//   Future<void> deleteAppointmentAndUpdateSlot(
//     String clinicId,
//     String doctorName,
//     String appointmentId,
//     DateTime appointmentDate,
//     String appointmentSlot,
//     Function onDeleteAppointmentAndUpdateSlotCallback,
//   ) async {
//     try {
//       await deleteAppointment(clinicId, appointmentId);
//       await updateSlot(clinicId, doctorName, appointmentDate, appointmentSlot);

//       // Invoke callback after successful deletion and update
//       onDeleteAppointmentAndUpdateSlotCallback();
//     } catch (e) {
//       devtools.log('Error deleting appointment and slot: $e');
//       throw Exception('Failed to delete appointment and update slot: $e');
//     }
//   }

//   //--------------------------------------------------------------------------//
//   Stream<Appointment?> getNextAppointmentStream({
//     required String doctorId,
//     required String clinicId,
//   }) async* {
//     devtools.log(
//         'Welcome to getNextAppointmentStream!doctorId receive is $doctorId and clinicId is $clinicId');

//     final now = DateTime.now();
//     final todayMidnight = DateTime(now.year, now.month, now.day);

//     try {
//       devtools.log(
//           'This is coming from inside try block of getNextAppointmentStream');

//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('appointments')
//           .where('doctorId', isEqualTo: doctorId)
//           .where('date', isGreaterThanOrEqualTo: todayMidnight)
//           .orderBy('date')
//           .get();

//       devtools
//           .log('snapshot found inside getNextAppointmentStream is $snapshot');

//       List<Appointment> upcomingAppointments = [];

//       //for (final documentSnapshot in snapshot.docs) {
//       for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
//           in snapshot.docs) {
//         devtools.log(
//             'This is coming from inside for loop of getNextAppointmentStream.');
//         final appointmentData = documentSnapshot.data();
//         devtools.log(
//             'appointmentData found inside  getNextAppointmentStream is $appointmentData');

//         final appointment = Appointment.fromMap(appointmentData);
//         devtools.log(
//             'next appointment found inside getNextAppointmentStream is $appointment');

//         if (appointment.appointmentDate.isAfter(now)) {
//           upcomingAppointments.add(appointment);
//         }
//       }

//       upcomingAppointments
//           .sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

//       if (upcomingAppointments.isNotEmpty) {
//         yield upcomingAppointments.first;
//       }
//     } catch (e) {
//       // Handle error here if needed
//       devtools
//           .log('Error occurred: $e, doctorId: $doctorId, clinicId: $clinicId');
//       throw Exception('Failed to fetch appointments: $e');
//     }
//   }

//   //--------------------------------------------------------------------------//
//   //getNextAppointment function to fetch immediate next appointment from now
//   Future<Appointment?> getNextAppointment({
//     required String doctorId,
//     required String clinicId,
//   }) async {
//     final now = DateTime.now();
//     final todayMidnight = DateTime(now.year, now.month, now.day);

//     try {
//       devtools.log(
//           'This is coming from inside try block of getNextAppointment function defined inside AppointmentService. doctorId: $doctorId, clinicId: $clinicId');

//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('appointments')
//           .where('doctorId', isEqualTo: doctorId)
//           .where('date', isGreaterThanOrEqualTo: todayMidnight)
//           .orderBy('date')
//           .get();

//       List<Appointment> upcomingAppointments = [];

//       for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
//           in snapshot.docs) {
//         devtools
//             .log('Inside for loop: doctorId: $doctorId, clinicId: $clinicId');

//         Map<String, dynamic> appointmentData = documentSnapshot.data();

//         final appointment = Appointment.fromMap(appointmentData);
//         devtools.log(
//             'This is coming from inside for loop.appointment after being populated from appointmentData is $appointment');

//         // Compare the appointment's date and time with the current date and time
//         if (appointment.appointmentDate.isAfter(now)) {
//           upcomingAppointments.add(appointment);
//         }
//       }

//       // Sort the upcoming appointments in ascending order
//       upcomingAppointments
//           .sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

//       if (upcomingAppointments.isNotEmpty) {
//         devtools.log(
//             'This coming from inside if (upcomingAppointments.isNotEmpty) clause inside getNextAppointment function inside AppointmentService. Returning ${upcomingAppointments.first} ');
//         return upcomingAppointments
//             .first; // Return the first upcoming appointment
//       }
//     } catch (e) {
//       // Handle error here if needed
//       devtools.log(
//           'This is coming from catch block of getNextAppointments() of NewAppointmentService. Failed to fetch appointment data');
//       devtools
//           .log('Error occurred: $e, doctorId: $doctorId, clinicId: $clinicId');

//       throw Exception('Failed to fetch appointments: $e');
//     }

//     return null; // No upcoming appointments
//   }

//   //-------------------------------------------------------//
//   // This method now returns a Stream<List<Appointment>> instead of Firestore types

//   Stream<List<Appointment>> listenToAppointments({
//     required String doctorId,
//     required String clinicId,
//   }) {
//     devtools.log('Listening to appointments for doctorId: $doctorId');

//     return clinicsCollection
//         .doc(clinicId)
//         .collection('appointments')
//         .where('doctorId', isEqualTo: doctorId)
//         .snapshots()
//         .map((snapshot) {
//       if (snapshot.docs.isEmpty) {
//         devtools.log('No appointments found for doctorId: $doctorId');
//         return [];
//       }

//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         return Appointment.fromMap(data);
//       }).toList();
//     });
//   }

//   Future<List<Map<String, dynamic>>> fetchSlotsForSelectedDay({
//     required String clinicId,
//     required String doctorId,
//     required String doctorName,
//     required DateTime selectedDate,
//   }) async {
//     try {
//       devtools.log(
//           'Welcome inside fetchSlotsForSelectedDay defined inside AppointmentService. Fetching slots for selected date: $selectedDate');
//       devtools.log(
//           '@@@@@ doctorId is $doctorId, selectedDate is $selectedDate @@@@@');

//       final selectedDateFormatted = DateFormat('d-MMMM').format(selectedDate);
//       final selectedDayOfWeek = DateFormat('EEEE').format(selectedDate);

//       final doctorDocumentRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('availableSlots')
//           .doc('Dr$doctorName');

//       final selectedDateSlotsRef = doctorDocumentRef
//           .collection('selectedDateSlots')
//           .doc(selectedDateFormatted);

//       final selectedDateSlotsDoc = await selectedDateSlotsRef.get();

//       List<Map<String, dynamic>> allSlots = [];

//       if (selectedDateSlotsDoc.exists) {
//         final slotsData = selectedDateSlotsDoc.data();
//         devtools.log('Slots data for selected date: $slotsData');

//         if (slotsData != null && slotsData.containsKey('slots')) {
//           final List<dynamic> allSlotsData = slotsData['slots'];
//           for (var slotsPeriodData in allSlotsData) {
//             final List<Map<String, dynamic>> slotsForPeriod =
//                 List<Map<String, dynamic>>.from(slotsPeriodData['slots']);
//             allSlots.addAll(slotsForPeriod);
//           }
//         }
//       }

//       if (allSlots.isEmpty) {
//         devtools.log('Fetching slots for $selectedDayOfWeek as fallback');
//         final doctorDocument = await doctorDocumentRef.get();

//         if (doctorDocument.exists) {
//           final slotsData = doctorDocument.data();
//           if (slotsData != null && slotsData.containsKey(selectedDayOfWeek)) {
//             final slotsForSelectedDay = slotsData[selectedDayOfWeek];

//             slotsForSelectedDay.forEach((timePeriod, slots) {
//               allSlots.addAll(List<Map<String, dynamic>>.from(slots));
//             });
//           }
//         }
//       }

//       if (allSlots.isEmpty) {
//         devtools
//             .log('No slots found for the selected date or day of the week.');
//         return [];
//       }

//       // Create a range for the entire selected date
//       final startOfDay =
//           DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
//       final endOfDay = startOfDay.add(const Duration(days: 1));

//       // Fetch booked appointments for the entire selected date
//       devtools.log('Fetching appointments for $selectedDate (whole day)');
//       final appointmentsSnapshot = await FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('appointments')
//           .where('doctorId', isEqualTo: doctorId)
//           .where('date', isGreaterThanOrEqualTo: startOfDay)
//           .where('date', isLessThan: endOfDay)
//           .get();

//       List<String> bookedSlots = [];
//       if (appointmentsSnapshot.docs.isNotEmpty) {
//         devtools.log('@@@@@ appointmentsSnapshot is not empty @@@@@@');
//         bookedSlots = appointmentsSnapshot.docs
//             .map((doc) => doc['slot'] as String)
//             .toList();
//       }
//       devtools.log(
//           '@@@@ This is coming from inside fetchSlotsForSelectedDay defined inside AppointmentService. bookedSlots are $bookedSlots ');

//       // Update the isBooked status based on booked slots
//       final updatedSlots = allSlots.map((slotData) {
//         final isBooked = bookedSlots.contains(slotData['slot']);
//         return {
//           ...slotData,
//           'isBooked': isBooked,
//         };
//       }).toList();

//       devtools.log('@@@@ Updated slots with isBooked flag: $updatedSlots');
//       return updatedSlots;
//     } catch (e) {
//       devtools.log('Failed to fetch slots: $e');
//       throw Exception('Failed to fetch slots: $e');
//     }
//   }

//   //---------------------------------------------------------------------//

//   Future<void> updateSlotAvailability({
//     required String clinicId,
//     required String doctorName,
//     required DateTime selectedDate,
//     required List<Map<String, dynamic>> updatedSlots,
//   }) async {
//     try {
//       devtools.log(
//           '@@@@@ Welcome to updateSlotAvailability defined inside AppointmentService. updatedSlots are $updatedSlots');
//       final selectedDateFormatted = DateFormat('d-MMMM').format(selectedDate);
//       final doctorDocumentRef = clinicsCollection
//           .doc(clinicId)
//           .collection('availableSlots')
//           .doc('Dr$doctorName')
//           .collection('selectedDateSlots')
//           .doc(selectedDateFormatted);

//       final slotsData = <String, dynamic>{'slots': updatedSlots};

//       await doctorDocumentRef.set(slotsData);
//     } catch (e) {
//       devtools.log('Failed to update slot availability: $e');
//       throw Exception('Failed to update slot availability: $e');
//     }
//   }

//   Future<List<Appointment>> fetchAppointmentsForDate({
//     required String clinicId,
//     required String doctorId,
//     required DateTime selectedDate,
//   }) async {
//     try {
//       // Start of day
//       final startOfDay = DateTime(
//         selectedDate.year,
//         selectedDate.month,
//         selectedDate.day,
//       );

//       // End of day (Add 1 day then subtract 1 second for the end of the day)
//       final endOfDay =
//           startOfDay.add(Duration(days: 1)).subtract(Duration(seconds: 1));

//       QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//           .doc(clinicId)
//           .collection('appointments')
//           .where('doctorId', isEqualTo: doctorId)
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
//           .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
//           .orderBy('date')
//           .get();

//       if (snapshot.docs.isEmpty) {
//         devtools.log('No appointments found for the selected date.');
//         return [];
//       }

//       return snapshot.docs
//           .map((doc) => Appointment.fromMap(doc.data()))
//           .toList();
//     } catch (e) {
//       devtools.log('Error fetching appointments for date: $e');
//       throw Exception('Failed to fetch appointments: $e');
//     }
//   }

//   //--------------------------------------------------------//
//   Future<DateTime?> updateTreatmentIdInAppointmentsAndFetchDate({
//     required String clinicId,
//     required String patientId,
//     required String? treatmentId,
//   }) async {
//     // Create references to the appointment documents in both locations
//     final clinicRef =
//         clinicsCollection.doc(clinicId).collection('appointments');
//     final patientRef = clinicsCollection
//         .doc(clinicId)
//         .collection('patients')
//         .doc(patientId)
//         .collection('appointments');

//     // Fetch the appointments matching the patientId and future dates
//     final clinicQuery = await clinicRef
//         .where('patientId', isEqualTo: patientId)
//         .where('date', isGreaterThanOrEqualTo: Timestamp.now())
//         .get();

//     // Iterate over the clinic's appointments
//     for (final clinicDoc in clinicQuery.docs) {
//       final appointmentId = clinicDoc.id;
//       devtools.log('appointmentId captured which is: $appointmentId');

//       try {
//         // Update treatmentId for clinic appointments
//         await clinicRef.doc(appointmentId).update({'treatmentId': treatmentId});

//         // Fetch the corresponding patient appointment using appointmentId
//         final patientQuery = await patientRef
//             .where('appointmentId', isEqualTo: appointmentId)
//             .get();

//         // Update treatmentId for patient appointments
//         for (final patientDoc in patientQuery.docs) {
//           final patientAppointmentId = patientDoc.id;
//           try {
//             await patientRef
//                 .doc(patientAppointmentId)
//                 .update({'treatmentId': treatmentId});
//           } catch (e) {
//             devtools.log('Error updating patient appointment document: $e');
//           }
//         }
//       } catch (e) {
//         devtools.log('Error updating clinic appointment document: $e');
//       }
//     }

//     // Return the appointmentDate if available
//     if (clinicQuery.docs.isNotEmpty) {
//       final Timestamp appointmentTimestamp = clinicQuery.docs.first['date'];
//       devtools.log('Appointment Timestamp: $appointmentTimestamp');
//       return appointmentTimestamp.toDate();
//     } else {
//       devtools.log('No appointments found');
//       return null;
//     }
//   }
//   //--------------------------------------------------------//

//   // -------------------------------------------------------//
// }
