import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:neocaresmileapp/firebase_options_dev.dart';

import 'auth_exceptions.dart';
import 'my_auth_provider.dart';
import 'auth_user.dart';
import 'dart:developer' as devtools show log;

class FirebaseAuthProvider implements MyAuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<void> initialize() async {
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = _auth.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      devtools.log('FirebaseAuthException code: ${e.code}');
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else if (e.code == 'invalid-credential') {
        throw UserNotFoundAuthException(); // Handle this as user not found
      } else {
        throw GenericAuthException();
      }
    }

    // on FirebaseAuthException catch (e) {
    //   if (e.code == 'user-not-found') {
    //     throw UserNotFoundAuthException();
    //   } else if (e.code == 'wrong-password') {
    //     throw WrongPasswordAuthException();
    //   } else {
    //     throw GenericAuthException();
    //   }
    // } catch (_) {
    //   throw GenericAuthException();
    // }
  }

  @override
  Future<void> logOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _auth.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    try {
      await _auth.sendPasswordResetEmail(email: toEmail);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        case 'firebase_auth/user-not-found':
          throw UserNotFoundAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw UserNotLoggedInAuthException();
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User user = userCredential.user!;
      return AuthUser.fromFirebase(user);
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser> signInWithCredential(dynamic credential) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User user = userCredential.user!;
      return AuthUser.fromFirebase(user);
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> changePassword({
    required String email,
    required String currentPassword, // Add this parameter
    required String newPassword,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email == email) {
        devtools.log('Current user found, re-authenticating...');

        // Re-authenticate the user
        final credential = EmailAuthProvider.credential(
          email: email,
          password: currentPassword, // Use the current password here
        );

        await currentUser.reauthenticateWithCredential(credential);
        devtools.log('User re-authenticated, updating password...');

        // Update the password
        await currentUser.updatePassword(newPassword);
        devtools.log('Password updated successfully.');
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      devtools.log('FirebaseAuthException: ${e.code} - ${e.message}');
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      devtools.log('Exception: $e');
      throw ChangePasswordFailedException('Failed to change password: $e');
    }
  }

  //---------------------------------------------------//
}

// The code in `firebase_auth_provider.dart` implements the `AuthProvider` 
//interface and provides authentication functionality using Firebase 
//Authentication. Let's break down the flow and logic of the code:

// 1. `FirebaseAuthProvider` class: This class implements the `AuthProvider` 
//interface and contains the necessary methods to handle authentication 
//operations.

// 2. `initialize` method: This method initializes Firebase by calling 
//`Firebase.initializeApp()` with the provided options. It ensures that 
//Firebase is properly initialized before performing any authentication 
//operations.

// 3. `createUser` method: This method creates a new user with the given email 
//and password. It uses the `_auth.createUserWithEmailAndPassword` method 
//provided by Firebase Authentication. If the user creation is successful, 
//it returns the `currentUser` as an `AuthUser` object. If any error occurs 
//during the process, appropriate exceptions are thrown based on the specific 
//error code.

// 4. `currentUser` getter: This getter retrieves the currently logged-in user 
//from Firebase Authentication. If a user is available, it returns an `AuthUser
//` object representing the current user; otherwise, it returns `null`.

// 5. `logIn` method: This method logs in the user with the provided email and 
//password. It uses the `_auth.signInWithEmailAndPassword` method to 
//authenticate the user. If the login is successful, it returns the 
//`currentUser` as an `AuthUser` object. If any error occurs during the process,
// appropriate exceptions are thrown based on the specific error code.

// 6. `logOut` method: This method logs out the currently logged-in user by 
//calling `_auth.signOut()`. If a user is successfully logged out, the method 
//completes successfully. Otherwise, it throws a `UserNotLoggedInAuthException`
// if no user is logged in.

// 7. `sendEmailVerification` method: This method sends an email verification 
//request to the currently logged-in user by calling `
//user.sendEmailVerification()`. If the request is successful, the email 
//verification is sent. Otherwise, it throws a `UserNotLoggedInAuthException` 
//if no user is logged in.

// 8. `sendPasswordReset` method: This method sends a password reset email to 
//the specified email address using `_auth.sendPasswordResetEmail()`. If the 
//email is successfully sent, the password reset process is initiated. If any 
//error occurs, appropriate exceptions are thrown based on the specific error 
//code.

// 9. `signInWithGoogle` method: This method performs the sign-in process using 
//Google authentication. It uses the `_googleSignIn.signIn()` method to initiate
// the Google sign-in flow. Once the user is authenticated with Google, the 
//method obtains the necessary credentials and calls `
//_auth.signInWithCredential()` to authenticate the user with Firebase 
//Authentication. The method returns a `UserCredential` object representing the 
//authenticated user.

// Overall, the `FirebaseAuthProvider` class encapsulates the authentication 
//operations using Firebase Authentication and provides methods to create 
//users, log in, log out, send email verification, and perform password reset. 
//It handles different authentication scenarios, throws specific exceptions for 
//different error cases, and integrates with Google sign-in functionality.