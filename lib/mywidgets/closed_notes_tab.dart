import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/note_service.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;

class ClosedNotesTab extends StatefulWidget {
  final String clinicId;
  final String patientId;
  final String? treatmentId;

  const ClosedNotesTab({
    super.key,
    required this.clinicId,
    required this.patientId,
    required this.treatmentId,
  });

  @override
  State<ClosedNotesTab> createState() => _ClosedNotesTabState();
}

class _ClosedNotesTabState extends State<ClosedNotesTab> {
  List<Map<String, dynamic>> savedNotes = [];
  bool notesFetched = false;
  late NoteService _noteService;

  @override
  void initState() {
    super.initState();
    _noteService = NoteService(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      treatmentId: widget.treatmentId!,
    );
    fetchSavedNotes();
  }

  Future<void> fetchSavedNotes() async {
    try {
      final notes =
          await _noteService.fetchNotes(); // Fetch notes from NoteService
      setState(() {
        savedNotes = notes;
        notesFetched = true;
      });
    } catch (e) {
      devtools.log('Error fetching saved notes: $e');
    }
  }

  Widget _buildToothChips(List<int> affectedTeeth) {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling in GridView
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8, // Display 8 teeth per row
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        childAspectRatio: 1,
      ),
      itemCount: affectedTeeth.length,
      itemBuilder: (context, index) {
        int toothNumber = affectedTeeth[index];
        return Container(
          decoration: BoxDecoration(
            color: MyColors.colorPalette['primary'],
            border: Border.all(
              color: MyColors.colorPalette['primary'] ?? Colors.blueAccent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              '$toothNumber',
              style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
                color: MyColors.colorPalette['on-primary'],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!notesFetched) {
      return const Center(child: CircularProgressIndicator());
    } else if (savedNotes.isEmpty) {
      return Center(
        child: Text(
          'No notes available',
          style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
            color: MyColors.colorPalette['on-surface-variant'],
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: savedNotes.map((note) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the note date
                    Text(
                      note['timestamp'], // Already formatted in NoteService
                      style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
                        color: MyColors.colorPalette['on-surface'],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Display affected teeth
                    Text(
                      'Affected Teeth:',
                      style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
                        color: MyColors.colorPalette['on-surface'],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // _buildToothChips(note['affectedTeeth']),
                    _buildToothChips(List<int>.from(note['affectedTeeth'])),

                    const SizedBox(height: 8),
                    // Display doctor's note
                    Text(
                      'Doctor\'s Note:',
                      style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
                        color: MyColors.colorPalette['on-surface'],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note['doctorNote'],
                      style: MyTextStyle.textStyleMap['label-small']?.copyWith(
                        color: MyColors.colorPalette['on-surface'],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/firestore/note_service.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:developer' as devtools show log;

// class ClosedNotesTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;

//   const ClosedNotesTab({
//     super.key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   });

//   @override
//   State<ClosedNotesTab> createState() => _ClosedNotesTabState();
// }

// class _ClosedNotesTabState extends State<ClosedNotesTab> {
//   List<Map<String, dynamic>> savedNotes = [];
//   bool notesFetched = false;
//   late NoteService _noteService;

//   @override
//   void initState() {
//     super.initState();
//     _noteService = NoteService(
//       clinicId: widget.clinicId,
//       patientId: widget.patientId,
//       treatmentId: widget.treatmentId!,
//     );
//     fetchSavedNotes();
//   }

//   Future<void> fetchSavedNotes() async {
//     try {
//       final notes =
//           await _noteService.fetchNotes(); // Fetch notes from NoteService
//       setState(() {
//         savedNotes = notes.map((note) {
//           // Explicitly cast affectedTeeth to List<int>
//           return {
//             'noteId': note['noteId'],
//             'date': note['date'],
//             'affectedTeeth': List<int>.from(note['affectedTeeth']), // Fix here
//             'doctorNote': note['doctorNote'],
//           };
//         }).toList();
//         notesFetched = true;
//       });
//     } catch (e) {
//       devtools.log('Error fetching saved notes: $e');
//     }
//   }

//   String _formatTimestamp(Timestamp? timestamp) {
//     if (timestamp == null) {
//       return '';
//     }
//     final dateTime = timestamp.toDate();
//     return DateFormat('MMMM dd, yyyy').format(dateTime);
//   }

//   Widget _buildToothChips(List<int> affectedTeeth) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics:
//           const NeverScrollableScrollPhysics(), // Disable scrolling in GridView
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 8, // Display 8 teeth per row
//         crossAxisSpacing: 4.0,
//         mainAxisSpacing: 4.0,
//         childAspectRatio: 1,
//       ),
//       itemCount: affectedTeeth.length,
//       itemBuilder: (context, index) {
//         int toothNumber = affectedTeeth[index];
//         return Container(
//           decoration: BoxDecoration(
//             color: MyColors.colorPalette['primary'],
//             border: Border.all(
//               color: MyColors.colorPalette['primary'] ?? Colors.blueAccent,
//               width: 1,
//             ),
//             borderRadius: BorderRadius.circular(5),
//           ),
//           child: Center(
//             child: Text(
//               '$toothNumber',
//               style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                 color: MyColors.colorPalette['on-primary'],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!notesFetched) {
//       return const Center(child: CircularProgressIndicator());
//     } else if (savedNotes.isEmpty) {
//       return Center(
//         child: Text(
//           'No notes available',
//           style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//             color: MyColors.colorPalette['on-surface-variant'],
//           ),
//         ),
//       );
//     } else {
//       return SingleChildScrollView(
//         child: Column(
//           children: savedNotes.map((note) {
//             final formattedDate = _formatTimestamp(note['date']);
//             return Card(
//               margin: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Display the note date
//                     Text(
//                       formattedDate,
//                       style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     // Display affected teeth
//                     Text(
//                       'Affected Teeth:',
//                       style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _buildToothChips(note['affectedTeeth']),
//                     const SizedBox(height: 8),
//                     // Display doctor's note
//                     Text(
//                       'Doctor\'s Note:',
//                       style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       note['doctorNote'],
//                       style: MyTextStyle.textStyleMap['label-small']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       );
//     }
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/notes_data_model.dart';
// import 'dart:developer' as devtools show log;
// import 'read_only_note_container.dart';

// class ClosedNotesTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;

//   const ClosedNotesTab({
//     super.key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   });

//   @override
//   State<ClosedNotesTab> createState() => _ClosedNotesTabState();
// }

// class _ClosedNotesTabState extends State<ClosedNotesTab> {
//   List<NotesDataModel> savedNotes = [];
//   bool notesFetched = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchSavedNotes();
//   }

//   Future<void> fetchSavedNotes() async {
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

//       List<NotesDataModel> fetchedNotes = notesQuery.docs.map((doc) {
//         final data = doc.data();
//         return NotesDataModel(
//           noteId: data['noteId'],
//           doctorNote: data['doctorNote'] ?? '',
//           q1: data['q1'] ?? '',
//           q2: data['q2'] ?? '',
//           q3: data['q3'] ?? '',
//           q4: data['q4'] ?? '',
//           timestamp: data['timestamp'] != null
//               ? _formatTimestamp(data['timestamp'])
//               : '',
//         );
//       }).toList();

//       setState(() {
//         savedNotes = fetchedNotes;
//         notesFetched = true;
//       });
//     } catch (e) {
//       devtools.log('Error fetching saved notes: $e');
//     }
//   }

//   String _formatTimestamp(Timestamp? timestamp) {
//     if (timestamp == null) {
//       return '';
//     }
//     final dateTime = timestamp.toDate();
//     return DateFormat('MMMM dd, yyyy').format(dateTime);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!notesFetched) {
//       return const Center(child: CircularProgressIndicator());
//     } else if (savedNotes.isEmpty) {
//       return Center(
//         child: Text(
//           'No notes available',
//           style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//             color: MyColors.colorPalette['on-surface-variant'],
//           ),
//         ),
//       );
//     } else {
//       return SingleChildScrollView(
//         child: Column(
//           children: savedNotes.map((note) {
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ReadOnlyNoteContainer(
//                 containerHeight: MediaQuery.of(context).size.height / 8,
//                 data: AddEmptyContainerData(
//                   id: note.noteId,
//                   doctorNote: note.doctorNote,
//                   q1: note.q1,
//                   q2: note.q2,
//                   q3: note.q3,
//                   q4: note.q4,
//                   timestamp: note.timestamp, // Pass timestamp here
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       );
//     }
//   }
// }

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/notes_data_model.dart';
// import 'dart:developer' as devtools show log;
// import 'read_only_note_container.dart';

// class ClosedNotesTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;

//   const ClosedNotesTab({
//     Key? key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   }) : super(key: key);

//   @override
//   _ClosedNotesTabState createState() => _ClosedNotesTabState();
// }

// class _ClosedNotesTabState extends State<ClosedNotesTab> {
//   List<NotesDataModel> savedNotes = [];
//   bool notesFetched = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchSavedNotes();
//   }

//   Future<void> fetchSavedNotes() async {
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

//       List<NotesDataModel> fetchedNotes = notesQuery.docs.map((doc) {
//         final data = doc.data();
//         return NotesDataModel(
//           noteId: data['noteId'],
//           doctorNote: data['doctorNote'] ?? '',
//           q1: data['q1'] ?? '',
//           q2: data['q2'] ?? '',
//           q3: data['q3'] ?? '',
//           q4: data['q4'] ?? '',
//           timestamp: data['timestamp'] != null
//               ? _formatTimestamp(data['timestamp'])
//               : '',
//         );
//       }).toList();
//       devtools.log('fetchedNotes are $fetchedNotes');

//       setState(() {
//         savedNotes = fetchedNotes;
//         notesFetched = true;
//       });
//     } catch (e) {
//       devtools.log('Error fetching saved notes: $e');
//     }
//   }

//   String _formatTimestamp(Timestamp? timestamp) {
//     if (timestamp == null) {
//       return '';
//     }
//     final dateTime = timestamp.toDate();
//     return DateFormat('MMMM dd, yyyy').format(dateTime);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!notesFetched) {
//       return const Center(child: CircularProgressIndicator());
//     } else if (savedNotes.isEmpty) {
//       return Center(
//         child: Text(
//           'No notes available',
//           style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//             color: MyColors.colorPalette['on-surface-variant'],
//           ),
//         ),
//       );
//     } else {
//       return SingleChildScrollView(
//         child: Column(
//           children: savedNotes.map((note) {
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ReadOnlyNoteContainer(
//                 containerHeight: MediaQuery.of(context).size.height / 8,
//                 data: AddEmptyContainerData(
//                   id: note.noteId,
//                   doctorNote: note.doctorNote,
//                   q1: note.q1,
//                   q2: note.q2,
//                   q3: note.q3,
//                   q4: note.q4,
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       );
//     }
//   }
// }

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// CODE BELOW LIST THE FETCHED NOTE DATA CORRECTLY
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/notes_data_model.dart';
// import 'dart:developer' as devtools show log;

// class ClosedNotesTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;

//   const ClosedNotesTab({
//     Key? key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   }) : super(key: key);

//   @override
//   _ClosedNotesTabState createState() => _ClosedNotesTabState();
// }

// class _ClosedNotesTabState extends State<ClosedNotesTab> {
//   List<NotesDataModel> savedNotes = [];
//   bool notesFetched = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchSavedNotes();
//   }

//   Future<void> fetchSavedNotes() async {
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

//       List<NotesDataModel> fetchedNotes = notesQuery.docs.map((doc) {
//         final data = doc.data();
//         return NotesDataModel(
//           noteId: data['noteId'],
//           doctorNote: data['doctorNote'] ?? '',
//           q1: data['q1'] ?? '',
//           q2: data['q2'] ?? '',
//           q3: data['q3'] ?? '',
//           q4: data['q4'] ?? '',
//           timestamp: data['timestamp'] != null
//               ? _formatTimestamp(data['timestamp'])
//               : '',
//         );
//       }).toList();

//       setState(() {
//         savedNotes = fetchedNotes;
//         notesFetched = true;
//       });
//     } catch (e) {
//       devtools.log('Error fetching saved notes: $e');
//     }
//   }

//   String _formatTimestamp(Timestamp? timestamp) {
//     if (timestamp == null) {
//       return '';
//     }
//     final dateTime = timestamp.toDate();
//     return DateFormat('MMMM dd, yyyy').format(dateTime);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!notesFetched) {
//       return const Center(child: CircularProgressIndicator());
//     } else if (savedNotes.isEmpty) {
//       return Center(
//         child: Text(
//           'No notes available',
//           style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//             color: MyColors.colorPalette['on-surface-variant'],
//           ),
//         ),
//       );
//     } else {
//       return SingleChildScrollView(
//         child: Column(
//           children: savedNotes.map((note) {
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: MyColors.colorPalette['on-surface']!,
//                     width: 1.0,
//                   ),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Note ID: ${note.noteId}',
//                       style: MyTextStyle.textStyleMap['title-medium'],
//                     ),
//                     const SizedBox(height: 8.0),
//                     Text(
//                       note.doctorNote,
//                       style: MyTextStyle.textStyleMap['body-large'],
//                     ),
//                     const SizedBox(height: 8.0),
//                     Text('Q1: ${note.q1}'),
//                     Text('Q2: ${note.q2}'),
//                     Text('Q3: ${note.q3}'),
//                     Text('Q4: ${note.q4}'),
//                     const SizedBox(height: 8.0),
//                     Text(
//                       'Date: ${note.timestamp}',
//                       style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                         color: MyColors.colorPalette['outline'],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       );
//     }
//   }
// }


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/notes_data_model.dart';
// import 'dart:developer' as devtools show log;

// class ClosedNotesTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;

//   const ClosedNotesTab({
//     Key? key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   }) : super(key: key);

//   @override
//   _ClosedNotesTabState createState() => _ClosedNotesTabState();
// }

// class _ClosedNotesTabState extends State<ClosedNotesTab> {
//   List<NotesDataModel> savedNotes = [];
//   bool notesFetched = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchSavedNotes();
//   }

//   Future<void> fetchSavedNotes() async {
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

//       List<NotesDataModel> fetchedNotes = notesQuery.docs.map((doc) {
//         final data = doc.data();
//         return NotesDataModel(
//           noteId: data['noteId'],
//           doctorNote: data['doctorNote'] ?? '',
//           q1: data['q1'] ?? '',
//           q2: data['q2'] ?? '',
//           q3: data['q3'] ?? '',
//           q4: data['q4'] ?? '',
//           timestamp: data['timestamp'] != null
//               ? _formatTimestamp(data['timestamp'])
//               : '',
//         );
//       }).toList();

//       setState(() {
//         savedNotes = fetchedNotes;
//         notesFetched = true;
//       });
//     } catch (e) {
//       devtools.log('Error fetching saved notes: $e');
//     }
//   }

//   String _formatTimestamp(Timestamp? timestamp) {
//     if (timestamp == null) {
//       return '';
//     }
//     final dateTime = timestamp.toDate();
//     return DateFormat('MMMM dd, yyyy').format(dateTime);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!notesFetched) {
//       return const Center(child: CircularProgressIndicator());
//     } else if (savedNotes.isEmpty) {
//       return Center(
//         child: Text(
//           'No notes available',
//           style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//             color: MyColors.colorPalette['on-surface-variant'],
//           ),
//         ),
//       );
//     } else {
//       return ListView.builder(
//         itemCount: savedNotes.length,
//         itemBuilder: (context, index) {
//           final note = savedNotes[index];
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: MyColors.colorPalette['on-surface']!,
//                   width: 1.0,
//                 ),
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Note ID: ${note.noteId}',
//                     style: MyTextStyle.textStyleMap['title-medium'],
//                   ),
//                   const SizedBox(height: 8.0),
//                   Text(
//                     note.doctorNote,
//                     style: MyTextStyle.textStyleMap['body-large'],
//                   ),
//                   const SizedBox(height: 8.0),
//                   Text('Q1: ${note.q1}'),
//                   Text('Q2: ${note.q2}'),
//                   Text('Q3: ${note.q3}'),
//                   Text('Q4: ${note.q4}'),
//                   const SizedBox(height: 8.0),
//                   Text(
//                     'Date: ${note.timestamp}',
//                     style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                       color: MyColors.colorPalette['outline'],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     }
//   }
// }



// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/notes_data_model.dart';
// import 'package:neocare_dental_app/mywidgets/render_treatment_data_container.dart';

// class ClosedNotesTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;

//   const ClosedNotesTab({
//     super.key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   });

//   @override
//   State<ClosedNotesTab> createState() => _ClosedNotesTabState();
// }

// class _ClosedNotesTabState extends State<ClosedNotesTab> {
//   List<Map<String, dynamic>> existingNotes = [];
//   bool notesFetched = false;

//   @override
//   void initState() {
//     super.initState();
//     // Fetch notes when the ClosedNotesTab is first displayed
//     if (!notesFetched) {
//       fetchNotes();
//     }
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

//       devtools.log('Before clearing existingNotes: $existingNotes');
//       existingNotes.clear();
//       devtools.log('After clearing existingNotes: $existingNotes');

//       for (final doc in notesQuery.docs) {
//         final Map<String, dynamic> data = doc.data();
//         final timestamp = data['timestamp'] != null
//             ? _formatTimestamp(data['timestamp'])
//             : '';

//         existingNotes.add({
//           'noteId': doc.id,
//           'timestamp': timestamp,
//           'doctorNote': data['doctorNote'] ?? '',
//           'q1': data['q1'] ?? '',
//           'q2': data['q2'] ?? '',
//           'q3': data['q3'] ?? '',
//           'q4': data['q4'] ?? '',
//         });
//       }

//       setState(() {
//         notesFetched = true;
//         devtools.log('Notes fetched: $existingNotes');
//       });
//     } catch (e) {
//       devtools.log('Error fetching notes data: $e');
//     }
//   }

//   String _formatTimestamp(Timestamp? timestamp) {
//     if (timestamp == null) {
//       return ''; // Return an empty string if the timestamp is null
//     }
//     final dateTime =
//         timestamp.toDate(); // Convert the Firestore Timestamp to DateTime
//     final formattedDate = DateFormat('MMMM dd, EEEE')
//         .format(dateTime); // Format the DateTime as desired
//     return formattedDate;
//   }

//   Widget _buildNoteContainer(Map<String, dynamic> note) {
//     return RenderTreatmentDataContainer(
//       containerHeight: 150.0, // Adjust the height as needed
//       data: TreatmentDataModel(
//         doctorNote: note['doctorNote'] ?? '',
//         q1: note['q1'] ?? '',
//         q2: note['q2'] ?? '',
//         q3: note['q3'] ?? '',
//         q4: note['q4'] ?? '',
//       ),
//     );
//   }

//   Widget _buildExistingNotesContainer() {
//     return Column(
//       children: existingNotes.map((note) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildNoteContainer(note),
//             const SizedBox(height: 8.0),
//           ],
//         );
//       }).toList(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!notesFetched) {
//       // Show a loading indicator or placeholder while fetching notes
//       return const CircularProgressIndicator(); // You can replace this with your loading indicator widget
//     } else {
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Text(
//                 'All Notes',
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//             ),
//           ),
//           if (existingNotes.isNotEmpty)
//             _buildExistingNotesContainer()
//           else
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Align(
//                 alignment: Alignment.topLeft,
//                 child: Text(
//                   'No notes taken so far',
//                   style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface-variant']),
//                 ),
//               ),
//             ),
//         ],
//       );
//     }
//   }
// }


// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/add_empty_note_container.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/notes_data_model.dart';
// import 'package:neocare_dental_app/mywidgets/render_notes_data_edit_mode_container.dart';

// class ClosedNotesTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;
//   const ClosedNotesTab({
//     super.key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   });

//   @override
//   State<ClosedNotesTab> createState() => _ClosedNotesTabState();
// }

// class _ClosedNotesTabState extends State<ClosedNotesTab> {
//   String doctorNote = '';
//   String q1 = '';
//   String q2 = '';
//   String q3 = '';
//   String q4 = '';
//   List<AddEmptyNoteContainer> containers = [];
//   int containerCount = 1;

//   List<AddEmptyNoteContainerData> containersData = [];
//   String noteId = '';

//   List<AddEmptyNoteContainerData> unsavedNotes = [];
//   List<AddEmptyNoteContainerData> savedNotes = [];

//   List<Map<String, dynamic>> existingNotes = [];
//   bool notesFetched = false;
//   List<Widget> noteContainers = [];

//   bool _isEditMode = false;

//   NotesDataModel? editedData;

//   @override
//   void initState() {
//     super.initState();

//     // Fetch notes when the NotesTab is first displayed
//     if (!notesFetched) {
//       fetchNotes();
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

  

//   Widget _buildNoteContainer(Map<String, dynamic> note) {
//     final String timestamp = note['timestamp'] ?? '';
//     final String noteId = note['noteId'] ?? '';

//     return RenderNotesDataEditModeContainer(
//       data: NotesDataModel(
//         noteId: noteId,
//         doctorNote: note['doctorNote'] ?? '',
//         q1: note['q1'] ?? '',
//         q2: note['q2'] ?? '',
//         q3: note['q3'] ?? '',
//         q4: note['q4'] ?? '',
//         timestamp: timestamp,
//       ),
//       onEdit: (String editedDoctorNote, NotesDataModel editedModel) async {
//         await saveEditedNote(
//           noteId,
//           NotesDataModel(
//             noteId: editedModel.noteId,
//             doctorNote: editedDoctorNote,
//             q1: editedModel.q1,
//             q2: editedModel.q2,
//             q3: editedModel.q3,
//             q4: editedModel.q4,
//             timestamp: timestamp,
//           ),
//         );
//       },
//       clinicId: widget.clinicId,
//       patientId: widget.patientId,
//       treatmentId: widget.treatmentId,
//       //onDeleteNote: onDeleteNote,
//     );
//   }

//   Widget _buildExistingNotesContainer() {
//     return Column(
//       children: existingNotes.map((note) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildNoteContainer(note),
//             const SizedBox(height: 8.0),
//           ],
//         );
//       }).toList(),
//     );
//   }

//   void addContainer() {
//     setState(() {
//       unsavedNotes.add(AddEmptyNoteContainerData(
//         doctorNote: doctorNote,
//         q1: q1,
//         q2: q2,
//         q3: q3,
//         q4: q4,
//       ));
//       containerCount++;
//       containers.add(
//         AddEmptyNoteContainer(
//           data: unsavedNotes.last,
//           onSave: (updatedData) async {
//             // Handle the updated data, e.g., save it to the backend
//             devtools.log('Welcome back to onSave callback');
//             devtools.log('updatedData is $updatedData');
//             devtools.log('editedData is ${updatedData.doctorNote}');
//             devtools.log('editedData is ${updatedData.q1}');
//             devtools.log('editedData is ${updatedData.q2}');
//             devtools.log('editedData is ${updatedData.q3}');
//             devtools.log('editedData is ${updatedData.q4}');
//             //return await saveNotes(updatedData);
//           },
//         ),
//       );
//     });
//   }

  

//   String _formatTimestamp(Timestamp? timestamp) {
//     if (timestamp == null) {
//       return ''; // Return an empty string if the timestamp is null
//     }
//     final dateTime =
//         timestamp.toDate(); // Convert the Firestore Timestamp to DateTime

//     final formattedDate = DateFormat('MMMM dd, EEEE')
//         .format(dateTime); // Format the DateTime as desired
//     return formattedDate;
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

//       devtools.log('Before clearing existingNotes: $existingNotes');
//       existingNotes.clear();
//       devtools.log('After clearing existingNotes: $existingNotes');

//       for (final doc in notesQuery.docs) {
//         final Map<String, dynamic> data = doc.data();
//         final timestamp = data['timestamp'] != null
//             ? _formatTimestamp(data['timestamp'])
//             : '';

//         final doctorNote = data['doctorNote'] ?? '';
//         final q1 = data['q1'] ?? ''; // Add this line for q1
//         final q2 = data['q2'] ?? ''; // Add this line for q2
//         final q3 = data['q3'] ?? ''; // Add this line for q3
//         final q4 = data['q4'] ?? ''; // Add this line for q4
//         final noteId = doc.id;

//         existingNotes.add({
//           'noteId': noteId,
//           'timestamp': timestamp,
//           'doctorNote': doctorNote,
//           'q1': q1,
//           'q2': q2,
//           'q3': q3,
//           'q4': q4,
//         });
//       }

//       if (existingNotes.isEmpty) {
//         // Handle case when there are no existing notes
//         // You can set a flag or display a message like 'No notes available so far.'
//       }

//       // Set notesFetched to true after successfully fetching notes
//       setState(() {
//         notesFetched = true;
//         devtools.log(
//             'This is coming from inside fetchNotes. existingNotes is $existingNotes');
//       });
//     } catch (e) {
//       devtools.log('Error fetching notes data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('doctorNote: $doctorNote, q1: $q1, q2: $q2, q3: $q3, q4: $q4');
//     if (!notesFetched) {
//       // Show a loading indicator or placeholder while fetching notes
//       return const CircularProgressIndicator(); // You can replace this with your loading indicator widget
//     } else {
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Text(
//                 'All Notes',
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//             ),
//           ),
//           if (existingNotes.isNotEmpty)
//             _buildExistingNotesContainer()
//           else
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Align(
//                 alignment: Alignment.topLeft,
//                 child: Text(
//                   'No notes taken so far',
//                   style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface-variant']),
//                 ),
//               ),
//             ),
//           Column(
//             children: containers.map((container) {
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _isEditMode = true;
//                   });
//                 },
//                 child: container,
//               );
//             }).toList(),
//           ),
          
//         ],
//       );
//     }
//   }
// }
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/add_empty_note_container.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/notes_data_model.dart';
// import 'package:neocare_dental_app/mywidgets/render_notes_data_edit_mode_container.dart';

// class ClosedNotesTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;
//   const ClosedNotesTab({
//     super.key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   });

//   @override
//   State<ClosedNotesTab> createState() => _ClosedNotesTabState();
// }

// class _ClosedNotesTabState extends State<ClosedNotesTab> {
//   String doctorNote = '';
//   String q1 = '';
//   String q2 = '';
//   String q3 = '';
//   String q4 = '';
//   List<AddEmptyNoteContainer> containers = [];
//   int containerCount = 1;

//   List<AddEmptyNoteContainerData> containersData = [];
//   String noteId = '';

//   List<AddEmptyNoteContainerData> unsavedNotes = [];
//   List<AddEmptyNoteContainerData> savedNotes = [];

//   List<Map<String, dynamic>> existingNotes = [];
//   bool notesFetched = false;
//   List<Widget> noteContainers = [];

//   bool _isEditMode = false;

//   NotesDataModel? editedData;

//   @override
//   void initState() {
//     super.initState();

//     // Fetch notes when the NotesTab is first displayed
//     if (!notesFetched) {
//       fetchNotes();
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   // void toggleEditMode() {
//   //   setState(() {
//   //     _isEditMode = !_isEditMode;
//   //   });
//   // }

//   // Callback to update the state and remove the deleted note from the UI
//   // void onDeleteNote() {
//   //   if (existingNotes.isNotEmpty) {
//   //     // If existing notes are already fetched, do nothing
//   //     devtools.log('existingNotes is still Not Empty');
//   //   }
//   //   // No need to manually filter out the deleted note
//   //   // Simply trigger a rebuild by setting notesFetched to false
//   //   setState(() {
//   //     notesFetched = false;
//   //   });

//   //   // Fetch notes again, and Flutter will rebuild the UI
//   //   fetchNotes();
//   // }

//   Widget _buildNoteContainer(Map<String, dynamic> note) {
//     final String timestamp = note['timestamp'] ?? '';
//     final String noteId = note['noteId'] ?? '';

//     return RenderNotesDataEditModeContainer(
//       data: NotesDataModel(
//         noteId: noteId,
//         doctorNote: note['doctorNote'] ?? '',
//         q1: note['q1'] ?? '',
//         q2: note['q2'] ?? '',
//         q3: note['q3'] ?? '',
//         q4: note['q4'] ?? '',
//         timestamp: timestamp,
//       ),
//       onEdit: (String editedDoctorNote, NotesDataModel editedModel) async {
//         await saveEditedNote(
//           noteId,
//           NotesDataModel(
//             noteId: editedModel.noteId,
//             doctorNote: editedDoctorNote,
//             q1: editedModel.q1,
//             q2: editedModel.q2,
//             q3: editedModel.q3,
//             q4: editedModel.q4,
//             timestamp: timestamp,
//           ),
//         );
//       },
//       clinicId: widget.clinicId,
//       patientId: widget.patientId,
//       treatmentId: widget.treatmentId,
//       //onDeleteNote: onDeleteNote,
//     );
//   }

//   Widget _buildExistingNotesContainer() {
//     return Column(
//       children: existingNotes.map((note) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildNoteContainer(note),
//             const SizedBox(height: 8.0),
//           ],
//         );
//       }).toList(),
//     );
//   }

//   void addContainer() {
//     setState(() {
//       unsavedNotes.add(AddEmptyNoteContainerData(
//         doctorNote: doctorNote,
//         q1: q1,
//         q2: q2,
//         q3: q3,
//         q4: q4,
//       ));
//       containerCount++;
//       containers.add(
//         AddEmptyNoteContainer(
//           data: unsavedNotes.last,
//           onSave: (updatedData) async {
//             // Handle the updated data, e.g., save it to the backend
//             devtools.log('Welcome back to onSave callback');
//             devtools.log('updatedData is $updatedData');
//             devtools.log('editedData is ${updatedData.doctorNote}');
//             devtools.log('editedData is ${updatedData.q1}');
//             devtools.log('editedData is ${updatedData.q2}');
//             devtools.log('editedData is ${updatedData.q3}');
//             devtools.log('editedData is ${updatedData.q4}');
//             //return await saveNotes(updatedData);
//           },
//         ),
//       );
//     });
//   }

//   // Future<void> saveNotes(AddEmptyNoteContainerData updatedData) async {
//   //   devtools.log('Welcome to saveNotes');

//   //   // Call the function to push unsaved notes to the backend
//   //   await pushUnsavedNotesToBackend(updatedData);
//   // }

//   // Future<void> pushUnsavedNotesToBackend(
//   //     AddEmptyNoteContainerData updatedData) async {
//   //   devtools.log('Welcome to pushUnsavedNotesToBackend');
//   //   try {
//   //     final clinicId = widget.clinicId;
//   //     final patientId = widget.patientId;
//   //     final treatmentId = widget.treatmentId;

//   //     Map<String, dynamic> noteData = {
//   //       'doctorNote': updatedData.doctorNote,
//   //       'q1': updatedData.q1,
//   //       'q2': updatedData.q2,
//   //       'q3': updatedData.q3,
//   //       'q4': updatedData.q4,
//   //       'timestamp': FieldValue.serverTimestamp(),
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

//   //     // Add the note document to Firestore
//   //     final noteDocRef = await notesCollectionRef.add(noteData);

//   //     // Get the generated noteId from the document reference
//   //     final noteId = noteDocRef.id;

//   //     // Update the note document with the obtained noteId
//   //     await noteDocRef.update({'noteId': noteId});

//   //     // Add the note to existingNotes immediately
//   //     existingNotes.add({
//   //       'noteId': noteId,
//   //       'timestamp': _formatTimestamp(Timestamp.now()),
//   //       'doctorNote': updatedData.doctorNote,
//   //       'q1': updatedData.q1,
//   //       'q2': updatedData.q2,
//   //       'q3': updatedData.q3,
//   //       'q4': updatedData.q4,
//   //     });

//   //     unsavedNotes.clear();

//   //     devtools.log('Note data pushed to the backend successfully');
//   //   } catch (e) {
//   //     devtools.log('Error saving notes data: $e');
//   //   }
//   // }

//   // Future<void> saveEditedNote(String noteId, NotesDataModel editedData) async {
//   //   try {
//   //     final clinicId = widget.clinicId;
//   //     final patientId = widget.patientId;
//   //     final treatmentId = widget.treatmentId;

//   //     // Update the note in the Firestore collection using the noteId
//   //     final noteRef = FirebaseFirestore.instance
//   //         .collection('clinics')
//   //         .doc(clinicId)
//   //         .collection('patients')
//   //         .doc(patientId)
//   //         .collection('treatments')
//   //         .doc(treatmentId)
//   //         .collection('notes')
//   //         .doc(noteId);

//   //     await noteRef.update({
//   //       'doctorNote': editedData.doctorNote,
//   //       'q1': editedData.q1,
//   //       'q2': editedData.q2,
//   //       'q3': editedData.q3,
//   //       'q4': editedData.q4,
//   //       'timestamp': FieldValue.serverTimestamp(),
//   //     });

//   //     // ... rest of the code
//   //   } catch (e) {
//   //     // Handle error
//   //     devtools.log('Error saving edited note data: $e');
//   //   }
//   // }

//   String _formatTimestamp(Timestamp? timestamp) {
//     if (timestamp == null) {
//       return ''; // Return an empty string if the timestamp is null
//     }
//     final dateTime =
//         timestamp.toDate(); // Convert the Firestore Timestamp to DateTime

//     final formattedDate = DateFormat('MMMM dd, EEEE')
//         .format(dateTime); // Format the DateTime as desired
//     return formattedDate;
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

//       devtools.log('Before clearing existingNotes: $existingNotes');
//       existingNotes.clear();
//       devtools.log('After clearing existingNotes: $existingNotes');

//       for (final doc in notesQuery.docs) {
//         final Map<String, dynamic> data = doc.data();
//         final timestamp = data['timestamp'] != null
//             ? _formatTimestamp(data['timestamp'])
//             : '';

//         final doctorNote = data['doctorNote'] ?? '';
//         final q1 = data['q1'] ?? ''; // Add this line for q1
//         final q2 = data['q2'] ?? ''; // Add this line for q2
//         final q3 = data['q3'] ?? ''; // Add this line for q3
//         final q4 = data['q4'] ?? ''; // Add this line for q4
//         final noteId = doc.id;

//         existingNotes.add({
//           'noteId': noteId,
//           'timestamp': timestamp,
//           'doctorNote': doctorNote,
//           'q1': q1,
//           'q2': q2,
//           'q3': q3,
//           'q4': q4,
//         });
//       }

//       if (existingNotes.isEmpty) {
//         // Handle case when there are no existing notes
//         // You can set a flag or display a message like 'No notes available so far.'
//       }

//       // Set notesFetched to true after successfully fetching notes
//       setState(() {
//         notesFetched = true;
//         devtools.log(
//             'This is coming from inside fetchNotes. existingNotes is $existingNotes');
//       });
//     } catch (e) {
//       devtools.log('Error fetching notes data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('doctorNote: $doctorNote, q1: $q1, q2: $q2, q3: $q3, q4: $q4');
//     if (!notesFetched) {
//       // Show a loading indicator or placeholder while fetching notes
//       return const CircularProgressIndicator(); // You can replace this with your loading indicator widget
//     } else {
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Text(
//                 'All Notes',
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//             ),
//           ),
//           if (existingNotes.isNotEmpty)
//             _buildExistingNotesContainer()
//           else
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Align(
//                 alignment: Alignment.topLeft,
//                 child: Text(
//                   'No notes taken so far',
//                   style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface-variant']),
//                 ),
//               ),
//             ),
//           Column(
//             children: containers.map((container) {
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _isEditMode = true;
//                   });
//                 },
//                 child: container,
//               );
//             }).toList(),
//           ),
//           // Padding(
//           //   padding: const EdgeInsets.all(8.0),
//           //   child: Align(
//           //     alignment: Alignment.centerLeft,
//           //     child: SizedBox(
//           //       height: 48,
//           //       child: ElevatedButton(
//           //         style: ButtonStyle(
//           //           backgroundColor: MaterialStateProperty.all(
//           //               MyColors.colorPalette['on-primary']!),
//           //           shape: MaterialStateProperty.all(
//           //             RoundedRectangleBorder(
//           //               side: BorderSide(
//           //                   color: MyColors.colorPalette['primary']!,
//           //                   width: 1.0),
//           //               borderRadius: BorderRadius.circular(
//           //                   24.0), // Adjust the radius as needed
//           //             ),
//           //           ),
//           //         ),
//           //         onPressed: addContainer,
//           //         child: Wrap(
//           //           children: [
//           //             Icon(
//           //               Icons.add,
//           //               color: MyColors.colorPalette['primary'],
//           //             ),
//           //             Text(
//           //               'Add New',
//           //               style: MyTextStyle.textStyleMap['label-large']
//           //                   ?.copyWith(color: MyColors.colorPalette['primary']),
//           //             ),
//           //           ],
//           //         ),
//           //       ),
//           //     ),
//           //   ),
//           // ),
//         ],
//       );
//     }
//   }
// }
