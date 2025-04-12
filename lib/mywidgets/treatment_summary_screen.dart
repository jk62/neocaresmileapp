import 'dart:io';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:neocaresmileapp/firestore/treatment_service.dart';
import 'package:neocaresmileapp/mywidgets/full_screen_image_dialog.dart';
import 'package:neocaresmileapp/mywidgets/image_cache_provider.dart';
import 'package:neocaresmileapp/mywidgets/more_tab.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/notes_tab.dart';
import 'package:neocaresmileapp/mywidgets/prescription_tab.dart';
import 'package:neocaresmileapp/mywidgets/render_treatment_data.dart';
import 'package:neocaresmileapp/mywidgets/start_or_edit_treatment.dart';
import 'package:neocaresmileapp/mywidgets/treatment_landing_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

class TreatmentSummaryScreen extends StatefulWidget {
  final String clinicId;
  final String patientId;
  final DateTime? appointmentDate;
  final String? patientPicUrl;
  final int age;
  final String gender;
  final String patientName;
  final String patientMobileNumber;
  final String? treatmentId;
  final Map<String, dynamic>? treatmentData;
  final String doctorId;
  final String doctorName;
  final String? uhid;

  const TreatmentSummaryScreen({
    super.key,
    required this.clinicId,
    required this.patientId,
    required this.appointmentDate,
    required this.patientPicUrl,
    required this.age,
    required this.gender,
    required this.patientName,
    required this.patientMobileNumber,
    required this.treatmentId,
    required this.treatmentData,
    required this.doctorId,
    required this.doctorName,
    required this.uhid,
  });

  @override
  State<TreatmentSummaryScreen> createState() => _TreatmentSummaryScreenState();
}

class _TreatmentSummaryScreenState extends State<TreatmentSummaryScreen> {
  bool _isSummaryButtonFocussed = true;
  bool _isPrescriptionButtonFocussed = false;
  bool _isNotesButtonFocussed = false;
  bool _isMoreButtonFocussed = false;
  Widget _tabContent = const SizedBox();
  bool _showMedicineInput = false;
  late List<String>? originalProcedures;
  List<Map<String, dynamic>> pictureData = [];
  bool _isLoading = false;
  late ImageCacheProvider _imageCacheProvider;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _imageCacheProvider =
        Provider.of<ImageCacheProvider>(context, listen: false);
    _fetchPictures(_imageCacheProvider);
    _updateTabContent();
    _showMedicineInput = false;
    // if (widget.treatmentData != null) {
    //   originalProcedures =
    //       (widget.treatmentData!['procedures'] as List<dynamic>)
    //           .map((procedure) => procedure['procName'] as String)
    //           .toList();
    //   devtools.log(
    //       'This is coming from inside initState of TreatmentSummaryScreen. originalProcedures are $originalProcedures');
    // } else {
    //   originalProcedures = [];
    // }
    // ------------------------------------------------------------------------ //
    if (widget.treatmentData != null) {
      originalProcedures =
          (widget.treatmentData!['procedures'] as List<dynamic>)
              .map((procedure) => procedure['procId'] as String)
              .toList();
      devtools.log(
          'This is coming from inside initState of TreatmentSummaryScreen. originalProcedures are $originalProcedures');
    } else {
      originalProcedures = [];
    }

