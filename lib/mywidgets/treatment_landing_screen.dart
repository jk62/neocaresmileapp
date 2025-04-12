import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/constants/routes.dart';
import 'package:neocaresmileapp/firestore/appointment_service.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import 'package:neocaresmileapp/firestore/payment_service.dart';
import 'package:neocaresmileapp/firestore/treatment_service.dart';
import 'package:neocaresmileapp/home_page.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/closed_treatment_summary_screen.dart';
import 'package:neocaresmileapp/mywidgets/consent_widget.dart';
import 'package:neocaresmileapp/mywidgets/image_cache_provider.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/patient_pictrue_overlay_screen.dart';
import 'package:neocaresmileapp/mywidgets/start_or_edit_treatment.dart';
import 'package:neocaresmileapp/mywidgets/start_treatment.dart';
import 'dart:developer' as devtools show log;
import 'package:neocaresmileapp/mywidgets/treatment_summary_screen.dart';
import 'package:neocaresmileapp/mywidgets/cache.dart';
import 'package:neocaresmileapp/mywidgets/user_data_provider.dart';
import 'package:provider/provider.dart';

class TreatmentLandingScreen extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String patientId;
  final int age;
  final String gender;
  final String patientName;
  final String patientMobileNumber;
  final String? patientPicUrl;
  final String? uhid;
  final String doctorName;

  const TreatmentLandingScreen({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.patientId,
    required this.age,
    required this.gender,
    required this.patientName,
    required this.patientMobileNumber,
    required this.patientPicUrl,
    required this.doctorName,
    required this.uhid,
  });

  @override
  State<TreatmentLandingScreen> createState() => _TreatmentLandingScreenState();
}

class _TreatmentLandingScreenState extends State<TreatmentLandingScreen> {
  DateTime? appointmentDate;
  String? treatmentId;
  DateTime? treatmentDate;
  Map<String, dynamic>? treatmentData;
  double totalCost = 0.0;
  double totalAmountPaid = 0.0;
  bool isTreatmentPlanCreated = false;
  bool isSelectedForDeletion = false;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? snackBarController;

  String? procedureName;
  bool isConsentTaken = false;
  bool isTreatmentClose = false;
  bool isNoPreviousTreatmentPlan = true;
  List<String> procedureNames = [];
  List<Map<String, dynamic>> closedTreatments = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _patientPicUrl;
  late AppointmentService _appointmentService;
  late TreatmentService _treatmentService;
  late PaymentService _paymentService;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _appointmentService = AppointmentService();
    _treatmentService = TreatmentService(
        clinicId: widget.clinicId, patientId: widget.patientId);
    _patientPicUrl = widget.patientPicUrl;
    devtools.log('@@@ Welcome inside initState of TreatmentLandingScreen.');

