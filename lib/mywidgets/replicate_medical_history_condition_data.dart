import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/clinic_setup_service.dart';
import 'dart:developer' as devtools show log;

class ReplicateMedicalHistoryConditionData extends StatefulWidget {
  final String? initialSourceClinicId;

  const ReplicateMedicalHistoryConditionData(
      {super.key, this.initialSourceClinicId});

  @override
  State<ReplicateMedicalHistoryConditionData> createState() =>
      _ReplicateMedicalHistoryConditionDataState();
}

class _ReplicateMedicalHistoryConditionDataState
    extends State<ReplicateMedicalHistoryConditionData> {
  final ClinicSetupService clinicSetupService = ClinicSetupService();
  bool isLoading = false; // Track loading state for replication

  List<Map<String, String>> clinics = []; // Stores clinic names and IDs
  String? selectedSourceClinicId;
  String? selectedTargetClinicId;

  @override
  void initState() {
    super.initState();
    _loadClinics();
    selectedSourceClinicId = widget.initialSourceClinicId;
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
      await clinicSetupService.replicateMedicalHistoryConditionData(
        selectedSourceClinicId!,
        selectedTargetClinicId!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Medical history conditions replicated successfully.')),
        );

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (error) {
      devtools.log('Error replicating medical history conditions: $error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to replicate medical history conditions.')),
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
        title: const Text('Replicate Medical History Conditions'),
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
