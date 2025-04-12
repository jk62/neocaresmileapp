class Procedure {
  final String procId;
  final String procName;
  final double procFee;
  final List<int> toothTable1;
  final List<int> toothTable2;
  final List<int> toothTable3;
  final List<int> toothTable4;
  final String doctorNote;
  final bool isToothwise;

  Procedure({
    required this.procId,
    required this.procName,
    required this.procFee,
    required this.toothTable1,
    required this.toothTable2,
    required this.toothTable3,
    required this.toothTable4,
    this.doctorNote = '',
    this.isToothwise = false,
  });

  // Method to convert the Procedure object to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'procId': procId,
      'procName': procName,
      'procFee': procFee,
      'toothTable1': toothTable1,
      'toothTable2': toothTable2,
      'toothTable3': toothTable3,
      'toothTable4': toothTable4,
      'doctorNote': doctorNote,
      'isToothwise': isToothwise,
    };
  }

  // Method to calculate the total number of affected teeth
  // int totalToothCount() {
  //   return toothTable1.length +
  //       toothTable2.length +
  //       toothTable3.length +
  //       toothTable4.length;
  // }

  factory Procedure.fromMap(Map<String, dynamic> map) {
    return Procedure(
      procId: map['procId'],
      procName: map['procName'],
      procFee:
          map['procFee'] != null ? (map['procFee'] as num).toDouble() : 0.0,
      toothTable1:
          map['toothTable1'] != null ? List<int>.from(map['toothTable1']) : [],
      toothTable2:
          map['toothTable2'] != null ? List<int>.from(map['toothTable2']) : [],
      toothTable3:
          map['toothTable3'] != null ? List<int>.from(map['toothTable3']) : [],
      toothTable4:
          map['toothTable4'] != null ? List<int>.from(map['toothTable4']) : [],
      doctorNote: map['doctorNote'] ?? '',
      isToothwise: map['isToothwise'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Procedure(procId: $procId, procName: $procName, procFee: $procFee, toothTable1: $toothTable1, toothTable2: $toothTable2, toothTable3: $toothTable3, toothTable4: $toothTable4, doctorNote: $doctorNote, isToothwise: $isToothwise)';
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

// class Procedure {
//   final String procId;
//   final String procName;
//   final double procFee;
//   final List<int> toothTable1;
//   final List<int> toothTable2;
//   final List<int> toothTable3;
//   final List<int> toothTable4;
//   final String doctorNote;
//   final bool isToothwise;

//   Procedure({
//     required this.procId,
//     required this.procName,
//     required this.procFee,
//     required this.toothTable1,
//     required this.toothTable2,
//     required this.toothTable3,
//     required this.toothTable4,
//     this.doctorNote = '',
//     this.isToothwise = false,
//   });

//   // Method to calculate the total number of affected teeth
//   int totalToothCount() {
//     return toothTable1.length +
//         toothTable2.length +
//         toothTable3.length +
//         toothTable4.length;
//   }

//   factory Procedure.fromMap(Map<String, dynamic> map) {
//     return Procedure(
//       procId: map['procId'],
//       procName: map['procName'],
//       procFee:
//           map['procFee'] != null ? (map['procFee'] as num).toDouble() : 0.0,
//       toothTable1:
//           map['toothTable1'] != null ? List<int>.from(map['toothTable1']) : [],
//       toothTable2:
//           map['toothTable2'] != null ? List<int>.from(map['toothTable2']) : [],
//       toothTable3:
//           map['toothTable3'] != null ? List<int>.from(map['toothTable3']) : [],
//       toothTable4:
//           map['toothTable4'] != null ? List<int>.from(map['toothTable4']) : [],
//       doctorNote: map['doctorNote'] ?? '',
//       isToothwise: map['isToothwise'] ?? false,
//     );
//   }

//   @override
//   String toString() {
//     return 'Procedure(procId: $procId, procName: $procName, procFee: $procFee, toothTable1: $toothTable1, toothTable2: $toothTable2, toothTable3: $toothTable3, toothTable4: $toothTable4, doctorNote: $doctorNote, isToothwise: $isToothwise)';
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// class Procedure {
//   final String procId;
//   final String procName;
//   final double procFee;
//   final List<int> toothTable1;
//   final List<int> toothTable2;
//   final List<int> toothTable3;
//   final List<int> toothTable4;
//   final String doctorNote;
//   final bool isToothwise;
//   late int totalToothCount; // Declare the totalToothCount field

//   Procedure({
//     required this.procId,
//     required this.procName,
//     required this.procFee,
//     required this.toothTable1,
//     required this.toothTable2,
//     required this.toothTable3,
//     required this.toothTable4,
//     this.doctorNote = '',
//     this.isToothwise = false,
//   }) {
//     // Initialize the totalToothCount field
//     totalToothCount = _calculateTotalToothCount();
//   }

//   // Method to calculate the total number of affected teeth
//   int _calculateTotalToothCount() {
//     return toothTable1.length +
//         toothTable2.length +
//         toothTable3.length +
//         toothTable4.length;
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'procId': procId,
//       'procName': procName,
//       'procFee': procFee,
//       'toothTable1': toothTable1,
//       'toothTable2': toothTable2,
//       'toothTable3': toothTable3,
//       'toothTable4': toothTable4,
//       'doctorNote': doctorNote,
//       'isToothwise': isToothwise,
//       'totalToothCount': totalToothCount, // Include totalToothCount in the map
//     };
//   }

//   factory Procedure.fromMap(Map<String, dynamic> map) {
//     return Procedure(
//       procId: map['procId'],
//       procName: map['procName'],
//       procFee:
//           map['procFee'] != null ? (map['procFee'] as num).toDouble() : 0.0,
//       toothTable1:
//           map['toothTable1'] != null ? List<int>.from(map['toothTable1']) : [],
//       toothTable2:
//           map['toothTable2'] != null ? List<int>.from(map['toothTable2']) : [],
//       toothTable3:
//           map['toothTable3'] != null ? List<int>.from(map['toothTable3']) : [],
//       toothTable4:
//           map['toothTable4'] != null ? List<int>.from(map['toothTable4']) : [],
//       doctorNote: map['doctorNote'] ?? '',
//       isToothwise: map['isToothwise'] ?? false,
//     );
//   }

//   // Update the total tooth count when tooth tables are modified
//   void updateToothTables({
//     List<int>? newToothTable1,
//     List<int>? newToothTable2,
//     List<int>? newToothTable3,
//     List<int>? newToothTable4,
//   }) {
//     if (newToothTable1 != null) {
//       toothTable1.clear();
//       toothTable1.addAll(newToothTable1);
//     }
//     if (newToothTable2 != null) {
//       toothTable2.clear();
//       toothTable2.addAll(newToothTable2);
//     }
//     if (newToothTable3 != null) {
//       toothTable3.clear();
//       toothTable3.addAll(newToothTable3);
//     }
//     if (newToothTable4 != null) {
//       toothTable4.clear();
//       toothTable4.addAll(newToothTable4);
//     }

//     // Recalculate the total tooth count
//     totalToothCount = _calculateTotalToothCount();
//   }


//   @override
//   String toString() {
//     return 'Procedure(procId: $procId, procName: $procName, procFee: $procFee, toothTable1: $toothTable1, toothTable2: $toothTable2, toothTable3: $toothTable3, toothTable4: $toothTable4, doctorNote: $doctorNote, isToothwise: $isToothwise, totalToothCount: $totalToothCount)';
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// class Procedure {
//   final String procId;
//   final String procName;
//   final double procFee;
//   final List<int> toothTable1; // Flattened list of tooth numbers for quadrant 1
//   final List<int> toothTable2; // Flattened list of tooth numbers for quadrant 2
//   final List<int> toothTable3; // Flattened list of tooth numbers for quadrant 3
//   final List<int> toothTable4; // Flattened list of tooth numbers for quadrant 4
//   final String doctorNote;
//   final bool isToothwise;

//   Procedure({
//     required this.procId,
//     required this.procName,
//     required this.procFee,
//     required this.toothTable1, // Initialize the toothTable1
//     required this.toothTable2, // Initialize the toothTable2
//     required this.toothTable3, // Initialize the toothTable3
//     required this.toothTable4, // Initialize the toothTable4
//     this.doctorNote = '', // Default value for doctorNote
//     this.isToothwise = false, // Default value for isToothwise
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'procId': procId,
//       'procName': procName,
//       'procFee': procFee,
//       'toothTable1': toothTable1, // Store as a list of teeth for quadrant 1
//       'toothTable2': toothTable2, // Store as a list of teeth for quadrant 2
//       'toothTable3': toothTable3, // Store as a list of teeth for quadrant 3
//       'toothTable4': toothTable4, // Store as a list of teeth for quadrant 4
//       'doctorNote': doctorNote,
//       'isToothwise': isToothwise, // Include isToothwise in the map
//     };
//   }

//   // Method to calculate the total number of affected teeth
//   int totalToothCount() {
//     return toothTable1.length +
//         toothTable2.length +
//         toothTable3.length +
//         toothTable4.length;
//   }

//   factory Procedure.fromMap(Map<String, dynamic> map) {
//     return Procedure(
//       procId: map['procId'],
//       procName: map['procName'],
//       procFee: map['procFee'] != null
//           ? (map['procFee'] as num).toDouble()
//           : 0.0, // Handle null procFee
//       toothTable1: map['toothTable1'] != null
//           ? List<int>.from(map['toothTable1'])
//           : [], // Handle null or missing toothTable1
//       toothTable2: map['toothTable2'] != null
//           ? List<int>.from(map['toothTable2'])
//           : [], // Handle null or missing toothTable2
//       toothTable3: map['toothTable3'] != null
//           ? List<int>.from(map['toothTable3'])
//           : [], // Handle null or missing toothTable3
//       toothTable4: map['toothTable4'] != null
//           ? List<int>.from(map['toothTable4'])
//           : [], // Handle null or missing toothTable4
//       doctorNote: map['doctorNote'] ?? '', // Handle null doctorNote
//       isToothwise: map['isToothwise'] ?? false, // Handle null isToothwise
//     );
//   }

//   @override
//   String toString() {
//     return 'Procedure(procId: $procId, procName: $procName, procFee: $procFee, toothTable1: $toothTable1, toothTable2: $toothTable2, toothTable3: $toothTable3, toothTable4: $toothTable4, doctorNote: $doctorNote, isToothwise: $isToothwise)';
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// code below stable with single tooth table
// class Procedure {
//   final String procId;
//   final String procName;
//   final double procFee;
//   final List<int> toothTable; // Flattened list of tooth numbers
//   final String doctorNote;
//   final bool isToothwise;

//   Procedure({
//     required this.procId,
//     required this.procName,
//     required this.procFee,
//     required this.toothTable, // Initialize the toothTable
//     this.doctorNote = '', // Default value for doctorNote
//     this.isToothwise = false, // Default value for isToothwise
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'procId': procId,
//       'procName': procName,
//       'procFee': procFee,
//       'toothTable': toothTable, // Store as a single list
//       'doctorNote': doctorNote,
//       'isToothwise': isToothwise, // Include isToothwise in the map
//     };
//   }

  
//   factory Procedure.fromMap(Map<String, dynamic> map) {
//     // Safely retrieve affectedTeeth, which should be a subset of all teeth
//     List<int> affectedTeeth = map['affectedTeeth'] != null
//         ? List<int>.from(map['affectedTeeth'])
//         : [];

//     return Procedure(
//       procId: map['procId'],
//       procName: map['procName'],
//       procFee: map['procFee'] != null
//           ? (map['procFee'] as num).toDouble()
//           : 0.0, // Handle null procFee
//       toothTable: affectedTeeth, // Use affectedTeeth here
//       doctorNote: map['doctorNote'] ?? '', // Handle null doctorNote
//       isToothwise: map['isToothwise'] ?? false, // Handle null isToothwise
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
