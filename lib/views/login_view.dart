import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/home_page.dart';
import 'package:neocaresmileapp/views/forgot_password_view.dart';
import 'package:neocaresmileapp/views/pending_approval_view.dart';
import 'package:neocaresmileapp/views/register_view.dart';
import '../services/auth/auth_exceptions.dart';
import '../services/bloc/auth_bloc.dart';
import '../services/bloc/auth_event.dart';
import '../services/bloc/auth_state.dart';
import '../utilities/dialogs/error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
    devtools.log('Welcome to LoginView with enhanced UI');

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            final shouldRegister = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('User not found'),
                content: const Text(
                    'No account found for this email. Would you like to register?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Register'),
                  ),
                ],
              ),
            );
            if (shouldRegister == true && mounted) {
              context.read<AuthBloc>().add(const AuthEventShouldRegister());
            }
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials!');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        } else if (state is AuthStateRegistering) {
          Future.microtask(() {
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RegisterView(),
                ),
              );
            }
          });
        } else if (state is AuthStateLoggedIn) {
          devtools.log('Logged in: Navigating to HomePage');
          final doctorData = state.doctorData;
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(doctorData: doctorData),
                ),
              );
            }
          });
        } else if (state is AuthStatePendingApproval) {
          Future.microtask(() {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const PendingApprovalView(),
                ),
              );
            }
          });
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MyColors.colorPalette['primary'] ?? Colors.blueAccent,
                MyColors.colorPalette['secondary'] ?? Colors.lightBlueAccent,
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
                      // Logo or header image
                      //Image.asset('assets/logo.png', height: 80),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome Back!',
                        style: MyTextStyle.textStyleMap['title-large'] ??
                            Theme.of(context).textTheme.headline5,
                      ),
                      const SizedBox(height: 24),
                      // Email TextField
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
                      // Password TextField
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
                      // Login Button
                      ElevatedButton(
                        onPressed: () {
                          final email = _email.text;
                          final password = _password.text;
                          context.read<AuthBloc>().add(
                                AuthEventLogin(
                                  email,
                                  password,
                                  doctorData: const {},
                                ),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 12),
                      // Forgot Password
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordView(),
                            ),
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                      const SizedBox(height: 12),
                      // Google Sign-In Button
                      ElevatedButton.icon(
                        onPressed: () {
                          devtools.log('Dispatching AuthEventGoogleSignIn');
                          context
                              .read<AuthBloc>()
                              .add(const AuthEventGoogleSignIn());
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Sign in with Google'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Registration Navigation
                      TextButton(
                        onPressed: () {
                          devtools.log('Dispatching AuthEventShouldRegister');
                          context
                              .read<AuthBloc>()
                              .add(const AuthEventShouldRegister());
                        },
                        child: const Text('Not registered yet? Register now.'),
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

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/home_page.dart';
// import 'package:neocare_dental_app/views/forgot_password_view.dart';
// import 'package:neocare_dental_app/views/pending_approval_view.dart';
// import 'package:neocare_dental_app/views/register_view.dart';
// import '../services/auth/auth_exceptions.dart';
// import '../services/bloc/auth_bloc.dart';
// import '../services/bloc/auth_event.dart';
// import '../services/bloc/auth_state.dart';
// import '../utilities/dialogs/error_dialog.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'dart:developer' as devtools show log;

// class LoginView extends StatefulWidget {
//   const LoginView({super.key});

//   @override
//   State<LoginView> createState() => _LoginViewState();
// }

// class _LoginViewState extends State<LoginView> {
//   late final TextEditingController _email;
//   late final TextEditingController _password;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
//     devtools.log('welcome to login view');

//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) async {
//         if (state is AuthStateLoggedOut) {
//           if (state.exception is UserNotFoundAuthException) {
//             final shouldRegister = await showDialog<bool>(
//               context: context,
//               builder: (context) => AlertDialog(
//                 title: const Text('User not found'),
//                 content: const Text(
//                     'No account found for this email. Would you like to register?'),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(false),
//                     child: const Text('Cancel'),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(true),
//                     child: const Text('Register'),
//                   ),
//                 ],
//               ),
//             );
//             if (shouldRegister == true && mounted) {
//               context.read<AuthBloc>().add(const AuthEventShouldRegister());
//             }
//           } else if (state.exception is WrongPasswordAuthException) {
//             await showErrorDialog(context, 'Wrong credentials!');
//           } else if (state.exception is GenericAuthException) {
//             await showErrorDialog(context, 'Authentication error');
//           }
//         } else if (state is AuthStateRegistering) {
//           Future.microtask(() {
//             if (mounted) {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => const RegisterView(),
//                 ),
//               );
//             }
//           });
//         } else if (state is AuthStateLoggedIn) {
//           devtools
//               .log('Welcome to if AuthStateLoggedIn. Navigating to HomePage');

//           final doctorData = state.doctorData;
//           Future.delayed(const Duration(milliseconds: 100), () {
//             if (mounted) {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => HomePage(
//                     doctorData: doctorData,
//                   ),
//                 ),
//               );
//             }
//           });
//         }
//         //----------------------------------------------------------//
//         else if (state is AuthStatePendingApproval) {
//           Future.microtask(() {
//             if (mounted) {
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(
//                   builder: (context) => const PendingApprovalView(),
//                 ),
//               );
//             }
//           });
//         }

//         //----------------------------------------------------------//
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//           title: Text(
//             'Login View',
//             style: MyTextStyle.textStyleMap['title-large']
//                 ?.copyWith(color: MyColors.colorPalette['on-surface']),
//           ),
//           iconTheme: IconThemeData(
//             color: MyColors.colorPalette['on-surface'],
//           ),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Text(
//                 'You are currently logged out. Please login!',
//                 style: MyTextStyle.textStyleMap['title-medium']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//               TextField(
//                 controller: _email,
//                 enableSuggestions: false,
//                 autocorrect: false,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration:
//                     const InputDecoration(hintText: 'Enter your email here!'),
//               ),
//               TextField(
//                 controller: _password,
//                 obscureText: true,
//                 enableSuggestions: false,
//                 autocorrect: false,
//                 decoration:
//                     const InputDecoration(hintText: 'Enter password here!'),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: () async {
//                   final email = _email.text;
//                   final password = _password.text;

//                   context.read<AuthBloc>().add(
//                         AuthEventLogin(
//                           email,
//                           password,
//                           doctorData: const {},
//                         ),
//                       );
//                 },
//                 child: const Text('Login'),
//               ),
//               const SizedBox(height: 8),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const ForgotPasswordView(),
//                     ),
//                   );
//                 },
//                 child: const Text('I forgot my password!'),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton.icon(
//                 // onPressed: () async {
//                 //   try {
//                 //     final GoogleSignInAccount? googleUser =
//                 //         await _googleSignIn.signIn();
//                 //     if (googleUser != null) {
//                 //       final GoogleSignInAuthentication googleAuth =
//                 //           await googleUser.authentication;
//                 //       final AuthCredential credential =
//                 //           GoogleAuthProvider.credential(
//                 //         accessToken: googleAuth.accessToken,
//                 //         idToken: googleAuth.idToken,
//                 //       );
//                 //       await _firebaseAuth.signInWithCredential(credential);
//                 //     }
//                 //   } catch (e) {
//                 //     if (mounted) {
//                 //       await showErrorDialog(
//                 //           context, 'Failed to sign in with Google!');
//                 //     }
//                 //   }
//                 // },
//                 onPressed: () {
//                   devtools.log('Dispatching AuthEventGoogleSignIn');
//                   context.read<AuthBloc>().add(const AuthEventGoogleSignIn());
//                 },

//                 icon: const Icon(Icons.login),
//                 label: const Text('Sign in with Google'),
//               ),
//               const SizedBox(height: 8),
//               TextButton(
//                 onPressed: () {
//                   devtools.log('Before dispatching AuthEventShouldRegister');
//                   context.read<AuthBloc>().add(const AuthEventShouldRegister());
//                   devtools.log('After dispatching AuthEventShouldRegister');
//                 },
//                 child: const Text('Not registered yet? Register now.'),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

