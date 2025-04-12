import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as devtools show log;

class UploadXrayScreen extends StatefulWidget {
  const UploadXrayScreen({super.key});

  @override
  State<UploadXrayScreen> createState() => _UploadXrayScreenState();
}

class _UploadXrayScreenState extends State<UploadXrayScreen> {
  String? filePath;

  Future<void> downloadAndUploadFile() async {
    const url =
        'http://<laptop-ip>:8000/png_files/output.png'; // Update with the actual URL
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/output.png');
      file.writeAsBytesSync(response.bodyBytes);

      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('xrays/output.png');
      UploadTask uploadTask = ref.putFile(file);

      uploadTask.then((res) {
        res.ref.getDownloadURL().then((url) {
          devtools.log('Uploaded X-ray URL: $url');
        });
      }).catchError((error) {
        devtools.log('Failed to upload X-ray: $error');
      });
    } else {
      devtools.log('Failed to download file');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload X-ray'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: downloadAndUploadFile,
          child: const Text('Download and Upload X-ray'),
        ),
      ),
    );
  }
}
