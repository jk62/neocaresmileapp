import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neocaresmileapp/mywidgets/procedure.dart';

class ProcedureService {
  String clinicId;

  ProcedureService(this.clinicId);
  //---------------------------------------------------------------------------//

  void updateClinicId(String newClinicId) {
    clinicId = newClinicId;
  }

  // ------------------------------------------------------------------------ //

  Future<List<Procedure>> searchProcedures(String query) async {
    final proceduresCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('procedures');

    final querySnapshot = await proceduresCollection.get();
    List<Procedure> matchingProcedures = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      if (data['procName'] != null) {
        final procName = data['procName'].toString().toLowerCase();

        if (procName.startsWith(query.toLowerCase())) {
          matchingProcedures.add(Procedure.fromMap(data));
        }
      }
    }

    return matchingProcedures;
  }

  // ------------------------------------------------------------------------- //

  Future<void> addProcedure(Procedure procedure) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('procedures')
        .doc();

    procedure = Procedure(
      procId: docRef.id,
      procName: procedure.procName,
      procFee: procedure.procFee,
      toothTable1: procedure.toothTable1,
      toothTable2: procedure.toothTable2,
      toothTable3: procedure.toothTable3,
      toothTable4: procedure.toothTable4,
      doctorNote: procedure.doctorNote,
      isToothwise: procedure.isToothwise,
    );

    await docRef.set(procedure.toJson());
  }

  // ------------------------------------------------------------------------- //

  Future<void> updateProcedure(Procedure procedure) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('procedures')
        .doc(procedure.procId);

    await docRef.update(procedure.toJson());
  }

  Future<void> deleteProcedure(String procId) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('procedures')
        .doc(procId);

    await docRef.delete();
  }

  Future<List<Procedure>> getAllProcedures() async {
    final proceduresCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('procedures');

    final querySnapshot = await proceduresCollection.get();
    List<Procedure> allProcedures = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      if (data['procName'] != null) {
        allProcedures.add(Procedure.fromMap(data));
      }
    }

    return allProcedures;
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! // 
// code below was stable with single tooth table
// import 'dart:core';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:neocare_dental_app/mywidgets/procedure.dart';

// class ProcedureService {
//   final String clinicId;

//   ProcedureService(this.clinicId);

//   // ------------------------------------------------------------------------ //
  
//   Future<List<Procedure>> searchProcedures(String query) async {
//     final proceduresCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('procedures');

//     final querySnapshot = await proceduresCollection.get();
//     List<Procedure> matchingProcedures = [];

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data();

//       if (data['procName'] != null &&
//           data['procFee'] != null &&
//           data['toothTable'] != null) {
//         final procName = data['procName'].toString().toLowerCase();

//         if (procName.startsWith(query.toLowerCase())) {
//           matchingProcedures.add(Procedure(
//             procId: doc.id,
//             procName: data['procName'],
//             procFee: data['procFee'].toDouble(),
//             toothTable: List<int>.from(data['toothTable']),
//             doctorNote: data['doctorNote'] ?? '',
//             isToothwise: data['isToothwise'] ?? false, // Handle isToothwise
//           ));
//         }
//       }
//     }

//     return matchingProcedures;
//   }
//   // ------------------------------------------------------------------------- //
  
//   Future<void> addProcedure(Procedure procedure) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('procedures')
//         .doc();

//     procedure = Procedure(
//       procId: docRef.id,
//       procName: procedure.procName,
//       procFee: procedure.procFee,
//       toothTable: procedure.toothTable,
//       doctorNote: procedure.doctorNote,
//       isToothwise: procedure.isToothwise, // Include isToothwise
//     );

//     await docRef.set(procedure.toJson());
//   }
//   // ------------------------------------------------------------------------- //

//   Future<void> updateProcedure(Procedure procedure) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('procedures')
//         .doc(procedure.procId);

//     await docRef.update(procedure.toJson());
//   }

//   Future<void> deleteProcedure(String procId) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('procedures')
//         .doc(procId);

//     await docRef.delete();
//   }

//   Future<List<Procedure>> getAllProcedures() async {
//     final proceduresCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('procedures');

//     final querySnapshot = await proceduresCollection.get();
//     List<Procedure> allProcedures = [];

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data();
//       if (data['procName'] != null &&
//           data['procFee'] != null &&
//           data['toothTable'] != null) {
//         allProcedures.add(Procedure(
//           procId: doc.id,
//           procName: data['procName'],
//           procFee: data['procFee'].toDouble(),
//           toothTable: List<int>.from(data['toothTable']),
//           doctorNote: data['doctorNote'] ?? '', // Handle null doctorNote
//         ));
//       }
//     }

//     return allProcedures;
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
