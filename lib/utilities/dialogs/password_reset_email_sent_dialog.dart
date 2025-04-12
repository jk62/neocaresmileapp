import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content:
        'We have just sent a reset password email. Please check your email for more information ',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

// The code you provided is for a function named `showPasswordResetSentDialog` 
//that displays a dialog box informing the user that a password reset email has 
//been sent. Let's break down the flow and logic behind this code:

// 1. Function Signature: The function `showPasswordResetSentDialog` takes a 
//`BuildContext` parameter and returns a `Future<void>`. The `BuildContext` 
//is used to show the dialog within the current widget tree.

// 2. Calling `showGenericDialog`: The function calls the `showGenericDialog` 
//function, passing the required parameters and options.

// 3. Dialog Title and Content: The title of the dialog is set to 'Password 
//Reset', and the content of the dialog is set to 'We have just sent a reset
// password email. Please check your email for more information'.

// 4. Options Builder: The `optionsBuilder` parameter is a callback function 
//that returns a map of button labels and their corresponding actions. In this 
//case, there is a single option 'OK' with a `null` action, indicating that 
//pressing the 'OK' button will close the dialog.

// 5. Displaying the Dialog: The `showGenericDialog` function creates and 
//displays the dialog using the provided parameters and options.

// 6. Returning a Future: The `showPasswordResetSentDialog` function returns 
//a `Future<void>`, indicating that it completes when the dialog is dismissed.

// The purpose of this code is to provide a reusable function that shows a 
//dialog informing the user about the password reset email being sent. It 
//abstracts away the details of creating and displaying the dialog, making it 
//easier to reuse and maintain consistent dialog styles throughout the 
//application.