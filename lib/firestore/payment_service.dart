import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  final String clinicId;
  final String patientId;
  final String treatmentId;

  PaymentService({
    required this.clinicId,
    required this.patientId,
    required this.treatmentId,
  });

  // Fetch payments from Firestore and convert Timestamp to DateTime
  Future<List<Map<String, dynamic>>> fetchPayments() async {
    final paymentsCollectionRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('patients')
        .doc(patientId)
        .collection('treatments')
        .doc(treatmentId)
        .collection('payments');

    final QuerySnapshot paymentDocs =
        await paymentsCollectionRef.orderBy('date', descending: false).get();

    return paymentDocs.docs.map((doc) {
      final paymentData = doc.data() as Map<String, dynamic>;

      // Convert Firestore Timestamp to DateTime here
      paymentData['date'] = (paymentData['date'] as Timestamp).toDate();

      return paymentData;
    }).toList();
  }

  // Fetch total amount paid
  Future<double> fetchTotalAmountPaid() async {
    final paymentsCollectionRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('patients')
        .doc(patientId)
        .collection('treatments')
        .doc(treatmentId)
        .collection('payments');

    final QuerySnapshot paymentDocs = await paymentsCollectionRef.get();
    double totalPaid = 0.0;

    for (var doc in paymentDocs.docs) {
      final paymentData =
          doc.data() as Map<String, dynamic>?; // Cast and check if not null
      if (paymentData != null) {
        final amountPaid = paymentData['paymentReceived'] ?? 0.0;
        totalPaid += amountPaid;
      }
    }

    return totalPaid;
  }

  // Save a new payment
  Future<void> savePayment(Payment payment) async {
    final paymentsCollectionRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('patients')
        .doc(patientId)
        .collection('treatments')
        .doc(treatmentId)
        .collection('payments');

    final paymentMap = payment.toMap();
    final paymentDocRef = await paymentsCollectionRef.add(paymentMap);
    await paymentDocRef.update({'paymentId': paymentDocRef.id});
  }
}

// Payment model class
class Payment {
  final String paymentId;
  final DateTime date; // Now handling DateTime, not Firestore Timestamp
  final double openingBalance;
  final double paymentReceived;
  final double adjustments;
  final String adjustmentDetails;
  final double closingBalance;

  Payment({
    required this.paymentId,
    required this.date,
    required this.openingBalance,
    required this.paymentReceived,
    required this.adjustments,
    required this.adjustmentDetails,
    required this.closingBalance,
  });

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'date': date, // Store the DateTime object directly
      'openingBalance': openingBalance,
      'paymentReceived': paymentReceived,
      'adjustments': adjustments,
      'adjustmentDetails': adjustmentDetails,
      'closingBalance': closingBalance,
    };
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// import 'package:cloud_firestore/cloud_firestore.dart';

// class PaymentService {
//   final String clinicId;
//   final String patientId;
//   final String treatmentId;

//   PaymentService({
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   });

//   // Fetch payments from Firestore and convert Timestamp to DateTime
//   Future<List<Map<String, dynamic>>> fetchPayments() async {
//     final paymentsCollectionRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('patients')
//         .doc(patientId)
//         .collection('treatments')
//         .doc(treatmentId)
//         .collection('payments');

//     final QuerySnapshot paymentDocs =
//         await paymentsCollectionRef.orderBy('date', descending: false).get();

//     return paymentDocs.docs.map((doc) {
//       final paymentData = doc.data() as Map<String, dynamic>;

//       // Convert Firestore Timestamp to DateTime here
//       paymentData['date'] = (paymentData['date'] as Timestamp).toDate();

//       return paymentData;
//     }).toList();
//   }

//   // Save a new payment
//   Future<void> savePayment(Payment payment) async {
//     final paymentsCollectionRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('patients')
//         .doc(patientId)
//         .collection('treatments')
//         .doc(treatmentId)
//         .collection('payments');

//     final paymentMap = payment.toMap();
//     final paymentDocRef = await paymentsCollectionRef.add(paymentMap);
//     await paymentDocRef.update({'paymentId': paymentDocRef.id});
//   }
// }

// // Payment model class
// class Payment {
//   final String paymentId;
//   final DateTime date; // Now handling DateTime, not Firestore Timestamp
//   final double openingBalance;
//   final double paymentReceived;
//   final double adjustments;
//   final String adjustmentDetails;
//   final double closingBalance;

//   Payment({
//     required this.paymentId,
//     required this.date,
//     required this.openingBalance,
//     required this.paymentReceived,
//     required this.adjustments,
//     required this.adjustmentDetails,
//     required this.closingBalance,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'paymentId': paymentId,
//       'date': date, // Store the DateTime object directly
//       'openingBalance': openingBalance,
//       'paymentReceived': paymentReceived,
//       'adjustments': adjustments,
//       'adjustmentDetails': adjustmentDetails,
//       'closingBalance': closingBalance,
//     };
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:cloud_firestore/cloud_firestore.dart';

// class PaymentService {
//   final String clinicId;
//   final String patientId;
//   final String treatmentId;

//   PaymentService({
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   });

//   // Fetch payments from Firestore
//   Future<List<Map<String, dynamic>>> fetchPayments() async {
//     final paymentsCollectionRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('patients')
//         .doc(patientId)
//         .collection('treatments')
//         .doc(treatmentId)
//         .collection('payments');

//     final QuerySnapshot paymentDocs =
//         await paymentsCollectionRef.orderBy('date', descending: false).get();

//     return paymentDocs.docs.map((doc) {
//       return doc.data() as Map<String, dynamic>;
//     }).toList();
//   }

//   // Save a new payment
//   Future<void> savePayment(Payment payment) async {
//     final paymentsCollectionRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('patients')
//         .doc(patientId)
//         .collection('treatments')
//         .doc(treatmentId)
//         .collection('payments');

//     final paymentMap = payment.toMap();
//     final paymentDocRef = await paymentsCollectionRef.add(paymentMap);
//     await paymentDocRef.update({'paymentId': paymentDocRef.id});
//   }
// }

// // Payment model class (moved here)
// class Payment {
//   final String paymentId;
//   final DateTime date;
//   final double openingBalance;
//   final double paymentReceived;
//   final double adjustments;
//   final String adjustmentDetails;
//   final double closingBalance;

//   Payment({
//     required this.paymentId,
//     required this.date,
//     required this.openingBalance,
//     required this.paymentReceived,
//     required this.adjustments,
//     required this.adjustmentDetails,
//     required this.closingBalance,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'paymentId': paymentId,
//       'date': date,
//       'openingBalance': openingBalance,
//       'paymentReceived': paymentReceived,
//       'adjustments': adjustments,
//       'adjustmentDetails': adjustmentDetails,
//       'closingBalance': closingBalance,
//     };
//   }
// }
