import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/firestore/prescription_service.dart';
import 'dart:developer' as devtools show log;

import 'package:neocaresmileapp/mywidgets/prescription_data.dart';

class ClosedPrescriptionTab extends StatefulWidget {
  final String clinicId;
  final VoidCallback navigateToPrescriptionTab;
  final String patientId;
  final String? treatmentId;

  const ClosedPrescriptionTab({
    super.key,
    required this.clinicId,
    required this.navigateToPrescriptionTab,
    required this.patientId,
    required this.treatmentId,
  });

  @override
  State<ClosedPrescriptionTab> createState() => _ClosedPrescriptionTabState();
}

class _ClosedPrescriptionTabState extends State<ClosedPrescriptionTab> {
  List<PrescriptionData> _recentPrescriptionList = [];
  bool _showRecentPrescriptions = false;
  String _recentPrescriptionDate = '';
  late PrescriptionService _prescriptionService;

  @override
  void initState() {
    super.initState();
    // Initialize PrescriptionService
    _prescriptionService = PrescriptionService(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      treatmentId: widget.treatmentId,
    );

    // Load existing prescriptions from PrescriptionService
    _loadExistingPrescriptions();
  }

  Future<void> _loadExistingPrescriptions() async {
    try {
      final existingPrescriptions =
          await _prescriptionService.fetchExistingPrescriptions();

      if (existingPrescriptions.isNotEmpty) {
        DateTime latestPrescriptionDate =
            existingPrescriptions.first.prescriptionDate;

        for (var prescription in existingPrescriptions) {
          if (prescription.prescriptionDate.isAfter(latestPrescriptionDate)) {
            latestPrescriptionDate = prescription.prescriptionDate;
          }
        }

        setState(() {
          _showRecentPrescriptions = true;
          _recentPrescriptionDate =
              DateFormat('MMMM dd, EEEE').format(latestPrescriptionDate);
          _recentPrescriptionList = existingPrescriptions;
        });
      }
    } catch (error) {
      devtools.log('Error loading prescriptions: $error');
    }
  }

