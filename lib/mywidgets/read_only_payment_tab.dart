// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ReadOnlyPaymentTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;
//   final String doctorId;
//   final Map<String, dynamic>? treatmentData;

//   const ReadOnlyPaymentTab({
//     super.key,
//     required this.clinicId,
//     required this.patientId,
//     this.treatmentId,
//     required this.doctorId,
//     this.treatmentData,
//   });

//   @override
//   State<ReadOnlyPaymentTab> createState() => _ReadOnlyPaymentTabState();
// }

// class _ReadOnlyPaymentTabState extends State<ReadOnlyPaymentTab> {
//   Map<String, dynamic>? _loadedTreatmentData;
//   List<Map<String, dynamic>> paymentList = [];
//   double? closingBalance;
//   double initialOpeningBalance = 0.0;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialValues();
//   }

//   Future<void> _loadInitialValues() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     if (widget.treatmentId != null && widget.treatmentData != null) {
//       String? lastTreatmentId = prefs.getString('lastTreatmentId');
//       if (lastTreatmentId != widget.treatmentId) {
//         await prefs.remove('initialOpeningBalance');
//         await prefs.setString('lastTreatmentId', widget.treatmentId!);
//       }

//       if (prefs.containsKey('initialOpeningBalance')) {
//         setState(() {
//           initialOpeningBalance = prefs.getDouble('initialOpeningBalance')!;
//         });
//       } else {
//         _loadedTreatmentData = widget.treatmentData;
//         initialOpeningBalance =
//             _loadedTreatmentData?['treatmentCost']['totalCost'] ?? 0.0;
//         await prefs.setDouble('initialOpeningBalance', initialOpeningBalance);
//       }
//     }

//     devtools.log('initialOpeningBalance is $initialOpeningBalance');
//     fetchAndRenderPayments();
//   }

//   void fetchAndRenderPayments() async {
//     final paymentsCollectionRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(widget.clinicId)
//         .collection('patients')
//         .doc(widget.patientId)
//         .collection('treatments')
//         .doc(widget.treatmentId)
//         .collection('payments');

//     try {
//       final QuerySnapshot paymentDocs =
//           await paymentsCollectionRef.orderBy('date', descending: false).get();

//       List<Map<String, dynamic>> paymentList = [];
//       double? lastClosingBalance;
//       double runningBalance = initialOpeningBalance;

//       paymentList.add({
//         'date': DateFormat('dd-MM-yy').format(DateTime.now()),
//         'description': 'Opening balance',
//         'transaction': null,
//         'balance': initialOpeningBalance,
//         'isError': false,
//       });

//       for (QueryDocumentSnapshot doc in paymentDocs.docs) {
//         Map<String, dynamic> paymentData = doc.data() as Map<String, dynamic>;

//         num paymentReceived = paymentData['paymentReceived'] as num;
//         num adjustments = paymentData['adjustments'] as num? ?? 0.0;
//         String adjustmentDetails =
//             paymentData['adjustmentDetails'] as String? ?? '';
//         DateTime date = paymentData['date'].toDate();

//         if (paymentData.containsKey('closingBalance')) {
//           lastClosingBalance = paymentData['closingBalance'] as double;
//         }

//         String formattedDate = DateFormat('dd-MM-yy').format(date);

//         runningBalance -= paymentReceived;
//         runningBalance += adjustments;

//         paymentList.add({
//           'date': formattedDate,
//           'description': adjustmentDetails.isNotEmpty
//               ? adjustmentDetails
//               : 'Payment received',
//           'transaction': paymentReceived != 0 ? -paymentReceived : adjustments,
//           'balance': runningBalance,
//           'isError': paymentReceived != 0,
//         });
//       }

