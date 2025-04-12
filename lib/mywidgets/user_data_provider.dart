import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/add_empty_container.dart';
import 'dart:developer' as devtools show log;

class UserDataProvider extends ChangeNotifier {
  // String? chiefComplaint = '';
  // String? medicalHistory = '';
  // List<Map<String, dynamic>> oralExamination = [];
  // List<Map<String, dynamic>> procedures = [];
  // List<Map<String, dynamic>> pictures = [];

  // List<String> selectedProcedures = [];
  // List<AddEmptyContainerData> dynamicContainersData = [];

  // // New field to store deleted procedures
  // List<Map<String, dynamic>> deletedProcedures = [];

  // List<Map<String, dynamic>> prescriptions = [];

  //----------------------------------------------//
  String? _clinicId;
  String? chiefComplaint = '';
  String? medicalHistory = '';
  List<Map<String, dynamic>> oralExamination = [];
  List<Map<String, dynamic>> procedures = [];
  List<Map<String, dynamic>> pictures = [];
  List<String> selectedProcedures = [];
  List<AddEmptyContainerData> dynamicContainersData = [];
  List<Map<String, dynamic>> deletedProcedures = [];
  List<Map<String, dynamic>> prescriptions = [];
  //----------------------------------------------//
  /// Setter for `clinicId`
  void setClinicId(String clinicId) {
    if (_clinicId != clinicId) {
      devtools.log('Clinic ID changed to: $clinicId');
      _clinicId = clinicId;
      clearState();
      fetchDataForClinic(); // Fetch data specific to the new clinic
    }
  }

  String? get clinicId => _clinicId;

  // Fetch data specific to the clinic
  Future<void> fetchDataForClinic() async {
    devtools.log('Fetching data for clinic: $_clinicId');
    // Add your Firestore fetching logic here to load data specific to `_clinicId`
    notifyListeners();
  }

  // Method to clear state when clinic changes
  void clearState() {
    devtools.log('Clearing state for clinic $_clinicId');
    chiefComplaint = '';
    medicalHistory = '';
    oralExamination = [];
    procedures = [];
    selectedProcedures = [];
    dynamicContainersData = [];
    deletedProcedures = [];
    prescriptions = [];
    pictures = [];
    notifyListeners();
  }

  //----------------------------------------------//

  // void clearState() {
  //   devtools.log('clearState invoked. userData is cleared of its contents');
  //   chiefComplaint = '';
  //   medicalHistory = '';
  //   oralExamination = [];
  //   procedures = [];
  //   selectedProcedures = [];
  //   dynamicContainersData = [];
  //   deletedProcedures = []; // Clear deleted procedures as well
  //   prescriptions = [];
  //   pictures = [];
  //   notifyListeners(); // Notify listeners of the change
  // }
  //-----------------------------------------------------------------------//
  // New methods for data preservation
  bool hasSavedData() {
    return (selectedProcedures.isNotEmpty &&
            dynamicContainersData.isNotEmpty) ||
        (medicalHistory?.isNotEmpty ?? false);
  }

  Map<String, dynamic> getSavedData() {
    return {
      'selectedProcedures': selectedProcedures,
      'dynamicContainersData': dynamicContainersData,
      'medicalHistory': medicalHistory,
    };
  }

  void saveData(List<String> procedures, List<dynamic> containerData) {
    List<String> newSelectedProcedures = List<String>.from(procedures);
    List<AddEmptyContainerData> newDynamicContainersData =
        List<AddEmptyContainerData>.from(
            containerData.cast<AddEmptyContainerData>());

    selectedProcedures = newSelectedProcedures;
    dynamicContainersData = newDynamicContainersData;

    notifyListeners(); // Notify listeners of the change
  }

  void updateChiefComplaint(String? value) {
    chiefComplaint = value;
    _notifyListenersSafely(); // Notify listeners safely
  }

  void updateMedicalHistory(String? value) {
    medicalHistory = value;
    _notifyListenersSafely(); // Notify listeners safely
  }

  void addOralExamination(Map<String, dynamic> entry) {
    if (entry['conditionId'] == null) {
      devtools.log('Warning: conditionId is null in addOralExamination');
    } else {
      devtools
          .log('Adding condition with conditionId: ${entry['conditionId']}');
    }
    oralExamination.add(entry);
    _notifyListenersSafely(); // Notify listeners safely
  }

  void updateOralExamination(List<Map<String, dynamic>> newOralExamination) {
    oralExamination = newOralExamination;
    _notifyListenersSafely(); // Notify listeners safely
  }

  void addProcedure(Map<String, dynamic> procedure) {
    procedures.add(procedure);
    _notifyListenersSafely(); // Notify listeners safely
  }

  void updateProcedures(List<Map<String, dynamic>> newProcedures) {
    procedures = newProcedures;
    _notifyListenersSafely(); // Notify listeners safely
  }

