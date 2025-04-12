class PreDefinedCourse {
  final String id;
  final String name;
  final List<Map<String, dynamic>> medicines;

  PreDefinedCourse({
    required this.id,
    required this.name,
    required this.medicines,
  });

  // Convert a PreDefinedCourse instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'medicines': medicines,
    };
  }

  // Create a PreDefinedCourse instance from a Map
  factory PreDefinedCourse.fromJson(Map<String, dynamic> json) {
    return PreDefinedCourse(
      id: json['id'],
      name: json['name'],
      medicines: List<Map<String, dynamic>>.from(json['medicines']),
    );
  }
}