    // ------------------------------------------------------------------------ //
  }

  //------------------------------------------------------------------------------------//
  Future<void> _fetchPictures(ImageCacheProvider imageCacheProvider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final treatmentService = TreatmentService(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
      );

      // Fetch pictures using the service
      final pictures =
          await treatmentService.fetchPictures(widget.treatmentId!);
      imageCacheProvider.clearPictures();

      for (var picture in pictures) {
        bool added = await _addPictureToCache(imageCacheProvider, picture);
        if (!added) {
          devtools.log(
              'Failed to add picture with docId ${picture['docId']} to the cache.');
        }
      }

      if (mounted) {
        setState(() {
          pictureData = imageCacheProvider.pictures;
          _isLoading = false;
          _updateTabContent();
        });
      }
    } catch (e) {
      devtools.log('Error fetching pictures: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  //------------------------------------------------------------------------------------//

  Future<bool> _addPictureToCache(ImageCacheProvider imageCacheProvider,
      Map<String, dynamic> picture) async {
    try {
      final localPath = await _downloadAndCacheImage(picture['picUrl']);
      if (localPath != null) {
        picture['localPath'] = localPath;
        imageCacheProvider.addPicture(picture);
        return true;
      }
      return false;
    } catch (e) {
      devtools.log('Error adding picture to cache: $e');
      return false;
    }
  }

  Future<String?> _downloadAndCacheImage(String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${url.split('/').last}';
      devtools.log(
          '!!!!!!!!This is coming from inside _downloadAndCacheImage. filePath is $filePath');
      final file = File(filePath);
      devtools.log(
          '!!!!!!!!This is coming from inside _downloadAndCacheImage. file is $file');

      if (await file.exists()) {
        devtools.log(
            '!!!!!! This is coming from inside if await file.exists. file.path is ${file.path}');
        return file.path;
      }

      final response = await http.get(Uri.parse(url));
      devtools.log('!!!!!!! response is $response');
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        devtools.log(
            '!!!!!!!! This is coming from inside await file.writeAsBytes. file.path now is ${file.path}');
        return file.path;
      }
      return null;
    } catch (e) {
      devtools.log('Error downloading and caching image: $e');
      return null;
    }
  }

  void _updateTabContent() {
    _tabContent = SingleChildScrollView(
      child: Column(
        children: [
          RenderTreatmentData(
            treatmentData: widget.treatmentData,
            onGalleryButtonPressed: _showPictureGallery,
            pictureData: pictureData,
          ),
        ],
      ),
    );
  }

  Future<void> _showPictureGallery() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration.zero);

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor:
                  MyColors.colorPalette['surface-container-lowest'],
              iconTheme: IconThemeData(
                color: MyColors.colorPalette['on-surface'],
              ),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: MyColors.colorPalette['on-surface'],
              ),
            ),
            body: ListView.builder(
              itemCount: pictureData.length,
              itemBuilder: (BuildContext context, int index) {
                final picture = pictureData[index];
                return Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                  child: GestureDetector(
                    onTap: () => _showFullImage(
                      picture['picUrl'],
                      picture['note'],
                      List<String>.from(picture['tags'] ?? []),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: MyColors.colorPalette['outline'] ??
                              Colors.blueAccent,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      height: 112.0,
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3,
                            child: CachedNetworkImage(
                              imageUrl: picture['picUrl'],
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.contain,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 112.0,
                              padding: const EdgeInsets.only(left: 8.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 8.0,
                                    ),
                                    Wrap(
                                      spacing: 8.0,
                                      children: picture['tags'] != null
                                          ? (picture['tags'] as List<dynamic>)
                                              .map<String>(
                                                  (tag) => tag.toString())
                                              .map<Widget>((tag) => Chip(
                                                    label: Text(
                                                      tag,
                                                      style: MyTextStyle
                                                          .textStyleMap[
                                                              'label-small']
                                                          ?.copyWith(
                                                        color: MyColors
                                                                .colorPalette[
                                                            'on-primary'],
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        MyColors.colorPalette[
                                                            'primary'],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
                                                    ),
                                                    visualDensity:
                                                        const VisualDensity(
                                                            horizontal: 0.0,
                                                            vertical: -4.0),
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4.0,
                                                            bottom: 4.0,
                                                            left: 8.0,
                                                            right: 8.0),
                                                  ))
                                              .toList()
                                          : [],
                                    ),
                                    const SizedBox(
                                      height: 8.0,
                                    ),
                                    Text(
                                      picture['note'] ?? 'No description',
                                      style: MyTextStyle
                                          .textStyleMap['label-small']
                                          ?.copyWith(
                                              color: MyColors
                                                  .colorPalette['on-surface']),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  void _showFullImage(String imageUrl, String? note, List<String> tags) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageDialog(
          imageUrl: imageUrl,
          note: note,
          tags: tags,
        ),
      ),
    );
  }

  void _navigateToSummaryTab() {
    devtools.log("Navigating to Summary Tab");

    setState(() {
      _isSummaryButtonFocussed = true;
      _isPrescriptionButtonFocussed = false;
      _isNotesButtonFocussed = false;
      _isMoreButtonFocussed = false;
      _updateTabContent();
    });
  }

  void _navigateToPrescriptionTab() {
    setState(() {
      _isPrescriptionButtonFocussed = true;
      _isSummaryButtonFocussed = false;
      _isNotesButtonFocussed = false;
      _isMoreButtonFocussed = false;
      _showMedicineInput = true;
      _tabContent = PrescriptionTab(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
        treatmentId: widget.treatmentId,
        uhid: widget.uhid,
        patientName: widget.patientName,
        doctorName: widget.doctorName,
        navigateToPrescriptionTab: _navigateToPrescriptionTab,
      );
    });
  }

  void _navigateToNotesTab() {
    devtools.log(
        "This is coming from _navigateToNotesTab function. Navigating to NotesTab");

    setState(() {
      _isNotesButtonFocussed = true;
      _isSummaryButtonFocussed = false;
      _isPrescriptionButtonFocussed = false;
      _isMoreButtonFocussed = false;
      _showMedicineInput = false;

      _tabContent = NotesTab(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
        treatmentId: widget.treatmentId,
      );
    });
  }

  void _navigateToMoreTab() {
    devtools.log(
        "This is coming from _navigateToMoreTab function. Navigating to MoreTab");

    setState(() {
      _isMoreButtonFocussed = true;
      _isNotesButtonFocussed = false;
      _isSummaryButtonFocussed = false;
      _isPrescriptionButtonFocussed = false;
      _showMedicineInput = false;

      _tabContent = MoreTab(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
        treatmentId: widget.treatmentId!,
        doctorId: widget.doctorId,
        doctorName: widget.doctorName,
        treatmentData: widget.treatmentData!,
        patientName: widget.patientName,
        age: widget.age,
        gender: widget.gender,
        patientMobileNumber: widget.patientMobileNumber,
        patientPicUrl: widget.patientPicUrl,
        uhid: widget.uhid,
      );
    });
  }

  //-------------------------------------------------------------------------------//
  Future<void> _closeTreatment() async {
    devtools.log('_closeTreatment invoked');

    setState(() {
      _isLoading = true;
    });

    try {
      final treatmentService = TreatmentService(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
      );

      // Call the closeTreatment method in TreatmentService
      await treatmentService.closeTreatment(widget.treatmentId!);

      devtools.log(
          'This is coming from inside _closeTreatment. cache being cleared.');
      _imageCacheProvider.clearPictures();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treatment closed successfully')),
        );

        // Check if the widget is still mounted before using BuildContext
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TreatmentLandingScreen(
                clinicId: widget.clinicId,
                patientId: widget.patientId,
                doctorId: widget.doctorId,
                doctorName: widget.doctorName,
                patientName: widget.patientName,
                patientMobileNumber: widget.patientMobileNumber,
                age: widget.age,
                gender: widget.gender,
                patientPicUrl: widget.patientPicUrl,
                uhid: widget.uhid,
              ),
            ),
          );
        }
      }
    } catch (e) {
      devtools.log('Error closing treatment: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error closing treatment: $e')),
        );
      }
    }
  }

  //-------------------------------------------------------------------------------//

  void _showCloseTreatmentConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Close Treatment'),
          content: const Text('Are you sure you want to close this treatment?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog

                _closeTreatment(); // Proceed to close the treatment
              },
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  void _editTreatmentPlan() {
    devtools.log("Navigating to Edit Treatment Plan");
    setState(() {
      _hasChanges = true;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final imageCacheProvider =
              Provider.of<ImageCacheProvider>(context, listen: false);
          devtools.log(
              'Before navigating to CreateEditTreatmentScreen2A, imageCacheProvider has pictures: ${imageCacheProvider.pictures}');
          return StartOrEditTreatment(
            chiefComplaint: widget.treatmentData?['chiefComplaint'] ?? '',
            clinicId: widget.clinicId,
            patientId: widget.patientId,
            age: widget.age,
            gender: widget.gender,
            patientName: widget.patientName,
            patientMobileNumber: widget.patientMobileNumber,
            patientPicUrl: widget.patientPicUrl,
            doctorId: widget.doctorId,
            doctorName: widget.doctorName,
            treatmentId: widget.treatmentId,
            treatmentData: widget.treatmentData,
            uhid: widget.uhid,
            originalProcedures: originalProcedures, // Pass originalProcedures
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _imageCacheProvider.clearPictures(); // Clear the cache
    super.dispose();
  }

  //----------------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Pop back to TreatmentLandingScreen, indicating if changes were made
            Navigator.pop(context, _hasChanges);
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 8.0,
                bottom: 8.0,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        left: 16.0, top: 24.0, bottom: 24.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: MyColors.colorPalette['outline'] ??
                            Colors.blueAccent,
                      ),
                      borderRadius: BorderRadius.circular(3),
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
                                            color: MyColors
                                                .colorPalette['on-surface']),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        widget.age.toString(),
                                        style: MyTextStyle
                                            .textStyleMap['label-small']
                                            ?.copyWith(
                                                color: MyColors.colorPalette[
                                                    'on-surface-variant']),
                                      ),
                                      Text(
                                        '/',
                                        style: MyTextStyle
                                            .textStyleMap['label-small']
                                            ?.copyWith(
                                                color: MyColors.colorPalette[
                                                    'on-surface-variant']),
                                      ),
                                      Text(
                                        widget.gender,
                                        style: MyTextStyle
                                            .textStyleMap['label-small']
                                            ?.copyWith(
                                                color: MyColors.colorPalette[
                                                    'on-surface-variant']),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    widget.patientMobileNumber,
                                    style: MyTextStyle
                                        .textStyleMap['label-small']
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildTabButton(
                        label: 'Summary',
                        isFocussed: _isSummaryButtonFocussed,
                        onPressed: _navigateToSummaryTab,
                      ),
                      const SizedBox(width: 8),
                      _buildTabButton(
                        label: 'Prescription',
                        isFocussed: _isPrescriptionButtonFocussed,
                        onPressed: _navigateToPrescriptionTab,
                      ),
                      const SizedBox(width: 8),
                      _buildTabButton(
                        label: 'Notes',
                        isFocussed: _isNotesButtonFocussed,
                        onPressed: _navigateToNotesTab,
                      ),
                      const SizedBox(width: 8),
                      _buildTabButton(
                        label: 'More',
                        isFocussed: _isMoreButtonFocussed,
                        onPressed: _navigateToMoreTab,
                      ),
                    ],
                  ),
                  Visibility(
                    visible: _isSummaryButtonFocussed ||
                        _isPrescriptionButtonFocussed ||
                        _isNotesButtonFocussed ||
                        _isMoreButtonFocussed,
                    child: _tabContent,
                  ),
                ],
              ),
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
      ),
      bottomNavigationBar: _isSummaryButtonFocussed
          ? Container(
              decoration: const BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(
                      width: 1.0, style: BorderStyle.solid, color: Colors.grey),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _editTreatmentPlan,
                        style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(152, 48)),
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
                        child: Text(
                          'Edit',
                          style: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors.colorPalette['primary']),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _showCloseTreatmentConfirmation(context),
                        style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(152, 48)),
                          backgroundColor: MaterialStateProperty.all(
                              MyColors.colorPalette['primary']),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              side: BorderSide(
                                  color: MyColors.colorPalette['primary']!,
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors.colorPalette['on-primary']),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  //----------------------------------------------------------------------------//

  Widget _buildTabButton({
    required String label,
    required bool isFocussed,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isFocussed
                ? MyColors.colorPalette['primary'] ?? Colors.blue
                : Colors.transparent,
            width: 1.0,
          ),
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return isFocussed
                  ? MyColors.colorPalette['primary'] ?? Colors.blue
                  : MyColors.colorPalette['on-surface'] ?? Colors.grey;
            },
          ),
          textStyle: MaterialStateProperty.all(
            MyTextStyle.textStyleMap['label-large'],
          ),
        ),
        child: Text(label),
      ),
    );
  }
}


// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'dart:io';
// //import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:http/http.dart' as http;
// import 'package:neocare_dental_app/firestore/treatment_service.dart';
// import 'package:neocare_dental_app/mywidgets/full_screen_image_dialog.dart';
// import 'package:neocare_dental_app/mywidgets/image_cache_provider.dart';
// import 'package:neocare_dental_app/mywidgets/more_tab.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/notes_tab.dart';
// import 'package:neocare_dental_app/mywidgets/prescription_tab.dart';
// import 'package:neocare_dental_app/mywidgets/render_treatment_data.dart';
// import 'package:neocare_dental_app/mywidgets/start_or_edit_treatment.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'dart:developer' as devtools show log;

// class TreatmentSummaryScreen extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final DateTime? appointmentDate;
//   final String? patientPicUrl;
//   final int age;
//   final String gender;
//   final String patientName;
//   final String patientMobileNumber;
//   final String? treatmentId;
//   final Map<String, dynamic>? treatmentData;
//   final String doctorId;
//   final String doctorName;
//   final String? uhid;

//   const TreatmentSummaryScreen({
//     super.key,
//     required this.clinicId,
//     required this.patientId,
//     required this.appointmentDate,
//     required this.patientPicUrl,
//     required this.age,
//     required this.gender,
//     required this.patientName,
//     required this.patientMobileNumber,
//     required this.treatmentId,
//     required this.treatmentData,
//     required this.doctorId,
//     required this.doctorName,
//     required this.uhid,
//   });

