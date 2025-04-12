// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/closed_notes_tab.dart';
// import 'package:neocare_dental_app/mywidgets/closed_more_tab.dart';
// import 'package:neocare_dental_app/mywidgets/closed_prescription_tab.dart';
// //import 'package:neocare_dental_app/mywidgets/closed_render_treatment_data.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'dart:developer' as devtools show log;

// class ClosedTreatmentSummaryScreen extends StatefulWidget {
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

//   const ClosedTreatmentSummaryScreen({
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
//   State<ClosedTreatmentSummaryScreen> createState() =>
//       _ClosedTreatmentSummaryScreenState();
// }

// class _ClosedTreatmentSummaryScreenState
//     extends State<ClosedTreatmentSummaryScreen> {
//   bool _isSummaryButtonFocussed = true;
//   bool _isPrescriptionButtonFocussed = false;
//   bool _isNotesButtonFocussed = false;
//   bool _isMoreButtonFocussed = false;
//   Widget _tabContent = const SizedBox();

//   @override
//   void initState() {
//     super.initState();
//     _updateTabContent();
//   }

//   void _updateTabContent() {
//     _tabContent = SingleChildScrollView(
//       child: Column(
//         children: [
//           ClosedRenderTreatmentData(
//             treatmentData: widget.treatmentData,
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateToSummaryTab() {
//     setState(() {
//       _isSummaryButtonFocussed = true;
//       _isPrescriptionButtonFocussed = false;
//       _isNotesButtonFocussed = false;
//       _isMoreButtonFocussed = false;
//       _updateTabContent();
//     });
//   }

//   void _navigateToClosedPrescriptionTab() {
//     setState(() {
//       _isPrescriptionButtonFocussed = true;
//       _isSummaryButtonFocussed = false;
//       _isNotesButtonFocussed = false;
//       _isMoreButtonFocussed = false;

//       _tabContent = ClosedPrescriptionTab(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//         treatmentId: widget.treatmentId,
//         uhid: widget.uhid,
//         patientName: widget.patientName,
//         doctorName: widget.doctorName,
//       );
//     });
//   }

//   void _navigateToClosedNotesTab() {
//     setState(() {
//       _isNotesButtonFocussed = true;
//       _isSummaryButtonFocussed = false;
//       _isPrescriptionButtonFocussed = false;
//       _isMoreButtonFocussed = false;

//       _tabContent = ClosedNotesTab(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//         treatmentId: widget.treatmentId,
//       );
//     });
//   }

//   void _navigateToClosedMoreTab() {
//     setState(() {
//       _isMoreButtonFocussed = true;
//       _isNotesButtonFocussed = false;
//       _isSummaryButtonFocussed = false;
//       _isPrescriptionButtonFocussed = false;

//       _tabContent = ClosedMoreTab(
//         clinicId: widget.clinicId,
//         patientId: widget.patientId,
//         treatmentId: widget.treatmentId!,
//         doctorId: widget.doctorId,
//         doctorName: widget.doctorName,
//         patientName: widget.patientName,
//         age: widget.age,
//         gender: widget.gender,
//         patientMobileNumber: widget.patientMobileNumber,
//         patientPicUrl: widget.patientPicUrl,
//         uhid: widget.uhid,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Closed Treatment',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         iconTheme: IconThemeData(
//           color: MyColors.colorPalette['on-surface'],
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pushAndRemoveUntil(
//               MaterialPageRoute(
//                 builder: (context) => TreatmentLandingScreen(
//                   clinicId: widget.clinicId,
//                   patientId: widget.patientId,
//                   doctorId: widget.doctorId,
//                   doctorName: widget.doctorName,
//                   patientName: widget.patientName,
//                   patientMobileNumber: widget.patientMobileNumber,
//                   age: widget.age,
//                   gender: widget.gender,
//                   patientPicUrl: widget.patientPicUrl,
//                   uhid: widget.uhid,
//                 ),
//               ),
//               (route) => false, // Removes all the previous routes
//             );
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   _buildTabButton(
//                     label: 'Summary',
//                     isFocussed: _isSummaryButtonFocussed,
//                     onPressed: _navigateToSummaryTab,
//                   ),
//                   const SizedBox(width: 8),
//                   _buildTabButton(
//                     label: 'Prescription',
//                     isFocussed: _isPrescriptionButtonFocussed,
//                     onPressed: _navigateToClosedPrescriptionTab,
//                   ),
//                   const SizedBox(width: 8),
//                   _buildTabButton(
//                     label: 'Notes',
//                     isFocussed: _isNotesButtonFocussed,
//                     onPressed: _navigateToClosedNotesTab,
//                   ),
//                   const SizedBox(width: 8),
//                   _buildTabButton(
//                     label: 'More',
//                     isFocussed: _isMoreButtonFocussed,
//                     onPressed: _navigateToClosedMoreTab,
//                   ),
//                 ],
//               ),
//               _tabContent,
//             ],
//           ),
//         ),
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

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:neocaresmileapp/mywidgets/full_screen_image_dialog.dart';
import 'package:neocaresmileapp/mywidgets/closed_more_tab.dart';
import 'package:neocaresmileapp/mywidgets/closed_notes_tab.dart';
import 'package:neocaresmileapp/mywidgets/closed_prescription_tab.dart';

import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/render_closed_treatment_data.dart';

import 'package:neocaresmileapp/mywidgets/image_cache_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

class ClosedTreatmentSummaryScreen extends StatefulWidget {
  final String clinicId;
  final String patientId;
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

  const ClosedTreatmentSummaryScreen({
    super.key,
    required this.clinicId,
    required this.patientId,
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
  State<ClosedTreatmentSummaryScreen> createState() =>
      _ClosedTreatmentSummaryScreenState();
}

class _ClosedTreatmentSummaryScreenState
    extends State<ClosedTreatmentSummaryScreen> {
  bool _isSummaryButtonFocussed = true;
  bool _isPrescriptionButtonFocussed = false;
  bool _isNotesButtonFocussed = false;
  bool _isMoreButtonFocussed = false;
  Widget _tabContent = const SizedBox();
  bool _showMedicineInput = false;
  List<Map<String, dynamic>> pictureData = [];
  bool _isLoading = false;
  late ImageCacheProvider _imageCacheProvider;

  @override
  void initState() {
    super.initState();
    _imageCacheProvider =
        Provider.of<ImageCacheProvider>(context, listen: false);
    _fetchClosedPictures(_imageCacheProvider);
    _updateTabContent();
    _showMedicineInput = false;
  }

  Future<void> _fetchClosedPictures(
      ImageCacheProvider imageCacheProvider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .collection('patients')
          .doc(widget.patientId)
          .collection('treatments')
          .doc(widget.treatmentId)
          .collection('pictures')
          .get();

      imageCacheProvider.clearPictures();

      for (var doc in snapshot.docs) {
        var picture = doc.data() as Map<String, dynamic>;
        picture['isExisting'] = true;
        picture['docId'] = doc.id;

        bool added = await _addPictureToCache(imageCacheProvider, picture);
        if (!added) {
          devtools
              .log('Failed to add picture with docId ${doc.id} to the cache.');
        }
      }

      devtools.log(
          'After fetching pictures, imageCacheProvider has pictures: ${imageCacheProvider.pictures}');

      if (mounted) {
        setState(() {
          pictureData = imageCacheProvider.pictures;
          _isLoading = false;
          _updateTabContent();
        });
      }

      if (imageCacheProvider.pictures.isNotEmpty) {
        devtools.log(
            'This is coming from inside _fetchClosedPictures defined inside ClosedTreatmentSummaryScreen. imageCacheProvider is populated with existing pictures.');
      }
    } catch (e) {
      devtools.log('Error fetching pictures: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
      final file = File(filePath);

      if (await file.exists()) {
        return file.path;
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
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
          RenderClosedTreatmentData(
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
                      context,
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

  void _showFullImage(
      BuildContext context, String imageUrl, String? note, List<String> tags) {
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

  // void _navigateToClosedPrescriptionTab() {
  //   setState(() {
  //     _isPrescriptionButtonFocussed = true;
  //     _isSummaryButtonFocussed = false;
  //     _isNotesButtonFocussed = false;
  //     _isMoreButtonFocussed = false;
  //     _showMedicineInput = true;
  //     _tabContent = ClosedPrescriptionTab(
  //       clinicId: widget.clinicId,
  //       patientId: widget.patientId,
  //       treatmentId: widget.treatmentId,
  //     );
  //   });
  // }
  void _navigateToClosedPrescriptionTab() {
    setState(() {
      _isPrescriptionButtonFocussed = true;
      _isSummaryButtonFocussed = false;
      _isNotesButtonFocussed = false;
      _isMoreButtonFocussed = false;
      _showMedicineInput = true;
      _tabContent = ClosedPrescriptionTab(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
        treatmentId: widget.treatmentId,
        navigateToPrescriptionTab:
            _navigateToClosedPrescriptionTab, // Add this line
      );
    });
  }

  void _navigateToClosedNotesTab() {
    devtools.log(
        "This is coming from _navigateToNotesTab function. Navigating to NotesTab");

    setState(() {
      _isNotesButtonFocussed = true;
      _isSummaryButtonFocussed = false;
      _isPrescriptionButtonFocussed = false;
      _isMoreButtonFocussed = false;
      _showMedicineInput = false;

      _tabContent = ClosedNotesTab(
        clinicId: widget.clinicId,
        patientId: widget.patientId,
        treatmentId: widget.treatmentId,
      );
    });
  }

  void _navigateToClosedMoreTab() {
    devtools.log(
        "This is coming from _navigateToMoreTab function. Navigating to MoreTab");

    setState(() {
      _isMoreButtonFocussed = true;
      _isNotesButtonFocussed = false;
      _isSummaryButtonFocussed = false;
      _isPrescriptionButtonFocussed = false;
      _showMedicineInput = false;

      _tabContent = ClosedMoreTab(
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

  @override
  void dispose() {
    _imageCacheProvider.clearPictures(); // Clear the cache
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Closed Treatment',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        iconTheme: IconThemeData(
          color: MyColors.colorPalette['on-surface'],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
                      child: Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    MyColors.colorPalette['surface'],
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
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabButton(
                        label: 'Summary',
                        isFocussed: _isSummaryButtonFocussed,
                        onPressed: _navigateToSummaryTab,
                      ),
                      _buildTabButton(
                        label: 'Prescription',
                        isFocussed: _isPrescriptionButtonFocussed,
                        onPressed: _navigateToClosedPrescriptionTab,
                      ),
                      _buildTabButton(
                        label: 'Notes',
                        isFocussed: _isNotesButtonFocussed,
                        onPressed: _navigateToClosedNotesTab,
                      ),
                      _buildTabButton(
                        label: 'More',
                        isFocussed: _isMoreButtonFocussed,
                        onPressed: _navigateToClosedMoreTab,
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
        ],
      ),
    );
  }

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
        ),
        child: Text(label),
      ),
    );
  }
}
