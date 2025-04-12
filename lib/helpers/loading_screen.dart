import 'dart:async';
import 'package:flutter/material.dart';

import 'loading_screen_controller.dart';

class LoadingScreen {
  factory LoadingScreen() => _shared;
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();

  LoadingScreenController? controller;

  void hide() {
    controller?.close();
    controller = null;
  }

  void show({
    required BuildContext context,
    required String text,
  }) {
    if (controller?.update(text) ?? false) {
      return;
    } else {
      controller = showOverlay(
        context: context,
        text: text,
      );
    }
  }

  LoadingScreenController showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final textController = StreamController<String>();
    textController.add(text);

    final overlayState = Overlay.of(context);
    if (overlayState == null) {
      throw FlutterError('Overlay is null');
    }

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                minWidth: MediaQuery.of(context).size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      StreamBuilder<String>(
                        stream: textController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    return LoadingScreenController(
      close: () {
        textController.close();
        overlayEntry.remove();
        return true;
      },
      update: (text) {
        textController.add(text);
        return true;
      },
    );
  }
}

// CODE BEFORE FIXING ERRORS 
// import 'dart:async';
// import 'package:flutter/material.dart';

// import 'loading_screen_controller.dart';

// class LoadingScreen {
//   factory LoadingScreen() => _shared;
//   static final LoadingScreen _shared = LoadingScreen._sharedInstance();
//   LoadingScreen._sharedInstance();

//   LoadingScreenController? controller;
//   GlobalKey? overlayKey; // New line

//   void hide() {
//     controller?.close();
//     controller = null;
//     overlayKey = null; // New line
//   }

//   void show({
//     required BuildContext context,
//     required String text,
//   }) {
//     if (controller?.update(text) ?? false) {
//       return;
//     } else {
//       overlayKey = GlobalKey(); // New line
//       controller = showOverlay(
//         context: context,
//         text: text,
//       );
//     }
//   }

//   LoadingScreenController showOverlay({
//     required BuildContext context,
//     required String text,
//   }) {
//     final text0 = StreamController<String>();
//     text0.add(text);

//     final state = Overlay.of(context);
//     final renderBox = overlayKey!.currentContext!.findRenderObject()
//         as RenderBox; // Updated line
//     final size = renderBox.size;

