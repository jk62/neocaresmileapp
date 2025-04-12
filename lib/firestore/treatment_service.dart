import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as devtools show log;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/firestore/payment_service.dart';

class TreatmentService {
  final String clinicId;
  final String patientId;

  TreatmentService({required this.clinicId, required this.patientId});

  // Create a new treatment
  Future<void> createTreatment({
    required String treatmentId,
    required String chiefComplaint,
    required List<Map<String, dynamic>> oralExamination,
    required List<Map<String, dynamic>> procedures,
  }) async {
    try {
      final treatmentData = {
        'treatmentId': treatmentId,
        'chiefComplaint': chiefComplaint,
        'oralExamination': oralExamination,
        'procedures': procedures,
      };

      final treatmentsRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('treatments');

      await treatmentsRef.add(treatmentData);
    } catch (error) {
      devtools.log('Error creating treatment: $error');
      // throw error;
      rethrow;
    }
  }

  // Update an existing treatment
  Future<void> updateTreatment({
    required String treatmentId,
    required String chiefComplaint,
    required List<Map<String, dynamic>> oralExamination,
    required List<Map<String, dynamic>> procedures,
  }) async {
    try {
      final treatmentData = {
        'chiefComplaint': chiefComplaint,
        'oralExamination': oralExamination,
        'procedures': procedures,
      };

      final treatmentRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('treatments')
          .doc(treatmentId);

      await treatmentRef.update(treatmentData);
    } catch (error) {
      devtools.log('Error updating treatment: $error');
      // throw error;
      rethrow;
    }
  }

  //-------------------------------------------------------------------//
  // Delete a treatment and its subcollections, including storage files
  Future<void> deleteTreatment(String treatmentId) async {
    try {
      final treatmentRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('treatments')
          .doc(treatmentId);

      // Fetch picture URLs to delete from storage
      final picturesSnapshot = await treatmentRef.collection('pictures').get();
      final pictureUrls = picturesSnapshot.docs
          .map((doc) => doc.data()['picUrl'] as String?)
          .where((url) => url != null)
          .cast<String>()
          .toList();

      // Delete subcollections first
      await _deleteSubcollection(treatmentRef, 'notes');
      await _deleteSubcollection(treatmentRef, 'payments');
      await _deleteSubcollection(treatmentRef, 'prescriptions');
      await _deleteSubcollection(treatmentRef, 'pictures');

      // Delete the treatment document
      await treatmentRef.delete();

      // Delete pictures from storage
      await _deletePicturesFromStorage(pictureUrls);
    } catch (error) {
      devtools.log('Error deleting treatment: $error');
      rethrow;
    }
  }

