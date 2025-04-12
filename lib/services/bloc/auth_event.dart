import 'package:flutter/foundation.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import 'dart:developer' as devtools show log;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}


class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;
  final Map<String, dynamic>? doctorData;

  const AuthEventLogin(
    this.email,
    this.password, {
    this.doctorData,
  });
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;

  const AuthEventRegister(this.email, this.password);
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;

  const AuthEventForgotPassword(this.email);
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventChangePassword extends AuthEvent {
  final String email;
  final String newPassword;
  final String currentPassword; // Add this field

  const AuthEventChangePassword({
    required this.email,
    required this.newPassword,
    required this.currentPassword, // Add this field
  });
}

// -------------------------------------------------------------------- //
class AuthEventCreateUser extends AuthEvent {
  final String email;
  final String password;

  const AuthEventCreateUser({
    required this.email,
    required this.password,
  });
}

// -------------------------------------------------------------------- //
class AuthEventGoogleSignIn extends AuthEvent {
  const AuthEventGoogleSignIn();
}
// -------------------------------------------------------------------- //


// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// #################################################################### //
// import 'package:flutter/foundation.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'dart:developer' as devtools show log;

// @immutable
// abstract class AuthEvent {
//   const AuthEvent();
// }

// class AuthEventInitialize extends AuthEvent {
//   const AuthEventInitialize();
// }

// class AuthEventLogin extends AuthEvent {
//   final String email;
//   final String password;
//   final Map<String, dynamic> doctorData;
//   final PatientService collectedPatientService;

//   const AuthEventLogin(
//     this.email,
//     this.password, {
//     required this.doctorData,
//     required this.collectedPatientService,
//   });
// }

// class AuthEventShouldRegister extends AuthEvent {
//   const AuthEventShouldRegister();
// }

// class AuthEventRegister extends AuthEvent {
//   final String email;
//   final String password;

//   const AuthEventRegister(this.email, this.password);
// }

// class AuthEventSendEmailVerification extends AuthEvent {
//   const AuthEventSendEmailVerification();
// }

// class AuthEventForgotPassword extends AuthEvent {
//   final String? email;

//   const AuthEventForgotPassword(this.email);
// }

// class AuthEventLogOut extends AuthEvent {
//   const AuthEventLogOut();
// }


// class AuthEventChangePassword extends AuthEvent {
//   final String email;
//   final String newPassword;
//   final String currentPassword; // Add this field

//   const AuthEventChangePassword({
//     required this.email,
//     required this.newPassword,
//     required this.currentPassword, // Add this field
//   });
// }

// // -------------------------------------------------------------------- //
// class AuthEventCreateUser extends AuthEvent {
//   final String email;
//   final String password;

//   const AuthEventCreateUser({
//     required this.email,
//     required this.password,
//   });
// }

// -------------------------------------------------------------------- //


// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// import 'package:flutter/foundation.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';

// @immutable
// abstract class AuthEvent {
//   const AuthEvent();
// }

// class AuthEventInitialize extends AuthEvent {
//   const AuthEventInitialize();
// }

// class AuthEventLogin extends AuthEvent {
//   final String email;
//   final String password;
//   final Map<String, dynamic> doctorData;
//   final PatientService collectedPatientService;

//   const AuthEventLogin(
//     this.email,
//     this.password, {
//     required this.doctorData,
//     required this.collectedPatientService,
//   });
// }

// class AuthEventShouldRegister extends AuthEvent {
//   const AuthEventShouldRegister();
// }

// class AuthEventRegister extends AuthEvent {
//   final String email;
//   final String password;

//   const AuthEventRegister(this.email, this.password);
// }

// class AuthEventSendEmailVerification extends AuthEvent {
//   const AuthEventSendEmailVerification();
// }

// class AuthEventForgotPassword extends AuthEvent {
//   final String? email;

//   const AuthEventForgotPassword(this.email);
// }

// class AuthEventLogOut extends AuthEvent {
//   const AuthEventLogOut();
// }

// // class AuthEventChangePassword extends AuthEvent {
// //   final String email;
// //   final String newPassword;

// //   const AuthEventChangePassword(this.email, this.newPassword);
// // }
// class AuthEventChangePassword extends AuthEvent {
//   final String email;
//   final String newPassword;

//   const AuthEventChangePassword({
//     required this.email,
//     required this.newPassword,
//   });
// }

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// import 'package:flutter/foundation.dart';

// @immutable
// abstract class AuthEvent {
//   const AuthEvent();
// }

// class AuthEventInitialize extends AuthEvent {
//   const AuthEventInitialize();
// }

// class AuthEventSendEmailVerification extends AuthEvent {
//   const AuthEventSendEmailVerification();
// }

// class AuthEventLogin extends AuthEvent {
//   final String email;
//   final String password;

//   const AuthEventLogin(this.email, this.password);
// }
// //-------------------------------------------------------------------//

// //-------------------------------------------------------------------//


// class AuthEventRegister extends AuthEvent {
//   final String email;
//   final String password;

