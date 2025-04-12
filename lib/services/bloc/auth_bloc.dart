import 'package:bloc/bloc.dart';
import 'package:neocaresmileapp/firestore/clinic_service.dart';
import 'package:neocaresmileapp/firestore/doctor_service.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import '../auth/my_auth_provider.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'dart:developer' as devtools show log;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final MyAuthProvider provider;

  AuthBloc(this.provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    // Fetch doctor data method
    Future<Map<String, dynamic>> fetchDoctorData(String userId) async {
      try {
        final doctorData =
            await DoctorService().fetchAndCacheDoctorDataIfNeeded(userId) ?? {};
        devtools.log(
            '#### This is coming from inside fetchDoctorData defined inside AuthBloc. doctorData is $doctorData');
        return doctorData;
      } catch (e) {
        devtools.log('Error fetching doctor data: $e');
        return {};
      }
    }

    on<AuthEventShouldRegister>((event, emit) {
      devtools.log('AuthEventShouldRegister occurred!');
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
      devtools.log('After dispatching AuthEventShouldRegister');
    });

    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));

      devtools.log('Welcome to AuthEventForgotPassword');
      final email = event.email;
      devtools.log('email is $email');

      if (email == null) {
        devtools.log('email is null');
        return;
      }

      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true,
      ));

      bool didSendEmail;
      Exception? exception;

      try {
        devtools.log('Sending email to $email');
        await provider.sendPasswordReset(toEmail: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }

      emit(AuthStateForgotPassword(
        exception: exception,
        hasSentEmail: didSendEmail,
        isLoading: false,
      ));
    });

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(
          email: email,
          password: password,
        );
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;

      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        final doctorData = await fetchDoctorData(user.id);
        final clinicsMapped = doctorData['clinicsMapped'] as List<dynamic>?;

        if (clinicsMapped == null || clinicsMapped.isEmpty) {
          emit(AuthStatePendingApproval(user: user, isLoading: false));
        } else {
          emit(AuthStateLoggedIn(
            user: user,
            doctorData: doctorData,
            isLoading: false,
          ));
        }
      }
    });

    // ----------------------------------------------------------------------- //

    on<AuthEventLogin>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: 'Please wait while I log you in!',
      ));

      final email = event.email;
      final password = event.password;

      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );

        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          final doctorData = await fetchDoctorData(user.id);

          // ✅ Check if user is mapped to any clinic
          final clinicsMapped = doctorData['clinicsMapped'] as List<dynamic>?;

          emit(const AuthStateLoggedOut(exception: null, isLoading: false));

          if (clinicsMapped == null || clinicsMapped.isEmpty) {
            emit(AuthStatePendingApproval(user: user, isLoading: false));
          } else {
            emit(AuthStateLoggedIn(
              user: user,
              doctorData: doctorData,
              isLoading: false,
            ));
          }
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });
    // ----------------------------------------------------------------------- //

    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventChangePassword>((event, emit) async {
      emit(const AuthStateLoading(loadingText: 'Changing Password...'));

      final email = event.email;
      final newPassword = event.newPassword;
      final currentPassword = event.currentPassword;

      try {
        await provider.changePassword(
          email: email,
          newPassword: newPassword,
          currentPassword: currentPassword,
        );
        emit(const AuthStateChangePasswordSuccess(
          loadingText: 'Password changed successfully!',
        ));
      } on Exception catch (e) {
        emit(AuthStateChangePasswordFailure(exception: e));
      }
    });

    // ----------------------------------------------------------------------- //
    on<AuthEventCreateUser>((event, emit) async {
      emit(const AuthStateLoading(loadingText: 'Creating User...'));
      try {
        await provider.createUser(
          email: event.email,
          password: event.password,
        );
        await provider.sendEmailVerification();
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });
    // ----------------------------------------------------------------------- //

    on<AuthEventGoogleSignIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: 'Signing in with Google...',
      ));

      try {
        final user = await provider.signInWithGoogle();

        // No email verification needed for Google Sign-In
        final doctorData = await fetchDoctorData(user.id);

        emit(const AuthStateLoggedOut(exception: null, isLoading: false));

        final clinicsMapped = doctorData['clinicsMapped'] as List<dynamic>?;

        if (clinicsMapped == null || clinicsMapped.isEmpty) {
          devtools.log(
              '>>> User is not mapped to any clinic. Emitting PendingApproval');

          emit(AuthStatePendingApproval(user: user, isLoading: false));
        } else {
          emit(AuthStateLoggedIn(
            user: user,
            doctorData: doctorData,
            isLoading: false,
          ));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });

    // ----------------------------------------------------------------------- //
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// ############################################################################ //
// import 'package:bloc/bloc.dart';
// import 'package:neocare_dental_app/firestore/clinic_service.dart';
// import 'package:neocare_dental_app/firestore/doctor_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import '../auth/auth_provider.dart';
// import 'auth_event.dart';
// import 'auth_state.dart';
// import 'dart:developer' as devtools show log;

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final AuthProvider provider;

//   AuthBloc(this.provider)
//       : super(const AuthStateUninitialized(isLoading: true)) {
//     // Fetch doctor data method
//     Future<Map<String, dynamic>> fetchDoctorData(String userId) async {
//       try {
//         final doctorData =
//             await DoctorService().fetchAndCacheDoctorDataIfNeeded(userId) ?? {};
//         devtools.log(
//             '#### This is coming from inside fetchDoctorData defined inside AuthBloc. doctorData is $doctorData');
//         return doctorData;
//       } catch (e) {
//         devtools.log('Error fetching doctor data: $e');
//         return {};
//       }
//     }

