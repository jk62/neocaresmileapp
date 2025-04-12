import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as devtools show log;

class ImageCacheProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _pictures = [];
  final Set<String> _deletedPictureIds = {};
  final Set<String> _deletedPictureDocIds = {};
  String? _clinicId; // New field to store the current clinicId

  List<Map<String, dynamic>> get pictures => List.unmodifiable(_pictures);
  Set<String> get deletedPictureIds => Set.unmodifiable(_deletedPictureIds);
  Set<String> get deletedPictureDocIds =>
      Set.unmodifiable(_deletedPictureDocIds);

  //--------------------------------------------------------------------------//
  // Method to set the clinic ID dynamically
  void setClinicId(String clinicId) {
    if (_clinicId != clinicId) {
      _clinicId = clinicId;
      devtools.log('Clinic ID changed to: $_clinicId');

      // Clear all pictures when clinic changes
      clearPictures();
      notifyListeners();
    }
  }
  //--------------------------------------------------------------------------//

  void addPicture(Map<String, dynamic> picture) {
    try {
      _pictures.add(picture);
      devtools.log(
          'Welcome to ImageCacheProvider. addPicture invoked. Picture added to cache: $picture');
      notifyListeners();
    } catch (e) {
      devtools.log('Error adding picture to cache: $e');
    }
  }

  void removePicture(String picId) {
    try {
      _pictures.removeWhere((picture) => picture['picId'] == picId);
      _deletedPictureIds.add(picId);
      devtools.log(
          'Welcome to ImageCacheProvider. removePicture invoked. Picture removed from cache. picId: $picId');
      notifyListeners();
    } catch (e) {
      devtools.log('Error removing picture from cache: $e');
    }
  }

  void addDeletedPictureDocId(String docId) {
    try {
      _deletedPictureDocIds.add(docId);
      devtools.log(
          'Welcome to ImageCacheProvider. addDeletedPictureDocId invoked. Deleted picture docId added: $docId');
      notifyListeners();
    } catch (e) {
      devtools.log('Error adding deleted picture docId: $e');
    }
  }

  void clearPictures() {
    try {
      _pictures.clear();
      _deletedPictureIds.clear();
      _deletedPictureDocIds.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      devtools.log(
          'Welcome to ImageCacheProvider. clearPictures invoked. Cleared all pictures from cache.');
    } catch (e) {
      devtools.log('Error clearing pictures from cache: $e');
    }
  }

  void updatePicture(String picId, Map<String, dynamic> updatedPicture) {
    try {
      int index = _pictures.indexWhere((picture) => picture['picId'] == picId);
      if (index != -1) {
        _pictures[index] = updatedPicture;
        devtools.log(
            'Welcome to ImageCacheProvider. updatePicture invoked. Updated picture in cache. picId: $picId');
        notifyListeners();
      } else {
        devtools.log('Picture with picId: $picId not found for update.');
      }
    } catch (e) {
      devtools.log('Error updating picture in cache: $e');
    }
  }

  void addPictures(List<Map<String, dynamic>> pictures) {
    try {
      _pictures.addAll(pictures);
      devtools.log(
          'Welcome to ImageCacheProvider. addPictures invoked. Added multiple pictures to cache.');
      notifyListeners();
    } catch (e) {
      devtools.log('Error adding multiple pictures to cache: $e');
    }
  }

  void markPictureForDeletion(String picId, String picUrl) {
    try {
      devtools.log(
          'Welcome to ImageCacheProvider. markPictureForDeletion invoked. Marking picture for deletion. picId: $picId, picUrl: $picUrl');
      final pictureIndex =
          pictures.indexWhere((picture) => picture['picId'] == picId);
      if (pictureIndex != -1) {
        pictures[pictureIndex]['isMarkedForDeletion'] = true;
        pictures[pictureIndex]['picUrl'] = picUrl;
        devtools.log(
            'Welcome to ImageCacheProvider. markPictureForDeletion invoked. Marked picture for deletion in cache. picId: $picId');
        notifyListeners();
      } else {
        devtools.log(
            'Welcome to ImageCacheProvider. markPictureForDeletion invoked. Picture with picId: $picId not found for deletion.');
      }
    } catch (e) {
      devtools.log('Error marking picture for deletion: $e');
    }
  }

  // Method to clear the image cache
  Future<void> clearImageCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory(directory.path);
      final files = dir.listSync();

      for (var file in files) {
        if (file is File) {
          await file.delete();
        }
      }

      clearPictures(); // Clear in-memory cache
      devtools.log(
          'Welcome to ImageCacheProvider. clearImageCache invoked which further invoked clearPictures. Cleared image cache from filesystem and in-memory cache.');
    } catch (e) {
      devtools.log('Error clearing image cache: $e');
    }
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE BEFORE THE INTRODUCTION OF CHANGENOTIFIERPROXYPROVIDER
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:developer' as devtools show log;

