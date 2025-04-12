import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neocaresmileapp/constants/routes.dart';
import 'package:neocaresmileapp/firestore/clinic_service.dart';

import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'dart:developer' as devtools show log;
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

import 'package:provider/provider.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? backgroundImage;
  final bool isLandingScreen;
  final String? additionalContent;
  final bool disableBackArrow;

  const CommonAppBar({
    super.key,
    this.backgroundImage,
    required this.isLandingScreen,
    required this.additionalContent,
    this.disableBackArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final clinicSelection = Provider.of<ClinicSelection>(context);

    //-----------------------------------------------------------------------//

    //-----------------------------------------------------------------------//

    devtools.log('clinicSelection is $clinicSelection');
    devtools.log('selectedClinicName is ${clinicSelection.selectedClinicName}');
    String currentDate = DateFormat('MMM d').format(DateTime.now());
    String currentDay = DateFormat('E').format(DateTime.now());

    return SafeArea(
      child: AppBar(
        forceMaterialTransparency: true,
        centerTitle: false,
        automaticallyImplyLeading: !disableBackArrow, // Key change
        flexibleSpace: isLandingScreen && backgroundImage != null
            ? Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(backgroundImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : null,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 48,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    clinicSelection.selectedClinicName,
                    style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
                      color: MyColors.colorPalette['on-surface'],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: clinicSelection.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.arrow_drop_down),
                    onSelected: (String newClinic) {
                      Provider.of<ClinicSelection>(context, listen: false)
                          .updateClinic(newClinic);

                      devtools.log(
                          '**** This is coming from inside PopupMenuButton defined inside CommonAppBar. Updated clinic to $newClinic');
                    },
                    itemBuilder: (BuildContext context) {
                      return clinicSelection.clinicNames
                          .map((String clinicName) {
                        return PopupMenuItem<String>(
                          value: clinicName,
                          child: Text(clinicName),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48.0),
            if (isLandingScreen) // Display additional content only in LandingScreen
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$currentDay, $currentDate',
                    style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
                      color: MyColors.colorPalette['on_surface-variant'],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Hi ! $additionalContent',
                    style: MyTextStyle.textStyleMap['title-large']?.copyWith(
                      color: MyColors.colorPalette['on_surface'],
                    ),
                  ),
                  const SizedBox(height: 96.0),
                ],
              ),
          ],
        ),
        toolbarHeight: isLandingScreen ? 256.0 : 100.0, //kToolbarHeight,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(isLandingScreen ? 256.0 : 100.0); //kToolbarHeight);
}

class AppBarConfig {
  final bool isLandingScreen;
  final String? backgroundImage;
  final String? additionalContent;
  final bool disableBackArrow;

  const AppBarConfig({
    required this.isLandingScreen,
    this.backgroundImage,
    this.additionalContent,
    this.disableBackArrow = false, // Default is false
  });
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// ########################################################################### //
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:neocare_dental_app/constants/routes.dart';
// import 'package:neocare_dental_app/firestore/clinic_service.dart';

// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// import 'package:provider/provider.dart';

// class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String? backgroundImage;
//   final bool isLandingScreen;
//   final String? additionalContent;
//   final bool disableBackArrow;

//   const CommonAppBar({
//     super.key,
//     this.backgroundImage,
//     required this.isLandingScreen,
//     required this.additionalContent,
//     this.disableBackArrow = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final clinicSelection = Provider.of<ClinicSelection>(context);

//     //-----------------------------------------------------------------------//

//     //-----------------------------------------------------------------------//

//     devtools.log('clinicSelection is $clinicSelection');
//     devtools.log('selectedClinicName is ${clinicSelection.selectedClinicName}');
//     String currentDate = DateFormat('MMM d').format(DateTime.now());
//     String currentDay = DateFormat('E').format(DateTime.now());

//     return SafeArea(
//       child: AppBar(
//         forceMaterialTransparency: true,
//         centerTitle: false,
//         automaticallyImplyLeading: !disableBackArrow, // Key change
//         flexibleSpace: isLandingScreen && backgroundImage != null
//             ? Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(backgroundImage!),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             : null,
//         title: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             const SizedBox(
//               height: 48,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     clinicSelection.selectedClinicName,
//                     style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                       color: MyColors.colorPalette['on-surface'],
//                     ),
//                   ),
//                   PopupMenuButton<String>(
//                     icon: const Icon(Icons.arrow_drop_down),
//                     onSelected: (String newClinic) {
//                       ClinicService clinicService = ClinicService();
//                       clinicService.getClinicId(newClinic).then((clinicId) {
//                         Provider.of<ClinicSelection>(context, listen: false)
//                             .updateClinic(newClinic, clinicId);
//                         //-------------------------------------------------------//

//                         devtools.log(
//                             '**** This is coming from inside PopupMenuButton defined inside CommonAppBar. Updated clinic to $newClinic with ID $clinicId');
//                         // Reset the navigation stack to HomePage

//                         //-------------------------------------------------------//
//                       }).catchError((error) {
//                         devtools.log(error.toString());
//                       });
//                     },
//                     itemBuilder: (BuildContext context) {
//                       return clinicSelection.clinicNames
//                           .map((String clinicName) {
//                         return PopupMenuItem<String>(
//                           value: clinicName,
//                           child: Text(clinicName),
//                         );
//                       }).toList();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 48.0),
//             if (isLandingScreen) // Display additional content only in LandingScreen
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '$currentDay, $currentDate',
//                     style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                       color: MyColors.colorPalette['on_surface-variant'],
//                     ),
//                   ),
//                   const SizedBox(height: 8.0),
//                   Text(
//                     'Hi ! $additionalContent',
//                     style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                       color: MyColors.colorPalette['on_surface'],
//                     ),
//                   ),
//                   const SizedBox(height: 96.0),
//                 ],
//               ),
//           ],
//         ),
//         toolbarHeight: isLandingScreen ? 256.0 : 100.0, //kToolbarHeight,
//       ),
//     );
//   }

//   @override
//   Size get preferredSize =>
//       Size.fromHeight(isLandingScreen ? 256.0 : 100.0); //kToolbarHeight);
// }


// class AppBarConfig {
//   final bool isLandingScreen;
//   final String? backgroundImage;
//   final String? additionalContent;
//   final bool disableBackArrow;

//   const AppBarConfig({
//     required this.isLandingScreen,
//     this.backgroundImage,
//     this.additionalContent,
//     this.disableBackArrow = false, // Default is false
//   });
// }


// class AppBarConfig {
//   final bool isLandingScreen;
//   final String? backgroundImage;
//   final String? additionalContent;

//   const AppBarConfig({
//     required this.isLandingScreen,
//     this.backgroundImage,
//     this.additionalContent,
//   });
// }