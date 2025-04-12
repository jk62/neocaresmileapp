import "package:firebase_auth/firebase_auth.dart" show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final String? email;
  final bool isEmailVerified;
  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        email: user.email!,
        isEmailVerified: user.emailVerified,
      );
}


// The code in `auth_user.dart` defines the `AuthUser` class, which represents
// a user authenticated through Firebase Authentication. Let's break down the 
//flow and logic of the code:

// 1. `AuthUser` class: This class is an immutable class that represents an 
//authenticated user. It contains the user's ID, email, and email verification 
//status.

// 2. Constructor: The `AuthUser` class has a constructor that initializes 
//the `id`, `email`, and `isEmailVerified` properties. These properties are
// marked as `required` since they must be provided during object creation.

// 3. `factory AuthUser.fromFirebase` constructor: This factory constructor 
//is used to create an instance of `AuthUser` from a `User` object obtained 
//from Firebase Authentication. It takes a `User` object as a parameter and
// extracts the necessary information to create an `AuthUser` instance. The
// user's ID is obtained from `user.uid`, the email is obtained from 
//`user.email`, and the email verification status is obtained from 
//`user.emailVerified`.

//    - `user.uid` represents the unique identifier of the user.
//    - `user.email` represents the user's email address.
//    - `user.emailVerified` indicates whether the user's email has been verified.

//    The factory constructor creates an `AuthUser` instance using the 
//extracted information and returns it.

// Overall, the `AuthUser` class provides a simple data structure to hold user 
//information obtained from Firebase Authentication. It has a factory 
//constructor that enables the creation of an `AuthUser` instance from a 
//`User` object, allowing for easy mapping between Firebase's `User` 
//object and the `AuthUser` class.