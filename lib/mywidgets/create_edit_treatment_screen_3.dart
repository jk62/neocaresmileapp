import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neocaresmileapp/firestore/treatment_service.dart';
import 'package:neocaresmileapp/mywidgets/create_edit_treatment_screen_3a.dart';
import 'package:neocaresmileapp/mywidgets/my_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/full_screen_note_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as devtools show log;
import 'user_data_provider.dart';
import 'image_cache_provider.dart';

class CreateEditTreatmentScreen3 extends StatefulWidget {
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

  final ImageCacheProvider imageCacheProvider;
  final String? chiefComplaint;

  const CreateEditTreatmentScreen3({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.patientId,
    required this.age,
    required this.gender,
    required this.patientName,
    required this.patientMobileNumber,
    required this.patientPicUrl,
    required this.pageController,
    required this.userData,
    required this.doctorName,
    required this.uhid,
    required this.treatmentData,
    required this.treatmentId,
    required this.isEditMode,
    required this.originalProcedures,
    required this.currentProcedures,
    required this.imageCacheProvider,
    required this.chiefComplaint,
  });

  @override
  State<CreateEditTreatmentScreen3> createState() =>
      _CreateEditTreatmentScreen3State();
}

class _CreateEditTreatmentScreen3State
    extends State<CreateEditTreatmentScreen3> {
  final ImagePicker _picker = ImagePicker();
  bool isEditMode = false;
  List<Map<String, dynamic>>? pictureData11 = [];
  Set<String> deletedPictureIds = {};
  late TreatmentService _treatmentService;

  @override
  void initState() {
    super.initState();
    final imageCacheProvider =
        Provider.of<ImageCacheProvider>(context, listen: false);
    devtools.log(
        'This is coming from inside  CreateEditTreatmentScreen3 initState, imageCacheProvider has pictures: ${imageCacheProvider.pictures}');
    _treatmentService = TreatmentService(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
    );
    _loadExistingPictures();
  }

  @override
  void dispose() {
    widget.userData.savePictures(widget.imageCacheProvider.pictures);
    super.dispose();
  }

  // Future<void> _loadExistingPictures() async {
  //   final imageCacheProvider =
  //       Provider.of<ImageCacheProvider>(context, listen: false);
  //   if (imageCacheProvider.pictures.isNotEmpty) {
  //     devtools.log(
  //         'Cache is already populated with pictures: ${imageCacheProvider.pictures}, skipping reload.');
  //     return;
  //   }

  //   if (widget.treatmentId != null) {
  //     devtools.log(
  //         'Existing pictures not found in the cache. Being downloaded from backend');
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection('clinics')
  //         .doc(widget.clinicId)
  //         .collection('patients')
  //         .doc(widget.patientId)
  //         .collection('treatments')
  //         .doc(widget.treatmentId)
  //         .collection('pictures')
  //         .get();

  //     imageCacheProvider.clearPictures();

  //     for (var doc in snapshot.docs) {
  //       final data = doc.data();
  //       data['tags'] = List<String>.from(data['tags'] ?? []);
  //       data['isExisting'] = true;
  //       data['docId'] = doc.id;
  //       imageCacheProvider.addPicture(data);
  //     }
  //     devtools.log(
  //         'After fetching from backend, imageCacheProvider has pictures: ${imageCacheProvider.pictures}');
  //   } else {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       imageCacheProvider.clearPictures();
  //     });
  //   }
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }
  //--------------------------------------------------------------------//
  Future<void> _loadExistingPictures() async {
    if (widget.treatmentId != null) {
      devtools.log('Fetching pictures from backend...');

      final pictures =
          await _treatmentService.fetchPictures(widget.treatmentId!);

      widget.imageCacheProvider.clearPictures();

      for (var picture in pictures) {
        widget.imageCacheProvider.addPicture(picture);
      }

      devtools.log(
          'Pictures after fetching from backend: ${widget.imageCacheProvider.pictures}');

      if (mounted) {
        setState(() {});
      }
    }
  }
  //--------------------------------------------------------------------//

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      // Check if the widget is still mounted before using the context
      if (!mounted) return;

      // Navigate to the FullScreenNoteDialog and capture the result
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => FullScreenNoteDialog(
            imageFile: image,
            noteController: TextEditingController(),
            imageCacheProvider:
                widget.imageCacheProvider, // Pass imageCacheProvider
            userData: widget.userData, // Pass userData
          ),
        ),
      );

      // Access the result after the navigation
      if (result != null) {
        final String? note = result['note'];
        final List<String>? tags = result['tags'];
        final String? localPath = result['localPath'];

        // Create the picture data
        final Map<String, dynamic> pictureData = {
          'localPath': localPath,
          'picId': const Uuid().v4(),
          'isUploading':
              true, // Initially set to true as it will be uploaded in background
          'note': note ?? '',
          'tags': tags ?? [],
          'picUrl': null, // This will be updated when the image is uploaded
          'isExisting': false, // Indicates that the picture is not yet uploaded
        };

        // Add the image data to the cache
        widget.imageCacheProvider.addPicture(pictureData);
        widget.userData.savePictures(
            widget.imageCacheProvider.pictures, 'from _pickImage');

        // Start the background upload process
        _uploadImageInBackground(image, pictureData['picId']);

        // Update the UI
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  // -------------------------------------------------------------------------- //

  // -------------------------------------------------------------------------- //

  Future<void> _uploadImageInBackground(XFile image, String picId) async {
    // Simulate an upload delay
    await Future.delayed(const Duration(seconds: 2));

    // Update the picture data in the cache to mark as not uploading
    final updatedPicture = widget.imageCacheProvider.pictures
        .firstWhere((picture) => picture['picId'] == picId);
    updatedPicture['isUploading'] = false;

    widget.imageCacheProvider.updatePicture(picId, updatedPicture);
    widget.userData.savePictures(
        widget.imageCacheProvider.pictures, 'from _uploadImageInBackground');

    // Update the UI to reflect the new state
    if (mounted) {
      setState(() {});
    }
  }

  // Future<void> _deletePicture(Map<String, dynamic> picture) async {
  //   final String picId = picture['picId'];
  //   final String? docId = picture['docId'];
  //   devtools.log(
  //       '!!! This is coming from inside _deletePicture defined inside CreateEditTreatmentScreen3. picId of picture to be deleted is $picId');
  //   devtools.log(
  //       '!!! This is coming from inside _deletePicture defined inside CreateEditTreatmentScreen3. docId of picture to be deleted is $docId');

  //   try {
  //     // If picture URL is available, delete the picture from Firebase Storage
  //     if (picture['picUrl'] != null) {
  //       final String picUrl = picture['picUrl'];
  //       final Reference storageRef =
  //           FirebaseStorage.instance.refFromURL(picUrl);
  //       await storageRef.delete();
  //       devtools.log('Image deleted from Firebase Storage');
  //     }

  //     // If document ID is available, delete the Firestore document
  //     if (docId != null) {
  //       await FirebaseFirestore.instance
  //           .collection('clinics')
  //           .doc(widget.clinicId)
  //           .collection('patients')
  //           .doc(widget.patientId)
  //           .collection('treatments')
  //           .doc(widget.treatmentId)
  //           .collection('pictures')
  //           .doc(docId)
  //           .delete();
  //       devtools.log('Picture document deleted from Firestore');
  //     }
  //   } catch (e) {
  //     devtools.log('Error deleting image or document: $e');
  //   }

  //   // Remove the picture from the cache
  //   widget.imageCacheProvider.removePicture(picId);
  //   deletedPictureIds.add(picId);
  //   if (docId != null) {
  //     widget.imageCacheProvider.addDeletedPictureDocId(docId);
  //   }

  //   devtools.log(
  //       'imageCacheProvider.pictures after removing picture is populated with ${widget.imageCacheProvider.pictures}');

  //   widget.userData.savePictures(widget.imageCacheProvider.pictures);

  //   if (mounted) {
  //     setState(() {});
  //   }
  // }
  //-------------------------------------------------------------------//
  Future<void> _deletePicture(Map<String, dynamic> picture) async {
    final String picId = picture['picId'];
    final String? docId = picture['docId'];

    try {
      await _treatmentService.deletePicture(picture, widget.treatmentId!);

      // Remove the picture from cache after deleting from backend
      widget.imageCacheProvider.removePicture(picId);
      deletedPictureIds.add(picId);

      if (docId != null) {
        widget.imageCacheProvider.addDeletedPictureDocId(docId);
      }

      widget.userData.savePictures(widget.imageCacheProvider.pictures);

      devtools.log(
          'Pictures after deletion: ${widget.imageCacheProvider.pictures}');

      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      devtools.log('Error deleting picture: $error');
    }
  }
  //-------------------------------------------------------------------//

  void _showImagePickerOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Image"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text("Cancel"),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullImage(Map<String, dynamic> picture) async {
    // Use local path if it exists, otherwise use the image URL
    final String? imageUrl = picture['localPath'] ?? picture['picUrl'];
    devtools.log(
        'This is coming from inside _showFullImage defined inside CreateEditTreatmentScreen3.localPath or imageUrl being passed is $imageUrl');

    // Check if file exists
    if (picture['localPath'] != null &&
        !File(picture['localPath']).existsSync()) {
      devtools.log('File at ${picture['localPath']} does not exist');
    }

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => FullScreenNoteDialog(
          imageUrl: imageUrl,
          note: picture['note'],
          noteController: TextEditingController(text: picture['note']),
          isEditMode: true,
          existingTags: picture['tags']?.cast<String>(),
          picture: picture, // Pass the picture data
          imageCacheProvider:
              widget.imageCacheProvider, // Pass imageCacheProvider
          userData: widget.userData, // Pass userData
        ),
      ),
    );

    if (result != null) {
      final String? updatedNote = result['note'];
      final List<String>? updatedTags = result['tags'];
      final String? updatedPicUrl = result['picUrl'];
      final String? updatedLocalPath = result['localPath'];
      final String? updatedDocId = result['docId'];

      if (updatedNote != null ||
          updatedTags != null ||
          updatedPicUrl != null ||
          updatedLocalPath != null) {
        picture['note'] = updatedNote;
        picture['tags'] = updatedTags;
        picture['picUrl'] = updatedPicUrl;
        picture['localPath'] = updatedLocalPath;
        picture['isEdited'] = true; // Add the isEdited flag
        picture['docId'] = updatedDocId;

        widget.imageCacheProvider.updatePicture(picture['picId'], picture);
        widget.userData.savePictures(widget.imageCacheProvider.pictures);

        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    devtools.log(
        'Welcome to build widget of CreateEditTreatmentScreen3. userData is ${widget.userData}');
    devtools.log(
        'This is coming from inside build widget of CreateEditTreatmentScreen3. originalProcedures are ${widget.originalProcedures}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          widget.isEditMode ? 'Edit Treatment' : 'Create Treatment',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        iconTheme: IconThemeData(
          color: MyColors.colorPalette['on-surface'],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: MyColors.colorPalette['outline'] ?? Colors.blueAccent,
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
                              style: MyTextStyle.textStyleMap['label-medium']
                                  ?.copyWith(
                                      color:
                                          MyColors.colorPalette['on-surface']),
                            ),
                            Row(
                              children: [
                                Text(
                                  widget.age.toString(),
                                  style: MyTextStyle.textStyleMap['label-small']
                                      ?.copyWith(
                                          color: MyColors.colorPalette[
                                              'on-surface-variant']),
                                ),
                                Text(
                                  '/',
                                  style: MyTextStyle.textStyleMap['label-small']
                                      ?.copyWith(
                                          color: MyColors.colorPalette[
                                              'on-surface-variant']),
                                ),
                                Text(
                                  widget.gender,
                                  style: MyTextStyle.textStyleMap['label-small']
                                      ?.copyWith(
                                          color: MyColors.colorPalette[
                                              'on-surface-variant']),
                                ),
                              ],
                            ),
                            Text(
                              widget.patientMobileNumber,
                              style: MyTextStyle.textStyleMap['label-small']
                                  ?.copyWith(
                                      color: MyColors
                                          .colorPalette['on-surface-variant']),
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
              alignment: Alignment.topLeft,
              child: Text(
                'Images ',
                style: MyTextStyle.textStyleMap['title-large']
                    ?.copyWith(color: MyColors.colorPalette['on-surface']),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                itemCount: widget.imageCacheProvider.pictures.length + 1,
                itemBuilder: (context, index) {
                  if (index == widget.imageCacheProvider.pictures.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: 144,
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
                            onPressed: _showImagePickerOptions,
                            child: Wrap(
                              children: [
                                Icon(
                                  Icons.add,
                                  color: MyColors.colorPalette['primary'],
                                ),
                                Text(
                                  'Add ',
                                  style: MyTextStyle.textStyleMap['label-large']
                                      ?.copyWith(
                                          color:
                                              MyColors.colorPalette['primary']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  final picture = widget.imageCacheProvider.pictures[index];
                  return GestureDetector(
                    onLongPress: () async {
                      final confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Delete Image"),
                            content: const Text(
                                "Are you sure you want to delete this image?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        await _deletePicture(picture);
                      }
                    },
                    onTap: () => _showFullImage(picture),
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
                            child: picture['localPath'] != null
                                ? Image.file(
                                    File(picture['localPath']),
                                    fit: BoxFit.contain,
                                  )
                                : picture['picUrl'] != null
                                    ? CachedNetworkImage(
                                        imageUrl: picture['picUrl']!,
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        fit: BoxFit.contain,
                                      )
                                    : const Icon(Icons.error),
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
                                      height: 16.0,
                                    ),
                                    Wrap(
                                      spacing: 8.0,
                                      children: picture['tags'] != null
                                          ? (picture['tags'] as List<dynamic>)
                                              .map<String>(
                                                  (tag) => tag.toString())
                                              .map<Widget>(
                                                (tag) => Chip(
                                                  label: Text(
                                                    tag,
                                                    style: MyTextStyle
                                                        .textStyleMap[
                                                            'label-small']
                                                        ?.copyWith(
                                                      color:
                                                          MyColors.colorPalette[
                                                              'on-primary'],
                                                    ),
                                                  ),
                                                  backgroundColor: MyColors
                                                      .colorPalette['primary'],
                                                  shape: RoundedRectangleBorder(
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
                                                ),
                                              )
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
                  );
                },
              ),
            )
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
        currentIndex: 2,
        nextIconSelectable: true,
        onTap: (int navIndex) {
          if (navIndex == 0) {
            Navigator.of(context).pop();
          } else if (navIndex == 3) {
            devtools.log('@@@@@@@@@@@@@@@@@@@@@@@@@');
            widget.userData.savePictures(widget.imageCacheProvider.pictures);

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CreateEditTreatmentScreen3A(
                  clinicId: widget.clinicId,
                  doctorId: widget.doctorId,
                  patientId: widget.patientId,
                  age: widget.age,
                  gender: widget.gender,
                  patientName: widget.patientName,
                  patientMobileNumber: widget.patientMobileNumber,
                  patientPicUrl: widget.patientPicUrl,
                  pageController: widget.pageController,
                  userData: widget.userData,
                  doctorName: widget.doctorName,
                  uhid: widget.uhid,
                  treatmentData: widget.treatmentData,
                  treatmentId: widget.treatmentId,
                  isEditMode: widget.isEditMode,
                  originalProcedures: widget.originalProcedures,
                  currentProcedures: widget.currentProcedures,
                  pictureData11: widget.imageCacheProvider.pictures,
                  imageCacheProvider: widget.imageCacheProvider,
                  chiefComplaint: widget.chiefComplaint,
                ),
                settings:
                    const RouteSettings(name: 'CreateEditTreatmentScreen3A'),
              ),
            );
          }
        },
      ),
    );
  }
}