//   @override
//   State<TreatmentSummaryScreen> createState() => _TreatmentSummaryScreenState();
// }

// class _TreatmentSummaryScreenState extends State<TreatmentSummaryScreen> {
//   bool _isSummaryButtonFocussed = true;
//   bool _isPrescriptionButtonFocussed = false;
//   bool _isNotesButtonFocussed = false;
//   bool _isMoreButtonFocussed = false;
//   Widget _tabContent = const SizedBox();
//   bool _showMedicineInput = false;
//   late List<String>? originalProcedures;
//   List<Map<String, dynamic>> pictureData = [];
//   bool _isLoading = false;
//   late ImageCacheProvider _imageCacheProvider;

//   bool _hasChanges = false;

//   @override
//   void initState() {
//     super.initState();
//     _imageCacheProvider =
//         Provider.of<ImageCacheProvider>(context, listen: false);
//     _fetchPictures(_imageCacheProvider);
//     _updateTabContent();
//     _showMedicineInput = false;
//     // if (widget.treatmentData != null) {
//     //   originalProcedures =
//     //       (widget.treatmentData!['procedures'] as List<dynamic>)
//     //           .map((procedure) => procedure['procName'] as String)
//     //           .toList();
//     //   devtools.log(
//     //       'This is coming from inside initState of TreatmentSummaryScreen. originalProcedures are $originalProcedures');
//     // } else {
//     //   originalProcedures = [];
//     // }
//     // ------------------------------------------------------------------------ //
//     if (widget.treatmentData != null) {
//       originalProcedures =
//           (widget.treatmentData!['procedures'] as List<dynamic>)
//               .map((procedure) => procedure['procId'] as String)
//               .toList();
//       devtools.log(
//           'This is coming from inside initState of TreatmentSummaryScreen. originalProcedures are $originalProcedures');
//     } else {
//       originalProcedures = [];
//     }

//     // ------------------------------------------------------------------------ //
//   }

//   // Future<void> _fetchPictures(ImageCacheProvider imageCacheProvider) async {
//   //   setState(() {
//   //     _isLoading = true;
//   //   });

//   //   try {
//   //     final QuerySnapshot snapshot = await FirebaseFirestore.instance
//   //         .collection('clinics')
//   //         .doc(widget.clinicId)
//   //         .collection('patients')
//   //         .doc(widget.patientId)
//   //         .collection('treatments')
//   //         .doc(widget.treatmentId)
//   //         .collection('pictures')
//   //         .get();

//   //     imageCacheProvider.clearPictures();

//   //     for (var doc in snapshot.docs) {
//   //       var picture = doc.data() as Map<String, dynamic>;
//   //       picture['isExisting'] = true;
//   //       picture['docId'] = doc.id;

//   //       bool added = await _addPictureToCache(imageCacheProvider, picture);
//   //       if (!added) {
//   //         devtools
//   //             .log('Failed to add picture with docId ${doc.id} to the cache.');
//   //       }
//   //     }

//   //     devtools.log(
//   //         'After fetching pictures, imageCacheProvider has pictures: ${imageCacheProvider.pictures}');

//   //     if (mounted) {
//   //       setState(() {
//   //         pictureData = imageCacheProvider.pictures;
//   //         _isLoading = false;
//   //         _updateTabContent();
//   //       });
//   //     }

