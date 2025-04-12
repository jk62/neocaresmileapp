import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/image_cache_provider.dart';
import 'package:neocaresmileapp/mywidgets/user_data_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'mycolors.dart';
import 'mytextstyle.dart';
import 'dart:developer' as devtools show log;

class FullScreenNoteDialog extends StatefulWidget {
  final XFile? imageFile;
  final TextEditingController noteController;
  final String? imageUrl;
  final String? note;
  final bool isEditMode;
  final List<String>? existingTags;
  final Map<String, dynamic>? picture;
  final ImageCacheProvider imageCacheProvider;
  final UserDataProvider userData;

  const FullScreenNoteDialog({
    super.key,
    this.imageFile,
    required this.noteController,
    this.imageUrl,
    this.note,
    this.isEditMode = false,
    this.existingTags,
    this.picture,
    required this.imageCacheProvider,
    required this.userData,
  });

  @override
  State<FullScreenNoteDialog> createState() => _FullScreenNoteDialogState();
}

class _FullScreenNoteDialogState extends State<FullScreenNoteDialog> {
  final ImagePicker _picker = ImagePicker();
  bool isImageSelected = false;
  bool isXraySelected = false;
  bool isExpanded = false;
  bool isLoading = true;
  String? picUrl;
  String? localPath;
  Map<String, dynamic>? pictureData;

  @override
  void initState() {
    super.initState();
    if (widget.imageFile != null) {
      localPath = widget.imageFile!.path;
      _setPictureData(widget.imageFile!);
    } else {
      localPath = widget.picture?['localPath'];
      picUrl = widget.imageUrl;
    }
    _initializeTags();
    setState(() {
      isLoading = false;
    });
  }

  void _initializeTags() {
    if (widget.existingTags != null) {
      setState(() {
        isImageSelected = widget.existingTags!.contains('Image');
        isXraySelected = widget.existingTags!.contains('X-ray');
      });
    }
  }

  void togglePanel() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  List<String> getSelectedTags() {
    List<String> tags = [];
    if (isImageSelected) tags.add('Image');
    if (isXraySelected) tags.add('X-ray');
    return tags;
  }

  Future<void> _setPictureData(XFile newImage) async {
    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final String fileName = newImage.name;
    final String filePath = '${directory.path}/$fileName';
    devtools.log(
        '!!!!!!!!!!! This is coming from inside _setPictureData defined inside FullScreenNoteDialog. filePath is $filePath');

    // Save the image to the application documents directory
    final File newImageFile = File(filePath);
    await File(newImage.path).copy(newImageFile.path);
    devtools.log(
        '!!!!!!!!!!! This is coming from inside _setPictureData defined inside FullScreenNoteDialog. newImageFile is $newImageFile');

    setState(() {
      localPath = filePath;
      devtools.log(
          '!!!!!!!!!!! This is coming from  setState inside _setPictureData defined inside FullScreenNoteDialog. localPath is $localPath');
    });

    pictureData = {
      'localPath': filePath, // Update localPath to the persistent storage path
      'picId': widget.picture?['picId'] ?? const Uuid().v4(),
      'isUploading': false,
      'note': widget.noteController.text,
      'tags': getSelectedTags(),
      'picUrl': null,
      'isExisting': true,
      'isEdited': true,
      'docId': null,
    };
  }