  void addOrUpdateProcedure(Map<String, dynamic> procedure) {
    devtools.log(
        'This is coming from inside addOrUpdateProcedure defined in UserDataProvider.procedure is $procedure');

    if (!procedure.containsKey('isToothwise')) {
      devtools.log('Error: isToothwise is missing in procedure $procedure');
      throw ArgumentError('Missing isToothwise field in procedure');
    }

    final index = procedures
        .indexWhere((element) => element['procId'] == procedure['procId']);
    if (index != -1) {
      procedures[index] = procedure;
    } else {
      procedures.add(procedure);
    }

    _notifyListenersSafely(); // Notify listeners safely
  }

  void removeProcedure(String procName) {
    procedures.removeWhere((element) => element['procedureName'] == procName);
    _notifyListenersSafely(); // Notify listeners safely
  }

  List<String> getProcedures() {
    return procedures.map((procedure) {
      return procedure['procName'] as String;
    }).toList();
  }

  void _notifyListenersSafely() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void savePictures(List<Map<String, dynamic>> newPictures,
      [String context = '']) {
    pictures = newPictures;
    devtools
        .log('new picture added to userData is $pictures (Context: $context)');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void clearOralExamination() {
    oralExamination.clear();
    _notifyListenersSafely(); // Notify listeners safely
  }

  // ------------------------------------------------------------------------ //

  // Method to add or update prescription data
  void addOrUpdatePrescription(Map<String, dynamic> prescription) {
    final index =
        prescriptions.indexWhere((p) => p['medId'] == prescription['medId']);
    if (index != -1) {
      prescriptions[index] = prescription; // Update existing prescription
    } else {
      prescriptions.add(prescription); // Add new prescription
    }
    _notifyListenersSafely(); // Notify listeners
  }

  // void updatePrescriptions(List<Map<String, dynamic>> newPrescriptions) {
  //   prescriptions = newPrescriptions;
  //   _notifyListenersSafely(); // Notify listeners
  // }
  void updatePrescriptions(List<Map<String, dynamic>> newPrescriptions) {
    for (var prescription in newPrescriptions) {
      addOrUpdatePrescription(
          prescription); // Use the addOrUpdatePrescription method
    }
    _notifyListenersSafely(); // Notify listeners after updates
  }

  void clearPrescriptions() {
    prescriptions.clear();
    _notifyListenersSafely(); // Clear all prescriptions
  }
  // ------------------------------------------------------------------------ //

  // @override
  // String toString() {
  //   return 'UserDataProvider(chiefComplaint: $chiefComplaint, medicalHistory: $medicalHistory, oralExamination: $oralExamination, procedures: $procedures, pictures: $pictures, selectedProcedures: $selectedProcedures, dynamicContainersData: $dynamicContainersData, deletedProcedures: $deletedProcedures)';
  // }
  @override
  String toString() {
    return 'UserDataProvider('
        'chiefComplaint: $chiefComplaint, '
        'medicalHistory: $medicalHistory, '
        'oralExamination: $oralExamination, '
        'procedures: $procedures, '
        'pictures: $pictures, '
        'selectedProcedures: $selectedProcedures, '
        'dynamicContainersData: $dynamicContainersData, '
        'deletedProcedures: $deletedProcedures, '
        'prescriptions: $prescriptions' // Include prescription data
        ')';
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE BEFORE THE INTRODUCTION OF CHANGENOTIFIERPROXYPROVIDER
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/add_empty_container.dart';
// import 'dart:developer' as devtools show log;

// class UserDataProvider extends ChangeNotifier {
//   String? chiefComplaint = '';
//   String? medicalHistory = '';
//   List<Map<String, dynamic>> oralExamination = [];
//   List<Map<String, dynamic>> procedures = [];
//   List<Map<String, dynamic>> pictures = [];

//   List<String> selectedProcedures = [];
//   List<AddEmptyContainerData> dynamicContainersData = [];

//   // New field to store deleted procedures
//   List<Map<String, dynamic>> deletedProcedures = [];

//   List<Map<String, dynamic>> prescriptions = []; // Add this if not present

//   // New methods for data preservation
//   bool hasSavedData() {
//     return (selectedProcedures.isNotEmpty &&
//             dynamicContainersData.isNotEmpty) ||
//         (medicalHistory?.isNotEmpty ?? false);
//   }

//   Map<String, dynamic> getSavedData() {
//     return {
//       'selectedProcedures': selectedProcedures,
//       'dynamicContainersData': dynamicContainersData,
//       'medicalHistory': medicalHistory,
//     };
//   }

//   void saveData(List<String> procedures, List<dynamic> containerData) {
//     List<String> newSelectedProcedures = List<String>.from(procedures);
//     List<AddEmptyContainerData> newDynamicContainersData =
//         List<AddEmptyContainerData>.from(
//             containerData.cast<AddEmptyContainerData>());

//     selectedProcedures = newSelectedProcedures;
//     dynamicContainersData = newDynamicContainersData;

//     notifyListeners(); // Notify listeners of the change
//   }

//   void updateChiefComplaint(String? value) {
//     chiefComplaint = value;
//     _notifyListenersSafely(); // Notify listeners safely
//   }

//   void updateMedicalHistory(String? value) {
//     medicalHistory = value;
//     _notifyListenersSafely(); // Notify listeners safely
//   }

//   void addOralExamination(Map<String, dynamic> entry) {
//     if (entry['conditionId'] == null) {
//       devtools.log('Warning: conditionId is null in addOralExamination');
//     } else {
//       devtools
//           .log('Adding condition with conditionId: ${entry['conditionId']}');
//     }
//     oralExamination.add(entry);
//     _notifyListenersSafely(); // Notify listeners safely
//   }

//   void updateOralExamination(List<Map<String, dynamic>> newOralExamination) {
//     oralExamination = newOralExamination;
//     _notifyListenersSafely(); // Notify listeners safely
//   }

//   void addProcedure(Map<String, dynamic> procedure) {
//     procedures.add(procedure);
//     _notifyListenersSafely(); // Notify listeners safely
//   }

//   void updateProcedures(List<Map<String, dynamic>> newProcedures) {
//     procedures = newProcedures;
//     _notifyListenersSafely(); // Notify listeners safely
//   }

//   void addOrUpdateProcedure(Map<String, dynamic> procedure) {
//     devtools.log(
//         'This is coming from inside addOrUpdateProcedure defined in UserDataProvider.procedure is $procedure');

//     if (!procedure.containsKey('isToothwise')) {
//       devtools.log('Error: isToothwise is missing in procedure $procedure');
//       throw ArgumentError('Missing isToothwise field in procedure');
//     }

//     final index = procedures
//         .indexWhere((element) => element['procId'] == procedure['procId']);
//     if (index != -1) {
//       procedures[index] = procedure;
//     } else {
//       procedures.add(procedure);
//     }

//     _notifyListenersSafely(); // Notify listeners safely
//   }

//   void removeProcedure(String procName) {
//     procedures.removeWhere((element) => element['procedureName'] == procName);
//     _notifyListenersSafely(); // Notify listeners safely
//   }

//   List<String> getProcedures() {
//     return procedures.map((procedure) {
//       return procedure['procName'] as String;
//     }).toList();
//   }

//   void clearState() {
//     devtools.log('clearState invoked. userData is cleared of its contents');
//     chiefComplaint = '';
//     medicalHistory = '';
//     oralExamination = [];
//     procedures = [];
//     selectedProcedures = [];
//     dynamicContainersData = [];
//     deletedProcedures = []; // Clear deleted procedures as well
//     prescriptions = [];
//     pictures = [];
//     notifyListeners(); // Notify listeners of the change
//   }

//   void _notifyListenersSafely() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       notifyListeners();
//     });
//   }

//   void savePictures(List<Map<String, dynamic>> newPictures,
//       [String context = '']) {
//     pictures = newPictures;
//     devtools
//         .log('new picture added to userData is $pictures (Context: $context)');
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       notifyListeners();
//     });
//   }

//   void clearOralExamination() {
//     oralExamination.clear();
//     _notifyListenersSafely(); // Notify listeners safely
//   }

//   // ------------------------------------------------------------------------ //

//   // Method to add or update prescription data
//   void addOrUpdatePrescription(Map<String, dynamic> prescription) {
//     final index =
//         prescriptions.indexWhere((p) => p['medId'] == prescription['medId']);
//     if (index != -1) {
//       prescriptions[index] = prescription; // Update existing prescription
//     } else {
//       prescriptions.add(prescription); // Add new prescription
//     }
//     _notifyListenersSafely(); // Notify listeners
//   }

//   // void updatePrescriptions(List<Map<String, dynamic>> newPrescriptions) {
//   //   prescriptions = newPrescriptions;
//   //   _notifyListenersSafely(); // Notify listeners
//   // }
//   void updatePrescriptions(List<Map<String, dynamic>> newPrescriptions) {
//     for (var prescription in newPrescriptions) {
//       addOrUpdatePrescription(
//           prescription); // Use the addOrUpdatePrescription method
//     }
//     _notifyListenersSafely(); // Notify listeners after updates
//   }

//   void clearPrescriptions() {
//     prescriptions.clear();
//     _notifyListenersSafely(); // Clear all prescriptions
//   }
//   // ------------------------------------------------------------------------ //

//   // @override
//   // String toString() {
//   //   return 'UserDataProvider(chiefComplaint: $chiefComplaint, medicalHistory: $medicalHistory, oralExamination: $oralExamination, procedures: $procedures, pictures: $pictures, selectedProcedures: $selectedProcedures, dynamicContainersData: $dynamicContainersData, deletedProcedures: $deletedProcedures)';
//   // }
//   @override
//   String toString() {
//     return 'UserDataProvider('
//         'chiefComplaint: $chiefComplaint, '
//         'medicalHistory: $medicalHistory, '
//         'oralExamination: $oralExamination, '
//         'procedures: $procedures, '
//         'pictures: $pictures, '
//         'selectedProcedures: $selectedProcedures, '
//         'dynamicContainersData: $dynamicContainersData, '
//         'deletedProcedures: $deletedProcedures, '
//         'prescriptions: $prescriptions' // Include prescription data
//         ')';
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