//     final overlay = OverlayEntry(
//       builder: (context) {
//         return Material(
//           color: Colors.black.withAlpha(150),
//           child: Center(
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: size.width * 0.8,
//                 maxHeight: size.height * 0.8,
//                 minWidth: size.width * 0.5,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: SingleChildScrollView(
//                     child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 10),
//                     const CircularProgressIndicator(),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     StreamBuilder(
//                       stream: text0.stream,
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData) {
//                           return Text(
//                             snapshot.data as String,
//                             textAlign: TextAlign.center,
//                           );
//                         } else {
//                           return Container();
//                         }
//                       },
//                     )
//                   ],
//                 )),
//               ),
//             ),
//           ),
//         );
//       },
//     );

//     state.insert(overlay);

//     return LoadingScreenController(close: () {
//       text0.close();
//       overlay.remove();
//       return true;
//     }, update: (text) {
//       text0.add(text);
//       return true;
//     });
//   }
// }

// code below was stable before
// import 'dart:async';
// import 'package:flutter/material.dart';

// import 'loading_screen_controller.dart';

// // class LoadingScreen {
// //   factory LoadingScreen() => _shared;
// //   static final LoadingScreen _shared = LoadingScreen._sharedInstance();
// //   LoadingScreen._sharedInstance();

// //   LoadingScreenController? controller;

// //   void hide() {
// //     controller?.close();
// //     controller = null;
// //   }

// //   // void show({
// //   //   required BuildContext context,
// //   //   required String text,
// //   // }) {
// //   //   if (controller?.update(text) ?? false) {
// //   //     return;
// //   //   } else {
// //   //     controller = showOverlay(
// //   //       context: context,
// //   //       text: text,
// //   //     );
// //   //   }
// //   // }

// //   void show({
// //     required BuildContext context,
// //     required String text,
// //   }) {
// //     if (controller?.update(text) ?? false) {
// //       return;
// //     } else {
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         controller = showOverlay(
// //           context: context,
// //           text: text,
// //         );
// //       });
// //     }
// //   }

// class LoadingScreen {
//   // Define a GlobalKey
//   final GlobalKey overlayKey = GlobalKey();
//   factory LoadingScreen() => _shared;
//   static final LoadingScreen _shared = LoadingScreen._sharedInstance();
//   LoadingScreen._sharedInstance();

//   LoadingScreenController? controller;
//   final GlobalKey _overlayKey = GlobalKey();

//   void hide() {
//     controller?.close();
//     controller = null;
//   }

//   void show({
//     required BuildContext context,
//     required String text,
//   }) {
//     if (controller?.update(text) ?? false) {
//       return;
//     } else {
//       WidgetsBinding.instance!.addPostFrameCallback((_) {
//         final RenderBox renderBox =
//             _overlayKey.currentContext!.findRenderObject() as RenderBox;
//         final size = renderBox.size;

//         controller = showOverlay(
//           context: context,
//           text: text,
//           overlaySize: size,
//         );
//       });
//     }
//   }

// //   LoadingScreenController showOverlay({
// //     required BuildContext context,
// //     required String text,
// //     required Size overlaySize,// this line is added
// //   }) {
// //     final text0 = StreamController<String>();
// //     text0.add(text);

// //     final state = Overlay.of(context);
// //     final renderBox = context.findRenderObject() as RenderBox;
// //     final size = renderBox.size;

// //     final overlay = OverlayEntry(
// //       builder: (context) {
// //         return Material(
// //           color: Colors.black.withAlpha(150),
// //           child: Center(
// //             child: Container(
// //               constraints: BoxConstraints(
// //                 maxWidth: size.width * 0.8,
// //                 maxHeight: size.height * 0.8,
// //                 minWidth: size.width * 0.5,
// //               ),
// //               decoration: BoxDecoration(
// //                 color: Colors.black,
// //                 borderRadius: BorderRadius.circular(10.0),
// //               ),
// //               child: Padding(
// //                 padding: const EdgeInsets.all(16.0),
// //                 child: SingleChildScrollView(
// //                     child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     const SizedBox(height: 10),
// //                     const CircularProgressIndicator(),
// //                     const SizedBox(
// //                       height: 20,
// //                     ),
// //                     StreamBuilder(
// //                       stream: text0.stream,
// //                       builder: (context, snapshot) {
// //                         if (snapshot.hasData) {
// //                           return Text(
// //                             snapshot.data as String,
// //                             textAlign: TextAlign.center,
// //                           );
// //                         } else {
// //                           return Container();
// //                         }
// //                       },
// //                     )
// //                   ],
// //                 )),
// //               ),
// //             ),
// //           ),
// //         );
// //       },

// //     );

// //     state.insert(overlay);

// //     return LoadingScreenController(close: () {
// //       text0.close();
// //       overlay.remove();
// //       return true;
// //     }, update: (text) {
// //       text0.add(text);
// //       return true;
// //     });
// //   }
// // }
//   LoadingScreenController showOverlay({
//     required BuildContext context,
//     required String text,
//     required Size overlaySize,
//   }) {
//     final text0 = StreamController<String>();
//     text0.add(text);

//     final state = Overlay.of(context);
//     final overlay = OverlayEntry(
//       builder: (context) {
//         return Material(
//           color: Colors.black.withAlpha(150),
//           child: Center(
//             child: Container(
//               key: overlayKey, // Assign GlobalKey to Container
//               constraints: BoxConstraints(
//                 maxWidth: overlaySize.width * 0.8,
//                 maxHeight: overlaySize.height * 0.8,
//                 minWidth: overlaySize.width * 0.5,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const SizedBox(height: 10),
//                       const CircularProgressIndicator(),
//                       const SizedBox(
//                         height: 20,
//                       ),
//                       StreamBuilder(
//                         stream: text0.stream,
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             return Text(
//                               snapshot.data as String,
//                               textAlign: TextAlign.center,
//                             );
//                           } else {
//                             return Container();
//                           }
//                         },
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );

//     state.insert(overlay);

//     return LoadingScreenController(
//       close: () {
//         text0.close();
//         overlay.remove();
//         return true;
//       },
//       update: (text) {
//         text0.add(text);
//         return true;
//       },
//     );
//   }
// }


// The code in `loading_screen.dart` defines a `LoadingScreen` class that 
//facilitates the display and control of a loading screen. Here's the flow and
// logic behind the code:

// 1. `LoadingScreen` class:
//    - The class is responsible for showing and hiding a loading screen.
//    - It implements the singleton design pattern, ensuring that only one 
//instance of `LoadingScreen` exists.
//    - It contains a `LoadingScreenController` instance, which is used to 
//control the behavior of the loading screen.

// 2. `hide()` method:
//    - The `hide()` method is used to hide the loading screen by closing 
//the controller and setting it to `null`.

// 3. `show()` method:
//    - The `show()` method is used to show the loading screen with the 
//provided `BuildContext` and `text`.
//    - If the loading screen is already visible and the text is the same as 
//the current text, the method returns early.
//    - Otherwise, it calls the `showOverlay()` method to display the loading 
//screen and assigns the returned `LoadingScreenController` instance to the 
//`controller` variable.

// 4. `showOverlay()` method:
//    - The `showOverlay()` method is responsible for creating and displaying 
//the loading screen overlay.
//    - It creates a `StreamController<String>` to handle the text updates of 
//the loading screen.
//    - It retrieves the `Overlay` state from the provided `BuildContext`.
//    - It creates an `OverlayEntry` with a builder that returns a `Material` 
//widget representing the loading screen overlay.
//    - The overlay contains a `Container` with a `CircularProgressIndicator`
// and a `Text` widget that displays the loading text.
//    - The `OverlayEntry` is inserted into the overlay state.
//    - Finally, a `LoadingScreenController` instance is returned with the
// necessary functions to close the loading screen and update its text.

// Overall, the `LoadingScreen` class provides a convenient way to show and
// hide a loading screen overlay. It uses the `LoadingScreenController` to 
//control the behavior of the loading screen and manage its state. The loading 
//screen overlay is displayed using the Flutter `Overlay` mechanism, and the 
//text content of the loading screen can be updated dynamically.