// class ImageCacheProvider extends ChangeNotifier {
//   final List<Map<String, dynamic>> _pictures = [];
//   final Set<String> _deletedPictureIds = {};
//   final Set<String> _deletedPictureDocIds = {};

//   List<Map<String, dynamic>> get pictures => List.unmodifiable(_pictures);
//   Set<String> get deletedPictureIds => Set.unmodifiable(_deletedPictureIds);
//   Set<String> get deletedPictureDocIds =>
//       Set.unmodifiable(_deletedPictureDocIds);

//   void addPicture(Map<String, dynamic> picture) {
//     try {
//       _pictures.add(picture);
//       devtools.log(
//           'Welcome to ImageCacheProvider. addPicture invoked. Picture added to cache: $picture');
//       notifyListeners();
//     } catch (e) {
//       devtools.log('Error adding picture to cache: $e');
//     }
//   }

//   void removePicture(String picId) {
//     try {
//       _pictures.removeWhere((picture) => picture['picId'] == picId);
//       _deletedPictureIds.add(picId);
//       devtools.log(
//           'Welcome to ImageCacheProvider. removePicture invoked. Picture removed from cache. picId: $picId');
//       notifyListeners();
//     } catch (e) {
//       devtools.log('Error removing picture from cache: $e');
//     }
//   }

//   void addDeletedPictureDocId(String docId) {
//     try {
//       _deletedPictureDocIds.add(docId);
//       devtools.log(
//           'Welcome to ImageCacheProvider. addDeletedPictureDocId invoked. Deleted picture docId added: $docId');
//       notifyListeners();
//     } catch (e) {
//       devtools.log('Error adding deleted picture docId: $e');
//     }
//   }

//   void clearPictures() {
//     try {
//       _pictures.clear();
//       _deletedPictureIds.clear();
//       _deletedPictureDocIds.clear();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         notifyListeners();
//       });
//       devtools.log(
//           'Welcome to ImageCacheProvider. clearPictures invoked. Cleared all pictures from cache.');
//     } catch (e) {
//       devtools.log('Error clearing pictures from cache: $e');
//     }
//   }

//   void updatePicture(String picId, Map<String, dynamic> updatedPicture) {
//     try {
//       int index = _pictures.indexWhere((picture) => picture['picId'] == picId);
//       if (index != -1) {
//         _pictures[index] = updatedPicture;
//         devtools.log(
//             'Welcome to ImageCacheProvider. updatePicture invoked. Updated picture in cache. picId: $picId');
//         notifyListeners();
//       } else {
//         devtools.log('Picture with picId: $picId not found for update.');
//       }
//     } catch (e) {
//       devtools.log('Error updating picture in cache: $e');
//     }
//   }

//   void addPictures(List<Map<String, dynamic>> pictures) {
//     try {
//       _pictures.addAll(pictures);
//       devtools.log(
//           'Welcome to ImageCacheProvider. addPictures invoked. Added multiple pictures to cache.');
//       notifyListeners();
//     } catch (e) {
//       devtools.log('Error adding multiple pictures to cache: $e');
//     }
//   }

//   void markPictureForDeletion(String picId, String picUrl) {
//     try {
//       devtools.log(
//           'Welcome to ImageCacheProvider. markPictureForDeletion invoked. Marking picture for deletion. picId: $picId, picUrl: $picUrl');
//       final pictureIndex =
//           pictures.indexWhere((picture) => picture['picId'] == picId);
//       if (pictureIndex != -1) {
//         pictures[pictureIndex]['isMarkedForDeletion'] = true;
//         pictures[pictureIndex]['picUrl'] = picUrl;
//         devtools.log(
//             'Welcome to ImageCacheProvider. markPictureForDeletion invoked. Marked picture for deletion in cache. picId: $picId');
//         notifyListeners();
//       } else {
//         devtools.log(
//             'Welcome to ImageCacheProvider. markPictureForDeletion invoked. Picture with picId: $picId not found for deletion.');
//       }
//     } catch (e) {
//       devtools.log('Error marking picture for deletion: $e');
//     }
//   }

//   // Method to clear the image cache
//   Future<void> clearImageCache() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final dir = Directory(directory.path);
//       final files = dir.listSync();

//       for (var file in files) {
//         if (file is File) {
//           await file.delete();
//         }
//       }

//       clearPictures(); // Clear in-memory cache
//       devtools.log(
//           'Welcome to ImageCacheProvider. clearImageCache invoked which further invoked clearPictures. Cleared image cache from filesystem and in-memory cache.');
//     } catch (e) {
//       devtools.log('Error clearing image cache: $e');
//     }
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
