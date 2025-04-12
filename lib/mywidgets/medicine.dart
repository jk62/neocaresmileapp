// lib/medicine.dart

class Medicine {
  final String medId;
  final String medName;
  final String? composition;

  Medicine({
    required this.medId,
    required this.medName,
    required this.composition,
  });

  // Optionally, you can add factory methods for easy serialization/deserialization if needed
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      medId: json['medId'],
      medName: json['medName'],
      composition: json['composition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medId': medId,
      'medName': medName,
      'composition': composition,
    };
  }
}
