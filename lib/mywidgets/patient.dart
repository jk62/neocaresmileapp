class Patient {
  final String patientId;
  final int age;
  final String gender;
  final String patientName;
  final String patientMobileNumber;
  final String? patientPicUrl;
  final String? uhid;
  final String? clinicId;
  final String? doctorId;
  final int searchCount;

  Patient({
    required this.patientId,
    required this.age,
    required this.gender,
    required this.patientName,
    required this.patientMobileNumber,
    this.patientPicUrl,
    this.uhid,
    this.clinicId,
    this.doctorId,
    required this.searchCount,
  });

  // Factory method to create a Patient object from a map (existing)
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patientId'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      patientName: json['patientName'] ?? '',
      patientMobileNumber: json['patientMobileNumber'] ?? '',
      patientPicUrl: json['patientPicUrl'],
      uhid: json['uhid'],
      clinicId: json['clinicId'],
      doctorId: json['doctorId'],
      searchCount: json['searchCount'] ?? 0,
    );
  }

  // Method to convert Patient object to a map
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'age': age,
      'gender': gender,
      'patientName': patientName,
      'patientMobileNumber': patientMobileNumber,
      'patientPicUrl': patientPicUrl,
      'uhid': uhid,
      'clinicId': clinicId,
      'doctorId': doctorId,
      'searchCount': searchCount,
    };
  }

  @override
  String toString() {
    return 'Patient ID: $patientId, Name: $patientName, Age: $age, Gender: $gender, Mobile Number: $patientMobileNumber, Search Count: $searchCount';
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

// class Patient {
//   final String patientId;
//   final int age;
//   final String gender;
//   final String patientName;
//   final String patientMobileNumber;
//   final String? patientPicUrl;
//   final String? uhid;
//   final String? clinicId;
//   final String? doctorId;
//   final int searchCount;

//   Patient({
//     required this.patientId,
//     required this.age,
//     required this.gender,
//     required this.patientName,
//     required this.patientMobileNumber,
//     required this.patientPicUrl,
//     required this.uhid,
//     required this.clinicId,
//     required this.doctorId,
//     required this.searchCount,
//   });

//   factory Patient.fromJson(Map<String, dynamic> json) {
//     return Patient(
//       patientId: json['patientId'] ?? '',
//       age: json['age'] ?? 0,
//       gender: json['gender'] ?? '',
//       patientName: json['patientName'] ?? '',
//       patientMobileNumber: json['patientMobileNumber'] ?? '',
//       patientPicUrl: json['patientPicUrl'],
//       uhid: json['uhid'],
//       clinicId: json['clinicId'],
//       doctorId: json['doctorId'],
//       searchCount: json['searchCount'] ?? 0,
//     );
//   }

//   @override
//   String toString() {
//     return 'Patient ID: $patientId, Name: $patientName, Age: $age, Gender: $gender, Mobile Number: $patientMobileNumber, Search Count: $searchCount';
//   }
// }





// class Patient {
//   final String patientId;
//   final int age;
//   final String gender;
//   final String patientName;
//   final String patientMobileNumber;
//   final String? patientPicUrl;
//   final String? uhid;
//   final String? clinicId;
//   final String? doctorId;
//   final int searchCount;

//   Patient({
//     required this.patientId,
//     required this.age,
//     required this.gender,
//     required this.patientName,
//     required this.patientMobileNumber,
//     required this.patientPicUrl,
//     required this.uhid,
//     required this.clinicId,
//     required this.doctorId,
//     required this.searchCount,
//   });

//   @override
//   String toString() {
//     return 'Patient ID: $patientId, Name: $patientName, Age: $age, Gender: $gender, Mobile Number: $patientMobileNumber, Search Count: $searchCount';
//   }
// }

// class Patient {
//   final String patientId;
//   final int age;
//   final String gender;
//   final String patientName;
//   final String patientMobileNumber;
//   final String? patientPicUrl;
//   final String? uhid;
//   final String? clinicId;
//   final String? doctorId;
//   final int searchCount;

//   Patient({
//     required this.patientId,
//     required this.age,
//     required this.gender,
//     required this.patientName,
//     required this.patientMobileNumber,
//     required this.patientPicUrl,
//     required this.uhid,
//     required this.clinicId,
//     required this.doctorId,
//     required this.searchCount,
//   });
// }
