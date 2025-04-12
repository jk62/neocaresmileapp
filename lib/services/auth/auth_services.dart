import 'package:neocaresmileapp/services/auth/auth_exceptions.dart';
import 'my_auth_provider.dart';
import 'auth_user.dart';
import 'firebase_auth_provider.dart';

class AuthService implements MyAuthProvider {
  final MyAuthProvider provider;

  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({required String email, required String password}) =>
      provider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);

  @override
  Future<AuthUser> signInWithCredential(credential) =>
      provider.signInWithCredential(credential);

  @override
  Future<AuthUser> signInWithGoogle() => provider.signInWithGoogle();

  //-------------------------------------------------------------//

  @override
  Future<void> changePassword({
    required String email,
    required String currentPassword, // Add this parameter
    required String newPassword,
  }) async {
    try {
      await provider.changePassword(
        email: email,
        currentPassword: currentPassword, // Pass this parameter
        newPassword: newPassword,
      );
    } catch (e) {
      throw ChangePasswordFailedException('Failed to change password: $e');
    }
  }

  //---------------------------------------------------------------//
}


// The code in `auth_service.dart` provides an implementation of the 
//`AuthProvider` interface and acts as a wrapper around the chosen 
//authentication provider. Let's break down the flow and logic of the code:

// 1. `AuthService` class: This class implements the `AuthProvider` interface, 
//which defines a set of authentication-related methods. It has a single 
//property, `provider`, of type `AuthProvider`, which represents the underlying 
//authentication provider.

// 2. Constructor: The `AuthService` class has a constructor that takes an 
//instance of `AuthProvider` as a parameter. It assigns the provided `provider`
// to the `provider` property.

// 3. `factory AuthService.firebase` constructor: This factory constructor 
//creates an instance of `AuthService` with the `FirebaseAuthProvider` as the 
//underlying authentication provider. It is a convenient way to create an 
//`AuthService` instance specifically for Firebase Authentication.

// 4. Method implementations: The `AuthService` class implements the methods 
//defined in the `AuthProvider` interface by delegating the calls to the 
//corresponding methods of the `provider` object. These methods include:

//    - `createUser`: Delegates the call to the `createUser` method of the 
// `provider`.
//    - `currentUser`: Returns the current user by delegating the call to the `
//currentUser` property of the `provider`.
//    - `logIn`: Delegates the call to the `logIn` method of the `provider`.
//    - `logOut`: Delegates the call to the `logOut` method of the `provider`.
//    - `sendEmailVerification`: Delegates the call to the 
//`sendEmailVerification` method of the `provider`.
//    - `initialize`: Delegates the call to the `initialize` method of the 
// `provider`.
//    - `sendPasswordReset`: Delegates the call to the `sendPasswordReset`
// method of the `provider`.

//    By implementing these methods, the `AuthService` class provides a unified
// interface for authentication operations regardless of the underlying provider.

// Overall, the `AuthService` class acts as an abstraction layer between the 
//application and the authentication provider. It allows for easy switching 
//between different authentication providers by implementing the `AuthProvider
//` interface and forwarding method calls to the specific provider. The use of
// factory constructors, such as `AuthService.firebase`, simplifies the 
//creation of `AuthService` instances with the desired provider.