import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neocaresmileapp/mywidgets/medicine.dart';
import 'package:neocaresmileapp/mywidgets/pre_defined_courses.dart';
import 'dart:developer' as devtools show log;

class MedicineService {
  final String clinicId;

  MedicineService(this.clinicId);

  Future<List<Medicine>> searchMedicines(String query) async {
    final medicinesCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('medicines');

    final querySnapshot = await medicinesCollection.get();
    List<Medicine> matchingMedicines = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      final medName = data['medName'].toString().toLowerCase();

      if (medName.startsWith(query.toLowerCase())) {
        matchingMedicines.add(Medicine(
          medId: doc.id,
          medName: data['medName'],
          composition: data['composition'],
        ));
      }
    }

    return matchingMedicines;
  }

  Future<void> addMedicine(Medicine medicine) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('medicines')
        .doc();

    medicine = Medicine(
      medId: docRef.id,
      medName: medicine.medName,
      composition: medicine.composition,
    );

    await docRef.set(medicine.toJson());
  }

  Future<void> updateMedicine(Medicine medicine) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('medicines')
        .doc(medicine.medId);

    await docRef.update(medicine.toJson());
  }

  Future<void> deleteMedicine(String medId) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('medicines')
        .doc(medId);

    await docRef.delete();
  }

  // Add methods for PreDefinedCourse
  Future<void> addPreDefinedCourse(PreDefinedCourse course) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('preDefinedCourses')
        //.doc();
        .doc(course.id);

    await docRef.set(course.toJson());
  }

  Future<List<PreDefinedCourse>> getPreDefinedCourses() async {
    final coursesCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('preDefinedCourses');

    final querySnapshot = await coursesCollection.get();
    List<PreDefinedCourse> courses = [];

    for (var doc in querySnapshot.docs) {
      courses.add(PreDefinedCourse.fromJson(doc.data()));
    }

    return courses;
  }

  Future<void> updatePreDefinedCourse(PreDefinedCourse course) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('preDefinedCourses')
        .doc(course.id);

    await docRef.update(course.toJson());
  }

  Future<void> deletePreDefinedCourse(String courseId) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('preDefinedCourses')
        .doc(courseId);

    await docRef.delete();
  }

  Future<List<PreDefinedCourse>> searchPreDefinedCourses(String query) async {
    final coursesCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('preDefinedCourses');

    final querySnapshot = await coursesCollection.get();
    List<PreDefinedCourse> matchingCourses = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      final courseName = data['name'].toString().toLowerCase();

      if (courseName.startsWith(query.toLowerCase())) {
        matchingCourses.add(PreDefinedCourse.fromJson(data));
      }
    }

    return matchingCourses;
  }

  Future<List<Medicine>> getAllMedicines() async {
    final medicinesCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('medicines');

    final querySnapshot = await medicinesCollection.get();
    List<Medicine> allMedicines = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      allMedicines.add(Medicine(
        medId: doc.id,
        medName: data['medName'],
        composition: data['composition'],
      ));
    }

    return allMedicines;
  }

  //---------------------------------------------------//
  // Fetch matching medicines based on user input
  Future<List<Medicine>> fetchMatchingMedicines(String input) async {
    try {
      final firstChar = input[0];
      final convertedInput = firstChar.toLowerCase() == firstChar
          ? firstChar.toUpperCase() + input.substring(1)
          : input;

      final medicinesCollection = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('medicines');

      final querySnapshot = await medicinesCollection
          .where('medName', isGreaterThanOrEqualTo: convertedInput)
          .where('medName', isLessThan: '${convertedInput}z')
          .get();

      List<Medicine> matchingMedicines = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Medicine(
          medId: doc.id,
          medName: data['medName'],
          composition: data['composition'],
        );
      }).toList();

      return matchingMedicines;
    } catch (error) {
      devtools.log('Error fetching matching medicines: $error');
      return [];
    }
  }
  //---------------------------------------------------//
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:neocare_dental_app/mywidgets/medicine.dart';
// import 'package:neocare_dental_app/mywidgets/pre_defined_courses.dart';

// class MedicineService {
//   final String clinicId;

//   MedicineService(this.clinicId);

//   Future<List<Medicine>> searchMedicines(String query) async {
//     final medicinesCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('medicines');

//     final querySnapshot = await medicinesCollection.get();
//     List<Medicine> matchingMedicines = [];

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data();

//       final medName = data['medName'].toString().toLowerCase();

//       if (medName.startsWith(query.toLowerCase())) {
//         matchingMedicines.add(Medicine(
//           medId: doc.id,
//           medName: data['medName'],
//           composition: data['composition'],
//         ));
//       }
//     }

//     return matchingMedicines;
//   }

//   Future<void> addMedicine(Medicine medicine) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('medicines')
//         .doc();

//     medicine = Medicine(
//       medId: docRef.id,
//       medName: medicine.medName,
//       composition: medicine.composition,
//     );

//     await docRef.set(medicine.toJson());
//   }

//   Future<void> updateMedicine(Medicine medicine) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('medicines')
//         .doc(medicine.medId);

//     await docRef.update(medicine.toJson());
//   }

//   Future<void> deleteMedicine(String medId) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('medicines')
//         .doc(medId);

//     await docRef.delete();
//   }

//   // Add methods for PreDefinedCourse
//   Future<void> addPreDefinedCourse(PreDefinedCourse course) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('preDefinedCourses')
//         .doc();

//     await docRef.set(course.toJson());
//   }

//   Future<List<PreDefinedCourse>> getPreDefinedCourses() async {
//     final coursesCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('preDefinedCourses');

//     final querySnapshot = await coursesCollection.get();
//     List<PreDefinedCourse> courses = [];

//     for (var doc in querySnapshot.docs) {
//       courses.add(PreDefinedCourse.fromJson(doc.data()));
//     }

//     return courses;
//   }

//   Future<void> updatePreDefinedCourse(PreDefinedCourse course) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('preDefinedCourses')
//         .doc(course.id);

//     await docRef.update(course.toJson());
//   }

//   Future<void> deletePreDefinedCourse(String courseId) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('preDefinedCourses')
//         .doc(courseId);

//     await docRef.delete();
//   }
// }




// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  //
// CODE BELOW WITHOUT PRE DEFINED COURSE IMPLEMENTATION
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:neocare_dental_app/mywidgets/medicine.dart';

// class MedicineService {
//   final String clinicId;

//   MedicineService(this.clinicId);

//   Future<List<Medicine>> searchMedicines(String query) async {
//     final medicinesCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('medicines');

//     final querySnapshot = await medicinesCollection.get();
//     List<Medicine> matchingMedicines = [];

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data();

//       final medName = data['medName'].toString().toLowerCase();

//       if (medName.startsWith(query.toLowerCase())) {
//         // Change here to use startsWith
//         matchingMedicines.add(Medicine(
//           medId: doc.id,
//           medName: data['medName'],
//           composition: data['composition'],
//         ));
//       }
//     }

//     return matchingMedicines;
//   }

//   Future<void> addMedicine(Medicine medicine) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('medicines')
//         .doc();

//     medicine = Medicine(
//       medId: docRef.id,
//       medName: medicine.medName,
//       composition: medicine.composition,
//     );

//     await docRef.set(medicine.toJson());
//   }

//   Future<void> updateMedicine(Medicine medicine) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('medicines')
//         .doc(medicine.medId);

//     await docRef.update(medicine.toJson());
//   }

//   Future<void> deleteMedicine(String medId) async {
//     DocumentReference docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('medicines')
//         .doc(medId);

//     await docRef.delete();
//   }
// }
