import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/clinic_setup_service.dart';
import 'dart:developer' as devtools show log;

class ReplicateConditionData extends StatefulWidget {
  final String? initialSourceClinicId;

  const ReplicateConditionData({super.key, this.initialSourceClinicId});

  @override
  State<ReplicateConditionData> createState() => _ReplicateConditionDataState();
}

class _ReplicateConditionDataState extends State<ReplicateConditionData> {
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
      await clinicSetupService.replicateConditionData(
        selectedSourceClinicId!,
        selectedTargetClinicId!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Condition data replicated successfully.')),
        );

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (error) {
      devtools.log('Error replicating condition data: $error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to replicate condition data.')),
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
        title: const Text('Replicate Condition Data'),
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
