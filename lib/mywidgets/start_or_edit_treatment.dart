import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/add_empty_container.dart';
import 'package:neocaresmileapp/mywidgets/add_empty_oral_examination_container.dart';
import 'package:neocaresmileapp/mywidgets/create_edit_treatment_screen_1.dart';
import 'package:neocaresmileapp/mywidgets/create_edit_treatment_screen_2.dart';
import 'package:neocaresmileapp/mywidgets/create_edit_treatment_screen_3.dart';
import 'package:neocaresmileapp/mywidgets/create_edit_treatment_screen_3a.dart';
import 'package:neocaresmileapp/mywidgets/create_edit_treatment_screen_4.dart';

import 'package:neocaresmileapp/mywidgets/image_cache_provider.dart';

import 'package:neocaresmileapp/mywidgets/user_data_provider.dart';
import 'package:neocaresmileapp/mywidgets/procedure_cache_provider.dart'; // Import ProcedureCacheProvider
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

import 'package:shared_preferences/shared_preferences.dart';

class StartOrEditTreatment extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String patientId;
  final int age;
  final String gender;
  final String patientName;
  final String patientMobileNumber;
  final String? patientPicUrl;
  final String doctorName;
  final String? uhid;
  final String? treatmentId;
  final Map<String, dynamic>? treatmentData;
  final List<String>? originalProcedures;
  final String? chiefComplaint;

  const StartOrEditTreatment({
    super.key,
    required this.patientId,
    required this.age,
    required this.gender,
    required this.patientName,
    required this.patientMobileNumber,
    required this.patientPicUrl,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
    required this.uhid,
    this.treatmentId,
    this.treatmentData,
    required this.originalProcedures,
    required this.chiefComplaint,
  });

  @override
  State<StartOrEditTreatment> createState() => _StartOrEditTreatmentState();
}

class _StartOrEditTreatmentState extends State<StartOrEditTreatment> {
  late PageController _pageController;
  List<AddEmptyOralExaminationContainer> addContainers = [];
  List<AddEmptyContainer> addDynamicContainers = [];
  //List<EditAddEmptyOralExaminationContainer> editContainers = [];
  //List<EditAddEmptyContainer> editDynamicContainers = [];

  List<Map<String, dynamic>> currentProcedures = [];

  late ImageCacheProvider imageCacheProvider;

  @override
  void initState() {
    super.initState();
    if (widget.treatmentId == null) {
      startNewTreatment();
    }
    _pageController = PageController(initialPage: 0);
    imageCacheProvider =
        Provider.of<ImageCacheProvider>(context, listen: false);
    _loadInitialData();
  }

  void _loadInitialData() {
    final userData = Provider.of<UserDataProvider>(context, listen: false);
    if (widget.treatmentData != null) {
      userData
          .updateChiefComplaint(widget.treatmentData!['chiefComplaint'] ?? '');

      List<Map<String, dynamic>> oralExamination =
          (widget.treatmentData!['oralExamination'] as List<dynamic>?)
                  ?.map((item) => item as Map<String, dynamic>)
                  .toList() ??
              [];

      userData.updateOralExamination(oralExamination);

      List<Map<String, dynamic>> procedures =
          (widget.treatmentData!['procedures'] as List<dynamic>?)
                  ?.map((item) => item as Map<String, dynamic>)
                  .toList() ??
              [];

      userData.updateProcedures(procedures);
    }
  }

  Future<void> startNewTreatment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('initialOpeningBalance');
    await prefs.remove('lastTreatmentId');

    devtools
        .log('Starting a new treatment. Previous SharedPreferences cleared.');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildScreen1(UserDataProvider userData) {
    return CreateEditTreatmentScreen1(
      doctorId: widget.doctorId,
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      age: widget.age,
      gender: widget.gender,
      patientName: widget.patientName,
      patientMobileNumber: widget.patientMobileNumber,
      patientPicUrl: widget.patientPicUrl,
      pageController: _pageController,
      doctorName: widget.doctorName,
      uhid: widget.uhid,
      userData: userData,
      treatmentData: widget.treatmentData,
      treatmentId: widget.treatmentId,
      isEditMode: widget.treatmentId != null && widget.treatmentData != null,
      originalProcedures: widget.originalProcedures,
      chiefComplaint: widget.chiefComplaint,
      imageCacheProvider: imageCacheProvider,
    );
  }

