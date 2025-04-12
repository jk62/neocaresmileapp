import 'package:flutter/widgets.dart';

import 'generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty note !',
    optionsBuilder: () => {
      'Ok': null,
    },
  );
}


// The code you provided defines a function `showCannotShareEmptyNoteDialog` 
//that displays a generic dialog with a message indicating that an empty note 
//cannot be shared. It uses the `showGenericDialog` function to create and 
//show the dialog. Here's the flow and logic behind the code:

// 1. Function Signature: The `showCannotShareEmptyNoteDialog` function takes 
//a `BuildContext` named `context` as a parameter. It returns a `Future<void>`.

// 2. Showing the Dialog: The function calls the `showGenericDialog` function
// to display the dialog. It passes the following parameters:
//    - `context`: The `BuildContext` passed to the `
//showCannotShareEmptyNoteDialog` function.
//    - `title`: A string `'Sharing'` to be displayed as the dialog title.
//    - `content`: A string `'You cannot share an empty note !'` to be 
//displayed as the dialog content.
//    - `optionsBuilder`: A callback function that returns a `Map<String, T?>` 
//with a single key-value pair: `'Ok': null`. This represents the only option 
//available in the dialog, which is an "Ok" button.

// 3. Returning the Future: The `showGenericDialog` function returns a 
//`Future<T?>`, which is also returned by the `showCannotShareEmptyNoteDialog`
// function. In this case, the future resolves to `void` since no specific
// value is returned or expected.

// The purpose of this code is to provide a simple way to display a generic 
//dialog with a message indicating that an empty note cannot be shared. The 
//`showCannotShareEmptyNoteDialog` function encapsulates the dialog creation 
//and presentation logic, allowing the caller to easily show the dialog when 
//needed.