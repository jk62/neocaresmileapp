// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:developer' as devtools show log;

// class GalleryScreen extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String treatmentId;

//   const GalleryScreen({
//     Key? key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   }) : super(key: key);

//   @override
//   State<GalleryScreen> createState() => _GalleryScreenState();
// }

// class _GalleryScreenState extends State<GalleryScreen> {
//   List<Map<String, dynamic>> pictures = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadPictures();
//   }

//   Future<void> _loadPictures() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(widget.clinicId)
//           .collection('patients')
//           .doc(widget.patientId)
//           .collection('treatments')
//           .doc(widget.treatmentId)
//           .collection('pictures')
//           .get();

//       setState(() {
//         pictures = snapshot.docs.map((doc) => doc.data()).toList();
//       });

//       // Print the fetched data to the console for debugging
//       devtools.log('Fetched pictures: $pictures');
//     } catch (e) {
//       devtools.log('Error fetching pictures: $e');
//     }
//   }

//   void _showFullImage(String picUrl, String? description) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Expanded(
//                 child: CachedNetworkImage(
//                   imageUrl: picUrl,
//                   placeholder: (context, url) =>
//                       const CircularProgressIndicator(),
//                   errorWidget: (context, url, error) => const Icon(Icons.error),
//                 ),
//               ),
//               if (description != null && description.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     description,
//                     style: MyTextStyle.textStyleMap['label-medium']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
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
//       ),
//       body: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text(
//               'Gallery',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: pictures.isEmpty
//                 ? const Center(child: Text('No pictures available'))
//                 : GridView.builder(
//                     padding: const EdgeInsets.all(8.0),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 5,
//                       crossAxisSpacing: 8.0,
//                       mainAxisSpacing: 8.0,
//                     ),
//                     itemCount: pictures.length,
//                     itemBuilder: (context, index) {
//                       final picture = pictures[index];
//                       return GestureDetector(
//                         onTap: () =>
//                             _showFullImage(picture['picUrl'], picture['note']),
//                         child: CachedNetworkImage(
//                           imageUrl: picture['picUrl'],
//                           placeholder: (context, url) =>
//                               const CircularProgressIndicator(),
//                           errorWidget: (context, url, error) =>
//                               const Icon(Icons.error),
//                           fit: BoxFit.cover,
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  //
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;

// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class GalleryTab extends StatefulWidget {
//   final String clinicId;
//   final String patientId;
//   final String treatmentId;

//   const GalleryTab({
//     Key? key,
//     required this.clinicId,
//     required this.patientId,
//     required this.treatmentId,
//   }) : super(key: key);

//   @override
//   State<GalleryTab> createState() => _GalleryTabState();
// }

// class _GalleryTabState extends State<GalleryTab> {
//   List<Map<String, dynamic>> pictures = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadPictures();
//   }

//   Future<void> _loadPictures() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(widget.clinicId)
//         .collection('patients')
//         .doc(widget.patientId)
//         .collection('treatments')
//         .doc(widget.treatmentId)
//         .collection('pictures')
//         .get();

//     setState(() {
//       pictures = snapshot.docs.map((doc) => doc.data()).toList();
//     });
//   }

//   void _showFullImage(String picUrl, String? description) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Expanded(
//                 child: CachedNetworkImage(
//                   imageUrl: picUrl,
//                   placeholder: (context, url) =>
//                       const CircularProgressIndicator(),
//                   errorWidget: (context, url, error) => const Icon(Icons.error),
//                 ),
//               ),
//               if (description != null && description.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     description,
//                     style: MyTextStyle.textStyleMap['label-medium']
//                         ?.copyWith(color: MyColors.colorPalette['on-surface']),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Text(
//             'Gallery',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//         ),
//         Flexible(
//           child: GridView.builder(
//             padding: const EdgeInsets.all(8.0),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 5,
//               crossAxisSpacing: 8.0,
//               mainAxisSpacing: 8.0,
//             ),
//             itemCount: pictures.length,
//             itemBuilder: (context, index) {
//               final picture = pictures[index];
//               return GestureDetector(
//                 onTap: () => _showFullImage(picture['picUrl'], picture['note']),
//                 child: CachedNetworkImage(
//                   imageUrl: picture['picUrl'],
//                   placeholder: (context, url) =>
//                       const CircularProgressIndicator(),
//                   errorWidget: (context, url, error) => const Icon(Icons.error),
//                   fit: BoxFit.cover,
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
