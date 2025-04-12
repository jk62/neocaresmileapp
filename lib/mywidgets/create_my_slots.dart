import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/slot_service.dart';
import 'dart:developer' as devtools show log;

class CreateMySlots extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String clinicId;

  const CreateMySlots({
    super.key,
    required this.doctorName,
    required this.doctorId,
    required this.clinicId,
  });

  @override
  State<CreateMySlots> createState() => _CreateMySlotsState();
}

class _CreateMySlotsState extends State<CreateMySlots> {
  Map<String, dynamic> clinicSlots = {}; // Initialize as an empty map
  late SlotService _slotService; // Define the SlotService instance

  @override
  void initState() {
    super.initState();
    _slotService = SlotService(widget.clinicId); // Initialize SlotService
    loadClinicSlots(); // Load clinicSlots data
  }

  void loadClinicSlots() async {
    try {
      // Use SlotService to get the slots
      final slots = await _slotService.getMySlots('clinicSlots');

      if (slots != null) {
        setState(() {
          clinicSlots = slots;
        });
      } else {
        devtools.log("clinicSlots data is null.");
      }
    } catch (e) {
      devtools.log("Error loading clinicSlots data: $e");
    }
  }

  void updateSlotStatus(String weekday, String slotTime, bool isSelected) {
    setState(() {
      clinicSlots[weekday][slotTime]['isSelected'] = isSelected;
    });
  }

  void saveUpdatedSlots() async {
    try {
      // Use SlotService to save the updated slots
      await _slotService.updateMySlot(widget.doctorName, clinicSlots);
      devtools.log("Updated slots data saved successfully!");
    } catch (e) {
      devtools.log("Error saving updated slots data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Availability Slots'),
      ),
      body: ListView.builder(
        itemCount: clinicSlots.length,
        itemBuilder: (context, index) {
          String weekday = clinicSlots.keys.elementAt(index);
          Map<String, dynamic> timeSlotsData = clinicSlots[weekday];

          return ExpansionTile(
            title: Text(weekday),
            children: timeSlotsData.entries.map((timeSlotEntry) {
              List<Map<String, dynamic>> slots =
                  timeSlotEntry.value.cast<Map<String, dynamic>>();

              return ListView.builder(
                itemCount: slots.length,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  String slotTime = slots[index]['slot'];
                  bool isSelected = slots[index]['isSelected'] ?? false;

                  return CheckboxListTile(
                    title: Text(slotTime),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        slots[index]['isSelected'] = value;
                      });
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Selection'),
                content: const Text('Do you want to save the selected slots?'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context); // Close the dialog
                      saveUpdatedSlots(); // Save the updated slots to the backend

                      // Navigate back to the previous screen after saving
                      Navigator.pop(context);
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
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE WITH DIRECT BACKEND CALLS
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:developer' as devtools show log;

// class CreateMySlots extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;

//   const CreateMySlots({
//     super.key,
//     required this.doctorName,
//     required this.doctorId,
//     required this.clinicId,
//   });

//   @override
//   State<CreateMySlots> createState() => _CreateMySlotsState();
// }

// class _CreateMySlotsState extends State<CreateMySlots> {
//   Map<String, dynamic> clinicSlots = {}; // Initialize as an empty map

//   @override
//   void initState() {
//     super.initState();
//     loadClinicSlots(); // Load clinicSlots data
//   }

//   void loadClinicSlots() async {
//     try {
//       DocumentReference clinicRef =
//           FirebaseFirestore.instance.collection('clinics').doc(widget.clinicId);

//       CollectionReference availableSlotsRef =
//           clinicRef.collection('availableSlots');
//       DocumentSnapshot clinicSlotsSnapshot =
//           await availableSlotsRef.doc('clinicSlots').get();

//       if (clinicSlotsSnapshot.exists) {
//         Map<String, dynamic>? clinicSlotsData =
//             clinicSlotsSnapshot.data() as Map<String, dynamic>?;

//         if (clinicSlotsData != null) {
//           setState(() {
//             clinicSlots = clinicSlotsData;
//           });
//         } else {
//           devtools.log("clinicSlots data is null.");
//         }
//       } else {
//         devtools.log("clinicSlots document not found.");
//       }
//     } catch (e) {
//       devtools.log("Error loading clinicSlots data: $e");
//     }
//   }

//   void updateSlotStatus(String weekday, String slotTime, bool isSelected) {
//     setState(() {
//       clinicSlots[weekday][slotTime]['isSelected'] = isSelected;
//     });
//   }

//   void saveUpdatedSlots() async {
//     try {
//       DocumentReference clinicRef =
//           FirebaseFirestore.instance.collection('clinics').doc(widget.clinicId);

//       await clinicRef
//           .collection('availableSlots')
//           .doc('Dr${widget.doctorName}')
//           //.set(clinicSlots['weekday']); // Save the updated data
//           .set(clinicSlots); // Save the updated data

//       devtools.log("Updated slots data saved successfully!");
//     } catch (e) {
//       devtools.log("Error saving updated slots data: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Availability Slots'),
//       ),
//       body: ListView.builder(
//         itemCount: clinicSlots.length,
//         itemBuilder: (context, index) {
//           String weekday = clinicSlots.keys.elementAt(index);
//           Map<String, dynamic> timeSlotsData = clinicSlots[weekday];

//           return ExpansionTile(
//             title: Text(weekday),
//             children: timeSlotsData.entries.map((timeSlotEntry) {
//               List<Map<String, dynamic>> slots =
//                   timeSlotEntry.value.cast<Map<String, dynamic>>();

//               return ListView.builder(
//                 itemCount: slots.length,
//                 shrinkWrap: true,
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 itemBuilder: (context, index) {
//                   String slotTime = slots[index]['slot'];
//                   bool isSelected = slots[index]['isSelected'] ?? false;

//                   return CheckboxListTile(
//                     title: Text(slotTime),
//                     value: isSelected,
//                     onChanged: (bool? value) {
//                       setState(() {
//                         slots[index]['isSelected'] = value;
//                       });
//                     },
//                   );
//                 },
//               );
//             }).toList(),
//           );
//         },
//       ),
//       bottomNavigationBar: ElevatedButton(
//         onPressed: () async {
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: const Text('Confirm Selection'),
//                 content: const Text('Do you want to save the selected slots?'),
//                 actions: [
//                   TextButton(
//                     onPressed: () async {
//                       Navigator.pop(context); // Close the dialog
//                       saveUpdatedSlots(); // Save the updated slots to the backend

//                       // Navigate back to the previous screen after saving
//                       Navigator.pop(context);
//                     },
//                     child: const Text('Save'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context); // Close the dialog
//                     },
//                     child: const Text('Cancel'),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//         child: const Text('Select Slots'),
//       ),
//     );
//   }
// }
