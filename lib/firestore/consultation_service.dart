import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neocaresmileapp/mywidgets/consultation.dart';
import 'package:uuid/uuid.dart';

class ConsultationService {
  String clinicId; // Make clinicId mutable
  final FirebaseFirestore firestore;

  ConsultationService(this.clinicId, {FirebaseFirestore? firestoreInstance})
      : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  // Method to update the clinicId
  void updateClinicId(String newClinicId) {
    clinicId = newClinicId;
  }

  Future<void> addConsultation(
      String doctorId, String doctorName, double consultationFee) async {
    final consultationId = const Uuid().v4();

    Consultation consultation = Consultation(
      consultationId: consultationId,
      doctorId: doctorId,
      doctorName: doctorName,
      consultationFee: consultationFee,
    );

    DocumentReference docRef = firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('consultations')
        .doc(consultationId);

    await docRef.set(consultation.toJson());
  }

  Future<void> updateConsultation(Consultation consultation) async {
    DocumentReference docRef = firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('consultations')
        .doc(consultation.consultationId);

    await docRef.update(consultation.toJson());
  }

  Future<void> deleteConsultation(String consultationId) async {
    DocumentReference docRef = firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('consultations')
        .doc(consultationId);

    await docRef.delete();
  }

  Future<List<Consultation>> getAllConsultations() async {
    final consultationsCollection = firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('consultations');

    final querySnapshot = await consultationsCollection.get();
    List<Consultation> allConsultations = [];

    for (var doc in querySnapshot.docs) {
      allConsultations.add(Consultation.fromJson(doc.data()));
    }

    return allConsultations;
  }

  Future<List<Consultation>> searchConsultations(String query) async {
    final consultationsCollection = firestore
        .collection('clinics')
        .doc(clinicId)
        .collection('consultations');

    final querySnapshot = await consultationsCollection.get();
    List<Consultation> matchingConsultations = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final doctorName = data['doctorName'].toString().toLowerCase();

      if (doctorName.startsWith(query.toLowerCase())) {
        matchingConsultations.add(Consultation.fromJson(data));
      }
    }

    return matchingConsultations;
  }
}


// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:neocare_dental_app/mywidgets/consultation.dart';
// import 'package:uuid/uuid.dart';

// class ConsultationService {
//   String clinicId; // Make clinicId mutable
//   final FirebaseFirestore firestore;

//   ConsultationService(this.clinicId, {FirebaseFirestore? firestoreInstance})
//       : firestore = firestoreInstance ?? FirebaseFirestore.instance;

//   // Method to update the clinicId
//   void updateClinicId(String newClinicId) {
//     clinicId = newClinicId;
//   }

//   Future<void> addConsultation(
//       String doctorId, String doctorName, double consultationFee) async {
//     final consultationId = const Uuid().v4();

//     Consultation consultation = Consultation(
//       consultationId: consultationId,
//       doctorId: doctorId,
//       doctorName: doctorName,
//       consultationFee: consultationFee,
//     );

//     DocumentReference docRef = firestore
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations')
//         .doc(consultationId);

//     await docRef.set(consultation.toJson());
//   }

//   Future<void> updateConsultation(Consultation consultation) async {
//     DocumentReference docRef = firestore
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations')
//         .doc(consultation.consultationId);

//     await docRef.update(consultation.toJson());
//   }

//   Future<void> deleteConsultation(String consultationId) async {
//     DocumentReference docRef = firestore
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations')
//         .doc(consultationId);

//     await docRef.delete();
//   }

//   Future<List<Consultation>> getAllConsultations() async {
//     final consultationsCollection = firestore
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations');

//     final querySnapshot = await consultationsCollection.get();
//     List<Consultation> allConsultations = [];

//     for (var doc in querySnapshot.docs) {
//       allConsultations.add(Consultation.fromJson(doc.data()));
//     }

//     return allConsultations;
//   }

//   Future<List<Consultation>> searchConsultations(String query) async {
//     final consultationsCollection = firestore
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations');

//     final querySnapshot = await consultationsCollection.get();
//     List<Consultation> matchingConsultations = [];

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data();
//       final doctorName = data['doctorName'].toString().toLowerCase();

//       if (doctorName.startsWith(query.toLowerCase())) {
//         matchingConsultations.add(Consultation.fromJson(data));
//       }
//     }

//     return matchingConsultations;
//   }
// }

// class ConsultationService {
//   final String clinicId;
//   final FirebaseFirestore firestore;

//   // Modify the constructor to take an optional FirebaseFirestore instance
//   ConsultationService(this.clinicId, {FirebaseFirestore? firestoreInstance})
//       : firestore = firestoreInstance ?? FirebaseFirestore.instance;

//   Future<void> addConsultation(
//       String doctorId, String doctorName, double consultationFee) async {
//     final consultationId = const Uuid().v4();

