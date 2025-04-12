import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as devtools show log;

class ManageSlots extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String clinicId;
  const ManageSlots({
    super.key,
    required this.doctorId,
    required this.clinicId,
    required this.doctorName,
  });

  @override
  State<ManageSlots> createState() => _ManageSlotsState();
}

class _ManageSlotsState extends State<ManageSlots> {
  // ... (existing code for availableSlots and _finalizedSlots)
  // Sample data for available slots
  Map<String, Map<String, List<String>>> availableSlots = {
    'Monday': {
      'Morning': ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM'],
      'Afternoon': ['3:00 PM', '4:00 PM', '5:00 PM'],
      'Evening': ['7:00 PM', '8:00 PM', '9:00 PM'],
    },
    'Tuesday': {
      'Morning': ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM'],
      'Afternoon': ['3:00 PM', '4:00 PM', '5:00 PM'],
      'Evening': ['7:00 PM', '8:00 PM', '9:00 PM'],
    },
    'Wednesday': {
      'Morning': ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM'],
      'Afternoon': ['3:00 PM', '4:00 PM', '5:00 PM'],
      'Evening': ['7:00 PM', '8:00 PM', '9:00 PM'],
    },
    'Thursday': {
      'Morning': ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM'],
      'Afternoon': ['3:00 PM', '4:00 PM', '5:00 PM'],
      'Evening': ['7:00 PM', '8:00 PM', '9:00 PM'],
    },
    'Friday': {
      'Morning': ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM'],
      'Afternoon': ['3:00 PM', '4:00 PM', '5:00 PM'],
      'Evening': ['7:00 PM', '8:00 PM', '9:00 PM'],
    },
    'Saturday': {
      'Morning': ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM'],
      'Afternoon': ['3:00 PM', '4:00 PM', '5:00 PM'],
      'Evening': ['7:00 PM', '8:00 PM', '9:00 PM'],
    },
    'Sunday': {
      'Morning': ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM'],
      'Afternoon': ['3:00 PM', '4:00 PM', '5:00 PM'],
      'Evening': ['7:00 PM', '8:00 PM', '9:00 PM'],
    },
  };

  final Map<String, Map<String, List<String>>> _finalizedSlots = {};

  void _updateFinalizedSlots(
      String day, String timePeriod, String timeSlot, bool isSelected) {
    if (!_finalizedSlots.containsKey(day)) {
      _finalizedSlots[day] = {};
    }

    if (isSelected) {
      if (!_finalizedSlots[day]!.containsKey(timePeriod)) {
        _finalizedSlots[day]![timePeriod] = [];
      }
      _finalizedSlots[day]![timePeriod]!.add(timeSlot);
    } else {
      _finalizedSlots[day]![timePeriod]?.remove(timeSlot);
    }
  }

  void _finalizeAndPushSlots(
    Map<String, Map<String, List<String>>> finalizedSlots,
  ) {
    FirebaseFirestore.instance
        .collection('clinics')
        .doc(widget.clinicId)
        .collection('availableSlots')
        .doc(widget.doctorName)
        .set(finalizedSlots)
        .then((value) {
      devtools.log('Finalized slots pushed to Firestore.');
      _updateSlotStatus(); // Call the function to update sub-collections, date documents, and slot documents

      Navigator.pop(context);
    }).catchError((error) {
      devtools.log('Error pushing finalized slots to Firestore: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Available Slots'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (int index = 0; index < availableSlots.length; index++)
              _buildExpansionTile(index),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _finalizeAndPushSlots(
            _finalizedSlots,
          );
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildExpansionTile(int index) {
    String day = availableSlots.keys.toList()[index];
    Map<String, List<String>> slotsByTime = availableSlots[day]!;

    return Card(
      child: ExpansionTile(
        title: Text(day),
        children: [
          _buildTimePeriodExpansionTile(slotsByTime, 'Morning', day),
          _buildTimePeriodExpansionTile(slotsByTime, 'Afternoon', day),
          _buildTimePeriodExpansionTile(slotsByTime, 'Evening', day),
        ],
      ),
    );
  }

  Widget _buildTimePeriodExpansionTile(
      Map<String, List<String>> slotsByTime, String timePeriod, String day) {
    List<String>? slots = slotsByTime[timePeriod];

    if (slots == null || slots.isEmpty) {
      return Container();
    }

    return ExpansionTile(
      title: Text(timePeriod),
      children: [
        _buildTimeSlotsList(slots, timePeriod, day),
      ],
    );
  }

  Widget _buildTimeSlotsList(
      List<String> slots, String timePeriod, String day) {
    return Container(
      height: 150, // Adjust the height as needed

      child: ListView.builder(
        shrinkWrap: true,
        itemCount: slots.length,
        itemBuilder: (context, index) {
          String slot = slots[index];
          bool isSelected = _finalizedSlots.containsKey(day) &&
              _finalizedSlots[day]!.containsKey(timePeriod) &&
              _finalizedSlots[day]![timePeriod]!.contains(slot);

          return StatefulBuilder(
            builder: (context, setState) {
              return CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    isSelected = value ?? false;
                    _updateFinalizedSlots(day, timePeriod, slot, isSelected);
                  });
                },
                title: Text(slot),
                subtitle: Text(timePeriod),
              );
            },
          );
        },
      ),
    );
  }

