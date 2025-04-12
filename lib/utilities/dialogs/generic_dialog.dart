import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options.keys.map((optionTitle) {
          final value = options[optionTitle];
          return TextButton(
            onPressed: () {
              if (value != null) {
                Navigator.of(context).pop(value);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(optionTitle),
          );
        }).toList(),
      );
    },
  );
}


// The code you provided defines a function `showGenericDialog` that displays 
//a generic dialog with customizable options and returns a `Future<T?>`. Here's 
//the flow and logic behind the code:

// 1. Function Signature: The `showGenericDialog` function takes several 
//required parameters: a `BuildContext` named `context`, a `String` named 
//`title`, a `String` named `content`, and a `DialogOptionBuilder` named 
//`optionsBuilder`. It returns a `Future<T?>`.

// 2. Creating the Options Map: The function calls the `optionsBuilder` 
//function, which should be provided by the caller. This function returns a 
//`Map<String, T?>` where the keys represent the option titles and the values
// represent the option values. The option values can be of any type `T`.

// 3. Showing the Dialog: The `showDialog` function is called to display the 
//dialog. It takes the following parameters:
//    - `context`: The `BuildContext` passed to the `showGenericDialog` function.
//    - `builder`: A callback function that returns the `AlertDialog` widget. 
//Within the builder function, the dialog is created using the provided `title
//`, `content`, and `options`.

// 4. Building the AlertDialog: Within the builder function, an `AlertDialog`
// is created with the following properties:
//    - `title`: The `Text` widget displaying the provided `title`.
//    - `content`: The `Text` widget displaying the provided `content`.
//    - `actions`: The list of actions in the dialog, which are generated based
// on the provided options. Each option title is mapped to a `TextButton`, and
// when pressed, the corresponding value (if not `null`) is passed back through 
// `Navigator.of(context).pop(value)`.

// 5. Returning the Future: The `showDialog` function returns a `Future<T?>` 
//that resolves to the value of the chosen option. When an option is selected, 
//the corresponding value is passed as the result of the future. If no value is
// associated with the chosen option, `null` is returned.

// The purpose of this code is to provide a reusable and flexible way to 
//display a generic dialog with customizable options. The caller can provide 
//the dialog's title, content, and options, and the function takes care of 
//displaying the dialog and returning the selected option's value as a future 
//result.