    // Fetch treatment data
    fetchTreatmentData();
  }

  //-------------------------------------------------------------------------------//

  Future<void> fetchTreatmentData() async {
    try {
      final fetchedData = await _treatmentService.fetchAllTreatmentData();
      devtools.log(
          'Welcome to fetchTreatmentData defined inside TreatmentLandingScreen. fetchedData is $fetchedData');

      if (fetchedData == null) {
        if (mounted) {
          setState(() {
            isNoPreviousTreatmentPlan = true;
            closedTreatments.clear();
            isLoading = false; // Loading complete
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          isNoPreviousTreatmentPlan = !fetchedData['hasClosedTreatments'];
          isTreatmentClose = !fetchedData['hasActiveTreatment'];
          closedTreatments = fetchedData['closedTreatments'] ?? [];

          if (fetchedData['hasActiveTreatment']) {
            final activeTreatmentData = fetchedData['activeTreatmentData'];
            isConsentTaken = activeTreatmentData?['isConsentTaken'] ?? false;
            treatmentId = activeTreatmentData?['treatmentId'];
            treatmentDate = activeTreatmentData?['treatmentDate'];
            procedureNames = List<String>.from(
                activeTreatmentData?['procedures']
                    .map((procedure) => procedure['procName']));
            treatmentData = activeTreatmentData;

            if (treatmentData?.containsKey('treatmentCost') == true) {
              final treatmentCost =
                  treatmentData!['treatmentCost'] as Map<String, dynamic>;
              totalCost = (treatmentCost['totalCost'] ?? 0).toDouble();
            }

            _paymentService = PaymentService(
                clinicId: widget.clinicId,
                patientId: widget.patientId,
                treatmentId: treatmentId!);
            fetchTotalAmountPaid();

            isTreatmentPlanCreated = true; // Plan exists
          }
          isLoading = false; // Loading complete
        });
      }
    } catch (error) {
      devtools.log('Error fetching treatment data: $error');
      if (mounted) {
        setState(() {
          isNoPreviousTreatmentPlan = true;
          closedTreatments.clear();
          isLoading = false; // Loading complete
        });
      }
    }
  }

  //-------------------------------------------------------------------------------//

  Future<void> fetchTotalAmountPaid() async {
    if (treatmentId != null) {
      final totalPaid = await _paymentService.fetchTotalAmountPaid();
      if (mounted) {
        setState(() {
          totalAmountPaid = totalPaid;
        });
      }
    }
  }

  Future<void> fetchAppointmentDate() async {
    final fetchedAppointmentDate =
        await _appointmentService.updateTreatmentIdInAppointmentsAndFetchDate(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      treatmentId: treatmentId,
    );

    devtools.log('Fetched Appointment Date: $fetchedAppointmentDate');
    if (mounted) {
      setState(() {
        appointmentDate = fetchedAppointmentDate;
      });
    }
  }

  Future<void> _navigateToTreatmentSummaryScreen() async {
    devtools.log('Navigating to Treatment Summary Screen');

    final updatedTreatmentData =
        await _treatmentService.fetchAllTreatmentData();

    if (!mounted || updatedTreatmentData == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TreatmentSummaryScreen(
          clinicId: widget.clinicId,
          patientId: widget.patientId,
          appointmentDate: appointmentDate,
          patientPicUrl: widget.patientPicUrl,
          age: widget.age,
          gender: widget.gender,
          patientName: widget.patientName,
          patientMobileNumber: widget.patientMobileNumber,
          uhid: widget.uhid,
          treatmentId: updatedTreatmentData['activeTreatmentData']
              ?['treatmentId'],
          treatmentData: updatedTreatmentData['activeTreatmentData'],
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
        ),
      ),
    );

    if (result == true) {
      await fetchTreatmentData();
    }
  }

  void _navigateToStartTreatment() {
    cache.clear();
    Future.delayed(Duration.zero, () {
      final userData = Provider.of<UserDataProvider>(context, listen: false);
      userData.clearState();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StartOrEditTreatment(
            clinicId: widget.clinicId,
            doctorId: widget.doctorId,
            patientId: widget.patientId,
            age: widget.age,
            gender: widget.gender,
            patientName: widget.patientName,
            patientMobileNumber: widget.patientMobileNumber,
            doctorName: widget.doctorName,
            patientPicUrl: widget.patientPicUrl,
            uhid: widget.uhid,
            originalProcedures: null,
            chiefComplaint: null,
          ),
          settings: const RouteSettings(name: 'StartOrEditTreatment'),
        ),
      );
      // Log the current navigation stack
      logNavigationStack(context);
    });
  }

  void logNavigationStack(BuildContext context) {
    Navigator.of(context).popUntil((route) {
      devtools.log('Route in stack: ${route.settings.name}');
      return true; // Do not pop, just log the stack
    });
  }

  Widget buildNoTreatmentWidget() {
    devtools.log('No Treatment Plan');
    return Column(
      children: [
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.topLeft,
          child: ElevatedButton(
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size(144, 48)),
              backgroundColor: MaterialStateProperty.all(
                  MyColors.colorPalette['on-primary']!),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  side: BorderSide(
                      color: MyColors.colorPalette['primary']!, width: 1.0),
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
            ),
            onPressed: _navigateToStartTreatment,
            child: Text(
              'Start',
              style: MyTextStyle.textStyleMap['label-large']
                  ?.copyWith(color: MyColors.colorPalette['primary']),
            ),
          ),
        ),
        const SizedBox(height: 56),
      ],
    );
  }

  Widget buildTreatmentPlanWidget() {
    devtools.log(
        '@@@@@@@@@ Welcome to buildTreatmentPlanWidget. Building Treatment Plan Widget @@@@@@@@@@');
    bool hasProcedures = treatmentData?['procedures'] != null &&
        (treatmentData!['procedures'] as List).isNotEmpty;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            if ((!hasProcedures || isConsentTaken) && !isSelectedForDeletion) {
              _navigateToTreatmentSummaryScreen();
            } else if (isSelectedForDeletion) {
              setState(() => isSelectedForDeletion = false);
              snackBarController?.close();
            } else if (hasProcedures && !isConsentTaken) {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  barrierColor: Colors.black54,
                  pageBuilder: (BuildContext context, _, __) {
                    return ConsentWidget(
                      clinicId: widget.clinicId,
                      doctorId: widget.doctorId,
                      patientId: widget.patientId,
                      age: widget.age,
                      gender: widget.gender,
                      patientName: widget.patientName,
                      patientMobileNumber: widget.patientMobileNumber,
                      patientPicUrl: widget.patientPicUrl,
                      doctorName: widget.doctorName,
                      uhid: widget.uhid,
                      treatmentId: treatmentId,
                    );
                  },
                  transitionsBuilder:
                      (___, Animation<double> animation, ____, Widget child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            }
          },
          onLongPress: () {
            setState(() => isSelectedForDeletion = true);
            _showDeleteSnackBar();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelectedForDeletion
                  ? Colors.red.withOpacity(0.2)
                  : Colors.transparent,
              border: Border.all(
                width: 1,
                color: MyColors.colorPalette['outline'] ?? Colors.blueAccent,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                if (hasProcedures && !isConsentTaken)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Consent pending!',
                      style: MyTextStyle.textStyleMap['title-small']
                          ?.copyWith(color: MyColors.colorPalette['error']),
                    ),
                  ),
                if (!hasProcedures)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'No procedures selected. Consent not required.',
                      style: MyTextStyle.textStyleMap['title-small']?.copyWith(
                          color: MyColors.colorPalette['on-surface-variant']),
                    ),
                  ),
                Container(
                  color: MyColors.colorPalette['outline-variant'],
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      List<String>.from(treatmentData!['procedures']
                              .map((procedure) => procedure['procName']))
                          .join(', '),
                      style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
                          color: MyColors.colorPalette['on-surface-variant']),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Next Appointment: ',
                          style: MyTextStyle.textStyleMap['label-medium']
                              ?.copyWith(
                            color: MyColors.colorPalette['on-surface-variant'],
                          ),
                        ),
                        TextSpan(
                          text: appointmentDate != null
                              ? DateFormat('E, d MMM, hh:mm a')
                                  .format(appointmentDate!)
                              : 'N/A',
                          style: MyTextStyle.textStyleMap['label-medium']
                              ?.copyWith(
                            color: MyColors.colorPalette['primary'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Amount Paid/Treatment Cost: ',
                          style: MyTextStyle.textStyleMap['label-medium']
                              ?.copyWith(
                            color: MyColors.colorPalette['on-surface-variant'],
                          ),
                        ),
                        TextSpan(
                          text:
                              '${totalAmountPaid.toStringAsFixed(0)} / ${totalCost.toStringAsFixed(0)}',
                          style: MyTextStyle.textStyleMap['label-medium']
                              ?.copyWith(
                            color: MyColors.colorPalette['primary'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteSnackBar() {
    if (snackBarController != null) {
      snackBarController!.close();
      snackBarController = null;
    }
    snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Delete this treatment?'),
        duration: const Duration(days: 1),
        action: SnackBarAction(
          label: 'DELETE',
          onPressed: () {
            _showDeleteConfirmationDialog();
          },
        ),
      ),
    );

    snackBarController!.closed.then((reason) {
      setState(() {
        isSelectedForDeletion = false;
      });
    });
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this treatment?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                isSelectedForDeletion = false;
              });
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteTreatment();
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTreatment() async {
    final imageCacheProvider =
        Provider.of<ImageCacheProvider>(context, listen: false);
    try {
      if (treatmentId != null) {
        await _treatmentService.deleteTreatment(treatmentId!);
        imageCacheProvider.clearPictures();
        await _deleteAssociatedAppointments();
        if (mounted) {
          _showSnackBar('Treatment deleted successfully');
        }
        setState(() {
          isTreatmentPlanCreated = false;
          treatmentId = null;
          treatmentData = null;
          isSelectedForDeletion = false;
        });
      }
    } catch (error) {
      if (mounted) {
        _showSnackBar('Error deleting treatment: $error');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteAssociatedAppointments() async {
    try {
      final appointmentService = AppointmentService();
      List<Appointment> patientFutureAppointments =
          await appointmentService.fetchPatientFutureAppointments(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
      );

      for (Appointment appointment in patientFutureAppointments) {
        await appointmentService.deleteAppointmentAndUpdateSlot(
          widget.clinicId,
          widget.doctorName,
          appointment.appointmentId,
          appointment.appointmentDate,
          appointment.slot,
          () {
            devtools.log(
                'Deleted appointment ${appointment.appointmentId} and updated slot');
          },
        );
      }
    } catch (error) {
      devtools.log('Error deleting appointments: $error');
      rethrow;
    }
  }

  //---------------------------------------------//

  // void _navigateToHomeScreen() {
  //   devtools.log('Navigating to Home Screen with clinicId: ${widget.clinicId}');

  //   // Access the parent HomePageState
  //   final homePageState = context.findAncestorStateOfType<HomePageState>();

  //   if (homePageState != null) {
  //     // Use the public setter to update currentIndex
  //     homePageState.currentIndex = 0; // Ensures LandingScreen is displayed
  //     devtools.log('Updated HomePageState to display LandingScreen.');
  //   } else {
  //     devtools.log('HomePageState not found in the ancestor tree.');
  //   }

  //   // Navigate back to HomePage
  //   Navigator.of(context).popUntil((route) {
  //     if (route.settings.name == homePageRoute) {
  //       return true; // Stop popping once HomePage is found
  //     }
  //     return false; // Continue popping
  //   });

  //   // If HomePage doesn't exist in the stack, push it
  //   final homePageExists = Navigator.of(context).canPop();
  //   if (!homePageExists) {
  //     Navigator.pushNamed(
  //       context,
  //       homePageRoute,
  //       arguments: {
  //         'selectedClinicId': widget.clinicId,
  //       },
  //     );
  //     devtools.log('HomePage not found in stack, navigating using pushNamed.');
  //   }
  // }

  void _navigateToHomeScreen() {
    devtools.log('Navigating to Home Screen with clinicId: ${widget.clinicId}');

    Navigator.of(context).popUntil((route) {
      if (route.settings.name == homePageRoute) {
        return true; // Stop popping once HomePage is found
      }
      return false; // Continue popping
    });

    // Check if HomePage exists in the navigation stack
    final homePageExists = Navigator.of(context).canPop();
    if (!homePageExists) {
      Navigator.pushNamed(
        context,
        homePageRoute,
        arguments: {
          'selectedClinicId': widget.clinicId,
          'selectedClinicName': ClinicSelection
              .instance.selectedClinicName, // Pass required argument
        },
      );
      devtools.log('HomePage not found in stack, navigating using pushNamed.');
    }
  }

  //----------------------------------------------//

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      final File imageFile = File(pickedImage.path);

      final PatientService patientService =
          PatientService(widget.clinicId, widget.doctorId);
      final String imageUrl =
          await patientService.uploadPatientImage(imageFile, widget.patientId);

      await patientService.updatePatientImage(widget.patientId, imageUrl);

      Navigator.of(context).pop(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    devtools.log(
        'This is coming from inside build widget. isTreatmentPlanCreated is $isTreatmentPlanCreated');

    return GestureDetector(
      onTap: () {
        if (snackBarController != null) {
          snackBarController!.close();
          snackBarController = null;
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: MyColors.colorPalette['surface-container-lowest'],
          title: Text(
            'Treatment',
            style: MyTextStyle.textStyleMap['title-large']
                ?.copyWith(color: MyColors.colorPalette['on-surface']),
          ),
          iconTheme: IconThemeData(
            color: MyColors.colorPalette['on-surface'],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (isSelectedForDeletion) {
                setState(() {
                  isSelectedForDeletion = false;
                });
                snackBarController?.close();
              }
              _navigateToHomeScreen();
            },
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: MyColors.colorPalette['outline'] ??
                                Colors.blueAccent,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: GestureDetector(
                                  onTap: () async {
                                    final imageUrl =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PatientPictureOverlayScreen(
                                          imageUrl: _patientPicUrl,
                                          onTakePicture: () =>
                                              _pickAndUploadImage(context),
                                        ),
                                      ),
                                    );

                                    if (imageUrl != null) {
                                      setState(() {
                                        _patientPicUrl = imageUrl;
                                      });
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor:
                                        MyColors.colorPalette['surface'],
                                    backgroundImage: _patientPicUrl != null &&
                                            _patientPicUrl!.isNotEmpty
                                        ? NetworkImage(_patientPicUrl!)
                                        : const AssetImage(
                                                'assets/images/default-image.png')
                                            as ImageProvider,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.patientName,
                                      style: MyTextStyle
                                          .textStyleMap['label-medium']
                                          ?.copyWith(
                                              color: MyColors
                                                  .colorPalette['on-surface']),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          widget.age.toString(),
                                          style: MyTextStyle
                                              .textStyleMap['label-medium']
                                              ?.copyWith(
                                                  color: MyColors.colorPalette[
                                                      'on-surface-variant']),
                                        ),
                                        Text(
                                          '/',
                                          style: MyTextStyle
                                              .textStyleMap['label-medium']
                                              ?.copyWith(
                                                  color: MyColors.colorPalette[
                                                      'on-surface-variant']),
                                        ),
                                        Text(
                                          widget.gender,
                                          style: MyTextStyle
                                              .textStyleMap['label-medium']
                                              ?.copyWith(
                                                  color: MyColors.colorPalette[
                                                      'on-surface-variant']),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      widget.patientMobileNumber,
                                      style: MyTextStyle
                                          .textStyleMap['label-medium']
                                          ?.copyWith(
                                              color: MyColors.colorPalette[
                                                  'on-surface-variant']),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ongoing Treatment',
                        style: MyTextStyle.textStyleMap['title-large']
                            ?.copyWith(
                                color: MyColors.colorPalette['on-surface']),
                      ),
                    ),
                    const SizedBox(height: 16),
                    isTreatmentPlanCreated
                        ? buildTreatmentPlanWidget()
                        : buildNoTreatmentWidget(),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Treatment History',
                        style: MyTextStyle.textStyleMap['title-large']
                            ?.copyWith(
                                color: MyColors.colorPalette['on-surface']),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isNoPreviousTreatmentPlan)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Patient has no previous treatment history with the clinic',
                          style: MyTextStyle.textStyleMap['label-medium']
                              ?.copyWith(
                                  color: MyColors
                                      .colorPalette['on-surface-variant']),
                        ),
                      ),
                    if (!isNoPreviousTreatmentPlan)
                      for (var i = 0; i < closedTreatments.length; i++) ...[
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ClosedTreatmentSummaryScreen(
                                  clinicId: widget.clinicId,
                                  patientId: widget.patientId,
                                  patientPicUrl: widget.patientPicUrl,
                                  age: widget.age,
                                  gender: widget.gender,
                                  patientName: widget.patientName,
                                  patientMobileNumber:
                                      widget.patientMobileNumber,
                                  treatmentId: closedTreatments[i]
                                      ['treatmentId'],
                                  treatmentData: closedTreatments[i],
                                  doctorId: widget.doctorId,
                                  doctorName: widget.doctorName,
                                  uhid: widget.uhid,
                                ),
                              ),
                            );
                          },
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color:
                                            MyColors.colorPalette['outline'] ??
                                                Colors.blueAccent,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (closedTreatments[i]['procedures'] !=
                                            null)
                                          Text(
                                            'Procedures: ${List<String>.from(closedTreatments[i]['procedures'].map((procedure) => procedure['procName'])).join(', ')}',
                                            style: MyTextStyle
                                                .textStyleMap['label-medium']
                                                ?.copyWith(
                                                    color: MyColors
                                                            .colorPalette[
                                                        'on-surface-variant']),
                                          ),
                                        const SizedBox(height: 8),
                                        if (closedTreatments[i]
                                                ['treatmentDate'] !=
                                            null)
                                          Text(
                                            'Treatment Date: ${DateFormat('E, d MMM, yyyy').format(closedTreatments[i]['treatmentDate'])}',
                                            style: MyTextStyle
                                                .textStyleMap['label-medium']
                                                ?.copyWith(
                                                    color: MyColors
                                                            .colorPalette[
                                                        'on-surface-variant']),
                                          ),
                                        if (closedTreatments[i]
                                                ['treatmentCloseDate'] !=
                                            null)
                                          Text(
                                            'Treatment Close Date: ${DateFormat('E, d MMM, yyyy').format(closedTreatments[i]['treatmentCloseDate'])}',
                                            style: MyTextStyle
                                                .textStyleMap['label-medium']
                                                ?.copyWith(
                                                    color: MyColors
                                                            .colorPalette[
                                                        'on-surface-variant']),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (i < closedTreatments.length - 1)
                          const SizedBox(height: 16),
                      ],
                  ],
                ),
              ),
            ),
            if (isLoading)
              Container(
                color:
                    Colors.black.withOpacity(0.1), // Semi-transparent overlay
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// @override
  // Widget build(BuildContext context) {
  //   devtools.log(
  //       'This is coming from inside build widget. isTreatmentPlanCreated is $isTreatmentPlanCreated');
  //   //---------------------------------------------------------------------//
  //   if (isLoading) {
  //     return Container(
  //       color: Colors.black.withOpacity(0.1),
  //       child: const Center(
  //         child: CircularProgressIndicator(), // Show loading spinner
  //       ),
  //     );
  //   }

  //   //---------------------------------------------------------------------//

  //   return GestureDetector(
  //     onTap: () {
  //       if (snackBarController != null) {
  //         snackBarController!.close();
  //         snackBarController = null;
  //       }
  //     },
  //     child: Scaffold(
  //       key: _scaffoldKey,
  //       appBar: AppBar(
  //         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
  //         title: Text(
  //           'Treatment',
  //           style: MyTextStyle.textStyleMap['title-large']
  //               ?.copyWith(color: MyColors.colorPalette['on-surface']),
  //         ),
  //         iconTheme: IconThemeData(
  //           color: MyColors.colorPalette['on-surface'],
  //         ),
  //         leading: IconButton(
  //           icon: const Icon(Icons.arrow_back),
  //           onPressed: () {
  //             if (isSelectedForDeletion) {
  //               setState(() {
  //                 isSelectedForDeletion = false;
  //               });
  //               snackBarController?.close();
  //             }
  //             _navigateToHomeScreen();
  //           },
  //         ),
  //       ),
  //       body: SingleChildScrollView(
  //         child: Padding(
  //           padding:
  //               const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  //           child: Column(
  //             children: [
  //               Align(
  //                 alignment: Alignment.topCenter,
  //                 child: Container(
  //                   padding: const EdgeInsets.all(16),
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       width: 1,
  //                       color: MyColors.colorPalette['outline'] ??
  //                           Colors.blueAccent,
  //                     ),
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                   child: IntrinsicHeight(
  //                     child: Row(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Align(
  //                           alignment: Alignment.topLeft,
  //                           child: GestureDetector(
  //                             onTap: () async {
  //                               final imageUrl =
  //                                   await Navigator.of(context).push(
  //                                 MaterialPageRoute(
  //                                   builder: (context) =>
  //                                       PatientPictureOverlayScreen(
  //                                     imageUrl: _patientPicUrl,
  //                                     onTakePicture: () =>
  //                                         _pickAndUploadImage(context),
  //                                   ),
  //                                 ),
  //                               );

  //                               if (imageUrl != null) {
  //                                 setState(() {
  //                                   _patientPicUrl = imageUrl;
  //                                 });
  //                               }
  //                             },
  //                             child: CircleAvatar(
  //                               radius: 24,
  //                               backgroundColor:
  //                                   MyColors.colorPalette['surface'],
  //                               backgroundImage: _patientPicUrl != null &&
  //                                       _patientPicUrl!.isNotEmpty
  //                                   ? NetworkImage(_patientPicUrl!)
  //                                   : const AssetImage(
  //                                           'assets/images/default-image.png')
  //                                       as ImageProvider,
  //                             ),
  //                           ),
  //                         ),
  //                         const SizedBox(height: 16),
  //                         Padding(
  //                           padding: const EdgeInsets.only(left: 8.0),
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 widget.patientName,
  //                                 style: MyTextStyle
  //                                     .textStyleMap['label-medium']
  //                                     ?.copyWith(
  //                                         color: MyColors
  //                                             .colorPalette['on-surface']),
  //                               ),
  //                               Row(
  //                                 children: [
  //                                   Text(
  //                                     widget.age.toString(),
  //                                     style: MyTextStyle
  //                                         .textStyleMap['label-medium']
  //                                         ?.copyWith(
  //                                             color: MyColors.colorPalette[
  //                                                 'on-surface-variant']),
  //                                   ),
  //                                   Text(
  //                                     '/',
  //                                     style: MyTextStyle
  //                                         .textStyleMap['label-medium']
  //                                         ?.copyWith(
  //                                             color: MyColors.colorPalette[
  //                                                 'on-surface-variant']),
  //                                   ),
  //                                   Text(
  //                                     widget.gender,
  //                                     style: MyTextStyle
  //                                         .textStyleMap['label-medium']
  //                                         ?.copyWith(
  //                                             color: MyColors.colorPalette[
  //                                                 'on-surface-variant']),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Text(
  //                                 widget.patientMobileNumber,
  //                                 style: MyTextStyle
  //                                     .textStyleMap['label-medium']
  //                                     ?.copyWith(
  //                                         color: MyColors.colorPalette[
  //                                             'on-surface-variant']),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               Align(
  //                 alignment: Alignment.centerLeft,
  //                 child: Text(
  //                   'Ongoing Treatment',
  //                   style: MyTextStyle.textStyleMap['title-large']
  //                       ?.copyWith(color: MyColors.colorPalette['on-surface']),
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               isTreatmentPlanCreated
  //                   ? buildTreatmentPlanWidget()
  //                   : buildNoTreatmentWidget(),
  //               const SizedBox(height: 16),
  //               Align(
  //                 alignment: Alignment.centerLeft,
  //                 child: Text(
  //                   'Treatment History',
  //                   style: MyTextStyle.textStyleMap['title-large']
  //                       ?.copyWith(color: MyColors.colorPalette['on-surface']),
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               if (isNoPreviousTreatmentPlan)
  //                 Align(
  //                   alignment: Alignment.centerLeft,
  //                   child: Text(
  //                     'Patient has no previous treatment history with the clinic',
  //                     style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
  //                         color: MyColors.colorPalette['on-surface-variant']),
  //                   ),
  //                 ),
  //               if (!isNoPreviousTreatmentPlan)
  //                 for (var i = 0; i < closedTreatments.length; i++) ...[
  //                   GestureDetector(
  //                     onTap: () {
  //                       Navigator.of(context).push(
  //                         MaterialPageRoute(
  //                           builder: (context) => ClosedTreatmentSummaryScreen(
  //                             clinicId: widget.clinicId,
  //                             patientId: widget.patientId,
  //                             patientPicUrl: widget.patientPicUrl,
  //                             age: widget.age,
  //                             gender: widget.gender,
  //                             patientName: widget.patientName,
  //                             patientMobileNumber: widget.patientMobileNumber,
  //                             treatmentId: closedTreatments[i]['treatmentId'],
  //                             treatmentData: closedTreatments[i],
  //                             doctorId: widget.doctorId,
  //                             doctorName: widget.doctorName,
  //                             uhid: widget.uhid,
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                     child: Align(
  //                       alignment: Alignment.topLeft,
  //                       child: Row(
  //                         children: [
  //                           Expanded(
  //                             child: Container(
  //                               padding: const EdgeInsets.all(16),
  //                               decoration: BoxDecoration(
  //                                 border: Border.all(
  //                                   width: 1,
  //                                   color: MyColors.colorPalette['outline'] ??
  //                                       Colors.blueAccent,
  //                                 ),
  //                                 borderRadius: BorderRadius.circular(10),
  //                               ),
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   if (closedTreatments[i]['procedures'] !=
  //                                       null)
  //                                     Text(
  //                                       'Procedures: ${List<String>.from(closedTreatments[i]['procedures'].map((procedure) => procedure['procName'])).join(', ')}',
  //                                       style: MyTextStyle
  //                                           .textStyleMap['label-medium']
  //                                           ?.copyWith(
  //                                               color: MyColors.colorPalette[
  //                                                   'on-surface-variant']),
  //                                     ),
  //                                   const SizedBox(height: 8),
  //                                   if (closedTreatments[i]['treatmentDate'] !=
  //                                       null)
  //                                     Text(
  //                                       'Treatment Date: ${DateFormat('E, d MMM, yyyy').format(closedTreatments[i]['treatmentDate'])}',
  //                                       style: MyTextStyle
  //                                           .textStyleMap['label-medium']
  //                                           ?.copyWith(
  //                                               color: MyColors.colorPalette[
  //                                                   'on-surface-variant']),
  //                                     ),
  //                                   if (closedTreatments[i]
  //                                           ['treatmentCloseDate'] !=
  //                                       null)
  //                                     Text(
  //                                       'Treatment Close Date: ${DateFormat('E, d MMM, yyyy').format(closedTreatments[i]['treatmentCloseDate'])}',
  //                                       style: MyTextStyle
  //                                           .textStyleMap['label-medium']
  //                                           ?.copyWith(
  //                                               color: MyColors.colorPalette[
  //                                                   'on-surface-variant']),
  //                                     ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   if (i < closedTreatments.length - 1)
  //                     const SizedBox(height: 16),
  //                 ],
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }


// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE WITH DIRECT BACKEND CALLS
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/constants/routes.dart';
// import 'package:neocare_dental_app/firestore/appointment_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/firestore/treatment_service.dart';
// import 'package:neocare_dental_app/mywidgets/closed_treatment_summary_screen.dart';
// import 'package:neocare_dental_app/mywidgets/consent_widget.dart';
// import 'package:neocare_dental_app/mywidgets/image_cache_provider.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient_pictrue_overlay_screen.dart';
// import 'package:neocare_dental_app/mywidgets/start_or_edit_treatment.dart';
// import 'package:neocare_dental_app/mywidgets/start_treatment.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/treatment_summary_screen.dart';
// import 'package:neocare_dental_app/mywidgets/cache.dart';
// import 'package:neocare_dental_app/mywidgets/user_data_provider.dart';
// import 'package:provider/provider.dart';

// class TreatmentLandingScreen extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String patientId;
//   final int age;
//   final String gender;
//   final String patientName;
//   final String patientMobileNumber;
//   final String? patientPicUrl;
//   final String? uhid;
//   final String doctorName;

//   const TreatmentLandingScreen({
//     super.key, // Using super parameter for 'key'
//     required this.clinicId,
//     required this.doctorId,
//     required this.patientId,
//     required this.age,
//     required this.gender,
//     required this.patientName,
//     required this.patientMobileNumber,
//     required this.patientPicUrl,
//     required this.doctorName,
//     required this.uhid,
//   });

//   @override
//   State<TreatmentLandingScreen> createState() => _TreatmentLandingScreenState();
// }

// class _TreatmentLandingScreenState extends State<TreatmentLandingScreen> {
//   DateTime? appointmentDate;
//   String? treatmentId;

//   DateTime? treatmentDate;
//   Map<String, dynamic>? treatmentData;
//   double totalCost = double.nan;
//   double totalAmountPaid = 0.0;
//   bool isTreatmentPlanCreated = false;

//   bool isSelectedForDeletion = false;
//   ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? snackBarController;

//   String? procedureName;
//   bool isConsentTaken = false;
//   //--------------------------//
//   bool isTreatmentClose = false; // Add this field
//   bool isNoPreviousTreatmentPlan = true;
//   List<String> procedureNames = [];
//   List<Map<String, dynamic>> closedTreatments = [];
//   //--------------------------//
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   String? _patientPicUrl;

//   Future<void> fetchAppointmentDate() async {
//     appointmentDate =
//         await updateTreatmentIdInAppointmentsAndFetchAppointmentDate();

//     devtools.log(
//         'This is coming from inside fetchAppointmentDate function. Appointment Date is: $appointmentDate');
//     if (mounted) {
//       setState(() {
//         appointmentDate = appointmentDate;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _patientPicUrl = widget.patientPicUrl;
//     devtools.log('@@@ Welcome inside initState of TreatmentLandingScreen.');

//     fetchTreatmentData(widget.clinicId, widget.patientId).then((treatmentData) {
//       devtools.log(
//           '@@@ fetchTreatmentData invoked from inside initState of TreatmentLandingScreen');
//       if (treatmentData != null) {
//         devtools.log(
//             '@@@ This is coming from inside initState of TreatmentLandingScreen.  treatmentData is $treatmentData');
//         setState(() {
//           devtools
//               .log('@@@ You entered setState block defined inside initState');
//           treatmentId = treatmentData['treatmentId'];
//           this.treatmentData = treatmentData;

//           // Check if treatmentCost exists and then calculate totalCost
//           if (treatmentData.containsKey('treatmentCost')) {
//             final treatmentCost =
//                 treatmentData['treatmentCost'] as Map<String, dynamic>;
//             totalCost = (treatmentCost['totalCost'] ?? 0).toDouble();
//           } else {
//             totalCost = 0.0;
//           }

//           devtools.log(
//               '@@@ This is coming from inside initState of TreatmentLandingScreen. trearmentId is $treatmentId');
//           devtools.log('@@@ totalCost is $totalCost');
//           isTreatmentPlanCreated = true;
//           devtools.log(
//               '@@@ This is coming from inside initState of treatment landing screen. isTreatmentPlanCreated is $isTreatmentPlanCreated');
//         });
//         // Fetch the total amount paid after setting the treatment ID
//         fetchTotalAmountPaid();
//         fetchAppointmentDate();
//       } else {
//         setState(() {
//           isTreatmentPlanCreated = false;
//         });
//       }
//     }).catchError((error) {
//       devtools.log('@@@ catchError invoked');
//       _showMessageDialog(
//         'Error!',
//         'An error occurred. Navigating back to Home Screen!',
//         _navigateToHomeScreen,
//       );
//     });
//   }

//   Future<void> _showMessageDialog(
//     String title,
//     String message,
//     Function onOkPressed,
//   ) async {
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 onOkPressed();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<Map<String, dynamic>?> fetchTreatmentData(
//     String clinicId,
//     String patientId,
//   ) async {
//     try {
//       final patientDocument = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('patients')
//           .doc(patientId);

//       final patientDocumentSnapshot = await patientDocument.get();

//       if (patientDocumentSnapshot.exists) {
//         final treatmentsCollection = patientDocument.collection('treatments');
//         final treatmentsQuerySnapshot = await treatmentsCollection.get();

//         if (treatmentsQuerySnapshot.docs.isNotEmpty) {
//           bool hasActiveTreatment = false;
//           bool hasClosedTreatments = false;
//           Map<String, dynamic>? activeTreatmentData;

//           closedTreatments.clear();

//           for (var treatmentDocument in treatmentsQuerySnapshot.docs) {
//             final treatmentData = treatmentDocument.data();

//             // Log each field to identify the null value
//             devtools.log('treatmentData: $treatmentData');
//             devtools.log('treatmentId: ${treatmentData['treatmentId']}');
//             devtools.log('isConsentTaken: ${treatmentData['isConsentTaken']}');
//             devtools
//                 .log('isTreatmentClose: ${treatmentData['isTreatmentClose']}');
//             devtools.log('treatmentDate: ${treatmentData['treatmentDate']}');
//             devtools.log('treatmentCost: ${treatmentData['treatmentCost']}');
//             devtools.log('procedures: ${treatmentData['procedures']}');

//             final isConsentTaken = treatmentData['isConsentTaken'] ?? false;
//             final isTreatmentClose = treatmentData['isTreatmentClose'] ?? false;
//             devtools.log('isConsentTaken is $isConsentTaken');
//             devtools.log('isTreatmentClose is $isTreatmentClose');

//             if (isTreatmentClose) {
//               hasClosedTreatments = true;
//               closedTreatments.add(treatmentData);
//             } else {
//               hasActiveTreatment = true;
//               activeTreatmentData = treatmentData;
//               devtools.log(
//                   'hasActiveTreatment is $hasActiveTreatment and activeTreatmentData is now $activeTreatmentData');
//             }
//           }

//           setState(() {
//             isNoPreviousTreatmentPlan = !hasClosedTreatments;
//             isTreatmentClose = !hasActiveTreatment;
//             closedTreatments = closedTreatments;
//           });

//           if (hasActiveTreatment) {
//             setState(() {
//               isConsentTaken = activeTreatmentData?['isConsentTaken'] ?? false;
//               treatmentId = activeTreatmentData?['treatmentId'];
//               devtools.log(
//                   'isConsentTaken is $isConsentTaken and treatmentId is $treatmentId');
//               treatmentDate = activeTreatmentData?['treatmentDate'] != null
//                   ? (activeTreatmentData!['treatmentDate'] as Timestamp)
//                       .toDate()
//                   : null;

//               procedureNames = List<String>.from(
//                   activeTreatmentData?['procedures']
//                       .map((procedure) => procedure['procName']));
//               devtools.log('procedureNames are $procedureNames');
//               treatmentData = activeTreatmentData;
//             });
//             return activeTreatmentData;
//           }
//         } else {
//           if (mounted) {
//             setState(() {
//               isNoPreviousTreatmentPlan = true;
//               closedTreatments.clear();
//             });
//           }
//         }
//       } else {
//         devtools.log(
//             'Patient document or treatments sub-collection does not exist.');
//         if (mounted) {
//           setState(() {
//             isNoPreviousTreatmentPlan = true;
//             closedTreatments.clear();
//           });
//         }
//       }

//       return null;
//     } catch (error) {
//       devtools.log('Error fetching treatment data: $error');
//       if (mounted) {
//         setState(() {
//           isNoPreviousTreatmentPlan = true;
//           closedTreatments.clear();
//         });
//       }

//       return null;
//     }
//   }

//   // ------------------------------------------------------------------------ //

//   Future<void> fetchTotalAmountPaid() async {
//     if (treatmentId != null) {
//       final paymentsCollection = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(widget.patientId)
//           .collection('treatments')
//           .doc(treatmentId)
//           .collection('payments');

//       final paymentsSnapshot = await paymentsCollection.get();
//       double totalPaid = 0.0;

//       for (var paymentDoc in paymentsSnapshot.docs) {
//         final paymentData = paymentDoc.data();
//         final amountPaid = paymentData['paymentReceived'] ?? 0.0;
//         totalPaid += amountPaid;
//       }

//       if (mounted) {
//         setState(() {
//           totalAmountPaid = totalPaid;
//         });
//       }
//     }
//   }

//   void _navigateToTreatmentSummaryScreen() async {
//     devtools.log(
//         'This is coming from _navigateToTreatmentSummaryScreen inside TreatmentLandingScreenn');
//     devtools.log('doctorName is ${widget.doctorName}');

//     // Fetch the latest treatment data for the given clinic and patient.
//     final updatedTreatmentData = await fetchTreatmentData(
//       widget.clinicId,
//       widget.patientId,
//     );

//     // Check if the widget is still mounted before performing any further actions.
//     if (!mounted) return;

//     // Navigate to the TreatmentSummaryScreen and await the result.
//     final result = await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => TreatmentSummaryScreen(
//           clinicId: widget.clinicId,
//           patientId: widget.patientId,
//           appointmentDate: appointmentDate,
//           patientPicUrl: widget.patientPicUrl,
//           age: widget.age,
//           gender: widget.gender,
//           patientName: widget.patientName,
//           patientMobileNumber: widget.patientMobileNumber,
//           uhid: widget.uhid,
//           treatmentId: updatedTreatmentData!['treatmentId'],
//           treatmentData: updatedTreatmentData,
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//         ),
//       ),
//     );

//     // If the result indicates that the treatment was updated, refresh the treatment data.
//     if (result == true) {
//       final refreshedTreatmentData =
//           await fetchTreatmentData(widget.clinicId, widget.patientId);
//       if (!mounted) return;
//       setState(() {
//         treatmentId = refreshedTreatmentData?['treatmentId'];
//         treatmentData = refreshedTreatmentData;
//         isTreatmentPlanCreated = refreshedTreatmentData != null;
//         isNoPreviousTreatmentPlan = closedTreatments.isEmpty;
//         // Update totalCost and totalAmountPaid here if they are part of treatmentData
//         if (refreshedTreatmentData != null) {
//           totalCost = (refreshedTreatmentData['treatmentCost'] ?? 0).toDouble();
//           fetchTotalAmountPaid();
//         }
//       });
//     }
//   }

//   // ------------------------------------------------------------------------- //

//   void _navigateToStartTreatment() {
//     cache.clear();
//     Future.delayed(Duration.zero, () {
//       final userData = Provider.of<UserDataProvider>(context, listen: false);
//       userData.clearState();
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           // builder: (context) => StartTreatment(
//           builder: (context) => StartOrEditTreatment(
//             clinicId: widget.clinicId,
//             doctorId: widget.doctorId,
//             patientId: widget.patientId,
//             age: widget.age,
//             gender: widget.gender,
//             patientName: widget.patientName,
//             patientMobileNumber: widget.patientMobileNumber,
//             doctorName: widget.doctorName,
//             patientPicUrl: widget.patientPicUrl,
//             uhid: widget.uhid,
//             originalProcedures: null,
//             chiefComplaint: null,
//           ),
//         ),
//       );
//     });
//   }

//   Future<DateTime?>
//       updateTreatmentIdInAppointmentsAndFetchAppointmentDate() async {
//     devtools.log(
//         'Welcome to updateTreatmentIdInAppointmentsAndFetchAppointmentDate ');
//     final clinicRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(widget.clinicId)
//         .collection('appointments');
//     final patientRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(widget.clinicId)
//         .collection('patients')
//         .doc(widget.patientId)
//         .collection('appointments');

//     final clinicQuery = await clinicRef
//         .where('patientId', isEqualTo: widget.patientId)
//         .where('date', isGreaterThanOrEqualTo: Timestamp.now())
//         .get();

//     for (final clinicDoc in clinicQuery.docs) {
//       final appointmentId = clinicDoc.id;
//       devtools.log('appointmentId captured which is: $appointmentId');
//       try {
//         await clinicRef.doc(appointmentId).update({'treatmentId': treatmentId});
//         final patientQuery = await patientRef
//             .where('appointmentId', isEqualTo: appointmentId)
//             .get();

//         for (final patientDoc in patientQuery.docs) {
//           final patientAppointmentId = patientDoc.id;
//           try {
//             await patientRef
//                 .doc(patientAppointmentId)
//                 .update({'treatmentId': treatmentId});
//           } catch (e) {
//             devtools.log('Error updating patient appointment document: $e');
//           }
//         }
//       } catch (e) {
//         devtools.log('Error updating clinic appointment document: $e');
//       }
//     }

//     if (clinicQuery.docs.isNotEmpty) {
//       final Timestamp appointmentTimestamp = clinicQuery.docs.first['date'];
//       devtools.log('Appointment Timestamp: $appointmentTimestamp');
//       return appointmentTimestamp.toDate();
//     } else {
//       devtools.log('No appointments found');
//       return null;
//     }
//   }

//   Widget buildNoTreatmentWidget() {
//     devtools.log('Welcome to buildNoTreatmentWidget !');
//     return Column(
//       children: [
//         const SizedBox(
//           height: 24,
//         ),
//         Align(
//           alignment: Alignment.topLeft,
//           child: ElevatedButton(
//             style: ButtonStyle(
//               fixedSize: MaterialStateProperty.all(const Size(144, 48)),
//               backgroundColor: MaterialStateProperty.all(
//                   MyColors.colorPalette['on-primary']!),
//               shape: MaterialStateProperty.all(
//                 RoundedRectangleBorder(
//                   side: BorderSide(
//                       color: MyColors.colorPalette['primary']!, width: 1.0),
//                   borderRadius: BorderRadius.circular(24.0),
//                 ),
//               ),
//             ),
//             onPressed: () {
//               if (!isTreatmentPlanCreated) {
//                 setState(() {
//                   _navigateToStartTreatment();
//                 });
//               }
//             },
//             child: Text(
//               'Start',
//               style: MyTextStyle.textStyleMap['label-large']
//                   ?.copyWith(color: MyColors.colorPalette['primary']),
//             ),
//           ),
//         ),
//         const SizedBox(
//           height: 56.0,
//         ),
//       ],
//     );
//   }

//   Widget buildTreatmentPlanWidget() {
//     devtools.log('Welcome to buildTreatmentPlanWidget !');

//     // Check if there are any procedures in the treatment
//     bool hasProcedures = treatmentData?['procedures'] != null &&
//         (treatmentData!['procedures'] as List).isNotEmpty;

//     return StatefulBuilder(
//       builder: (context, setState) {
//         return GestureDetector(
//           onTap: () {
//             // Allow navigation to the treatment summary only if consent is taken or if there are no procedures
//             if ((!hasProcedures || isConsentTaken) && !isSelectedForDeletion) {
//               devtools.log('Navigating to Treatment Summary Screen');
//               _navigateToTreatmentSummaryScreen();
//             } else if (isSelectedForDeletion) {
//               // Deselect the treatment card and remove the Snackbar
//               devtools.log('Deselecting the treatment card for deletion');
//               setState(() {
//                 isSelectedForDeletion = false;
//               });
//               if (snackBarController != null) {
//                 snackBarController!.close();
//                 snackBarController = null;
//               }
//             } else if (hasProcedures && !isConsentTaken) {
//               // Prompt for consent only if procedures exist and consent is not taken
//               Navigator.of(context).push(
//                 PageRouteBuilder(
//                   opaque: false,
//                   barrierColor: Colors.black54,
//                   pageBuilder: (BuildContext context, _, __) {
//                     return ConsentWidget(
//                       clinicId: widget.clinicId,
//                       doctorId: widget.doctorId,
//                       patientId: widget.patientId,
//                       age: widget.age,
//                       gender: widget.gender,
//                       patientName: widget.patientName,
//                       patientMobileNumber: widget.patientMobileNumber,
//                       patientPicUrl: widget.patientPicUrl,
//                       doctorName: widget.doctorName,
//                       uhid: widget.uhid,
//                       treatmentId: treatmentId,
//                     );
//                   },
//                   transitionsBuilder:
//                       (___, Animation<double> animation, ____, Widget child) {
//                     return FadeTransition(
//                       opacity: animation,
//                       child: child,
//                     );
//                   },
//                 ),
//               );
//             }
//           },
//           onLongPress: () {
//             devtools.log('You long pressed on the treatment card.');
//             setState(() {
//               isSelectedForDeletion = true;
//             });
//             _showDeleteSnackBar();
//           },
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: isSelectedForDeletion
//                   ? Colors.red.withOpacity(0.2)
//                   : Colors.transparent,
//               border: Border.all(
//                 width: 1,
//                 color: MyColors.colorPalette['outline'] ?? Colors.blueAccent,
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Column(
//               children: [
//                 if (hasProcedures && !isConsentTaken)
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'Consent pending!',
//                       style: MyTextStyle.textStyleMap['title-small']
//                           ?.copyWith(color: MyColors.colorPalette['error']),
//                     ),
//                   ),
//                 if (!hasProcedures)
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'No procedures selected. Consent not required.',
//                       style: MyTextStyle.textStyleMap['title-small']?.copyWith(
//                           color: MyColors.colorPalette['on-surface-variant']),
//                     ),
//                   ),
//                 Container(
//                   color: MyColors.colorPalette['outline-variant'],
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       List<String>.from(treatmentData!['procedures']
//                               .map((procedure) => procedure['procName']))
//                           .join(', '),
//                       style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface-variant']),
//                     ),
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: 'Next Appointment: ',
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['on-surface-variant'],
//                           ),
//                         ),
//                         TextSpan(
//                           text: appointmentDate != null
//                               ? DateFormat('E, d MMM, hh:mm a')
//                                   .format(appointmentDate!)
//                               : 'N/A',
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['primary'],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: 'Amount Paid/Treatment Cost: ',
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['on-surface-variant'],
//                           ),
//                         ),
//                         TextSpan(
//                           text:
//                               '${totalAmountPaid.toStringAsFixed(0)} / ${totalCost.toStringAsFixed(0)}',
//                           style: MyTextStyle.textStyleMap['label-medium']
//                               ?.copyWith(
//                             color: MyColors.colorPalette['primary'],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _deleteTreatment() async {
//     final imageCacheProvider =
//         Provider.of<ImageCacheProvider>(context, listen: false);
//     try {
//       if (treatmentId != null) {
//         final treatmentService = TreatmentService(
//           clinicId: widget.clinicId,
//           patientId: widget.patientId,
//         );
//         await treatmentService.deleteTreatment(treatmentId!);

//         // Clear image cache

//         imageCacheProvider.clearPictures(); // Add this line

//         await _deleteAssociatedAppointments();
//         if (mounted) {
//           _showSnackBar('Treatment deleted successfully');
//         }
//         setState(() {
//           isTreatmentPlanCreated = false;
//           treatmentId = null;
//           treatmentData = null;
//           isSelectedForDeletion = false;
//         });
//       }
//     } catch (error) {
//       if (mounted) {
//         _showSnackBar('Error deleting treatment: $error');
//       }
//     }
//   }

//   // ------------------------------------------------------------------------//

//   void _showDeleteSnackBar() {
//     if (snackBarController != null) {
//       snackBarController!.close();
//       snackBarController = null;
//     }
//     _displaySnackBar();
//   }

//   void _displaySnackBar() {
//     snackBarController = ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Delete this treatment?'),
//         duration: const Duration(days: 1),
//         action: SnackBarAction(
//           label: 'DELETE',
//           onPressed: () {
//             _showDeleteConfirmationDialog(context);
//           },
//         ),
//       ),
//     );

//     snackBarController!.closed.then((reason) {
//       setState(() {
//         isSelectedForDeletion = false; // Deselect card when SnackBar is closed
//       });
//     });
//   }

//   void _showDeleteConfirmationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Deletion'),
//         content: const Text('Are you sure you want to delete this treatment?'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               setState(() {
//                 isSelectedForDeletion = false;
//               });
//             },
//             child: const Text('CANCEL'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.of(context).pop();
//               await _deleteTreatment(); // Await the future returned by _deleteTreatment
//             },
//             child: const Text('DELETE'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ----------------------------------------------------------------------- //

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   Future<void> _deleteAssociatedAppointments() async {
//     try {
//       final appointmentService = AppointmentService();
//       List<Appointment> patientFutureAppointments =
//           await appointmentService.fetchPatientFutureAppointments(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//       );

//       for (Appointment appointment in patientFutureAppointments) {
//         await appointmentService.deleteAppointmentAndUpdateSlot(
//           widget.clinicId,
//           widget.doctorName,
//           appointment.appointmentId,
//           appointment.appointmentDate,
//           appointment.slot,
//           () {
//             devtools.log(
//                 'Deleted appointment ${appointment.appointmentId} and updated slot');
//           },
//         );
//       }
//     } catch (error) {
//       devtools.log('Error deleting appointments: $error');
//       //throw error;
//       rethrow;
//     }
//   }

//   //----------------------------------------------------//
//   void _navigateToHomeScreen() {
//     Navigator.pushNamedAndRemoveUntil(
//       context,
//       homePageRoute, // Replace with your home page route name
//       (Route<dynamic> route) => false,
//     );
//   }

//   //------------------------------------------------------//

//   Future<void> _pickAndUploadImage(BuildContext context) async {
//     final picker = ImagePicker();
//     final pickedImage = await picker.pickImage(source: ImageSource.camera);

//     if (pickedImage != null) {
//       final File imageFile = File(pickedImage.path);

//       // Upload the image to Firebase Storage and get the URL
//       final PatientService patientService =
//           PatientService(widget.clinicId, widget.doctorId);
//       final String imageUrl =
//           await patientService.uploadPatientImage(imageFile, widget.patientId);

//       // Update the patient document with the new image URL
//       await patientService.updatePatientImage(widget.patientId, imageUrl);

//       // Return to the previous screen with the new image URL
//       Navigator.of(context).pop(imageUrl);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (snackBarController != null) {
//           snackBarController!.close();
//           snackBarController = null;
//         }
//       },
//       child: Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(
//           backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//           title: Text(
//             'Treatment',
//             style: MyTextStyle.textStyleMap['title-large']
//                 ?.copyWith(color: MyColors.colorPalette['on-surface']),
//           ),
//           iconTheme: IconThemeData(
//             color: MyColors.colorPalette['on-surface'],
//           ),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               if (isSelectedForDeletion) {
//                 setState(() {
//                   isSelectedForDeletion = false;
//                 });
//                 if (snackBarController != null) {
//                   snackBarController!.close();
//                   snackBarController = null;
//                 }
//               }

//               _navigateToHomeScreen();
//             },
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.only(
//                 left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//             child: Column(
//               children: [
//                 Align(
//                   alignment: Alignment.topCenter,
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         width: 1,
//                         color: MyColors.colorPalette['outline'] ??
//                             Colors.blueAccent,
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: IntrinsicHeight(
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Align(
//                             alignment: Alignment.topLeft,
//                             child: GestureDetector(
//                               onTap: () async {
//                                 final imageUrl =
//                                     await Navigator.of(context).push(
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         PatientPictureOverlayScreen(
//                                       imageUrl: _patientPicUrl,
//                                       onTakePicture: () => _pickAndUploadImage(
//                                           context), // Handle picture taking
//                                     ),
//                                   ),
//                                 );

//                                 // Update the CircleAvatar with the new image
//                                 if (imageUrl != null) {
//                                   setState(() {
//                                     _patientPicUrl = imageUrl;
//                                   });
//                                 }
//                               },
//                               child: CircleAvatar(
//                                 radius: 24,
//                                 backgroundColor:
//                                     MyColors.colorPalette['surface'],
//                                 backgroundImage: _patientPicUrl != null &&
//                                         _patientPicUrl!.isNotEmpty
//                                     ? NetworkImage(_patientPicUrl!)
//                                     : const AssetImage(
//                                             'assets/images/default-image.png')
//                                         as ImageProvider,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   widget.patientName,
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                           color: MyColors
//                                               .colorPalette['on-surface']),
//                                 ),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       widget.age.toString(),
//                                       style: MyTextStyle
//                                           .textStyleMap['label-medium']
//                                           ?.copyWith(
//                                               color: MyColors.colorPalette[
//                                                   'on-surface-variant']),
//                                     ),
//                                     Text(
//                                       '/',
//                                       style: MyTextStyle
//                                           .textStyleMap['label-medium']
//                                           ?.copyWith(
//                                               color: MyColors.colorPalette[
//                                                   'on-surface-variant']),
//                                     ),
//                                     Text(
//                                       widget.gender,
//                                       style: MyTextStyle
//                                           .textStyleMap['label-medium']
//                                           ?.copyWith(
//                                               color: MyColors.colorPalette[
//                                                   'on-surface-variant']),
//                                     ),
//                                   ],
//                                 ),
//                                 Text(
//                                   widget.patientMobileNumber,
//                                   style: MyTextStyle
//                                       .textStyleMap['label-medium']
//                                       ?.copyWith(
//                                           color: MyColors.colorPalette[
//                                               'on-surface-variant']),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Ongoing Treatment',
//                     style: MyTextStyle.textStyleMap['title-large']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 isTreatmentPlanCreated
//                     ? buildTreatmentPlanWidget()
//                     : buildNoTreatmentWidget(),
//                 const SizedBox(height: 16),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Treatment History',
//                     style: MyTextStyle.textStyleMap['title-large']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 if (isNoPreviousTreatmentPlan)
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'Patient has no previous treatment history with the clinic',
//                       style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface-variant']),
//                     ),
//                   ),
//                 if (!isNoPreviousTreatmentPlan)
//                   for (var i = 0; i < closedTreatments.length; i++) ...[
//                     GestureDetector(
//                       onTap: () {
//                         //Navigate to the closed treatment screen
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => ClosedTreatmentSummaryScreen(
//                               clinicId: widget.clinicId,
//                               patientId: widget.patientId,
//                               patientPicUrl: widget.patientPicUrl,
//                               age: widget.age,
//                               gender: widget.gender,
//                               patientName: widget.patientName,
//                               patientMobileNumber: widget.patientMobileNumber,
//                               treatmentId: closedTreatments[i]['treatmentId'],
//                               treatmentData: closedTreatments[i],
//                               doctorId: widget.doctorId,
//                               doctorName: widget.doctorName,
//                               uhid: widget.uhid,
//                             ),
//                           ),
//                         );
//                       },
//                       child: Align(
//                         alignment: Alignment.topLeft,
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     width: 1,
//                                     color: MyColors.colorPalette['outline'] ??
//                                         Colors.blueAccent,
//                                   ),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     if (closedTreatments[i]['procedures'] !=
//                                         null)
//                                       Text(
//                                         'Procedures: ${List<String>.from(closedTreatments[i]['procedures'].map((procedure) => procedure['procName'])).join(', ')}',
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on-surface-variant']),
//                                       ),
//                                     const SizedBox(height: 8),
//                                     if (closedTreatments[i]['treatmentDate'] !=
//                                         null)
//                                       Text(
//                                         'Treatment Date: ${DateFormat('E, d MMM, yyyy').format((closedTreatments[i]['treatmentDate'] as Timestamp).toDate())}',
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on-surface-variant']),
//                                       ),
//                                     if (closedTreatments[i]['treatmentDate'] !=
//                                         null)
//                                       Text(
//                                         'Treatment Close Date: ${DateFormat('E, d MMM, yyyy').format((closedTreatments[i]['treatmentCloseDate'] as Timestamp).toDate())}',
//                                         style: MyTextStyle
//                                             .textStyleMap['label-medium']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on-surface-variant']),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     if (i < closedTreatments.length - 1)
//                       const SizedBox(
//                           height: 16), // Add space between containers
//                   ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