//   //     if (imageCacheProvider.pictures.isNotEmpty) {
//   //       devtools.log(
//   //           'This is coming from inside _fetchPictures defined inside TreatmentSummaryScreen. imageCacheProvider is populated with existing pictures.');
//   //     }
//   //   } catch (e) {
//   //     devtools.log('Error fetching pictures: $e');
//   //     if (mounted) {
//   //       setState(() {
//   //         _isLoading = false;
//   //       });
//   //     }
//   //   }
//   // }
//   //------------------------------------------------------------------------------------//
//   Future<void> _fetchPictures(ImageCacheProvider imageCacheProvider) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final treatmentService = TreatmentService(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//       );

//       // Fetch pictures using the service
//       final pictures =
//           await treatmentService.fetchPictures(widget.treatmentId!);
//       imageCacheProvider.clearPictures();

//       for (var picture in pictures) {
//         bool added = await _addPictureToCache(imageCacheProvider, picture);
//         if (!added) {
//           devtools.log(
//               'Failed to add picture with docId ${picture['docId']} to the cache.');
//         }
//       }

//       if (mounted) {
//         setState(() {
//           pictureData = imageCacheProvider.pictures;
//           _isLoading = false;
//           _updateTabContent();
//         });
//       }
//     } catch (e) {
//       devtools.log('Error fetching pictures: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   //------------------------------------------------------------------------------------//

//   Future<bool> _addPictureToCache(ImageCacheProvider imageCacheProvider,
//       Map<String, dynamic> picture) async {
//     try {
//       final localPath = await _downloadAndCacheImage(picture['picUrl']);
//       if (localPath != null) {
//         picture['localPath'] = localPath;
//         imageCacheProvider.addPicture(picture);
//         return true;
//       }
//       return false;
//     } catch (e) {
//       devtools.log('Error adding picture to cache: $e');
//       return false;
//     }
//   }

//   Future<String?> _downloadAndCacheImage(String url) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = '${directory.path}/${url.split('/').last}';
//       devtools.log(
//           '!!!!!!!!This is coming from inside _downloadAndCacheImage. filePath is $filePath');
//       final file = File(filePath);
//       devtools.log(
//           '!!!!!!!!This is coming from inside _downloadAndCacheImage. file is $file');

//       if (await file.exists()) {
//         devtools.log(
//             '!!!!!! This is coming from inside if await file.exists. file.path is ${file.path}');
//         return file.path;
//       }

//       final response = await http.get(Uri.parse(url));
//       devtools.log('!!!!!!! response is $response');
//       if (response.statusCode == 200) {
//         await file.writeAsBytes(response.bodyBytes);
//         devtools.log(
//             '!!!!!!!! This is coming from inside await file.writeAsBytes. file.path now is ${file.path}');
//         return file.path;
//       }
//       return null;
//     } catch (e) {
//       devtools.log('Error downloading and caching image: $e');
//       return null;
//     }
//   }