  Widget _buildScreen2(
      UserDataProvider userData, ImageCacheProvider imageCacheProvider) {
    // Access ProcedureCacheProvider here
    final procedureCache =
        Provider.of<ProcedureCacheProvider>(context, listen: false);

    return CreateEditTreatmentScreen2(
      doctorId: widget.doctorId,
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      age: widget.age,
      gender: widget.gender,
      patientName: widget.patientName,
      patientMobileNumber: widget.patientMobileNumber,
      patientPicUrl: widget.patientPicUrl,
      pageController: _pageController,
      userData: userData,
      doctorName: widget.doctorName,
      uhid: widget.uhid,
      treatmentData: widget.treatmentData,
      treatmentId: widget.treatmentId,
      isEditMode: widget.treatmentId != null && widget.treatmentData != null,
      originalProcedures: widget.originalProcedures,
      chiefComplaint: widget.chiefComplaint,
      imageCacheProvider: imageCacheProvider,
    );
  }

  Widget _buildScreen3(
      UserDataProvider userData, ImageCacheProvider imageCacheProvider) {
    final procedureCache =
        Provider.of<ProcedureCacheProvider>(context, listen: false);

    return CreateEditTreatmentScreen3(
      doctorId: widget.doctorId,
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      age: widget.age,
      gender: widget.gender,
      patientName: widget.patientName,
      patientMobileNumber: widget.patientMobileNumber,
      patientPicUrl: widget.patientPicUrl,
      pageController: _pageController,
      userData: userData,
      doctorName: widget.doctorName,
      uhid: widget.uhid,
      treatmentData: widget.treatmentData,
      treatmentId: widget.treatmentId,
      isEditMode: widget.treatmentId != null && widget.treatmentData != null,
      originalProcedures: widget.originalProcedures,
      chiefComplaint: widget.chiefComplaint,
      imageCacheProvider: imageCacheProvider,
      currentProcedures: procedureCache.selectedProcedures,
    );
  }

  //------------------------------------------------------------------ //
  Widget _buildScreen3a(
      UserDataProvider userData, ImageCacheProvider imageCacheProvider) {
    final procedureCache =
        Provider.of<ProcedureCacheProvider>(context, listen: false);

    return CreateEditTreatmentScreen3A(
      doctorId: widget.doctorId,
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      age: widget.age,
      gender: widget.gender,
      patientName: widget.patientName,
      patientMobileNumber: widget.patientMobileNumber,
      patientPicUrl: widget.patientPicUrl,
      pageController: _pageController,
      userData: userData,
      doctorName: widget.doctorName,
      uhid: widget.uhid,
      treatmentData: widget.treatmentData,
      treatmentId: widget.treatmentId,
      isEditMode: widget.treatmentId != null && widget.treatmentData != null,
      originalProcedures: widget.originalProcedures,
      chiefComplaint: widget.chiefComplaint,
      imageCacheProvider: imageCacheProvider,
      currentProcedures: procedureCache.selectedProcedures,
      pictureData11: imageCacheProvider.pictures,
    );
  }
  // ----------------------------------------------------------------- //

  Widget _buildScreen4(
      UserDataProvider userData, ImageCacheProvider imageCacheProvider) {
    final procedureCache =
        Provider.of<ProcedureCacheProvider>(context, listen: false);

    return CreateEditTreatmentScreen4(
      doctorId: widget.doctorId,
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      age: widget.age,
      gender: widget.gender,
      patientName: widget.patientName,
      patientMobileNumber: widget.patientMobileNumber,
      patientPicUrl: widget.patientPicUrl,
      pageController: _pageController,
      userData: userData,
      doctorName: widget.doctorName,
      uhid: widget.uhid,
      treatmentData: widget.treatmentData,
      treatmentId: widget.treatmentId,
      isEditMode: widget.treatmentId != null && widget.treatmentData != null,
      originalProcedures: widget.originalProcedures,
      currentProcedures:
          procedureCache.selectedProcedures, // Pass currentProcedures
      //pictureData11: userData.pictures,
      pictureData11: imageCacheProvider.pictures,
      imageCacheProvider: imageCacheProvider,
      chiefComplaint: widget.chiefComplaint,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context);
    final imageCacheProvider = Provider.of<ImageCacheProvider>(context);

    final procedureCache =
        Provider.of<ProcedureCacheProvider>(context, listen: false);

    return PopScope(
      onPopInvoked: (bool backButtonPressed) {
        _handlePop(); // No need for confirmation
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildScreen1(userData),
            _buildScreen2(userData, imageCacheProvider),
            _buildScreen3(userData, imageCacheProvider),
            _buildScreen3a(userData, imageCacheProvider),
            _buildScreen4(userData, imageCacheProvider),
          ],
        ),
      ),
    );
  }

  void _handlePop() {
    // Immediately clear caches and user data when navigating back
    if (mounted) {
      final userData = Provider.of<UserDataProvider>(context, listen: false);

      final procedureCache =
          Provider.of<ProcedureCacheProvider>(context, listen: false);
      final imageCacheProvider =
          Provider.of<ImageCacheProvider>(context, listen: false);

      userData.clearState();

      procedureCache.clearProcedures();
      imageCacheProvider.clearImageCache();

      devtools
          .log('Treatment creation abandoned. Caches and user data cleared.');
    }
  }
}
