// flutter run --flavor dev -t lib/main_dev.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neocaresmileapp/constants/routes.dart';
import 'package:neocaresmileapp/firebase_options_dev.dart';
import 'package:neocaresmileapp/helpers/loading_screen.dart';
import 'package:neocaresmileapp/home_page.dart';
import 'package:neocaresmileapp/mywidgets/appointment_provider.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/custom_route_observer.dart';
import 'package:neocaresmileapp/mywidgets/image_cache_provider.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/procedure_cache_provider.dart';
import 'package:neocaresmileapp/mywidgets/recent_patient_provider.dart';
import 'package:neocaresmileapp/mywidgets/user_data_provider.dart';
import 'package:neocaresmileapp/services/auth/firebase_auth_provider.dart';
import 'package:neocaresmileapp/services/bloc/auth_bloc.dart';
import 'package:neocaresmileapp/services/bloc/auth_event.dart';
import 'package:neocaresmileapp/services/bloc/auth_state.dart';
import 'package:neocaresmileapp/views/forgot_password_view.dart';
import 'package:neocaresmileapp/views/login_view.dart';
import 'package:neocaresmileapp/views/pending_approval_view.dart';
import 'package:neocaresmileapp/views/register_view.dart';
import 'package:neocaresmileapp/views/verify_email_view.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

