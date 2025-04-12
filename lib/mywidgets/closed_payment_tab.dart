import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/firestore/payment_service.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;

// class ClosedPaymentTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String? treatmentId;

//   const ClosedPaymentTab({
//     super.key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   });

//   @override
//   State<ClosedPaymentTab> createState() => _ClosedPaymentTabState();
// }
class ClosedPaymentTab extends StatefulWidget {
  final String clinicId;
  final String patientId;
  final String? treatmentId;
  final Map<String, dynamic>? treatmentData; // Add this parameter

  const ClosedPaymentTab({
    super.key,
    required this.clinicId,
    required this.patientId,
    required this.treatmentId,
    required this.treatmentData, // Include it in the constructor
  });

  @override
  State<ClosedPaymentTab> createState() => _ClosedPaymentTabState();
}

class _ClosedPaymentTabState extends State<ClosedPaymentTab> {
  PaymentService? _paymentService;
  List<Map<String, dynamic>> paymentList = [];
  double initialOpeningBalance = 0.0;

  // @override
  // void initState() {
  //   super.initState();
  //   _paymentService = PaymentService(
  //     clinicId: widget.clinicId,
  //     patientId: widget.patientId,
  //     treatmentId: widget.treatmentId!,
  //   );
  //   fetchAndRenderPayments();
  // }
  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      treatmentId: widget.treatmentId!,
    );

    // Load initial opening balance similarly to how it's done in PaymentTab
    _loadInitialValues();
  }

  Future<void> _loadInitialValues() async {
    if (widget.treatmentId != null) {
      double treatmentCost =
          widget.treatmentData?['treatmentCost']['totalCost'] ?? 0.0;
      double consultationFee = widget.treatmentData?['consultationFee'] ?? 0.0;

      setState(() {
        initialOpeningBalance = treatmentCost + consultationFee;
      });
    }

    devtools.log(
        'Initial opening balance (ClosedPaymentTab) is $initialOpeningBalance');
    fetchAndRenderPayments();
  }

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
        ],
      ),
    );
  }
}
