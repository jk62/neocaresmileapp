import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neocaresmileapp/constants/routes.dart';
import 'package:neocaresmileapp/services/bloc/auth_bloc.dart';
import 'package:neocaresmileapp/services/bloc/auth_event.dart';
import 'package:neocaresmileapp/services/bloc/auth_state.dart';
import 'package:neocaresmileapp/utilities/dialogs/error_dialog.dart';
import 'dart:developer' as devtools show log;

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  late final TextEditingController _emailController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    devtools.log('Welcome to ChangePasswordView');
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Generic change password state; if an error is present, show an error dialog.
        if (state is AuthStateChangePassword) {
          devtools.log('State: $state');
          if (state.exception != null) {
            showErrorDialog(
              context,
              'We could not process your request. Please make sure that you are a registered user!',
            );
          }
        }
        // On successful password change: clear the fields, show a SnackBar, and then force logout & navigation.
        else if (state is AuthStateChangePasswordSuccess) {
          devtools.log('Password changed successfully.');
          _emailController.clear();
          _currentPasswordController.clear();
          _newPasswordController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(state.loadingText ?? 'Password changed successfully!'),
              duration: const Duration(seconds: 2),
            ),
          );
          // Delay to allow the user to see the confirmation before logging out.
          Future.delayed(const Duration(seconds: 2), () {
            // Dispatch logout event
            context.read<AuthBloc>().add(const AuthEventLogOut());
            // Navigate to the login route managed in main.dart
            Navigator.pushNamedAndRemoveUntil(
              context,
              loginRoute,
              (Route<dynamic> route) => false,
            );
          });
        }
        // On failure, show an error dialog.
        else if (state is AuthStateChangePasswordFailure) {
          showErrorDialog(
              context, 'Failed to change password: ${state.exception}');
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // Optional: You can add a title here if desired.
          // title: const Text('Change Password'),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent,
                Colors.lightBlueAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Change Your Password',
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _currentPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          hintText: 'Enter current password',
                          prefixIcon: const Icon(Icons.lock_open),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          hintText: 'Enter new password',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          final email = _emailController.text;
                          final currentPassword =
                              _currentPasswordController.text;
                          final newPassword = _newPasswordController.text;
                          context.read<AuthBloc>().add(
                                AuthEventChangePassword(
                                  email: email,
                                  newPassword: newPassword,
                                  currentPassword: currentPassword,
                                ),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Change Password'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Force logout and navigate to the login route.
                          context.read<AuthBloc>().add(const AuthEventLogOut());
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            loginRoute,
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text('Back to login page'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../services/bloc/auth_bloc.dart';
// import '../services/bloc/auth_event.dart';
// import '../services/bloc/auth_state.dart';
// import '../utilities/dialogs/error_dialog.dart';
// import '../utilities/dialogs/password_reset_email_sent_dialog.dart';
// import 'dart:developer' as devtools show log;

// class ChangePasswordView extends StatefulWidget {
//   const ChangePasswordView({super.key});

//   @override
//   State<ChangePasswordView> createState() => _ChangePasswordViewState();
// }

// class _ChangePasswordViewState extends State<ChangePasswordView> {
//   late final TextEditingController _emailController;
//   late final TextEditingController _currentPasswordController;
//   late final TextEditingController _newPasswordController;

//   @override
//   void initState() {
//     _emailController = TextEditingController();
//     _currentPasswordController = TextEditingController();
//     _newPasswordController = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _currentPasswordController.dispose();
//     _newPasswordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to ChangePasswordView');
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthStateChangePassword) {
//           devtools.log('state is $state');
//           if (state.exception != null) {
//             showErrorDialog(context,
//                 'We could not process your request. Please make sure that you are a registered user!');
//           }
//         } else if (state is AuthStateChangePasswordSuccess) {
//           devtools.log(
//               'This is coming from inside ChangePasswordView. state is $AuthStateChangePasswordSuccess. Password changed successfully');
//           _emailController.clear();
//           _currentPasswordController.clear();
//           _newPasswordController.clear();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//                     state.loadingText ?? 'Password changed successfully!')),
//           );
//         } else if (state is AuthStateChangePasswordFailure) {
//           showErrorDialog(
//               context, 'Failed to change password: ${state.exception}');
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Change Password'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               const Text(
//                   'Enter your email, current password, new password and press Change Password button to change your password!'),
//               TextField(
//                 keyboardType: TextInputType.emailAddress,
//                 autocorrect: false,
//                 autofocus: true,
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   hintText: 'Your email address ...',
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 obscureText: true,
//                 controller: _currentPasswordController,
//                 decoration: const InputDecoration(
//                   hintText: 'Current Password ...',
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 obscureText: true,
//                 controller: _newPasswordController,
//                 decoration: const InputDecoration(
//                   hintText: 'New Password ...',
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextButton(
//                 onPressed: () {
//                   final email = _emailController.text;
//                   final currentPassword = _currentPasswordController.text;
//                   final newPassword = _newPasswordController.text;
//                   context.read<AuthBloc>().add(
//                         AuthEventChangePassword(
//                           email: email,
//                           newPassword: newPassword,
//                           currentPassword: currentPassword,
//                         ),
//                       );
//                 },
//                 child: const Text('Change Password'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   logout(context);
//                 },
//                 child: const Text('Back to login page'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> logout(BuildContext context) async {
//     context.read<AuthBloc>().add(
//           const AuthEventLogOut(),
//         );
//     devtools.log('AuthEventLogOut triggered');
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../services/bloc/auth_bloc.dart';
// import '../services/bloc/auth_event.dart';
// import '../services/bloc/auth_state.dart';
// import '../utilities/dialogs/error_dialog.dart';
// import '../utilities/dialogs/password_reset_email_sent_dialog.dart';
// import 'dart:developer' as devtools show log;

// class ChangePasswordView extends StatefulWidget {
//   const ChangePasswordView({Key? key}) : super(key: key);

//   @override
//   State<ChangePasswordView> createState() => _ChangePasswordViewState();
// }

// class _ChangePasswordViewState extends State<ChangePasswordView> {
//   late final TextEditingController _emailController;
//   late final TextEditingController _passwordController;

//   @override
//   void initState() {
//     _emailController = TextEditingController();
//     _passwordController = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthStateChangePassword) {
//           devtools.log('state is $state');
//           if (state.hasSentEmail) {
//             _emailController.clear();
//             showPasswordResetSentDialog(context);
//           }
//           if (state.exception != null) {
//             showErrorDialog(context,
//                 'We could not process your request. Please make sure that you are a registered user!');
//           }
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Change Password'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               const Text(
//                   'Enter your email, new password and press Change Password button to receive the password reset link to change the password!'),
//               TextField(
//                 keyboardType: TextInputType.emailAddress,
//                 autocorrect: false,
//                 autofocus: true,
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   hintText: 'Your email address ...',
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 obscureText: true,
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   hintText: 'New Password ...',
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextButton(
//                 onPressed: () {
//                   final email = _emailController.text;
//                   context.read<AuthBloc>().add(
//                         AuthEventChangePassword(
//                           email: email,
//                           newPassword: _passwordController.text,
//                         ),
//                       );
//                 },
//                 child: const Text('Change Password'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   logout(context);
//                 },
//                 child: const Text('Back to login page'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> logout(BuildContext context) async {
//     context.read<AuthBloc>().add(
//           const AuthEventLogOut(),
//         );
//   }
// }

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//