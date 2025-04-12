class PrescriptionData {
  final String prescriptionId;
  final DateTime prescriptionDate;
  final List<Map<String, dynamic>> medicines;

  PrescriptionData({
    required this.prescriptionId,
    required this.prescriptionDate,
    required this.medicines,
  });
}
