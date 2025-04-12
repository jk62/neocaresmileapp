import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occured',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

// The code you provided defines a function `showErrorDialog` that displays 
//an error dialog with an "OK" option. It uses the `showGenericDialog` function 
//to create and show the dialog. Here's the flow and logic behind the code:

// 1. Function Signature: The `showErrorDialog` function takes two parameters:
// a `BuildContext` named `context` and a `String` named `text`. It returns a `
// Future<void>`.

// 2. Showing the Dialog: The function calls the `showGenericDialog` function 
//to display the error dialog. It passes the following parameters:
//    - `context`: The `BuildContext` passed to the `showErrorDialog` function.
//    - `title`: A string `'An error occurred'` to be displayed as the dialog 
// title.
//    - `content`: The value of the `text` parameter, which represents the error 
//message to be displayed in the dialog.
//    - `optionsBuilder`: A callback function that returns a `Map<String, T?>` 
//with a single key-value pair: `'OK': null`. This represents the only option 
//available in the dialog, which is the "OK" option.

// 3. Returning the Future: The `showGenericDialog` function returns a `
//Future<T?>`, which is also returned by the `showErrorDialog` function. 
//Since the `showGenericDialog` function is called with a `void` type parameter 
//(`<void>`), the returned future will resolve to `null` when the "OK" option 
//is selected in the dialog.

// The purpose of this code is to provide a convenient way to display an error
// dialog with a single "OK" option. The `showErrorDialog` function abstracts 
//away the details of creating and showing the dialog, allowing the caller to 
//easily show error messages to the user.