//       setState(() {
//         this.paymentList = paymentList;
//         closingBalance = lastClosingBalance;
//         _isLoading = false;
//       });
//     } catch (e) {
//       devtools.log('Error fetching payments: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Widget _buildPaymentRow(Map<String, dynamic>? payment,
//       {bool isHeader = false}) {
//     if (isHeader) {
//       return Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     'Date',
//                     style: MyTextStyle.textStyleMap['title-small']
//                         ?.copyWith(color: MyColors.colorPalette['secondary']),
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     'Description',
//                     style: MyTextStyle.textStyleMap['title-small']
//                         ?.copyWith(color: MyColors.colorPalette['secondary']),
//                     textAlign: TextAlign.left,
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     'Transaction',
//                     style: MyTextStyle.textStyleMap['title-small']
//                         ?.copyWith(color: MyColors.colorPalette['secondary']),
//                     textAlign: TextAlign.right,
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     'Balance',
//                     style: MyTextStyle.textStyleMap['title-small']
//                         ?.copyWith(color: MyColors.colorPalette['secondary']),
//                     textAlign: TextAlign.right,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Divider(
//             thickness: 1.0,
//             color: MyColors.colorPalette['outline'],
//           )
//         ],
//       );
//     }

//     String date = payment!['date'];
//     String description = payment['description'];
//     double? transaction = payment['transaction'];
//     double balance = payment['balance'];

//     bool isError = transaction != null && transaction < 0;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Text(
//               date,
//               style: MyTextStyle.textStyleMap['title-small']
//                   ?.copyWith(color: MyColors.colorPalette['secondary']),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               description,
//               style: MyTextStyle.textStyleMap['title-small']
//                   ?.copyWith(color: MyColors.colorPalette['secondary']),
//               textAlign: TextAlign.left,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               transaction != null
//                   ? '${transaction < 0 ? '-' : ''}${transaction.abs().toStringAsFixed(0)}'
//                   : '',
//               style: MyTextStyle.textStyleMap['title-small']?.copyWith(
//                 color: isError
//                     ? MyColors.colorPalette['error']
//                     : MyColors.colorPalette['secondary'],
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               balance.toStringAsFixed(0),
//               style: MyTextStyle.textStyleMap['title-small']
//                   ?.copyWith(color: MyColors.colorPalette['secondary']),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           const SizedBox(height: 16),
//           Divider(
//             thickness: 1.0,
//             color: MyColors.colorPalette['outline'],
//           ),
//           if (_isLoading)
//             const Center(
//               child: CircularProgressIndicator(),
//             )
//           else ...[
//             _buildPaymentRow(null, isHeader: true), // Add header row
//             ...paymentList.map((payment) => _buildPaymentRow(payment)).toList(),
//           ],
//           Divider(
//             thickness: 1.0,
//             color: MyColors.colorPalette['outline'],
//           ),
//         ],
//       ),
//     );
//   }
// }



// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class ReadOnlyPaymentTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;
//   final String doctorId;
//   final Map<String, dynamic>? treatmentData;

//   const ReadOnlyPaymentTab({
//     Key? key,
//     required this.clinicId,
//     required this.patientId,
//     this.treatmentId,
//     required this.doctorId,
//     this.treatmentData,
//   }) : super(key: key);

//   @override
//   _ReadOnlyPaymentTabState createState() => _ReadOnlyPaymentTabState();
// }

// class _ReadOnlyPaymentTabState extends State<ReadOnlyPaymentTab> {
//   List<ReadOnlyPaymentData> paymentList = [];
//   double? closingBalance;
//   bool paymentsFetched = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchAndRenderPayments();
//   }

//   Future<void> fetchAndRenderPayments() async {
//     final paymentsCollectionRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(widget.clinicId)
//         .collection('patients')
//         .doc(widget.patientId)
//         .collection('treatments')
//         .doc(widget.treatmentId)
//         .collection('payments');

//     try {
//       final QuerySnapshot paymentDocs =
//           await paymentsCollectionRef.orderBy('date', descending: false).get();

//       List<ReadOnlyPaymentData> fetchedPayments = [];
//       double? lastClosingBalance;

