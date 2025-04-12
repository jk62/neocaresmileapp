import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as devtools show log;
import 'package:shared_preferences/shared_preferences.dart';

class DoctorService {
  final FirebaseFirestore firestore;

  DoctorService({FirebaseFirestore? firestoreInstance})
      : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get doctorsCollection =>
      firestore.collection('doctors');

  Future<Map<String, dynamic>?> fetchDoctorData(String doctorId) async {
    devtools.log('**** fetchDoctorData defined inside DoctorService invoked');
    final snapshot = await doctorsCollection
        .where('doctorId', isEqualTo: doctorId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs[0].data();
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchDoctorDataForUser(String userId) async {
    devtools.log(
        '**** fetchDoctorDataForUser defined inside DoctorService invoked');
    final snapshot = await doctorsCollection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs[0].data();
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchAndCacheDoctorDataIfNeeded(
      String userId) async {
    devtools.log(
        '**** fetchAndCacheDoctorDataIfNeeded defined inside DoctorService invoked');
    Map<String, dynamic>? cachedData = await _getCachedDoctorData();
    Map<String, dynamic>? fetchedData = await fetchDoctorDataForUser(userId);

    if (_shouldUpdateData(cachedData, fetchedData)) {
      await _cacheDoctorData(fetchedData);
      return fetchedData;
    }
    return cachedData;
  }

  bool _shouldUpdateData(
      Map<String, dynamic>? cachedData, Map<String, dynamic>? fetchedData) {
    devtools.log('**** _shouldUpdateData defined inside DoctorService invoked');

    if (cachedData == null || fetchedData == null) return true;

    final cachedUpdatedAt = cachedData['updatedAt'] as DateTime?;
    final fetchedUpdatedAt = fetchedData['updatedAt'] as DateTime?;

    if (cachedUpdatedAt == null || fetchedUpdatedAt == null) return true;

    return fetchedUpdatedAt.isAfter(cachedUpdatedAt);
  }

  //------------------------------------------------------------------------//

  Future<void> _cacheDoctorData(Map<String, dynamic>? data) async {
    devtools.log('**** _cacheDoctorData defined inside DoctorService invoked.');
    if (data != null) {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        const String cachedDataKey = 'doctor_data';

        // Convert DateTime to string
        final String jsonData = jsonEncode(data.map((key, value) {
          if (value is DateTime) {
            return MapEntry(key, value.toIso8601String());
          }
          return MapEntry(key, value);
        }));

        await prefs.setString(cachedDataKey, jsonData);
        devtools.log(
            '**** This is coming from inside _cacheDoctorData defined inside DoctorService. Doctor data cached successfully!');
      } catch (e) {
        devtools.log(
            '**** This is coming from inside _cacheDoctorData defined inside DoctorService. Error caching doctor data: $e');
      }
    } else {
      devtools.log('Cannot cache null data.');
    }
  }

  Future<Map<String, dynamic>?> _getCachedDoctorData() async {
    devtools.log(
        '**** _getCachedDoctorData defined inside DoctorService invoked !');
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const String cachedDataKey = 'doctor_data';
      final String? jsonData = prefs.getString(cachedDataKey);

      if (jsonData != null) {
        // Explicitly cast the decoded JSON to Map<String, dynamic>.
        final Map<String, dynamic> cachedData =
            Map<String, dynamic>.from(jsonDecode(jsonData));

        // Check if 'updatedAt' exists and convert it to DateTime.
        if (cachedData.containsKey('updatedAt')) {
          cachedData['updatedAt'] = DateTime.parse(cachedData['updatedAt']);
        } else {
          devtools.log('**** No "updatedAt" key found in cached doctor data.');
        }

        return cachedData;
      }
    } catch (e) {
      devtools.log(
          '**** This is coming from inside _getCachedDoctorData defined inside DoctorService. Error retrieving cached doctor data: $e');
    }
    return null;
  }

  //--------------------------------------------------------------------------//

  Future<List<Map<String, String>>> getDoctorNames() async {
    try {
      devtools.log(
          '**** Fetching doctor names... This is coming from inside getDoctorNames defined inside DoctorService !');
      final snapshot = await doctorsCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'doctorName': data['doctorName'] as String,
          'doctorId': data['doctorId'] as String,
        };
      }).toList();
    } catch (error) {
      devtools.log(
          '**** This is coming from inside getDoctorNames defined inside DoctorService ! Error fetching doctor names: $error');
      return [];
    }
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE WITH DIRECT CALL TO FIREBASE WITHOUT USING DEPENDENCY INJECTION //
// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:developer' as devtools show log;
// import 'package:shared_preferences/shared_preferences.dart';

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

//---------------------------------------------------------------------------//
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
//---------------------------------------------------------------------------//