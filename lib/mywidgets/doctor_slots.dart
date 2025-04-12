import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/clinic_service.dart';
import 'package:neocaresmileapp/firestore/doctor_service.dart';
import 'package:neocaresmileapp/firestore/slot_service.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;

class DoctorSlots extends StatefulWidget {
  final String clinicId;

  const DoctorSlots({super.key, required this.clinicId});

  @override
  State<DoctorSlots> createState() => _DoctorSlotsState();
}

class _DoctorSlotsState extends State<DoctorSlots> {
  Map<String, dynamic>? clinicSlotsData;
  Map<String, Set<String>> selectedSlots = {};
  List<Map<String, String>> doctorNamesAndIds = [];
  String? selectedDoctorName;
  String? selectedDoctorId;
  late DoctorService doctorService;
  late SlotService slotService;
  bool isAddingNewDoctorSlots = false;

  final List<String> weekdayOrder = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> periodOrder = [
    'Morning',
    'Afternoon',
    'Evening',
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   doctorService = DoctorService();
  //   slotService =
  //       SlotService(widget.clinicId); // Initialize SlotService with clinicId
  //   fetchDoctorNames();
  //   fetchClinicSlots(); // Call SlotService to fetch clinic-wide slots
  // }

  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
  @override
  void initState() {
    super.initState();
    doctorService = DoctorService();
    _updateSlotService(widget.clinicId); // initialize SlotService
    fetchDoctorNames();
    fetchClinicSlots();

    // Register listener for clinic selection changes
    ClinicSelection.instance.addListener(_onClinicChanged);
  }

  void _updateSlotService(String clinicId) {
    slotService = SlotService(clinicId);
  }

  void _onClinicChanged() {
    final newClinicId = ClinicSelection.instance.selectedClinicId;
    setState(() {
      _updateSlotService(newClinicId); // Update SlotService with new clinic ID
      fetchClinicSlots(); // Re-fetch slots based on selected clinic
    });
  }

  @override
  void dispose() {
    ClinicSelection.instance.removeListener(_onClinicChanged);
    super.dispose();
  }
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

  Future<void> fetchDoctorNames() async {
    doctorNamesAndIds = await doctorService.getDoctorNames();
    setState(() {});
  }

  Future<void> fetchClinicSlots() async {
    devtools.log('Calling fetchClinicSlots from SlotService...');
    try {
      final fetchedSlots = await slotService
          .fetchClinicSlots(); // Fetch clinic slots using SlotService

      if (fetchedSlots != null) {
        setState(() {
          clinicSlotsData = fetchedSlots;
        });
        devtools.log('Fetched clinic slots: $clinicSlotsData');
      } else {
        devtools.log('No clinic slots found.');
      }
    } catch (e) {
      devtools.log('Error fetching clinic slots: $e');
    }
  }

  void toggleSlotSelection(String day, String period, String slotTime) {
    setState(() {
      selectedSlots[day] ??= {};
      if (selectedSlots[day]!.contains(slotTime)) {
        selectedSlots[day]!.remove(slotTime);
      } else {
        selectedSlots[day]!.add(slotTime);
      }
    });
  }

  // void prepareAndSaveSelectedSlots() async {
  //   devtools.log('Welcome to prepareAndSaveSelectedSlots!');

  //   if (selectedDoctorName == null || clinicSlotsData == null) {
  //     _showAlertDialog('Invalid Input',
  //         'Please select a doctor and ensure slots data is available.');
  //     return;
  //   }

  //   if (isAddingNewDoctorSlots) {
  //     return; // Prevent multiple simultaneous submissions
  //   }

  //   setState(() {
  //     isAddingNewDoctorSlots = true;
  //   });

  //   try {
  //     Map<String, dynamic> selectedSlotsData = {};

  //     selectedSlots.forEach((day, slots) {
  //       if (clinicSlotsData!.containsKey(day)) {
  //         Map<String, dynamic> daySlots = clinicSlotsData![day];

  //         Map<String, List<Map<String, dynamic>>> periodSlots = {};
  //         daySlots.forEach((period, slotsList) {
  //           periodSlots[period] = [];

  //           for (var slot in slotsList) {
  //             if (slots.contains(slot['slot'])) {
  //               Map<String, dynamic> updatedSlot =
  //                   Map<String, dynamic>.from(slot);
  //               updatedSlot['isSelected'] = true;
  //               periodSlots[period]!.add(updatedSlot);
  //             } else {
  //               periodSlots[period]!.add(slot);
  //             }
  //           }
  //         });

  //         selectedSlotsData[day] = periodSlots;
  //       }
  //     });

  //     await slotService.addSlot(selectedDoctorName!,
  //         selectedSlotsData); // Use SlotService to add slots

  //     // Show success message
  //     _showAlertDialog('Success', 'Selected slots data pushed successfully.');
  //   } catch (error) {
  //     // Handle errors
  //     _showAlertDialog('Error', 'An error occurred while saving the slots.');
  //   } finally {
  //     setState(() {
  //       isAddingNewDoctorSlots = false;
  //     });
  //   }
  // }

  void prepareAndSaveSelectedSlots() async {
    devtools.log('Welcome to prepareAndSaveSelectedSlots!');

    if (selectedDoctorName == null || clinicSlotsData == null) {
      _showAlertDialog('Invalid Input',
          'Please select a doctor and ensure slots data is available.');
      return;
    }

    if (isAddingNewDoctorSlots) {
      return; // Prevent multiple simultaneous submissions
    }

    setState(() {
      isAddingNewDoctorSlots = true;
    });

    try {
      Map<String, dynamic> selectedSlotsData = {};

      selectedSlots.forEach((day, slots) {
        if (clinicSlotsData!.containsKey(day)) {
          Map<String, dynamic> daySlots = clinicSlotsData![day];

          Map<String, List<Map<String, dynamic>>> periodSlots = {};
          daySlots.forEach((period, slotsList) {
            // Convert slotsList to List<Map<String, dynamic>> safely
            var convertedSlotsList = List<Map<String, dynamic>>.from(
                slotsList as List); // Convert safely
            periodSlots[period] = convertedSlotsList.where((slot) {
              return slots.contains(slot['slot']);
            }).map((slot) {
              return {...slot, 'isSelected': true}; // Mark as selected
            }).toList();
          });

          selectedSlotsData[day] = periodSlots;
        }
      });

      devtools
          .log('Selected slots data prepared for backend: $selectedSlotsData');

      await slotService.addSlot(selectedDoctorName!, selectedSlotsData);

      _showAlertDialog('Success', 'Selected slots data pushed successfully.');
    } catch (error) {
      devtools.log('Error in prepareAndSaveSelectedSlots: $error');
      _showAlertDialog('Error', 'An error occurred while saving the slots.');
    } finally {
      setState(() {
        isAddingNewDoctorSlots = false;
      });
    }
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              if (title == 'Success') {
                Navigator.pop(context); // Navigate back to the parent screen
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Slots'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: clinicSlotsData == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching data
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedDoctorName,
                    items: doctorNamesAndIds.map((doc) {
                      return DropdownMenuItem(
                        value: doc['doctorName'],
                        child: Text(doc['doctorName']!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDoctorName = newValue;
                        selectedDoctorId = doctorNamesAndIds.firstWhere((doc) =>
                            doc['doctorName'] ==
                            selectedDoctorName)['doctorId'];
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Doctor',
                      labelStyle: MyTextStyle.textStyleMap['label-large']
                          ?.copyWith(
                              color:
                                  MyColors.colorPalette['on-surface-variant']),
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(
                          color: MyColors.colorPalette['on-surface-variant'] ??
                              Colors.black,
                        ),
                      ),
                      contentPadding: const EdgeInsets.only(left: 8.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: weekdayOrder.length,
                      itemBuilder: (context, index) {
                        String day = weekdayOrder[index];
                        Map<String, dynamic>? daySlots = clinicSlotsData![day];

                        if (daySlots == null) {
                          return Container(); // Handle days with no slots available
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                day,
                                style: MyTextStyle.textStyleMap['title-large']!
                                    .copyWith(
                                        color: MyColors
                                            .colorPalette['on-surface']),
                              ),
                            ),
                            ...periodOrder.map<Widget>((period) {
                              List<dynamic>? slots = daySlots[period];

                              if (slots == null) {
                                return Container(); // Handle periods with no slots available
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      period,
                                      style: MyTextStyle
                                          .textStyleMap['title-small']!
                                          .copyWith(
                                              color: MyColors
                                                  .colorPalette['on-surface']),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: slots
                                          .asMap()
                                          .entries
                                          .map<Widget>((entry) {
                                        int slotIndex = entry.key;
                                        Map<String, dynamic> slot = entry.value;
                                        bool isSelected = selectedSlots[day]
                                                ?.contains(slot['slot']) ??
                                            false;

                                        return GestureDetector(
                                          onTap: () => toggleSlotSelection(
                                              day, period, slot['slot']),
                                          child: Chip(
                                            label: Text(slot['slot']),
                                            backgroundColor: isSelected
                                                ? MyColors
                                                    .colorPalette['primary']
                                                : MyColors.colorPalette[
                                                    'outline-variant'],
                                            labelStyle: TextStyle(
                                              color: isSelected
                                                  ? MyColors.colorPalette[
                                                      'on-primary']
                                                  : MyColors.colorPalette[
                                                      'on-surface'],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  ),
                  // Save and Cancel Buttons
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 48,
                          width: 144,
                          child: ElevatedButton(
                            onPressed: prepareAndSaveSelectedSlots,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyColors.colorPalette[
                                  'primary'], // Set the background color
                            ),
                            child: Text(
                              'Save',
                              style: MyTextStyle.textStyleMap['label-large']
                                  ?.copyWith(
                                color: MyColors.colorPalette[
                                    'on-primary'], // Set the text color
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                                context); // Close or cancel the operation
                          },
                          child: const Text('Cancel'),
                        ),
                        if (isAddingNewDoctorSlots)
                          const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
