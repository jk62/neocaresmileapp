import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/firestore/payment_service.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as devtools show log;

class PaymentTab extends StatefulWidget {
  final String clinicId;
  final String patientId;
  final String? treatmentId;
  final String doctorId;
  final Map<String, dynamic>? treatmentData;

  const PaymentTab({
    super.key,
    required this.clinicId,
    required this.patientId,
    this.treatmentId,
    required this.doctorId,
    this.treatmentData,
  });

  @override
  State<PaymentTab> createState() => _PaymentTabState();
}

class _PaymentTabState extends State<PaymentTab> {
  PaymentService? _paymentService;
  bool isAddingPayment = false;
  bool isPaymentSaved = false;
  bool isInputValid = false;
  double initialOpeningBalance = 0.0;
  double? closingBalance;
  List<Map<String, dynamic>> paymentList = [];
  bool _isSaving = false;
  TextEditingController paymentController = TextEditingController();
  final FocusNode _saveButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      treatmentId: widget.treatmentId!,
    );
    _loadInitialValues();
  }

  // Future<void> _loadInitialValues() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   // Check if the treatment ID has changed, indicating a new treatment
  //   if (widget.treatmentId != null && widget.treatmentData != null) {
  //     String? lastTreatmentId = prefs.getString('lastTreatmentId');
  //     if (lastTreatmentId != widget.treatmentId) {
  //       // New treatment, reset initialOpeningBalance
  //       await prefs.remove('initialOpeningBalance');
  //       await prefs.setString('lastTreatmentId', widget.treatmentId!);
  //     }

  //     // Load initialOpeningBalance from SharedPreferences or set it
  //     if (prefs.containsKey('initialOpeningBalance')) {
  //       setState(() {
  //         initialOpeningBalance = prefs.getDouble('initialOpeningBalance')!;
  //       });
  //     } else {
  //       initialOpeningBalance =
  //           widget.treatmentData?['treatmentCost']['totalCost'] ?? 0.0;
  //       await prefs.setDouble('initialOpeningBalance', initialOpeningBalance);
  //     }
  //   }

  //   devtools.log('initialOpeningBalance is $initialOpeningBalance');
  //   fetchAndRenderPayments();
  // }

  Future<void> _loadInitialValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (widget.treatmentId != null && widget.treatmentData != null) {
      String? lastTreatmentId = prefs.getString('lastTreatmentId');
      if (lastTreatmentId != widget.treatmentId) {
        // New treatment, reset initialOpeningBalance
        await prefs.remove('initialOpeningBalance');
        await prefs.setString('lastTreatmentId', widget.treatmentId!);
      }

      // Load initialOpeningBalance from SharedPreferences or set it
      if (prefs.containsKey('initialOpeningBalance')) {
        setState(() {
          initialOpeningBalance = prefs.getDouble('initialOpeningBalance')!;
        });
      } else {
        double treatmentCost =
            widget.treatmentData?['treatmentCost']['totalCost'] ?? 0.0;
        double consultationFee = widget.treatmentData?['consultationFee'] ??
            0.0; // Fetch consultation fee

        initialOpeningBalance = treatmentCost +
            consultationFee; // Include consultation fee in balance

        await prefs.setDouble('initialOpeningBalance', initialOpeningBalance);
      }
    }

    devtools.log('initialOpeningBalance is $initialOpeningBalance');
    fetchAndRenderPayments();
  }

  void savePayment() async {
    double paymentAmount = double.tryParse(paymentController.text) ?? 0.0;

    Payment paymentData = Payment(
      paymentId: '',
      date: DateTime.now(),
      openingBalance: initialOpeningBalance,
      paymentReceived: paymentAmount,
      adjustments: 0.0,
      adjustmentDetails: '',
      closingBalance: initialOpeningBalance - paymentAmount,
    );

    try {
      // Pass the Payment object directly, not a Map
      await _paymentService?.savePayment(paymentData);
      paymentController.clear();
      setState(() {
        isPaymentSaved = false;
        isAddingPayment = false;
        isInputValid = false;
      });
      devtools.log('Payment data pushed to the backend successfully');
      fetchAndRenderPayments();
    } catch (error) {
      devtools.log('Error submitting payment data: $error');
    }
  }

  //-------------------------------------------------------------------------//

  void fetchAndRenderPayments() async {
    try {
      List<Map<String, dynamic>> tempPaymentList = [];
      double runningBalance = initialOpeningBalance;

      // Add the initial opening balance entry
      tempPaymentList.add({
        'date': DateFormat('dd-MM-yy').format(DateTime.now()),
        'description': 'Opening balance',
        'transaction': null,
        'balance': initialOpeningBalance,
        'isError': false,
      });

      // Fetch the payments from the PaymentService
      List<Map<String, dynamic>> fetchedPayments =
          await _paymentService?.fetchPayments() ?? [];

      for (Map<String, dynamic> paymentData in fetchedPayments) {
        DateTime date = paymentData['date'] as DateTime;
        num paymentReceived = paymentData['paymentReceived'] as num;
        num adjustments = paymentData['adjustments'] as num? ?? 0.0;
        String adjustmentDetails =
            paymentData['adjustmentDetails'] as String? ?? '';

        String formattedDate = DateFormat('dd-MM-yy').format(date);
        runningBalance -= paymentReceived;
        runningBalance += adjustments;

        tempPaymentList.add({
          'date': formattedDate,
          'description': adjustmentDetails.isNotEmpty
              ? adjustmentDetails
              : 'Payment received',
          'transaction': paymentReceived != 0 ? -paymentReceived : adjustments,
          'balance': runningBalance,
          'isError': paymentReceived != 0,
        });
      }

      setState(() {
        paymentList = tempPaymentList;
      });
    } catch (e) {
      devtools.log('Error fetching payments: $e');
    }
  }
  //------------------------------------------------------------------------//

  //------------------------------------------------------------------------//

  void _handleSave() async {
    setState(() {
      _isSaving = true; // Disable the button immediately
    });

    try {
      savePayment(); // Perform the save operation
    } finally {
      setState(() {
        _isSaving = false; // Re-enable the button if needed
      });
    }
  }

  Widget _buildPaymentRow(Map<String, dynamic>? payment,
      {bool isHeader = false}) {
    if (isHeader) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Date',
                    style: MyTextStyle.textStyleMap['title-small']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Description',
                    style: MyTextStyle.textStyleMap['title-small']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Transaction',
                    style: MyTextStyle.textStyleMap['title-small']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Balance',
                    style: MyTextStyle.textStyleMap['title-small']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 1.0,
            color: MyColors.colorPalette['outline'],
          )
        ],
      );
    }

    String date = payment!['date'];
    String description = payment['description'];
    double? transaction = payment['transaction'];
    double balance = payment['balance'];

    bool isError = transaction != null && transaction < 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              date,
              style: MyTextStyle.textStyleMap['title-small']
                  ?.copyWith(color: MyColors.colorPalette['secondary']),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: MyTextStyle.textStyleMap['title-small']
                  ?.copyWith(color: MyColors.colorPalette['secondary']),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: Text(
              transaction != null
                  ? '${transaction < 0 ? '-' : ''}${transaction.abs().toStringAsFixed(0)}'
                  : '',
              style: MyTextStyle.textStyleMap['title-small']?.copyWith(
                color: isError
                    ? MyColors.colorPalette['error']
                    : MyColors.colorPalette['secondary'],
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              balance.toStringAsFixed(0),
              style: MyTextStyle.textStyleMap['title-small']
                  ?.copyWith(color: MyColors.colorPalette['secondary']),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('dd-MM-yy').format(currentDate);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Divider(
            thickness: 1.0,
            color: MyColors.colorPalette['outline'],
          ),
          _buildPaymentRow(null, isHeader: true), // Add header row
          ...paymentList.map((payment) => _buildPaymentRow(payment)).toList(),
          Divider(
            thickness: 1.0,
            color: MyColors.colorPalette['outline'],
          ),
          if (isAddingPayment && !isPaymentSaved) ...[
            Container(
              color: MyColors.colorPalette['outline-variant'],
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          formattedDate,
                          style: MyTextStyle.textStyleMap['title-small']
                              ?.copyWith(
                                  color: MyColors.colorPalette['secondary']),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Payment received',
                          style: MyTextStyle.textStyleMap['title-small']
                              ?.copyWith(
                                  color: MyColors.colorPalette['secondary']),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                        width: 120,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: TextFormField(
                          controller: paymentController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.right,
                          onChanged: (value) {
                            setState(() {
                              isInputValid = value.isNotEmpty;
                            });
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            border: InputBorder.none,
                            hintText: 'amount',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: isInputValid && !_isSaving
                      ? _handleSave
                      : null, // Update onPressed
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        isInputValid && !_isSaving
                            ? MyColors.colorPalette['primary']
                            : Colors.grey),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        side: BorderSide(
                            color: isInputValid && !_isSaving
                                ? MyColors.colorPalette['primary']!
                                : Colors.grey),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                  focusNode: _saveButtonFocusNode,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Save',
                      style: MyTextStyle.textStyleMap['label-large']?.copyWith(
                          color: MyColors.colorPalette['on-primary']),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isAddingPayment = false;
                      paymentController.clear();
                    });
                  },
                  child: Text(
                    'Cancel',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                ),
              ],
            ),
          ],
          if (!isAddingPayment)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
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
                        isAddingPayment = true;
                      });
                    },
                    child: Wrap(
                      children: [
                        Icon(
                          Icons.add,
                          color: MyColors.colorPalette['primary'],
                        ),
                        Text(
                          'Add Payment',
                          style: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors.colorPalette['primary']),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}



// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE WITH DIRECT BACKEND CALLS
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PaymentTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;
//   final String doctorId;
//   final Map<String, dynamic>? treatmentData;

//   const PaymentTab({
//     super.key,
//     required this.clinicId,
//     required this.patientId,
//     this.treatmentId,
//     required this.doctorId,
//     this.treatmentData,
//   });

//   @override
//   State<PaymentTab> createState() => _PaymentTabState();
// }

// class _PaymentTabState extends State<PaymentTab> {
//   Map<String, dynamic>? _loadedTreatmentData;
//   bool isAddingPayment = false;
//   bool isPaymentSaved = false;
//   bool isInputValid = false;

//   double containerHeight = 400;
//   TextEditingController paymentController = TextEditingController();
//   final FocusNode _saveButtonFocusNode = FocusNode();
//   String? capturedPaymentAmount;

//   List<Map<String, dynamic>> paymentList = [];
//   double? closingBalance;
//   double initialOpeningBalance = 0.0;
//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialValues();
//   }

//   Future<void> _loadInitialValues() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Check if the treatment ID has changed, indicating a new treatment
//     if (widget.treatmentId != null && widget.treatmentData != null) {
//       String? lastTreatmentId = prefs.getString('lastTreatmentId');
//       if (lastTreatmentId != widget.treatmentId) {
//         // New treatment, reset initialOpeningBalance
//         await prefs.remove('initialOpeningBalance');
//         await prefs.setString('lastTreatmentId', widget.treatmentId!);
//       }

//       // Load initialOpeningBalance from SharedPreferences or set it
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

//   void savePayment() async {
//     try {
//       double paymentAmount = double.tryParse(paymentController.text) ?? 0.0;

//       final paymentsCollectionRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(widget.patientId)
//           .collection('treatments')
//           .doc(widget.treatmentId)
//           .collection('payments');

//       final QuerySnapshot paymentDocs =
//           await paymentsCollectionRef.orderBy('date', descending: false).get();

//       double openingBalance;

//       if (paymentDocs.docs.isEmpty) {
//         openingBalance = initialOpeningBalance;
//       } else {
//         final mostRecentPayment =
//             paymentDocs.docs.last.data() as Map<String, dynamic>;
//         openingBalance = mostRecentPayment['closingBalance'] as double;
//       }

//       double closingBalance = openingBalance - paymentAmount;

//       Payment paymentData = Payment(
//         paymentId: '',
//         date: DateTime.now(),
//         openingBalance: openingBalance,
//         paymentReceived: paymentAmount,
//         adjustments: 0.0,
//         adjustmentDetails: '',
//         closingBalance: closingBalance,
//       );

//       Map<String, dynamic> paymentMap = paymentData.toMap();

//       final paymentDocRef = await paymentsCollectionRef.add(paymentMap);
//       await paymentDocRef.update({'paymentId': paymentDocRef.id});

//       FocusScope.of(context).requestFocus(_saveButtonFocusNode);

//       paymentController.clear();

//       setState(() {
//         isPaymentSaved = false;
//         isAddingPayment = false;
//         isInputValid = false;
//       });

//       devtools.log('Payment data pushed to the backend successfully');
//       fetchAndRenderPayments();
//     } catch (error) {
//       devtools.log('Error submitting payment data: $error');
//     }
//   }

//   void _handleSave() async {
//     setState(() {
//       _isSaving = true; // Disable the button immediately
//     });

//     try {
//       savePayment(); // Perform the save operation
//     } finally {
//       setState(() {
//         _isSaving = false; // Re-enable the button if needed
//       });
//     }
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
//       // Clear the tempPaymentList to start fresh
//       List<Map<String, dynamic>> tempPaymentList = [];
//       double? lastClosingBalance;
//       double runningBalance = initialOpeningBalance;

//       // 1. Add the initial opening balance entry (always visible)
//       tempPaymentList.add({
//         'date': DateFormat('dd-MM-yy').format(
//             DateTime.now()), // Use the current date or initial treatment date
//         'description': 'Opening balance',
//         'transaction': null, // No transaction for the opening balance
//         'balance': initialOpeningBalance, // The opening balance itself
//         'isError': false,
//       });

//       // 2. Fetch payments from Firestore (if any payments have been made)
//       final QuerySnapshot paymentDocs =
//           await paymentsCollectionRef.orderBy('date', descending: false).get();

//       // 3. Process the fetched payment documents
//       for (QueryDocumentSnapshot doc in paymentDocs.docs) {
//         Map<String, dynamic> paymentData = doc.data() as Map<String, dynamic>;

//         // Safely extract the necessary values, using defaults if null
//         num paymentReceived = paymentData['paymentReceived'] as num? ?? 0.0;
//         num adjustments = paymentData['adjustments'] as num? ?? 0.0;
//         String adjustmentDetails =
//             paymentData['adjustmentDetails'] as String? ?? '';
//         DateTime date = (paymentData['date'] as Timestamp).toDate();

//         // Update the closing balance if it exists
//         if (paymentData.containsKey('closingBalance')) {
//           lastClosingBalance =
//               (paymentData['closingBalance'] as num?)?.toDouble() ??
//                   runningBalance;
//         }

//         String formattedDate = DateFormat('dd-MM-yy').format(date);

//         // Update running balance (deducting the payment, adding adjustments)
//         runningBalance -= paymentReceived;
//         runningBalance += adjustments;

//         // 4. Add payment entry to the list (if any payments are recorded)
//         tempPaymentList.add({
//           'date': formattedDate,
//           'description': adjustmentDetails.isNotEmpty
//               ? adjustmentDetails
//               : 'Payment received',
//           'transaction': paymentReceived != 0 ? -paymentReceived : adjustments,
//           'balance': runningBalance,
//           'isError': paymentReceived != 0,
//         });
//       }

//       // 5. Finally, update the paymentList with the temp list and update the closing balance
//       setState(() {
//         paymentList = tempPaymentList;
//         closingBalance = lastClosingBalance;
//       });
//     } catch (e) {
//       devtools.log('Error fetching payments: $e');
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

//   //------------------------------------------------------------------//
//   void addProcedureToPaymentList(String procedureName, double procedureFee) {
//     // Get the current date for the new procedure
//     String currentDate = DateFormat('dd-MM-yy').format(DateTime.now());

//     // Calculate the new balance (previous balance + procedure fee)
//     double newBalance = paymentList.isEmpty
//         ? initialOpeningBalance + procedureFee // if this is the first procedure
//         : paymentList.last['balance'] + procedureFee;

//     // Add a new entry to the paymentList
//     paymentList.add({
//       'date': currentDate,
//       'description': procedureName, // Add the specific procedure name
//       'transaction': procedureFee,
//       'balance': newBalance,
//       'isError': false // assuming no error here
//     });

//     // Update the UI to reflect the changes
//     setState(() {});
//   }

//   //------------------------------------------------------------------//

//   @override
//   Widget build(BuildContext context) {
//     final currentDate = DateTime.now();
//     final formattedDate = DateFormat('dd-MM-yy').format(currentDate);
//     devtools.log(
//         'Welcome to build widget of PaymentTab. _loadedTreatmentData is $_loadedTreatmentData');
//     devtools.log('treatmentId is ${widget.treatmentId}');
//     devtools.log('treatmentData is ${widget.treatmentData}');

//     return SingleChildScrollView(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           const SizedBox(height: 16),
//           Divider(
//             thickness: 1.0,
//             color: MyColors.colorPalette['outline'],
//           ),
//           ...[
//             _buildPaymentRow(null, isHeader: true), // Add header row
//             ...paymentList.map((payment) => _buildPaymentRow(payment)).toList(),
//           ],
//           Divider(
//             thickness: 1.0,
//             color: MyColors.colorPalette['outline'],
//           ),
//           if (isAddingPayment && !isPaymentSaved) ...[
//             Container(
//               color: MyColors.colorPalette['outline-variant'],
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           formattedDate,
//                           style: MyTextStyle.textStyleMap['title-small']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                         const SizedBox(
//                             width: 16), // Add spacing between date and label
//                         Text(
//                           'Payment received',
//                           style: MyTextStyle.textStyleMap['title-small']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                       ],
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(1.0),
//                       child: Container(
//                         width: 120,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: Colors.grey,
//                             width: 1.0,
//                           ),
//                           borderRadius: BorderRadius.circular(5.0),
//                         ),
//                         child: TextFormField(
//                           controller: paymentController,
//                           keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true,
//                           ),
//                           textAlign: TextAlign.right,
//                           onChanged: (value) {
//                             setState(() {
//                               isInputValid = value.isNotEmpty;
//                             });
//                           },
//                           decoration: const InputDecoration(
//                             contentPadding: EdgeInsets.symmetric(
//                                 horizontal: 8.0, vertical: 8.0),
//                             border: InputBorder.none,
//                             hintText: 'amount',
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 ElevatedButton(
//                   onPressed: isInputValid && !_isSaving
//                       ? _handleSave
//                       : null, // Update onPressed
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all(
//                         isInputValid && !_isSaving
//                             ? MyColors.colorPalette['primary']
//                             : Colors.grey),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         side: BorderSide(
//                             color: isInputValid && !_isSaving
//                                 ? MyColors.colorPalette['primary']!
//                                 : Colors.grey),
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   focusNode: _saveButtonFocusNode,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Text(
//                       'Save',
//                       style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                           color: MyColors.colorPalette['on-primary']),
//                     ),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       isAddingPayment = false;
//                       paymentController.clear();
//                     });
//                   },
//                   child: Text(
//                     'Cancel',
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['primary']),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//           if (!isAddingPayment)
//             Padding(
//               padding: const EdgeInsets.only(top: 16.0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: SizedBox(
//                   height: 48,
//                   child: ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.all(
//                           MyColors.colorPalette['on-primary']!),
//                       shape: MaterialStateProperty.all(
//                         RoundedRectangleBorder(
//                           side: BorderSide(
//                               color: MyColors.colorPalette['primary']!,
//                               width: 1.0),
//                           borderRadius: BorderRadius.circular(24.0),
//                         ),
//                       ),
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         isAddingPayment = true;
//                       });
//                     },
//                     child: Wrap(
//                       children: [
//                         Icon(
//                           Icons.add,
//                           color: MyColors.colorPalette['primary'],
//                         ),
//                         Text(
//                           'Add Payment',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['primary']),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class Payment {
//   final String paymentId;
//   final DateTime date;
//   final double openingBalance;
//   final double paymentReceived;
//   final double adjustments;
//   final String adjustmentDetails;
//   final double closingBalance;

//   Payment({
//     required this.paymentId,
//     required this.date,
//     required this.openingBalance,
//     required this.paymentReceived,
//     required this.adjustments,
//     required this.adjustmentDetails,
//     required this.closingBalance,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'paymentId': paymentId,
//       'date': date,
//       'openingBalance': openingBalance,
//       'paymentReceived': paymentReceived,
//       'adjustments': adjustments,
//       'adjustmentDetails': adjustmentDetails,
//       'closingBalance': closingBalance,
//     };
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE BUT DO NOT DISPLAY procName WITH NUMBER OF AFFECTED TEETH
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PaymentTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;
//   final String doctorId;
//   final Map<String, dynamic>? treatmentData;

//   const PaymentTab({
//     super.key,
//     required this.clinicId,
//     required this.patientId,
//     this.treatmentId,
//     required this.doctorId,
//     this.treatmentData,
//   });

//   @override
//   State<PaymentTab> createState() => _PaymentTabState();
// }

// class _PaymentTabState extends State<PaymentTab> {
//   Map<String, dynamic>? _loadedTreatmentData;
//   bool isAddingPayment = false;
//   bool isPaymentSaved = false;
//   bool isInputValid = false;

//   double containerHeight = 400;
//   TextEditingController paymentController = TextEditingController();
//   final FocusNode _saveButtonFocusNode = FocusNode();
//   String? capturedPaymentAmount;

//   List<Map<String, dynamic>> paymentList = [];
//   double? closingBalance;
//   double initialOpeningBalance = 0.0;
//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialValues();
//   }

//   Future<void> _loadInitialValues() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Check if the treatment ID has changed, indicating a new treatment
//     if (widget.treatmentId != null && widget.treatmentData != null) {
//       String? lastTreatmentId = prefs.getString('lastTreatmentId');
//       if (lastTreatmentId != widget.treatmentId) {
//         // New treatment, reset initialOpeningBalance
//         await prefs.remove('initialOpeningBalance');
//         await prefs.setString('lastTreatmentId', widget.treatmentId!);
//       }

//       // Load initialOpeningBalance from SharedPreferences or set it
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

//   void savePayment() async {
//     try {
//       double paymentAmount = double.tryParse(paymentController.text) ?? 0.0;

//       final paymentsCollectionRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(widget.patientId)
//           .collection('treatments')
//           .doc(widget.treatmentId)
//           .collection('payments');

//       final QuerySnapshot paymentDocs =
//           await paymentsCollectionRef.orderBy('date', descending: false).get();

//       double openingBalance;

//       if (paymentDocs.docs.isEmpty) {
//         openingBalance = initialOpeningBalance;
//       } else {
//         final mostRecentPayment =
//             paymentDocs.docs.last.data() as Map<String, dynamic>;
//         openingBalance = mostRecentPayment['closingBalance'] as double;
//       }

//       double closingBalance = openingBalance - paymentAmount;

//       Payment paymentData = Payment(
//         paymentId: '',
//         date: DateTime.now(),
//         openingBalance: openingBalance,
//         paymentReceived: paymentAmount,
//         adjustments: 0.0,
//         adjustmentDetails: '',
//         closingBalance: closingBalance,
//       );

//       Map<String, dynamic> paymentMap = paymentData.toMap();

//       final paymentDocRef = await paymentsCollectionRef.add(paymentMap);
//       await paymentDocRef.update({'paymentId': paymentDocRef.id});

//       FocusScope.of(context).requestFocus(_saveButtonFocusNode);

//       paymentController.clear();

//       setState(() {
//         isPaymentSaved = false;
//         isAddingPayment = false;
//         isInputValid = false;
//       });

//       devtools.log('Payment data pushed to the backend successfully');
//       fetchAndRenderPayments();
//     } catch (error) {
//       devtools.log('Error submitting payment data: $error');
//     }
//   }

//   void _handleSave() async {
//     setState(() {
//       _isSaving = true; // Disable the button immediately
//     });

//     try {
//       savePayment(); // Perform the save operation

//       // Reset state or navigate to another screen
//     } finally {
//       setState(() {
//         _isSaving = false; // Re-enable the button if needed
//       });
//     }
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

//       // Add the initial opening balance entry
//       paymentList.add({
//         'date': DateFormat('dd-MM-yy').format(DateTime.now()),
//         'description': 'Opening balance',
//         // 'transaction': initialOpeningBalance,
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

//         runningBalance -= paymentReceived; // Deduct payment received
//         runningBalance += adjustments; // Add adjustments

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
//       });
//     } catch (e) {
//       devtools.log('Error fetching payments: $e');
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
//     // final currentDate = DateTime.now();
//     // final formattedDate = DateFormat('MMM d, EEE').format(currentDate);
//     final currentDate = DateTime.now();
//     final formattedDate = DateFormat('dd-MM-yy').format(currentDate);
//     devtools.log(
//         'Welcome to build widget of PaymentTab. _loadedTreatmentData is $_loadedTreatmentData');
//     devtools.log('treatmentId is ${widget.treatmentId}');
//     devtools.log('treatmentData is ${widget.treatmentData}');

//     return SingleChildScrollView(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           const SizedBox(height: 16),
//           Divider(
//             thickness: 1.0,
//             color: MyColors.colorPalette['outline'],
//           ),
//           ...[
//             _buildPaymentRow(null, isHeader: true), // Add header row
//             ...paymentList.map((payment) => _buildPaymentRow(payment)).toList(),
//           ],
//           Divider(
//             thickness: 1.0,
//             color: MyColors.colorPalette['outline'],
//           ),
//           if (isAddingPayment && !isPaymentSaved) ...[
//             Container(
//               color: MyColors.colorPalette['outline-variant'],
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           formattedDate,
//                           style: MyTextStyle.textStyleMap['title-small']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                         const SizedBox(
//                             width: 16), // Add spacing between date and label
//                         Text(
//                           'Payment received',
//                           style: MyTextStyle.textStyleMap['title-small']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                       ],
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(1.0),
//                       child: Container(
//                         width: 120,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: Colors.grey,
//                             width: 1.0,
//                           ),
//                           borderRadius: BorderRadius.circular(5.0),
//                         ),
//                         child: TextFormField(
//                           controller: paymentController,
//                           keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true,
//                           ),
//                           textAlign: TextAlign.right,
//                           onChanged: (value) {
//                             setState(() {
//                               isInputValid = value.isNotEmpty;
//                             });
//                           },
//                           decoration: const InputDecoration(
//                             contentPadding: EdgeInsets.symmetric(
//                                 horizontal: 8.0, vertical: 8.0),
//                             border: InputBorder.none,
//                             hintText: 'amount',
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 ElevatedButton(
//                   onPressed: isInputValid && !_isSaving
//                       ? _handleSave
//                       : null, // Update onPressed
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all(
//                         isInputValid && !_isSaving
//                             ? MyColors.colorPalette['primary']
//                             : Colors.grey),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         side: BorderSide(
//                             color: isInputValid && !_isSaving
//                                 ? MyColors.colorPalette['primary']!
//                                 : Colors.grey),
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   focusNode: _saveButtonFocusNode,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Text(
//                       'Save',
//                       style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                           color: MyColors.colorPalette['on-primary']),
//                     ),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       isAddingPayment = false;
//                       paymentController.clear();
//                     });
//                   },
//                   child: Text(
//                     'Cancel',
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['primary']),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//           if (!isAddingPayment)
//             Padding(
//               padding: const EdgeInsets.only(top: 16.0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: SizedBox(
//                   height: 48,
//                   child: ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor: MaterialStateProperty.all(
//                           MyColors.colorPalette['on-primary']!),
//                       shape: MaterialStateProperty.all(
//                         RoundedRectangleBorder(
//                           side: BorderSide(
//                               color: MyColors.colorPalette['primary']!,
//                               width: 1.0),
//                           borderRadius: BorderRadius.circular(24.0),
//                         ),
//                       ),
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         isAddingPayment = true;
//                       });
//                     },
//                     child: Wrap(
//                       children: [
//                         Icon(
//                           Icons.add,
//                           color: MyColors.colorPalette['primary'],
//                         ),
//                         Text(
//                           'Add Payment',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['primary']),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class Payment {
//   final String paymentId;
//   final DateTime date;
//   final double openingBalance;
//   final double paymentReceived;
//   final double adjustments;
//   final String adjustmentDetails;
//   final double closingBalance;

//   Payment({
//     required this.paymentId,
//     required this.date,
//     required this.openingBalance,
//     required this.paymentReceived,
//     required this.adjustments,
//     required this.adjustmentDetails,
//     required this.closingBalance,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'paymentId': paymentId,
//       'date': date,
//       'openingBalance': openingBalance,
//       'paymentReceived': paymentReceived,
//       'adjustments': adjustments,
//       'adjustmentDetails': adjustmentDetails,
//       'closingBalance': closingBalance,
//     };
//   }
// }