  // Helper function to delete a subcollection
  Future<void> _deleteSubcollection(
      DocumentReference parentRef, String subcollectionName) async {
    final subcollectionRef = parentRef.collection(subcollectionName);
    final subcollectionSnapshot = await subcollectionRef.get();
    for (final doc in subcollectionSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Helper function to delete pictures from Firebase Storage
  Future<void> _deletePicturesFromStorage(List<String> urls) async {
    final storage = FirebaseStorage.instance;
    for (final url in urls) {
      try {
        // Extract the file path from the URL
        final path = _extractFilePathFromUrl(url);
        final ref = storage.ref().child(path);
        await ref.delete();
      } catch (error) {
        devtools.log('Error deleting picture from storage: $error');
      }
    }
  }

  // Function to extract file path from URL with logging and validation
  String _extractFilePathFromUrl(String url) {
    final Uri uri = Uri.parse(url);
    devtools.log('Extracting file path from URL: $url');
    final path = uri.path.replaceFirst('/v0/b/', '');
    devtools.log('Path after replaceFirst: $path');
    final pathSegments = path.split('/o/');
    devtools.log('Path segments: $pathSegments');

    // Validate that pathSegments has the expected format
    if (pathSegments.length > 1) {
      final filePath = pathSegments[1].split('?').first.replaceAll('%2F', '/');
      devtools.log('Extracted file path: $filePath');
      return filePath;
    } else {
      devtools.log('Unexpected URL format: $url');
      throw FormatException('Unexpected URL format', url);
    }
  }

  // ------------------------------------------------------------------//
  // Fetch treatment data
  Future<Map<String, dynamic>?> fetchTreatmentData(String treatmentId) async {
    try {
      final treatmentsRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('treatments');

      final treatmentDoc = await treatmentsRef.doc(treatmentId).get();

      if (treatmentDoc.exists) {
        return treatmentDoc.data(); // Return the treatment data
      } else {
        devtools.log('Treatment document with ID $treatmentId not found.');
        return null;
      }
    } catch (error) {
      devtools.log('Error fetching treatment data: $error');
      return null; // Handle the error
    }
  }

  // Update consent status
  Future<void> updateConsent(String treatmentId, bool isConsentTaken) async {
    try {
      final treatmentDocRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('treatments')
          .doc(treatmentId);

      await treatmentDocRef.update({'isConsentTaken': isConsentTaken});
      devtools.log('isConsentTaken updated successfully to $isConsentTaken');
    } catch (error) {
      devtools.log('Error updating isConsentTaken: $error');
      throw error; // Handle error
    }
  }

  //-------------------------------------------------------------------//
  // Fetch existing pictures for a treatment
  Future<List<Map<String, dynamic>>> fetchPictures(String treatmentId) async {
    try {
      final picturesSnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('treatments')
          .doc(treatmentId)
          .collection('pictures')
          .get();

      List<Map<String, dynamic>> pictures = [];
      for (var doc in picturesSnapshot.docs) {
        final data = doc.data();
        data['tags'] = List<String>.from(data['tags'] ?? []);
        data['isExisting'] = true;
        data['docId'] = doc.id;
        pictures.add(data);
      }
      return pictures;
    } catch (error) {
      devtools.log('Error fetching pictures: $error');
      return [];
    }
  }

  // Delete picture from Firestore and Firebase Storage
  Future<void> deletePicture(
      Map<String, dynamic> picture, String treatmentId) async {
    final String? picUrl = picture['picUrl'];
    final String? docId = picture['docId'];

    try {
      // Delete from Firebase Storage if picUrl is available
      if (picUrl != null) {
        final Reference storageRef =
            FirebaseStorage.instance.refFromURL(picUrl);
        await storageRef.delete();
        devtools.log('Image deleted from Firebase Storage');
      }

      // Delete from Firestore if docId is available
      if (docId != null) {
        await FirebaseFirestore.instance
            .collection('clinics')
            .doc(clinicId)
            .collection('patients')
            .doc(patientId)
            .collection('treatments')
            .doc(treatmentId)
            .collection('pictures')
            .doc(docId)
            .delete();
        devtools.log('Picture document deleted from Firestore');
      }
    } catch (e) {
      devtools.log('Error deleting image or document: $e');
      throw e;
    }
  }

  //-------------------------------------------------------------------//
  Future<String> submitTreatment({
    required String? treatmentId,
    required Map<String, dynamic> treatmentData,
    bool isEditMode = false,
  }) async {
    try {
      final treatmentsRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('treatments');

      // Handle update in edit mode
      if (isEditMode && treatmentId != null) {
        await treatmentsRef.doc(treatmentId).update(treatmentData);
        devtools.log('Treatment updated successfully.');
        return treatmentId;
      }
      // Handle create new treatment
      else {
        final treatmentDocRef = await treatmentsRef.add(treatmentData);
        treatmentId = treatmentDocRef.id;
        await treatmentDocRef.update({'treatmentId': treatmentId});
        devtools.log('New treatment created with ID: $treatmentId');
        return treatmentId;
      }
    } catch (error) {
      devtools.log('Error submitting treatment data: $error');
      rethrow;
    }
  }

  // This method handles uploading, editing, and deleting images
  Future<void> uploadAndHandleImages({
    required String treatmentId,
    required List<Map<String, dynamic>> pictures,
    required List<String> deletedPictureDocIds,
  }) async {
    final picturesCollectionRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('patients')
        .doc(patientId)
        .collection('treatments')
        .doc(treatmentId)
        .collection('pictures');

    // Handle New Pictures
    final newPictures =
        pictures.where((picture) => picture['isExisting'] == false).toList();
    for (var picture in newPictures) {
      await _uploadPicture(picture, picturesCollectionRef, treatmentId);
    }

    // Handle Edited Pictures
    final editedPictures =
        pictures.where((picture) => picture['isEdited'] == true).toList();
    for (var picture in editedPictures) {
      await _updatePicture(picture, picturesCollectionRef, treatmentId);
    }

    // Handle Deletion of Pictures
    final picturesToDelete = pictures
        .where((picture) => picture['isMarkedForDeletion'] == true)
        .toList();
    await _deletePictures(picturesToDelete, picturesCollectionRef);

    // Handle Deletion of Picture Documents
    for (var docId in deletedPictureDocIds) {
      await picturesCollectionRef.doc(docId).delete();
      devtools.log('Deleted picture doc with docId $docId');
    }
  }

  // Helper function to upload a new picture to Firebase Storage
  Future<void> _uploadPicture(
    Map<String, dynamic> picture,
    CollectionReference picturesCollectionRef,
    String treatmentId,
  ) async {
    final String localPath = picture['localPath'];
    final String picId = picture['picId'];
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('patient_treatment_pictures/$patientId/$treatmentId/$picId.jpg');

    await storageRef.putFile(File(localPath));
    final String picUrl = await storageRef.getDownloadURL();

    picture['picUrl'] = picUrl;
    picture['treatmentId'] = treatmentId;
    picture['isExisting'] = true;

    await picturesCollectionRef.add(picture);
    devtools.log('New picture uploaded and document created successfully.');
  }

  // Helper function to update an existing picture in Firebase Storage
  Future<void> _updatePicture(
    Map<String, dynamic> picture,
    CollectionReference picturesCollectionRef,
    String treatmentId,
  ) async {
    final String localPath = picture['localPath'];
    final String picId = picture['picId'];
    final String? docId = picture['docId'];
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('patient_treatment_pictures/$patientId/$treatmentId/$picId.jpg');

    await storageRef.putFile(File(localPath));
    final String picUrl = await storageRef.getDownloadURL();

    picture['picUrl'] = picUrl;
    picture['treatmentId'] = treatmentId;
    picture['isExisting'] = true;
    picture['isEdited'] = false;

    // Add updated picture data to Firestore
    await picturesCollectionRef.add(picture);
    devtools.log('Edited picture uploaded and updated in Firestore.');

    // Delete the old document if necessary
    if (docId != null && docId.isNotEmpty) {
      await picturesCollectionRef.doc(docId).delete();
      devtools.log('Old picture document removed for docId $docId');
    }
  }

  // Helper function to delete pictures from Firebase Storage and Firestore
  Future<void> _deletePictures(
    List<Map<String, dynamic>> picturesToDelete,
    CollectionReference picturesCollectionRef,
  ) async {
    for (var picture in picturesToDelete) {
      final String? picUrl = picture['picUrl'];
      if (picUrl != null && picUrl.startsWith('https://')) {
        final Reference storageRef =
            FirebaseStorage.instance.refFromURL(picUrl);
        await storageRef.delete();
        devtools.log('Deleted picture from Firebase Storage at URL: $picUrl');

        if (picture['docId'] != null) {
          await picturesCollectionRef.doc(picture['docId']).delete();
          devtools.log('Deleted picture document from Firestore.');
        }
      }
    }
  }

  // Method to handle adding or updating prescriptions
  Future<void> handlePrescriptions({
    required String treatmentId,
    required List<Map<String, dynamic>> prescriptions,
  }) async {
    try {
      final prescriptionCollectionRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('treatments')
          .doc(treatmentId)
          .collection('prescriptions');

      if (prescriptions.isNotEmpty) {
        final prescriptionData = {
          'treatmentId': treatmentId,
          'medPrescribed': prescriptions,
        };

        // Add or update prescription
        final prescriptionDocRef =
            await prescriptionCollectionRef.add(prescriptionData);
        final prescriptionId = prescriptionDocRef.id;

        await prescriptionDocRef.update({'prescriptionId': prescriptionId});
        devtools.log('Prescriptions added with ID: $prescriptionId');
      } else {
        devtools.log('No prescriptions to add.');
      }
    } catch (error) {
      devtools.log('Error handling prescriptions: $error');
      rethrow;
    }
  }

  // Fetch the consultation fee for a specific doctor
  Future<int?> fetchConsultationFee(String doctorId) async {
    try {
      devtools.log('Welcome to fetchConsultationFee in TreatmentService');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('consultations')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final consultationFee = data['consultationFee'] as double?;
        devtools.log('Consultation Fee fetched: $consultationFee');
        return consultationFee?.toInt();
      }

      devtools.log('No consultation found for doctorId: $doctorId');
      return null;
    } catch (error) {
      devtools.log('Error fetching Consultation Fee: $error');
      return null;
    }
  }

  // Add adjustment to payments
  Future<void> addAdjustmentToPayments({
    required String treatmentId,
    required double adjustmentAmount,
    required String adjustmentDetails,
    required Map<String, dynamic> treatmentData,
  }) async {
    try {
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

      double lastClosingBalance;

      if (paymentDocs.docs.isNotEmpty) {
        final mostRecentPayment =
            paymentDocs.docs.last.data() as Map<String, dynamic>;
        lastClosingBalance = mostRecentPayment['closingBalance'] as double;
      } else {
        lastClosingBalance =
            treatmentData['treatmentCost']['totalCost'] as double;
      }

      double newClosingBalance = lastClosingBalance + adjustmentAmount;

      Payment adjustmentPayment = Payment(
        paymentId: '',
        date: DateTime.now(),
        openingBalance: lastClosingBalance,
        paymentReceived: 0.0,
        adjustments: adjustmentAmount,
        adjustmentDetails: adjustmentDetails,
        closingBalance: newClosingBalance,
      );

      Map<String, dynamic> adjustmentPaymentMap = adjustmentPayment.toMap();

      // Add the adjustment payment to Firestore
      final paymentDocRef =
          await paymentsCollectionRef.add(adjustmentPaymentMap);
      await paymentDocRef.update({'paymentId': paymentDocRef.id});
    } catch (error) {
      devtools.log('Error adding adjustment to payments: $error');
      rethrow;
    }
  }

  // Fetch payments for the treatment
  Future<List<Map<String, dynamic>>> fetchPayments(String treatmentId) async {
    try {
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

      List<Map<String, dynamic>> paymentList = [];
      double lastClosingBalance = 0.0;

      for (QueryDocumentSnapshot doc in paymentDocs.docs) {
        Map<String, dynamic> paymentData = doc.data() as Map<String, dynamic>;

        num paymentReceived = paymentData['paymentReceived'] as num;
        DateTime date = paymentData['date'].toDate();

        if (paymentData.containsKey('closingBalance')) {
          lastClosingBalance = paymentData['closingBalance'] as double;
        }

        String formattedDate = DateFormat('MMM d, EEE').format(date);

        paymentList.add({
          'paymentReceived': paymentReceived.toStringAsFixed(0),
          'date': formattedDate,
        });
      }

      return paymentList;
    } catch (e) {
      devtools.log('Error fetching payments: $e');
      rethrow;
    }
  }

  //-------------------------------------------------------------------//
  // Fetch treatment data for a patient
  Future<Map<String, dynamic>?> fetchAllTreatmentData() async {
    try {
      // Reference to the patient document
      final patientDocument = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId);

      // Fetch the patient document
      final patientDocumentSnapshot = await patientDocument.get();

      // Check if the patient document exists
      if (!patientDocumentSnapshot.exists) {
        devtools.log(
            'Patient document or treatments sub-collection does not exist.');
        return null;
      }

      // Fetch the treatments sub-collection
      final treatmentsCollection = patientDocument.collection('treatments');
      final treatmentsQuerySnapshot = await treatmentsCollection.get();

      // Check if there are treatments available
      if (treatmentsQuerySnapshot.docs.isEmpty) {
        devtools.log('No treatments found for the patient.');
        return null;
      }

      // Logic for determining active and closed treatments
      bool hasActiveTreatment = false;
      bool hasClosedTreatments = false;
      Map<String, dynamic>? activeTreatmentData;
      List<Map<String, dynamic>> closedTreatments = [];

      // Iterate over the treatment documents
      for (var treatmentDocument in treatmentsQuerySnapshot.docs) {
        final treatmentData = treatmentDocument.data();

        devtools.log('treatmentData: $treatmentData');
        final isConsentTaken = treatmentData['isConsentTaken'] ?? false;
        final isTreatmentClose = treatmentData['isTreatmentClose'] ?? false;

        devtools.log('isConsentTaken: $isConsentTaken');
        devtools.log('isTreatmentClose: $isTreatmentClose');

        // Convert 'treatmentDate' and 'treatmentCloseDate' from Timestamp to DateTime
        if (treatmentData['treatmentDate'] != null) {
          treatmentData['treatmentDate'] =
              (treatmentData['treatmentDate'] as Timestamp).toDate();
        }

        if (treatmentData['treatmentCloseDate'] != null) {
          treatmentData['treatmentCloseDate'] =
              (treatmentData['treatmentCloseDate'] as Timestamp).toDate();
        }

        if (isTreatmentClose) {
          // Closed treatment
          hasClosedTreatments = true;
          closedTreatments.add(treatmentData);
        } else {
          // Active treatment
          hasActiveTreatment = true;
          activeTreatmentData = treatmentData;
        }
      }

      // Prepare the final result
      return {
        'hasActiveTreatment': hasActiveTreatment,
        'hasClosedTreatments': hasClosedTreatments,
        'activeTreatmentData': activeTreatmentData,
        'closedTreatments': closedTreatments,
      };
    } catch (error) {
      devtools.log('Error fetching treatment data: $error');
      return null;
    }
  }

  //-------------------------------------------------------------------//
  // Close treatment
  Future<void> closeTreatment(String treatmentId) async {
    try {
      final treatmentRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('patients')
          .doc(patientId)
          .collection('treatments')
          .doc(treatmentId);

      await treatmentRef.update({
        'isTreatmentClose': true,
        'treatmentCloseDate': DateTime.now().toUtc(),
      });

      devtools.log('Treatment $treatmentId closed successfully.');
    } catch (error) {
      devtools.log('Error closing treatment: $error');
      rethrow; // Allow the caller to handle the error
    }
  }
  //-------------------------------------------------------------------//
}