//   void _updateTabContent() {
//     _tabContent = SingleChildScrollView(
//       child: Column(
//         children: [
//           RenderTreatmentData(
//             treatmentData: widget.treatmentData,
//             onGalleryButtonPressed: _showPictureGallery,
//             pictureData: pictureData,
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _showPictureGallery() async {
//     setState(() {
//       _isLoading = true;
//     });

//     await Future.delayed(Duration.zero);

//     if (mounted) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return Scaffold(
//             appBar: AppBar(
//               backgroundColor:
//                   MyColors.colorPalette['surface-container-lowest'],
//               iconTheme: IconThemeData(
//                 color: MyColors.colorPalette['on-surface'],
//               ),
//               leading: IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 color: MyColors.colorPalette['on-surface'],
//               ),
//             ),
//             body: ListView.builder(
//               itemCount: pictureData.length,
//               itemBuilder: (BuildContext context, int index) {
//                 final picture = pictureData[index];
//                 return Padding(
//                   padding: const EdgeInsets.only(
//                       top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
//                   child: GestureDetector(
//                     onTap: () => _showFullImage(
//                       picture['picUrl'],
//                       picture['note'],
//                       List<String>.from(picture['tags'] ?? []),
//                     ),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           width: 1,
//                           color: MyColors.colorPalette['outline'] ??
//                               Colors.blueAccent,
//                         ),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       margin: const EdgeInsets.only(bottom: 8.0),
//                       height: 112.0,
//                       child: Row(
//                         children: [
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width / 3,
//                             child: CachedNetworkImage(
//                               imageUrl: picture['picUrl'],
//                               placeholder: (context, url) =>
//                                   const CircularProgressIndicator(),
//                               errorWidget: (context, url, error) =>
//                                   const Icon(Icons.error),
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                           Expanded(
//                             child: Container(
//                               height: 112.0,
//                               padding: const EdgeInsets.only(left: 8.0),
//                               child: SingleChildScrollView(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const SizedBox(
//                                       height: 8.0,
//                                     ),
//                                     Wrap(
//                                       spacing: 8.0,
//                                       children: picture['tags'] != null
//                                           ? (picture['tags'] as List<dynamic>)
//                                               .map<String>(
//                                                   (tag) => tag.toString())
//                                               .map<Widget>((tag) => Chip(
//                                                     label: Text(
//                                                       tag,
//                                                       style: MyTextStyle
//                                                           .textStyleMap[
//                                                               'label-small']
//                                                           ?.copyWith(
//                                                         color: MyColors
//                                                                 .colorPalette[
//                                                             'on-primary'],
//                                                       ),
//                                                     ),
//                                                     backgroundColor:
//                                                         MyColors.colorPalette[
//                                                             'primary'],
//                                                     shape:
//                                                         RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               24.0),
//                                                     ),
//                                                     visualDensity:
//                                                         const VisualDensity(
//                                                             horizontal: 0.0,
//                                                             vertical: -4.0),
//                                                     materialTapTargetSize:
//                                                         MaterialTapTargetSize
//                                                             .shrinkWrap,
//                                                     padding:
//                                                         const EdgeInsets.only(
//                                                             top: 4.0,
//                                                             bottom: 4.0,
//                                                             left: 8.0,
//                                                             right: 8.0),
//                                                   ))
//                                               .toList()
//                                           : [],
//                                     ),
//                                     const SizedBox(
//                                       height: 8.0,
//                                     ),
//                                     Text(
//                                       picture['note'] ?? 'No description',
//                                       style: MyTextStyle
//                                           .textStyleMap['label-small']
//                                           ?.copyWith(
//                                               color: MyColors
//                                                   .colorPalette['on-surface']),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ).then((_) {
//         setState(() {
//           _isLoading = false;
//         });
//       });
//     }
//   }

//   void _showFullImage(String imageUrl, String? note, List<String> tags) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => FullScreenImageDialog(
//           imageUrl: imageUrl,
//           note: note,
//           tags: tags,
//         ),
//       ),
//     );
//   }

//   void _navigateToSummaryTab() {
//     devtools.log("Navigating to Summary Tab");

//     setState(() {
//       _isSummaryButtonFocussed = true;
//       _isPrescriptionButtonFocussed = false;
//       _isNotesButtonFocussed = false;
//       _isMoreButtonFocussed = false;
//       _updateTabContent();
//     });
//   }

//   void _navigateToPrescriptionTab() {
//     setState(() {
//       _isPrescriptionButtonFocussed = true;
//       _isSummaryButtonFocussed = false;
//       _isNotesButtonFocussed = false;
//       _isMoreButtonFocussed = false;
//       _showMedicineInput = true;
//       _tabContent = PrescriptionTab(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//         treatmentId: widget.treatmentId,
//         uhid: widget.uhid,
//         patientName: widget.patientName,
//         doctorName: widget.doctorName,
//         navigateToPrescriptionTab: _navigateToPrescriptionTab,
//       );
//     });
//   }

//   void _navigateToNotesTab() {
//     devtools.log(
//         "This is coming from _navigateToNotesTab function. Navigating to NotesTab");

//     setState(() {
//       _isNotesButtonFocussed = true;
//       _isSummaryButtonFocussed = false;
//       _isPrescriptionButtonFocussed = false;
//       _isMoreButtonFocussed = false;
//       _showMedicineInput = false;

//       _tabContent = NotesTab(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//         treatmentId: widget.treatmentId,
//       );
//     });
//   }

//   void _navigateToMoreTab() {
//     devtools.log(
//         "This is coming from _navigateToMoreTab function. Navigating to MoreTab");

//     setState(() {
//       _isMoreButtonFocussed = true;
//       _isNotesButtonFocussed = false;
//       _isSummaryButtonFocussed = false;
//       _isPrescriptionButtonFocussed = false;
//       _showMedicineInput = false;

//       _tabContent = MoreTab(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//         treatmentId: widget.treatmentId!,
//         doctorId: widget.doctorId,
//         doctorName: widget.doctorName,
//         treatmentData: widget.treatmentData!,
//         patientName: widget.patientName,
//         age: widget.age,
//         gender: widget.gender,
//         patientMobileNumber: widget.patientMobileNumber,
//         patientPicUrl: widget.patientPicUrl,
//         uhid: widget.uhid,
//       );
//     });
//   }

//   // Future<void> _closeTreatment() async {
//   //   devtools.log('_closeTreatment invoked');

//   //   // Capture the current context at the beginning of the method
//   //   final context = this.context;

//   //   try {
//   //     final treatmentRef = FirebaseFirestore.instance
//   //         .collection('clinics')
//   //         .doc(widget.clinicId)
//   //         .collection('patients')
//   //         .doc(widget.patientId)
//   //         .collection('treatments')
//   //         .doc(widget.treatmentId);

//   //     await treatmentRef.update({
//   //       'isTreatmentClose': true,
//   //       'treatmentCloseDate': DateTime.now().toUtc(),
//   //     });

//   //     devtools.log('Treatment ${widget.treatmentId} closed successfully.');
//   //     devtools.log(
//   //         'This is coming from inside _closeTreatment. cache being cleared.');
//   //     _imageCacheProvider.clearPictures();

//   //     if (mounted) {
//   //       setState(() {
//   //         _isLoading = false;
//   //       });

//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Treatment closed successfully')),
//   //       );
//   //     }

//   //     // Use the captured context here for navigation
//   //     Navigator.of(context).pushAndRemoveUntil(
//   //       MaterialPageRoute(
//   //         builder: (context) => TreatmentLandingScreen(
//   //           clinicId: widget.clinicId,
//   //           patientId: widget.patientId,
//   //           doctorId: widget.doctorId,
//   //           doctorName: widget.doctorName,
//   //           patientName: widget.patientName,
//   //           patientMobileNumber: widget.patientMobileNumber,
//   //           age: widget.age,
//   //           gender: widget.gender,
//   //           patientPicUrl: widget.patientPicUrl,
//   //           uhid: widget.uhid,
//   //         ),
//   //       ),
//   //       (route) => false, // This removes all the previous routes
//   //     );
//   //   } catch (e) {
//   //     devtools.log('Error closing treatment: $e');
//   //     if (mounted) {
//   //       setState(() {
//   //         _isLoading = false;
//   //       });

//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text('Error closing treatment: $e')),
//   //       );
//   //     }
//   //   }
//   // }

//   //-------------------------------------------------------------------------------//
//   Future<void> _closeTreatment() async {
//     devtools.log('_closeTreatment invoked');

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final treatmentService = TreatmentService(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//       );

//       // Call the closeTreatment method in TreatmentService
//       await treatmentService.closeTreatment(widget.treatmentId!);

//       devtools.log(
//           'This is coming from inside _closeTreatment. cache being cleared.');
//       _imageCacheProvider.clearPictures();

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Treatment closed successfully')),
//         );

//         // Check if the widget is still mounted before using BuildContext
//         if (mounted) {
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(
//               builder: (context) => TreatmentLandingScreen(
//                 clinicId: widget.clinicId,
//                 patientId: widget.patientId,
//                 doctorId: widget.doctorId,
//                 doctorName: widget.doctorName,
//                 patientName: widget.patientName,
//                 patientMobileNumber: widget.patientMobileNumber,
//                 age: widget.age,
//                 gender: widget.gender,
//                 patientPicUrl: widget.patientPicUrl,
//                 uhid: widget.uhid,
//               ),
//             ),
//             (route) => false, // This removes all the previous routes
//           );
//         }
//       }
//     } catch (e) {
//       devtools.log('Error closing treatment: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error closing treatment: $e')),
//         );
//       }
//     }
//   }

//   //-------------------------------------------------------------------------------//

//   void _showCloseTreatmentConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Close Treatment'),
//           content: const Text('Are you sure you want to close this treatment?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: const Text('CANCEL'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog

//                 _closeTreatment(); // Proceed to close the treatment
//               },
//               child: const Text('CLOSE'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _editTreatmentPlan() {
//     devtools.log("Navigating to Edit Treatment Plan");
//     setState(() {
//       _hasChanges = true;
//     });
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) {
//           final imageCacheProvider =
//               Provider.of<ImageCacheProvider>(context, listen: false);
//           devtools.log(
//               'Before navigating to CreateEditTreatmentScreen2A, imageCacheProvider has pictures: ${imageCacheProvider.pictures}');
//           return StartOrEditTreatment(
//             chiefComplaint: widget.treatmentData?['chiefComplaint'] ?? '',
//             clinicId: widget.clinicId,
//             patientId: widget.patientId,
//             age: widget.age,
//             gender: widget.gender,
//             patientName: widget.patientName,
//             patientMobileNumber: widget.patientMobileNumber,
//             patientPicUrl: widget.patientPicUrl,
//             doctorId: widget.doctorId,
//             doctorName: widget.doctorName,
//             treatmentId: widget.treatmentId,
//             treatmentData: widget.treatmentData,
//             uhid: widget.uhid,
//             originalProcedures: originalProcedures, // Pass originalProcedures
//           );
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _imageCacheProvider.clearPictures(); // Clear the cache
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       onPopInvoked: (willPop) {
//         if (willPop) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             Navigator.pop(
//                 context, _hasChanges); // Indicate whether changes were made
//           });
//         }
//       },
//       child: Stack(
//         children: [
//           Scaffold(
//             appBar: AppBar(
//               backgroundColor:
//                   MyColors.colorPalette['surface-container-lowest'],
//               title: Text(
//                 'Treatment',
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//               iconTheme: IconThemeData(
//                 color: MyColors.colorPalette['on-surface'],
//               ),
//               leading: IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () {
//                   Navigator.of(context).pushAndRemoveUntil(
//                     MaterialPageRoute(
//                       builder: (context) => TreatmentLandingScreen(
//                         clinicId: widget.clinicId,
//                         patientId: widget.patientId,

//                         doctorId: widget.doctorId,
//                         doctorName: widget.doctorName,

//                         patientName: widget.patientName,
//                         patientMobileNumber: widget.patientMobileNumber,
//                         age: widget.age,
//                         gender: widget.gender,
//                         patientPicUrl: widget.patientPicUrl,
//                         uhid: widget.uhid,
//                         // pass any other required parameters here
//                       ),
//                     ),
//                     (route) => false, // This removes all the previous routes
//                   );
//                 },
//               ),
//             ),
//             body: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.only(
//                     left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.only(
//                           left: 16.0, top: 24.0, bottom: 24.0),
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           width: 1,
//                           color: MyColors.colorPalette['outline'] ??
//                               Colors.blueAccent,
//                         ),
//                         borderRadius: BorderRadius.circular(3),
//                       ),
//                       child: Align(
//                         alignment: AlignmentDirectional.topStart,
//                         child: Padding(
//                           padding: const EdgeInsets.all(4),
//                           child: Row(
//                             children: [
//                               CircleAvatar(
//                                 radius: 28,
//                                 backgroundColor:
//                                     MyColors.colorPalette['surface'],
//                                 backgroundImage: widget.patientPicUrl != null &&
//                                         widget.patientPicUrl!.isNotEmpty
//                                     ? NetworkImage(widget.patientPicUrl!)
//                                     : Image.asset(
//                                         'assets/images/default-image.png',
//                                         color: MyColors.colorPalette['primary'],
//                                         colorBlendMode: BlendMode.color,
//                                       ).image,
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       widget.patientName,
//                                       style: MyTextStyle
//                                           .textStyleMap['label-medium']
//                                           ?.copyWith(
//                                               color: MyColors
//                                                   .colorPalette['on-surface']),
//                                     ),
//                                     Row(
//                                       children: [
//                                         Text(
//                                           widget.age.toString(),
//                                           style: MyTextStyle
//                                               .textStyleMap['label-small']
//                                               ?.copyWith(
//                                                   color: MyColors.colorPalette[
//                                                       'on-surface-variant']),
//                                         ),
//                                         Text(
//                                           '/',
//                                           style: MyTextStyle
//                                               .textStyleMap['label-small']
//                                               ?.copyWith(
//                                                   color: MyColors.colorPalette[
//                                                       'on-surface-variant']),
//                                         ),
//                                         Text(
//                                           widget.gender,
//                                           style: MyTextStyle
//                                               .textStyleMap['label-small']
//                                               ?.copyWith(
//                                                   color: MyColors.colorPalette[
//                                                       'on-surface-variant']),
//                                         ),
//                                       ],
//                                     ),
//                                     Text(
//                                       widget.patientMobileNumber,
//                                       style: MyTextStyle
//                                           .textStyleMap['label-small']
//                                           ?.copyWith(
//                                               color: MyColors.colorPalette[
//                                                   'on-surface-variant']),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         _buildTabButton(
//                           label: 'Summary',
//                           isFocussed: _isSummaryButtonFocussed,
//                           onPressed: _navigateToSummaryTab,
//                         ),
//                         const SizedBox(width: 8),
//                         _buildTabButton(
//                           label: 'Prescription',
//                           isFocussed: _isPrescriptionButtonFocussed,
//                           onPressed: _navigateToPrescriptionTab,
//                         ),
//                         const SizedBox(width: 8),
//                         _buildTabButton(
//                           label: 'Notes',
//                           isFocussed: _isNotesButtonFocussed,
//                           onPressed: _navigateToNotesTab,
//                         ),
//                         const SizedBox(width: 8),
//                         _buildTabButton(
//                           label: 'More',
//                           isFocussed: _isMoreButtonFocussed,
//                           onPressed: _navigateToMoreTab,
//                         ),
//                       ],
//                     ),
//                     Visibility(
//                       visible: _isSummaryButtonFocussed ||
//                           _isPrescriptionButtonFocussed ||
//                           _isNotesButtonFocussed ||
//                           _isMoreButtonFocussed,
//                       child: _tabContent,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             bottomNavigationBar: _isSummaryButtonFocussed
//                 ? Container(
//                     decoration: const BoxDecoration(
//                       border: Border.fromBorderSide(
//                         BorderSide(
//                           width: 1.0,
//                           style: BorderStyle.solid,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: ElevatedButton(
//                               onPressed: _editTreatmentPlan,
//                               style: ButtonStyle(
//                                 fixedSize: MaterialStateProperty.all(
//                                     const Size(152, 48)),
//                                 backgroundColor: MaterialStateProperty.all(
//                                     MyColors.colorPalette['on-primary']!),
//                                 shape: MaterialStateProperty.all(
//                                   RoundedRectangleBorder(
//                                     side: BorderSide(
//                                         color:
//                                             MyColors.colorPalette['primary']!,
//                                         width: 1.0),
//                                     borderRadius: BorderRadius.circular(24.0),
//                                   ),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Edit',
//                                 style: MyTextStyle.textStyleMap['label-large']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['primary']),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: ElevatedButton(
//                               onPressed: () =>
//                                   _showCloseTreatmentConfirmation(context),
//                               style: ButtonStyle(
//                                 fixedSize: MaterialStateProperty.all(
//                                     const Size(152, 48)),
//                                 backgroundColor: MaterialStateProperty.all(
//                                     MyColors.colorPalette['primary']),
//                                 shape: MaterialStateProperty.all(
//                                   RoundedRectangleBorder(
//                                     side: BorderSide(
//                                       color: MyColors.colorPalette['primary']!,
//                                       width: 1.0,
//                                     ),
//                                     borderRadius: BorderRadius.circular(24.0),
//                                   ),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Close',
//                                 style: MyTextStyle.textStyleMap['label-large']
//                                     ?.copyWith(
//                                         color: MyColors
//                                             .colorPalette['on-primary']),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 : null,
//           ),
//           if (_isLoading)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black.withOpacity(0.5),
//                 child: const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabButton({
//     required String label,
//     required bool isFocussed,
//     required VoidCallback onPressed,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: isFocussed
//                 ? MyColors.colorPalette['primary'] ?? Colors.blue
//                 : Colors.transparent,
//             width: 1.0,
//           ),
//         ),
//       ),
//       child: TextButton(
//         onPressed: onPressed,
//         style: ButtonStyle(
//           foregroundColor: MaterialStateProperty.resolveWith<Color>(
//             (Set<MaterialState> states) {
//               return isFocussed
//                   ? MyColors.colorPalette['primary'] ?? Colors.blue
//                   : MyColors.colorPalette['on-surface'] ?? Colors.grey;
//             },
//           ),
//           textStyle: MaterialStateProperty.all(
//             MyTextStyle.textStyleMap['label-large'],
//           ),
//         ),
//         child: Text(label),
//       ),
//     );
//   }
// }

