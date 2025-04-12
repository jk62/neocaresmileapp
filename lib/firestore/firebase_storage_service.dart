import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage storage;

  FirebaseStorageService({FirebaseStorage? storageInstance})
      : storage = storageInstance ?? FirebaseStorage.instance;

  Future<String> getDownloadUrl(String gsPath) async {
    final ref = storage.refFromURL(gsPath);
    return await ref.getDownloadURL();
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:firebase_storage/firebase_storage.dart';

// class FirebaseStorageService {
//   static Future<String> getDownloadUrl(String gsPath) async {
//     final ref = FirebaseStorage.instance.refFromURL(gsPath);
//     return await ref.getDownloadURL();
//   }
// }
