class MedicalCondition {
  final String medicalConditionId;
  final String medicalConditionName;

  final String doctorNote;

  MedicalCondition({
    required this.medicalConditionId,
    required this.medicalConditionName,
    this.doctorNote = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'medicalConditionId': medicalConditionId,
      'medicalConditionName': medicalConditionName,
      'doctorNote': doctorNote,
    };
  }

  factory MedicalCondition.fromJson(Map<String, dynamic> json) {
    return MedicalCondition(
      medicalConditionId: json['medicalConditionId'],
      medicalConditionName: json['medicalConditionName'],
      doctorNote: json['doctorNote'] ?? '',
    );
  }

  @override
  String toString() {
    return 'MedicalCondition(medicalConditionId: $medicalConditionId, medicalConditionName: $medicalConditionName,  doctorNote: $doctorNote, )';
  }
}
