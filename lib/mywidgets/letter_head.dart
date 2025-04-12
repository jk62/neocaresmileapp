import 'package:flutter/material.dart';

class Letterhead extends StatelessWidget {
  final Widget child;

  const Letterhead({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Letterhead Image
        Positioned.fill(
          child: Image.asset(
            'assets/images/letterhead.png',
            fit: BoxFit.cover,
          ),
        ),
        // Additional Content
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add any additional widgets here
              // Example: Prescription details
              child,
            ],
          ),
        ),
      ],
    );
  }
}

class PrescriptionPage extends StatelessWidget {
  const PrescriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription'),
      ),
      body: const Letterhead(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prescription Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Add more prescription details here
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: PrescriptionPage(),
  ));
}
