import 'package:flutter/foundation.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import '../auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment',
  });
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required super.isLoading});
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({
    required this.exception,
    required super.isLoading,
  });
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;

  const AuthStateForgotPassword({
    required this.exception,
    required this.hasSentEmail,
    required super.isLoading,
  });
}

class AuthStateChangePassword extends AuthState {
  final Exception? exception;

  const AuthStateChangePassword({
    required this.exception,
    required super.isLoading,
  });
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading({super.loadingText = null}) : super(isLoading: true);
}

class AuthStateChangePasswordSuccess extends AuthState {
  const AuthStateChangePasswordSuccess({required String loadingText})
      : super(isLoading: false, loadingText: loadingText);
}

class AuthStateChangePasswordFailure extends AuthState {
  final Exception exception;

  const AuthStateChangePasswordFailure({required this.exception})
      : super(isLoading: false, loadingText: 'Change Password Failed');
}

class AuthStatePendingApproval extends AuthState {
  final AuthUser user;
  const AuthStatePendingApproval({
    required this.user,
    required super.isLoading,
  });
}


// class AuthStateLoggedIn extends AuthState {
//   final AuthUser user;
//   final Map<String, dynamic> doctorData;
//   final PatientService collectedPatientService;

//   const AuthStateLoggedIn({
//     required this.user,
//     required this.doctorData,
//     required this.collectedPatientService,
//     required super.isLoading,
//   });
// }

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  final Map<String, dynamic> doctorData;
  const AuthStateLoggedIn({
    required this.user,
    required this.doctorData,
    required super.isLoading,
  });
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({
    required super.isLoading,
  });
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required super.isLoading,
    super.loadingText = null,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// ################################################################## //
// import 'package:flutter/foundation.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import '../auth/auth_user.dart';
// import 'package:equatable/equatable.dart';

// @immutable
// abstract class AuthState {
//   final bool isLoading;
//   final String? loadingText;
//   const AuthState({
//     required this.isLoading,
//     this.loadingText = 'Please wait a moment',
//   });
// }

// class AuthStateUninitialized extends AuthState {
//   const AuthStateUninitialized({required super.isLoading});
// }

// class AuthStateRegistering extends AuthState {
//   final Exception? exception;
//   const AuthStateRegistering({
//     required this.exception,
//     required super.isLoading,
//   });
// }

// class AuthStateForgotPassword extends AuthState {
//   final Exception? exception;
//   final bool hasSentEmail;

//   const AuthStateForgotPassword({
//     required this.exception,
//     required this.hasSentEmail,
//     required super.isLoading,
//   });
// }

// class AuthStateChangePassword extends AuthState {
//   final Exception? exception;

//   const AuthStateChangePassword({
//     required this.exception,
//     required super.isLoading,
//   });
// }

// class AuthStateLoading extends AuthState {
//   const AuthStateLoading({super.loadingText = null}) : super(isLoading: true);
// }

// class AuthStateChangePasswordSuccess extends AuthState {
//   const AuthStateChangePasswordSuccess({required String loadingText})
//       : super(isLoading: false, loadingText: loadingText);
// }

// class AuthStateChangePasswordFailure extends AuthState {
//   final Exception exception;

//   const AuthStateChangePasswordFailure({required this.exception})
//       : super(isLoading: false, loadingText: 'Change Password Failed');
// }

// class AuthStateLoggedIn extends AuthState {
//   final AuthUser user;
//   final Map<String, dynamic> doctorData;
//   final PatientService collectedPatientService;

//   const AuthStateLoggedIn({
//     required this.user,
//     required this.doctorData,
//     required this.collectedPatientService,
//     required super.isLoading,
//   });
// }

// class AuthStateNeedsVerification extends AuthState {
//   const AuthStateNeedsVerification({
//     required super.isLoading,
//   });
// }

// class AuthStateLoggedOut extends AuthState with EquatableMixin {
//   final Exception? exception;
//   const AuthStateLoggedOut({
//     required this.exception,
//     required super.isLoading,
//     super.loadingText = null,
//   });

//   @override
//   List<Object?> get props => [exception, isLoading];
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// import 'package:flutter/foundation.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import '../auth/auth_user.dart';
// import 'package:equatable/equatable.dart';

// @immutable
// abstract class AuthState {
//   final bool isLoading;
//   final String? loadingText;
//   const AuthState({
//     required this.isLoading,
//     this.loadingText = 'Please wait a moment',
//   });
// }

