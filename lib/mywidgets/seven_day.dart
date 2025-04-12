import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/slot_service.dart';

class SevenDay extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String doctorName;

  const SevenDay({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<SevenDay> createState() => _SevenDayState();
}

class _SevenDayState extends State<SevenDay> {
  late SlotService _slotService;
  late Future<Map<String, dynamic>?> _slotsFuture;

  @override
  void initState() {
    super.initState();
    _slotService = SlotService(widget.clinicId);
    _slotsFuture = _slotService
        .getSlots(widget.doctorName); // Fetch slots using SlotService
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Seven Days Slots')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _slotsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Data is still loading
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // There was an error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            // Data has been loaded successfully
            final slotData = snapshot.data!;
            return SlotDataDisplayWidget(
                slotData, widget.clinicId, widget.doctorName);
          } else {
            // The document does not exist or no data
            return const Center(child: Text('No slots available.'));
          }
        },
      ),
    );
  }
}

class SlotDataDisplayWidget extends StatelessWidget {
  final Map<String, dynamic> slotData;
  final String clinicId;
  final String doctorName;

  const SlotDataDisplayWidget(this.slotData, this.clinicId, this.doctorName,
      {super.key});

  final String chosenDay = 'Monday';

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: slotData.keys.map((day) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(day,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            for (var timeCategory in ['Morning', 'Afternoon', 'Evening'])
              if (slotData[day][timeCategory] != null)
                Column(
                  children: [
                    Text(timeCategory,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    for (var timeSlot in slotData[day][timeCategory])
                      ListTile(
                        title: Text('Time: ${timeSlot['slot']}'),
                        subtitle: Text('Is Booked: ${timeSlot['isBooked']}'),
                      ),
                  ],
                ),
          ],
        );
      }).toList(),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// CODE BELOW STABLE WITH DIRECT BACKEND CALLS
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class SevenDay extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;

//   const SevenDay({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//   });

//   @override
//   State<SevenDay> createState() => _SevenDayState();
// }

// class _SevenDayState extends State<SevenDay> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('All Seven Days Slots')),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('clinics')
//             .doc(widget.clinicId)
//             .collection('availableSlots')
//             .doc('Dr${widget.doctorName}')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Data is still loading
//             return const CircularProgressIndicator();
//           } else if (snapshot.hasError) {
//             // There was an error
//             return Text('Error: ${snapshot.error}');
//           } else {
//             if (snapshot.hasData && snapshot.data!.exists) {
//               // Data has been loaded successfully
//               // Retrieve the slot data from the Firestore document
//               final slotData = snapshot.data!.data() as Map<String, dynamic>;

//               // Now you can display the slot data on the screen using a custom widget
//               return SlotDataDisplayWidget(
//                   slotData, widget.clinicId, widget.doctorName);
//             } else {
//               // The document does not exist
//               return const Text('Document does not exist');
//             }
//           }
//         },
//       ),
//     );
//   }
// }

// class SlotDataDisplayWidget extends StatelessWidget {
//   final Map<String, dynamic> slotData;
//   final String clinicId;
//   final String doctorName;

//   const SlotDataDisplayWidget(this.slotData, this.clinicId, this.doctorName,
//       {super.key});

//   final String chosenDay = 'Monday';

//   // Define the method to save the chosen day data to Firestore.
//   Future<void> saveChosenDayData(String weekday) async {
//     final Map<String, dynamic> chosenDayData = {chosenDay: slotData[chosenDay]};

//     // Create a reference to 'chosenDaySlots/DrJaikishan'.
//     DocumentReference chosenDayRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('availableSlots')
//         .doc('Dr$doctorName')
//         .collection('chosenDaySlots')
//         .doc(chosenDay);

//     try {
//       await chosenDayRef.set(chosenDayData);
//       print("Data for $chosenDay saved successfully.");
//     } catch (error) {
//       print("Error saving data: $error");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Use the slotData to display the slots for each day, time, etc.
//     // Example: You can create a ListView or a table to display the data.
//     return ListView(
//       children: slotData.keys.map((day) {
//         return Column(
//           children: <Widget>[
//             Text(day,
//                 style:
//                     const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             for (var timeCategory in ['Morning', 'Afternoon', 'Evening'])
//               if (slotData[day][timeCategory] != null)
//                 Column(
//                   children: [
//                     Text(timeCategory,
//                         style: const TextStyle(fontWeight: FontWeight.bold)),
//                     for (var timeSlot in slotData[day][timeCategory])
//                       ListTile(
//                         title: Text('Time: ${timeSlot['slot']}'),
//                         subtitle: Text('Is Booked: ${timeSlot['isBooked']}'),
//                       ),
//                   ],
//                 ),
//             // Add a button to save data for the chosen day
//             ElevatedButton(
//               onPressed: () {
//                 saveChosenDayData(chosenDay);
//               },
//               child: Text('Save $chosenDay Data'),
//             ),
//           ],
//         );
//       }).toList(),
//     );
//   }
// }