//       for (QueryDocumentSnapshot doc in paymentDocs.docs) {
//         Map<String, dynamic> paymentData = doc.data() as Map<String, dynamic>;

//         DateTime date = (paymentData['date'] as Timestamp).toDate();
//         double paymentReceived = paymentData['paymentReceived'] as double;
//         double closingBalance = paymentData['closingBalance'] as double;

//         fetchedPayments.add(ReadOnlyPaymentData(
//           paymentId: paymentData['paymentId'],
//           date: date,
//           paymentReceived: paymentReceived,
//           closingBalance: closingBalance,
//         ));

//         lastClosingBalance = closingBalance;
//       }

//       setState(() {
//         paymentList = fetchedPayments;
//         closingBalance = lastClosingBalance;
//         paymentsFetched = true;
//       });
//     } catch (e) {
//       devtools.log('Error fetching payments: $e');
//     }
//   }

//   Widget _buildTreatmentCostRow(String title, dynamic cost) {
//     if (cost != null && cost != 0) {
//       return Container(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               '$title:',
//               style: MyTextStyle.textStyleMap['title-medium']
//                   ?.copyWith(color: MyColors.colorPalette['secondary']),
//             ),
//             Text(
//               '$cost',
//               style: MyTextStyle.textStyleMap['title-medium']
//                   ?.copyWith(color: MyColors.colorPalette['secondary']),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return Container();
//     }
//   }

//   Widget _buildTreatmentCostSection() {
//     return Visibility(
//       visible: widget.treatmentData != null,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           decoration: BoxDecoration(
//               border: Border.all(
//                 width: 1.0,
//               ),
//               borderRadius: const BorderRadius.all(Radius.circular(10.0))),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 const SizedBox(height: 16),
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: Text(
//                     'Treatment Cost:',
//                     style: MyTextStyle.textStyleMap['title-large']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                 ),
//                 Divider(
//                   thickness: 1.0,
//                   color: MyColors.colorPalette['outline'],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTreatmentCostRow(
//                   'Consultation Fee',
//                   widget.treatmentData?['treatmentCost']['consultationFee'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Filling',
//                   widget.treatmentData?['treatmentCost']['filling'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Root Canal',
//                   widget.treatmentData?['treatmentCost']['rootCanal'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Implant',
//                   widget.treatmentData?['treatmentCost']['implant'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Bridge',
//                   widget.treatmentData?['treatmentCost']['bridge'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Scaling & Polishing',
//                   widget.treatmentData?['treatmentCost']['scalingPolishing'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Discount',
//                   widget.treatmentData?['treatmentCost']['discount'],
//                 ),
//                 Divider(
//                   thickness: 1.0,
//                   color: MyColors.colorPalette['outline'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Total Cost',
//                   widget.treatmentData?['treatmentCost']['totalCost'],
//                 ),
//                 const SizedBox(height: 16),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPaymentContainer() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Align(
//             alignment: Alignment.topLeft,
//             child: Text(
//               'All Payments',
//               style: MyTextStyle.textStyleMap['title-large']
//                   ?.copyWith(color: MyColors.colorPalette['on-surface']),
//             ),
//           ),
//         ),
//         for (final payment in paymentList)
//           _buildReadOnlyPaymentContainer(payment),
//       ],
//     );
//   }

//   Widget _buildReadOnlyPaymentContainer(ReadOnlyPaymentData payment) {
//     final formattedDate = DateFormat('MMMM d, EEEE').format(payment.date);

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         width: double.infinity, // Ensure the container takes full width
//         padding: const EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Text(
//                 formattedDate,
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['secondary']),
//               ),
//             ),
//             Text(
//               'Payment Received: ₹ ${payment.paymentReceived.toStringAsFixed(2)}',
//               style: MyTextStyle.textStyleMap['body-large']
//                   ?.copyWith(color: MyColors.colorPalette['primary']),
//             ),
//             Text(
//               'Closing Balance: ₹ ${payment.closingBalance.toStringAsFixed(2)}',
//               style: MyTextStyle.textStyleMap['body-large']
//                   ?.copyWith(color: MyColors.colorPalette['primary']),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!paymentsFetched) {
//       return const Center(child: CircularProgressIndicator());
//     } else if (paymentList.isEmpty) {
//       return Center(
//         child: Text(
//           'No payments available',
//           style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//             color: MyColors.colorPalette['on-surface-variant'],
//           ),
//         ),
//       );
//     } else {
//       return SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildTreatmentCostSection(),
//             _buildPaymentContainer(),
//             const SizedBox(
//               height: 16.0,
//             )
//           ],
//         ),
//       );
//     }
//   }
// }

