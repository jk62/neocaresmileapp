import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/bloc/auth_bloc.dart';
import '../services/bloc/auth_event.dart';
import '../services/bloc/auth_state.dart';
import '../utilities/dialogs/error_dialog.dart';
import '../utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            showErrorDialog(
              context,
              'We could not process your request. Please make sure that you are a registered user!',
            );
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // You can choose to remove the AppBar entirely if you’d like
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text('Forgot Password'),
        ),
        body: Container(
          decoration: BoxDecoration(
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
                      const Text(
                        'Forgot your password?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Enter your email and we will send you a password reset link.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email address',
                          hintText: 'Your email address...',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          final email = _controller.text;
                          context
                              .read<AuthBloc>()
                              .add(AuthEventForgotPassword(email));
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Send Reset Link'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Navigate back to the login page
                          Navigator.of(context).pop();
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

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../services/bloc/auth_bloc.dart';
// import '../services/bloc/auth_event.dart';
// import '../services/bloc/auth_state.dart';
// import '../utilities/dialogs/error_dialog.dart';
// import '../utilities/dialogs/password_reset_email_sent_dialog.dart';

// class ForgotPasswordView extends StatefulWidget {
//   const ForgotPasswordView({super.key});

//   @override
//   State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
// }

// class _ForgotPasswordViewState extends State<ForgotPasswordView> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     _controller = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthStateForgotPassword) {
//           if (state.hasSentEmail) {
//             _controller.clear();
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
//           title: const Text('Forgot Password'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               const Text(
//                   'If you forgot your password, simply enter your email and we will send you a password reset link!'),
//               TextField(
//                 keyboardType: TextInputType.emailAddress,
//                 autocorrect: false,
//                 autofocus: true,
//                 controller: _controller,
//                 decoration: const InputDecoration(
//                   hintText: 'Your email address .....',
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   final email = _controller.text;
//                   context.read<AuthBloc>().add(
//                         //AuthEventForgotPassword(email: email),
//                         AuthEventForgotPassword(email),
//                       );
//                 },
//                 child: const Text('Send me a password reset link'),
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



// The `ForgotPasswordView` widget represents the forgot password screen of an 
//application. It allows users to enter their email address and request a 
//password reset link. Here's the flow and logic behind the code:

// 1. Widget Initialization: The `ForgotPasswordView` widget extends the 
//`StatefulWidget` class and overrides the `createState` method to create an 
//instance of the `_ForgotPasswordViewState` class, which manages the state of 
//the widget.

// 2. State Initialization: The `_ForgotPasswordViewState` class initializes
// a `TextEditingController` object `_controller` in the `initState` method, 
//which controls the input field for the email address.

// 3. Widget Disposal: The `dispose` method is overridden to dispose of the
// `_controller` when the widget is no longer used.

// 4. Widget Building: The `build` method is overridden to build the widget 
//tree. It returns a `BlocListener` widget from the `flutter_bloc` package,
// which listens to state changes in the `AuthBloc` and reacts accordingly.

// 5. Error Handling and Password Reset Confirmation: Within the `BlocListener`,
// the `listener` callback is defined to handle specific authentication state 
//changes. If the `AuthState` is `AuthStateForgotPassword` and an email reset 
//link has been successfully sent (`state.hasSentEmail` is `true`), the 
//`_controller` is cleared, and the `showPasswordResetSentDialog` function
// is called to show a dialog confirming the password reset email has been
// sent. If there is an exception (`state.exception` is not `null`), the
// `showErrorDialog` function is called to display an error message.

// 6. Scaffold and AppBar: The main structure of the screen is defined 
//using the `Scaffold` widget, which provides the app bar with the title
// "Forgot Password".

// 7. Forgot Password Form: The forgot password form consists of a `TextField`
// widget for the email address input, a "Send me password reset link" button,
// and a "Back to login page" button.

// 8. Send Password Reset Link Button: When the "Send me password reset link" 
//button is pressed, it retrieves the email address from the text field and 
//dispatches an `AuthEventForgotPassword` event to the `AuthBloc` using the 
//`context.read<AuthBloc>().add()` method. This triggers the password reset 
//process.

// 9. Back to Login Page Button: When the "Back to login page" button is 
//pressed, it calls the `logout` function, which dispatches an `AuthEventLogOut`
// event to the `AuthBloc`. This allows the user to go back to the login page.

// The purpose of this code is to provide a complete forgot password screen 
//that integrates with the `AuthBloc` to handle the password reset functionality. 
//It allows users to request a password reset link by entering their email 
//address and provides error handling for unsuccessful requests.