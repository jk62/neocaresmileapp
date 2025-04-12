import 'package:flutter_test/flutter_test.dart';
import 'package:neocaresmileapp/services/auth/auth_exceptions.dart';
import 'package:neocaresmileapp/services/auth/firebase_auth_provider.dart';
import 'package:neocaresmileapp/services/bloc/auth_bloc.dart';
import 'package:neocaresmileapp/services/bloc/auth_event.dart';
import 'package:neocaresmileapp/services/bloc/auth_state.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';

void main() {
  group('AuthBloc', () {
    test('Emits AuthStateLoggedOut with UserNotFoundAuthException', () async {
      // Arrange: Create an AuthBloc instance
      final authProvider = FirebaseAuthProvider();
      final authBloc = AuthBloc(authProvider);

      // Mock data for the required parameters
      final Map<String, dynamic> mockDoctorData = {};
      final PatientService mockPatientService = PatientService('', '');

      // Act: Dispatch an AuthEvent (e.g., AuthEventLogin with invalid credentials)
      // authBloc.add(AuthEventLogin(
      //   'invalid@example.com',
      //   'password',
      //   doctorData: mockDoctorData,
      //   collectedPatientService: mockPatientService,
      // ));
      authBloc.add(AuthEventLogin(
        'invalid@example.com',
        'password',
        doctorData: mockDoctorData,
      ));

      // Assert: Check the emitted state
      final authStateMatcher = isA<AuthStateLoggedOut>().having(
        (AuthStateLoggedOut state) => state.exception,
        'exception',
        isA<UserNotFoundAuthException>(),
      );

      await expectLater(
        authBloc.stream,
        emitsInOrder([authStateMatcher]),
      );

      // Clean up: Close the bloc
      await authBloc.close();
    });
  });
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// ######################################################################//
// import 'package:flutter_test/flutter_test.dart';
// import 'package:neocare_dental_app/services/auth/auth_exceptions.dart';
// import 'package:neocare_dental_app/services/auth/firebase_auth_provider.dart';
// import 'package:neocare_dental_app/services/bloc/auth_bloc.dart';
// import 'package:neocare_dental_app/services/bloc/auth_event.dart';
// import 'package:neocare_dental_app/services/bloc/auth_state.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';

// void main() {
//   group('AuthBloc', () {
//     test('Emits AuthStateLoggedOut with UserNotFoundAuthException', () async {
//       // Arrange: Create an AuthBloc instance
//       final authProvider = FirebaseAuthProvider();
//       final authBloc = AuthBloc(authProvider);

//       // Mock data for the required parameters
//       final Map<String, dynamic> mockDoctorData = {};
//       final PatientService mockPatientService = PatientService('', '');

//       // Act: Dispatch an AuthEvent (e.g., AuthEventLogin with invalid credentials)
//       authBloc.add(AuthEventLogin(
//         'invalid@example.com',
//         'password',
//         doctorData: mockDoctorData,
//         collectedPatientService: mockPatientService,
//       ));

//       // Assert: Check the emitted state
//       final authStateMatcher = isA<AuthStateLoggedOut>().having(
//         (AuthStateLoggedOut state) => state.exception,
//         'exception',
//         isA<UserNotFoundAuthException>(),
//       );

//       await expectLater(
//         authBloc.stream,
//         emitsInOrder([authStateMatcher]),
//       );

//       // Clean up: Close the bloc
//       await authBloc.close();
//     });
//   });
// }

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// Code below was before shifting fethcDoctorData to AuthBloc
// import 'package:flutter_test/flutter_test.dart';
// import 'package:neocare_dental_app/services/auth/auth_exceptions.dart';
// import 'package:neocare_dental_app/services/auth/firebase_auth_provider.dart';
// import 'package:neocare_dental_app/services/bloc/auth_bloc.dart';
// import 'package:neocare_dental_app/services/bloc/auth_event.dart';
// import 'package:neocare_dental_app/services/bloc/auth_state.dart';

// void main() {
//   group('AuthBloc', () {
//     test('Emits AuthStateLoggedOut with UserNotFoundAuthException', () {
//       // Arrange: Create an AuthBloc instance
//       //final authBloc = AuthBloc();
//       final authProvider =
//           FirebaseAuthProvider(); // Assuming FirebaseAuthProvider is your AuthProvider implementation
//       final authBloc = AuthBloc(authProvider);

//       // Act: Dispatch an AuthEvent (e.g., AuthEventLogin with invalid credentials)
//       authBloc.add(const AuthEventLogin('invalid@example.com', 'password'));

//       // Assert: Check the emitted state
//       // expectLater(
//       //   authBloc.stream,
//       //   emitsInOrder([
//       //     // Expect an AuthStateLoggedOut with UserNotFoundAuthException
//       //     isA<AuthStateLoggedOut>()
//       //       ..having(
//       //         (state) => state.exception,
//       //         'exception',
//       //         isA<UserNotFoundAuthException>(),
//       //       ),
//       //   ]),
//       // );
//       // Assert: Check the emitted state
//       final authStateMatcher = isA<AuthStateLoggedOut>().having(
//         (AuthStateLoggedOut state) => state.exception,
//         'exception',
//         isA<UserNotFoundAuthException>(),
//       );

//       expectLater(
//         authBloc.stream,
//         emitsInOrder([authStateMatcher]),
//       );

//       // Clean up: Close the bloc
//       authBloc.close();
//     });
//   });
// }