// class ReadOnlyPaymentData {
//   String paymentId;
//   DateTime date;
//   double paymentReceived;
//   double closingBalance;

//   ReadOnlyPaymentData({
//     required this.paymentId,
//     required this.date,
//     required this.paymentReceived,
//     required this.closingBalance,
//   });
// }

//!!!!!!!!!!!!!!!!!!!!!!!
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class ReadOnlyPaymentTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;
//   final String doctorId;
//   final Map<String, dynamic>? treatmentData;

//   const ReadOnlyPaymentTab({
//     Key? key,
//     required this.clinicId,
//     required this.patientId,
//     this.treatmentId,
//     required this.doctorId,
//     this.treatmentData,
//   }) : super(key: key);

//   @override
//   _ReadOnlyPaymentTabState createState() => _ReadOnlyPaymentTabState();
// }

// class _ReadOnlyPaymentTabState extends State<ReadOnlyPaymentTab> {
//   List<ReadOnlyPaymentData> paymentList = [];
//   double? closingBalance;
//   bool paymentsFetched = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchAndRenderPayments();
//   }

//   Future<void> fetchAndRenderPayments() async {
//     final paymentsCollectionRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(widget.clinicId)
//         .collection('patients')
//         .doc(widget.patientId)
//         .collection('treatments')
//         .doc(widget.treatmentId)
//         .collection('payments');

//     try {
//       final QuerySnapshot paymentDocs =
//           await paymentsCollectionRef.orderBy('date', descending: false).get();

//       List<ReadOnlyPaymentData> fetchedPayments = [];
//       double? lastClosingBalance;

//       for (QueryDocumentSnapshot doc in paymentDocs.docs) {
//         Map<String, dynamic> paymentData = doc.data() as Map<String, dynamic>;

//         DateTime date = (paymentData['date'] as Timestamp).toDate();
//         double paymentReceived = paymentData['paymentReceived'] as double;
//         double closingBalance = paymentData['closingBalance'] as double;

//         fetchedPayments.add(ReadOnlyPaymentData(
//           paymentId: paymentData['paymentId'],
//           date: date,
//           paymentReceived: paymentReceived,
//           closingBalance: closingBalance,
//         ));

//         lastClosingBalance = closingBalance;
//       }

//       setState(() {
//         paymentList = fetchedPayments;
//         closingBalance = lastClosingBalance;
//         paymentsFetched = true;
//       });
//     } catch (e) {
//       devtools.log('Error fetching payments: $e');
//     }
//   }

//   Widget _buildTreatmentCostRow(String title, dynamic cost) {
//     if (cost != null && cost != 0) {
//       return Container(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               '$title:',
//               style: MyTextStyle.textStyleMap['title-medium']
//                   ?.copyWith(color: MyColors.colorPalette['secondary']),
//             ),
//             Text(
//               '$cost',
//               style: MyTextStyle.textStyleMap['title-medium']
//                   ?.copyWith(color: MyColors.colorPalette['secondary']),
//             ),
//             // const SizedBox(height: 8),
//           ],
//         ),
//       );
//     } else {
//       return Container();
//     }
//   }


