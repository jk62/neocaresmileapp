import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as devtools show log;

import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';

class CreateSlots extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String clinicId;
  const CreateSlots({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
  });

  @override
  State<CreateSlots> createState() => _CreateSlotsState();
}

class _CreateSlotsState extends State<CreateSlots> {
  late String currentClinicId;
  Map<String, dynamic> availabilitySlotsData = {}; // Initialize as an empty map

  // @override
  // void initState() {
  //   super.initState();
  //   initializeAvailabilityData(); // Call the initialization method
  // }

  //------------------------------------//
  @override
  void initState() {
    super.initState();
    currentClinicId = widget.clinicId; // Initialize with the passed clinicId
    ClinicSelection.instance.addListener(_onClinicChanged);
    initializeAvailabilityData();
  }

  void _onClinicChanged() {
    setState(() {
      currentClinicId = ClinicSelection.instance.selectedClinicId;
      initializeAvailabilityData();
    });
  }

  @override
  void dispose() {
    ClinicSelection.instance.removeListener(_onClinicChanged);
    super.dispose();
  }

  //------------------------------------//

  void initializeAvailabilityData() {
    // Initialize the availabilitySlotsData map with your sample data
    // This could involve setting the initial slot data based on your requirements
    availabilitySlotsData = {
      'Monday': {
        'Morning': [
          {
            'slot': '9:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '9:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Afternoon': [
          {
            'slot': '3:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '3:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Evening': [
          {
            'slot': '7:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '7:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
      },
      'Tuesday': {
        'Morning': [
          {
            'slot': '9:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '9:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Afternoon': [
          {
            'slot': '3:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '3:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Evening': [
          {
            'slot': '7:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '7:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
      },
      'Wednesday': {
        'Morning': [
          {
            'slot': '9:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '9:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Afternoon': [
          {
            'slot': '3:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '3:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Evening': [
          {
            'slot': '7:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '7:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
      },
      'Thursday': {
        'Morning': [
          {
            'slot': '9:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '9:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Afternoon': [
          {
            'slot': '3:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '3:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Evening': [
          {
            'slot': '7:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '7:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
      },
      'Friday': {
        'Morning': [
          {
            'slot': '9:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '9:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Afternoon': [
          {
            'slot': '3:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '3:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Evening': [
          {
            'slot': '7:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '7:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
      },
      'Saturday': {
        'Morning': [
          {
            'slot': '9:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '9:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Afternoon': [
          {
            'slot': '3:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '3:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Evening': [
          {
            'slot': '7:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '7:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
      },
      'Sunday': {
        'Morning': [
          {
            'slot': '9:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '9:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '10:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:00 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '11:30 AM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Afternoon': [
          {
            'slot': '3:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '3:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '4:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
        'Evening': [
          {
            'slot': '7:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '7:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:00 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
          {
            'slot': '8:30 PM',
            'isBooked': false,
            'isDoctor': true,
            'isCancelled': false,
            'isSelected': false,
          },
        ],
      },
    };
  }

  // Future<void> _updateSelectedSlots(
  //     Map<String, dynamic> selectedSlotsData) async {
  //   int maxRetries = 3;
  //   int currentRetry = 0;

  //   //String docName = 'Dr ${widget.doctorName}';

  //   while (currentRetry < maxRetries) {
  //     try {
  //       DocumentReference clinicRef = FirebaseFirestore.instance
  //           .collection('clinics')
  //           .doc(widget.clinicId);

  //       await clinicRef
  //           .collection('availableSlots')
  //           //.doc(widget.doctorName)
  //           .doc('clinicSlots')
  //           .set(selectedSlotsData);

  //       devtools.log("Selected slots data updated successfully!");
  //       Navigator.pop(context); // Close the current screen
  //       break; // Success, exit the loop
  //     } catch (e) {
  //       currentRetry++;
  //       devtools.log("Error updating selected slots data: $e");
  //       await Future.delayed(const Duration(seconds: 1)); // Delay before retry
  //     }
  //   }
  // }

  Future<void> _updateSelectedSlots(
      Map<String, dynamic> selectedSlotsData) async {
    int maxRetries = 3;
    int currentRetry = 0;

    while (currentRetry < maxRetries) {
      try {
        DocumentReference clinicRef = FirebaseFirestore.instance
            .collection('clinics')
            .doc(currentClinicId);

        await clinicRef
            .collection('availableSlots')
            .doc('clinicSlots')
            .set(selectedSlotsData);

        devtools.log("Selected slots data updated successfully!");

        // Check if the widget is still mounted before popping the context
        if (mounted) {
          Navigator.pop(context); // Close the current screen
        }
        break; // Success, exit the loop
      } catch (e) {
        currentRetry++;
        devtools.log("Error updating selected slots data: $e");
        await Future.delayed(const Duration(seconds: 1)); // Delay before retry
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Availability Slots'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (availabilitySlotsData.isNotEmpty)
                  ..._buildAvailabilitySlots(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Selection'),
                content: const Text('Do you want to save the selected slots?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      _updateSelectedSlots(
                          availabilitySlotsData); // Push data to backend
                    },
                    child: const Text('Save'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          );
        },
        child: const Text('Select Slots'),
      ),
    );
  }

  List<Widget> _buildAvailabilitySlots() {
    List<Widget> slotWidgets = [];

    availabilitySlotsData.forEach((weekday, slotsData) {
      slotWidgets.add(Text(weekday));

      slotsData.forEach((slotType, slots) {
        List<Widget> slotWidgetsForType = [];
        slots.forEach((slot) {
          slotWidgetsForType.add(
            CheckboxListTile(
              title: Text(slot['slot']),
              value: slot['isSelected'] ?? false,
              onChanged: (bool? value) {
                setState(() {
                  slot['isSelected'] = value;
                });
              },
            ),
          );
        });

        slotWidgets.addAll(slotWidgetsForType);
      });
    });

    return slotWidgets;
  }
}
