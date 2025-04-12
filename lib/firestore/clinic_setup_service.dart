import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neocaresmileapp/mywidgets/condition.dart';
import 'package:neocaresmileapp/mywidgets/medical_condition.dart';
import 'package:neocaresmileapp/mywidgets/medicine.dart';
import 'dart:developer' as devtools show log;

import 'package:neocaresmileapp/mywidgets/procedure.dart';

class ClinicSetupService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fetch clinic names and IDs from the clinics collection
  Future<List<Map<String, String>>> getClinics() async {
    final clinicsCollection = firestore.collection('clinics');
    final querySnapshot = await clinicsCollection.get();

    // Map each document to a name and ID pair
    return querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc.data()['clinicName'] as String,
      };
    }).toList();
  }

  // Function to replicate medicines from one clinic to another
  Future<void> replicateMedicineData(
      String sourceClinicId, String targetClinicId) async {
    try {
      final sourceMedicinesCollection = firestore
          .collection('clinics')
          .doc(sourceClinicId)
          .collection('medicines');

      final targetMedicinesCollection = firestore
          .collection('clinics')
          .doc(targetClinicId)
          .collection('medicines');

      // Step 1: Fetch all existing medicines in the target clinic
      final targetSnapshot = await targetMedicinesCollection.get();
      Set<String> existingMedicineNames = {};

      // Check if the target clinic has any medicines
      if (targetSnapshot.docs.isNotEmpty) {
        // Populate existing medicine names if any medicines are present
        existingMedicineNames = targetSnapshot.docs
            .map((doc) => doc.data()['medName'] as String)
            .toSet();
      }

      // Step 2: Fetch medicines from the source clinic and replicate only if not already in the target clinic
      final sourceSnapshot = await sourceMedicinesCollection.get();

      for (var doc in sourceSnapshot.docs) {
        final data = doc.data();
        final medName = data['medName'] as String;

        // Step 3: Check if the medicine is already present in the target clinic
        if (!existingMedicineNames.contains(medName)) {
          // Generate a new document reference with a unique ID for the target clinic
          DocumentReference newDocRef = targetMedicinesCollection.doc();

          // Ensure the newDocRef.id is set as medId in the Medicine object
          Medicine medicine = Medicine(
            medId: newDocRef.id, // Use the new document ID as medId
            medName: medName,
            composition: data['composition'],
          );

          // Save the medicine with the generated medId in Firestore
          await newDocRef.set(medicine.toJson());

          // Optional: Add the medName to existingMedicineNames to prevent re-checking
          existingMedicineNames.add(medName);
        }
      }

      devtools.log(
          'Medicine data replicated successfully from $sourceClinicId to $targetClinicId');
    } catch (error) {
      devtools.log('Error replicating medicine data: $error');
    }
  }

  //---------------------------------------------------------------------------//
  // Function to replicate conditions from one clinic to another
  Future<void> replicateConditionData(
      String sourceClinicId, String targetClinicId) async {
    try {
      final sourceConditionsCollection = firestore
          .collection('clinics')
          .doc(sourceClinicId)
          .collection('conditions');

      final targetConditionsCollection = firestore
          .collection('clinics')
          .doc(targetClinicId)
          .collection('conditions');

      // Step 1: Fetch all existing conditions in the target clinic
      final targetSnapshot = await targetConditionsCollection.get();
      Set<String> existingConditionNames = {};

      // Check if the target clinic has any conditions
      if (targetSnapshot.docs.isNotEmpty) {
        // Populate existing condition names if any conditions are present
        existingConditionNames = targetSnapshot.docs
            .map((doc) => doc.data()['conditionName'] as String)
            .toSet();
      }

      // Step 2: Fetch conditions from the source clinic and replicate only if not already in the target clinic
      final sourceSnapshot = await sourceConditionsCollection.get();

      for (var doc in sourceSnapshot.docs) {
        final data = doc.data();
        final conditionName = data['conditionName'] as String;

        // Step 3: Check if the condition is already present in the target clinic
        if (!existingConditionNames.contains(conditionName)) {
          // Generate a new document reference with a unique ID for the target clinic
          DocumentReference newDocRef = targetConditionsCollection.doc();

          // Create a Condition object with the new document ID as conditionId
          Condition condition = Condition(
            conditionId: newDocRef.id, // Use the new document ID as conditionId
            conditionName: conditionName,
            toothTable1: List<int>.from(data['toothTable1'] ?? []),
            toothTable2: List<int>.from(data['toothTable2'] ?? []),
            toothTable3: List<int>.from(data['toothTable3'] ?? []),
            toothTable4: List<int>.from(data['toothTable4'] ?? []),
            doctorNote: data['doctorNote'] as String? ?? '',
            isToothTable: data['isToothTable'] as bool? ?? false,
          );

          // Save the condition with the generated conditionId in Firestore
          await newDocRef.set(condition.toJson());

          // Optional: Add the conditionName to existingConditionNames to prevent re-checking
          existingConditionNames.add(conditionName);
        }
      }

      devtools.log(
          'Condition data replicated successfully from $sourceClinicId to $targetClinicId');
    } catch (error) {
      devtools.log('Error replicating condition data: $error');
    }
  }

  //----------------------------------------------------------------------------//
  // Function to replicate procedures from one clinic to another
  Future<void> replicateProcedureData(
      String sourceClinicId, String targetClinicId) async {
    try {
      final sourceProceduresCollection = firestore
          .collection('clinics')
          .doc(sourceClinicId)
          .collection('procedures');

      final targetProceduresCollection = firestore
          .collection('clinics')
          .doc(targetClinicId)
          .collection('procedures');

      // Step 1: Fetch all existing procedures in the target clinic
      final targetSnapshot = await targetProceduresCollection.get();
      Set<String> existingProcedureNames = {};

      // Check if the target clinic has any procedures
      if (targetSnapshot.docs.isNotEmpty) {
        // Populate existing procedure names if any procedures are present
        existingProcedureNames = targetSnapshot.docs
            .map((doc) => doc.data()['procName'] as String)
            .toSet();
      }

      // Step 2: Fetch procedures from the source clinic and replicate only if not already in the target clinic
      final sourceSnapshot = await sourceProceduresCollection.get();

      for (var doc in sourceSnapshot.docs) {
        final data = doc.data();
        final procName = data['procName'] as String;

        // Step 3: Check if the procedure is already present in the target clinic
        if (!existingProcedureNames.contains(procName)) {
          // Generate a new document reference with a unique ID for the target clinic
          DocumentReference newDocRef = targetProceduresCollection.doc();

          // Create a Procedure object with the new document ID as procId
          Procedure procedure = Procedure(
            procId: newDocRef.id, // Use the new document ID as procId
            procName: procName,
            procFee: data['procFee'] as double? ?? 0.0,
            toothTable1: List<int>.from(data['toothTable1'] ?? []),
            toothTable2: List<int>.from(data['toothTable2'] ?? []),
            toothTable3: List<int>.from(data['toothTable3'] ?? []),
            toothTable4: List<int>.from(data['toothTable4'] ?? []),
            doctorNote: data['doctorNote'] as String? ?? '',
            isToothwise: data['isToothwise'] as bool? ?? false,
          );

          // Save the procedure with the generated procId in Firestore
          await newDocRef.set(procedure.toJson());

          // Optional: Add the procName to existingProcedureNames to prevent re-checking
          existingProcedureNames.add(procName);
        }
      }

      devtools.log(
          'Procedure data replicated successfully from $sourceClinicId to $targetClinicId');
    } catch (error) {
      devtools.log('Error replicating procedure data: $error');
    }
  }

  //---------------------------------------------------------------------//
  // Function to replicate medical history conditions from one clinic to another
  Future<void> replicateMedicalHistoryConditionData(
      String sourceClinicId, String targetClinicId) async {
    try {
      final sourceMedicalHistoryConditionsCollection = firestore
          .collection('clinics')
          .doc(sourceClinicId)
          .collection('medicalHistoryConditions');

      final targetMedicalHistoryConditionsCollection = firestore
          .collection('clinics')
          .doc(targetClinicId)
          .collection('medicalHistoryConditions');

      // Step 1: Fetch all existing medical history conditions in the target clinic
      final targetSnapshot =
          await targetMedicalHistoryConditionsCollection.get();
      Set<String> existingConditionNames = {};

      // Populate existing condition names if any are present in the target clinic
      if (targetSnapshot.docs.isNotEmpty) {
        existingConditionNames = targetSnapshot.docs
            .map((doc) => doc.data()['medicalConditionName'] as String)
            .toSet();
      }

      // Step 2: Fetch medical history conditions from the source clinic and replicate only if not already in the target clinic
      final sourceSnapshot =
          await sourceMedicalHistoryConditionsCollection.get();

      for (var doc in sourceSnapshot.docs) {
        final data = doc.data();
        final conditionName = data['medicalConditionName'] as String;

        // Step 3: Check if the condition is already present in the target clinic
        if (!existingConditionNames.contains(conditionName)) {
          // Generate a new document reference with a unique ID for the target clinic
          DocumentReference newDocRef =
              targetMedicalHistoryConditionsCollection.doc();

          // Create a MedicalCondition object with the new document ID as medicalConditionId
          MedicalCondition condition = MedicalCondition(
            medicalConditionId:
                newDocRef.id, // Use the new document ID as medicalConditionId
            medicalConditionName: conditionName,
            doctorNote: data['doctorNote'] as String? ?? '',
          );

          // Save the medical condition with the generated medicalConditionId in Firestore
          await newDocRef.set(condition.toJson());

          // Optional: Add the conditionName to existingConditionNames to prevent re-checking
          existingConditionNames.add(conditionName);
        }
      }

      devtools.log(
          'Medical history condition data replicated successfully from $sourceClinicId to $targetClinicId');
    } catch (error) {
      devtools.log('Error replicating medical history condition data: $error');
    }
  }
}
