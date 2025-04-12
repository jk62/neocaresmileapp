import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neocaresmileapp/mywidgets/condition.dart';

class ExaminationService {
  String clinicId;
  final FirebaseFirestore firestore;

  ExaminationService(this.clinicId, {FirebaseFirestore? firestoreInstance})
      : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  void updateClinicId(String newClinicId) {
    clinicId = newClinicId;
  }

  Future<List<Condition>> searchConditions(String query) async {
    final conditionsCollection =
        firestore.collection('clinics').doc(clinicId).collection('conditions');

    final querySnapshot = await conditionsCollection.get();
    List<Condition> matchingConditions = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      if (data['conditionName'] != null) {
        final conditionName = data['conditionName'].toString().toLowerCase();

        if (conditionName.startsWith(query.toLowerCase())) {
          matchingConditions.add(Condition.fromJson(data));
        }
      }
    }

    return matchingConditions;
  }

  Future<void> addCondition(Condition condition) async {
    DocumentReference docRef = firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('conditions')
        .doc();

    condition = Condition(
      conditionId: docRef.id,
      conditionName: condition.conditionName,
      toothTable1: condition.toothTable1,
      toothTable2: condition.toothTable2,
      toothTable3: condition.toothTable3,
      toothTable4: condition.toothTable4,
      doctorNote: condition.doctorNote,
      isToothTable: condition.isToothTable,
    );

    await docRef.set(condition.toJson());
  }

  Future<void> updateCondition(Condition condition) async {
    DocumentReference docRef = firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('conditions')
        .doc(condition.conditionId);

    await docRef.update(condition.toJson());
  }

  Future<void> deleteCondition(String conditionId) async {
    DocumentReference docRef = firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('conditions')
        .doc(conditionId);

    await docRef.delete();
  }

  Future<List<Condition>> getAllConditions() async {
    final conditionsCollection =
        firestore.collection('clinics').doc(clinicId).collection('conditions');

    final querySnapshot = await conditionsCollection.get();
    List<Condition> allConditions = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      if (data['conditionName'] != null) {
        allConditions.add(Condition.fromJson(data));
      }
    }

    return allConditions;
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'dart:core';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:neocare_dental_app/mywidgets/condition.dart';

// class ExaminationService {
//   final String clinicId;

//   ExaminationService(this.clinicId);

//   Future<List<Condition>> searchConditions(String query) async {
//     final conditionsCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('conditions');

//     final querySnapshot = await conditionsCollection.get();
//     List<Condition> matchingConditions = [];

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data();

//       if (data['conditionName'] != null) {
//         final conditionName = data['conditionName'].toString().toLowerCase();

//         if (conditionName.startsWith(query.toLowerCase())) {
//           matchingConditions.add(Condition.fromJson(data));
//         }
//       }
//     }

//     return matchingConditions;
//   }

//   Future<void> addCondition(Condition condition) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('conditions')
//         .doc();

//     condition = Condition(
//       conditionId: docRef.id,
//       conditionName: condition.conditionName,
//       toothTable1: condition.toothTable1,
//       toothTable2: condition.toothTable2,
//       toothTable3: condition.toothTable3,
//       toothTable4: condition.toothTable4,
//       doctorNote: condition.doctorNote,
//       isToothTable: condition.isToothTable,
//     );

//     await docRef.set(condition.toJson());
//   }

//   Future<void> updateCondition(Condition condition) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('conditions')
//         .doc(condition.conditionId);

//     await docRef.update(condition.toJson());
//   }

//   Future<void> deleteCondition(String conditionId) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('conditions')
//         .doc(conditionId);

//     await docRef.delete();
//   }

//   Future<List<Condition>> getAllConditions() async {
//     final conditionsCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('conditions');

//     final querySnapshot = await conditionsCollection.get();
//     List<Condition> allConditions = [];

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data();
//       if (data['conditionName'] != null) {
//         allConditions.add(Condition.fromJson(data));
//       }
//     }

//     return allConditions;
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// code below stable with single tooth table
// import 'dart:core';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:neocare_dental_app/mywidgets/condition.dart';

// class ExaminationService {
//   final String clinicId;

//   ExaminationService(this.clinicId);

//   Future<List<Condition>> searchConditions(String query) async {
//     final conditionsCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('conditions');

//     final querySnapshot = await conditionsCollection.get();
//     List<Condition> matchingConditions = [];

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data();

//       if (data['conditionName'] != null && data['toothTable'] != null) {
//         final conditionName = data['conditionName'].toString().toLowerCase();

//         if (conditionName.startsWith(query.toLowerCase())) {
//           matchingConditions.add(Condition.fromJson(data));
//         }
//       }
//     }

//     return matchingConditions;
//   }

//   Future<void> addCondition(Condition condition) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('conditions')
//         .doc();

//     condition = Condition(
//       conditionId: docRef.id,
//       conditionName: condition.conditionName,
//       toothTable: condition.toothTable,
//       doctorNote: condition.doctorNote,
//     );

//     await docRef.set(condition.toJson());
//   }

//   Future<void> updateCondition(Condition condition) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('conditions')
//         .doc(condition.conditionId);

//     await docRef.update(condition.toJson());
//   }

//   Future<void> deleteCondition(String conditionId) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('conditions')
//         .doc(conditionId);

//     await docRef.delete();
//   }

//   Future<List<Condition>> getAllConditions() async {
//     final conditionsCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('conditions');

//     final querySnapshot = await conditionsCollection.get();
//     List<Condition> allConditions = [];

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data();
//       if (data['conditionName'] != null && data['toothTable'] != null) {
//         allConditions.add(Condition.fromJson(data));
//       }
//     }

//     return allConditions;
//   }
// }
