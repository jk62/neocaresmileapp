import 'package:flutter/material.dart';

class PatientPictureOverlayScreen extends StatefulWidget {
  final String? imageUrl; // Existing patient image URL
  final Function onTakePicture; // Callback to trigger picture-taking

  const PatientPictureOverlayScreen({
    super.key,
    this.imageUrl,
    required this.onTakePicture,
  });

  @override
  State<PatientPictureOverlayScreen> createState() =>
      _PatientPictureOverlayScreenState();
}

class _PatientPictureOverlayScreenState
    extends State<PatientPictureOverlayScreen> {
  bool _isLoading = false; // Loading state

  void _handleTakePicture() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    await widget.onTakePicture(); // Call the picture-taking function

    setState(() {
      _isLoading = false; // Stop loading after picture upload
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                ? Image.network(widget.imageUrl!)
                : Image.asset('assets/images/default-image.png'),
          ),
          Positioned(
            bottom: 32,
            right: 32,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _handleTakePicture,
              child: const Icon(Icons.edit,
                  color: Colors.black), // Trigger the picture-taking process
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
