import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Logout',
    content: 'Are you sure you want to logout',
    optionsBuilder: () => {
      'Cancel': false,
      'Log Out': true,
    },
  ).then(
    (value) => value ?? false,
  );
}

class LogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutDialog({Key? key, required this.onConfirm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Logout Confirmation'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text('Logout'),
        ),
      ],
    );
  }
}

// The code you provided consists of two parts: a function named 
//`showLogOutDialog` and a `LogoutDialog` widget. Let's break down the flow 
//and logic behind each part:

// 1. `showLogOutDialog` function:
//    - Function Signature: The function `showLogOutDialog` takes a 
//`BuildContext` parameter and returns a `Future<bool>`. The `BuildContext` 
//is used to show the dialog within the current widget tree.
//    - Calling `showGenericDialog`: The function calls the `showGenericDialog` 
//function, passing the required parameters and options.
//    - Dialog Title and Content: The title of the dialog is set to 'Logout', 
//and the content is set to 'Are you sure you want to logout'.
//    - Options Builder: The `optionsBuilder` parameter is a callback function 
//that returns a map of button labels and their corresponding actions. In this 
//case, there are two options: 'Cancel' with a value of `false` and 'Log Out' 
//with a value of `true`.
//    - Handling the Result: The `showGenericDialog` function returns a `
//Future` that resolves to a `bool` value representing the user's choice. 
//The function uses the `then` method to handle the result, returning `value ?? 
//false`. If the user closes the dialog without selecting an option, the 
//function defaults to `false`.

// 2. `LogoutDialog` widget:
//    - Widget Description: The `LogoutDialog` widget is a stateless widget 
//that displays an `AlertDialog` with a logout confirmation message.
//    - Constructor: The widget takes a `VoidCallback` named `onConfirm` as a 
//required parameter, which is a callback function to be executed when the user
//confirms the logout.
//    - Building the AlertDialog: In the `build` method, an `AlertDialog` 
//widget is created with a title, content, and action buttons.
//    - Action Buttons: The AlertDialog has two `TextButton` widgets as 
//actions. The 'Cancel' button triggers `Navigator.of(context).pop()` when 
//pressed, closing the dialog. The 'Logout' button triggers the `onConfirm`
// callback when pressed.
   
// The purpose of this code is to provide a convenient way to show a logout
// dialog and handle the user's choice. The `showLogOutDialog` function 
//abstracts away the details of creating and displaying the dialog, while 
//the `LogoutDialog` widget defines the visual representation and behavior of 
//the dialog.