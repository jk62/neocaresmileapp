import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/bloc/auth_bloc.dart';
import '../services/bloc/auth_event.dart';

class PendingApprovalView extends StatelessWidget {
  const PendingApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approval'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_empty, size: 64, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'Your account is pending approval.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'You have successfully logged in, but have not been mapped to any clinic yet. '
                'Please wait for an administrator to approve your access.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(const AuthEventLogOut());

                  // Give it a short delay to allow logout to finish
                  await Future.delayed(const Duration(milliseconds: 500));

                  exit(0); // Immediately exits the app
                },
                child: const Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
