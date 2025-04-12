import 'package:flutter/foundation.dart';

typedef CloseLoadingScreen = bool Function();
typedef UpdateLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final CloseLoadingScreen close;
  final UpdateLoadingScreen update;

  const LoadingScreenController({
    required this.close,
    required this.update,
  });
}


// The code in `loading_screen_controller.dart` defines a `
//LoadingScreenController` class, which is responsible for controlling a 
//loading screen. Here's the flow and logic behind the code:

// 1. `LoadingScreenController` class:
//    - The class is marked as `@immutable`, indicating that its instances 
//are immutable and cannot be changed once created.
//    - It encapsulates two functions: `close` and `update`.

// 2. `CloseLoadingScreen` typedef:
//    - Defines a function type `CloseLoadingScreen` that takes no arguments 
//and returns a `bool` value.
//    - The `CloseLoadingScreen` function is intended to be used to close the 
//loading screen and return a boolean value indicating whether the screen was 
//closed successfully.

// 3. `UpdateLoadingScreen` typedef:
//    - Defines a function type `UpdateLoadingScreen` that takes a `String` 
//argument for the loading text and returns a `bool` value.
//    - The `UpdateLoadingScreen` function is intended to be used to update
// the loading screen with a new loading text and return a boolean value 
//indicating whether the update was successful.

// 4. Purpose:
//    - The `LoadingScreenController` class provides a way to control the 
//behavior of a loading screen.
//    - It acts as a mediator between the loading screen and the components 
//that interact with it.
//    - The `close` function can be called to request the closing of the 
//loading screen, and the returned boolean value indicates whether the closing 
//operation was successful.
//    - The `update` function can be called to update the loading screen with 
//a new loading text, and the returned boolean value indicates whether the 
//update operation was successful.
//    - By encapsulating these functions in the `LoadingScreenController`, 
//it provides a convenient way to manage and control the loading screen's 
//behavior from different parts of the application.

// Overall, the `LoadingScreenController` class facilitates the coordination 
//and control of a loading screen, allowing other parts of the application to 
//interact with it and perform actions such as closing the screen or updating
// its content.