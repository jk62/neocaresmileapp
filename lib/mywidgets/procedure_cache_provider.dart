import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class ProcedureCacheProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _selectedProcedures = [];
  String? _clinicId;

  // Return an unmodifiable list of selected procedures
  List<Map<String, dynamic>> get selectedProcedures =>
      List.unmodifiable(_selectedProcedures);

  //--------------------------------------------//
  // Method to set the clinic ID dynamically
  void setClinicId(String clinicId) {
    if (_clinicId != clinicId) {
      _clinicId = clinicId;
      devtools.log('Clinic ID changed to: $_clinicId');
      clearProcedures(); // Clear procedures when the clinic changes
      notifyListeners();
    }
  }

  //--------------------------------------------//

  // Add or update procedure logic
  void addProcedure(Map<String, dynamic> procedure) {
    // Find the index of the existing procedure if it exists
    final index = _selectedProcedures.indexWhere(
      (existingProcedure) =>
          existingProcedure['procId'] == procedure['procId'] ||
          existingProcedure['procName'] == procedure['procName'],
    );

    if (index != -1) {
      // Merge the existing procedure with the new data
      _selectedProcedures[index] = {
        ..._selectedProcedures[index],
        ...procedure,
      };
    } else {
      // Add new procedure if it doesn't exist
      _selectedProcedures.add(procedure);
    }

    // Defer the notifyListeners call to the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Remove procedure by its ID
  void removeProcedure(String procId) {
    _selectedProcedures
        .removeWhere((procedure) => procedure['procId'] == procId);
    notifyListeners();
  }

  // Clear all procedures
  void clearProcedures() {
    devtools.log('clearProcedures invoked. procedureCache cleared');
    _selectedProcedures.clear();
    notifyListeners();
  }

  // Update an existing procedure by index
  void updateProcedure(int index, Map<String, dynamic> updatedProcedure) {
    if (index >= 0 && index < _selectedProcedures.length) {
      _selectedProcedures[index] = {
        ..._selectedProcedures[index],
        ...updatedProcedure,
      };
      // Log the update for debugging
      devtools.log(
          'Procedure at index $index updated: $_selectedProcedures[index]');

      notifyListeners();
    } else {
      devtools.log('Invalid index for updateProcedure: $index');
    }
  }
}


// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW STABLE BEFORE INTRODUCTION OF CHANGENOTIFIERPROXYPROVIDER
// import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

// class ProcedureCacheProvider extends ChangeNotifier {
//   final List<Map<String, dynamic>> _selectedProcedures = [];

//   // Return an unmodifiable list of selected procedures
//   List<Map<String, dynamic>> get selectedProcedures =>
//       List.unmodifiable(_selectedProcedures);

//   // Add or update procedure logic
//   void addProcedure(Map<String, dynamic> procedure) {
//     // Find the index of the existing procedure if it exists
//     final index = _selectedProcedures.indexWhere(
//       (existingProcedure) =>
//           existingProcedure['procId'] == procedure['procId'] ||
//           existingProcedure['procName'] == procedure['procName'],
//     );

//     if (index != -1) {
//       // Merge the existing procedure with the new data
//       _selectedProcedures[index] = {
//         ..._selectedProcedures[index],
//         ...procedure,
//       };
//     } else {
//       // Add new procedure if it doesn't exist
//       _selectedProcedures.add(procedure);
//     }

//     // Defer the notifyListeners call to the next frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       notifyListeners();
//     });
//   }

//   // void addProcedure(Map<String, dynamic> procedure) {
//   //   final index = _selectedProcedures.indexWhere(
//   //     (existingProcedure) =>
//   //         existingProcedure['procId'] == procedure['procId'] ||
//   //         existingProcedure['procName'] == procedure['procName'],
//   //   );

//   //   if (index != -1) {
//   //     _selectedProcedures[index] = {
//   //       ..._selectedProcedures[index],
//   //       ...procedure,
//   //     };
//   //   } else {
//   //     _selectedProcedures.add(procedure);
//   //   }

//   //   // Immediately notify listeners without deferring
//   //   notifyListeners();
//   // }

//   // Remove procedure by its ID
//   void removeProcedure(String procId) {
//     _selectedProcedures
//         .removeWhere((procedure) => procedure['procId'] == procId);
//     notifyListeners();
//   }

//   // Clear all procedures
//   void clearProcedures() {
//     devtools.log('clearProcedures invoked. procedureCache cleared');
//     _selectedProcedures.clear();
//     notifyListeners();
//   }

//   // Update an existing procedure by index
//   void updateProcedure(int index, Map<String, dynamic> updatedProcedure) {
//     if (index >= 0 && index < _selectedProcedures.length) {
//       _selectedProcedures[index] = {
//         ..._selectedProcedures[index],
//         ...updatedProcedure,
//       };
//       // Log the update for debugging
//       devtools.log(
//           'Procedure at index $index updated: $_selectedProcedures[index]');

//       notifyListeners();
//     } else {
//       devtools.log('Invalid index for updateProcedure: $index');
//     }
//   }
// }

