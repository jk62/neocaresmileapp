import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/bloc/auth_bloc.dart';
import '../services/bloc/auth_event.dart';
import 'dart:developer' as devtools show log; // Import developer log

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  Timer? _pollingTimer;
  bool _isResending = false; // To show loading on resend button

  @override
  void initState() {
    super.initState();
    devtools.log('VerifyEmailView: initState'); // Add log
    // Send initial verification email immediately when screen loads
    _sendVerificationEmail(
        showSnackbar: false); // Don't show snackbar on initial send
    _startEmailVerificationPoller();
  }

  // Helper function to send email
  Future<void> _sendVerificationEmail({bool showSnackbar = true}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      // Check if user exists and not verified
      try {
        devtools.log(
            'VerifyEmailView: Sending verification email to ${user.email}'); // Add log
        await user.sendEmailVerification();
        if (showSnackbar && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '📬 Verification email sent! Check your inbox (and spam).'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        devtools.log(
            'VerifyEmailView: Error sending verification email: $e'); // Add log
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error sending email: ${e.toString()}'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } else if (user == null) {
      devtools.log(
          'VerifyEmailView: Cannot send verification email, user is null.'); // Add log
      // Optional: Navigate back to login if user becomes null unexpectedly
      // context.read<AuthBloc>().add(const AuthEventLogOut());
    }
  }

  void _startEmailVerificationPoller() {
    devtools
        .log('VerifyEmailView: Starting email verification poller.'); // Add log
    // Cancel existing timer just in case
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // Increased interval slightly
      final user = FirebaseAuth.instance.currentUser;
      // Important: Reload BEFORE checking emailVerified
      try {
        devtools.log('VerifyEmailView: Polling - Reloading user...'); // Add log
        await user?.reload();
      } catch (e) {
        devtools.log('VerifyEmailView: Error reloading user: $e'); // Add log
        // Handle specific errors like user-token-expired, user-disabled if needed
        if (e is FirebaseAuthException &&
            (e.code == 'user-disabled' || e.code == 'user-not-found')) {
          timer.cancel();
          devtools.log(
              'VerifyEmailView: User disabled or not found during poll. Logging out.'); // Add log
          if (mounted) {
            context.read<AuthBloc>().add(const AuthEventLogOut());
          }
          return; // Stop further processing
        }
        // For other errors, maybe just log and continue polling
      }

      // Get the potentially updated user object AFTER reload
      final updatedUser = FirebaseAuth.instance.currentUser;
      devtools.log(
          'VerifyEmailView: Polling - User verified: ${updatedUser?.emailVerified}'); // Add log

      if (updatedUser != null && updatedUser.emailVerified) {
        timer.cancel();
        devtools.log(
            'VerifyEmailView: Email verified! Triggering AuthEventInitialize.'); // Add log
        if (mounted) {
          // Trigger re-initialization which will fetch data and move to HomePage/Pending
          context.read<AuthBloc>().add(const AuthEventInitialize());
        }
      } else if (updatedUser == null) {
        // If user becomes null during polling (e.g., deleted externally)
        timer.cancel();
        devtools.log(
            'VerifyEmailView: User became null during poll. Logging out.'); // Add log
        if (mounted) {
          context.read<AuthBloc>().add(const AuthEventLogOut());
        }
      }
    });
  }

  @override
  void dispose() {
    devtools.log('VerifyEmailView: dispose - Cancelling timer.'); // Add log
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleResendEmail() async {
    if (_isResending) return; // Prevent multiple clicks

    setState(() {
      _isResending = true;
    });
    await _sendVerificationEmail(showSnackbar: true); // Send and show snackbar
    // Add a small delay before allowing resend again if desired
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      // Check if still mounted after delay
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    devtools.log('VerifyEmailView: Building UI'); // Add log
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        centerTitle: true,
      ),
      body: Center(
        // Center the content vertically
        child: Padding(
          padding: const EdgeInsets.all(24.0), // More padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons
            children: [
              const Icon(
                Icons.mark_email_read_outlined, // Email icon
                size: 80,
                color: Colors.blueAccent, // Or your theme color
              ),
              const SizedBox(height: 24),
              const Text(
                'Verification Email Sent',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                // Provide more specific instruction
                'We\'ve sent a verification link to ${FirebaseAuth.instance.currentUser?.email ?? 'your email address'}. '
                'Please click the link in the email to activate your account.\n\n'
                'This screen will update automatically once verified.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),
              // Conditionally show loading or button for resend
              _isResending
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.outgoing_mail),
                      label: const Text('Resend Verification Email'),
                      onPressed: _handleResendEmail,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  devtools.log(
                      'VerifyEmailView: Logout button pressed.'); // Add log
                  // Cancel timer before logging out
                  _pollingTimer?.cancel();
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: const Text('Log Out'), // Simpler text
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../services/bloc/auth_bloc.dart';
// import '../services/bloc/auth_event.dart';

// class VerifyEmailView extends StatefulWidget {
//   const VerifyEmailView({super.key});

//   @override
//   State<VerifyEmailView> createState() => _VerifyEmailViewState();
// }

// class _VerifyEmailViewState extends State<VerifyEmailView> {
//   Timer? _pollingTimer;
//   ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
//       _snackBarController;

//   @override
//   void initState() {
//     super.initState();
//     _startEmailVerificationPoller();

//     // Show a persistent snackbar on init
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('⏳ Waiting for email verification...'),
//           duration: Duration(hours: 1), // effectively infinite
//         ),
//       );
//     });
//   }

//   void _startEmailVerificationPoller() {
//     _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
//       await FirebaseAuth.instance.currentUser?.reload();
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null && user.emailVerified) {
//         timer.cancel();

//         // Dismiss snackbar
//         _snackBarController?.close();

//         if (mounted) {
//           context.read<AuthBloc>().add(const AuthEventInitialize());
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _pollingTimer?.cancel();
//     _snackBarController?.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Verify Email')),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Text(
//               'A verification email has been sent to your email address. '
//               'Please verify it to continue.',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//           const SizedBox(height: 16),
//           const CircularProgressIndicator(), // spinner
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () async {
//               final user = FirebaseAuth.instance.currentUser;
//               await user?.sendEmailVerification();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('📬 Verification email re-sent!')),
//               );
//             },
//             child: const Text('Resend verification email'),
//           ),
//           const SizedBox(height: 8),
//           TextButton(
//             onPressed: () {
//               context.read<AuthBloc>().add(const AuthEventLogOut());
//             },
//             child: const Text('Restart / Back to Login'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
