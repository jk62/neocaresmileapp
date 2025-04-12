import 'dart:io';
import 'package:flutter/foundation.dart'; // For using compute
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

// class ImageService {
//   final String clinicId;

//   ImageService(this.clinicId);
//---------------------------------//
class ImageService {
  final String clinicId;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ImageService(this.clinicId,
      {FirebaseFirestore? firestoreInstance, FirebaseStorage? storageInstance})
      : firestore = firestoreInstance ?? FirebaseFirestore.instance,
        storage = storageInstance ?? FirebaseStorage.instance;
//--------------------------------//

  // Upload a single image
  Future<String> _uploadImage(File imageFile) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('images/${Uuid().v4()}.png');
    final uploadTask = await storageRef.putFile(imageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  // Upload multiple images using isolate
  Future<List<String>> _uploadImages(List<File> imageFiles) async {
    return await compute(_uploadImagesInIsolate, imageFiles);
  }

  // Add a single image
  Future<void> addImage(
      File imageFile, Map<String, dynamic> imageMetadata) async {
    final String downloadUrl = await _uploadImage(imageFile);

    final docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('images')
        .doc();

    imageMetadata['imageId'] = docRef.id;
    imageMetadata['imageUrl'] = downloadUrl;

    await docRef.set(imageMetadata);
  }

  // Add multiple images
  Future<void> addImages(
      List<File> imageFiles, List<Map<String, dynamic>> imagesMetadata) async {
    final List<String> downloadUrls = await _uploadImages(imageFiles);

    for (int i = 0; i < imagesMetadata.length; i++) {
      final docRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('images')
          .doc();

      imagesMetadata[i]['imageId'] = docRef.id;
      imagesMetadata[i]['imageUrl'] = downloadUrls[i];

      await docRef.set(imagesMetadata[i]);
    }
  }

  // Update a single image
  Future<void> updateImage(File? imageFile, Map<String, dynamic> imageMetadata,
      String imageId) async {
    // If there's a new image file, upload it and update the imageUrl
    if (imageFile != null) {
      final String downloadUrl = await _uploadImage(imageFile);
      imageMetadata['imageUrl'] = downloadUrl;
    }

    final docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('images')
        .doc(imageId);

    await docRef.update(imageMetadata);
  }

  // Update multiple images
  Future<void> updateImages(List<File?> imageFiles,
      List<Map<String, dynamic>> imagesMetadata, List<String> imageIds) async {
    final List<String?> downloadUrls =
        await compute(_updateImagesInIsolate, imageFiles);

    for (int i = 0; i < imagesMetadata.length; i++) {
      if (downloadUrls[i] != null) {
        imagesMetadata[i]['imageUrl'] = downloadUrls[i]!;
      }

      final docRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('images')
          .doc(imageIds[i]);

      await docRef.update(imagesMetadata[i]);
    }
  }

  // Delete a single image
  Future<void> deleteImage(String imageId, String imageUrl) async {
    // Delete the image metadata from Firestore
    final docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('images')
        .doc(imageId);

    await docRef.delete();

    // Delete the image file from Firebase Storage
    final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
    await storageRef.delete();
  }

  // Delete multiple images
  Future<void> deleteImages(
      List<String> imageIds, List<String> imageUrls) async {
    await compute(_deleteImagesInIsolate,
        {'imageIds': imageIds, 'imageUrls': imageUrls, 'clinicId': clinicId});
  }

  // Get all images
  Future<List<Map<String, dynamic>>> getAllImages() async {
    final imagesCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('images');

    final querySnapshot = await imagesCollection.get();
    List<Map<String, dynamic>> allImages = [];

    for (var doc in querySnapshot.docs) {
      allImages.add(doc.data());
    }

    return allImages;
  }

  // Search images by name
  Future<List<Map<String, dynamic>>> searchImages(String query) async {
    final imagesCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('images');

    final querySnapshot = await imagesCollection.get();
    List<Map<String, dynamic>> matchingImages = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final imageName = data['imageName'].toString().toLowerCase();

      if (imageName.startsWith(query.toLowerCase())) {
        matchingImages.add(data);
      }
    }

    return matchingImages;
  }

