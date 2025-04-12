import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/firestore/appointment_service.dart';

import 'dart:developer' as devtools show log;

typedef SlotSelectionCallback = void Function(String date, String day,
    String slot, String selectedSlot); // Add selectedSlot

class FetchAvailableSlots extends StatefulWidget {
  final String doctorId;
  final String clinicId;
  final String doctorName;
  final Function(bool) toggleAvailableSlots;
  final String selectedSlot;
  final SlotSelectionCallback onSlotSelected;
  final String selectedDate; // Add this parameter

  const FetchAvailableSlots({
    super.key,
    required this.doctorId,
    required this.clinicId,
    required this.doctorName,
    required this.toggleAvailableSlots,
    required this.selectedSlot,
    required this.onSlotSelected,
    required this.selectedDate,
  });

  // @override
  // State<FetchAvailableSlots> createState() =>
  //     _FetchAvailableSlotsState(selectedDate: selectedDate, selectedSlot: '');
  @override
  State<FetchAvailableSlots> createState() => _FetchAvailableSlotsState();
}

class _FetchAvailableSlotsState extends State<FetchAvailableSlots> {
  // Add your implementation for the Create Appointment Widget here.
  Map<String, dynamic> _availableSlots = {}; // Store the fetched slots here
  //Set<int> _tappedIndices = {};
  String?
      tappedWeekday; // Store the tapped weekday here// Keep track of tapped container indices
  String? selectedWeekday;

  Map<String, List<String>> daySlots = {};
  // String selectedDate;
  // String selectedSlot; // Add this

  // _FetchAvailableSlotsState({
  //   required this.selectedDate,
  //   required this.selectedSlot,
  // }) {
  //   // Set a default value for selectedDate if it's empty
  //   if (selectedDate.isEmpty) {
  //     selectedDate = _getCurrentDate();
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   print("clinicId: ${widget.clinicId}, doctorId: ${widget.doctorId}");
  //   selectedWeekday = DateFormat('EEEE').format(DateTime.now());
  //   _fetchSlots(); // Fetch the slots when the widget is initialized
  // }

  late String selectedDate;
  late String selectedSlot;

  @override
  void initState() {
    super.initState();

    // Set a default value for selectedDate if it's empty
    if (widget.selectedDate.isEmpty) {
      setState(() {
        selectedDate = _getCurrentDate();
      });
    } else {
      setState(() {
        selectedDate = widget.selectedDate;
      });
    }

    // Fetch the available slots when the widget is initialized
    _fetchSlots();
  }