//     on<AuthEventShouldRegister>((event, emit) {
//       devtools.log('AuthEventShouldRegister occurred!');
//       emit(const AuthStateRegistering(
//         exception: null,
//         isLoading: false,
//       ));
//       devtools.log('After dispatching AuthEventShouldRegister');
//     });

//     on<AuthEventForgotPassword>((event, emit) async {
//       emit(const AuthStateForgotPassword(
//         exception: null,
//         hasSentEmail: false,
//         isLoading: false,
//       ));

//       devtools.log('Welcome to AuthEventForgotPassword');
//       final email = event.email;
//       devtools.log('email is $email');

//       if (email == null) {
//         devtools.log('email is null');
//         return;
//       }

//       emit(const AuthStateForgotPassword(
//         exception: null,
//         hasSentEmail: false,
//         isLoading: true,
//       ));

//       bool didSendEmail;
//       Exception? exception;

//       try {
//         devtools.log('Sending email to $email');
//         await provider.sendPasswordReset(toEmail: email);
//         didSendEmail = true;
//         exception = null;
//       } on Exception catch (e) {
//         didSendEmail = false;
//         exception = e;
//       }

//       emit(AuthStateForgotPassword(
//         exception: exception,
//         hasSentEmail: didSendEmail,
//         isLoading: false,
//       ));
//     });

//     on<AuthEventRegister>((event, emit) async {
//       final email = event.email;
//       final password = event.password;
//       try {
//         await provider.createUser(
//           email: email,
//           password: password,
//         );
//         await provider.sendEmailVerification();
//         emit(const AuthStateNeedsVerification(isLoading: false));
//       } on Exception catch (e) {
//         emit(AuthStateRegistering(
//           exception: e,
//           isLoading: false,
//         ));
//       }
//     });

//     on<AuthEventInitialize>((event, emit) async {
//       await provider.initialize();
//       final user = provider.currentUser;
//       if (user == null) {
//         emit(
//           const AuthStateLoggedOut(
//             exception: null,
//             isLoading: false,
//           ),
//         );
//       } else if (!user.isEmailVerified) {
//         emit(const AuthStateNeedsVerification(isLoading: false));
//       } else {
//         final doctorData = await fetchDoctorData(user.id);
//         final collectedPatientService = PatientService(
//           doctorData['clinicsMapped'][0]['clinicId'],
//           user.id,
//         );
//         emit(AuthStateLoggedIn(
//           user: user,
//           doctorData: doctorData,
//           collectedPatientService: collectedPatientService,
//           isLoading: false,
//         ));
//       }

            
//     });

//     on<AuthEventLogin>((event, emit) async {
//       emit(const AuthStateLoggedOut(
//         exception: null,
//         isLoading: true,
//         loadingText: 'Please wait while I log you in!',
//       ));
//       final email = event.email;
//       final password = event.password;
//       try {
//         final user = await provider.logIn(
//           email: email,
//           password: password,
//         );
//         if (!user.isEmailVerified) {
//           emit(const AuthStateLoggedOut(
//             exception: null,
//             isLoading: false,
//           ));
//           emit(const AuthStateNeedsVerification(isLoading: false));
//         } else {
//           final doctorData = await fetchDoctorData(user.id);
//           final collectedPatientService = PatientService(
//             doctorData['clinicsMapped'][0]['clinicId'],
//             user.id,
//           );
//           emit(const AuthStateLoggedOut(
//             exception: null,
//             isLoading: false,
//           ));
//           emit(AuthStateLoggedIn(
//             user: user,
//             doctorData: doctorData,
//             collectedPatientService: collectedPatientService,
//             isLoading: false,
//           ));
//         }
//       } on Exception catch (e) {
//         emit(AuthStateLoggedOut(
//           exception: e,
//           isLoading: false,
//         ));
//       }
//     });

//     on<AuthEventLogOut>((event, emit) async {
//       try {
//         await provider.logOut();
//         emit(const AuthStateLoggedOut(
//           exception: null,
//           isLoading: false,
//         ));
//       } on Exception catch (e) {
//         emit(AuthStateLoggedOut(
//           exception: e,
//           isLoading: false,
//         ));
//       }
//     });

//     on<AuthEventChangePassword>((event, emit) async {
//       emit(const AuthStateLoading(loadingText: 'Changing Password...'));

//       final email = event.email;
//       final newPassword = event.newPassword;
//       final currentPassword = event.currentPassword;

//       try {
//         await provider.changePassword(
//           email: email,
//           newPassword: newPassword,
//           currentPassword: currentPassword,
//         );
//         emit(const AuthStateChangePasswordSuccess(
//           loadingText: 'Password changed successfully!',
//         ));
//       } on Exception catch (e) {
//         emit(AuthStateChangePasswordFailure(exception: e));
//       }
//     });

//     // ----------------------------------------------------------------------- //
//     on<AuthEventCreateUser>((event, emit) async {
//       emit(const AuthStateLoading(loadingText: 'Creating User...'));
//       try {
//         await provider.createUser(
//           email: event.email,
//           password: event.password,
//         );
//         await provider.sendEmailVerification();
//         emit(const AuthStateLoggedOut(
//           exception: null,
//           isLoading: false,
//         ));
//       } on Exception catch (e) {
//         emit(AuthStateRegistering(
//           exception: e,
//           isLoading: false,
//         ));
//       }
//     });

//     // ----------------------------------------------------------------------- //
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