  Widget _buildRecentPrescriptionsContainer() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Recent Prescriptions',
              style: MyTextStyle.textStyleMap['title-large']
                  ?.copyWith(color: MyColors.colorPalette['on-surface']),
            ),
          ),
        ),
        for (final closedPrescriptionData in _recentPrescriptionList)
          _buildPrescriptionContainer(closedPrescriptionData),
      ],
    );
  }

  Widget _buildPrescriptionContainer(PrescriptionData PrescriptionData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM dd, EEEE')
                      .format(PrescriptionData.prescriptionDate),
                  style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
                    color: MyColors.colorPalette['outline'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade300),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: PrescriptionData.medicines.map((medicine) {
                  final dose = medicine['dose'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${medicine['medName']}',
                          style: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors.colorPalette['secondary'],
                                  fontWeight: FontWeight.w600),
                        ),
                        if (dose != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Wrap(
                              spacing: 8.0,
                              children: [
                                if (dose['morning'])
                                  Text(
                                    'Morning',
                                    style: MyTextStyle
                                        .textStyleMap['label-large']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['outline']),
                                  ),
                                Text('-',
                                    style: MyTextStyle
                                        .textStyleMap['label-large']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['outline'])),
                                if (dose['afternoon'])
                                  Text(
                                    'Afternoon',
                                    style: MyTextStyle
                                        .textStyleMap['label-large']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['outline']),
                                  ),
                                Text('-',
                                    style: MyTextStyle
                                        .textStyleMap['label-large']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['outline'])),
                                if (dose['evening'])
                                  Text(
                                    'Evening',
                                    style: MyTextStyle
                                        .textStyleMap['label-large']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['outline']),
                                  ),
                                if (dose['sos'])
                                  Text(
                                    'SOS',
                                    style: MyTextStyle
                                        .textStyleMap['label-large']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['outline']),
                                  ),
                                Text(
                                  'x ${medicine['days']} days',
                                  style: MyTextStyle.textStyleMap['label-large']
                                      ?.copyWith(
                                          color:
                                              MyColors.colorPalette['outline']),
                                ),
                              ],
                            ),
                          ),
                        if (medicine['instructions'] != null &&
                            medicine['instructions'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Instructions: ${medicine['instructions']}',
                              style: MyTextStyle.textStyleMap['label-large']
                                  ?.copyWith(
                                      color: MyColors.colorPalette['outline']),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     children: [
  //       if (_showRecentPrescriptions) _buildRecentPrescriptionsContainer(),
  //     ],
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return _showRecentPrescriptions
        ? _buildRecentPrescriptionsContainer()
        : Center(
            child: _recentPrescriptionList.isEmpty
                ? const Text('No recent prescriptions found.')
                : const CircularProgressIndicator(),
          );
  }
}



// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/medicine.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/prescription_tab.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:share/share.dart';

// // class Medicine {
// //   final String medId;
// //   final String medName;

// //   Medicine({
// //     required this.medId,
// //     required this.medName,
// //   });
// // }

// class ClosedPrescriptionTab extends StatefulWidget {
//   final String clinicId;
//   final VoidCallback navigateToPrescriptionTab; // Callback function
//   final String patientId;
//   final String? treatmentId;

//   const ClosedPrescriptionTab({
//     super.key,
//     required this.clinicId,
//     required this.navigateToPrescriptionTab,
//     required this.patientId,
//     required this.treatmentId,
//   });

//   @override
//   State<ClosedPrescriptionTab> createState() => _ClosedPrescriptionTabState();
// }

// class _ClosedPrescriptionTabState extends State<ClosedPrescriptionTab> {
//   final TextEditingController _medicineNameController = TextEditingController();
//   final TextEditingController _daysController = TextEditingController();

//   List<Medicine> matchingMedicines = [];

//   bool _showMedicineInput = false; // Set to false initially
//   bool _showCheckboxContainer = false;
//   List<Map<String, dynamic>> prescriptions = []; // List to store prescriptions

//   bool _showRecentPrescriptions = false; // Add this variable
//   String _recentPrescriptionDate = ''; // Add this variable
//   bool _morningCheckboxValue = false; // Declare as instance variable
//   bool _afternoonCheckboxValue = false; // Declare as instance variable
//   bool _eveningCheckboxValue = false; // Declare as instance variable

//   List<String> _recentPrescriptionMedicines = [];
//   // Track the selected medicine for the current prescription
//   Medicine? _selectedMedicine;
//   List<ClosedPrescriptionData> _recentPrescriptionList = [];
//   final GlobalKey letterheadKey = GlobalKey();
//   String? pdfPath = '';
//   List<Map<String, dynamic>> recentMedicines = [];

//   @override
//   void initState() {
//     super.initState();
//     _showMedicineInput = false; // Set to false initially
//     _selectedMedicine = null;
//     _loadExistingPrescriptions();
//   }

//   // Future<void> _loadExistingPrescriptions() async {
//   //   try {
//   //     final existingPrescriptions = await FirebaseFirestore.instance
//   //         .collection('clinics')
//   //         .doc(widget.clinicId)
//   //         .collection('patients')
//   //         .doc(widget.patientId)
//   //         .collection('treatments')
//   //         .doc(widget.treatmentId)
//   //         .collection('prescriptions')
//   //         .get();

//   //     final List<ClosedPrescriptionData> existingPrescriptionList = [];

//   //     DateTime latestPrescriptionDate = DateTime(1900);

//   //     for (final doc in existingPrescriptions.docs) {
//   //       final data = doc.data();

//   //       final prescriptions =
//   //           List<Map<String, dynamic>>.from(data['medPrescribed']);
//   //       final prescriptionList = <Map<String, dynamic>>[];

//   //       for (final prescription in prescriptions) {
//   //         final prescriptionDate =
//   //             prescription['prescriptionDate']?.toDate() ?? DateTime.now();

//   //         if (prescriptionDate.isAfter(latestPrescriptionDate)) {
//   //           latestPrescriptionDate = prescriptionDate;
//   //         }

//   //         prescriptionList.add({
//   //           'medName': prescription['medName'],
//   //           'days': prescription['days'],
//   //           // Add other fields as needed
//   //         });
//   //       }

//   //       existingPrescriptionList.add(ClosedPrescriptionData(
//   //         prescriptionId: doc.id,
//   //         prescriptionDate: latestPrescriptionDate,
//   //         medicines: prescriptionList,
//   //       ));
//   //     }

//   //     if (existingPrescriptionList.isNotEmpty) {
//   //       devtools.log('existingPrescriptionList is $existingPrescriptionList');
//   //       setState(() {
//   //         _showRecentPrescriptions = true;
//   //         _recentPrescriptionDate =
//   //             DateFormat('MMMM dd, EEEE').format(latestPrescriptionDate);
//   //         _recentPrescriptionList = existingPrescriptionList;
//   //       });
//   //     }
//   //   } catch (error) {
//   //     devtools.log('Error loading existing prescriptions: $error');
//   //   }
//   // }

//   // ------------------------------------------------------------------------  //
//   Future<void> _loadExistingPrescriptions() async {
//     try {
//       final existingPrescriptionsSnapshot = await FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(widget.patientId)
//           .collection('treatments')
//           .doc(widget.treatmentId)
//           .collection('prescriptions')
//           .get();

//       final List<ClosedPrescriptionData> existingPrescriptionList = [];

//       DateTime latestPrescriptionDate = DateTime(1900);

//       for (final doc in existingPrescriptionsSnapshot.docs) {
//         final data = doc.data();

//         final prescriptions =
//             List<Map<String, dynamic>>.from(data['medPrescribed'] ?? []);
//         final prescriptionList = <Map<String, dynamic>>[];

//         for (final prescription in prescriptions) {
//           final prescriptionDate =
//               (prescription['prescriptionDate'] as Timestamp?)?.toDate() ??
//                   DateTime.now();

//           if (prescriptionDate.isAfter(latestPrescriptionDate)) {
//             latestPrescriptionDate = prescriptionDate;
//           }

//           prescriptionList.add({
//             'medName': prescription['medName'],
//             'days': prescription['days'],
//             'instructions': prescription['instructions'] ?? '', // Add this line
//             'dose': prescription['dose'] ??
//                 {
//                   'morning': false,
//                   'afternoon': false,
//                   'evening': false,
//                   'sos': false,
//                 }
//           });
//         }

//         existingPrescriptionList.add(ClosedPrescriptionData(
//           prescriptionId: doc.id,
//           prescriptionDate: latestPrescriptionDate,
//           medicines: prescriptionList,
//         ));
//       }

//       if (existingPrescriptionList.isNotEmpty) {
//         devtools.log('existingPrescriptionList is $existingPrescriptionList');
//         setState(() {
//           _showRecentPrescriptions = true;
//           _recentPrescriptionDate =
//               DateFormat('MMMM dd, EEEE').format(latestPrescriptionDate);
//           _recentPrescriptionList = existingPrescriptionList;
//         });
//       }
//     } catch (error) {
//       devtools.log('Error loading existing prescriptions: $error');
//     }
//   }
//   // ------------------------------------------------------------------------  //

//   Widget _buildRecentPrescriptionsContainer() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Align(
//             alignment: Alignment.topLeft,
//             child: Text(
//               'Recent Prescriptions',
//               style: MyTextStyle.textStyleMap['title-large']
//                   ?.copyWith(color: MyColors.colorPalette['on-surface']),
//             ),
//           ),
//         ),
//         for (final closedPrescriptionData in _recentPrescriptionList)
//           _buildPrescriptionContainer(closedPrescriptionData),
//       ],
//     );
//   }

//   // Widget _buildPrescriptionContainer(
//   //     ClosedPrescriptionData closedPrescriptionData) {
//   //   return Container(
//   //     padding: const EdgeInsets.all(16.0),
//   //     decoration: BoxDecoration(
//   //       border: Border.all(color: Colors.grey),
//   //       borderRadius: BorderRadius.circular(10.0),
//   //     ),
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         Padding(
//   //           padding: const EdgeInsets.only(bottom: 8.0),
//   //           child: Row(
//   //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //             children: [
//   //               Text(
//   //                 DateFormat('MMMM dd, EEEE')
//   //                     .format(closedPrescriptionData.prescriptionDate),
//   //                 style: MyTextStyle.textStyleMap['label-medium']
//   //                     ?.copyWith(color: MyColors.colorPalette['outline']),
//   //               ),
//   //               GestureDetector(
//   //                 onTap: () {
//   //                   // Add your delete operation here
//   //                   // devtools.log('Delete operation triggered');
//   //                   // _deletePrescription(closedPrescriptionData);
//   //                 },
//   //                 child: Icon(
//   //                   Icons.close,
//   //                   size: 24,
//   //                   color: MyColors.colorPalette['on-surface'],
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //         Padding(
//   //           padding: const EdgeInsets.all(8.0),
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: closedPrescriptionData.medicines.map((medicine) {
//   //               return Text(
//   //                 '${medicine['medName']} X ${medicine['days']} days',
//   //                 style: MyTextStyle.textStyleMap['label-large']
//   //                     ?.copyWith(color: MyColors.colorPalette['secondary']),
//   //               );
//   //             }).toList(),
//   //           ),
//   //         ),
//   //         Row(
//   //           mainAxisAlignment: MainAxisAlignment.end,
//   //           children: [
//   //             if (_showRecentPrescriptions)
//   //               // IconButton(
//   //               //   onPressed: () {
//   //               //     //_sharePrescriptionViaWhatsApp(closedPrescriptionData);
//   //               //   },
//   //               //   icon: Icon(
//   //               //     Icons.share,
//   //               //     size: 24,
//   //               //     color: MyColors.colorPalette['primary'],
//   //               //   ),
//   //               // ),
//   //               Icon(
//   //                 Icons.share,
//   //                 size: 24,
//   //                 color: MyColors.colorPalette['primary'],
//   //               ),

//   //             // IconButton(
//   //             //   onPressed: () {
//   //             //     // Handle download icon click
//   //             //     //downloadPrescriptionPdf(closedPrescriptionData);
//   //             //   },
//   //             //   icon: Icon(
//   //             //     Icons.download,
//   //             //     size: 24,
//   //             //     color: MyColors.colorPalette['primary'],
//   //             //   ),
//   //             // ),

//   //             Icon(
//   //               Icons.download,
//   //               size: 24,
//   //               color: MyColors.colorPalette['primary'],
//   //             ),
//   //           ],
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//   Widget _buildPrescriptionContainer(
//       ClosedPrescriptionData closedPrescriptionData) {
//     devtools.log(
//         'This is coming from inside _buildPrescriptionContainer. medicine in closedPrescriptionData is ${closedPrescriptionData.medicines}');
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(12.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               spreadRadius: 2,
//               blurRadius: 5,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   DateFormat('MMMM dd, EEEE')
//                       .format(closedPrescriptionData.prescriptionDate),
//                   style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                     color: MyColors.colorPalette['outline'],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 // GestureDetector(
//                 //   onTap: () {
//                 //     // devtools.log('Delete operation triggered');
//                 //     // _deletePrescription(prescriptionData);
//                 //   },
//                 //   child: Icon(
//                 //     Icons.close,
//                 //     size: 24,
//                 //     color: MyColors.colorPalette['on-surface'],
//                 //   ),
//                 // ),
//               ],
//             ),
//             Divider(color: Colors.grey.shade300),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: closedPrescriptionData.medicines.map((medicine) {
//                   final dose = medicine['dose'];
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Text(
//                         //   '${medicine['medName']} x ${medicine['days']} days',
//                         //   style: MyTextStyle.textStyleMap['label-large']
//                         //       ?.copyWith(
//                         //           color: MyColors.colorPalette['secondary'],
//                         //           fontWeight: FontWeight.w600),
//                         // ),
//                         Text(
//                           '${medicine['medName']}',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary'],
//                                   fontWeight: FontWeight.w600),
//                         ),
//                         if (dose != null)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4.0),
//                             child: Wrap(
//                               spacing: 8.0,
//                               children: [
//                                 if (dose['morning'])
//                                   Text(
//                                     'Morning',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-large']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['outline']),
//                                   ),
//                                 Text(
//                                   '-',
//                                   style: MyTextStyle.textStyleMap['label-large']
//                                       ?.copyWith(
//                                           color:
//                                               MyColors.colorPalette['outline']),
//                                 ),
//                                 if (dose['afternoon'])
//                                   Text(
//                                     'Afternoon',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-large']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['outline']),
//                                   ),
//                                 Text(
//                                   '-',
//                                   style: MyTextStyle.textStyleMap['label-large']
//                                       ?.copyWith(
//                                           color:
//                                               MyColors.colorPalette['outline']),
//                                 ),
//                                 if (dose['evening'])
//                                   Text(
//                                     'Evening',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-large']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['outline']),
//                                   ),
//                                 if (dose['sos'])
//                                   Text(
//                                     'SOS',
//                                     style: MyTextStyle
//                                         .textStyleMap['label-large']
//                                         ?.copyWith(
//                                             color: MyColors
//                                                 .colorPalette['outline']),
//                                   ),
//                                 Text(
//                                   'x ${medicine['days']} days',
//                                   style: MyTextStyle.textStyleMap['label-large']
//                                       ?.copyWith(
//                                           color:
//                                               MyColors.colorPalette['outline']),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         if (medicine['instructions'] != null &&
//                             medicine['instructions'].isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4.0),
//                             child: Text(
//                               'Instructions: ${medicine['instructions']}',
//                               style: MyTextStyle.textStyleMap['label-large']
//                                   ?.copyWith(
//                                       color: MyColors.colorPalette['outline']),
//                             ),
//                           ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//             // Row(
//             //   mainAxisAlignment: MainAxisAlignment.end,
//             //   children: [
//             //     IconButton(
//             //       onPressed: () {
//             //         _sharePrescriptionTableViaWhatsApp(prescriptionData);
//             //         devtools.log('_sharePrescriptionTableViaWhatsApp invoked');
//             //       },
//             //       icon: Icon(
//             //         Icons.share,
//             //         size: 24,
//             //         color: MyColors.colorPalette['primary'],
//             //       ),
//             //     ),
//             //   ],
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         if (_showRecentPrescriptions) _buildRecentPrescriptionsContainer(),
//       ],
//     );
//   }
// }

// class CircularCheckboxWithLabel extends StatefulWidget {
//   final bool initialValue;
//   final Function(bool) onChanged;
//   final bool isChecked;

//   const CircularCheckboxWithLabel({
//     super.key,
//     required this.initialValue,
//     required this.onChanged,
//     required this.isChecked,
//   });

//   @override
//   State<CircularCheckboxWithLabel> createState() =>
//       _CircularCheckboxWithLabelState();
// }

// class _CircularCheckboxWithLabelState extends State<CircularCheckboxWithLabel> {
//   bool _isChecked = false;

//   @override
//   void initState() {
//     super.initState();
//     _isChecked = widget.isChecked;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               _isChecked = !_isChecked;
//               widget.onChanged(_isChecked);
//             });
//           },
//           child: Container(
//             width: 24.0,
//             height: 24.0,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color:
//                     MyColors.colorPalette['surface-container'] ?? Colors.black,
//                 width: 2.0,
//               ),
//             ),
//             child: _isChecked
//                 ? Icon(
//                     Icons.check,
//                     size: 16.0,
//                     color: MyColors.colorPalette['primary'],
//                   )
//                 : null,
//           ),
//         ),
//         const SizedBox(width: 8.0),
//       ],
//     );
//   }
// }

// class ClosedPrescriptionData {
//   final String prescriptionId;
//   final DateTime prescriptionDate;
//   final List<Map<String, dynamic>> medicines;

//   ClosedPrescriptionData({
//     required this.prescriptionId,
//     required this.prescriptionDate,
//     required this.medicines,
//   });
// }
