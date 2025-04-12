// login exceptions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// register exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

// generic exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

class ChangePasswordFailedException implements Exception {
  final String message;

  ChangePasswordFailedException(this.message);

  @override
  String toString() => 'ChangePasswordFailedException: $message';
}

// network and rate-limiting exceptions
class NetworkAuthException implements Exception {}

class TooManyRequestsAuthException implements Exception {}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// //login exceptions
// class UserNotFoundAuthException implements Exception {}

// class WrongPasswordAuthException implements Exception {}

// //register exceptions
// class WeakPasswordAuthException implements Exception {}

// class EmailAlreadyInUseAuthException implements Exception {}

// class InvalidEmailAuthException implements Exception {}

// //generic exceptions
// class GenericAuthException implements Exception {}

// class UserNotLoggedInAuthException implements Exception {}

// class ChangePasswordFailedException implements Exception {
//   final String message;

//   ChangePasswordFailedException(this.message);

//   @override
//   String toString() => 'ChangePasswordFailedException: $message';
// }


// The code in `auth_exceptions.dart` defines a set of custom exceptions 
//related to authentication. These exceptions are used to handle different 
//error scenarios that can occur during authentication operations. Let's break 
//down the flow and logic of the code:

// 1. Exception classes:
//    - `UserNotFoundAuthException`: This exception is thrown when a user is not 
//found during the login process.
//    - `WrongPasswordAuthException`: This exception is thrown when an incorrect 
//password is provided during the login process.
//    - `WeakPasswordAuthException`: This exception is thrown when a weak 
//password is detected during the registration process.
//    - `EmailAlreadyInUseAuthException`: This exception is thrown when an
// email is already associated with an existing user during the registration
// process.
//    - `InvalidEmailAuthException`: This exception is thrown when an invalid 
//email is provided during the registration or password reset process.
//    - `GenericAuthException`: This exception is used as a generic exception 
//for handling authentication errors that don't fall into any specific category.
//    - `UserNotLoggedInAuthException`: This exception is thrown when an 
//operation is attempted that requires the user to be logged in, but the user 
//is not currently authenticated.

//    By defining these exception classes, the code provides a way to handle 
//and differentiate various authentication-related errors that can occur in 
//the application. Each exception class represents a specific error scenario, 
//allowing for more targeted error handling and user feedback.

// These custom exceptions can be caught and handled appropriately in the 
//application code, providing specific error messages or performing specific
// actions based on the type of exception thrown.