void main() async {
  devtools.log('This is coming from void main of main.dart');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptionsDev.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthBloc _authBloc;
  final CustomRouteObserver _customRouteObserver = CustomRouteObserver();

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(FirebaseAuthProvider());
    _authBloc.add(const AuthEventInitialize());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          devtools
              .log('💡 AuthState: ${state.runtimeType} triggered in main.dart');

          return MaterialApp(
            theme: ThemeData(primaryColor: MyColors.colorPalette['primary']),
            debugShowCheckedModeBanner: false,
            navigatorObservers: [_customRouteObserver],
            routes: {
              loginRoute: (context) => const LoginView(),
              registerRoute: (context) => const RegisterView(),
              forgotPasswordRoute: (context) => const ForgotPasswordView(),
              verifyEmailRoute: (context) => const VerifyEmailView(),
            },
            home: Builder(
              builder: (context) {
                if (state is AuthStateLoggedOut) {
                  return const LoginView();
                } else if (state is AuthStateRegistering) {
                  return const RegisterView();
                } else if (state is AuthStateNeedsVerification) {
                  return const VerifyEmailView(); // Show the verification view
                } else if (state is AuthStatePendingApproval) {
                  return const PendingApprovalView();
                } else if (state is AuthStateLoggedIn) {
                  final doctorData = state.doctorData;
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider<ClinicSelection>(
                        create: (_) {
                          final clinicSelection = ClinicSelection.instance;
                          String doctorId = state.user.id;
                          List<dynamic>? clinicsMapped =
                              doctorData['clinicsMapped'];
                          List<String> clinicNames = [];
                          String selectedClinicName = '';
                          String selectedClinicId = '';

                          if (clinicsMapped != null &&
                              clinicsMapped.isNotEmpty) {
                            clinicNames = clinicsMapped
                                .map((clinic) => clinic['clinicName'] as String)
                                .toList();
                            selectedClinicName = clinicNames.first;
                            selectedClinicId =
                                clinicsMapped[0]['clinicId'] as String;
                          }

                          clinicSelection.setDoctorId(doctorId);
                          clinicSelection.updateParameters(selectedClinicName,
                              clinicNames, selectedClinicId);
                          return clinicSelection;
                        },
                      ),
                      ChangeNotifierProxyProvider<ClinicSelection,
                          UserDataProvider>(
                        create: (_) => UserDataProvider(),
                        update: (_, clinicSelection, userDataProvider) {
                          userDataProvider!
                              .setClinicId(clinicSelection.selectedClinicId);
                          return userDataProvider;
                        },
                      ),
                      ChangeNotifierProxyProvider<ClinicSelection,
                          AppointmentProvider>(
                        create: (_) => AppointmentProvider(),
                        update: (_, clinicSelection, appointmentProvider) {
                          appointmentProvider?.updateClinicAndDoctor(
                            clinicSelection.selectedClinicId,
                            clinicSelection.doctorId,
                          );
                          return appointmentProvider!;
                        },
                      ),
                      ChangeNotifierProxyProvider<ClinicSelection,
                          RecentPatientProvider>(
                        create: (_) => RecentPatientProvider(),
                        update: (_, clinicSelection, recentPatientProvider) {
                          recentPatientProvider!
                              .setClinicId(clinicSelection.selectedClinicId);
                          return recentPatientProvider;
                        },
                      ),
                      ChangeNotifierProxyProvider<ClinicSelection,
                          ImageCacheProvider>(
                        create: (_) => ImageCacheProvider(),
                        update: (_, clinicSelection, imageCacheProvider) {
                          imageCacheProvider!
                              .setClinicId(clinicSelection.selectedClinicId);
                          return imageCacheProvider;
                        },
                      ),
                      ChangeNotifierProxyProvider<ClinicSelection,
                          ProcedureCacheProvider>(
                        create: (_) => ProcedureCacheProvider(),
                        update: (_, clinicSelection, procedureCacheProvider) {
                          procedureCacheProvider!
                              .setClinicId(clinicSelection.selectedClinicId);
                          return procedureCacheProvider;
                        },
                      ),
                    ],
                    child: HomePage(doctorData: doctorData),
                  );
                } else {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW BEFORE CLINIC SELECTION MOVED UP
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:neocare_dental_app/constants/routes.dart';
// import 'package:neocare_dental_app/firebase_options.dart';
// import 'package:neocare_dental_app/helpers/loading_screen.dart';
// import 'package:neocare_dental_app/home_page.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/custom_route_observer.dart';
// import 'package:neocare_dental_app/mywidgets/image_cache_provider.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/procedure_cache_provider.dart';
// import 'package:neocare_dental_app/mywidgets/recent_patient_provider.dart';
// import 'package:neocare_dental_app/mywidgets/user_data_provider.dart';
// import 'package:neocare_dental_app/services/auth/firebase_auth_provider.dart';
// import 'package:neocare_dental_app/services/bloc/auth_bloc.dart';
// import 'package:neocare_dental_app/services/bloc/auth_event.dart';
// import 'package:neocare_dental_app/services/bloc/auth_state.dart';
// import 'package:neocare_dental_app/views/forgot_password_view.dart';
// import 'package:neocare_dental_app/views/login_view.dart';
// import 'package:neocare_dental_app/views/pending_approval_view.dart';
// import 'package:neocare_dental_app/views/register_view.dart';
// import 'package:neocare_dental_app/views/verify_email_view.dart';
// import 'package:provider/provider.dart';
// import 'dart:developer' as devtools show log;

// void main() async {
//   devtools.log('This is coming from void main of main.dart');
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late AuthBloc _authBloc;
//   final CustomRouteObserver _customRouteObserver = CustomRouteObserver();

//   @override
//   void initState() {
//     super.initState();
//     _authBloc = AuthBloc(FirebaseAuthProvider());
//     _authBloc.add(const AuthEventInitialize());
//   }

//   @override
//   void dispose() {
//     _authBloc.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);

//     return BlocProvider<AuthBloc>.value(
//       value: _authBloc,
//       child: BlocBuilder<AuthBloc, AuthState>(
//         builder: (context, state) {
//           devtools
//               .log('💡 AuthState: ${state.runtimeType} triggered in main.dart');

//           return MaterialApp(
//             theme: ThemeData(primaryColor: MyColors.colorPalette['primary']),
//             debugShowCheckedModeBanner: false,
//             navigatorObservers: [_customRouteObserver],
//             routes: {
//               loginRoute: (context) => const LoginView(),
//               registerRoute: (context) => const RegisterView(),
//               forgotPasswordRoute: (context) => const ForgotPasswordView(),
//               verifyEmailRoute: (context) => const VerifyEmailView(),
//             },
//             home: Builder(
//               builder: (context) {
//                 if (state is AuthStateLoggedOut) {
//                   return const LoginView();
//                 } else if (state is AuthStateRegistering) {
//                   return const RegisterView();
//                 } else if (state is AuthStatePendingApproval) {
//                   return const PendingApprovalView();
//                 } else if (state is AuthStateLoggedIn) {
//                   final doctorData = state.doctorData;
//                   return MultiProvider(
//                     providers: [
//                       ChangeNotifierProvider<ClinicSelection>(
//                         create: (_) {
//                           final clinicSelection = ClinicSelection.instance;
//                           String doctorId = state.user.id;
//                           List<dynamic>? clinicsMapped =
//                               doctorData['clinicsMapped'];
//                           List<String> clinicNames = [];
//                           String selectedClinicName = '';
//                           String selectedClinicId = '';

//                           if (clinicsMapped != null &&
//                               clinicsMapped.isNotEmpty) {
//                             clinicNames = clinicsMapped
//                                 .map((clinic) => clinic['clinicName'] as String)
//                                 .toList();
//                             selectedClinicName = clinicNames.first;
//                             selectedClinicId =
//                                 clinicsMapped[0]['clinicId'] as String;
//                           }

//                           clinicSelection.setDoctorId(doctorId);
//                           clinicSelection.updateParameters(selectedClinicName,
//                               clinicNames, selectedClinicId);
//                           return clinicSelection;
//                         },
//                       ),
//                       ChangeNotifierProxyProvider<ClinicSelection,
//                           UserDataProvider>(
//                         create: (_) => UserDataProvider(),
//                         update: (_, clinicSelection, userDataProvider) {
//                           userDataProvider!
//                               .setClinicId(clinicSelection.selectedClinicId);
//                           return userDataProvider;
//                         },
//                       ),
//                       ChangeNotifierProxyProvider<ClinicSelection,
//                           AppointmentProvider>(
//                         create: (_) => AppointmentProvider(),
//                         update: (_, clinicSelection, appointmentProvider) {
//                           appointmentProvider?.updateClinicAndDoctor(
//                             clinicSelection.selectedClinicId,
//                             clinicSelection.doctorId,
//                           );
//                           return appointmentProvider!;
//                         },
//                       ),
//                       ChangeNotifierProxyProvider<ClinicSelection,
//                           RecentPatientProvider>(
//                         create: (_) => RecentPatientProvider(),
//                         update: (_, clinicSelection, recentPatientProvider) {
//                           recentPatientProvider!
//                               .setClinicId(clinicSelection.selectedClinicId);
//                           return recentPatientProvider;
//                         },
//                       ),
//                       ChangeNotifierProxyProvider<ClinicSelection,
//                           ImageCacheProvider>(
//                         create: (_) => ImageCacheProvider(),
//                         update: (_, clinicSelection, imageCacheProvider) {
//                           imageCacheProvider!
//                               .setClinicId(clinicSelection.selectedClinicId);
//                           return imageCacheProvider;
//                         },
//                       ),
//                       ChangeNotifierProxyProvider<ClinicSelection,
//                           ProcedureCacheProvider>(
//                         create: (_) => ProcedureCacheProvider(),
//                         update: (_, clinicSelection, procedureCacheProvider) {
//                           procedureCacheProvider!
//                               .setClinicId(clinicSelection.selectedClinicId);
//                           return procedureCacheProvider;
//                         },
//                       ),
//                     ],
//                     child: HomePage(doctorData: doctorData),
//                   );
//                 } else {
//                   return const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ??