  Future<void> _chooseImageSource() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final XFile? newImage =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (newImage != null) {
                  await _setPictureData(
                      newImage); // Save the image to persistent storage
                }
              },
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final XFile? newImage =
                    await _picker.pickImage(source: ImageSource.camera);
                if (newImage != null) {
                  await _setPictureData(
                      newImage); // Save the image to persistent storage
                }
              },
              child: const Text('Camera'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        iconTheme: IconThemeData(
          color: MyColors.colorPalette['on-surface'],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop({
              'note': widget.noteController.text,
              'tags': getSelectedTags(),
              'picUrl': picUrl,
              'localPath': localPath, // Ensure localPath is returned
              'isEdited':
                  widget.isEditMode, // Indicate if the picture is edited
              'docId': widget.picture?['docId'],
            });
          },
          color: MyColors.colorPalette['on-surface'],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (localPath != null || picUrl != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              backgroundColor: MyColors
                                  .colorPalette['surface-container-lowest'],
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
                            body: Center(
                              child: PhotoView(
                                imageProvider: localPath != null
                                    ? FileImage(File(localPath!))
                                        as ImageProvider<Object>
                                    : CachedNetworkImageProvider(picUrl!)
                                        as ImageProvider<Object>,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: localPath != null
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height / 3,
                          child: Image.file(
                            File(localPath!),
                            fit: BoxFit.contain,
                          ),
                        )
                      : picUrl != null
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height / 3,
                              child: CachedNetworkImage(
                                imageUrl: picUrl!,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                fit: BoxFit.contain,
                              ),
                            )
                          : Container(
                              color: Colors.grey,
                              height: MediaQuery.of(context).size.height / 2,
                              width: double.infinity,
                              child:
                                  const Icon(Icons.image, color: Colors.white),
                            ),
                ),
              ),
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: isLoading ? null : _chooseImageSource,
                  color: MyColors.colorPalette['primary'],
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Details',
                style: MyTextStyle.textStyleMap['title-medium']
                    ?.copyWith(color: MyColors.colorPalette['secondary']),
              ),
              const SizedBox(height: 8.0),
              if (!isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: MyColors.colorPalette['outline'] ?? Colors.grey,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        'Select Tag(s)',
                        style: MyTextStyle.textStyleMap['title-medium']
                            ?.copyWith(
                                color: MyColors.colorPalette['secondary']),
                      ),
                      trailing: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: MyColors.colorPalette['secondary'],
                      ),
                      onTap: togglePanel,
                    ),
                  ),
                ),
              if (isExpanded)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color:
                          MyColors.colorPalette['outline'] ?? Colors.blueAccent,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        value: isImageSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            isImageSelected = value ?? false;
                          });
                        },
                        title: Text(
                          'Image',
                          style: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors.colorPalette['secondary']),
                        ),
                        activeColor: MyColors.colorPalette['primary'],
                      ),
                      CheckboxListTile(
                        value: isXraySelected,
                        onChanged: (bool? value) {
                          setState(() {
                            isXraySelected = value ?? false;
                          });
                        },
                        title: Text(
                          'X-ray',
                          style: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors.colorPalette['secondary']),
                        ),
                        activeColor: MyColors.colorPalette['primary'],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              isExpanded = false;
                            });
                          },
                          child: Text(
                            'OK',
                            style: MyTextStyle.textStyleMap['label-large']
                                ?.copyWith(
                                    color: MyColors.colorPalette['primary']),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8.0),
              if (!isExpanded)
                Wrap(
                  spacing: 8.0,
                  children: getSelectedTags()
                      .map((label) => Chip(
                            label: Text(
                              label,
                              style: MyTextStyle.textStyleMap['label-small']
                                  ?.copyWith(
                                      color:
                                          MyColors.colorPalette['on-primary']),
                            ),
                            backgroundColor: MyColors.colorPalette['primary'],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            visualDensity: const VisualDensity(
                                horizontal: 0.0, vertical: -4.0),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: TextFormField(
                  controller: widget.noteController,
                  minLines: 4,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    labelStyle: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(
                            color: MyColors.colorPalette['on-surface-variant']),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(
                        color: MyColors.colorPalette['outline'] ?? Colors.black,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(
                        color: MyColors.colorPalette['on-surface-variant'] ??
                            Colors.black,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(8.0),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                      MyColors.colorPalette['primary']!.withOpacity(0.1),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop({
                            'note': widget.noteController.text,
                            'tags': getSelectedTags(),
                            'picUrl': picUrl,
                            'localPath': localPath,
                            'isEdited': widget
                                .isEditMode, // Indicate if the picture is edited
                            'docId': widget.picture?['docId'],
                          });
                          devtools.log(
                              'This is coming from inside FullScreenNoteDialog. localPath being passed back on pressing Add or Save is $localPath');
                        },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      isLoading
                          ? Colors.grey
                          : MyColors.colorPalette['primary'],
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                  child: Text(
                    widget.isEditMode ? 'Save' : 'Add',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['on-primary']),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW WITH REDUNDANT replaceImage
// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/image_cache_provider.dart';
// import 'package:neocare_dental_app/mywidgets/user_data_provider.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';
// import 'mycolors.dart';
// import 'mytextstyle.dart';
// import 'dart:developer' as devtools show log;

// class FullScreenNoteDialog extends StatefulWidget {
//   final XFile? imageFile;
//   final TextEditingController noteController;
//   final String? imageUrl;
//   final String? note;
//   final bool isEditMode;
//   final List<String>? existingTags;
//   final Map<String, dynamic>? picture;
//   final ImageCacheProvider imageCacheProvider;
//   final UserDataProvider userData;

//   const FullScreenNoteDialog({
//     super.key,
//     this.imageFile,
//     required this.noteController,
//     this.imageUrl,
//     this.note,
//     this.isEditMode = false,
//     this.existingTags,
//     this.picture,
//     required this.imageCacheProvider,
//     required this.userData,
//   });

//   @override
//   State<FullScreenNoteDialog> createState() => _FullScreenNoteDialogState();
// }

// class _FullScreenNoteDialogState extends State<FullScreenNoteDialog> {
//   final ImagePicker _picker = ImagePicker();
//   bool isImageSelected = false;
//   bool isXraySelected = false;
//   bool isExpanded = false;
//   bool isLoading = true;
//   String? picUrl;
//   String? localPath;
//   Map<String, dynamic>? pictureData;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.imageFile != null) {
//       localPath = widget.imageFile!.path;
//       _setPictureData(widget.imageFile!);
//     } else {
//       localPath = widget.picture?['localPath'];
//       picUrl = widget.imageUrl;
//     }
//     _initializeTags();
//     setState(() {
//       isLoading = false;
//     });
//   }

//   void _initializeTags() {
//     if (widget.existingTags != null) {
//       setState(() {
//         isImageSelected = widget.existingTags!.contains('Image');
//         isXraySelected = widget.existingTags!.contains('X-ray');
//       });
//     }
//   }

//   void togglePanel() {
//     setState(() {
//       isExpanded = !isExpanded;
//     });
//   }

//   List<String> getSelectedTags() {
//     List<String> tags = [];
//     if (isImageSelected) tags.add('Image');
//     if (isXraySelected) tags.add('X-ray');
//     return tags;
//   }

//   void _setPictureData(XFile newImage) {
//     pictureData = {
//       'localPath': newImage.path,
//       'picId': widget.picture?['picId'] ?? const Uuid().v4(),
//       'isUploading': false,
//       'note': widget.noteController.text,
//       'tags': getSelectedTags(),
//       'picUrl': null,
//       'isExisting': true,
//       'isEdited': true,
//       'docId': null,
//     };
//   }

//   // Future<void> _setPictureData(XFile newImage) async {
//   //   // Clear existing picture from the cache
//   //   //widget.imageCacheProvider.clearPictures();

//   //   // Get the application documents directory
//   //   final directory = await getApplicationDocumentsDirectory();
//   //   final String fileName = newImage.name;
//   //   final String filePath = '${directory.path}/$fileName';

//   //   // Save the image to the application documents directory
//   //   final File newImageFile = File(newImage.path);
//   //   await newImageFile.copy(filePath);

//   //   pictureData = {
//   //     'localPath': filePath, // Update localPath to the persistent storage path
//   //     'picId': widget.picture?['picId'] ?? const Uuid().v4(),
//   //     'isUploading': false,
//   //     'note': widget.noteController.text,
//   //     'tags': getSelectedTags(),
//   //     'picUrl': null,
//   //     'isExisting': true,
//   //     'isEdited': true,
//   //     'docId': null,
//   //   };
//   //   //widget.imageCacheProvider.addPicture(pictureData!); // Add picture to cache
//   // }

//   Future<void> _replaceImage() async {
//     final XFile? newImage = await _picker.pickImage(source: ImageSource.camera);
//     if (newImage != null) {
//       setState(() {
//         isLoading = true;
//       });

//       try {
//         if (widget.picture != null && widget.picture!['picUrl'] != null) {
//           final String oldPicDocId = widget.picture!['docId'];
//           final String oldPicUrl = widget.picture!['picUrl'];
//           final Reference storageRef =
//               FirebaseStorage.instance.refFromURL(oldPicUrl);
//           await storageRef.delete();

//           if (oldPicDocId != null) {
//             widget.imageCacheProvider.addDeletedPictureDocId(oldPicDocId);
//           }
//         }

//         _setPictureData(newImage);

//         setState(() {
//           localPath = newImage.path;
//           isLoading = false;
//         });
//       } catch (e) {
//         devtools.log("Error replacing image: $e");
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } else {
//       devtools.log("No image selected for replacement.");
//     }
//   }

//   Future<void> _chooseImageSource() async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Choose Image Source'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 final XFile? newImage =
//                     await _picker.pickImage(source: ImageSource.gallery);
//                 if (newImage != null) {
//                   _setPictureData(newImage);
//                   setState(() {
//                     localPath = newImage.path;
//                     devtools.log(
//                         '!!!!!!! This is coming from inside _chooseImageSource defined inside FullScreenNoteDialog. When ImageSource is gallery then localPath is $localPath');
//                   });
//                 }
//               },
//               child: const Text('Gallery'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 final XFile? newImage =
//                     await _picker.pickImage(source: ImageSource.camera);
//                 if (newImage != null) {
//                   _setPictureData(newImage);
//                   setState(() {
//                     localPath = newImage.path;
//                     devtools.log(
//                         '!!!!!!! This is coming from inside _chooseImageSource defined inside FullScreenNoteDialog. When ImageSource is camera then localPath is $localPath');
//                   });
//                 }
//               },
//               child: const Text('Camera'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         iconTheme: IconThemeData(
//           color: MyColors.colorPalette['on-surface'],
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () {
//             Navigator.of(context).pop({
//               'note': widget.noteController.text,
//               'tags': getSelectedTags(),
//               'picUrl': picUrl,
//               'localPath': localPath, // Ensure localPath is returned
//               'isEdited':
//                   widget.isEditMode, // Indicate if the picture is edited
//               'docId': widget.picture?['docId'],
//             });
//           },
//           color: MyColors.colorPalette['on-surface'],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: GestureDetector(
//                   onTap: () {
//                     if (localPath != null || picUrl != null) {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => Scaffold(
//                             appBar: AppBar(
//                               backgroundColor: MyColors
//                                   .colorPalette['surface-container-lowest'],
//                               iconTheme: IconThemeData(
//                                 color: MyColors.colorPalette['on-surface'],
//                               ),
//                               leading: IconButton(
//                                 icon: const Icon(Icons.close),
//                                 onPressed: () {
//                                   Navigator.of(context).pop();
//                                 },
//                                 color: MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                             body: Center(
//                               child: PhotoView(
//                                 imageProvider: localPath != null
//                                     ? FileImage(File(localPath!))
//                                         as ImageProvider<Object>
//                                     : CachedNetworkImageProvider(picUrl!)
//                                         as ImageProvider<Object>,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                   child: localPath != null
//                       ? SizedBox(
//                           height: MediaQuery.of(context).size.height / 3,
//                           child: Image.file(
//                             File(localPath!),
//                             fit: BoxFit.contain,
//                           ),
//                         )
//                       : picUrl != null
//                           ? SizedBox(
//                               height: MediaQuery.of(context).size.height / 3,
//                               child: CachedNetworkImage(
//                                 imageUrl: picUrl!,
//                                 placeholder: (context, url) =>
//                                     const CircularProgressIndicator(),
//                                 errorWidget: (context, url, error) =>
//                                     const Icon(Icons.error),
//                                 fit: BoxFit.contain,
//                               ),
//                             )
//                           : Container(
//                               color: Colors.grey,
//                               height: MediaQuery.of(context).size.height / 2,
//                               width: double.infinity,
//                               child:
//                                   const Icon(Icons.image, color: Colors.white),
//                             ),
//                 ),
//               ),
//               const SizedBox(height: 8.0),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: IconButton(
//                   icon: const Icon(Icons.edit),
//                   onPressed: isLoading ? null : _chooseImageSource,
//                   color: MyColors.colorPalette['primary'],
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               Text(
//                 'Details',
//                 style: MyTextStyle.textStyleMap['title-medium']
//                     ?.copyWith(color: MyColors.colorPalette['secondary']),
//               ),
//               const SizedBox(height: 8.0),
//               if (!isExpanded)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         width: 1,
//                         color: MyColors.colorPalette['outline'] ?? Colors.grey,
//                       ),
//                     ),
//                     child: ListTile(
//                       title: Text(
//                         'Select Tag(s)',
//                         style: MyTextStyle.textStyleMap['title-medium']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['secondary']),
//                       ),
//                       trailing: Icon(
//                         isExpanded
//                             ? Icons.keyboard_arrow_up
//                             : Icons.keyboard_arrow_down,
//                         color: MyColors.colorPalette['secondary'],
//                       ),
//                       onTap: togglePanel,
//                     ),
//                   ),
//                 ),
//               if (isExpanded)
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color:
//                           MyColors.colorPalette['outline'] ?? Colors.blueAccent,
//                     ),
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   child: Column(
//                     children: [
//                       CheckboxListTile(
//                         value: isImageSelected,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             isImageSelected = value ?? false;
//                           });
//                         },
//                         title: Text(
//                           'Image',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                         activeColor: MyColors.colorPalette['primary'],
//                       ),
//                       CheckboxListTile(
//                         value: isXraySelected,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             isXraySelected = value ?? false;
//                           });
//                         },
//                         title: Text(
//                           'X-ray',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                         activeColor: MyColors.colorPalette['primary'],
//                       ),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () {
//                             setState(() {
//                               isExpanded = false;
//                             });
//                           },
//                           child: Text(
//                             'OK',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['primary']),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               const SizedBox(height: 8.0),
//               if (!isExpanded)
//                 Wrap(
//                   spacing: 8.0,
//                   children: getSelectedTags()
//                       .map((label) => Chip(
//                             label: Text(
//                               label,
//                               style: MyTextStyle.textStyleMap['label-small']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-primary']),
//                             ),
//                             backgroundColor: MyColors.colorPalette['primary'],
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(24.0),
//                             ),
//                             visualDensity: const VisualDensity(
//                                 horizontal: 0.0, vertical: -4.0),
//                             materialTapTargetSize:
//                                 MaterialTapTargetSize.shrinkWrap,
//                           ))
//                       .toList(),
//                 ),
//               const SizedBox(height: 16.0),
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                 child: TextFormField(
//                   controller: widget.noteController,
//                   minLines: 4,
//                   maxLines: 4,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     alignLabelWithHint: true,
//                     labelStyle: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(
//                             color: MyColors.colorPalette['on-surface-variant']),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(5.0)),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['outline'] ?? Colors.black,
//                       ),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(5.0)),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['on-surface-variant'] ??
//                             Colors.black,
//                       ),
//                     ),
//                     contentPadding: const EdgeInsets.all(8.0),
//                   ),
//                   onChanged: (_) => setState(() {}),
//                 ),
//               ),
//               const SizedBox(height: 8.0),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: Colors.transparent,
//         elevation: 0,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   style: ButtonStyle(
//                     overlayColor: MaterialStateProperty.all(
//                       MyColors.colorPalette['primary']!.withOpacity(0.1),
//                     ),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     'Cancel',
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['primary']),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: isLoading
//                       ? null
//                       : () {
//                           Navigator.of(context).pop({
//                             'note': widget.noteController.text,
//                             'tags': getSelectedTags(),
//                             'picUrl': picUrl,
//                             'localPath': localPath,

//                             'isEdited': widget
//                                 .isEditMode, // Indicate if the picture is edited
//                             'docId': widget.picture?['docId'],
//                           });
//                           devtools.log(
//                               'This is coming from inside FullScreenNoteDialog. localPath being passed back on return is $localPath');
//                         },
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all(
//                       isLoading
//                           ? Colors.grey
//                           : MyColors.colorPalette['primary'],
//                     ),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     widget.isEditMode ? 'Save' : 'Add',
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['on-primary']),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// CODE BELOW STABLE WITHOUT UPLOAD FROM GALLERY OPTION
// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/image_cache_provider.dart';
// import 'package:neocare_dental_app/mywidgets/user_data_provider.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';
// import 'mycolors.dart';
// import 'mytextstyle.dart';
// import 'dart:developer' as devtools show log;

// class FullScreenNoteDialog extends StatefulWidget {
//   final XFile? imageFile;
//   final TextEditingController noteController;
//   final String? imageUrl;
//   final String? note;
//   final bool isEditMode;
//   final List<String>? existingTags;
//   final Map<String, dynamic>? picture;
//   final ImageCacheProvider imageCacheProvider;
//   final UserDataProvider userData;

//   const FullScreenNoteDialog({
//     super.key,
//     this.imageFile,
//     required this.noteController,
//     this.imageUrl,
//     this.note,
//     this.isEditMode = false,
//     this.existingTags,
//     this.picture,
//     required this.imageCacheProvider,
//     required this.userData,
//   });

//   @override
//   State<FullScreenNoteDialog> createState() => _FullScreenNoteDialogState();
// }

// class _FullScreenNoteDialogState extends State<FullScreenNoteDialog> {
//   final ImagePicker _picker = ImagePicker();
//   bool isImageSelected = false;
//   bool isXraySelected = false;
//   bool isExpanded = false;
//   bool isLoading = true;
//   String? picUrl;
//   String? localPath;
//   Map<String, dynamic>? pictureData;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.imageFile != null) {
//       localPath = widget.imageFile!.path;
//       _setPictureData(widget.imageFile!);
//     } else {
//       localPath = widget.picture?['localPath'];
//       picUrl = widget.imageUrl;
//     }
//     _initializeTags();
//     setState(() {
//       isLoading = false;
//     });
//   }

//   void _initializeTags() {
//     if (widget.existingTags != null) {
//       setState(() {
//         isImageSelected = widget.existingTags!.contains('Image');
//         isXraySelected = widget.existingTags!.contains('X-ray');
//       });
//     }
//   }

//   void togglePanel() {
//     setState(() {
//       isExpanded = !isExpanded;
//     });
//   }

//   List<String> getSelectedTags() {
//     List<String> tags = [];
//     if (isImageSelected) tags.add('Image');
//     if (isXraySelected) tags.add('X-ray');
//     return tags;
//   }

//   void _setPictureData(XFile newImage) {
//     pictureData = {
//       'localPath': newImage.path,
//       'picId': widget.picture?['picId'] ?? const Uuid().v4(),
//       'isUploading': false,
//       'note': widget.noteController.text,
//       'tags': getSelectedTags(),
//       'picUrl': null,
//       'isExisting': true,
//       'isEdited': true,
//       'docId': null,
//     };
//   }

//   Future<void> _replaceImage() async {
//     final XFile? newImage = await _picker.pickImage(source: ImageSource.camera);
//     if (newImage != null) {
//       setState(() {
//         isLoading = true;
//       });

//       try {
//         if (widget.picture != null && widget.picture!['picUrl'] != null) {
//           final String oldPicDocId = widget.picture!['docId'];
//           final String oldPicUrl = widget.picture!['picUrl'];
//           final Reference storageRef =
//               FirebaseStorage.instance.refFromURL(oldPicUrl);
//           await storageRef.delete();

//           if (oldPicDocId != null) {
//             widget.imageCacheProvider.addDeletedPictureDocId(oldPicDocId);
//           }
//         }

//         _setPictureData(newImage);

//         setState(() {
//           localPath = newImage.path;
//           isLoading = false;
//         });
//       } catch (e) {
//         devtools.log("Error replacing image: $e");
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } else {
//       devtools.log("No image selected for replacement.");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         iconTheme: IconThemeData(
//           color: MyColors.colorPalette['on-surface'],
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () {
//             Navigator.of(context).pop({
//               'note': widget.noteController.text,
//               'tags': getSelectedTags(),
//               'picUrl': picUrl,
//               'localPath': localPath, // Ensure localPath is returned
//               'isEdited':
//                   widget.isEditMode, // Indicate if the picture is edited
//               'docId': widget.picture?['docId'],
//             });
//           },
//           color: MyColors.colorPalette['on-surface'],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: GestureDetector(
//                   onTap: () {
//                     if (localPath != null || picUrl != null) {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => Scaffold(
//                             appBar: AppBar(
//                               backgroundColor: MyColors
//                                   .colorPalette['surface-container-lowest'],
//                               iconTheme: IconThemeData(
//                                 color: MyColors.colorPalette['on-surface'],
//                               ),
//                               leading: IconButton(
//                                 icon: const Icon(Icons.close),
//                                 onPressed: () {
//                                   Navigator.of(context).pop();
//                                 },
//                                 color: MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                             body: Center(
//                               child: PhotoView(
//                                 imageProvider: localPath != null
//                                     ? FileImage(File(localPath!))
//                                         as ImageProvider<Object>
//                                     : CachedNetworkImageProvider(picUrl!)
//                                         as ImageProvider<Object>,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                   child: localPath != null
//                       ? SizedBox(
//                           height: MediaQuery.of(context).size.height / 3,
//                           child: Image.file(
//                             File(localPath!),
//                             fit: BoxFit.contain,
//                           ),
//                         )
//                       : picUrl != null
//                           ? SizedBox(
//                               height: MediaQuery.of(context).size.height / 3,
//                               child: CachedNetworkImage(
//                                 imageUrl: picUrl!,
//                                 placeholder: (context, url) =>
//                                     const CircularProgressIndicator(),
//                                 errorWidget: (context, url, error) =>
//                                     const Icon(Icons.error),
//                                 fit: BoxFit.contain,
//                               ),
//                             )
//                           : Container(
//                               color: Colors.grey,
//                               height: MediaQuery.of(context).size.height / 2,
//                               width: double.infinity,
//                               child:
//                                   const Icon(Icons.image, color: Colors.white),
//                             ),
//                 ),
//               ),
//               const SizedBox(height: 8.0),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: IconButton(
//                   icon: const Icon(Icons.edit),
//                   onPressed: isLoading ? null : _replaceImage,
//                   color: MyColors.colorPalette['primary'],
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               Text(
//                 'Details',
//                 style: MyTextStyle.textStyleMap['title-medium']
//                     ?.copyWith(color: MyColors.colorPalette['secondary']),
//               ),
//               const SizedBox(height: 8.0),
//               if (!isExpanded)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         width: 1,
//                         color: MyColors.colorPalette['outline'] ?? Colors.grey,
//                       ),
//                     ),
//                     child: ListTile(
//                       title: Text(
//                         'Select Tag(s)',
//                         style: MyTextStyle.textStyleMap['title-medium']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['secondary']),
//                       ),
//                       trailing: Icon(
//                         isExpanded
//                             ? Icons.keyboard_arrow_up
//                             : Icons.keyboard_arrow_down,
//                         color: MyColors.colorPalette['secondary'],
//                       ),
//                       onTap: togglePanel,
//                     ),
//                   ),
//                 ),
//               if (isExpanded)
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color:
//                           MyColors.colorPalette['outline'] ?? Colors.blueAccent,
//                     ),
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   child: Column(
//                     children: [
//                       CheckboxListTile(
//                         value: isImageSelected,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             isImageSelected = value ?? false;
//                           });
//                         },
//                         title: Text(
//                           'Image',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                         activeColor: MyColors.colorPalette['primary'],
//                       ),
//                       CheckboxListTile(
//                         value: isXraySelected,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             isXraySelected = value ?? false;
//                           });
//                         },
//                         title: Text(
//                           'X-ray',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                         activeColor: MyColors.colorPalette['primary'],
//                       ),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () {
//                             setState(() {
//                               isExpanded = false;
//                             });
//                           },
//                           child: Text(
//                             'OK',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['primary']),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               const SizedBox(height: 8.0),
//               if (!isExpanded)
//                 Wrap(
//                   spacing: 8.0,
//                   children: getSelectedTags()
//                       .map((label) => Chip(
//                             label: Text(
//                               label,
//                               style: MyTextStyle.textStyleMap['label-small']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-primary']),
//                             ),
//                             backgroundColor: MyColors.colorPalette['primary'],
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(24.0),
//                             ),
//                             visualDensity: const VisualDensity(
//                                 horizontal: 0.0, vertical: -4.0),
//                             materialTapTargetSize:
//                                 MaterialTapTargetSize.shrinkWrap,
//                           ))
//                       .toList(),
//                 ),
//               const SizedBox(height: 16.0),
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                 child: TextFormField(
//                   controller: widget.noteController,
//                   minLines: 4,
//                   maxLines: 4,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     alignLabelWithHint: true,
//                     labelStyle: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(
//                             color: MyColors.colorPalette['on-surface-variant']),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(5.0)),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['outline'] ?? Colors.black,
//                       ),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(5.0)),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['on-surface-variant'] ??
//                             Colors.black,
//                       ),
//                     ),
//                     contentPadding: const EdgeInsets.all(8.0),
//                   ),
//                   onChanged: (_) => setState(() {}),
//                 ),
//               ),
//               const SizedBox(height: 8.0),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: Colors.transparent,
//         elevation: 0,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   style: ButtonStyle(
//                     overlayColor: MaterialStateProperty.all(
//                       MyColors.colorPalette['primary']!.withOpacity(0.1),
//                     ),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     'Cancel',
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['primary']),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: isLoading
//                       ? null
//                       : () {
//                           Navigator.of(context).pop({
//                             'note': widget.noteController.text,
//                             'tags': getSelectedTags(),
//                             'picUrl': picUrl,
//                             'localPath': localPath,

//                             'isEdited': widget
//                                 .isEditMode, // Indicate if the picture is edited
//                             'docId': widget.picture?['docId'],
//                           });
//                           devtools.log(
//                               'This is coming from inside FullScreenNoteDialog. localPath being passed back on return is $localPath');
//                         },
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all(
//                       isLoading
//                           ? Colors.grey
//                           : MyColors.colorPalette['primary'],
//                     ),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     widget.isEditMode ? 'Save' : 'Add',
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['on-primary']),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/image_cache_provider.dart';
// import 'package:neocare_dental_app/mywidgets/user_data_provider.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';
// import 'mycolors.dart';
// import 'mytextstyle.dart';
// import 'dart:developer' as devtools show log;

// class FullScreenNoteDialog extends StatefulWidget {
//   final XFile? imageFile;
//   final TextEditingController noteController;
//   final String? imageUrl;
//   final String? note;
//   final bool isEditMode;
//   final List<String>? existingTags;
//   final Map<String, dynamic>? picture;
//   final ImageCacheProvider imageCacheProvider;
//   final UserDataProvider userData;

//   const FullScreenNoteDialog({
//     super.key,
//     this.imageFile,
//     required this.noteController,
//     this.imageUrl,
//     this.note,
//     this.isEditMode = false,
//     this.existingTags,
//     this.picture,
//     required this.imageCacheProvider,
//     required this.userData,
//   });

//   @override
//   State<FullScreenNoteDialog> createState() => _FullScreenNoteDialogState();
// }

// class _FullScreenNoteDialogState extends State<FullScreenNoteDialog> {
//   final ImagePicker _picker = ImagePicker();
//   bool isImageSelected = false;
//   bool isXraySelected = false;
//   bool isExpanded = false;
//   bool isLoading = true;
//   String? picUrl;
//   String? localPath;
//   Map<String, dynamic>? pictureData;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.imageFile != null) {
//       localPath = widget.imageFile!.path;
//       _setPictureData(widget.imageFile!);
//     } else {
//       localPath = widget.picture?['localPath'];
//       picUrl = widget.imageUrl;
//     }
//     _initializeTags();
//     setState(() {
//       isLoading = false;
//     });
//   }

//   void _initializeTags() {
//     if (widget.existingTags != null) {
//       setState(() {
//         isImageSelected = widget.existingTags!.contains('Image');
//         isXraySelected = widget.existingTags!.contains('X-ray');
//       });
//     }
//   }

//   void togglePanel() {
//     setState(() {
//       isExpanded = !isExpanded;
//     });
//   }

//   List<String> getSelectedTags() {
//     List<String> tags = [];
//     if (isImageSelected) tags.add('Image');
//     if (isXraySelected) tags.add('X-ray');
//     return tags;
//   }

//   void _setPictureData(XFile newImage) {
//     pictureData = {
//       'localPath': newImage.path,
//       'picId': widget.picture?['picId'] ?? const Uuid().v4(),
//       'isUploading': false,
//       'note': widget.noteController.text,
//       'tags': getSelectedTags(),
//       'picUrl': null,
//       'isExisting': true,
//       'isEdited': true,
//       'docId': null,
//     };
//   }

//   Future<void> _replaceImage() async {
//     final XFile? newImage = await _picker.pickImage(source: ImageSource.camera);
//     if (newImage != null) {
//       setState(() {
//         isLoading = true;
//       });

//       try {
//         if (widget.picture != null && widget.picture!['picUrl'] != null) {
//           final String oldPicDocId = widget.picture!['docId'];
//           final String oldPicUrl = widget.picture!['picUrl'];
//           final Reference storageRef =
//               FirebaseStorage.instance.refFromURL(oldPicUrl);
//           await storageRef.delete();

//           if (oldPicDocId != null) {
//             widget.imageCacheProvider.addDeletedPictureDocId(oldPicDocId);
//           }
//         }

//         _setPictureData(newImage);

//         setState(() {
//           localPath = newImage.path;
//           isLoading = false;
//         });
//       } catch (e) {
//         devtools.log("Error replacing image: $e");
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } else {
//       devtools.log("No image selected for replacement.");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         iconTheme: IconThemeData(
//           color: MyColors.colorPalette['on-surface'],
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () {
//             Navigator.of(context).pop({
//               'note': widget.noteController.text,
//               'tags': getSelectedTags(),
//               'picUrl': picUrl,
//               'localPath': localPath, // Ensure localPath is returned
//               'isEdited':
//                   widget.isEditMode, // Indicate if the picture is edited
//               'docId': widget.picture?['docId'],
//             });
//           },
//           color: MyColors.colorPalette['on-surface'],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   if (localPath != null || picUrl != null) {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => Scaffold(
//                           appBar: AppBar(
//                             backgroundColor: MyColors
//                                 .colorPalette['surface-container-lowest'],
//                             iconTheme: IconThemeData(
//                               color: MyColors.colorPalette['on-surface'],
//                             ),
//                             leading: IconButton(
//                               icon: const Icon(Icons.close),
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                               },
//                               color: MyColors.colorPalette['on-surface'],
//                             ),
//                           ),
//                           body: Center(
//                             child: PhotoView(
//                               imageProvider: localPath != null
//                                   ? FileImage(File(localPath!))
//                                       as ImageProvider<Object>
//                                   : CachedNetworkImageProvider(picUrl!)
//                                       as ImageProvider<Object>,
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//                 },
//                 child: Stack(
//                   children: [
//                     localPath != null
//                         ? SizedBox(
//                             height: MediaQuery.of(context).size.height / 3,
//                             child: Image.file(
//                               File(localPath!),
//                               fit: BoxFit.contain,
//                             ),
//                           )
//                         : picUrl != null
//                             ? SizedBox(
//                                 height: MediaQuery.of(context).size.height / 3,
//                                 child: CachedNetworkImage(
//                                   imageUrl: picUrl!,
//                                   placeholder: (context, url) =>
//                                       const CircularProgressIndicator(),
//                                   errorWidget: (context, url, error) =>
//                                       const Icon(Icons.error),
//                                   fit: BoxFit.contain,
//                                 ),
//                               )
//                             : Container(
//                                 color: Colors.grey,
//                                 height: MediaQuery.of(context).size.height / 2,
//                                 width: double.infinity,
//                                 child: const Icon(Icons.image,
//                                     color: Colors.white),
//                               ),
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: IconButton(
//                         icon: const Icon(Icons.edit),
//                         onPressed: isLoading ? null : _replaceImage,
//                         color: MyColors.colorPalette['primary'],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               Text(
//                 'Details',
//                 style: MyTextStyle.textStyleMap['title-medium']
//                     ?.copyWith(color: MyColors.colorPalette['secondary']),
//               ),
//               const SizedBox(height: 8.0),
//               if (!isExpanded)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         width: 1,
//                         color: MyColors.colorPalette['outline'] ?? Colors.grey,
//                       ),
//                     ),
//                     child: ListTile(
//                       title: Text(
//                         'Select Tag(s)',
//                         style: MyTextStyle.textStyleMap['title-medium']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['secondary']),
//                       ),
//                       trailing: Icon(
//                         isExpanded
//                             ? Icons.keyboard_arrow_up
//                             : Icons.keyboard_arrow_down,
//                         color: MyColors.colorPalette['secondary'],
//                       ),
//                       onTap: togglePanel,
//                     ),
//                   ),
//                 ),
//               if (isExpanded)
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color:
//                           MyColors.colorPalette['outline'] ?? Colors.blueAccent,
//                     ),
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   child: Column(
//                     children: [
//                       CheckboxListTile(
//                         value: isImageSelected,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             isImageSelected = value ?? false;
//                           });
//                         },
//                         title: Text(
//                           'Image',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                         activeColor: MyColors.colorPalette['primary'],
//                       ),
//                       CheckboxListTile(
//                         value: isXraySelected,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             isXraySelected = value ?? false;
//                           });
//                         },
//                         title: Text(
//                           'X-ray',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                         activeColor: MyColors.colorPalette['primary'],
//                       ),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () {
//                             setState(() {
//                               isExpanded = false;
//                             });
//                           },
//                           child: Text(
//                             'OK',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['primary']),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               const SizedBox(height: 8.0),
//               if (!isExpanded)
//                 Wrap(
//                   spacing: 8.0,
//                   children: getSelectedTags()
//                       .map((label) => Chip(
//                             label: Text(
//                               label,
//                               style: MyTextStyle.textStyleMap['label-small']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-primary']),
//                             ),
//                             backgroundColor: MyColors.colorPalette['primary'],
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(24.0),
//                             ),
//                             visualDensity: const VisualDensity(
//                                 horizontal: 0.0, vertical: -4.0),
//                             materialTapTargetSize:
//                                 MaterialTapTargetSize.shrinkWrap,
//                           ))
//                       .toList(),
//                 ),
//               const SizedBox(height: 16.0),
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                 child: TextFormField(
//                   controller: widget.noteController,
//                   minLines: 4,
//                   maxLines: 4,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     alignLabelWithHint: true,
//                     labelStyle: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(
//                             color: MyColors.colorPalette['on-surface-variant']),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(5.0)),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['outline'] ?? Colors.black,
//                       ),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(5.0)),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['on-surface-variant'] ??
//                             Colors.black,
//                       ),
//                     ),
//                     contentPadding: const EdgeInsets.all(8.0),
//                   ),
//                   onChanged: (_) => setState(() {}),
//                 ),
//               ),
//               const SizedBox(height: 8.0),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: Colors.transparent,
//         elevation: 0,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   style: ButtonStyle(
//                     overlayColor: MaterialStateProperty.all(
//                       MyColors.colorPalette['primary']!.withOpacity(0.1),
//                     ),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     'Cancel',
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['primary']),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: isLoading
//                       ? null
//                       : () {
//                           Navigator.of(context).pop({
//                             'note': widget.noteController.text,
//                             'tags': getSelectedTags(),
//                             'picUrl': picUrl,
//                             'localPath': localPath,

//                             'isEdited': widget
//                                 .isEditMode, // Indicate if the picture is edited
//                             'docId': widget.picture?['docId'],
//                           });
//                           devtools.log(
//                               'This is coming from inside FullScreenNoteDialog. localPath being passed back on return is $localPath');
//                         },
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all(
//                       isLoading
//                           ? Colors.grey
//                           : MyColors.colorPalette['primary'],
//                     ),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     widget.isEditMode ? 'Save' : 'Add',
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['on-primary']),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// class FullScreenNoteDialog extends StatefulWidget {
//   final XFile? imageFile;
//   final TextEditingController noteController;
//   final String? imageUrl;
//   final String? note;
//   final bool isEditMode;
//   final List<String>? existingTags;
//   final Map<String, dynamic>? picture;
//   final ImageCacheProvider imageCacheProvider;
//   final UserDataProvider userData;

//   const FullScreenNoteDialog({
//     super.key,
//     this.imageFile,
//     required this.noteController,
//     this.imageUrl,
//     this.note,
//     this.isEditMode = false,
//     this.existingTags,
//     this.picture,
//     required this.imageCacheProvider,
//     required this.userData,
//   });

//   @override
//   State<FullScreenNoteDialog> createState() => _FullScreenNoteDialogState();
// }

// class _FullScreenNoteDialogState extends State<FullScreenNoteDialog> {
//   final ImagePicker _picker = ImagePicker();
//   bool isImageSelected = false;
//   bool isXraySelected = false;
//   bool isExpanded = false;
//   bool isLoading = true;
//   String? picUrl;
//   String? localPath;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.imageFile != null) {
//       localPath = widget.imageFile!.path;
//     } else {
//       localPath = widget.picture?['localPath'];
//       picUrl = widget.imageUrl;
//     }
//     _initializeTags();
//     setState(() {
//       isLoading = false;
//     });
//   }

//   void _initializeTags() {
//     if (widget.existingTags != null) {
//       setState(() {
//         isImageSelected = widget.existingTags!.contains('Image');
//         isXraySelected = widget.existingTags!.contains('X-ray');
//       });
//     }
//   }

//   void togglePanel() {
//     setState(() {
//       isExpanded = !isExpanded;
//     });
//   }

//   List<String> getSelectedTags() {
//     List<String> tags = [];
//     if (isImageSelected) tags.add('Image');
//     if (isXraySelected) tags.add('X-ray');
//     return tags;
//   }

//   // When editing an existing picture
//   Future<void> _replaceImage() async {
//     final XFile? newImage = await _picker.pickImage(source: ImageSource.camera);
//     if (newImage != null) {
//       setState(() {
//         isLoading = true;
//       });

//       try {
//         if (widget.picture != null && widget.picture!['picUrl'] != null) {
//           final String oldPicDocId = widget.picture!['docId'];
//           final String oldPicUrl = widget.picture!['picUrl'];
//           final Reference storageRef =
//               FirebaseStorage.instance.refFromURL(oldPicUrl);
//           await storageRef.delete();

//           if (oldPicDocId != null) {
//             widget.imageCacheProvider.addDeletedPictureDocId(oldPicDocId);
//           }
//         }

//         final updatedPictureData = {
//           'localPath': newImage.path,
//           'picId': widget.picture?['picId'] ?? const Uuid().v4(),
//           'isUploading': false,
//           'note': widget.noteController.text,
//           'tags': getSelectedTags(),
//           'picUrl': null,
//           'isExisting': true,
//           'isEdited': true,
//           'docId': null,
//         };

//         devtools.log('New updated picture data: $updatedPictureData');

//         if (widget.picture != null) {
//           widget.imageCacheProvider.removePicture(widget.picture!['picId']);
//           widget.imageCacheProvider.addPicture(updatedPictureData);
//         } else {
//           widget.imageCacheProvider.addPicture(updatedPictureData);
//         }

//         widget.userData.savePictures(
//             widget.imageCacheProvider.pictures, 'from _replaceImage');

//         setState(() {
//           localPath = newImage.path;
//           isLoading = false;
//         });
//       } catch (e) {
//         devtools.log("Error replacing image: $e");
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } else {
//       devtools.log("No image selected for replacement.");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         iconTheme: IconThemeData(
//           color: MyColors.colorPalette['on-surface'],
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () {
//             Navigator.of(context).pop({
//               'note': widget.noteController.text,
//               'tags': getSelectedTags(),
//               'picUrl': picUrl,
//               'localPath': localPath, // Ensure localPath is returned
//               'isEdited':
//                   widget.isEditMode, // Indicate if the picture is edited
//               'docId': widget.picture?['docId'],
//             });
//           },
//           color: MyColors.colorPalette['on-surface'],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   if (localPath != null || picUrl != null) {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => Scaffold(
//                           appBar: AppBar(
//                             backgroundColor: MyColors
//                                 .colorPalette['surface-container-lowest'],
//                             iconTheme: IconThemeData(
//                               color: MyColors.colorPalette['on-surface'],
//                             ),
//                             leading: IconButton(
//                               icon: const Icon(Icons.close),
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                               },
//                               color: MyColors.colorPalette['on-surface'],
//                             ),
//                           ),
//                           body: Center(
//                             child: PhotoView(
//                               imageProvider: localPath != null
//                                   ? FileImage(File(localPath!))
//                                       as ImageProvider<Object>
//                                   : CachedNetworkImageProvider(picUrl!)
//                                       as ImageProvider<Object>,
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//                 },
//                 child: Stack(
//                   children: [
//                     localPath != null
//                         ? SizedBox(
//                             height: MediaQuery.of(context).size.height / 3,
//                             child: Image.file(
//                               File(localPath!),
//                               fit: BoxFit.contain,
//                             ),
//                           )
//                         : picUrl != null
//                             ? SizedBox(
//                                 height: MediaQuery.of(context).size.height / 3,
//                                 child: CachedNetworkImage(
//                                   imageUrl: picUrl!,
//                                   placeholder: (context, url) =>
//                                       const CircularProgressIndicator(),
//                                   errorWidget: (context, url, error) =>
//                                       const Icon(Icons.error),
//                                   fit: BoxFit.contain,
//                                 ),
//                               )
//                             : Container(
//                                 color: Colors.grey,
//                                 height: MediaQuery.of(context).size.height / 2,
//                                 width: double.infinity,
//                                 child: const Icon(Icons.image,
//                                     color: Colors.white),
//                               ),
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: IconButton(
//                         icon: const Icon(Icons.edit),
//                         onPressed: isLoading ? null : _replaceImage,
//                         color: MyColors.colorPalette['primary'],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               Text(
//                 'Details',
//                 style: MyTextStyle.textStyleMap['title-medium']
//                     ?.copyWith(color: MyColors.colorPalette['secondary']),
//               ),
//               const SizedBox(height: 8.0),
//               if (!isExpanded)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         width: 1,
//                         color: MyColors.colorPalette['outline'] ?? Colors.grey,
//                       ),
//                     ),
//                     child: ListTile(
//                       title: Text(
//                         'Select Tag(s)',
//                         style: MyTextStyle.textStyleMap['title-medium']
//                             ?.copyWith(
//                                 color: MyColors.colorPalette['secondary']),
//                       ),
//                       trailing: Icon(
//                         isExpanded
//                             ? Icons.keyboard_arrow_up
//                             : Icons.keyboard_arrow_down,
//                         color: MyColors.colorPalette['secondary'],
//                       ),
//                       onTap: togglePanel,
//                     ),
//                   ),
//                 ),
//               if (isExpanded)
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1,
//                       color:
//                           MyColors.colorPalette['outline'] ?? Colors.blueAccent,
//                     ),
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   child: Column(
//                     children: [
//                       CheckboxListTile(
//                         value: isImageSelected,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             isImageSelected = value ?? false;
//                           });
//                         },
//                         title: Text(
//                           'Image',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                         activeColor: MyColors.colorPalette['primary'],
//                       ),
//                       CheckboxListTile(
//                         value: isXraySelected,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             isXraySelected = value ?? false;
//                           });
//                         },
//                         title: Text(
//                           'X-ray',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                         activeColor: MyColors.colorPalette['primary'],
//                       ),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () {
//                             setState(() {
//                               isExpanded = false;
//                             });
//                           },
//                           child: Text(
//                             'OK',
//                             style: MyTextStyle.textStyleMap['label-large']
//                                 ?.copyWith(
//                                     color: MyColors.colorPalette['primary']),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               const SizedBox(height: 8.0),
//               if (!isExpanded)
//                 Wrap(
//                   spacing: 8.0,
//                   children: getSelectedTags()
//                       .map((label) => Chip(
//                             label: Text(
//                               label,
//                               style: MyTextStyle.textStyleMap['label-small']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['on-primary']),
//                             ),
//                             backgroundColor: MyColors.colorPalette['primary'],
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(24.0),
//                             ),
//                             visualDensity: const VisualDensity(
//                                 horizontal: 0.0, vertical: -4.0),
//                             materialTapTargetSize:
//                                 MaterialTapTargetSize.shrinkWrap,
//                           ))
//                       .toList(),
//                 ),
//               const SizedBox(height: 16.0),
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
//                 child: TextFormField(
//                   controller: widget.noteController,
//                   minLines: 4,
//                   maxLines: 4,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     alignLabelWithHint: true,
//                     labelStyle: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(
//                             color: MyColors.colorPalette['on-surface-variant']),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(5.0)),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['outline'] ?? Colors.black,
//                       ),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(5.0)),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['on-surface-variant'] ??
//                             Colors.black,
//                       ),
//                     ),
//                     contentPadding: const EdgeInsets.all(8.0),
//                   ),
//                   onChanged: (_) => setState(() {}),
//                 ),
//               ),
//               const SizedBox(height: 8.0),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: Colors.transparent,
//         elevation: 0,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   style: ButtonStyle(
//                     overlayColor: MaterialStateProperty.all(
//                       MyColors.colorPalette['primary']!.withOpacity(0.1),
//                     ),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     'Cancel',
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['primary']),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: isLoading
//                       ? null
//                       : () {
//                           Navigator.of(context).pop({
//                             'note': widget.noteController.text,
//                             'tags': getSelectedTags(),
//                             'picUrl': picUrl,
//                             'localPath': localPath,

//                             'isEdited': widget
//                                 .isEditMode, // Indicate if the picture is edited
//                             'docId': widget.picture?['docId'],
//                           });
//                           devtools.log(
//                               'This is coming from inside FullScreenNoteDialog. localPath being passed back on return is $localPath');
//                         },
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all(
//                       isLoading
//                           ? Colors.grey
//                           : MyColors.colorPalette['primary'],
//                     ),
//                     shape: MaterialStateProperty.all(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     widget.isEditMode ? 'Save' : 'Add',
//                     style: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(color: MyColors.colorPalette['on-primary']),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// //--------------------------------------------------------------