//   Widget _buildTreatmentCostSection() {
//     return Visibility(
//       visible: widget.treatmentData != null,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           decoration: BoxDecoration(
//               border: Border.all(
//                 width: 1.0,
//               ),
//               borderRadius: const BorderRadius.all(Radius.circular(10.0))),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 const SizedBox(height: 16),
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: Text(
//                     'Treatment Cost:',
//                     style: MyTextStyle.textStyleMap['title-large']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                 ),
//                 Divider(
//                   thickness: 1.0,
//                   color: MyColors.colorPalette['outline'],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTreatmentCostRow(
//                   'Consultation Fee',
//                   widget.treatmentData?['treatmentCost']['consultationFee'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Filling',
//                   widget.treatmentData?['treatmentCost']['filling'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Root Canal',
//                   widget.treatmentData?['treatmentCost']['rootCanal'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Implant',
//                   widget.treatmentData?['treatmentCost']['implant'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Bridge',
//                   widget.treatmentData?['treatmentCost']['bridge'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Scaling & Polishing',
//                   widget.treatmentData?['treatmentCost']['scalingPolishing'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Discount',
//                   widget.treatmentData?['treatmentCost']['discount'],
//                 ),
//                 Divider(
//                   thickness: 1.0,
//                   color: MyColors.colorPalette['outline'],
//                 ),
//                 _buildTreatmentCostRow(
//                   'Total Cost',
//                   widget.treatmentData?['treatmentCost']['totalCost'],
//                 ),
//                 const SizedBox(height: 16),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPaymentContainer() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Align(
//             alignment: Alignment.topLeft,
//             child: Text(
//               'All Payments',
//               style: MyTextStyle.textStyleMap['title-large']
//                   ?.copyWith(color: MyColors.colorPalette['on-surface']),
//             ),
//           ),
//         ),
//         for (final payment in paymentList)
//           _buildReadOnlyPaymentContainer(payment),
//       ],
//     );
//   }

//   Widget _buildReadOnlyPaymentContainer(ReadOnlyPaymentData payment) {
//     final formattedDate = DateFormat('MMMM d, EEEE').format(payment.date);
//     final formattedTime = DateFormat.jm().format(payment.date);

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Icon(
//                     Icons.payment,
//                     size: 24,
//                     color: MyColors.colorPalette['on-surface'],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Text(
//                 formattedDate,
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['secondary']),
//               ),
//             ),
//             Text(
//               'Payment Received: ₹ ${payment.paymentReceived.toStringAsFixed(2)}',
//               style: MyTextStyle.textStyleMap['body-large']
//                   ?.copyWith(color: MyColors.colorPalette['primary']),
//             ),
//             Text(
//               'Closing Balance: ₹ ${payment.closingBalance.toStringAsFixed(2)}',
//               style: MyTextStyle.textStyleMap['body-large']
//                   ?.copyWith(color: MyColors.colorPalette['primary']),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!paymentsFetched) {
//       return const Center(child: CircularProgressIndicator());
//     } else if (paymentList.isEmpty) {
//       return Center(
//         child: Text(
//           'No payments available',
//           style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//             color: MyColors.colorPalette['on-surface-variant'],
//           ),
//         ),
//       );
//     } else {
//       return SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildTreatmentCostSection(),
//             _buildPaymentContainer(),
//           ],
//         ),
//       );
//     }
//   }
// }

// class ReadOnlyPaymentData {
//   String paymentId;
//   DateTime date;
//   double paymentReceived;
//   double closingBalance;

//   ReadOnlyPaymentData({
//     required this.paymentId,
//     required this.date,
//     required this.paymentReceived,
//     required this.closingBalance,
//   });
// }

//!!!!!!!!!!!!!!!!!!!!!!!!!
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class ReadOnlyPaymentTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;
//   final String doctorId;
//   final Map<String, dynamic>? treatmentData;

//   const ReadOnlyPaymentTab({
//     Key? key,
//     required this.clinicId,
//     required this.patientId,
//     this.treatmentId,
//     required this.doctorId,
//     this.treatmentData,
//   }) : super(key: key);

//   @override
//   _ReadOnlyPaymentTabState createState() => _ReadOnlyPaymentTabState();
// }

// class _ReadOnlyPaymentTabState extends State<ReadOnlyPaymentTab> {
//   List<ReadOnlyPaymentData> paymentList = [];
//   double? closingBalance;
//   bool paymentsFetched = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchAndRenderPayments();
//   }

//   Future<void> fetchAndRenderPayments() async {
//     final paymentsCollectionRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(widget.clinicId)
//         .collection('patients')
//         .doc(widget.patientId)
//         .collection('treatments')
//         .doc(widget.treatmentId)
//         .collection('payments');

//     try {
//       final QuerySnapshot paymentDocs =
//           await paymentsCollectionRef.orderBy('date', descending: false).get();

//       List<ReadOnlyPaymentData> fetchedPayments = [];
//       double? lastClosingBalance;

//       for (QueryDocumentSnapshot doc in paymentDocs.docs) {
//         Map<String, dynamic> paymentData = doc.data() as Map<String, dynamic>;

//         DateTime date = (paymentData['date'] as Timestamp).toDate();
//         double paymentReceived = paymentData['paymentReceived'] as double;
//         double closingBalance = paymentData['closingBalance'] as double;

//         fetchedPayments.add(ReadOnlyPaymentData(
//           paymentId: paymentData['paymentId'],
//           date: date,
//           paymentReceived: paymentReceived,
//           closingBalance: closingBalance,
//         ));

//         lastClosingBalance = closingBalance;
//       }

//       setState(() {
//         paymentList = fetchedPayments;
//         closingBalance = lastClosingBalance;
//         paymentsFetched = true;
//       });
//     } catch (e) {
//       devtools.log('Error fetching payments: $e');
//     }
//   }

//   Widget _buildPaymentContainer() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Align(
//             alignment: Alignment.topLeft,
//             child: Text(
//               'All Payments',
//               style: MyTextStyle.textStyleMap['title-large']
//                   ?.copyWith(color: MyColors.colorPalette['on-surface']),
//             ),
//           ),
//         ),
//         for (final payment in paymentList)
//           _buildReadOnlyPaymentContainer(payment),
//       ],
//     );
//   }

//   Widget _buildReadOnlyPaymentContainer(ReadOnlyPaymentData payment) {
//     final formattedDate = DateFormat('MMMM d, EEEE').format(payment.date);
//     final formattedTime = DateFormat.jm().format(payment.date);

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Icon(
//                     Icons.payment,
//                     size: 24,
//                     color: MyColors.colorPalette['on-surface'],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Text(
//                 formattedDate,
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['secondary']),
//               ),
//             ),
//             Text(
//               'Payment Received: ₹ ${payment.paymentReceived.toStringAsFixed(2)}',
//               style: MyTextStyle.textStyleMap['body-large']
//                   ?.copyWith(color: MyColors.colorPalette['primary']),
//             ),
//             Text(
//               'Closing Balance: ₹ ${payment.closingBalance.toStringAsFixed(2)}',
//               style: MyTextStyle.textStyleMap['body-large']
//                   ?.copyWith(color: MyColors.colorPalette['primary']),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!paymentsFetched) {
//       return const Center(child: CircularProgressIndicator());
//     } else if (paymentList.isEmpty) {
//       return Center(
//         child: Text(
//           'No payments available',
//           style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//             color: MyColors.colorPalette['on-surface-variant'],
//           ),
//         ),
//       );
//     } else {
//       return SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildPaymentContainer(),
//           ],
//         ),
//       );
//     }
//   }
// }

// class ReadOnlyPaymentData {
//   String paymentId;
//   DateTime date;
//   double paymentReceived;
//   double closingBalance;

//   ReadOnlyPaymentData({
//     required this.paymentId,
//     required this.date,
//     required this.paymentReceived,
//     required this.closingBalance,
//   });
// }
