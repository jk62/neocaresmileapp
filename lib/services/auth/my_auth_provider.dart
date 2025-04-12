import 'auth_user.dart';

abstract class MyAuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  //--------------------------------------//

  Future<void> changePassword({
    required String email,
    required String currentPassword, // Add this parameter
    required String newPassword,
  });

  //--------------------------------------//

  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordReset({required String toEmail});
  // Add the new method signature for signInWithCredential
  Future<AuthUser> signInWithCredential(dynamic credential);

  // Add the method signature for signInWithGoogle
  Future<AuthUser> signInWithGoogle();
}


// The code in `auth_provider.dart` defines an abstract class `AuthProvider` 
//that serves as an interface for authentication providers. It declares several 
//methods that need to be implemented by concrete authentication providers. 
//Let's break down the flow and logic of the code:

// 1. `AuthProvider` class: This abstract class defines a set of methods that 
//represent various authentication operations. It provides a contract for 
//authentication providers to adhere to.

// 2. Method signatures:
//    - `initialize`: This method is responsible for initializing the 
//authentication provider. It typically involves setting up any necessary 
//configurations or establishing connections. The implementation details are 
//left to the concrete providers.
//    - `currentUser`: This getter returns the currently authenticated user. 
//It is expected to return an instance of `AuthUser` or `null` if no user is 
//authenticated.
//    - `logIn`: This method is used to log in a user with the provided email 
//and password. It expects the email and password as parameters and returns an
// instance of `AuthUser` representing the logged-in user.
//    - `createUser`: This method is used to create a new user with the provided
// email and password. It expects the email and password as parameters and 
//returns an instance of `AuthUser` representing the newly created user.
//    - `logOut`: This method is responsible for logging out the currently 
//authenticated user.
//    - `sendEmailVerification`: This method sends an email verification 
//link to the currently authenticated user.
//    - `sendPasswordReset`: This method sends a password reset email to the 
//specified email address.

//    The method signatures provide a clear contract that concrete 
//authentication providers must follow.

// By defining the `AuthProvider` interface, the code establishes a common set
// of methods that any authentication provider can implement. This allows for
// a unified approach to authentication operations in the application, 
//regardless of the specific authentication provider being used. Different 
//authentication providers can implement the `AuthProvider` interface and 
//provide their own implementation logic for each method.