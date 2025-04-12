import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as devtools show log;

class SlotService {
  final String clinicId;

  SlotService(this.clinicId);

  // Future<void> addSlot(
  //     String doctorName, Map<String, dynamic> selectedSlots) async {
  //   final slotsCollection = FirebaseFirestore.instance
  //       .collection('clinics')
  //       .doc(clinicId)
  //       .collection('availableSlots')
  //       .doc('Dr$doctorName');

  //   await slotsCollection.set(selectedSlots);
  // }

  Future<void> addSlot(
      String doctorName, Map<String, dynamic> selectedSlots) async {
    final slotsCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('availableSlots')
        .doc('Dr$doctorName');

    try {
      await slotsCollection.set(selectedSlots);
      devtools.log('Slots data saved successfully for Dr$doctorName');
    } catch (error) {
      devtools.log('Error saving slots data for Dr$doctorName: $error');
      throw Exception('Error saving slots data: $error');
    }
  }

  Future<void> updateMySlot(
      String doctorName, Map<String, dynamic> selectedSlots) async {
    final slotsCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('availableSlots')
        .doc('Dr$doctorName');

    await slotsCollection.update(selectedSlots);
  }

  Future<void> deleteMySlot(String doctorName) async {
    final slotsCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('availableSlots')
        .doc('Dr$doctorName');

    await slotsCollection.delete();
  }

  Future<Map<String, dynamic>?> getSlots(String doctorName) async {
    final slotsCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('availableSlots')
        .doc('Dr$doctorName');

    final docSnapshot = await slotsCollection.get();
    if (docSnapshot.exists) {
      return docSnapshot.data();
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMySlots(String doctorName) async {
    devtools.log('Welcome to getSlots defined inside SlotService !');
    final slotsCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('availableSlots')
        .doc('Dr$doctorName');

    final docSnapshot = await slotsCollection.get();

    if (docSnapshot.exists) {
      devtools
          .log('Fetched slots data: ${docSnapshot.data()}'); // Log fetched data
      return docSnapshot.data();
    } else {
      devtools.log('No slots data found for Dr$doctorName');
      return null;
    }
  }

  // Fetch all clinic slots (clinic-wide slots)
  Future<Map<String, dynamic>?> fetchClinicSlots() async {
    devtools.log(
        '********************** Welcome to fetchClinicSlots inside SlotService!');

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('clinics')
          .doc(clinicId)
          .collection('availableSlots')
          .doc('clinicSlots')
          .get();

      if (snapshot.exists) {
        devtools.log(
            '******************* Fetched clinicSlotsData: ${snapshot.data()}');
        return snapshot.data();
      } else {
        devtools.log('No clinicSlots document found.');
        return null;
      }
    } catch (e) {
      devtools.log('Error fetching clinic slots: $e');
      return null;
    }
  }
}
