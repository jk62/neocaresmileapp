import 'package:flutter/material.dart';

import 'package:neocaresmileapp/firestore/procedure_service.dart';
import 'package:neocaresmileapp/firestore/treatment_service.dart';
import 'package:neocaresmileapp/mywidgets/discount_input_formatter.dart';
import 'package:neocaresmileapp/mywidgets/image_cache_provider.dart';
import 'package:neocaresmileapp/mywidgets/procedure.dart';

import 'package:neocaresmileapp/mywidgets/create_edit_treatment_screen_5.dart';
import 'package:neocaresmileapp/mywidgets/procedure_cache_provider.dart';
import 'package:neocaresmileapp/mywidgets/user_data_provider.dart';
import 'package:neocaresmileapp/mywidgets/my_bottom_navigation_bar.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

import 'dart:developer' as devtools show log;

import 'package:provider/provider.dart';

class CreateEditTreatmentScreen4 extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String patientId;
  final int age;
  final String gender;
  final String patientName;
  final String patientMobileNumber;
  final String? patientPicUrl;
  final PageController pageController;
  final UserDataProvider userData;
  final String doctorName;
  final String? uhid;
  final Map<String, dynamic>? treatmentData;
  final String? treatmentId;
  final bool isEditMode;
  final List<String>? originalProcedures;
  final List<Map<String, dynamic>> currentProcedures;
  final List<Map<String, dynamic>> pictureData11;
  final ImageCacheProvider imageCacheProvider;
  final String? chiefComplaint;

  const CreateEditTreatmentScreen4({
    super.key,
    required this.patientId,
    required this.age,
    required this.gender,
    required this.patientName,
    required this.patientMobileNumber,
    required this.patientPicUrl,
    required this.pageController,
    required this.clinicId,
    required this.doctorId,
    required this.userData,
    required this.doctorName,
    required this.uhid,
    this.treatmentData,
    this.treatmentId,
    this.isEditMode = false,
    required this.originalProcedures,
    required this.currentProcedures,
    required this.pictureData11,
    required this.imageCacheProvider,
    required this.chiefComplaint,
  });

  @override
  State<CreateEditTreatmentScreen4> createState() =>
      _CreateEditTreatmentScreen3State();
}

