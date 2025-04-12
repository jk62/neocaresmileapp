class Condition {
  final String conditionId;
  final String conditionName;
  final List<int> toothTable1; // Flattened list of tooth numbers
  final List<int> toothTable2;
  final List<int> toothTable3;
  final List<int> toothTable4;
  final String doctorNote;
  final bool isToothTable; // New field to indicate if toothTable is applicable

  Condition({
    required this.conditionId,
    required this.conditionName,
    required this.toothTable1,
    required this.toothTable2,
    required this.toothTable3,
    required this.toothTable4,
    this.doctorNote = '',
    this.isToothTable =
        true, // Default to true, assuming most conditions are tooth-specific
  });

  Map<String, dynamic> toJson() {
    return {
      'conditionId': conditionId,
      'conditionName': conditionName,
      'toothTable1': toothTable1,
      'toothTable2': toothTable2,
      'toothTable3': toothTable3,
      'toothTable4': toothTable4,
      'doctorNote': doctorNote,
      'isToothTable': isToothTable, // Include the new field in the map
    };
  }

  factory Condition.fromJson(Map<String, dynamic> json) {
    List<int> flatToothTable1 =
        json['toothTable1'] != null ? List<int>.from(json['toothTable1']) : [];
    List<int> flatToothTable2 =
        json['toothTable2'] != null ? List<int>.from(json['toothTable2']) : [];
    List<int> flatToothTable3 =
        json['toothTable3'] != null ? List<int>.from(json['toothTable3']) : [];
    List<int> flatToothTable4 =
        json['toothTable4'] != null ? List<int>.from(json['toothTable4']) : [];

    return Condition(
      conditionId: json['conditionId'],
      conditionName: json['conditionName'],
      toothTable1: flatToothTable1,
      toothTable2: flatToothTable2,
      toothTable3: flatToothTable3,
      toothTable4: flatToothTable4,
      doctorNote: json['doctorNote'] ?? '',
      isToothTable: json['isToothTable'] ?? true, // Default to true if null
    );
  }

  @override
  String toString() {
    return 'Condition(conditionId: $conditionId, conditionName: $conditionName, toothTable1: $toothTable1,toothTable2: $toothTable2,toothTable3: $toothTable3,toothTable4: $toothTable4, doctorNote: $doctorNote, isToothTable: $isToothTable)';
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// code below stable single toothTable
// class Condition {
//   final String conditionId;
//   final String conditionName;
//   final List<int> toothTable; // Flattened list of tooth numbers
//   final String doctorNote;
//   final bool isToothTable; // New field to indicate if toothTable is applicable

//   Condition({
//     required this.conditionId,
//     required this.conditionName,
//     required this.toothTable,
//     this.doctorNote = '',
//     this.isToothTable =
//         true, // Default to true, assuming most conditions are tooth-specific
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'conditionId': conditionId,
//       'conditionName': conditionName,
//       'toothTable': toothTable, // Store as a single list
//       'doctorNote': doctorNote,
//       'isToothTable': isToothTable, // Include the new field in the map
//     };
//   }

//   factory Condition.fromJson(Map<String, dynamic> json) {
//     List<int> flatToothTable = List<int>.from(json['toothTable']);

//     return Condition(
//       conditionId: json['conditionId'],
//       conditionName: json['conditionName'],
//       toothTable: flatToothTable,
//       doctorNote: json['doctorNote'] ?? '',
//       isToothTable: json['isToothTable'] ??
//           true, // Handle null for backward compatibility
//     );
//   }

//   @override
//   String toString() {
//     return 'Condition(conditionId: $conditionId, conditionName: $conditionName, toothTable: $toothTable, doctorNote: $doctorNote, isToothTable: $isToothTable)';
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
