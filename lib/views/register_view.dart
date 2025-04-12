import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:neocaresmileapp/views/login_view.dart';

import '../services/auth/auth_exceptions.dart';
import '../services/bloc/auth_bloc.dart';
import '../services/bloc/auth_event.dart';
import '../services/bloc/auth_state.dart';
import '../utilities/dialogs/error_dialog.dart';
import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    devtools.log('Welcome to enhanced RegisterView');

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateNeedsVerification) {
          Future.microtask(() async {
            await showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Registration Successful!'),
                content: const Text(
                  'A verification email has been sent. Please verify your email and then log in.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Close dialog
                      if (mounted) {
                        Navigator.of(context)
                            .pop(); // Navigate back to LoginView
                      }
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          });
        }

        if (state is AuthStateRegistering && state.exception != null) {
          Future.microtask(() async {
            if (state.exception is EmailAlreadyInUseAuthException) {
              await showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('An error occurred'),
                  content: const Text(
                      'Email already in use! Please try logging in instead.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else if (state.exception is WeakPasswordAuthException) {
              await showErrorDialog(context, 'Weak password!');
            } else if (state.exception is InvalidEmailAuthException) {
              await showErrorDialog(context, 'Invalid email!');
            } else {
              await showErrorDialog(context, 'Registration failed!');
            }
          });
        }
      },
      builder: (context, state) {
        if (state is AuthStateRegistering && state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          // appBar: AppBar(
          //   backgroundColor: Colors.transparent,
          //   elevation: 0,
          //   iconTheme: const IconThemeData(color: Colors.white),
          // ),
          // appBar: AppBar(
          //   backgroundColor: Colors.transparent,
          //   elevation: 0,
          //   leading: IconButton(
          //     icon: const Icon(Icons.arrow_back, color: Colors.white),
          //     onPressed: () {
          //       Navigator.pushAndRemoveUntil(
          //         context,
          //         MaterialPageRoute(builder: (context) => const LoginView()),
          //         (Route<dynamic> route) => false, // Remove all previous routes
          //       );
          //     },
          //   ),
          // ),

          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  // Replace these with your actual color palette or desired colors
                  // Fallback colors are provided in case your map values are null
                  // For example: MyColors.colorPalette['primary'] and MyColors.colorPalette['secondary']
                  Colors.blueAccent,
                  Colors.lightBlueAccent,
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Optional logo or header image
                        //Image.asset('assets/logo.png', height: 80),
                        const SizedBox(height: 16),
                        Text(
                          'Create Account',
                          style:
                              Theme.of(context).textTheme.headline5?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _password,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            final email = _email.text;
                            final password = _password.text;
                            context
                                .read<AuthBloc>()
                                .add(AuthEventRegister(email, password));
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Register'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            context
                                .read<AuthBloc>()
                                .add(const AuthEventLogOut());
                            if (mounted) {
                              Navigator.of(context)
                                  .pop(); // Navigate back to the Login view.
                            }
                          },
                          child: const Text(
                              'Already registered? Go back to login.'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_signin_button/flutter_signin_button.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// import '../services/auth/auth_exceptions.dart';
// import '../services/bloc/auth_bloc.dart';
// import '../services/bloc/auth_event.dart';
// import '../services/bloc/auth_state.dart';
// import '../utilities/dialogs/error_dialog.dart';
// import 'dart:developer' as devtools show log;

// class RegisterView extends StatefulWidget {
//   const RegisterView({super.key});

//   @override
//   State<RegisterView> createState() => _RegisterViewState();
// }

// class _RegisterViewState extends State<RegisterView> {
//   late final TextEditingController _email;
//   late final TextEditingController _password;

  

//   @override
//   void initState() {
//     _email = TextEditingController();
//     _password = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _email.dispose();
//     _password.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to RegisterView build widget!');

//     return BlocConsumer<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthStateNeedsVerification) {
//           Future.microtask(() async {
//             await showDialog(
//               context: context,
//               builder: (dialogContext) => AlertDialog(
//                 title: const Text('Registration successful!'),
//                 content: const Text(
//                   'A verification email has been sent. Please verify and then log in.',
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(dialogContext).pop(); // Close dialog
//                       if (mounted) {
//                         Navigator.of(context).pop(); // Navigate to LoginView
//                       }
//                     },
//                     child: const Text('OK'),
//                   ),
//                 ],
//               ),
//             );
//           });
//         }

//         if (state is AuthStateRegistering && state.exception != null) {
//           Future.microtask(() async {
//             if (state.exception is EmailAlreadyInUseAuthException) {
//               await showDialog(
//                 context: context,
//                 builder: (dialogContext) => AlertDialog(
//                   title: const Text('An error occurred'),
//                   content:
//                       const Text('Email already in use! Go back to login page'),
//                   actions: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(dialogContext).pop(); // Close dialog
//                         if (mounted) {
//                           Navigator.of(context).pop(); // Back to LoginView
//                         }
//                       },
//                       child: const Text('OK'),
//                     ),
//                   ],
//                 ),
//               );
//             } else if (state.exception is WeakPasswordAuthException) {
//               await showErrorDialog(context, 'Weak password!');
//             } else if (state.exception is InvalidEmailAuthException) {
//               await showErrorDialog(context, 'Invalid email!');
//             } else {
//               await showErrorDialog(context, 'Registration failed!');
//             }
//           });
//         }
//       },
//       builder: (context, state) {
//         if (state is AuthStateRegistering && state.isLoading) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         return Scaffold(
//           appBar: AppBar(title: const Text('Register')),
//           body: _buildRegistrationForm(context),
//         );
//       },
//     );
//   }

//   Widget _buildRegistrationForm(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Enter your email and password'),
//           TextField(
//             controller: _email,
//             enableSuggestions: false,
//             autocorrect: false,
//             autofocus: true,
//             keyboardType: TextInputType.emailAddress,
//             decoration: const InputDecoration(
//               hintText: 'Enter your email here!',
//             ),
//           ),
//           TextField(
//             controller: _password,
//             obscureText: true,
//             enableSuggestions: false,
//             autocorrect: false,
//             decoration: const InputDecoration(
//               hintText: 'Enter password here!',
//             ),
//           ),
//           const SizedBox(height: 12),
//           Center(
//             child: Column(
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     final email = _email.text;
//                     final password = _password.text;
//                     context.read<AuthBloc>().add(
//                           AuthEventRegister(email, password),
//                         );
//                   },
//                   child: const Text('Register'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     context.read<AuthBloc>().add(const AuthEventLogOut());
//                     if (mounted) {
//                       Navigator.of(context).pop(); // Back to login
//                     }
//                   },
//                   child:
//                       const Text('Already registered? Go back to login page.'),
//                 ),
                
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