class _CreateEditTreatmentScreen3State
    extends State<CreateEditTreatmentScreen4> {
  Set<String> selectedProcedureNames = {};
  Map<String, double> procedureCostMap = {};
  bool isLumpsumDiscountSelected = false;
  bool isConsentTaken = false;
  bool isTreatmentClose = false;

  double consultationFee = 0.0;
  CostResult costResult = CostResult(0.0, 0.0, 0.0, 0.0);

  bool nextIconSelectable = false;
  double lumpsumDiscountAmount = 0;
  bool _isSubmitting = false;
  double originalDiscount = 0;
  Map<String, dynamic>? _loadedTreatmentData;

  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _chiefComplaintController =
      TextEditingController();
  final FocusNode _discountFocusNode = FocusNode();

  List<Map<String, dynamic>> paymentList = [];
  double closingBalance = 0.0;
  bool _isLoading = false;
  List<Procedure> allProcedures = [];
  late TreatmentService _treatmentService;

  // @override
  // void initState() {
  //   super.initState();
  //   devtools
  //       .log('widget.userData.procedures are : ${widget.userData.procedures}');
  //   widget.userData.procedures.forEach(extractProcedureName);
  //   devtools.log('Selected procedures: $selectedProcedureNames');
  //   _treatmentService = TreatmentService(
  //     clinicId: widget.clinicId,
  //     patientId: widget.patientId,
  //   );

  //   if (widget.isEditMode &&
  //       widget.treatmentData != null &&
  //       widget.treatmentData!.containsKey('treatmentCost')) {
  //     final treatmentCost = widget.treatmentData!['treatmentCost'];
  //     if (treatmentCost.containsKey('discount')) {
  //       lumpsumDiscountAmount = (treatmentCost['discount'] as num).toDouble();

  //       // Always prefix the minus sign since discount is inherently a deduction
  //       _discountController.text =
  //           '-${lumpsumDiscountAmount.toStringAsFixed(0)}';

  //       originalDiscount = lumpsumDiscountAmount; // Store original discount
  //       isLumpsumDiscountSelected = true; // Mark that discount is selected
  //     }
  //   }

  //   _loadedTreatmentData = widget.treatmentData;

  //   fetchConsultationFee().then((consultationFee) {
  //     devtools.log('consultationFee fetched is $consultationFee');
  //     if (consultationFee != null) {
  //       setState(() {
  //         this.consultationFee = consultationFee.toDouble();
  //         fetchProcedureCosts().then((_) {
  //           costResult = computeTotalCost();
  //         });
  //       });
  //     }
  //   });

  //   _discountFocusNode.addListener(() {
  //     if (!_discountFocusNode.hasFocus) {
  //       final enteredDiscount =
  //           double.tryParse(_discountController.text.replaceAll('-', '')) ?? 0;
  //       if (enteredDiscount > costResult.totalCost.toInt()) {
  //         _showSnackBar('Discount cannot be more than total cost');
  //         _discountController.text = lumpsumDiscountAmount.toString();
  //       } else {
  //         setState(() {
  //           lumpsumDiscountAmount = enteredDiscount;
  //           costResult = computeTotalCost();
  //         });
  //       }
  //     }
  //   });

  //   fetchAndRenderPayments(); // Fetch and render payments when the screen is initialized
  // }

  @override
  void initState() {
    super.initState();
    devtools
        .log('widget.userData.procedures are : ${widget.userData.procedures}');
    widget.userData.procedures.forEach(extractProcedureName);
    devtools.log('Selected procedures: $selectedProcedureNames');

    // Initialize the TreatmentService
    _treatmentService = TreatmentService(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
    );

    // Handle discount if in edit mode and discount data exists
    if (widget.isEditMode &&
        widget.treatmentData != null &&
        widget.treatmentData!.containsKey('treatmentCost')) {
      final treatmentCost = widget.treatmentData!['treatmentCost'];
      if (treatmentCost.containsKey('discount')) {
        lumpsumDiscountAmount = (treatmentCost['discount'] as num).toDouble();

        // Always prefix the minus sign since discount is inherently a deduction
        _discountController.text =
            '-${lumpsumDiscountAmount.toStringAsFixed(0)}';

        originalDiscount = lumpsumDiscountAmount; // Store original discount
        isLumpsumDiscountSelected = true; // Mark that discount is selected
      }
    }

    _loadedTreatmentData = widget.treatmentData;

    // Fetch consultation fee using TreatmentService
    _treatmentService
        .fetchConsultationFee(widget.doctorId)
        .then((consultationFee) {
      devtools.log('Consultation fee fetched is $consultationFee');
      if (consultationFee != null) {
        setState(() {
          this.consultationFee = consultationFee.toDouble();
          // Fetch procedure costs after consultation fee is set
          fetchProcedureCosts().then((_) {
            costResult = computeTotalCost();
          });
        });
      }
    });

    // Add a listener for the discount focus node
    _discountFocusNode.addListener(() {
      if (!_discountFocusNode.hasFocus) {
        final enteredDiscount =
            double.tryParse(_discountController.text.replaceAll('-', '')) ?? 0;
        if (enteredDiscount > costResult.totalCost.toInt()) {
          _showSnackBar('Discount cannot be more than total cost');
          _discountController.text = lumpsumDiscountAmount.toString();
        } else {
          setState(() {
            lumpsumDiscountAmount = enteredDiscount;
            costResult = computeTotalCost();
          });
        }
      }
    });

    // Fetch and render payments when the screen is initialized
    fetchAndRenderPayments();
  }

  @override
  void dispose() {
    _discountController.dispose();
    _discountFocusNode.dispose();
    _chiefComplaintController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------------ //

  Future<void> fetchProcedureCosts() async {
    ProcedureService procedureService = ProcedureService(widget.clinicId);
    allProcedures = await procedureService.searchProcedures('');
    procedureCostMap = {
      for (var procedure in allProcedures) procedure.procId: procedure.procFee
    };

    devtools.log(
        'Procedure cost map: $procedureCostMap'); // Log the cost map to ensure it's correct

    setState(() {
      costResult = computeTotalCost(); // Ensure cost is computed after fetching
    });
  }
  // ------------------------------------------------------------------------ //

  CostResult computeTotalCost() {
    double totalCost = consultationFee;
    double discount = 0.0;

    for (var procedure in widget.userData.procedures) {
      devtools.log(
          'Processing procedure: ${procedure['procName']} with data: $procedure');
      final isToothwise = procedure['isToothwise'] ?? false;
      devtools.log(
          'Retrieved isToothwise of: ${procedure['procName']} is: $isToothwise');

      double procedureCost = 0.0;

      if (isToothwise) {
        final affectedTeethCount = procedure['affectedTeeth']?.length ?? 0;
        procedureCost =
            affectedTeethCount * (procedureCostMap[procedure['procId']] ?? 0.0);
      } else {
        procedureCost = procedureCostMap[procedure['procId']] ?? 0.0;
      }

      devtools
          .log('Procedure Cost for ${procedure['procName']}: $procedureCost');
      totalCost += procedureCost;
    }

    final totalCostBeforeDiscount = totalCost;

    if (isLumpsumDiscountSelected) {
      discount = lumpsumDiscountAmount;
      totalCost -= discount;
    }

    totalCost = totalCost.roundToDouble();
    discount = discount.roundToDouble();

    devtools.log(
        'Total Cost: $totalCost, Discount: $discount'); // Log final amounts
    return CostResult(
      totalCost,
      discount,
      consultationFee,
      totalCostBeforeDiscount,
    );
  }

  // ------------------------------------------------------------------------ //

  // ----------------------------------------------------------------------- //
  // Future<void> _submitData() async {
  //   devtools.log('Welcome to _submitData');
  //   try {
  //     setState(() {
  //       _isLoading = true; // Show loading indicator
  //     });

  //     final clinicId = widget.clinicId;
  //     final patientId = widget.patientId;

  //     String? chiefComplaint = widget.userData.chiefComplaint;
  //     String? medicalHistory =
  //         widget.userData.medicalHistory; // Include medical history
  //     devtools.log(
  //         'This is coming from inside _submitData. chiefComplaint: $chiefComplaint, medicalHistory: $medicalHistory');

  //     List<Map<String, dynamic>> oralExaminationData =
  //         widget.userData.oralExamination.map((examination) {
  //       return {
  //         'conditionId': examination['conditionId'],
  //         'conditionName': examination['conditionName'],
  //         'affectedTeeth': examination['affectedTeeth'],
  //         'doctorNote': examination['doctorNote'],
  //       };
  //     }).toList();
  //     devtools.log(
  //         'This is coming from inside _submitData. oralExaminationData: $oralExaminationData');

  //     List<Map<String, dynamic>> proceduresData =
  //         widget.userData.procedures.map((procedure) {
  //       return {
  //         'procId': procedure['procId'],
  //         'procName': procedure['procName'],
  //         'affectedTeeth': procedure['affectedTeeth'],
  //         'doctorNote': procedure['doctorNote'],
  //         'isToothwise': procedure['isToothwise'] ?? false,
  //       };
  //     }).toList();

  //     devtools.log(
  //         'This is coming from inside _submitData. proceduresData: $proceduresData');

  //     final consultationFee = await fetchConsultationFee();
  //     if (consultationFee == null) {
  //       devtools.log('Consultation fee not available');
  //       throw 'Consultation fee not available';
  //     }
  //     devtools.log('consultationFee: $consultationFee');

  //     double selectedProceduresFee = 0.0;
  //     Map<String, dynamic> treatmentCost = {
  //       'consultationFee': consultationFee,
  //     };

  //     for (var procedure in widget.userData.procedures) {
  //       final procId = procedure['procId'];
  //       final procedureValue = procedureCostMap[procId];
  //       final isToothwise = procedure['isToothwise'] ?? false;

  //       if (procedureValue != null) {
  //         double procedureFee = procedureValue.toDouble();

  //         if (isToothwise) {
  //           final toothCount =
  //               (procedure['affectedTeeth'] as List<dynamic>?)?.length ?? 0;
  //           procedureFee *= toothCount;
  //         }

  //         selectedProceduresFee += procedureFee;
  //         treatmentCost[procId] = procedureFee;
  //       } else {
  //         devtools.log('Procedure value for $procId is null');
  //       }
  //     }

  //     devtools.log('treatmentCost: $treatmentCost');

  //     double totalCost = consultationFee.toDouble() + selectedProceduresFee;
  //     if (isLumpsumDiscountSelected) {
  //       totalCost -= lumpsumDiscountAmount;
  //       treatmentCost['discount'] = lumpsumDiscountAmount;
  //     }
  //     treatmentCost['totalCost'] = totalCost;
  //     devtools.log('totalCost: $totalCost');

  //     final treatmentCloseDate =
  //         isTreatmentClose ? DateTime.now().toUtc() : null;

  //     final treatmentData = {
  //       'chiefComplaint': chiefComplaint,
  //       'medicalHistory':
  //           medicalHistory, // Add medical history to the treatment data
  //       'oralExamination': oralExaminationData,
  //       'procedures': proceduresData,
  //       'treatmentCost': treatmentCost,
  //       'isConsentTaken': isConsentTaken,
  //       'isTreatmentClose': isTreatmentClose,
  //       'treatmentCloseDate': treatmentCloseDate,
  //       'treatmentDate': DateTime.now().toUtc(),
  //     };
  //     devtools.log('treatmentData: $treatmentData');

  //     final treatmentsRef = FirebaseFirestore.instance
  //         .collection('clinics')
  //         .doc(clinicId)
  //         .collection('patients')
  //         .doc(patientId)
  //         .collection('treatments');

  //     String treatmentId;
  //     if (widget.isEditMode) {
  //       treatmentId = widget.treatmentId!;
  //       await treatmentsRef.doc(treatmentId).update(treatmentData);
  //     } else {
  //       final treatmentDocRef = await treatmentsRef.add(treatmentData);
  //       treatmentId = treatmentDocRef.id;
  //       await treatmentDocRef.update({'treatmentId': treatmentId});
  //     }
  //     devtools.log('treatmentId: $treatmentId');

  //     // Handle Images
  //     await _uploadAndHandleImages(treatmentsRef, treatmentId, patientId);
  //     //--------------//
  //     // Handle Prescriptions
  //     // Handle Prescriptions as a single document
  //     if (widget.userData.prescriptions.isNotEmpty) {
  //       final prescriptionData = {
  //         'treatmentId':
  //             treatmentId, // Include treatmentId in the prescription data
  //         'medPrescribed': widget.userData
  //             .prescriptions, // Push all prescriptions in a single document
  //       };

  //       final prescriptionCollectionRef = FirebaseFirestore.instance
  //           .collection('clinics')
  //           .doc(clinicId)
  //           .collection('patients')
  //           .doc(patientId)
  //           .collection('treatments')
  //           .doc(treatmentId)
  //           .collection('prescriptions');

  //       final prescriptionDocRef =
  //           await prescriptionCollectionRef.add(prescriptionData);
  //       final prescriptionId = prescriptionDocRef.id;

  //       await prescriptionDocRef.update({'prescriptionId': prescriptionId});
  //       devtools.log('Prescriptions added with ID: $prescriptionId');
  //     }
  //     //--------------//

  //     devtools.log('Treatment data pushed to the backend successfully');
  //     if (!mounted) return;

  //     context.read<ProcedureCacheProvider>().clearProcedures();
  //     widget.imageCacheProvider.clearPictures();
  //     widget.userData.clearState();

  //     if (mounted) {
  //       await _navigateToCreateEditTreatmentScreen5(context, treatmentId);
  //     }
  //   } catch (error) {
  //     devtools.log('Error submitting treatment data: $error');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Error submitting treatment data. Please try again.'),
  //         ),
  //       );
  //       setState(() {
  //         _isSubmitting = false;
  //       });
  //     }
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
  //------------------------------------------------------------------------//
  // Future<void> _uploadAndHandleImages(CollectionReference treatmentsRef,
  //     String treatmentId, String patientId) async {
  //   final picturesCollectionRef =
  //       treatmentsRef.doc(treatmentId).collection('pictures');

  //   final newPictures = widget.imageCacheProvider.pictures
  //       .where((picture) => picture['isExisting'] == false)
  //       .toList();
  //   final editedPictures = widget.imageCacheProvider.pictures
  //       .where((picture) => picture['isEdited'] == true)
  //       .toList();

  //   devtools.log(
  //       'This is coming from inside _submitData. New pictures to be added: $newPictures');
  //   devtools.log(
  //       'This is coming from inside _submitData. Edited pictures to be updated: $editedPictures');

  //   for (var picture in newPictures) {
  //     devtools.log(
  //         'This is coming from inside for loop meant for pushing new pictures to the backend.');
  //     final String localPath = picture['localPath'];
  //     final String picId = picture['picId'];
  //     final Reference storageRef = FirebaseStorage.instance.ref().child(
  //         'patient_treatment_pictures/$patientId/$treatmentId/$picId.jpg');

  //     await storageRef.putFile(File(localPath));
  //     final String picUrl = await storageRef.getDownloadURL();
  //     devtools.log(
  //         'New picture pushed to the storage successfully at picUrl $picUrl ');

  //     picture['picUrl'] = picUrl;
  //     picture['treatmentId'] = treatmentId;
  //     picture['isExisting'] = true;

  //     await picturesCollectionRef.add(picture);
  //     devtools.log('Picture document created successfully !');
  //   }

  //   for (var picture in editedPictures) {
  //     if (picture['docId'] == null || picture['docId'].isEmpty) {
  //       continue;
  //     }
  //     devtools.log('Uploading edited picture: ${picture['localPath']}');
  //     final String localPath = picture['localPath'];
  //     final String picId = picture['picId'];
  //     final String? docId = picture['docId'];
  //     final Reference storageRef = FirebaseStorage.instance.ref().child(
  //         'patient_treatment_pictures/$patientId/$treatmentId/$picId.jpg');

  //     await storageRef.putFile(File(localPath));
  //     final String picUrl = await storageRef.getDownloadURL();
  //     devtools.log('Uploaded edited picture at URL: $picUrl');

  //     picture['picUrl'] = picUrl;
  //     picture['treatmentId'] = treatmentId;
  //     picture['isExisting'] = true;
  //     picture['isEdited'] = false;

  //     await picturesCollectionRef.add(picture);

  //     devtools
  //         .log('Removing old Firestore document for edited picture: $docId');
  //     if (docId != null && docId.isNotEmpty) {
  //       await picturesCollectionRef.doc(docId).delete();
  //       devtools.log('Old picture doc removed successfully.');
  //     }
  //   }

  //   final picturesToDelete = widget.imageCacheProvider.pictures
  //       .where((picture) => picture['isMarkedForDeletion'] == true)
  //       .toList();
  //   devtools.log('Pictures to be deleted: $picturesToDelete');

  //   for (var picture in picturesToDelete) {
  //     final String picUrl = picture['picUrl'];
  //     if (picUrl != null && picUrl.startsWith('https://')) {
  //       final Reference storageRef =
  //           FirebaseStorage.instance.refFromURL(picUrl);
  //       await storageRef.delete();

  //       if (picture['docId'] != null) {
  //         await picturesCollectionRef.doc(picture['docId']).delete();
  //         devtools.log(
  //             "Deleted picture with docId ${picture['docId']} from Firestore");
  //       }
  //     }
  //   }

  //   for (var docId in widget.imageCacheProvider.deletedPictureDocIds) {
  //     await picturesCollectionRef.doc(docId).delete();
  //     devtools.log('Deleted picture doc with docId $docId');
  //   }
  // }
  //------------------------------------------------------------------------//
  Future<void> _submitData() async {
    devtools.log('Welcome to _submitData');
    // Capture the ProcedureCacheProvider before any async operation
    final procedureCache =
        Provider.of<ProcedureCacheProvider>(context, listen: false);

    try {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      // Collect all necessary data for submission
      final String? chiefComplaint = widget.userData.chiefComplaint;
      final String? medicalHistory = widget.userData.medicalHistory;

      List<Map<String, dynamic>> oralExaminationData =
          widget.userData.oralExamination.map((examination) {
        return {
          'conditionId': examination['conditionId'],
          'conditionName': examination['conditionName'],
          'affectedTeeth': examination['affectedTeeth'],
          'doctorNote': examination['doctorNote'],
        };
      }).toList();

      List<Map<String, dynamic>> proceduresData =
          widget.userData.procedures.map((procedure) {
        return {
          'procId': procedure['procId'],
          'procName': procedure['procName'],
          'affectedTeeth': procedure['affectedTeeth'],
          'doctorNote': procedure['doctorNote'],
          'isToothwise': procedure['isToothwise'] ?? false,
        };
      }).toList();

      devtools.log('Collected oralExaminationData and proceduresData');

      // Initialize TreatmentService before using it
      final TreatmentService treatmentService = TreatmentService(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
      );

      // Fetch the consultation fee using TreatmentService
      final int? consultationFee =
          await treatmentService.fetchConsultationFee(widget.doctorId);

      if (consultationFee == null) {
        throw 'Consultation fee not available';
      }

      // Prepare treatment cost
      double selectedProceduresFee = 0.0;
      Map<String, dynamic> treatmentCost = {
        'consultationFee': consultationFee,
      };

      for (var procedure in widget.userData.procedures) {
        final procId = procedure['procId'];
        final procedureValue = procedureCostMap[procId];
        final isToothwise = procedure['isToothwise'] ?? false;

        if (procedureValue != null) {
          double procedureFee = procedureValue.toDouble();
          if (isToothwise) {
            final toothCount =
                (procedure['affectedTeeth'] as List<dynamic>?)?.length ?? 0;
            procedureFee *= toothCount;
          }
          selectedProceduresFee += procedureFee;
          treatmentCost[procId] = procedureFee;
        }
      }

      double totalCost = consultationFee.toDouble() + selectedProceduresFee;
      if (isLumpsumDiscountSelected) {
        totalCost -= lumpsumDiscountAmount;
        treatmentCost['discount'] = lumpsumDiscountAmount;
      }
      treatmentCost['totalCost'] = totalCost;
      devtools.log('Total cost calculated: $totalCost');

      // Prepare the treatment data
      final treatmentData = {
        'chiefComplaint': chiefComplaint,
        'medicalHistory': medicalHistory,
        'oralExamination': oralExaminationData,
        'procedures': proceduresData,
        'treatmentCost': treatmentCost,
        'isConsentTaken': isConsentTaken,
        'isTreatmentClose': isTreatmentClose,
        'treatmentCloseDate': isTreatmentClose ? DateTime.now().toUtc() : null,
        'treatmentDate': DateTime.now().toUtc(),
      };

      final treatmentId = await treatmentService.submitTreatment(
        treatmentId: widget.treatmentId,
        treatmentData: treatmentData,
        isEditMode: widget.isEditMode,
      );

      // Handle Images and Prescriptions after submitting treatment data
      await _uploadAndHandleImages(treatmentService, treatmentId);
      await _handlePrescriptions(treatmentService, treatmentId);

      devtools.log(
          'Treatment data submitted successfully with treatmentId: $treatmentId');

      procedureCache.clearProcedures();

      widget.userData.clearState();
      widget.imageCacheProvider.clearPictures();

      if (mounted) {
        await _navigateToCreateEditTreatmentScreen5(context, treatmentId);
      }
    } catch (error) {
      devtools.log('Error submitting treatment data: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Error submitting treatment data. Please try again.')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadAndHandleImages(
      TreatmentService treatmentService, String treatmentId) async {
    devtools.log('Handling images for treatmentId: $treatmentId');

    await treatmentService.uploadAndHandleImages(
      treatmentId: treatmentId,
      pictures: widget.imageCacheProvider.pictures,
      deletedPictureDocIds: widget.imageCacheProvider.deletedPictureDocIds
          .toList(), // Convert Set to List here
    );

    devtools.log('Images processed successfully for treatmentId: $treatmentId');
  }

  Future<void> _handlePrescriptions(
      TreatmentService treatmentService, String treatmentId) async {
    devtools.log('Handling prescriptions for treatmentId: $treatmentId');

    await treatmentService.handlePrescriptions(
      treatmentId: treatmentId,
      prescriptions: widget
          .userData.prescriptions, // Passing prescriptions from the userData
    );

    devtools.log(
        'Prescriptions processed successfully for treatmentId: $treatmentId');
  }

  //-----------------------------------------------------------------------//

  // Future<int?> fetchConsultationFee() async {
  //   devtools.log('Welcome to fetchConsultationFee');
  //   String doctorId = widget.doctorId;
  //   try {
  //     final clinicId = widget.clinicId;

  //     final querySnapshot = await FirebaseFirestore.instance
  //         .collection('clinics')
  //         .doc(clinicId)
  //         .collection('consultations')
  //         .where('doctorId', isEqualTo: doctorId)
  //         .get();

  //     if (querySnapshot.docs.isNotEmpty) {
  //       final data = querySnapshot.docs.first.data();
  //       final consultationFee = data['consultationFee'] as double?;
  //       devtools.log('Consultation Fee fetched: $consultationFee');
  //       return consultationFee?.toInt();
  //     }

  //     devtools.log('No consultation found for doctorId: $doctorId');
  //     return null;
  //   } catch (error) {
  //     devtools.log('Error fetching Consultation Fee: $error');
  //     return null;
  //   }
  // }
  // //--------------------------------------------------------------------------//
  // Future<void> fetchConsultationFee(TreatmentService treatmentService) async {
  //   devtools.log('Fetching consultation fee in CreateEditTreatmentScreen4');

  //   final consultationFee =
  //       await treatmentService.fetchConsultationFee(widget.doctorId);

  //   if (consultationFee != null) {
  //     setState(() {
  //       this.consultationFee = consultationFee.toDouble();
  //       devtools.log('Consultation fee set to $consultationFee');
  //     });
  //   } else {
  //     devtools
  //         .log('Consultation fee not found for doctorId: ${widget.doctorId}');
  //   }
  // }

  //--------------------------------------------------------------------------//

  void extractProcedureName(Map<String, dynamic> procedure) {
    if (procedure['procName'] != null) {
      selectedProcedureNames.add(procedure['procName'] as String);
      final procedureObject = allProcedures.firstWhere(
          (proc) => proc.procName == procedure['procName'],
          orElse: () => Procedure(
              procId: '',
              procName: '',
              procFee: 0.0,
              toothTable1: [],
              toothTable2: [],
              toothTable3: [],
              toothTable4: [],
              doctorNote: '',
              isToothwise: false));
      procedureCostMap[procedure['procId']] = procedureObject.procFee;
    } else {
      devtools.log('Procedure Id is null, skipping this procedure.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _navigateToCreateEditTreatmentScreen5(
      BuildContext context, String treatmentId) async {
    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreateEditTreatmentScreen5(
            doctorId: widget.doctorId,
            clinicId: widget.clinicId,
            patientId: widget.patientId,
            age: widget.age,
            gender: widget.gender,
            patientName: widget.patientName,
            patientMobileNumber: widget.patientMobileNumber,
            patientPicUrl: widget.patientPicUrl,
            pageController: widget.pageController,
            treatmentId: treatmentId,
            doctorName: widget.doctorName,
            uhid: widget.uhid,
            pictureData11: widget.pictureData11,
          ),
          settings: const RouteSettings(name: 'CreateEditTreatmentScreen5'),
        ),
      );
    }
  }

  Future<void> handleAdjustments() async {
    devtools.log(
        '!!!!!!!!!!! Welcome inside handleAdjustments. widget.originalProcedures are ${widget.originalProcedures}!!!!!!!!!');
    devtools.log(
        '!!!!!!!!!!! Welcome inside handleAdjustments. widget.currentProcedures are ${widget.currentProcedures}!!!!!!!!!!!!');

    if (widget.isEditMode) {
      if (originalDiscount != lumpsumDiscountAmount) {
        double discountDifference = originalDiscount - lumpsumDiscountAmount;
        String adjustmentDetails =
            discountDifference > 0 ? 'Discount reduced' : 'Discount granted';
        await _addAdjustmentToPayments(discountDifference, adjustmentDetails);
      }

      List<Map<String, dynamic>> removedProcedures =
          widget.userData.deletedProcedures;
      devtools.log(
          '!!!!!!!!!!!!! This is coming from inside handleAdjustments. removedProcedures are $removedProcedures !!!!!!!!!!');

      List<Map<String, dynamic>> addedOrUpdatedProcedures =
          widget.userData.procedures.where((procedure) {
        var originalProcedureId = procedure['procId'];
        var originalProcedure = widget.originalProcedures!.firstWhere(
            (procId) => procId == originalProcedureId,
            orElse: () => '');
        return originalProcedure == '' ||
            !compareProcedures(originalProcedure, procedure);
      }).toList();

      devtools.log(
          'This is coming from inside handleAdjustments. Removed Procedures: $removedProcedures !!!!!!!!!!!');
      devtools.log(
          'This is coming from inside handleAdjustments. Added or Updated Procedures: $addedOrUpdatedProcedures!!!!!!!!!!');

      for (var procedure in removedProcedures) {
        final String procId = procedure['procId'] as String;
        double removedProcedureCost = procedureCostMap[procId] ?? 0.0;

        if (procedure['isToothwise'] == true) {
          int affectedTeethCount = (procedure['affectedTeeth'] as List).length;
          removedProcedureCost *= affectedTeethCount;
        }

        await _addAdjustmentToPayments(
            -removedProcedureCost, '${procedure['procName']} removed');
        devtools.log(
            '!!!!!!!!!!!!! _addAdjustmentToPayments invoked with removed procedure ${procedure['procName']} !!!!!!!!!');
      }

      for (var procedure in addedOrUpdatedProcedures) {
        final String procId = procedure['procId'] as String;
        double addedProcedureCost = procedureCostMap[procId] ?? 0.0;
        devtools.log(
            '!!!!!!!!!!!! Base cost for ${procedure['procName']} (procId: $procId) is $addedProcedureCost !!!!!!!!!');

        if (procedure['isToothwise'] == true) {
          int affectedTeethCount = (procedure['affectedTeeth'] as List).length;
          addedProcedureCost *= affectedTeethCount;
          devtools.log(
              '!!!!!!!! Affected teeth count: $affectedTeethCount, Total cost after multiplication: $addedProcedureCost !!!!!!!!');
        }

        await _addAdjustmentToPayments(
            addedProcedureCost, '${procedure['procName']} added ');
        devtools.log(
            '!!!!!!!!!!!! _addAdjustmentToPayments invoked with added or updated procedure ${procedure['procName']} !!!!!!!!!!!!');
      }
    }
  }

  bool compareProcedures(
      String originalProcedureId, Map<String, dynamic> currentProcedure) {
    var originalProcedureData = widget.userData.procedures.firstWhere(
        (proc) => proc['procId'] == originalProcedureId,
        orElse: () => <String, dynamic>{});

    if (originalProcedureData.isEmpty) {
      return false;
    }

    bool wasDeleted = widget.userData.deletedProcedures.any(
        (deletedProcedure) =>
            deletedProcedure['procId'] == originalProcedureId);

    if (wasDeleted) {
      devtools.log(
          '!!!!!!!! Procedure was previously deleted, treating as new !!!!!!!');
      return false;
    }

    bool isSame = originalProcedureData['affectedTeeth'] ==
            currentProcedure['affectedTeeth'] &&
        originalProcedureData['doctorNote'] == currentProcedure['doctorNote'];

    devtools.log(
        '!!!!!!!!! Comparing procedures: Original = $originalProcedureData, Current = $currentProcedure, Is Same = $isSame !!!!!!');

    return isSame;
  }

  // Future<void> _addAdjustmentToPayments(
  //     double adjustmentAmount, String adjustmentDetails) async {
  //   devtools.log(
  //       '!!!!!!!!!! Welcome inside _addAdjustmentToPayments which is invoked with $adjustmentDetails.!!!!!!!!!!!!!!!!!!!!!');

  //   try {
  //     final paymentsCollectionRef = FirebaseFirestore.instance
  //         .collection('clinics')
  //         .doc(widget.clinicId)
  //         .collection('patients')
  //         .doc(widget.patientId)
  //         .collection('treatments')
  //         .doc(widget.treatmentId)
  //         .collection('payments');

  //     final QuerySnapshot paymentDocs =
  //         await paymentsCollectionRef.orderBy('date', descending: false).get();

  //     double lastClosingBalance;

  //     if (paymentDocs.docs.isNotEmpty) {
  //       final mostRecentPayment =
  //           paymentDocs.docs.last.data() as Map<String, dynamic>;
  //       lastClosingBalance = mostRecentPayment['closingBalance'] as double;
  //     } else {
  //       lastClosingBalance =
  //           _loadedTreatmentData!['treatmentCost']['totalCost'] as double;
  //     }

  //     double newClosingBalance = lastClosingBalance + adjustmentAmount;

  //     Payment adjustmentPayment = Payment(
  //       paymentId: '',
  //       date: DateTime.now(),
  //       openingBalance: lastClosingBalance,
  //       paymentReceived: 0.0,
  //       adjustments: adjustmentAmount,
  //       adjustmentDetails: adjustmentDetails,
  //       closingBalance: newClosingBalance,
  //     );

  //     Map<String, dynamic> adjustmentPaymentMap = adjustmentPayment.toMap();

  //     final paymentDocRef =
  //         await paymentsCollectionRef.add(adjustmentPaymentMap);
  //     await paymentDocRef.update({'paymentId': paymentDocRef.id});

  //     await fetchAndRenderPayments(); // Ensure this updates your UI or state
  //   } catch (error) {
  //     devtools.log(
  //         '!!!!!!!!!!! This is coming from inside _addAdjustmentToPayments defined inside CreateEditTreatmentScreen4. Error adding adjustment to payments: $error !!!!!!!!!!!');
  //   }
  // }
  //------------------------------------------------------------------------//
  Future<void> _addAdjustmentToPayments(
      double adjustmentAmount, String adjustmentDetails) async {
    devtools.log('Adding adjustment to payments');
    try {
      await _treatmentService.addAdjustmentToPayments(
        treatmentId: widget.treatmentId!,
        adjustmentAmount: adjustmentAmount,
        adjustmentDetails: adjustmentDetails,
        treatmentData: _loadedTreatmentData!,
      );
      // After adding adjustment, fetch updated payments
      await fetchAndRenderPayments();
    } catch (error) {
      devtools.log('Error in adding adjustment: $error');
    }
  }

  //------------------------------------------------------------------------//

  // Future<void> fetchAndRenderPayments() async {
  //   devtools.log('!!!!!!!! Welcome to fetchAndRenderPayments!!!!!!!!!');
  //   final paymentsCollectionRef = FirebaseFirestore.instance
  //       .collection('clinics')
  //       .doc(widget.clinicId)
  //       .collection('patients')
  //       .doc(widget.patientId)
  //       .collection('treatments')
  //       .doc(widget.treatmentId)
  //       .collection('payments');

  //   try {
  //     final QuerySnapshot paymentDocs =
  //         await paymentsCollectionRef.orderBy('date', descending: false).get();

  //     List<Map<String, dynamic>> paymentList = [];
  //     double lastClosingBalance = 0.0;

  //     for (QueryDocumentSnapshot doc in paymentDocs.docs) {
  //       Map<String, dynamic> paymentData = doc.data() as Map<String, dynamic>;

  //       num paymentReceived = paymentData['paymentReceived'] as num;
  //       DateTime date = paymentData['date'].toDate();

  //       if (paymentData.containsKey('closingBalance')) {
  //         lastClosingBalance = paymentData['closingBalance'] as double;
  //       }

  //       String formattedDate = DateFormat('MMM d, EEE').format(date);

  //       paymentList.add({
  //         'paymentReceived': paymentReceived.toStringAsFixed(0),
  //         'date': formattedDate,
  //       });
  //     }

  //     setState(() {
  //       this.paymentList = paymentList;
  //       closingBalance = lastClosingBalance;
  //     });
  //   } catch (e) {
  //     devtools.log('!!!!!!!!!Error fetching payments: $e !!!!!!!!!');
  //   }
  // }
  //---------------------------------------------------------------------//
  Future<void> fetchAndRenderPayments() async {
    devtools.log('Fetching and rendering payments');
    try {
      List<Map<String, dynamic>> paymentList =
          await _treatmentService.fetchPayments(widget.treatmentId!);

      setState(() {
        this.paymentList = paymentList;
        closingBalance = paymentList.isNotEmpty
            ? double.parse(paymentList.last['paymentReceived'])
            : 0.0;
      });
    } catch (e) {
      devtools.log('Error in fetching payments: $e');
    }
  }

  //---------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    devtools.log(
        'Welcome to build widget of CreateEditTreatmentScreen4. userData is ${widget.userData}');
    devtools.log(
        'This is coming from inside build widget of CreateEditTreatmentScreen4. currentProcedures are ${widget.currentProcedures} and originalProcedures are ${widget.originalProcedures}');

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: MyColors.colorPalette['surface-container-lowest'],
            title: Text(
              widget.isEditMode ? 'Treatment' : 'Treatment',
              style: MyTextStyle.textStyleMap['title-large']?.copyWith(
                color: MyColors.colorPalette['on-surface'],
              ),
            ),
            iconTheme: IconThemeData(
              color: MyColors.colorPalette['on-surface'],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 16.0, top: 24, bottom: 24),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: MyColors.colorPalette['outline'] ??
                            Colors.blueAccent,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: MyColors.colorPalette['surface'],
                              backgroundImage: widget.patientPicUrl != null &&
                                      widget.patientPicUrl!.isNotEmpty
                                  ? NetworkImage(widget.patientPicUrl!)
                                  : Image.asset(
                                      'assets/images/default-image.png',
                                      color: MyColors.colorPalette['primary'],
                                      colorBlendMode: BlendMode.color,
                                    ).image,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.patientName,
                                    style: MyTextStyle
                                        .textStyleMap['label-medium']
                                        ?.copyWith(
                                      color:
                                          MyColors.colorPalette['on-surface'],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        widget.age.toString(),
                                        style: MyTextStyle
                                            .textStyleMap['label-small']
                                            ?.copyWith(
                                          color: MyColors.colorPalette[
                                              'on-surface-variant'],
                                        ),
                                      ),
                                      Text(
                                        '/',
                                        style: MyTextStyle
                                            .textStyleMap['label-small']
                                            ?.copyWith(
                                          color: MyColors.colorPalette[
                                              'on-surface-variant'],
                                        ),
                                      ),
                                      Text(
                                        widget.gender,
                                        style: MyTextStyle
                                            .textStyleMap['label-small']
                                            ?.copyWith(
                                          color: MyColors.colorPalette[
                                              'on-surface-variant'],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    widget.patientMobileNumber,
                                    style: MyTextStyle
                                        .textStyleMap['label-small']
                                        ?.copyWith(
                                      color: MyColors
                                          .colorPalette['on-surface-variant'],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Treatment Cost',
                      style: MyTextStyle.textStyleMap['title-large']?.copyWith(
                        color: MyColors.colorPalette['on-surface'],
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                                color: MyColors.colorPalette['outline'] ??
                                    Colors.grey,
                                width: 1.0),
                            bottom: BorderSide.none,
                            left: BorderSide.none,
                            right: BorderSide.none,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Consultation',
                                    style: MyTextStyle
                                        .textStyleMap['title-medium']
                                        ?.copyWith(
                                      color: MyColors.colorPalette['secondary'],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${consultationFee.toInt()}',
                                    style: MyTextStyle
                                        .textStyleMap['title-medium']
                                        ?.copyWith(
                                      color: MyColors.colorPalette['secondary'],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            for (var procedure in widget.currentProcedures)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${procedure['procName']} ${procedure['isToothwise'] == true ? "(x${procedure['affectedTeeth'].length})" : ""}',
                                      style: MyTextStyle
                                          .textStyleMap['title-medium']
                                          ?.copyWith(
                                        color:
                                            MyColors.colorPalette['secondary'],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${procedure['isToothwise'] == true ? ((procedureCostMap[procedure['procId']] ?? 0.0) * procedure['affectedTeeth'].length).toInt() : (procedureCostMap[procedure['procId']] ?? 0.0).toInt()}',
                                      style: MyTextStyle
                                          .textStyleMap['title-medium']
                                          ?.copyWith(
                                        color:
                                            MyColors.colorPalette['secondary'],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: MyColors.colorPalette['outline-variant'],
                          border: Border(
                            bottom: BorderSide(
                                color: MyColors.colorPalette['outline'] ??
                                    Colors.grey,
                                width: 1.0),
                            top: BorderSide.none,
                            left: BorderSide.none,
                            right: BorderSide.none,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isLumpsumDiscountSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isLumpsumDiscountSelected =
                                          value ?? false;
                                      if (!isLumpsumDiscountSelected) {
                                        lumpsumDiscountAmount = 0;
                                        _discountController.clear();
                                      }
                                      costResult = computeTotalCost();
                                    });
                                  },
                                  activeColor: MyColors.colorPalette['primary'],
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                Text(
                                  'Discount',
                                  style: MyTextStyle
                                      .textStyleMap['title-medium']
                                      ?.copyWith(
                                    color: MyColors.colorPalette['secondary'],
                                  ),
                                ),
                              ],
                            ),
                            if (isLumpsumDiscountSelected)
                              SizedBox(
                                width: 120,
                                height: 40,
                                child: TextFormField(
                                  controller: _discountController,
                                  focusNode: _discountFocusNode,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.right,
                                  style: MyTextStyle
                                      .textStyleMap['title-medium']
                                      ?.copyWith(
                                    color: MyColors.colorPalette['error'],
                                  ),
                                  inputFormatters: [DiscountInputFormatter()],
                                  onChanged: (value) {
                                    final enteredDiscount = double.tryParse(
                                            value.replaceAll('-', '')) ??
                                        0.0;
                                    // ---------------------------------------- //
                                    if (_discountController.text
                                        .startsWith('-')) {
                                      _discountController.text =
                                          '-${enteredDiscount.toStringAsFixed(0)}';
                                    } else {
                                      _discountController.text =
                                          enteredDiscount.toStringAsFixed(0);
                                    }
                                    //--------------------------------------- //

                                    if (enteredDiscount >
                                        costResult.totalCostBeforeDiscount
                                            .toInt()) {
                                      devtools.log(
                                          'enteredDiscount is $enteredDiscount');
                                      devtools.log(
                                          'costResult.totalCostBeforeDiscount.toInt() is ${costResult.totalCostBeforeDiscount.toInt()}');
                                      _showSnackBar(
                                          'Discount cannot be more than total cost');
                                      _discountController.text =
                                          lumpsumDiscountAmount.toString();
                                    } else {
                                      setState(() {
                                        lumpsumDiscountAmount = enteredDiscount;
                                        costResult = computeTotalCost();
                                      });
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 8.0),
                                    border: InputBorder.none,
                                    hintText: 'Enter amount',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                      child: Divider(),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 8.0),
                      child: Text(
                        'Total Cost',
                        style:
                            MyTextStyle.textStyleMap['title-large']?.copyWith(
                          color: MyColors.colorPalette['on-surface'],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        '₹ ${costResult.totalCost.toInt()}',
                        style:
                            MyTextStyle.textStyleMap['title-large']?.copyWith(
                          color: MyColors.colorPalette['primary'],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: MyBottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.circle),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.circle),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.circle),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.circle),
                label: '',
              ),
            ],
            currentIndex: 3,
            nextIconSelectable: nextIconSelectable,
            onTap: (int navIndex) async {
              if (navIndex == 0) {
                Navigator.of(context).pop();
              } else if (navIndex == 3 && !_isSubmitting) {
                setState(() {
                  _isSubmitting = true;
                  _isLoading = true;
                });
                await handleAdjustments();
                await _submitData();
                if (mounted) {
                  await _navigateToCreateEditTreatmentScreen5(
                      context, widget.treatmentId!);
                }
                setState(() {
                  _isSubmitting = false;
                  _isLoading = false;
                });
              }
            },
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}

class CostResult {
  final double totalCost;
  final double discount;
  final double consultationFee;
  final double totalCostBeforeDiscount;

  CostResult(
    this.totalCost,
    this.discount,
    this.consultationFee,
    this.totalCostBeforeDiscount,
  );
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW IS STABLE WITH DIRECE BACKEND CALLS
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/payment_service.dart';
// import 'package:neocare_dental_app/firestore/procedure_service.dart';
// import 'package:neocare_dental_app/firestore/treatment_service.dart';
// import 'package:neocare_dental_app/mywidgets/discount_input_formatter.dart';
// import 'package:neocare_dental_app/mywidgets/image_cache_provider.dart';
// import 'package:neocare_dental_app/mywidgets/procedure.dart';
// import 'package:neocare_dental_app/mywidgets/procedure_cache_provider.dart';
// import 'package:neocare_dental_app/mywidgets/read_only_payment_tab.dart';
// import 'package:neocare_dental_app/mywidgets/create_edit_treatment_screen_5.dart';
// import 'package:neocare_dental_app/mywidgets/user_data_provider.dart';
// import 'package:neocare_dental_app/mywidgets/my_bottom_navigation_bar.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'dart:developer' as devtools show log;

// class CreateEditTreatmentScreen4 extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String patientId;
//   final int age;
//   final String gender;
//   final String patientName;
//   final String patientMobileNumber;
//   final String? patientPicUrl;
//   final PageController pageController;
//   final UserDataProvider userData;
//   final String doctorName;
//   final String? uhid;
//   final Map<String, dynamic>? treatmentData;
//   final String? treatmentId;
//   final bool isEditMode;
//   final List<String>? originalProcedures;
//   final List<Map<String, dynamic>> currentProcedures;
//   final List<Map<String, dynamic>> pictureData11;
//   final ImageCacheProvider imageCacheProvider;
//   final String? chiefComplaint;

//   const CreateEditTreatmentScreen4({
//     super.key,
//     required this.patientId,
//     required this.age,
//     required this.gender,
//     required this.patientName,
//     required this.patientMobileNumber,
//     required this.patientPicUrl,
//     required this.pageController,
//     required this.clinicId,
//     required this.doctorId,
//     required this.userData,
//     required this.doctorName,
//     required this.uhid,
//     this.treatmentData,
//     this.treatmentId,
//     this.isEditMode = false,
//     required this.originalProcedures,
//     required this.currentProcedures,
//     required this.pictureData11,
//     required this.imageCacheProvider,
//     required this.chiefComplaint,
//   });

//   @override
//   State<CreateEditTreatmentScreen4> createState() =>
//       _CreateEditTreatmentScreen3State();
// }

// class _CreateEditTreatmentScreen3State
//     extends State<CreateEditTreatmentScreen4> {
//   Set<String> selectedProcedureNames = {};
//   Map<String, double> procedureCostMap = {};
//   bool isLumpsumDiscountSelected = false;
//   bool isConsentTaken = false;
//   bool isTreatmentClose = false;

//   double consultationFee = 0.0;
//   CostResult costResult = CostResult(0.0, 0.0, 0.0, 0.0);

//   bool nextIconSelectable = false;
//   double lumpsumDiscountAmount = 0;
//   bool _isSubmitting = false;
//   double originalDiscount = 0;
//   Map<String, dynamic>? _loadedTreatmentData;

//   final TextEditingController _discountController = TextEditingController();
//   final TextEditingController _chiefComplaintController =
//       TextEditingController();
//   final FocusNode _discountFocusNode = FocusNode();

//   List<Map<String, dynamic>> paymentList = [];
//   double closingBalance = 0.0;
//   bool _isLoading = false;
//   List<Procedure> allProcedures = [];

//   @override
//   void initState() {
//     super.initState();
//     devtools
//         .log('widget.userData.procedures are : ${widget.userData.procedures}');
//     widget.userData.procedures.forEach(extractProcedureName);
//     devtools.log('Selected procedures: $selectedProcedureNames');

//     if (widget.isEditMode &&
//         widget.treatmentData != null &&
//         widget.treatmentData!.containsKey('treatmentCost')) {
//       final treatmentCost = widget.treatmentData!['treatmentCost'];
//       if (treatmentCost.containsKey('discount')) {
//         lumpsumDiscountAmount = (treatmentCost['discount'] as num).toDouble();

//         // Always prefix the minus sign since discount is inherently a deduction
//         _discountController.text =
//             '-${lumpsumDiscountAmount.toStringAsFixed(0)}';

//         originalDiscount = lumpsumDiscountAmount; // Store original discount
//         isLumpsumDiscountSelected = true; // Mark that discount is selected
//       }
//     }

//     _loadedTreatmentData = widget.treatmentData;

//     fetchConsultationFee().then((consultationFee) {
//       devtools.log('consultationFee fetched is $consultationFee');
//       if (consultationFee != null) {
//         setState(() {
//           this.consultationFee = consultationFee.toDouble();
//           fetchProcedureCosts().then((_) {
//             costResult = computeTotalCost();
//           });
//         });
//       }
//     });

//     _discountFocusNode.addListener(() {
//       if (!_discountFocusNode.hasFocus) {
//         final enteredDiscount =
//             double.tryParse(_discountController.text.replaceAll('-', '')) ?? 0;
//         if (enteredDiscount > costResult.totalCost.toInt()) {
//           _showSnackBar('Discount cannot be more than total cost');
//           _discountController.text = lumpsumDiscountAmount.toString();
//         } else {
//           setState(() {
//             lumpsumDiscountAmount = enteredDiscount;
//             costResult = computeTotalCost();
//           });
//         }
//       }
//     });

//     fetchAndRenderPayments(); // Fetch and render payments when the screen is initialized
//   }

//   @override
//   void dispose() {
//     _discountController.dispose();
//     _discountFocusNode.dispose();
//     _chiefComplaintController.dispose();
//     super.dispose();
//   }

//   // ------------------------------------------------------------------------ //

//   Future<void> fetchProcedureCosts() async {
//     ProcedureService procedureService = ProcedureService(widget.clinicId);
//     allProcedures = await procedureService.searchProcedures('');
//     procedureCostMap = {
//       for (var procedure in allProcedures) procedure.procId: procedure.procFee
//     };

//     devtools.log(
//         'Procedure cost map: $procedureCostMap'); // Log the cost map to ensure it's correct

//     setState(() {
//       costResult = computeTotalCost(); // Ensure cost is computed after fetching
//     });
//   }
//   // ------------------------------------------------------------------------ //

//   CostResult computeTotalCost() {
//     double totalCost = consultationFee;
//     double discount = 0.0;

//     for (var procedure in widget.userData.procedures) {
//       devtools.log(
//           'Processing procedure: ${procedure['procName']} with data: $procedure');
//       final isToothwise = procedure['isToothwise'] ?? false;
//       devtools.log(
//           'Retrieved isToothwise of: ${procedure['procName']} is: $isToothwise');

//       double procedureCost = 0.0;

//       if (isToothwise) {
//         final affectedTeethCount = procedure['affectedTeeth']?.length ?? 0;
//         procedureCost =
//             affectedTeethCount * (procedureCostMap[procedure['procId']] ?? 0.0);
//       } else {
//         procedureCost = procedureCostMap[procedure['procId']] ?? 0.0;
//       }

//       devtools
//           .log('Procedure Cost for ${procedure['procName']}: $procedureCost');
//       totalCost += procedureCost;
//     }

//     final totalCostBeforeDiscount = totalCost;

//     if (isLumpsumDiscountSelected) {
//       discount = lumpsumDiscountAmount;
//       totalCost -= discount;
//     }

//     totalCost = totalCost.roundToDouble();
//     discount = discount.roundToDouble();

//     devtools.log(
//         'Total Cost: $totalCost, Discount: $discount'); // Log final amounts
//     return CostResult(
//       totalCost,
//       discount,
//       consultationFee,
//       totalCostBeforeDiscount,
//     );
//   }

//   Future<void> _submitData() async {
//     devtools.log('Welcome to _submitData');
//     try {
//       setState(() {
//         _isLoading = true; // Show loading indicator
//       });

//       final clinicId = widget.clinicId;
//       final patientId = widget.patientId;

//       String? chiefComplaint = widget.userData.chiefComplaint;
//       String? medicalHistory =
//           widget.userData.medicalHistory; // Include medical history
//       devtools.log(
//           'This is coming from inside _submitData. chiefComplaint: $chiefComplaint, medicalHistory: $medicalHistory');

//       List<Map<String, dynamic>> oralExaminationData =
//           widget.userData.oralExamination.map((examination) {
//         return {
//           'conditionId': examination['conditionId'],
//           'conditionName': examination['conditionName'],
//           'affectedTeeth': examination['affectedTeeth'],
//           'doctorNote': examination['doctorNote'],
//         };
//       }).toList();
//       devtools.log(
//           'This is coming from inside _submitData. oralExaminationData: $oralExaminationData');

//       List<Map<String, dynamic>> proceduresData =
//           widget.userData.procedures.map((procedure) {
//         return {
//           'procId': procedure['procId'],
//           'procName': procedure['procName'],
//           'affectedTeeth': procedure['affectedTeeth'],
//           'doctorNote': procedure['doctorNote'],
//           'isToothwise': procedure['isToothwise'] ?? false,
//         };
//       }).toList();

//       devtools.log(
//           'This is coming from inside _submitData. proceduresData: $proceduresData');

//       final consultationFee = await fetchConsultationFee();
//       if (consultationFee == null) {
//         devtools.log('Consultation fee not available');
//         throw 'Consultation fee not available';
//       }
//       devtools.log('consultationFee: $consultationFee');

//       double selectedProceduresFee = 0.0;
//       Map<String, dynamic> treatmentCost = {
//         'consultationFee': consultationFee,
//       };

//       for (var procedure in widget.userData.procedures) {
//         final procId = procedure['procId'];
//         final procedureValue = procedureCostMap[procId];
//         final isToothwise = procedure['isToothwise'] ?? false;

//         if (procedureValue != null) {
//           double procedureFee = procedureValue.toDouble();

//           if (isToothwise) {
//             final toothCount =
//                 (procedure['affectedTeeth'] as List<dynamic>?)?.length ?? 0;
//             procedureFee *= toothCount;
//           }

//           selectedProceduresFee += procedureFee;
//           treatmentCost[procId] = procedureFee;
//         } else {
//           devtools.log('Procedure value for $procId is null');
//         }
//       }

//       devtools.log('treatmentCost: $treatmentCost');

//       double totalCost = consultationFee.toDouble() + selectedProceduresFee;
//       if (isLumpsumDiscountSelected) {
//         totalCost -= lumpsumDiscountAmount;
//         treatmentCost['discount'] = lumpsumDiscountAmount;
//       }
//       treatmentCost['totalCost'] = totalCost;
//       devtools.log('totalCost: $totalCost');

//       final treatmentCloseDate =
//           isTreatmentClose ? DateTime.now().toUtc() : null;

//       final treatmentData = {
//         'chiefComplaint': chiefComplaint,
//         'medicalHistory':
//             medicalHistory, // Add medical history to the treatment data
//         'oralExamination': oralExaminationData,
//         'procedures': proceduresData,
//         'treatmentCost': treatmentCost,
//         'isConsentTaken': isConsentTaken,
//         'isTreatmentClose': isTreatmentClose,
//         'treatmentCloseDate': treatmentCloseDate,
//         'treatmentDate': DateTime.now().toUtc(),
//       };
//       devtools.log('treatmentData: $treatmentData');

//       final treatmentsRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId)
//           .collection('treatments');

//       String treatmentId;
//       if (widget.isEditMode) {
//         treatmentId = widget.treatmentId!;
//         await treatmentsRef.doc(treatmentId).update(treatmentData);
//       } else {
//         final treatmentDocRef = await treatmentsRef.add(treatmentData);
//         treatmentId = treatmentDocRef.id;
//         await treatmentDocRef.update({'treatmentId': treatmentId});
//       }
//       devtools.log('treatmentId: $treatmentId');

//       // Handle Images
//       await _uploadAndHandleImages(treatmentsRef, treatmentId, patientId);
//       //--------------//
//       // Handle Prescriptions
//       // Handle Prescriptions as a single document
//       if (widget.userData.prescriptions.isNotEmpty) {
//         final prescriptionData = {
//           'treatmentId':
//               treatmentId, // Include treatmentId in the prescription data
//           'medPrescribed': widget.userData
//               .prescriptions, // Push all prescriptions in a single document
//         };

//         final prescriptionCollectionRef = FirebaseFirestore.instance
//             .collection('clinics')
//             .doc(clinicId)
//             .collection('patients')
//             .doc(patientId)
//             .collection('treatments')
//             .doc(treatmentId)
//             .collection('prescriptions');

//         final prescriptionDocRef =
//             await prescriptionCollectionRef.add(prescriptionData);
//         final prescriptionId = prescriptionDocRef.id;

//         await prescriptionDocRef.update({'prescriptionId': prescriptionId});
//         devtools.log('Prescriptions added with ID: $prescriptionId');
//       }
//       //--------------//

//       devtools.log('Treatment data pushed to the backend successfully');
//       if (!mounted) return;

//       context.read<ProcedureCacheProvider>().clearProcedures();
//       widget.imageCacheProvider.clearPictures();
//       widget.userData.clearState();

//       if (mounted) {
//         await _navigateToCreateEditTreatmentScreen5(context, treatmentId);
//       }
//     } catch (error) {
//       devtools.log('Error submitting treatment data: $error');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Error submitting treatment data. Please try again.'),
//           ),
//         );
//         setState(() {
//           _isSubmitting = false;
//         });
//       }
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   //------------------------------------------------------------------------//
//   Future<void> _uploadAndHandleImages(CollectionReference treatmentsRef,
//       String treatmentId, String patientId) async {
//     final picturesCollectionRef =
//         treatmentsRef.doc(treatmentId).collection('pictures');

//     final newPictures = widget.imageCacheProvider.pictures
//         .where((picture) => picture['isExisting'] == false)
//         .toList();
//     final editedPictures = widget.imageCacheProvider.pictures
//         .where((picture) => picture['isEdited'] == true)
//         .toList();

//     devtools.log(
//         'This is coming from inside _submitData. New pictures to be added: $newPictures');
//     devtools.log(
//         'This is coming from inside _submitData. Edited pictures to be updated: $editedPictures');

//     for (var picture in newPictures) {
//       devtools.log(
//           'This is coming from inside for loop meant for pushing new pictures to the backend.');
//       final String localPath = picture['localPath'];
//       final String picId = picture['picId'];
//       final Reference storageRef = FirebaseStorage.instance.ref().child(
//           'patient_treatment_pictures/$patientId/$treatmentId/$picId.jpg');

//       await storageRef.putFile(File(localPath));
//       final String picUrl = await storageRef.getDownloadURL();
//       devtools.log(
//           'New picture pushed to the storage successfully at picUrl $picUrl ');

//       picture['picUrl'] = picUrl;
//       picture['treatmentId'] = treatmentId;
//       picture['isExisting'] = true;

//       await picturesCollectionRef.add(picture);
//       devtools.log('Picture document created successfully !');
//     }

//     for (var picture in editedPictures) {
//       if (picture['docId'] == null || picture['docId'].isEmpty) {
//         continue;
//       }
//       devtools.log('Uploading edited picture: ${picture['localPath']}');
//       final String localPath = picture['localPath'];
//       final String picId = picture['picId'];
//       final String? docId = picture['docId'];
//       final Reference storageRef = FirebaseStorage.instance.ref().child(
//           'patient_treatment_pictures/$patientId/$treatmentId/$picId.jpg');

//       await storageRef.putFile(File(localPath));
//       final String picUrl = await storageRef.getDownloadURL();
//       devtools.log('Uploaded edited picture at URL: $picUrl');

//       picture['picUrl'] = picUrl;
//       picture['treatmentId'] = treatmentId;
//       picture['isExisting'] = true;
//       picture['isEdited'] = false;

//       await picturesCollectionRef.add(picture);

//       devtools
//           .log('Removing old Firestore document for edited picture: $docId');
//       if (docId != null && docId.isNotEmpty) {
//         await picturesCollectionRef.doc(docId).delete();
//         devtools.log('Old picture doc removed successfully.');
//       }
//     }

//     final picturesToDelete = widget.imageCacheProvider.pictures
//         .where((picture) => picture['isMarkedForDeletion'] == true)
//         .toList();
//     devtools.log('Pictures to be deleted: $picturesToDelete');

//     for (var picture in picturesToDelete) {
//       final String picUrl = picture['picUrl'];
//       if (picUrl != null && picUrl.startsWith('https://')) {
//         final Reference storageRef =
//             FirebaseStorage.instance.refFromURL(picUrl);
//         await storageRef.delete();

//         if (picture['docId'] != null) {
//           await picturesCollectionRef.doc(picture['docId']).delete();
//           devtools.log(
//               "Deleted picture with docId ${picture['docId']} from Firestore");
//         }
//       }
//     }

//     for (var docId in widget.imageCacheProvider.deletedPictureDocIds) {
//       await picturesCollectionRef.doc(docId).delete();
//       devtools.log('Deleted picture doc with docId $docId');
//     }
//   }
//   //------------------------------------------------------------------------//

//   //-----------------------------------------------------------------------//

//   Future<int?> fetchConsultationFee() async {
//     devtools.log('Welcome to fetchConsultationFee');
//     String doctorId = widget.doctorId;
//     try {
//       final clinicId = widget.clinicId;

//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('consultations')
//           .where('doctorId', isEqualTo: doctorId)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         final data = querySnapshot.docs.first.data();
//         final consultationFee = data['consultationFee'] as double?;
//         devtools.log('Consultation Fee fetched: $consultationFee');
//         return consultationFee?.toInt();
//       }

//       devtools.log('No consultation found for doctorId: $doctorId');
//       return null;
//     } catch (error) {
//       devtools.log('Error fetching Consultation Fee: $error');
//       return null;
//     }
//   }

//   void extractProcedureName(Map<String, dynamic> procedure) {
//     if (procedure['procName'] != null) {
//       selectedProcedureNames.add(procedure['procName'] as String);
//       final procedureObject = allProcedures.firstWhere(
//           (proc) => proc.procName == procedure['procName'],
//           orElse: () => Procedure(
//               procId: '',
//               procName: '',
//               procFee: 0.0,
//               toothTable1: [],
//               toothTable2: [],
//               toothTable3: [],
//               toothTable4: [],
//               doctorNote: '',
//               isToothwise: false));
//       procedureCostMap[procedure['procId']] = procedureObject.procFee;
//     } else {
//       devtools.log('Procedure Id is null, skipping this procedure.');
//     }
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   Future<void> _navigateToCreateEditTreatmentScreen5(
//       BuildContext context, String treatmentId) async {
//     if (mounted) {
//       await Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => CreateEditTreatmentScreen5(
//             doctorId: widget.doctorId,
//             clinicId: widget.clinicId,
//             patientId: widget.patientId,
//             age: widget.age,
//             gender: widget.gender,
//             patientName: widget.patientName,
//             patientMobileNumber: widget.patientMobileNumber,
//             patientPicUrl: widget.patientPicUrl,
//             pageController: widget.pageController,
//             treatmentId: treatmentId,
//             doctorName: widget.doctorName,
//             uhid: widget.uhid,
//             pictureData11: widget.pictureData11,
//           ),
//         ),
//       );
//     }
//   }

//   Future<void> handleAdjustments() async {
//     devtools.log(
//         '!!!!!!!!!!! Welcome inside handleAdjustments. widget.originalProcedures are ${widget.originalProcedures}!!!!!!!!!');
//     devtools.log(
//         '!!!!!!!!!!! Welcome inside handleAdjustments. widget.currentProcedures are ${widget.currentProcedures}!!!!!!!!!!!!');

//     if (widget.isEditMode) {
//       if (originalDiscount != lumpsumDiscountAmount) {
//         double discountDifference = originalDiscount - lumpsumDiscountAmount;
//         String adjustmentDetails =
//             discountDifference > 0 ? 'Discount reduced' : 'Discount granted';
//         await _addAdjustmentToPayments(discountDifference, adjustmentDetails);
//       }

//       List<Map<String, dynamic>> removedProcedures =
//           widget.userData.deletedProcedures;
//       devtools.log(
//           '!!!!!!!!!!!!! This is coming from inside handleAdjustments. removedProcedures are $removedProcedures !!!!!!!!!!');

//       List<Map<String, dynamic>> addedOrUpdatedProcedures =
//           widget.userData.procedures.where((procedure) {
//         var originalProcedureId = procedure['procId'];
//         var originalProcedure = widget.originalProcedures!.firstWhere(
//             (procId) => procId == originalProcedureId,
//             orElse: () => '');
//         return originalProcedure == '' ||
//             !compareProcedures(originalProcedure, procedure);
//       }).toList();

//       devtools.log(
//           'This is coming from inside handleAdjustments. Removed Procedures: $removedProcedures !!!!!!!!!!!');
//       devtools.log(
//           'This is coming from inside handleAdjustments. Added or Updated Procedures: $addedOrUpdatedProcedures!!!!!!!!!!');

//       for (var procedure in removedProcedures) {
//         final String procId = procedure['procId'] as String;
//         double removedProcedureCost = procedureCostMap[procId] ?? 0.0;

//         if (procedure['isToothwise'] == true) {
//           int affectedTeethCount = (procedure['affectedTeeth'] as List).length;
//           removedProcedureCost *= affectedTeethCount;
//         }

//         await _addAdjustmentToPayments(
//             -removedProcedureCost, '${procedure['procName']} removed');
//         devtools.log(
//             '!!!!!!!!!!!!! _addAdjustmentToPayments invoked with removed procedure ${procedure['procName']} !!!!!!!!!');
//       }

//       for (var procedure in addedOrUpdatedProcedures) {
//         final String procId = procedure['procId'] as String;
//         double addedProcedureCost = procedureCostMap[procId] ?? 0.0;
//         devtools.log(
//             '!!!!!!!!!!!! Base cost for ${procedure['procName']} (procId: $procId) is $addedProcedureCost !!!!!!!!!');

//         if (procedure['isToothwise'] == true) {
//           int affectedTeethCount = (procedure['affectedTeeth'] as List).length;
//           addedProcedureCost *= affectedTeethCount;
//           devtools.log(
//               '!!!!!!!! Affected teeth count: $affectedTeethCount, Total cost after multiplication: $addedProcedureCost !!!!!!!!');
//         }

//         await _addAdjustmentToPayments(
//             addedProcedureCost, '${procedure['procName']} added ');
//         devtools.log(
//             '!!!!!!!!!!!! _addAdjustmentToPayments invoked with added or updated procedure ${procedure['procName']} !!!!!!!!!!!!');
//       }
//     }
//   }

//   bool compareProcedures(
//       String originalProcedureId, Map<String, dynamic> currentProcedure) {
//     var originalProcedureData = widget.userData.procedures.firstWhere(
//         (proc) => proc['procId'] == originalProcedureId,
//         orElse: () => <String, dynamic>{});

//     if (originalProcedureData.isEmpty) {
//       return false;
//     }

//     bool wasDeleted = widget.userData.deletedProcedures.any(
//         (deletedProcedure) =>
//             deletedProcedure['procId'] == originalProcedureId);

//     if (wasDeleted) {
//       devtools.log(
//           '!!!!!!!! Procedure was previously deleted, treating as new !!!!!!!');
//       return false;
//     }

//     bool isSame = originalProcedureData['affectedTeeth'] ==
//             currentProcedure['affectedTeeth'] &&
//         originalProcedureData['doctorNote'] == currentProcedure['doctorNote'];

//     devtools.log(
//         '!!!!!!!!! Comparing procedures: Original = $originalProcedureData, Current = $currentProcedure, Is Same = $isSame !!!!!!');

//     return isSame;
//   }

//   Future<void> _addAdjustmentToPayments(
//       double adjustmentAmount, String adjustmentDetails) async {
//     devtools.log(
//         '!!!!!!!!!! Welcome inside _addAdjustmentToPayments which is invoked with $adjustmentDetails.!!!!!!!!!!!!!!!!!!!!!');

//     try {
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

//       double lastClosingBalance;

//       if (paymentDocs.docs.isNotEmpty) {
//         final mostRecentPayment =
//             paymentDocs.docs.last.data() as Map<String, dynamic>;
//         lastClosingBalance = mostRecentPayment['closingBalance'] as double;
//       } else {
//         lastClosingBalance =
//             _loadedTreatmentData!['treatmentCost']['totalCost'] as double;
//       }

//       double newClosingBalance = lastClosingBalance + adjustmentAmount;

//       Payment adjustmentPayment = Payment(
//         paymentId: '',
//         date: DateTime.now(),
//         openingBalance: lastClosingBalance,
//         paymentReceived: 0.0,
//         adjustments: adjustmentAmount,
//         adjustmentDetails: adjustmentDetails,
//         closingBalance: newClosingBalance,
//       );

//       Map<String, dynamic> adjustmentPaymentMap = adjustmentPayment.toMap();

//       final paymentDocRef =
//           await paymentsCollectionRef.add(adjustmentPaymentMap);
//       await paymentDocRef.update({'paymentId': paymentDocRef.id});

//       await fetchAndRenderPayments(); // Ensure this updates your UI or state
//     } catch (error) {
//       devtools.log(
//           '!!!!!!!!!!! This is coming from inside _addAdjustmentToPayments defined inside CreateEditTreatmentScreen4. Error adding adjustment to payments: $error !!!!!!!!!!!');
//     }
//   }

//   Future<void> fetchAndRenderPayments() async {
//     devtools.log('!!!!!!!! Welcome to fetchAndRenderPayments!!!!!!!!!');
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
//       double lastClosingBalance = 0.0;

//       for (QueryDocumentSnapshot doc in paymentDocs.docs) {
//         Map<String, dynamic> paymentData = doc.data() as Map<String, dynamic>;

//         num paymentReceived = paymentData['paymentReceived'] as num;
//         DateTime date = paymentData['date'].toDate();

//         if (paymentData.containsKey('closingBalance')) {
//           lastClosingBalance = paymentData['closingBalance'] as double;
//         }

//         String formattedDate = DateFormat('MMM d, EEE').format(date);

//         paymentList.add({
//           'paymentReceived': paymentReceived.toStringAsFixed(0),
//           'date': formattedDate,
//         });
//       }

//       setState(() {
//         this.paymentList = paymentList;
//         closingBalance = lastClosingBalance;
//       });
//     } catch (e) {
//       devtools.log('!!!!!!!!!Error fetching payments: $e !!!!!!!!!');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log(
//         'Welcome to build widget of CreateEditTreatmentScreen4. userData is ${widget.userData}');
//     devtools.log(
//         'This is coming from inside build widget of CreateEditTreatmentScreen4. currentProcedures are ${widget.currentProcedures} and originalProcedures are ${widget.originalProcedures}');

//     return Stack(
//       children: [
//         Scaffold(
//           appBar: AppBar(
//             backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//             title: Text(
//               widget.isEditMode ? 'Treatment' : 'Treatment',
//               style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                 color: MyColors.colorPalette['on-surface'],
//               ),
//             ),
//             iconTheme: IconThemeData(
//               color: MyColors.colorPalette['on-surface'],
//             ),
//           ),
//           body: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Container(
//                     padding:
//                         const EdgeInsets.only(left: 16.0, top: 24, bottom: 24),
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         width: 1,
//                         color: MyColors.colorPalette['outline'] ??
//                             Colors.blueAccent,
//                       ),
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     child: Align(
//                       alignment: AlignmentDirectional.topStart,
//                       child: Padding(
//                         padding: const EdgeInsets.all(4),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 28,
//                               backgroundColor: MyColors.colorPalette['surface'],
//                               backgroundImage: widget.patientPicUrl != null &&
//                                       widget.patientPicUrl!.isNotEmpty
//                                   ? NetworkImage(widget.patientPicUrl!)
//                                   : Image.asset(
//                                       'assets/images/default-image.png',
//                                       color: MyColors.colorPalette['primary'],
//                                       colorBlendMode: BlendMode.color,
//                                     ).image,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     widget.patientName,
//                                     style: MyTextStyle
//                                         .textStyleMap['label-medium']
//                                         ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-surface'],
//                                     ),
//                                   ),
//                                   Row(
//                                     children: [
//                                       Text(
//                                         widget.age.toString(),
//                                         style: MyTextStyle
//                                             .textStyleMap['label-small']
//                                             ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant'],
//                                         ),
//                                       ),
//                                       Text(
//                                         '/',
//                                         style: MyTextStyle
//                                             .textStyleMap['label-small']
//                                             ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant'],
//                                         ),
//                                       ),
//                                       Text(
//                                         widget.gender,
//                                         style: MyTextStyle
//                                             .textStyleMap['label-small']
//                                             ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant'],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Text(
//                                     widget.patientMobileNumber,
//                                     style: MyTextStyle
//                                         .textStyleMap['label-small']
//                                         ?.copyWith(
//                                       color: MyColors
//                                           .colorPalette['on-surface-variant'],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 16.0),
//                     child: Text(
//                       'Treatment Cost',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                         color: MyColors.colorPalette['on-surface'],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           border: Border(
//                             top: BorderSide(
//                                 color: MyColors.colorPalette['outline'] ??
//                                     Colors.grey,
//                                 width: 1.0),
//                             bottom: BorderSide.none,
//                             left: BorderSide.none,
//                             right: BorderSide.none,
//                           ),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     'Consultation',
//                                     style: MyTextStyle
//                                         .textStyleMap['title-medium']
//                                         ?.copyWith(
//                                       color: MyColors.colorPalette['secondary'],
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     '${consultationFee.toInt()}',
//                                     style: MyTextStyle
//                                         .textStyleMap['title-medium']
//                                         ?.copyWith(
//                                       color: MyColors.colorPalette['secondary'],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             for (var procedure in widget.currentProcedures)
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       '${procedure['procName']} ${procedure['isToothwise'] == true ? "(x${procedure['affectedTeeth'].length})" : ""}',
//                                       style: MyTextStyle
//                                           .textStyleMap['title-medium']
//                                           ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary'],
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       '${procedure['isToothwise'] == true ? ((procedureCostMap[procedure['procId']] ?? 0.0) * procedure['affectedTeeth'].length).toInt() : (procedureCostMap[procedure['procId']] ?? 0.0).toInt()}',
//                                       style: MyTextStyle
//                                           .textStyleMap['title-medium']
//                                           ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary'],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0, right: 16.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: MyColors.colorPalette['outline-variant'],
//                           border: Border(
//                             bottom: BorderSide(
//                                 color: MyColors.colorPalette['outline'] ??
//                                     Colors.grey,
//                                 width: 1.0),
//                             top: BorderSide.none,
//                             left: BorderSide.none,
//                             right: BorderSide.none,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Checkbox(
//                                   value: isLumpsumDiscountSelected,
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       isLumpsumDiscountSelected =
//                                           value ?? false;
//                                       if (!isLumpsumDiscountSelected) {
//                                         lumpsumDiscountAmount = 0;
//                                         _discountController.clear();
//                                       }
//                                       costResult = computeTotalCost();
//                                     });
//                                   },
//                                   activeColor: MyColors.colorPalette['primary'],
//                                   materialTapTargetSize:
//                                       MaterialTapTargetSize.shrinkWrap,
//                                   visualDensity: VisualDensity.compact,
//                                 ),
//                                 Text(
//                                   'Discount',
//                                   style: MyTextStyle
//                                       .textStyleMap['title-medium']
//                                       ?.copyWith(
//                                     color: MyColors.colorPalette['secondary'],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             if (isLumpsumDiscountSelected)
//                               SizedBox(
//                                 width: 120,
//                                 height: 40,
//                                 child: TextFormField(
//                                   controller: _discountController,
//                                   focusNode: _discountFocusNode,
//                                   keyboardType: TextInputType.number,
//                                   textAlign: TextAlign.right,
//                                   style: MyTextStyle
//                                       .textStyleMap['title-medium']
//                                       ?.copyWith(
//                                     color: MyColors.colorPalette['error'],
//                                   ),
//                                   inputFormatters: [DiscountInputFormatter()],
//                                   onChanged: (value) {
//                                     final enteredDiscount = double.tryParse(
//                                             value.replaceAll('-', '')) ??
//                                         0.0;
//                                     // ---------------------------------------- //
//                                     if (_discountController.text
//                                         .startsWith('-')) {
//                                       _discountController.text =
//                                           '-${enteredDiscount.toStringAsFixed(0)}';
//                                     } else {
//                                       _discountController.text =
//                                           enteredDiscount.toStringAsFixed(0);
//                                     }
//                                     //--------------------------------------- //

//                                     if (enteredDiscount >
//                                         costResult.totalCostBeforeDiscount
//                                             .toInt()) {
//                                       devtools.log(
//                                           'enteredDiscount is $enteredDiscount');
//                                       devtools.log(
//                                           'costResult.totalCostBeforeDiscount.toInt() is ${costResult.totalCostBeforeDiscount.toInt()}');
//                                       _showSnackBar(
//                                           'Discount cannot be more than total cost');
//                                       _discountController.text =
//                                           lumpsumDiscountAmount.toString();
//                                     } else {
//                                       setState(() {
//                                         lumpsumDiscountAmount = enteredDiscount;
//                                         costResult = computeTotalCost();
//                                       });
//                                     }
//                                   },
//                                   decoration: const InputDecoration(
//                                     contentPadding: EdgeInsets.symmetric(
//                                         horizontal: 8.0, vertical: 8.0),
//                                     border: InputBorder.none,
//                                     hintText: 'Enter amount',
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const Padding(
//                       padding:
//                           EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
//                       child: Divider(),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           left: 16.0, right: 16.0, top: 8.0),
//                       child: Text(
//                         'Total Cost',
//                         style:
//                             MyTextStyle.textStyleMap['title-large']?.copyWith(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 16.0),
//                       child: Text(
//                         '₹ ${costResult.totalCost.toInt()}',
//                         style:
//                             MyTextStyle.textStyleMap['title-large']?.copyWith(
//                           color: MyColors.colorPalette['primary'],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           bottomNavigationBar: MyBottomNavigationBar(
//             items: const <BottomNavigationBarItem>[
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.circle),
//                 label: '',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.circle),
//                 label: '',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.circle),
//                 label: '',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.circle),
//                 label: '',
//               ),
//             ],
//             currentIndex: 3,
//             nextIconSelectable: nextIconSelectable,
//             onTap: (int navIndex) async {
//               if (navIndex == 0) {
//                 Navigator.of(context).pop();
//               } else if (navIndex == 3 && !_isSubmitting) {
//                 setState(() {
//                   _isSubmitting = true;
//                   _isLoading = true;
//                 });
//                 await handleAdjustments();
//                 await _submitData();
//                 if (mounted) {
//                   await _navigateToCreateEditTreatmentScreen5(
//                       context, widget.treatmentId!);
//                 }
//                 setState(() {
//                   _isSubmitting = false;
//                   _isLoading = false;
//                 });
//               }
//             },
//           ),
//         ),
//         if (_isLoading)
//           Positioned.fill(
//             child: Container(
//               color: Colors.black.withOpacity(0.5),
//               child: const Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// class CostResult {
//   final double totalCost;
//   final double discount;
//   final double consultationFee;
//   final double totalCostBeforeDiscount;

//   CostResult(
//     this.totalCost,
//     this.discount,
//     this.consultationFee,
//     this.totalCostBeforeDiscount,
//   );
// }