  // Top-level function to upload multiple images
  static Future<List<String>> _uploadImagesInIsolate(
      List<File> imageFiles) async {
    List<String> downloadUrls = [];

    for (File imageFile in imageFiles) {
      final storageRef =
          FirebaseStorage.instance.ref().child('images/${Uuid().v4()}.png');
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    return downloadUrls;
  }

  // Top-level function to update multiple images
  static Future<List<String?>> _updateImagesInIsolate(
      List<File?> imageFiles) async {
    List<String?> downloadUrls = [];

    for (File? imageFile in imageFiles) {
      if (imageFile != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('images/${Uuid().v4()}.png');
        final uploadTask = await storageRef.putFile(imageFile);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } else {
        downloadUrls.add(null); // No update for this image
      }
    }

    return downloadUrls;
  }

  // Top-level function to delete multiple images
  static Future<void> _deleteImagesInIsolate(Map<String, dynamic> data) async {
    final List<String> imageIds = List<String>.from(data['imageIds']);
    final List<String> imageUrls = List<String>.from(data['imageUrls']);
    final String clinicId = data['clinicId'];

    for (int i = 0; i < imageIds.length; i++) {
      final docRef = FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('images')
          .doc(imageIds[i]);

      await docRef.delete();

      final storageRef = FirebaseStorage.instance.refFromURL(imageUrls[i]);
      await storageRef.delete();
    }
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// code below stable without FirebaseFirestore and FirebaseStorage instances as constructor parameters
// import 'dart:io';
// import 'package:flutter/foundation.dart'; // For using compute
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:uuid/uuid.dart';

// class ImageService {
//   final String clinicId;

//   ImageService(this.clinicId);

//   // Upload a single image
//   Future<String> _uploadImage(File imageFile) async {
//     final storageRef =
//         FirebaseStorage.instance.ref().child('images/${Uuid().v4()}.png');
//     final uploadTask = await storageRef.putFile(imageFile);
//     final downloadUrl = await uploadTask.ref.getDownloadURL();
//     return downloadUrl;
//   }

//   // Upload multiple images using isolate
//   Future<List<String>> _uploadImages(List<File> imageFiles) async {
//     return await compute(_uploadImagesInIsolate, imageFiles);
//   }

//   // Add a single image
//   Future<void> addImage(
//       File imageFile, Map<String, dynamic> imageMetadata) async {
//     final String downloadUrl = await _uploadImage(imageFile);

//     final docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('images')
//         .doc();

//     imageMetadata['imageId'] = docRef.id;
//     imageMetadata['imageUrl'] = downloadUrl;

//     await docRef.set(imageMetadata);
//   }

//   // Add multiple images
//   Future<void> addImages(
//       List<File> imageFiles, List<Map<String, dynamic>> imagesMetadata) async {
//     final List<String> downloadUrls = await _uploadImages(imageFiles);

//     for (int i = 0; i < imagesMetadata.length; i++) {
//       final docRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('images')
//           .doc();

//       imagesMetadata[i]['imageId'] = docRef.id;
//       imagesMetadata[i]['imageUrl'] = downloadUrls[i];

//       await docRef.set(imagesMetadata[i]);
//     }
//   }

//   // Update a single image
//   Future<void> updateImage(File? imageFile, Map<String, dynamic> imageMetadata,
//       String imageId) async {
//     // If there's a new image file, upload it and update the imageUrl
//     if (imageFile != null) {
//       final String downloadUrl = await _uploadImage(imageFile);
//       imageMetadata['imageUrl'] = downloadUrl;
//     }

//     final docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('images')
//         .doc(imageId);

//     await docRef.update(imageMetadata);
//   }

//   // Update multiple images
//   Future<void> updateImages(List<File?> imageFiles,
//       List<Map<String, dynamic>> imagesMetadata, List<String> imageIds) async {
//     final List<String?> downloadUrls =
//         await compute(_updateImagesInIsolate, imageFiles);

//     for (int i = 0; i < imagesMetadata.length; i++) {
//       if (downloadUrls[i] != null) {
//         imagesMetadata[i]['imageUrl'] = downloadUrls[i]!;
//       }

//       final docRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('images')
//           .doc(imageIds[i]);

//       await docRef.update(imagesMetadata[i]);
//     }
//   }

//   // Delete a single image
//   Future<void> deleteImage(String imageId, String imageUrl) async {
//     // Delete the image metadata from Firestore
//     final docRef = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('images')
//         .doc(imageId);

//     await docRef.delete();

//     // Delete the image file from Firebase Storage
//     final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
//     await storageRef.delete();
//   }

//   // Delete multiple images
//   Future<void> deleteImages(
//       List<String> imageIds, List<String> imageUrls) async {
//     await compute(_deleteImagesInIsolate,
//         {'imageIds': imageIds, 'imageUrls': imageUrls, 'clinicId': clinicId});
//   }

//   // Get all images
//   Future<List<Map<String, dynamic>>> getAllImages() async {
//     final imagesCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('images');

//     final querySnapshot = await imagesCollection.get();
//     List<Map<String, dynamic>> allImages = [];

//     for (var doc in querySnapshot.docs) {
//       allImages.add(doc.data());
//     }

//     return allImages;
//   }

//   // Search images by name
//   Future<List<Map<String, dynamic>>> searchImages(String query) async {
//     final imagesCollection = FirebaseFirestore.instance
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('images');

//     final querySnapshot = await imagesCollection.get();
//     List<Map<String, dynamic>> matchingImages = [];

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data();
//       final imageName = data['imageName'].toString().toLowerCase();

//       if (imageName.startsWith(query.toLowerCase())) {
//         matchingImages.add(data);
//       }
//     }

//     return matchingImages;
//   }

//   // Top-level function to upload multiple images
//   static Future<List<String>> _uploadImagesInIsolate(
//       List<File> imageFiles) async {
//     List<String> downloadUrls = [];

//     for (File imageFile in imageFiles) {
//       final storageRef =
//           FirebaseStorage.instance.ref().child('images/${Uuid().v4()}.png');
//       final uploadTask = await storageRef.putFile(imageFile);
//       final downloadUrl = await uploadTask.ref.getDownloadURL();
//       downloadUrls.add(downloadUrl);
//     }

//     return downloadUrls;
//   }

//   // Top-level function to update multiple images
//   static Future<List<String?>> _updateImagesInIsolate(
//       List<File?> imageFiles) async {
//     List<String?> downloadUrls = [];

//     for (File? imageFile in imageFiles) {
//       if (imageFile != null) {
//         final storageRef =
//             FirebaseStorage.instance.ref().child('images/${Uuid().v4()}.png');
//         final uploadTask = await storageRef.putFile(imageFile);
//         final downloadUrl = await uploadTask.ref.getDownloadURL();
//         downloadUrls.add(downloadUrl);
//       } else {
//         downloadUrls.add(null); // No update for this image
//       }
//     }

//     return downloadUrls;
//   }

//   // Top-level function to delete multiple images
//   static Future<void> _deleteImagesInIsolate(Map<String, dynamic> data) async {
//     final List<String> imageIds = List<String>.from(data['imageIds']);
//     final List<String> imageUrls = List<String>.from(data['imageUrls']);
//     final String clinicId = data['clinicId'];

//     for (int i = 0; i < imageIds.length; i++) {
//       final docRef = FirebaseFirestore.instance
//           .collection('clinics')
//           .doc(clinicId)
//           .collection('images')
//           .doc(imageIds[i]);

//       await docRef.delete();

//       final storageRef = FirebaseStorage.instance.refFromURL(imageUrls[i]);
//       await storageRef.delete();
//     }
//   }
// }
