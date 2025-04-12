import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/firestore/note_service.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'dart:developer' as devtools show log;
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

class NotesTab extends StatefulWidget {
  final String clinicId;
  final String patientId;
  final String? treatmentId;

  const NotesTab({
    super.key,
    required this.clinicId,
    required this.patientId,
    required this.treatmentId,
  });

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  late NoteService _noteService;
  String noteId = '';
  bool notesFetched = false;
  bool _isEditMode = false;
  List<Map<String, dynamic>> existingNotes = [];

  List<int> affectedTeeth = [];
  bool showToothTable = false;
  bool toothSelectionConfirmed = false;
  TextEditingController doctorNoteController = TextEditingController();
  bool showAddNewCard = false;
  DateTime currentDate = DateTime.now();

  List<int> flatToothTable1 = [14, 13, 12, 11, 18, 17, 16, 15];
  List<int> flatToothTable2 = [21, 22, 23, 24, 25, 26, 27, 28];
  List<int> flatToothTable3 = [44, 43, 42, 41, 48, 47, 46, 45];
  List<int> flatToothTable4 = [31, 32, 33, 34, 35, 36, 37, 38];

  @override
  void initState() {
    super.initState();
    _noteService = NoteService(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      treatmentId: widget.treatmentId!,
    );
    if (!notesFetched) {
      fetchNotes();
    }
  }

  @override
  void dispose() {
    doctorNoteController.dispose();
    super.dispose();
  }

  void toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void toggleToothSelection(int toothNumber) {
    setState(() {
      if (affectedTeeth.contains(toothNumber)) {
        affectedTeeth.remove(toothNumber);
      } else {
        affectedTeeth.add(toothNumber);
      }
    });
  }

  Future<void> addNote() async {
    try {
      await _noteService.addNoteToBackend(
        currentDate: currentDate,
        affectedTeeth: affectedTeeth,
        doctorNote: doctorNoteController.text,
      );

      setState(() {
        showAddNewCard = false;
        affectedTeeth.clear();
        doctorNoteController.clear();
      });

      await fetchNotes();
    } catch (e) {
      devtools.log('Error adding note: $e');
    }
  }

  Future<void> fetchNotes() async {
    try {
      final notes = await _noteService.fetchNotes();
      setState(() {
        existingNotes = notes;
        notesFetched = true;
      });
    } catch (e) {
      devtools.log('Error fetching notes: $e');
    }
  }

  Future<void> deleteNoteFromBackend(String noteId) async {
    try {
      await _noteService.deleteNoteFromBackend(noteId);
      setState(() {
        existingNotes.removeWhere((note) => note['noteId'] == noteId);
      });
    } catch (e) {
      devtools.log('Error deleting note: $e');
    }
  }

