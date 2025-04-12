import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('WhatsApp Integration'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              _launchWhatsApp();
            },
            child: Text('Open WhatsApp'),
          ),
        ),
      ),
    );
  }

  // Function to launch WhatsApp
  void _launchWhatsApp() async {
    String phoneNumber =
        '1234567890'; // Replace with the phone number you want to message
    String message =
        'Hello, this is a test message!'; // Replace with your message

    // Encode the message and phone number
    String url = 'https://wa.me/$phoneNumber/?text=${Uri.encodeFull(message)}';

    // Convert the string URL to a Uri object
    Uri uri = Uri.parse(url);

    // Launch WhatsApp using the url_launcher package
    if (await launcher.canLaunchUrl(uri)) {
      await launcher.launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
