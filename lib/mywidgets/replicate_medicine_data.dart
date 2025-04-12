import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/clinic_setup_service.dart';
import 'dart:developer' as devtools show log;

class ReplicateMedicineData extends StatefulWidget {
  final String? initialSourceClinicId;

  const ReplicateMedicineData({super.key, this.initialSourceClinicId});

  @override
  State<ReplicateMedicineData> createState() => _ReplicateMedicineDataState();
}

class _ReplicateMedicineDataState extends State<ReplicateMedicineData> {
  final ClinicSetupService clinicSetupService = ClinicSetupService();
  bool isLoading = false; // Track loading state for replication

  List<Map<String, String>> clinics = []; // Stores clinic names and IDs
  String? selectedSourceClinicId;
  String? selectedTargetClinicId;

  @override
  void initState() {
    super.initState();
    _loadClinics();
    selectedSourceClinicId =
        widget.initialSourceClinicId; // Set initial source clinic if provided
  }

  Future<void> _loadClinics() async {
    try {
      final fetchedClinics = await clinicSetupService.getClinics();
      setState(() {
        clinics = fetchedClinics;
      });
    } catch (error) {
      devtools.log('Error loading clinics: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load clinics.')),
      );
    }
  }

  Future<void> _startReplication() async {
    if (selectedSourceClinicId == null || selectedTargetClinicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both source and target clinics.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await clinicSetupService.replicateMedicineData(
        selectedSourceClinicId!,
        selectedTargetClinicId!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Medicine data replicated successfully.')),
        );

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (error) {
      devtools.log('Error replicating medicine data: $error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to replicate medicine data.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replicate Medicine Data'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedSourceClinicId,
                    hint: const Text('Select Source Clinic'),
                    items: clinics.map((clinic) {
                      return DropdownMenuItem(
                        value: clinic['id'],
                        child: Text(clinic['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSourceClinicId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedTargetClinicId,
                    hint: const Text('Select Target Clinic'),
                    items: clinics.map((clinic) {
                      return DropdownMenuItem(
                        value: clinic['id'],
                        child: Text(clinic['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTargetClinicId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _startReplication,
                    child: const Text('Start Replication'),
                  ),
                ],
              ),
      ),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/clinic_setup_service.dart';
// import 'dart:developer' as devtools show log;

// class ReplicateMedicineData extends StatefulWidget {
//   const ReplicateMedicineData({super.key});

//   @override
//   State<ReplicateMedicineData> createState() => _ReplicateMedicineDataState();
// }



// class _ReplicateMedicineDataState extends State<ReplicateMedicineData> {
//   final ClinicSetupService clinicSetupService = ClinicSetupService();
//   bool isLoading = false; // Track loading state for replication

//   List<Map<String, String>> clinics = []; // Stores clinic names and IDs
//   String? selectedSourceClinicId;
//   String? selectedTargetClinicId;

//   @override
//   void initState() {
//     super.initState();
//     _loadClinics(); // Load clinics when the widget initializes
//   }

//   Future<void> _loadClinics() async {
//     try {
//       final fetchedClinics = await clinicSetupService.getClinics();
//       setState(() {
//         clinics = fetchedClinics;
//       });
//     } catch (error) {
//       devtools.log('Error loading clinics: $error');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to load clinics.')),
//       );
//     }
//   }

//   Future<void> _startReplication() async {
//     if (selectedSourceClinicId == null || selectedTargetClinicId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please select both source and target clinics.')),
//       );
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       await clinicSetupService.replicateMedicineData(
//         selectedSourceClinicId!,
//         selectedTargetClinicId!,
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Medicine data replicated successfully.')),
//         );

//         await Future.delayed(const Duration(seconds: 2));

//         if (mounted) {
//           Navigator.of(context).pop();
//         }
//       }
//     } catch (error) {
//       devtools.log('Error replicating medicine data: $error');

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to replicate medicine data.')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Replicate Medicine Data'),
//       ),
//       body: Center(
//         child: isLoading
//             ? const CircularProgressIndicator()
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   DropdownButtonFormField<String>(
//                     value: selectedSourceClinicId,
//                     hint: const Text('Select Source Clinic'),
//                     items: clinics.map((clinic) {
//                       return DropdownMenuItem(
//                         value: clinic['id'],
//                         child: Text(clinic['name'] ?? ''),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedSourceClinicId = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   DropdownButtonFormField<String>(
//                     value: selectedTargetClinicId,
//                     hint: const Text('Select Target Clinic'),
//                     items: clinics.map((clinic) {
//                       return DropdownMenuItem(
//                         value: clinic['id'],
//                         child: Text(clinic['name'] ?? ''),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedTargetClinicId = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 32),
//                   ElevatedButton(
//                     onPressed: _startReplication,
//                     child: const Text('Start Replication'),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/clinic_setup_service.dart';
// import 'dart:developer' as devtools show log;

// class ReplicateMedicineData extends StatefulWidget {
//   const ReplicateMedicineData({super.key});

//   @override
//   State<ReplicateMedicineData> createState() => _ReplicateMedicineDataState();
// }

// class _ReplicateMedicineDataState extends State<ReplicateMedicineData> {
//   final String sourceClinicId = 's2b7F4N98Ad1PEycID1z';
//   final String targetClinicId = '8hW96TcML6quaZ00Dcfn';

//   final ClinicSetupService clinicSetupService = ClinicSetupService();
//   bool isLoading = false; // Track the loading state

//   Future<void> _startReplication() async {
//     setState(() {
//       isLoading = true; // Show loading indicator
//     });

//     try {
//       await clinicSetupService.replicateMedicineData(
//           sourceClinicId, targetClinicId);

//       if (mounted) {
//         // Show a success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Medicine data replicated successfully.')),
//         );

//         // Navigate back to the previous screen after a short delay
//         await Future.delayed(const Duration(seconds: 2));

//         if (mounted) {
//           // Ensure the widget is still mounted before navigating
//           Navigator.of(context).pop();
//         }
//       }
//     } catch (error) {
//       devtools.log('Error replicating medicine data: $error');

//       if (mounted) {
//         // Show an error message if replication fails
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to replicate medicine data.')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false; // Hide loading indicator
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Replicate Medicine Data'),
//       ),
//       body: Center(
//         child: isLoading
//             ? const CircularProgressIndicator() // Show loading indicator
//             : ElevatedButton(
//                 onPressed: _startReplication,
//                 child: const Text('Start Replication'),
//               ),
//       ),
//     );
//   }
// }

