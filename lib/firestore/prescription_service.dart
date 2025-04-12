import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neocaresmileapp/mywidgets/medicine.dart';
import 'package:neocaresmileapp/mywidgets/prescription_data.dart';

class PrescriptionService {
  final String clinicId;
  final String patientId;
  final String? treatmentId;

  PrescriptionService({
    required this.clinicId,
    required this.patientId,
    required this.treatmentId,
  });

  Future<void> savePrescription(Map<String, dynamic> prescriptionData) async {
    final prescriptionCollectionRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('patients')
        .doc(patientId)
        .collection('treatments')
        .doc(treatmentId)
        .collection('prescriptions');

    final prescriptionDocRef =
        await prescriptionCollectionRef.add(prescriptionData);
    final prescriptionId = prescriptionDocRef.id;

    await prescriptionDocRef.update({'prescriptionId': prescriptionId});
  }

  Future<void> deletePrescription(String prescriptionId) async {
    final prescriptionDocRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('patients')
        .doc(patientId)
        .collection('treatments')
        .doc(treatmentId)
        .collection('prescriptions')
        .doc(prescriptionId);

    await prescriptionDocRef.delete();
  }

  Future<List<Medicine>> updateMatchingMedicines(String userInput) async {
    if (userInput.isEmpty) {
      return [];
    }

    final firstChar = userInput[0];
    final convertedInput = firstChar.toLowerCase() == firstChar
        ? firstChar.toUpperCase() + userInput.substring(1)
        : userInput;

    final medicinesCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('medicines');

    final querySnapshot = await medicinesCollection
        .where('medName', isGreaterThanOrEqualTo: convertedInput)
        .where('medName', isLessThan: '${convertedInput}z')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Medicine(
        medId: doc.id,
        medName: data['medName'],
        composition: '',
      );
    }).toList();
  }

  // Future<List<PrescriptionData>> fetchExistingPrescriptions() async {
  //   final existingPrescriptionsSnapshot = await FirebaseFirestore.instance
  //       .collection('clinics')
  //       .doc(clinicId)
  //       .collection('patients')
  //       .doc(patientId)
  //       .collection('treatments')
  //       .doc(treatmentId)
  //       .collection('prescriptions')
  //       .get();

  //   return existingPrescriptionsSnapshot.docs.map((doc) {
  //     final data = doc.data();
  //     final prescriptions =
  //         List<Map<String, dynamic>>.from(data['medPrescribed'] ?? []);
  //     final prescriptionDate = (data['prescriptionDate'] as Timestamp).toDate();

  //     return PrescriptionData(
  //       prescriptionId: doc.id,
  //       prescriptionDate: prescriptionDate,
  //       medicines: prescriptions,
  //     );
  //   }).toList();
  // }

  Future<List<PrescriptionData>> fetchExistingPrescriptions() async {
    final existingPrescriptionsSnapshot = await FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('patients')
        .doc(patientId)
        .collection('treatments')
        .doc(treatmentId)
        .collection('prescriptions')
        .get();

    List<PrescriptionData> prescriptionList = [];
    DateTime latestPrescriptionDate = DateTime(1900);

    for (final doc in existingPrescriptionsSnapshot.docs) {
      final data = doc.data();

      // Parse prescriptions list
      final prescriptions =
          List<Map<String, dynamic>>.from(data['medPrescribed'] ?? []);

      // Parse the prescription date
      final prescriptionDate =
          (data['prescriptionDate'] as Timestamp?)?.toDate() ?? DateTime.now();

      if (prescriptionDate.isAfter(latestPrescriptionDate)) {
        latestPrescriptionDate = prescriptionDate;
      }

      prescriptionList.add(
        PrescriptionData(
          prescriptionId: doc.id,
          prescriptionDate: prescriptionDate,
          medicines: prescriptions,
        ),
      );
    }

    return prescriptionList;
  }

  Future<Map<String, dynamic>?> fetchTreatmentAndPatientData() async {
    try {
      // Fetch the treatment data
      final treatmentRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('treatments')
          .doc(treatmentId);

      final treatmentSnapshot = await treatmentRef.get();

      if (!treatmentSnapshot.exists) {
        return null;
      }

      // Fetch the patient data
      final patientRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId);

      final patientSnapshot = await patientRef.get();

      if (!patientSnapshot.exists) {
        return null;
      }

      // Combine treatment and patient data
      final combinedData = {
        'treatmentData': treatmentSnapshot.data(),
        'patientData': patientSnapshot.data(),
      };

      return combinedData;
    } catch (error) {
      // Handle error
      return null;
    }
  }
}