  String _getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM d, EEEE').format(now);
    return formattedDate;
  }

  Future<void> _fetchSlots() async {
    try {
      Map<String, dynamic> slotsData = await AppointmentService().fetchSlots(
        doctorName: widget.doctorName,
        clinicId: widget.clinicId,
      );

      // Reorder the slots within each day
      Map<String, dynamic> updatedSlotsData = {};
      slotsData.forEach((day, daySlots) {
        // Define your desired order for Morning, Afternoon, Evening
        List<String> desiredOrder = ['Morning', 'Afternoon', 'Evening'];

        // Create a list of slot types sorted by desired order
        List<String> sortedSlots = daySlots.keys.toList()
          ..sort((a, b) =>
              desiredOrder.indexOf(a).compareTo(desiredOrder.indexOf(b)));

        // Create a new map with sorted slot types
        Map<String, List<String>> sortedDaySlots = {};
        for (String slotType in sortedSlots) {
          sortedDaySlots[slotType] = daySlots[slotType];
        }

        // Update the slots for the current day in the updated map
        updatedSlotsData[day] = sortedDaySlots;
      });

      devtools
          .log("Slots data: $updatedSlotsData"); // Print the fetched slots data

      setState(() {
        _availableSlots =
            updatedSlotsData; // Update the state with fetched slots
        // Notify Widget100 to show available slots
        widget.toggleAvailableSlots(true);
      });
    } catch (e) {
      devtools.log("Error fetching slots: $e");
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    devtools.log(
        'This is coming from inside the build widget of FetchAvailableSlots');
    String timeSlotFromWeekday() {
      // Replace this with your actual logic
      // For example, you could return the first time slot for the selected day and slot type
      if (selectedWeekday != null) {
        if (daySlots.containsKey(selectedWeekday)) {
          List<String> timeSlots = daySlots[selectedWeekday]!;
          if (timeSlots.isNotEmpty) {
            return timeSlots.first;
          }
        }
      }
      return '';
    }

    String currentDate = _getCurrentDate();
    String currentWeekday = DateFormat('EEEE').format(DateTime.now());

    // Define the order of weekdays starting from the current weekday
    List<Map<String, String>> weekdaysOrder = [
      {
        'weekday': currentWeekday,
        'date': DateFormat('d').format(DateTime.now()),
      },
      for (int i = 1; i <= 6; i++)
        {
          'weekday':
              DateFormat('EEEE').format(DateTime.now().add(Duration(days: i))),
          'date': DateFormat('d').format(DateTime.now().add(Duration(days: i))),
        },
    ];

    // Create a list of weekdays based on the order defined above
    List<String> weekdays = weekdaysOrder
        .where((weekdayData) =>
            _availableSlots.containsKey(weekdayData['weekday']))
        .map((weekdayData) => weekdayData['weekday']!)
        .toList();

    // Create a list of dates based on the order defined above
    List<String> dates = weekdaysOrder
        .where((weekdayData) =>
            _availableSlots.containsKey(weekdayData['weekday']))
        .map((weekdayData) => weekdayData['date']!)
        .toList();

    // Split weekdays and dates into two lists for two rows
    List<String> weekdaysRow1 =
        weekdays.length >= 4 ? weekdays.sublist(0, 4) : [];
    List<String> weekdaysRow2 = weekdays.length >= 4 ? weekdays.sublist(4) : [];
    List<String> datesRow1 = dates.length >= 4 ? dates.sublist(0, 4) : [];
    List<String> datesRow2 = dates.length >= 4 ? dates.sublist(4) : [];

    // Track the index of the selected container
    int selectedIndex = -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Available Slots',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    currentDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              const SizedBox(height: 8),
              const Divider(
                thickness: 3,
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < weekdaysRow1.length; i++)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = i;
                          selectedWeekday =
                              weekdaysRow1[i]; // Capture the tapped weekday
                          daySlots = _availableSlots[
                              selectedWeekday!]; // Update daySlots
                          //selectedDate = '${datesRow1[i]}, ${weekdaysRow1[i]}';
                          selectedDate = DateFormat('MMMM d, EEEE')
                              .format(DateTime.now().add(Duration(days: i)));
                        });
                        String selectedSlotType = timeSlotFromWeekday();

                        widget.onSlotSelected(
                          datesRow1[i],
                          selectedWeekday!,
                          selectedSlotType,
                          widget.selectedSlot,
                        );
                        // Add the print statement here
                        devtools.log(
                            "This is coming from inside onTap of first Row FetchAvailableSlots");
                        devtools.log(" Selected Slot: $selectedSlotType");
                      },
                      child: Container(
                        height: 70,
                        width: 70,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          border: Border.all(width: 1),
                          color: selectedIndex == i
                              ? Colors
                                  .red // Change the color for the selected container
                              : (weekdaysRow1[i] == currentWeekday
                                  ? Colors.teal[400]
                                  : Colors.teal[100]),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              weekdaysRow1[i].substring(0, 3),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              datesRow1[i],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < weekdaysRow2.length; i++)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = i + weekdaysRow1.length;
                          selectedWeekday =
                              weekdaysRow2[i]; // Capture the tapped weekday
                          daySlots = _availableSlots[
                              selectedWeekday!]; // Update daySlots
                          //selectedDate = '${datesRow2[i]}, ${weekdaysRow2[i]}';
                          selectedDate = DateFormat('MMMM d, EEEE').format(
                              DateTime.now().add(
                                  Duration(days: weekdaysRow1.length + i)));
                        });
                        String selectedSlotType = timeSlotFromWeekday();
                        widget.onSlotSelected(
                          datesRow2[i],
                          selectedWeekday!,
                          selectedSlotType,
                          widget.selectedSlot,
                        );
                        // Add the print statement here
                        devtools.log(
                            "This is coming from inside onTap of second Row Widget104");
                        devtools.log(" Selected Slot: $selectedSlotType");
                      },
                      child: Container(
                        height: 70,
                        width: 70,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          border: Border.all(width: 1),
                          color: selectedIndex == i + weekdaysRow1.length
                              ? Colors
                                  .red // Change the color for the selected container
                              : (weekdaysRow2[i] == currentWeekday
                                  ? Colors.teal[400]
                                  : Colors.teal[100]),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              weekdaysRow2[i].substring(0, 3),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              datesRow2[i],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _availableSlots.containsKey(selectedWeekday) ? 1 : 0,
            //itemCount: weekdays.length,
            itemBuilder: (context, index) {
              String weekday = selectedWeekday!;
              // itemBuilder: (context, index) {
              //   String weekday = weekdays[index];
              Map<String, List<String>> daySlots = _availableSlots[weekday]!;

              // Render the available slots here
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      weekday,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  for (String slotType in daySlots.keys)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            slotType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            for (String timeSlot in daySlots[slotType]!)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // Update the selected slot
                                    widget.onSlotSelected(
                                      selectedDate, // Pass the selected date
                                      selectedWeekday!, // Pass the selected weekday
                                      slotType, // Pass the slot type
                                      timeSlot, // Pass the selected slot
                                    );
                                    // Add the print statement here

                                    devtools.log(
                                        "This is coming from inside onTap of Expanded widget for timeSlot inside Widget104");

                                    devtools
                                        .log('Selected Date: $selectedDate');
                                    devtools.log(
                                        'Selected Weekday: $selectedWeekday');
                                    devtools.log('Slot Type: $slotType');
                                    devtools.log(" Time Slot: $timeSlot");
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: CircleAvatar(
                                    radius: 24,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          timeSlot.split(":")[0],
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          timeSlot.split(" ")[1],
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
