import 'package:flutter/material.dart';

typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10.0),
        Text(text),
      ],
    ),
  );
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => dialog,
  );

  return () => Navigator.of(context).pop();
}


// The code you provided defines a function `showLoadingDialog` that displays 
//a loading dialog and returns a `CloseDialog` callback function. Here's the 
//flow and logic behind the code:

// 1. Function Signature: The `showLoadingDialog` function takes two required 
//parameters: a `BuildContext` named `context` and a `String` named `text`. It 
//returns a `CloseDialog` callback function.

// 2. Creating the AlertDialog: The function creates an `AlertDialog` widget 
//with a `Column` as its content. The `Column` contains a circular progress 
//indicator (`CircularProgressIndicator`) and a `Text` widget displaying the 
//provided `text`.

// 3. Showing the Dialog: The `showDialog` function is called to display the 
//dialog. It takes the following parameters:
//    - `context`: The `BuildContext` passed to the `showLoadingDialog` function.
//    - `barrierDismissible`: Set to `false` to prevent dismissing the dialog by 
//tapping outside of it.
//    - `builder`: A callback function that returns the `dialog` widget.

// 4. Returning the CloseDialog Callback: Finally, a callback function is 
//returned as `() => Navigator.of(context).pop()`. This function is responsible 
//for closing the dialog when invoked by calling `Navigator.of(context).pop()`.

// The purpose of this code is to provide a convenient way to show a loading 
//dialog with a custom text message. The dialog is displayed using `showDialog`,
// and the returned callback function allows the dialog to be closed 
//programmatically when needed.