//     Consultation consultation = Consultation(
//       consultationId: consultationId,
//       doctorId: doctorId,
//       doctorName: doctorName,
//       consultationFee: consultationFee,
//     );

//     DocumentReference docRef = firestore
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations')
//         .doc(consultationId);

//     await docRef.set(consultation.toJson());
//   }

//   Future<void> updateConsultation(Consultation consultation) async {
//     DocumentReference docRef = firestore
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations')
//         .doc(consultation.consultationId);

//     await docRef.update(consultation.toJson());
//   }

//   Future<void> deleteConsultation(String consultationId) async {
//     DocumentReference docRef = firestore
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations')
//         .doc(consultationId);

//     await docRef.delete();
//   }

//   Future<List<Consultation>> getAllConsultations() async {
//     final consultationsCollection = firestore
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations');

//     final querySnapshot = await consultationsCollection.get();
//     List<Consultation> allConsultations = [];

//     for (var doc in querySnapshot.docs) {
//       allConsultations.add(Consultation.fromJson(doc.data()));
//     }

//     return allConsultations;
//   }

//   Future<List<Consultation>> searchConsultations(String query) async {
//     final consultationsCollection = firestore
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations');

//     final querySnapshot = await consultationsCollection.get();
//     List<Consultation> matchingConsultations = [];

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data();

//       final doctorName = data['doctorName'].toString().toLowerCase();

//       if (doctorName.startsWith(query.toLowerCase())) {
//         matchingConsultations.add(Consultation.fromJson(data));
//       }
//     }

//     return matchingConsultations;
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:neocare_dental_app/mywidgets/consultation.dart';
// import 'package:uuid/uuid.dart';

// class ConsultationService {
//   final String clinicId;

//   ConsultationService(this.clinicId);

//   Future<void> addConsultation(
//       String doctorId, String doctorName, double consultationFee) async {
//     final consultationId = const Uuid().v4();

//     Consultation consultation = Consultation(
//       consultationId: consultationId,
//       doctorId: doctorId,
//       doctorName: doctorName,
//       consultationFee: consultationFee,
//     );

//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations')
//         .doc(consultationId);

//     await docRef.set(consultation.toJson());
//   }

//   Future<void> updateConsultation(Consultation consultation) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations')
//         .doc(consultation.consultationId);

//     await docRef.update(consultation.toJson());
//   }

//   Future<void> deleteConsultation(String consultationId) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations')
//         .doc(consultationId);

//     await docRef.delete();
//   }

//   Future<List<Consultation>> getAllConsultations() async {
//     final consultationsCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations');

//     final querySnapshot = await consultationsCollection.get();
//     List<Consultation> allConsultations = [];

//     for (var doc in querySnapshot.docs) {
//       allConsultations.add(Consultation.fromJson(doc.data()));
//     }

//     return allConsultations;
//   }

//   Future<List<Consultation>> searchConsultations(String query) async {
//     final consultationsCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations');

//     final querySnapshot = await consultationsCollection.get();
//     List<Consultation> matchingConsultations = [];

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data();

//       final doctorName = data['doctorName'].toString().toLowerCase();

//       if (doctorName.startsWith(query.toLowerCase())) {
//         matchingConsultations.add(Consultation.fromJson(data));
//       }
//     }

//     return matchingConsultations;
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:neocare_dental_app/mywidgets/consultation.dart';
// import 'package:uuid/uuid.dart';

// class ConsultationService {
//   final String clinicId;

//   ConsultationService(this.clinicId);

//   Future<void> addConsultation(
//       String doctorId, String doctorName, double consultationFee) async {
//     final consultationId = const Uuid().v4();

//     Consultation consultation = Consultation(
//       consultationId: consultationId,
//       doctorId: doctorId,
//       doctorName: doctorName,
//       consultationFee: consultationFee,
//     );

//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations')
//         .doc(consultationId);

//     await docRef.set(consultation.toJson());
//   }

//   Future<void> updateConsultation(Consultation consultation) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations')
//         .doc(consultation.consultationId);

//     await docRef.update(consultation.toJson());
//   }

//   Future<void> deleteConsultation(String consultationId) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations')
//         .doc(consultationId);

//     await docRef.delete();
//   }

//   Future<List<Consultation>> getAllConsultations() async {
//     final consultationsCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations');

//     final querySnapshot = await consultationsCollection.get();
//     List<Consultation> allConsultations = [];

//     for (var doc in querySnapshot.docs) {
//       allConsultations.add(Consultation.fromJson(doc.data()));
//     }

//     return allConsultations;
//   }

//   Future<Consultation?> getConsultationByDoctorId(String doctorId) async {
//     final consultationsCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('consultations');

//     final querySnapshot = await consultationsCollection
//         .where('doctorId', isEqualTo: doctorId)
//         .get();

//     if (querySnapshot.docs.isNotEmpty) {
//       return Consultation.fromJson(querySnapshot.docs.first.data());
//     }

//     return null;
//   }
// }