//   const AuthEventRegister(
//     this.email,
//     this.password,
//   );
// }

// class AuthEventForgotPassword extends AuthEvent {
//   final String? email;
//   const AuthEventForgotPassword({this.email});
// }

// class AuthEventLogOut extends AuthEvent {
//   const AuthEventLogOut();
// }

// class AuthEventShouldRegister extends AuthEvent {
//   const AuthEventShouldRegister();
// }

// //---------------------------------------------------//

// @immutable
// class AuthEventChangePassword extends AuthEvent {
//   final String email;
//   final String newPassword;

//   const AuthEventChangePassword({
//     required this.email,
//     required this.newPassword,
//   });

//   //----------------------------------------------------//
// }
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

// @override
  // List<Object?> get props => [email, newPassword];



// The code in `auth_event.dart` defines different events that can occur during 
//the authentication process. Here's the flow and logic behind the code:

// 1. `AuthEvent` class:
//    - An abstract class that serves as the base class for all authentication 
// events.
//    - It is marked as `@immutable`, indicating that its instances are 
//immutable and cannot be changed once created.
//    - Provides a common interface for all authentication events.

// 2. Concrete Event Classes:
//    - `AuthEventInitialize`: Represents the event to initialize the 
//authentication process. It is triggered during application startup.
//    - `AuthEventLogin`: Represents the event to log in a user. It contains 
//the user's email and password.
//    - `AuthEventRegister`: Represents the event to register a new user. It 
//contains the user's email and password.
//    - `AuthEventShouldRegister`: Represents the event when the user intends
// to register.
//    - `AuthEventSendEmailVerifcation`: Represents the event to send an email
// verification request to the user.
//    - `AuthEventForgotPassword`: Represents the event to initiate a password 
//reset. It can optionally contain the user's email.
//    - `AuthEventLogOut`: Represents the event to log out the currently 
//logged-in user.

// 3. Event Parameters:
//    - The concrete event classes (`AuthEventLogin`, `AuthEventRegister`, `
//AuthEventForgotPassword`) define specific parameters necessary for the 
//corresponding event.
//    - These parameters capture information such as the user's email and
// password.

// 4. Purpose:
//    - The event classes provide a way to encapsulate and communicate different
// user actions or requests related to authentication.
//    - They are used as input to the `AuthBloc` to trigger specific 
//authentication operations and state transitions.

// By defining distinct event classes, the code achieves a clear and organized
// separation of concerns, allowing the authentication process to handle 
//different user actions effectively. Each event class represents a specific 
//user intent and provides the necessary data to perform the corresponding 
//authentication operation.

//entire flow 

// The flow for the "Forgot Password" functionality typically begins with the creation of the AuthEventForgotPassword class. This class is responsible for encapsulating the information related to the "Forgot Password" action, including the user's email.

// Here's a general outline of the flow:

//****** */
// Define the AuthEventForgotPassword class:
// class AuthEventForgotPassword extends AuthEvent {
//   final String email;

//   const AuthEventForgotPassword({
//     required this.email,
//   });
// }
//****** */

//****** */
// Handle the AuthEventForgotPassword in AuthBloc:

// on<AuthEventForgotPassword>((event, emit) async {
//   emit(const AuthStateForgotPassword(
//     exception: null,
//     hasSentEmail: false,
//     isLoading: false,
//   ));

//   final email = event.email;
  
//   if (email == null) {
//     return; // user just wants to show the "Forgot Password" screen
//   }

//   emit(const AuthStateForgotPassword(
//     exception: null,
//     hasSentEmail: false,
//     isLoading: true,
//   ));

//   bool didSendEmail;
//   Exception? exception;

//   try {
//     await provider.sendPasswordReset(toEmail: email);
//     didSendEmail = true;
//     exception = null;
//   } on Exception catch (e) {
//     didSendEmail = false;
//     exception = e;
//   }

//   emit(AuthStateForgotPassword(
//     exception: exception,
//     hasSentEmail: didSendEmail,
//     isLoading: false,
//   ));
// });
//****** */

//****** */
// Trigger the AuthEventForgotPassword in the UI (ForgotPasswordView):

// TextButton(
//   onPressed: () {
//     final email = _controller.text;
//     context.read<AuthBloc>().add(
//       AuthEventForgotPassword(email: email),
//     );
//   },
//   child: const Text('Send me a password reset link'),
// ),
//****** */

//****** */
// Handle the AuthStateForgotPassword in the UI (ForgotPasswordView):

// BlocListener<AuthBloc, AuthState>(
//   listener: (context, state) {
//     if (state is AuthStateForgotPassword) {
//       if (state.hasSentEmail) {
//         _controller.clear();
//         showPasswordResetSentDialog(context);
//       }
//       if (state.exception != null) {
//         showErrorDialog(context,
//             'We could not process your request. Please make sure that you are a registered user!');
//       }
//     }
//   },
//   // ... other UI code
// ),
// This is a high-level overview of the flow for handling "Forgot Password" functionality in your app. Adjustments may be needed based on the specific implementation details in your application
//****** */