import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;

class MyBottomNavigationBar extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool nextIconSelectable;

  const MyBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.nextIconSelectable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          _buildBackNavItem(context),
          const Spacer(),
          for (int index = 0; index < items.length - 1; index++)
            _buildNavItem(index, items[index], index == currentIndex, context),
          const Spacer(),
          _buildNextNavItem(items.length - 1, items.last),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, BottomNavigationBarItem item, bool isSelected,
      BuildContext context) {
    return InkWell(
      onTap: () {
        if (index < items.length - 1 && nextIconSelectable) {
          onTap(index);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please provide input for all required fields."),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              size: 16,
              color: isSelected
                  ? MyColors.colorPalette['primary'] ?? Colors.blue
                  : MyColors.colorPalette['outline'] ?? Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextNavItem(int navIndex, BottomNavigationBarItem item) {
    return InkWell(
      onTap: () {
        devtools.log('Next icon pressed');
        if (nextIconSelectable) {
          onTap(navIndex);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            currentIndex == 3
                ? Align(
                    alignment: Alignment.topLeft,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        fixedSize:
                            MaterialStateProperty.all(const Size(144, 48)),
                        backgroundColor: MaterialStateProperty.all(
                          nextIconSelectable
                              ? MyColors.colorPalette['on-primary']!
                              : MyColors.colorPalette['primary']!,
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            side: BorderSide(
                              color: nextIconSelectable
                                  ? MyColors.colorPalette['outline']!
                                  : MyColors.colorPalette['primary']!,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        onTap(navIndex);
                      },
                      child: Text(
                        'Take Consent',
                        style:
                            MyTextStyle.textStyleMap['label-large']?.copyWith(
                          color:
                              nextIconSelectable ? Colors.grey : Colors.white,
                        ),
                      ),
                    ),
                  )
                : Text(
                    'Next',
                    style: MyTextStyle.textStyleMap['title-large']?.copyWith(
                      color: nextIconSelectable
                          ? MyColors.colorPalette['primary'] ?? Colors.blue
                          : MyColors.colorPalette['outline'] ?? Colors.grey,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackNavItem(BuildContext context) {
    bool isNotFirstScreen = currentIndex > 0;

    return isNotFirstScreen
        ? InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Back',
                    style: MyTextStyle.textStyleMap['title-large']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox();
  }
}

// CODE BELOW STABLE BEFORE CreateEditTreatmentScreen2A //
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'dart:developer' as devtools show log;

// class MyBottomNavigationBar extends StatelessWidget {
//   final List<BottomNavigationBarItem> items;
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//   final bool nextIconSelectable;

//   const MyBottomNavigationBar({
//     super.key,
//     required this.items,
//     required this.currentIndex,
//     required this.onTap,
//     required this.nextIconSelectable,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       decoration: const BoxDecoration(
//         color: Colors.transparent,
//       ),
//       child: Row(
//         children: [
//           _buildBackNavItem(context),
//           const Spacer(),
//           for (int index = 0; index < items.length - 1; index++)
//             _buildNavItem(index, items[index], index == currentIndex, context),
//           const Spacer(),
//           _buildNextNavItem(items.length - 1, items.last),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem(int index, BottomNavigationBarItem item, bool isSelected,
//       BuildContext context) {
//     return InkWell(
//       onTap: () {
//         if (index < items.length - 1 && nextIconSelectable) {
//           onTap(index);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Please provide input for all required fields."),
//             ),
//           );
//         }
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.circle,
//               size: 16,
//               color: isSelected
//                   ? MyColors.colorPalette['primary'] ?? Colors.blue
//                   : MyColors.colorPalette['outline'] ?? Colors.grey,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNextNavItem(int navIndex, BottomNavigationBarItem item) {
//     return InkWell(
//       onTap: () {
//         devtools.log('Next icon pressed');
//         if (nextIconSelectable) {
//           onTap(navIndex);
//         }
//       },
//       child: Padding(
//         padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             currentIndex == 2
//                 ? Align(
//                     alignment: Alignment.topLeft,
//                     child: ElevatedButton(
//                       style: ButtonStyle(
//                         fixedSize:
//                             MaterialStateProperty.all(const Size(144, 48)),
//                         backgroundColor: MaterialStateProperty.all(
//                           nextIconSelectable
//                               ? MyColors.colorPalette['on-primary']!
//                               : MyColors.colorPalette['primary']!,
//                         ),
//                         shape: MaterialStateProperty.all(
//                           RoundedRectangleBorder(
//                             side: BorderSide(
//                               color: nextIconSelectable
//                                   ? MyColors.colorPalette['outline']!
//                                   : MyColors.colorPalette['primary']!,
//                               width: 1.0,
//                             ),
//                             borderRadius: BorderRadius.circular(24.0),
//                           ),
//                         ),
//                       ),
//                       onPressed: () {
//                         onTap(navIndex);
//                       },
//                       child: Text(
//                         'Take Consent',
//                         style:
//                             MyTextStyle.textStyleMap['label-large']?.copyWith(
//                           color:
//                               nextIconSelectable ? Colors.grey : Colors.white,
//                         ),
//                       ),
//                     ),
//                   )
//                 : Text(
//                     'Next',
//                     style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                       color: nextIconSelectable
//                           ? MyColors.colorPalette['primary'] ?? Colors.blue
//                           : MyColors.colorPalette['outline'] ?? Colors.grey,
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBackNavItem(BuildContext context) {
//     bool isNotFirstScreen = currentIndex > 0;

//     return isNotFirstScreen
//         ? InkWell(
//             onTap: () {
//               Navigator.of(context).pop();
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Back',
//                     style: MyTextStyle.textStyleMap['title-large']
//                         ?.copyWith(color: MyColors.colorPalette['primary']),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         : const SizedBox();
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  /
// CODE BELOW STABLE BEFORE INTRODUCTION OF CreateEditTreatmentScreen2A
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;

// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class MyBottomNavigationBar extends StatelessWidget {
//   final List<BottomNavigationBarItem> items;
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//   final bool nextIconSelectable; // New parameter

//   const MyBottomNavigationBar({
//     super.key,
//     required this.items,
//     required this.currentIndex,
//     required this.onTap,
//     required this.nextIconSelectable,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // decoration: BoxDecoration(
//       //   color: MyColors.colorPalette['on-primary'],
//       //   border: Border(
//       //     top: BorderSide(
//       //       color: MyColors.colorPalette['outline']!,
//       //       width: 1.0,
//       //     ),
//       //   ),
//       // ),
//       padding: const EdgeInsets.only(bottom: 16.0),
//       decoration: const BoxDecoration(
//         color: Colors.transparent, // Set background color to transparent
//       ),
//       child: Row(
//         children: [
//           _buildBackNavItem(context), // Pass context here
//           const Spacer(),
//           for (int index = 0; index < items.length - 1; index++)
//             _buildNavItem(
//               index,
//               items[index],
//               index == currentIndex,
//               nextIconSelectable,
//               context,
//             ),
//           const Spacer(),
//           _buildNextNavItem(
//             items.length - 1,
//             items.last,
//             //currentIndex == items.length - 1,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem(int index, BottomNavigationBarItem item, bool isSelected,
//       bool nextIconSelectable, BuildContext context) {
//     return InkWell(
//       onTap: () {
//         //if (index < items.length - 1 && nextIconSelectable) {
//         if (index < items.length - 1 &&
//             index != currentIndex &&
//             nextIconSelectable) {
//           onTap(index);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                 "Please provide input for chief complaint, doctor note, and at least one quadrant.",
//               ),
//             ),
//           );
//         }
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.circle,
//               size: 16,
//               color: isSelected
//                   ? MyColors.colorPalette['primary'] ?? Colors.blue
//                   : MyColors.colorPalette['outline'] ?? Colors.grey,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNextNavItem(int navIndex, BottomNavigationBarItem item) {
//     devtools.log(
//         'Building NextNavItem: nextIconSelectable=$nextIconSelectable, navIndex=$navIndex');
//     return InkWell(
//       onTap: () {
//         devtools.log('Next icon pressed');
//         devtools.log('nextIconSelectable is $nextIconSelectable');
//         devtools.log('navIndex is $navIndex');
//         if (nextIconSelectable) {
//           onTap(navIndex);
//         }
//       },
//       child: Padding(
//         //padding: const EdgeInsets.all(8.0),
//         padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             currentIndex == 2
//                 ? Align(
//                     alignment: Alignment.topLeft,
//                     child: ElevatedButton(
//                       style: ButtonStyle(
//                         fixedSize: MaterialStateProperty.all(
//                             const Size(144, 48)), // Set fixed width and height

//                         backgroundColor: MaterialStateProperty.all(
//                           nextIconSelectable
//                               ? MyColors.colorPalette['on-primary']!
//                               : MyColors.colorPalette['primary']!,
//                         ),
//                         shape: MaterialStateProperty.all(
//                           RoundedRectangleBorder(
//                             side: BorderSide(
//                               color: nextIconSelectable
//                                   ? MyColors.colorPalette['outline']!
//                                   : MyColors.colorPalette['primary']!,
//                               width: 1.0,
//                             ),
//                             borderRadius: BorderRadius.circular(24.0),
//                           ),
//                         ),
//                       ),
//                       onPressed: () {
//                         onTap(navIndex);
//                         devtools.log('onPressed navIndex is $navIndex');
//                       },
//                       child: Text(
//                         'Take Consent',
//                         style:
//                             MyTextStyle.textStyleMap['label-large']?.copyWith(
//                           color:
//                               nextIconSelectable ? Colors.grey : Colors.white,
//                         ),
//                       ),
//                     ),
//                   )
//                 : Text(
//                     'Next',
//                     // style: TextStyle(
//                     //   color: nextIconSelectable
//                     //       ? MyColors.colorPalette['primary'] ?? Colors.blue
//                     //       : MyColors.colorPalette['outline'] ?? Colors.grey,
//                     // ),
//                     style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                       color: nextIconSelectable
//                           ? MyColors.colorPalette['primary'] ?? Colors.blue
//                           : MyColors.colorPalette['outline'] ?? Colors.grey,
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBackNavItem(BuildContext context) {
//     // Check if the current screen is not the first screen (TreatmentScreen1)
//     bool isNotFirstScreen = currentIndex > 0;

//     return isNotFirstScreen
//         ? InkWell(
//             onTap: () {
//               // Handle back button tap, for example, pop the current screen
//               Navigator.of(context).pop();
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Back',
//                     // style: TextStyle(
//                     //   color: MyColors.colorPalette['primary'] ?? Colors.blue,
//                     // ),
//                     style: MyTextStyle.textStyleMap['title-large']
//                         ?.copyWith(color: MyColors.colorPalette['primary']),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         : const SizedBox(); // Return an empty SizedBox if it's the first screen
//   }
// }

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;

// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class MyBottomNavigationBar extends StatelessWidget {
//   final List<BottomNavigationBarItem> items;
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//   final bool nextIconSelectable; // New parameter
//   //final bool isSubmitting; // Add this line

//   const MyBottomNavigationBar({
//     super.key,
//     required this.items,
//     required this.currentIndex,
//     required this.onTap,
//     required this.nextIconSelectable,
//     //required this.isSubmitting, // Add this line
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.transparent, // Set background color to transparent
//       ),
//       child: Row(
//         children: [
//           _buildBackNavItem(context), // Pass context here
//           const Spacer(),
//           for (int index = 0; index < items.length - 1; index++)
//             _buildNavItem(
//               index,
//               items[index],
//               index == currentIndex,
//               nextIconSelectable,
//               context,
//             ),
//           const Spacer(),
//           _buildNextNavItem(
//             items.length - 1,
//             items.last,
//             //currentIndex == items.length - 1,
//           ),
//         ],
//       ),
//     );
//   }
  

//   Widget _buildNavItem(int index, BottomNavigationBarItem item, bool isSelected,
//       bool nextIconSelectable, BuildContext context) {
//     return InkWell(
//       onTap: () {
//         //if (index < items.length - 1 && nextIconSelectable) {
//         if (index < items.length - 1 &&
//             index != currentIndex &&
//             nextIconSelectable) {
//           onTap(index);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                 "Please provide input for chief complaint, doctor note, and at least one quadrant.",
//               ),
//             ),
//           );
//         }
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.circle,
//               size: 16,
//               color: isSelected
//                   ? MyColors.colorPalette['primary'] ?? Colors.blue
//                   : MyColors.colorPalette['outline'] ?? Colors.grey,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNextNavItem(int index, BottomNavigationBarItem item) {
//     devtools.log(
//         'Building NextNavItem: nextIconSelectable=$nextIconSelectable, index=$index');
//     return InkWell(
//       onTap: () {
//         devtools.log('Next icon pressed');
//         devtools.log('nextIconSelectable is $nextIconSelectable');
//         devtools.log('index is $index');
//         if (nextIconSelectable) {
//           onTap(index);
//         }
//       },
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           currentIndex == 2
//               ? Align(
//                   alignment: Alignment.topLeft,
//                   child: ElevatedButton(
//                     style: ButtonStyle(
//                       fixedSize: MaterialStateProperty.all(
//                           const Size(138, 18)), // Set fixed width and height

//                       backgroundColor: MaterialStateProperty.all(
//                         nextIconSelectable
//                             ? MyColors.colorPalette['on-primary']!
//                             : MyColors.colorPalette['primary']!,
//                       ),
//                       shape: MaterialStateProperty.all(
//                         RoundedRectangleBorder(
//                           side: BorderSide(
//                             color: nextIconSelectable
//                                 ? MyColors.colorPalette['outline']!
//                                 : MyColors.colorPalette['primary']!,
//                             width: 1.0,
//                           ),
//                           borderRadius: BorderRadius.circular(24.0),
//                         ),
//                       ),
//                     ),
//                     onPressed: () {
//                       onTap(index);
//                       devtools.log('onPressed index is $index');
//                     },
//                     child: Text(
//                       'Take Consent',
//                       style: MyTextStyle.textStyleMap['label-large']?.copyWith(
//                         color: nextIconSelectable ? Colors.grey : Colors.white,
//                       ),
//                     ),
//                   ),
//                 )
//               : Text(
//                   'Next',
//                   style: MyTextStyle.textStyleMap['title-large']
//                       ?.copyWith(color: MyColors.colorPalette['primary']),
//                 ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBackNavItem(BuildContext context) {
//     // Check if the current screen is not the first screen (TreatmentScreen1)
//     bool isNotFirstScreen = currentIndex > 0;

//     return isNotFirstScreen
//         ? InkWell(
//             onTap: () {
//               // Handle back button tap, for example, pop the current screen
//               Navigator.of(context).pop();
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Back',
//                     style: MyTextStyle.textStyleMap['title-large']
//                         ?.copyWith(color: MyColors.colorPalette['primary']),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         : const SizedBox(); // Return an empty SizedBox if it's the first screen
//   }
// }

