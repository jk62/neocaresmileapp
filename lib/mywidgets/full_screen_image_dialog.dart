import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'mycolors.dart';
import 'mytextstyle.dart';

class FullScreenImageDialog extends StatelessWidget {
  final String? localPath;
  final String imageUrl;
  final String? note;
  final List<String> tags;

  const FullScreenImageDialog({
    super.key,
    this.localPath,
    required this.imageUrl,
    required this.note,
    required this.tags,
  });

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
            Navigator.of(context).pop();
          },
          color: MyColors.colorPalette['on-surface'],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
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
                      body: Center(
                        child: PhotoView(
                          imageProvider: localPath != null
                              ? FileImage(File(localPath!))
                                  as ImageProvider<Object>
                              : CachedNetworkImageProvider(imageUrl)
                                  as ImageProvider<Object>,
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                height: MediaQuery.of(context).size.height / 3,
                child: localPath != null
                    ? Image.file(
                        File(localPath!),
                        fit: BoxFit.contain,
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Details',
                      style: MyTextStyle.textStyleMap['title-large']?.copyWith(
                          color: MyColors.colorPalette['on-surface']),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      spacing: 8.0,
                      children: tags
                          .map((label) => Chip(
                                label: Text(
                                  label,
                                  style: MyTextStyle.textStyleMap['label-small']
                                      ?.copyWith(
                                          color: MyColors
                                              .colorPalette['on-primary']),
                                ),
                                backgroundColor:
                                    MyColors.colorPalette['primary'],
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
                  ),
                  const SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: double.infinity,
                      height: 112.0,
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color:
                                MyColors.colorPalette['outline'] ?? Colors.grey,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          note ?? 'No description',
                          style: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors.colorPalette['secondary']),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW STABLE BEFORE IMPLEMENTING DELAYED PUSHING OF PICTURE
// import 'package:flutter/material.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'mycolors.dart';
// import 'mytextstyle.dart';

// class FullScreenImageDialog extends StatelessWidget {
//   final String imageUrl;
//   final String? note;
//   final List<String> tags;

//   const FullScreenImageDialog({
//     Key? key,
//     required this.imageUrl,
//     required this.note,
//     required this.tags,
//   }) : super(key: key);

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
//             Navigator.of(context).pop();
//           },
//           color: MyColors.colorPalette['on-surface'],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => Scaffold(
//                       appBar: AppBar(
//                         backgroundColor:
//                             MyColors.colorPalette['surface-container-lowest'],
//                         iconTheme: IconThemeData(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                         leading: IconButton(
//                           icon: const Icon(Icons.close),
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                       body: Center(
//                         child: PhotoView(
//                           imageProvider: CachedNetworkImageProvider(imageUrl),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               child: Container(
//                 height: MediaQuery.of(context).size.height / 3,
//                 //height: 240.0,
//                 child: CachedNetworkImage(
//                   imageUrl: imageUrl,
//                   placeholder: (context, url) =>
//                       const CircularProgressIndicator(),
//                   errorWidget: (context, url, error) => const Icon(Icons.error),
//                   width: double.infinity,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 //crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'Details',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                           color: MyColors.colorPalette['on-surface']),
//                     ),
//                   ),
//                   const SizedBox(height: 16.0),
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Wrap(
//                       spacing: 8.0,
//                       children: tags
//                           .map((label) => Chip(
//                                 label: Text(
//                                   label,
//                                   style: MyTextStyle.textStyleMap['label-small']
//                                       ?.copyWith(
//                                           color: MyColors
//                                               .colorPalette['on-primary']),
//                                 ),
//                                 backgroundColor:
//                                     MyColors.colorPalette['primary'],
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(24.0),
//                                 ),
//                                 visualDensity: const VisualDensity(
//                                     horizontal: 0.0, vertical: -4.0),
//                                 materialTapTargetSize:
//                                     MaterialTapTargetSize.shrinkWrap,
//                               ))
//                           .toList(),
//                     ),
//                   ),
//                   const SizedBox(height: 16.0),
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Container(
//                       width: double.infinity,
//                       height: 112.0,
//                       decoration: BoxDecoration(
//                           border: Border.all(
//                             width: 1.0,
//                             color:
//                                 MyColors.colorPalette['outline'] ?? Colors.grey,
//                           ),
//                           borderRadius:
//                               const BorderRadius.all(Radius.circular(10.0))),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           note ?? 'No description',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16.0),
//           ],
//         ),
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// CODE BELOW IS STABLE BEFORE DELAYED PUSHING OF PICTURE DATA
// import 'package:flutter/material.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'mycolors.dart';
// import 'mytextstyle.dart';

// class FullScreenImageDialog extends StatelessWidget {
//   final String imageUrl;
//   final String? note;
//   final List<String> tags;

//   const FullScreenImageDialog({
//     Key? key,
//     required this.imageUrl,
//     required this.note,
//     required this.tags,
//   }) : super(key: key);

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
//             Navigator.of(context).pop();
//           },
//           color: MyColors.colorPalette['on-surface'],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => Scaffold(
//                       appBar: AppBar(
//                         backgroundColor:
//                             MyColors.colorPalette['surface-container-lowest'],
//                         iconTheme: IconThemeData(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                         leading: IconButton(
//                           icon: const Icon(Icons.close),
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                       body: Center(
//                         child: PhotoView(
//                           imageProvider: CachedNetworkImageProvider(imageUrl),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               child: Container(
//                 height: MediaQuery.of(context).size.height / 3,
//                 //height: 240.0,
//                 child: CachedNetworkImage(
//                   imageUrl: imageUrl,
//                   placeholder: (context, url) =>
//                       const CircularProgressIndicator(),
//                   errorWidget: (context, url, error) => const Icon(Icons.error),
//                   width: double.infinity,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 //crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'Details',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                           color: MyColors.colorPalette['on-surface']),
//                     ),
//                   ),
//                   const SizedBox(height: 16.0),
//                   // Align(
//                   //   alignment: Alignment.topLeft,
//                   //   child: Wrap(
//                   //     spacing: 8.0,
//                   //     children: tags
//                   //         .map((label) => Chip(
//                   //               backgroundColor:
//                   //                   MyColors.colorPalette['primary'],
//                   //               shape: RoundedRectangleBorder(
//                   //                 borderRadius: BorderRadius.circular(24.0),
//                   //               ),
//                   //               label: Text(
//                   //                 label,
//                   //                 style: MyTextStyle.textStyleMap['label-large']
//                   //                     ?.copyWith(
//                   //                         color: MyColors
//                   //                             .colorPalette['on-primary']),
//                   //               ),
//                   //             ))
//                   //         .toList(),
//                   //   ),
//                   // ),
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Wrap(
//                       spacing: 8.0,
//                       children: tags
//                           .map((label) => Chip(
//                                 label: Text(
//                                   label,
//                                   style: MyTextStyle.textStyleMap['label-small']
//                                       ?.copyWith(
//                                           color: MyColors
//                                               .colorPalette['on-primary']),
//                                 ),
//                                 backgroundColor:
//                                     MyColors.colorPalette['primary'],
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(24.0),
//                                 ),
//                                 visualDensity: const VisualDensity(
//                                     horizontal: 0.0, vertical: -4.0),
//                                 materialTapTargetSize:
//                                     MaterialTapTargetSize.shrinkWrap,
//                               ))
//                           .toList(),
//                     ),
//                   ),
//                   const SizedBox(height: 16.0),
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Container(
//                       width: double.infinity,
//                       height: 112.0,
//                       decoration: BoxDecoration(
//                           border: Border.all(
//                             width: 1.0,
//                             color:
//                                 MyColors.colorPalette['outline'] ?? Colors.grey,
//                           ),
//                           borderRadius:
//                               const BorderRadius.all(Radius.circular(10.0))),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           note ?? 'No description',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16.0),
//           ],
//         ),
//       ),
//     );
//   }
// }
