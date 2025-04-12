import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as devtools show log;

import 'package:intl/intl.dart';

class NoteService {
  final String clinicId;
  final String patientId;
  final String treatmentId;

  NoteService({
    required this.clinicId,
    required this.patientId,
    required this.treatmentId,
  });

  // Future<void> addNoteToBackend({
  //   required String noteId,
  //   required DateTime currentDate,
  //   required List<int> affectedTeeth,
  //   required String doctorNote,
  // }) async {
  //   try {
  //     // Prepare note data
  //     Map<String, dynamic> noteData = {
  //       'noteId': noteId,
  //       'date':
  //           Timestamp.fromDate(currentDate), // Store as Timestamp in Firestore
  //       'affectedTeeth': affectedTeeth,
  //       'doctorNote': doctorNote,
  //     };

  //     // Reference to the notes sub-collection
  //     final notesCollectionRef = FirebaseFirestore.instance
  //         .collection('clinics')
  //         .doc(clinicId)
  //         .collection('patients')
  //         .doc(patientId)
  //         .collection('treatments')
  //         .doc(treatmentId)
  //         .collection('notes');

  //     // Push the note data to Firestore
  //     await notesCollectionRef.doc(noteId).set(noteData);
  //     devtools.log('Note data pushed to the backend successfully');
  //   } catch (e) {
  //     devtools.log('Error adding note data: $e');
  //     rethrow;
  //   }
  // }

  Future<void> addNoteToBackend({
    required DateTime currentDate,
    required List<int> affectedTeeth,
    required String doctorNote,
  }) async {
    try {
      // Generate a new noteId within the service
      String noteId = FirebaseFirestore.instance.collection('notes').doc().id;

      // Prepare note data
      Map<String, dynamic> noteData = {
        'noteId': noteId,
        'date':
            Timestamp.fromDate(currentDate), // Store as Timestamp in Firestore
        'affectedTeeth': affectedTeeth,
        'doctorNote': doctorNote,
      };

      // Reference to the notes sub-collection
      final notesCollectionRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('treatments')
          .doc(treatmentId)
          .collection('notes');

      // Push the note data to Firestore
      await notesCollectionRef.doc(noteId).set(noteData);
      devtools.log('Note data pushed to the backend successfully');
    } catch (e) {
      devtools.log('Error adding note data: $e');
      rethrow;
    }
  }

  // Future<List<Map<String, dynamic>>> fetchNotes() async {
  //   try {
  //     final notesQuery = await FirebaseFirestore.instance
  //         .collection('clinics')
  //         .doc(clinicId)
  //         .collection('patients')
  //         .doc(patientId)
  //         .collection('treatments')
  //         .doc(treatmentId)
  //         .collection('notes')
  //         .get();

  //     List<Map<String, dynamic>> existingNotes = [];

  //     for (final doc in notesQuery.docs) {
  //       final Map<String, dynamic> data = doc.data();
  //       final timestamp = data['date'];
  //       String formattedDate = '';

  //       if (timestamp != null && timestamp is Timestamp) {
  //         DateTime dateTime = timestamp.toDate();
  //         formattedDate = DateFormat('MMMM dd, EEEE').format(dateTime);
  //       }

  //       existingNotes.add({
  //         'noteId': doc.id,
  //         'timestamp': formattedDate,
  //         'doctorNote': data['doctorNote'] ?? '',
  //         'affectedTeeth': data['affectedTeeth'] ?? [],
  //       });
  //     }

  //     return existingNotes;
  //   } catch (e) {
  //     devtools.log('Error fetching notes data: $e');
  //     rethrow;
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchNotes() async {
    try {
      final notesQuery = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('treatments')
          .doc(treatmentId)
          .collection('notes')
          .get();

      List<Map<String, dynamic>> existingNotes = [];

      for (final doc in notesQuery.docs) {
        final Map<String, dynamic> data = doc.data();
        final timestamp = data['date'];
        String formattedDate = '';

        if (timestamp != null && timestamp is Timestamp) {
          DateTime dateTime = timestamp.toDate();
          formattedDate = DateFormat('MMMM dd, EEEE').format(dateTime);
        }

        existingNotes.add({
          'noteId': doc.id,
          'timestamp': formattedDate,
          'doctorNote': data['doctorNote'] ?? '',
          'affectedTeeth':
              List<int>.from(data['affectedTeeth'] ?? []), // Cast to List<int>
        });
      }

      return existingNotes;
    } catch (e) {
      devtools.log('Error fetching notes data: $e');
      rethrow;
    }
  }

  Future<void> deleteNoteFromBackend(String noteId) async {
    try {
      final noteDocRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('treatments')
          .doc(treatmentId)
          .collection('notes')
          .doc(noteId);

      // Delete the note from Firestore
      await noteDocRef.delete();
      devtools.log('Note with noteId $noteId deleted successfully');
    } catch (e) {
      devtools.log('Error deleting note with noteId $noteId: $e');
      rethrow;
    }
  }
}