  void _updateSlotStatus() async {
    // Get the days of the week
    List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    try {
      // Iterate through each day of the week
      for (String day in daysOfWeek) {
        devtools.log('Creating documents for day: $day');
        // Reference to the weekday's document
        DocumentReference dayDocumentRef = FirebaseFirestore.instance
            .collection('clinics')
            .doc(widget.clinicId)
            .collection('availableSlots')
            .doc(day)
            .collection(widget.doctorName) // Sub-collection under doctorName
            .doc(_getFormattedDate(
                day)); // Use formatted date as the document ID

        // Create the 'slots' sub-collection under the date document
        CollectionReference slotsCollectionRef =
            dayDocumentRef.collection('slots');

        // Clear the existing slots sub-collection
        QuerySnapshot existingSlotsSnapshot = await slotsCollectionRef.get();
        for (QueryDocumentSnapshot slotDocument in existingSlotsSnapshot.docs) {
          await slotDocument.reference.delete();
        }

        // Get the list of slots for the day
        Map<String, List<String>> slotsByTime = _finalizedSlots[day] ?? {};

        for (String timePeriod in slotsByTime.keys) {
          for (String slot in slotsByTime[timePeriod]!) {
            // Create the slot document with time slot as the document ID
            DocumentReference slotDocumentRef = slotsCollectionRef.doc(slot);
            await slotDocumentRef.set({
              'isBooked': false, // Set initial booked status to false
            });
          }
        }

        devtools.log(
            'Replaced subcollection, slots, and slot documents for doctor ${widget.doctorName} on $day');
        devtools.log('Finished creating documents for day: $day');
      }

      devtools.log(
          'Sub-collections, slots, and slot documents replaced for doctor: ${widget.doctorName}');
      devtools.log('Finished creating weekday documents for all days.');
    } catch (error) {
      devtools.log(
          'Error replacing sub-collections, slots, and slot documents: $error');
    }
  }

  String _getFormattedDate(String day) {
    DateTime now = DateTime.now();
    DateTime weekdayDate = now.add(Duration(days: _getDaysUntilWeekday(day)));
    return DateFormat('MMMM d').format(weekdayDate);
  }

  int _getDaysUntilWeekday(String targetWeekday) {
    int currentWeekday = DateTime.now().weekday;
    int targetWeekdayIndex = _getWeekdayIndex(targetWeekday);

    if (targetWeekdayIndex >= currentWeekday) {
      return targetWeekdayIndex - currentWeekday;
    } else {
      return 7 - (currentWeekday - targetWeekdayIndex);
    }
  }

  int _getWeekdayIndex(String weekday) {
    return DateTime.now()
        .subtract(
            Duration(days: DateTime.now().weekday - _getWeekdayNumber(weekday)))
        .weekday;
  }

  int _getWeekdayNumber(String weekday) {
    switch (weekday) {
      case 'Sunday':
        return 7;
      case 'Monday':
        return 1;
      case 'Tuesday':
        return 2;
      case 'Wednesday':
        return 3;
      case 'Thursday':
        return 4;
      case 'Friday':
        return 5;
      case 'Saturday':
        return 6;
      default:
        return 0;
    }
  }

  // ... (existing functions for _updateFinalizedSlots and _finalizeAndPushSlots)
}
