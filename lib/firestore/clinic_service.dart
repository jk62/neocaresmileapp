import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicService {
  final FirebaseFirestore firestore;
  ClinicService({FirebaseFirestore? firestoreInstance})
      : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  CollectionReference get clinicsCollection => firestore.collection('clinics');

  Future<Map<String, dynamic>?> fetchClinicData(String clinicId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
        .doc(clinicId)
        .get() as DocumentSnapshot<Map<String, dynamic>>;

    return snapshot.data();
  }

  Future<String> getClinicId(String clinicName) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
        .where('clinicName', isEqualTo: clinicName)
        .get() as QuerySnapshot<Map<String, dynamic>>;

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs[0].id;
    }

    throw Exception('Clinic not found');
  }
}

//------------------------------------------------------------------------------//
// CODE BELOW STABLE WITH DIRECT CALL TO FIREBASE
// class ClinicService {
//   final clinicsCollection = FirebaseFirestore.instance.collection('clinics');
//   Future<Map<String, dynamic>?> fetchClinicData(String clinicId) async {
//     DocumentSnapshot<Map<String, dynamic>> snapshot =
//         await clinicsCollection.doc(clinicId).get();
//     return snapshot.data();
//   }

//   Future<String> getClinicId(String clinicName) async {
//     QuerySnapshot<Map<String, dynamic>> snapshot = await clinicsCollection
//         .where('clinicName', isEqualTo: clinicName)
//         .get();

//     if (snapshot.docs.isNotEmpty) {
//       return snapshot.docs[0].id;
//     }

//     throw Exception('Clinic not found');
//   }
// }

//------------------------------------------------------------------------------//
// class DoctorService {
//   final CollectionReference<Map<String, dynamic>> doctorsCollection =
//       FirebaseFirestore.instance.collection('doctors');

//   Future<Map<String, dynamic>?> fetchDoctorData(String doctorId) async {
//     QuerySnapshot<Map<String, dynamic>> snapshot = await doctorsCollection
//         .where('doctorId', isEqualTo: doctorId)
//         .limit(1)
//         .get();

//     if (snapshot.docs.isNotEmpty) {
//       DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
//           snapshot.docs[0];
//       return documentSnapshot.data();
//     }

//     return null;
//   }

//   Future<Map<String, dynamic>?> fetchDoctorDataForUser(String userId) async {
//     QuerySnapshot<Map<String, dynamic>> snapshot = await doctorsCollection
//         .where('userId', isEqualTo: userId)
//         .limit(1)
//         .get();

//     if (snapshot.docs.isNotEmpty) {
//       DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
//           snapshot.docs[0];
//       return documentSnapshot.data();
//     }

//     return null;
//   }

//   //---------------------------------------------------------------------------//

//   Future<Map<String, dynamic>?> fetchAndCacheDoctorDataIfNeeded(
//       String userId) async {
//     devtools.log('fetchAndCacheDoctorDataIfNeeded invoked');
//     // Check if cached data exists
//     Map<String, dynamic>? cachedData = await _getCachedDoctorData();

//     // Fetch data from Firestore
//     Map<String, dynamic>? fetchedData = await fetchDoctorDataForUser(userId);

//     // Compare metadata to determine if data needs to be updated
//     bool shouldUpdate = _shouldUpdateData(cachedData, fetchedData);

//     if (shouldUpdate) {
//       // Cache the fetched data
//       await _cacheDoctorData(fetchedData);
//       return fetchedData;
//     } else {
//       // Use cached data
//       return cachedData;
//     }
//   }

//   //````````````````````````````````````````````````````````````````````````````//
//   //`````````````````````````````````````````````````````````````````````````````//
//   // Check if data needs to be updated
//   bool _shouldUpdateData(
//     Map<String, dynamic>? cachedData,
//     Map<String, dynamic>? fetchedData,
//   ) {
//     if (cachedData == null || fetchedData == null) {
//       // If either cachedData or fetchedData is null, update the data
//       return true;
//     }

//     // Compare metadata to determine if data should be updated
//     // Example: Compare timestamps or version numbers
//     // For simplicity, we'll compare the 'updatedAt' field if available

//     final DateTime? cachedUpdatedAt = cachedData['updatedAt'] as DateTime?;
//     final DateTime? fetchedUpdatedAt = fetchedData['updatedAt'] as DateTime?;

//     // If cachedUpdatedAt or fetchedUpdatedAt is null, update the data
//     if (cachedUpdatedAt == null || fetchedUpdatedAt == null) {
//       return true;
//     }

//     // Compare the timestamps
//     return fetchedUpdatedAt.isAfter(cachedUpdatedAt);
//   }

//   //````````````````````````````````````````````````````````````````````````````//
//   // Cache doctor data
//   Future<void> _cacheDoctorData(Map<String, dynamic>? data) async {
//     if (data != null) {
//       try {
//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         const String cachedDataKey = 'doctor_data';

//         // Convert data to JSON string
//         final String jsonData = jsonEncode(data);

//         // Store the JSON string in SharedPreferences
//         await prefs.setString(cachedDataKey, jsonData);

//         // Print a log message indicating successful caching
//         devtools.log('Doctor data cached successfully!');
//       } catch (e) {
//         // Handle any errors that occur during caching
//         devtools.log('Error caching doctor data: $e');
//       }
//     } else {
//       // Handle case where data is null
//       devtools.log('Cannot cache null data.');
//     }
//   }

//   //````````````````````````````````````````````````````````````````````````````//
//   // Retrieve cached doctor data
//   Future<Map<String, dynamic>?> _getCachedDoctorData() async {
//     try {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       const String cachedDataKey = 'doctor_data';

//       // Retrieve the cached data as a JSON string
//       final String? jsonData = prefs.getString(cachedDataKey);

//       if (jsonData != null) {
//         // Parse the JSON string back into a Map<String, dynamic>
//         final Map<String, dynamic> cachedData = jsonDecode(jsonData);

//         // Return the parsed data
//         return cachedData;
//       } else {
//         // Return null if no cached data is found
//         return null;
//       }
//     } catch (e) {
//       // Handle any errors that occur during data retrieval
//       devtools.log('Error retrieving cached doctor data: $e');
//       return null;
//     }
//   }

//   //````````````````````````````````````````````````````````````````````````````//
//   Future<List<Map<String, String>>> getDoctorNames() async {
//     try {
//       devtools.log('Welcome to getDoctorNames defined inside DoctorService ! ');
//       // Query the doctors sub-collection to get all doctors
//       final querySnapshot =
//           await FirebaseFirestore.instance.collection('doctors').get();

//       // Extract doctorName and doctorId from each document and store in a Map
//       List<Map<String, String>> doctorNamesAndIds =
//           querySnapshot.docs.map((doc) {
//         final data = doc.data();
//         return {
//           'doctorName': data['doctorName'] as String,
//           'doctorId': data['doctorId'] as String,
//         };
//       }).toList();
//       devtools.log('doctorNamesAndIds fetched are $doctorNamesAndIds');

//       return doctorNamesAndIds;
//     } catch (error) {
//       devtools.log('Error fetching doctor names: $error');
//       return [];
//     }
//   }
// }