  Widget _buildExistingNotesCards() {
    return SingleChildScrollView(
      child: Column(
        children: existingNotes.map((note) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        note['timestamp'],
                        style: MyTextStyle.textStyleMap['label-medium']
                            ?.copyWith(
                                color: MyColors.colorPalette['on-surface']),
                      ),
                      GestureDetector(
                        onTap: () {
                          devtools.log('Delete operation triggered');
                          deleteNoteFromBackend(note['noteId']);
                        },
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: MyColors.colorPalette['on-surface'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Affected Teeth:',
                    style: MyTextStyle.textStyleMap['label-medium']
                        ?.copyWith(color: MyColors.colorPalette['on-surface']),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable scrolling in GridView
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8, // 8 chips per row
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                      childAspectRatio: 1,
                    ),
                    itemCount: note['affectedTeeth'].length,
                    itemBuilder: (context, index) {
                      int toothNumber = note['affectedTeeth'][index];
                      return Container(
                        decoration: BoxDecoration(
                          color: MyColors.colorPalette['primary'],
                          border: Border.all(
                            color: MyColors.colorPalette['primary'] ??
                                Colors.blueAccent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            '$toothNumber',
                            style: MyTextStyle.textStyleMap['label-medium']
                                ?.copyWith(
                              color: MyColors.colorPalette['on-primary'],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '${note['doctorNote']}',
                          style: MyTextStyle.textStyleMap['label-small']
                              ?.copyWith(
                                  color: MyColors.colorPalette['on-surface']),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildToothTable() {
    if (!showToothTable) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Top row containing first and second quadrants
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: MyColors.colorPalette['on-surface'] ?? Colors.grey,
                width: 2.0,
              ),
            ),
          ),
          child: Row(
            children: [
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color:
                            MyColors.colorPalette['on-surface'] ?? Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: flatToothTable1.length,
                    itemBuilder: (context, index) {
                      int toothNumber = flatToothTable1[index];
                      bool isSelected = affectedTeeth.contains(toothNumber);

                      return GestureDetector(
                        onTap: () => toggleToothSelection(toothNumber),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MyColors.colorPalette['primary']
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? MyColors.colorPalette['primary'] ??
                                      Colors.blueAccent
                                  : MyColors.colorPalette['on-surface'] ??
                                      Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              '$toothNumber',
                              style: MyTextStyle.textStyleMap['label-medium']
                                  ?.copyWith(
                                color: isSelected
                                    ? MyColors.colorPalette['on-primary']
                                    : MyColors.colorPalette['on-surface'],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color:
                            MyColors.colorPalette['on-surface'] ?? Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: flatToothTable2.length,
                    itemBuilder: (context, index) {
                      int toothNumber = flatToothTable2[index];
                      bool isSelected = affectedTeeth.contains(toothNumber);

                      return GestureDetector(
                        onTap: () => toggleToothSelection(toothNumber),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MyColors.colorPalette['primary']
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? MyColors.colorPalette['primary'] ??
                                      Colors.blueAccent
                                  : MyColors.colorPalette['on-surface'] ??
                                      Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              '$toothNumber',
                              style: MyTextStyle.textStyleMap['label-medium']
                                  ?.copyWith(
                                color: isSelected
                                    ? MyColors.colorPalette['on-primary']
                                    : MyColors.colorPalette['on-surface'],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom row containing third and fourth quadrants
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: MyColors.colorPalette['on-surface'] ?? Colors.grey,
                width: 2.0,
              ),
            ),
          ),
          child: Row(
            children: [
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color:
                            MyColors.colorPalette['on-surface'] ?? Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: flatToothTable3.length,
                    itemBuilder: (context, index) {
                      int toothNumber = flatToothTable3[index];
                      bool isSelected = affectedTeeth.contains(toothNumber);

                      return GestureDetector(
                        onTap: () => toggleToothSelection(toothNumber),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MyColors.colorPalette['primary']
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? MyColors.colorPalette['primary'] ??
                                      Colors.blueAccent
                                  : MyColors.colorPalette['on-surface'] ??
                                      Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              '$toothNumber',
                              style: MyTextStyle.textStyleMap['label-medium']
                                  ?.copyWith(
                                color: isSelected
                                    ? MyColors.colorPalette['on-primary']
                                    : MyColors.colorPalette['on-surface'],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color:
                            MyColors.colorPalette['on-surface'] ?? Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: flatToothTable4.length,
                    itemBuilder: (context, index) {
                      int toothNumber = flatToothTable4[index];
                      bool isSelected = affectedTeeth.contains(toothNumber);

                      return GestureDetector(
                        onTap: () => toggleToothSelection(toothNumber),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MyColors.colorPalette['primary']
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? MyColors.colorPalette['primary'] ??
                                      Colors.blueAccent
                                  : MyColors.colorPalette['on-surface'] ??
                                      Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              '$toothNumber',
                              style: MyTextStyle.textStyleMap['label-medium']
                                  ?.copyWith(
                                color: isSelected
                                    ? MyColors.colorPalette['on-primary']
                                    : MyColors.colorPalette['on-surface'],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!showAddNewCard) // Only show when not adding a new note
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'All Notes',
                style: MyTextStyle.textStyleMap['title-large']
                    ?.copyWith(color: MyColors.colorPalette['on-surface']),
              ),
            ),
          ),
        if (!showAddNewCard && existingNotes.isNotEmpty)
          _buildExistingNotesCards()
        else if (!showAddNewCard)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'No notes taken so far',
                style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
                    color: MyColors.colorPalette['on-surface-variant']),
              ),
            ),
          ),
        if (!showAddNewCard) // Only show when not adding a new note
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        MyColors.colorPalette['on-primary']!),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        side: BorderSide(
                            color: MyColors.colorPalette['primary']!,
                            width: 1.0),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      showAddNewCard = true; // Show the card when pressed
                      showToothTable = true; // Make the tooth table visible
                    });
                  },
                  child: Wrap(
                    children: [
                      Icon(
                        Icons.add,
                        color: MyColors.colorPalette['primary'],
                      ),
                      Text(
                        'Add New',
                        style: MyTextStyle.textStyleMap['label-large']
                            ?.copyWith(color: MyColors.colorPalette['primary']),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (showAddNewCard) _buildAddNewCard(), // Render the card if toggled
      ],
    );
  }

  Widget _buildAddNewCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM dd, EEEE').format(currentDate),
                    style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
                      color: MyColors.colorPalette['on-surface'],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAddNewCard = false; // Hide the card on close
                      });
                    },
                    child: Icon(
                      Icons.close,
                      size: 24,
                      color: MyColors.colorPalette['on-surface'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Mark Affected Teeth',
                style: MyTextStyle.textStyleMap['title-medium']
                    ?.copyWith(color: MyColors.colorPalette['secondary']),
              ),
              const SizedBox(height: 8),
              buildToothTable(),
              const SizedBox(height: 16),
              Text(
                'Add Note',
                style: MyTextStyle.textStyleMap['title-medium']
                    ?.copyWith(color: MyColors.colorPalette['secondary']),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: MyColors.colorPalette['on-surface'] ??
                        const Color(0xFF011718),
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: TextFormField(
                  controller: doctorNoteController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                  maxLines: null,
                  style: MyTextStyle.textStyleMap['label-large']
                      ?.copyWith(color: MyColors.colorPalette['secondary']),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      height: 48,
                      width: 144,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              MyColors.colorPalette['primary']!),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              side: BorderSide(
                                color: MyColors.colorPalette['primary']!,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                        onPressed: addNote,
                        child: Text(
                          'Add',
                          style: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors.colorPalette['on-primary']),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showAddNewCard = false; // Cancel and hide the card
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW STABLE WITH DIRECT BACKEND CALLS
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class NotesTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;
//   const NotesTab({
//     super.key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   });

//   @override
//   State<NotesTab> createState() => _NotesTabState();
// }

// class _NotesTabState extends State<NotesTab> {
//   String noteId = '';
//   bool notesFetched = false;
//   bool _isEditMode = false;
//   List<Map<String, dynamic>> existingNotes = [];

//   // New state variables
//   List<int> affectedTeeth = [];
//   bool showToothTable = false;
//   bool toothSelectionConfirmed = false;
//   TextEditingController doctorNoteController = TextEditingController();
//   bool showAddNewCard = false; // To toggle the visibility of the "Add New" card
//   DateTime currentDate = DateTime.now(); // To store the current date

//   // Separate flat tooth tables for quadrants
//   List<int> flatToothTable1 = [
//     14,
//     13,
//     12,
//     11,
//     18,
//     17,
//     16,
//     15,
//   ];

//   List<int> flatToothTable2 = [
//     21,
//     22,
//     23,
//     24,
//     25,
//     26,
//     27,
//     28,
//   ];

//   List<int> flatToothTable3 = [
//     44,
//     43,
//     42,
//     41,
//     48,
//     47,
//     46,
//     45,
//   ];

//   List<int> flatToothTable4 = [
//     31,
//     32,
//     33,
//     34,
//     35,
//     36,
//     37,
//     38,
//   ];

//   @override
//   void initState() {
//     super.initState();
//     if (!notesFetched) {
//       fetchNotes();
//     }
//   }

//   @override
//   void dispose() {
//     doctorNoteController.dispose();
//     super.dispose();
//   }

//   void toggleEditMode() {
//     setState(() {
//       _isEditMode = !_isEditMode;
//     });
//   }

//   void toggleToothSelection(int toothNumber) {
//     setState(() {
//       if (affectedTeeth.contains(toothNumber)) {
//         affectedTeeth.remove(toothNumber);
//       } else {
//         affectedTeeth.add(toothNumber);
//       }
//     });
//   }

//   Future<void> addNoteToBackend() async {
//     try {
//       final clinicId = widget.clinicId;
//       final patientId = widget.patientId;
//       final treatmentId = widget.treatmentId;

//       // Generate a new noteId using a UUID or similar
//       String noteId = FirebaseFirestore.instance.collection('notes').doc().id;

//       // Prepare note data
//       Map<String, dynamic> noteData = {
//         'noteId': noteId,
//         'date':
//             Timestamp.fromDate(currentDate), // Store as Timestamp in Firestore
//         'affectedTeeth': affectedTeeth,
//         'doctorNote': doctorNoteController.text,
//       };

//       // Reference to the notes sub-collection
//       final notesCollectionRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId)
//           .collection('treatments')
//           .doc(treatmentId)
//           .collection('notes');

//       // Push the note data to Firestore
//       await notesCollectionRef.doc(noteId).set(noteData);

//       devtools.log('Note data pushed to the backend successfully');

//       // Clear the inputs after saving
//       setState(() {
//         showAddNewCard = false;
//         affectedTeeth.clear();
//         doctorNoteController.clear();
//       });

//       // Fetch the updated notes to include the new note in the existing notes list
//       await fetchNotes();
//     } catch (e) {
//       devtools.log('Error adding note data: $e');
//     }
//   }

//   void confirmToothSelection() {
//     setState(() {
//       showToothTable = false; // Hide the tooth table after confirmation
//       toothSelectionConfirmed = true; // Show the affected teeth as chips
//     });
//   }

//   String _formatTimestamp(Timestamp? timestamp) {
//     if (timestamp == null) {
//       return '';
//     }
//     final dateTime = timestamp.toDate();
//     return DateFormat('MMMM dd, EEEE').format(dateTime);
//   }

//   Future<void> fetchNotes() async {
//     try {
//       final clinicId = widget.clinicId;
//       final patientId = widget.patientId;
//       final treatmentId = widget.treatmentId;

//       final notesQuery = await FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId)
//           .collection('treatments')
//           .doc(treatmentId)
//           .collection('notes')
//           .get();

//       existingNotes.clear();

//       for (final doc in notesQuery.docs) {
//         final Map<String, dynamic> data = doc.data();
//         final timestamp =
//             data['date']; // Accessing 'date' instead of 'timestamp'
//         String formattedDate = '';

//         if (timestamp != null && timestamp is Timestamp) {
//           DateTime dateTime = timestamp.toDate();
//           formattedDate = DateFormat('MMMM dd, EEEE').format(dateTime);
//         }

//         existingNotes.add({
//           'noteId': doc.id,
//           'timestamp': formattedDate, // Use the correctly formatted date here
//           'doctorNote': data['doctorNote'] ?? '',
//           'affectedTeeth': data['affectedTeeth'] ?? [],
//         });
//       }

//       setState(() {
//         notesFetched = true;
//       });
//     } catch (e) {
//       devtools.log('Error fetching notes data: $e');
//     }
//   }

//   Widget _buildExistingNotesCards() {
//     return SingleChildScrollView(
//       child: Column(
//         children: existingNotes.map((note) {
//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         note['timestamp'],
//                         style: MyTextStyle.textStyleMap['label-medium']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['on-surface']),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           devtools.log('Delete operation triggered');
//                           deleteNoteFromBackend(note['noteId']);
//                         },
//                         child: Icon(
//                           Icons.close,
//                           size: 24,
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Affected Teeth:',
//                     style: MyTextStyle.textStyleMap['label-medium']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                   const SizedBox(height: 8),
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics:
//                         const NeverScrollableScrollPhysics(), // Disable scrolling in GridView
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 8, // 8 chips per row
//                       crossAxisSpacing: 4.0,
//                       mainAxisSpacing: 4.0,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: note['affectedTeeth'].length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = note['affectedTeeth'][index];
//                       return Container(
//                         decoration: BoxDecoration(
//                           color: MyColors.colorPalette['primary'],
//                           border: Border.all(
//                             color: MyColors.colorPalette['primary'] ??
//                                 Colors.blueAccent,
//                             width: 1,
//                           ),
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         child: Center(
//                           child: Text(
//                             '$toothNumber',
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                               color: MyColors.colorPalette['on-primary'],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 8),
//                   Column(
//                     children: [
//                       Align(
//                         alignment: Alignment.topLeft,
//                         child: Text(
//                           '${note['doctorNote']}',
//                           style: MyTextStyle.textStyleMap['label-small']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['on-surface']),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Future<void> deleteNoteFromBackend(String noteId) async {
//     try {
//       final clinicId = widget.clinicId;
//       final patientId = widget.patientId;
//       final treatmentId = widget.treatmentId;

//       // Reference to the specific note document in the backend
//       final noteDocRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId)
//           .collection('treatments')
//           .doc(treatmentId)
//           .collection('notes')
//           .doc(noteId);

//       // Delete the note from Firestore
//       await noteDocRef.delete();

//       // Remove the note from the local state
//       setState(() {
//         existingNotes.removeWhere((note) => note['noteId'] == noteId);
//       });

//       devtools.log('Note with noteId $noteId deleted successfully');
//     } catch (e) {
//       devtools.log('Error deleting note with noteId $noteId: $e');
//     }
//   }

//   //-----------------------------------------------------------------//

//   Widget buildToothTable() {
//     if (!showToothTable) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       children: [
//         // Top row containing first and second quadrants
//         Container(
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                 width: 2.0,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               Flexible(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       right: BorderSide(
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                         width: 1.0,
//                       ),
//                     ),
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: flatToothTable1.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = flatToothTable1[index];
//                       bool isSelected = affectedTeeth.contains(toothNumber);

//                       return GestureDetector(
//                         onTap: () => toggleToothSelection(toothNumber),
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? MyColors.colorPalette['primary']
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: isSelected
//                                   ? MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent
//                                   : MyColors.colorPalette['on-surface'] ??
//                                       Colors.grey,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$toothNumber',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                 color: isSelected
//                                     ? MyColors.colorPalette['on-primary']
//                                     : MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               Flexible(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       left: BorderSide(
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                         width: 1.0,
//                       ),
//                     ),
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: flatToothTable2.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = flatToothTable2[index];
//                       bool isSelected = affectedTeeth.contains(toothNumber);

//                       return GestureDetector(
//                         onTap: () => toggleToothSelection(toothNumber),
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? MyColors.colorPalette['primary']
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: isSelected
//                                   ? MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent
//                                   : MyColors.colorPalette['on-surface'] ??
//                                       Colors.grey,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$toothNumber',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                 color: isSelected
//                                     ? MyColors.colorPalette['on-primary']
//                                     : MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // Bottom row containing third and fourth quadrants
//         Container(
//           decoration: BoxDecoration(
//             border: Border(
//               top: BorderSide(
//                 color: MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                 width: 2.0,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               Flexible(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       right: BorderSide(
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                         width: 1.0,
//                       ),
//                     ),
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: flatToothTable3.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = flatToothTable3[index];
//                       bool isSelected = affectedTeeth.contains(toothNumber);

//                       return GestureDetector(
//                         onTap: () => toggleToothSelection(toothNumber),
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? MyColors.colorPalette['primary']
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: isSelected
//                                   ? MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent
//                                   : MyColors.colorPalette['on-surface'] ??
//                                       Colors.grey,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$toothNumber',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                 color: isSelected
//                                     ? MyColors.colorPalette['on-primary']
//                                     : MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               Flexible(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       left: BorderSide(
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                         width: 1.0,
//                       ),
//                     ),
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: flatToothTable4.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = flatToothTable4[index];
//                       bool isSelected = affectedTeeth.contains(toothNumber);

//                       return GestureDetector(
//                         onTap: () => toggleToothSelection(toothNumber),
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? MyColors.colorPalette['primary']
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: isSelected
//                                   ? MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent
//                                   : MyColors.colorPalette['on-surface'] ??
//                                       Colors.grey,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$toothNumber',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                 color: isSelected
//                                     ? MyColors.colorPalette['on-primary']
//                                     : MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   //-----------------------------------------------------------------//

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (!showAddNewCard) // Only show when not adding a new note
//           Padding(
//             padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Text(
//                 'All Notes',
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//             ),
//           ),
//         if (!showAddNewCard && existingNotes.isNotEmpty)
//           _buildExistingNotesCards()
//         else if (!showAddNewCard)
//           Padding(
//             padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Text(
//                 'No notes taken so far',
//                 style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         if (!showAddNewCard) // Only show when not adding a new note
//           Padding(
//             padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: SizedBox(
//                 height: 48,
//                 child: ElevatedButton(
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all(
//                         MyColors.colorPalette['on-primary']!),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         side: BorderSide(
//                             color: MyColors.colorPalette['primary']!,
//                             width: 1.0),
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       showAddNewCard = true; // Show the card when pressed
//                       showToothTable = true; // Make the tooth table visible
//                     });
//                   },
//                   child: Wrap(
//                     children: [
//                       Icon(
//                         Icons.add,
//                         color: MyColors.colorPalette['primary'],
//                       ),
//                       Text(
//                         'Add New',
//                         style: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(color: MyColors.colorPalette['primary']),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         if (showAddNewCard) _buildAddNewCard(), // Render the card if toggled
//       ],
//     );
//   }

//   // ------------------------------------------------------------------------ //

//   Widget _buildAddNewCard() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     DateFormat('MMMM dd, EEEE').format(currentDate),
//                     style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         showAddNewCard = false; // Hide the card on close
//                       });
//                     },
//                     child: Icon(
//                       Icons.close,
//                       size: 24,
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Mark Affected Teeth',
//                 style: MyTextStyle.textStyleMap['title-medium']
//                     ?.copyWith(color: MyColors.colorPalette['secondary']),
//               ),
//               const SizedBox(height: 8),
//               buildToothTable(),
//               const SizedBox(height: 16),
//               Text(
//                 'Add Note',
//                 style: MyTextStyle.textStyleMap['title-medium']
//                     ?.copyWith(color: MyColors.colorPalette['secondary']),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     width: 1,
//                     color: MyColors.colorPalette['on-surface'] ??
//                         const Color(0xFF011718),
//                   ),
//                   borderRadius: BorderRadius.circular(5.0),
//                 ),
//                 child: TextFormField(
//                   controller: doctorNoteController,
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.all(16.0),
//                   ),
//                   maxLines: null,
//                   style: MyTextStyle.textStyleMap['label-large']
//                       ?.copyWith(color: MyColors.colorPalette['secondary']),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       height: 48,
//                       width: 144,
//                       child: ElevatedButton(
//                         style: ButtonStyle(
//                           backgroundColor: MaterialStateProperty.all(
//                               MyColors.colorPalette['primary']!),
//                           shape: MaterialStateProperty.all(
//                             RoundedRectangleBorder(
//                               side: BorderSide(
//                                 color: MyColors.colorPalette['primary']!,
//                                 width: 1.0,
//                               ),
//                               borderRadius: BorderRadius.circular(24.0),
//                             ),
//                           ),
//                         ),
//                         onPressed: addNoteToBackend,
//                         child: Text(
//                           'Add',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['on-primary']),
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         setState(() {
//                           showAddNewCard = false; // Cancel and hide the card
//                         });
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW STABLE WITH OLD TOOTH TABLE
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class NotesTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;
//   const NotesTab({
//     super.key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   });

//   @override
//   State<NotesTab> createState() => _NotesTabState();
// }

// class _NotesTabState extends State<NotesTab> {
//   String noteId = '';
//   bool notesFetched = false;
//   bool _isEditMode = false;
//   List<Map<String, dynamic>> existingNotes = [];

//   // New state variables
//   List<int> affectedTeeth = [];
//   bool showToothTable = false;
//   bool toothSelectionConfirmed = false;
//   TextEditingController doctorNoteController = TextEditingController();
//   bool showAddNewCard = false; // To toggle the visibility of the "Add New" card
//   DateTime currentDate = DateTime.now(); // To store the current date

//   List<int> flatToothTable = [
//     11,
//     12,
//     13,
//     14,
//     15,
//     16,
//     17,
//     18,
//     21,
//     22,
//     23,
//     24,
//     25,
//     26,
//     27,
//     28,
//     31,
//     32,
//     33,
//     34,
//     35,
//     36,
//     37,
//     38,
//     41,
//     42,
//     43,
//     44,
//     45,
//     46,
//     47,
//     48,
//   ];

//   @override
//   void initState() {
//     super.initState();
//     if (!notesFetched) {
//       fetchNotes();
//     }
//   }

//   @override
//   void dispose() {
//     doctorNoteController.dispose();
//     super.dispose();
//   }

//   void toggleEditMode() {
//     setState(() {
//       _isEditMode = !_isEditMode;
//     });
//   }

//   void toggleToothSelection(int toothNumber) {
//     setState(() {
//       if (affectedTeeth.contains(toothNumber)) {
//         affectedTeeth.remove(toothNumber);
//       } else {
//         affectedTeeth.add(toothNumber);
//       }
//     });
//   }

//   // Future<void> addNoteToBackend() async {
//   //   try {
//   //     final clinicId = widget.clinicId;
//   //     final patientId = widget.patientId;
//   //     final treatmentId = widget.treatmentId;

//   //     // Generate a new noteId using a UUID or similar
//   //     String noteId = FirebaseFirestore.instance.collection('notes').doc().id;

//   //     // Prepare note data
//   //     Map<String, dynamic> noteData = {
//   //       'noteId': noteId,
//   //       'date':
//   //           Timestamp.fromDate(currentDate), // Store as Timestamp in Firestore
//   //       'affectedTeeth': affectedTeeth,
//   //       'doctorNote': doctorNoteController.text,
//   //     };

//   //     // Reference to the notes sub-collection
//   //     final notesCollectionRef = FirebaseFirestore.instance
//   //         .collection('clinics')
//   //         .doc(clinicId)
//   //         .collection('patients')
//   //         .doc(patientId)
//   //         .collection('treatments')
//   //         .doc(treatmentId)
//   //         .collection('notes');

//   //     // Push the note data to Firestore
//   //     await notesCollectionRef.doc(noteId).set(noteData);

//   //     // Clear the inputs after saving
//   //     setState(() {
//   //       showAddNewCard = false;
//   //       affectedTeeth.clear();
//   //       doctorNoteController.clear();
//   //     });

//   //     devtools.log('Note data pushed to the backend successfully');
//   //   } catch (e) {
//   //     devtools.log('Error adding note data: $e');
//   //   }
//   // }

//   Future<void> addNoteToBackend() async {
//     try {
//       final clinicId = widget.clinicId;
//       final patientId = widget.patientId;
//       final treatmentId = widget.treatmentId;

//       // Generate a new noteId using a UUID or similar
//       String noteId = FirebaseFirestore.instance.collection('notes').doc().id;

//       // Prepare note data
//       Map<String, dynamic> noteData = {
//         'noteId': noteId,
//         'date':
//             Timestamp.fromDate(currentDate), // Store as Timestamp in Firestore
//         'affectedTeeth': affectedTeeth,
//         'doctorNote': doctorNoteController.text,
//       };

//       // Reference to the notes sub-collection
//       final notesCollectionRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId)
//           .collection('treatments')
//           .doc(treatmentId)
//           .collection('notes');

//       // Push the note data to Firestore
//       await notesCollectionRef.doc(noteId).set(noteData);

//       devtools.log('Note data pushed to the backend successfully');

//       // Clear the inputs after saving
//       setState(() {
//         showAddNewCard = false;
//         affectedTeeth.clear();
//         doctorNoteController.clear();
//       });

//       // Fetch the updated notes to include the new note in the existing notes list
//       await fetchNotes();
//     } catch (e) {
//       devtools.log('Error adding note data: $e');
//     }
//   }

//   void confirmToothSelection() {
//     setState(() {
//       showToothTable = false; // Hide the tooth table after confirmation
//       toothSelectionConfirmed = true; // Show the affected teeth as chips
//     });
//   }

//   String _formatTimestamp(Timestamp? timestamp) {
//     if (timestamp == null) {
//       return '';
//     }
//     final dateTime = timestamp.toDate();
//     return DateFormat('MMMM dd, EEEE').format(dateTime);
//   }

//   Future<void> fetchNotes() async {
//     try {
//       final clinicId = widget.clinicId;
//       final patientId = widget.patientId;
//       final treatmentId = widget.treatmentId;

//       final notesQuery = await FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId)
//           .collection('treatments')
//           .doc(treatmentId)
//           .collection('notes')
//           .get();

//       existingNotes.clear();

//       for (final doc in notesQuery.docs) {
//         final Map<String, dynamic> data = doc.data();
//         final timestamp =
//             data['date']; // Accessing 'date' instead of 'timestamp'
//         String formattedDate = '';

//         if (timestamp != null && timestamp is Timestamp) {
//           DateTime dateTime = timestamp.toDate();
//           formattedDate = DateFormat('MMMM dd, EEEE').format(dateTime);
//         }

//         existingNotes.add({
//           'noteId': doc.id,
//           'timestamp': formattedDate, // Use the correctly formatted date here
//           'doctorNote': data['doctorNote'] ?? '',
//           'affectedTeeth': data['affectedTeeth'] ?? [],
//         });
//       }

//       setState(() {
//         notesFetched = true;
//       });
//     } catch (e) {
//       devtools.log('Error fetching notes data: $e');
//     }
//   }

//   Widget _buildExistingNotesCards() {
//     return SingleChildScrollView(
//       child: Column(
//         children: existingNotes.map((note) {
//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         note['timestamp'],
//                         style: MyTextStyle.textStyleMap['label-medium']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['on-surface']),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           devtools.log('Delete operation triggered');
//                           deleteNoteFromBackend(note['noteId']);
//                         },
//                         child: Icon(
//                           Icons.close,
//                           size: 24,
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Affected Teeth:',
//                     style: MyTextStyle.textStyleMap['label-medium']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                   const SizedBox(height: 8),
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics:
//                         const NeverScrollableScrollPhysics(), // Disable scrolling in GridView
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 8, // 8 chips per row
//                       crossAxisSpacing: 4.0,
//                       mainAxisSpacing: 4.0,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: note['affectedTeeth'].length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = note['affectedTeeth'][index];
//                       return Container(
//                         decoration: BoxDecoration(
//                           color: MyColors.colorPalette['primary'],
//                           border: Border.all(
//                             color: MyColors.colorPalette['primary'] ??
//                                 Colors.blueAccent,
//                             width: 1,
//                           ),
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         child: Center(
//                           child: Text(
//                             '$toothNumber',
//                             style: MyTextStyle.textStyleMap['label-medium']
//                                 ?.copyWith(
//                               color: MyColors.colorPalette['on-primary'],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 8),
//                   Column(
//                     children: [
//                       Align(
//                         alignment: Alignment.topLeft,
//                         child: Text(
//                           'Doctor\'s Note',
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['on-surface']),
//                         ),
//                       ),
//                       Align(
//                         alignment: Alignment.topLeft,
//                         child: Text(
//                           '${note['doctorNote']}',
//                           style: MyTextStyle.textStyleMap['label-small']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['on-surface']),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Future<void> deleteNoteFromBackend(String noteId) async {
//     try {
//       final clinicId = widget.clinicId;
//       final patientId = widget.patientId;
//       final treatmentId = widget.treatmentId;

//       // Reference to the specific note document in the backend
//       final noteDocRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId)
//           .collection('treatments')
//           .doc(treatmentId)
//           .collection('notes')
//           .doc(noteId);

//       // Delete the note from Firestore
//       await noteDocRef.delete();

//       // Remove the note from the local state
//       setState(() {
//         existingNotes.removeWhere((note) => note['noteId'] == noteId);
//       });

//       devtools.log('Note with noteId $noteId deleted successfully');
//     } catch (e) {
//       devtools.log('Error deleting note with noteId $noteId: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (!showAddNewCard) // Only show when not adding a new note
//           Padding(
//             padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Text(
//                 'All Notes',
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//             ),
//           ),
//         if (!showAddNewCard && existingNotes.isNotEmpty)
//           _buildExistingNotesCards()
//         else if (!showAddNewCard)
//           Padding(
//             padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Text(
//                 'No notes taken so far',
//                 style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         if (!showAddNewCard) // Only show when not adding a new note
//           Padding(
//             padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: SizedBox(
//                 height: 48,
//                 child: ElevatedButton(
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all(
//                         MyColors.colorPalette['on-primary']!),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         side: BorderSide(
//                             color: MyColors.colorPalette['primary']!,
//                             width: 1.0),
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       showAddNewCard = true; // Show the card when pressed
//                     });
//                   },
//                   child: Wrap(
//                     children: [
//                       Icon(
//                         Icons.add,
//                         color: MyColors.colorPalette['primary'],
//                       ),
//                       Text(
//                         'Add New',
//                         style: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(color: MyColors.colorPalette['primary']),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         if (showAddNewCard) _buildAddNewCard(), // Render the card if toggled
//       ],
//     );
//   }

//   // ------------------------------------------------------------------------ //

//   Widget _buildAddNewCard() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     DateFormat('MMMM dd, EEEE').format(currentDate),
//                     style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         showAddNewCard = false; // Hide the card on close
//                       });
//                     },
//                     child: Icon(
//                       Icons.close,
//                       size: 24,
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Mark Affected Teeth',
//                 style: MyTextStyle.textStyleMap['title-medium']
//                     ?.copyWith(color: MyColors.colorPalette['secondary']),
//               ),
//               const SizedBox(height: 8),
//               GridView.builder(
//                 shrinkWrap: true,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 8,
//                   childAspectRatio: 1,
//                 ),
//                 itemCount: flatToothTable.length,
//                 itemBuilder: (context, index) {
//                   int toothNumber = flatToothTable[index];
//                   bool isSelected = affectedTeeth.contains(toothNumber);

//                   return GestureDetector(
//                     onTap: () => toggleToothSelection(toothNumber),
//                     child: Container(
//                       margin: const EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? MyColors.colorPalette['primary']
//                             : Colors.transparent,
//                         border: Border.all(
//                           color: isSelected
//                               ? MyColors.colorPalette['primary'] ??
//                                   Colors.blueAccent
//                               : MyColors.colorPalette['on-surface'] ??
//                                   Colors.grey,
//                           width: 1,
//                         ),
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '$toothNumber',
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                             color: isSelected
//                                 ? MyColors.colorPalette['on-primary']
//                                 : MyColors.colorPalette['on-surface'],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Add Note',
//                 style: MyTextStyle.textStyleMap['title-medium']
//                     ?.copyWith(color: MyColors.colorPalette['secondary']),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     width: 1,
//                     color: MyColors.colorPalette['on-surface'] ??
//                         const Color(0xFF011718),
//                   ),
//                   borderRadius: BorderRadius.circular(5.0),
//                 ),
//                 child: TextFormField(
//                   controller: doctorNoteController,
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.all(16.0),
//                   ),
//                   maxLines: null,
//                   style: MyTextStyle.textStyleMap['label-large']
//                       ?.copyWith(color: MyColors.colorPalette['secondary']),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       height: 48,
//                       width: 144,
//                       child: ElevatedButton(
//                         style: ButtonStyle(
//                           backgroundColor: MaterialStateProperty.all(
//                               MyColors.colorPalette['primary']!),
//                           shape: MaterialStateProperty.all(
//                             RoundedRectangleBorder(
//                               side: BorderSide(
//                                 color: MyColors.colorPalette['primary']!,
//                                 width: 1.0,
//                               ),
//                               borderRadius: BorderRadius.circular(24.0),
//                             ),
//                           ),
//                         ),
//                         // onPressed: () {
//                         //   // Implement the Add functionality here
//                         // },
//                         onPressed: addNoteToBackend,
//                         child: Text(
//                           'Add',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['on-primary']),
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         setState(() {
//                           showAddNewCard = false; // Cancel and hide the card
//                         });
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