// class AuthStateUninitialized extends AuthState {
//   const AuthStateUninitialized({required super.isLoading});
// }

// class AuthStateRegistering extends AuthState {
//   final Exception? exception;
//   const AuthStateRegistering({
//     required this.exception,
//     required super.isLoading,
//   });
// }

// class AuthStateForgotPassword extends AuthState {
//   final Exception? exception;
//   final bool hasSentEmail;

//   const AuthStateForgotPassword({
//     required this.exception,
//     required this.hasSentEmail,
//     required super.isLoading,
//   });
// }

// //-----------------------------------------------//
// class AuthStateChangePassword extends AuthState {
//   final Exception? exception;
//   final bool hasSentEmail;

//   const AuthStateChangePassword({
//     required this.exception,
//     required this.hasSentEmail,
//     required super.isLoading,
//   });
// }

// class AuthStateLoading extends AuthState {
//   const AuthStateLoading({super.loadingText = null}) : super(isLoading: true);
// }

// //

// class AuthStateChangePasswordSuccess extends AuthState {
//   const AuthStateChangePasswordSuccess({required String loadingText})
//       : super(isLoading: false, loadingText: loadingText);
// }

// class AuthStateChangePasswordFailure extends AuthState {
//   final Exception exception;

//   const AuthStateChangePasswordFailure({required this.exception})
//       : super(isLoading: false, loadingText: 'Change Password Failed');
// }

// //-----------------------------------------------//
// // class AuthStateLoggedIn extends AuthState {
// //   final AuthUser user;
// //   const AuthStateLoggedIn({
// //     required this.user,
// //     required super.isLoading,
// //   });
// // }

// //-----------------------------------------//
// class AuthStateLoggedIn extends AuthState {
//   final AuthUser user;
//   final Map<String, dynamic> doctorData;
//   final PatientService collectedPatientService;

//   const AuthStateLoggedIn({
//     required this.user,
//     required this.doctorData,
//     required this.collectedPatientService,
//     required super.isLoading,
//   });
// }

// //-----------------------------------------//

// class AuthStateNeedsVerification extends AuthState {
//   const AuthStateNeedsVerification({
//     required super.isLoading,
//   });
// }

// class AuthStateLoggedOut extends AuthState with EquatableMixin {
//   final Exception? exception;
//   const AuthStateLoggedOut({
//     required this.exception,
//     required super.isLoading,
//     super.loadingText = null,
//   });

//   @override
//   List<Object?> get props => [exception, isLoading];
// }

// The code in `auth_state.dart` defines different states that can occur during
//the authentication process. Here's the flow and logic behind the code:

// 1. `AuthState` class:
//    - An abstract class that serves as the base class for all authentication
// states.
//    - It is marked as `@immutable`, indicating that its instances are
//immutable and cannot be changed once created.
//    - Provides common properties related to the loading state, such as `
//isLoading` (whether the authentication process is in progress) and `
//loadingText` (optional text to display during loading).

// 2. Concrete State Classes:
//    - `AuthStateUninitialized`: Represents the state when the authentication
//process is not initialized or hasn't started yet.
//    - `AuthStateRegistering`: Represents the state during user registration.
//It contains an optional `exception` to handle any registration errors.
//    - `AuthStateForgotPassword`: Represents the state during the password
//reset process. It contains an optional `exception` to handle any errors and
//`hasSentEmail` to indicate whether the reset email has been sent.
//    - `AuthStateLoggedIn`: Represents the state when the user is successfully
//logged in. It contains the `AuthUser` object representing the logged-in user.
//    - `AuthStateNeedsVerification`: Represents the state when the user needs
//to verify their email address.
//    - `AuthStateLoggedOut`: Represents the state when the user is logged out.
// It contains an optional `exception` to handle any errors.

// 3. EquatableMixin:
//    - `AuthStateLoggedOut` class implements `EquatableMixin`, allowing the
//comparison of state objects for equality.
//    - The `props` method is overridden to provide a list of properties that
//should be considered when comparing state objects for equality.

// 4. Purpose:
//    - The state classes provide a way to represent different stages or
//outcomes of the authentication process.
//    - They encapsulate information about the current state of authentication,
//such as loading status, error messages, and user data.
//    - By defining distinct state classes, the code achieves a clear and
//organized representation of different authentication scenarios, making it
//easier to handle and update the UI based on the current state.

// Overall, the code in `auth_state.dart` facilitates tracking and
//communication of the authentication state throughout the application,
//enabling proper handling and display of UI components based on the current
//authentication status.
