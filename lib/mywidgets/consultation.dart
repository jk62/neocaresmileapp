class Consultation {
  final String consultationId;
  final String doctorId;
  final String doctorName;
  final double consultationFee;

  Consultation({
    required this.consultationId,
    required this.doctorId,
    required this.doctorName,
    required this.consultationFee,
  });

  // Factory method for deserialization
  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      consultationId: json['consultationId'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      consultationFee: json['consultationFee'],
    );
  }

  // Method for serialization
  Map<String, dynamic> toJson() {
    return {
      'consultationId': consultationId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'consultationFee': consultationFee,
    };
  }
}
