import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neocaresmileapp/mywidgets/medical_condition.dart';

class MedicalHistoryService {
  final String clinicId;

  MedicalHistoryService(this.clinicId);

  Future<List<MedicalCondition>> searchMedicalConditions(String query) async {
    final conditionsCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('medicalHistoryConditions');

    final querySnapshot = await conditionsCollection.get();
    List<MedicalCondition> matchingConditions = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      if (data['medicalConditionName'] != null) {
        final conditionName =
            data['medicalConditionName'].toString().toLowerCase();

        if (conditionName.startsWith(query.toLowerCase())) {
          matchingConditions.add(MedicalCondition.fromJson(data));
        }
      }
    }

    return matchingConditions;
  }

  Future<void> addMedicalCondition(MedicalCondition condition) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('medicalHistoryConditions')
        .doc();

    condition = MedicalCondition(
      medicalConditionId: docRef.id,
      medicalConditionName: condition.medicalConditionName,
      doctorNote: condition.doctorNote,
    );

    await docRef.set(condition.toJson());
  }

  Future<void> updateMedicalCondition(MedicalCondition condition) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('medicalHistoryConditions')
        .doc(condition.medicalConditionId);

    await docRef.update(condition.toJson());
  }

  Future<void> deleteMedicalCondition(String medicalConditionId) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('medicalHistoryConditions')
        .doc(medicalConditionId);

    await docRef.delete();
  }

  // Future<List<MedicalCondition>> getAllMedicalConditions() async {
  //   final conditionsCollection = FirebaseFirestore.instance
  //       .collection('clinics')
  //       .doc(clinicId)
  //       .collection('medicalHistoryConditions');

  //   final querySnapshot = await conditionsCollection.get();
  //   List<MedicalCondition> allConditions = [];

  //   for (var doc in querySnapshot.docs) {
  //     final data = doc.data();
  //     if (data['medicalConditionName'] != null) {
  //       allConditions.add(MedicalCondition.fromJson(data));
  //     }
  //   }

  //   return allConditions;
  // }
  //---------------------------------------//
  Future<List<MedicalCondition>> getAllMedicalConditions() async {
    final conditionsCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('medicalHistoryConditions');

    final querySnapshot = await conditionsCollection.get();
    List<MedicalCondition> allConditions = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      if (data['medicalConditionName'] != null) {
        allConditions.add(MedicalCondition.fromJson(data));
      }
    }

    return allConditions;
  }

  //---------------------------------------//
}
