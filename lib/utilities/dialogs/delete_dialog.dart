import 'package:flutter/cupertino.dart';

import 'generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this item?',
    optionsBuilder: () => {
      'Cancel': false,
      'Yes': true,
    },
  ).then(
    (value) => value ?? false,
  );
}

// The code you provided defines a function `showDeleteDialog` that displays
// a delete confirmation dialog with "Cancel" and "Yes" options. It uses the `
//showGenericDialog` function to create and show the dialog. Here's the flow 
//and logic behind the code:

// 1. Function Signature: The `showDeleteDialog` function takes a `BuildContext`
// named `context` as a parameter. It returns a `Future<bool>`.

// 2. Showing the Dialog: The function calls the `showGenericDialog` function 
//to display the delete confirmation dialog. It passes the following 
//parameters:
//    - `context`: The `BuildContext` passed to the `showDeleteDialog` 
// function.
//    - `title`: A string `'Delete'` to be displayed as the dialog title.
//    - `content`: A string `'Are you sure you want to delete this item?'` 
//to be displayed as the dialog content.
//    - `optionsBuilder`: A callback function that returns a `Map<String, T?>` 
//with two key-value pairs: `'Cancel': false` and `'Yes': true`. This 
//represents the options available in the dialog, where selecting "Cancel"
// will resolve the future to `false` and selecting "Yes" will resolve it to 
// `true`.

// 3. Returning the Future: The `showGenericDialog` function returns a `
//Future<T?>`, which is also returned by the `showDeleteDialog` function. 
//Since the `showGenericDialog` function is called with a `bool` type parameter 
//(`<bool>`), the returned future will resolve to either `true` or `false` 
//depending on the user's choice in the dialog. However, if the user dismisses 
//the dialog without making a selection, the `then` method is used to handle 
//the `null` value and resolve the future to `false` by default.

// The purpose of this code is to provide a convenient way to display a delete 
//confirmation dialog with "Cancel" and "Yes" options. The `showDeleteDialog` 
//function abstracts away the details of creating and showing the dialog, 
//allowing the caller to easily prompt the user for delete confirmation and 
//handle the user's choice.
