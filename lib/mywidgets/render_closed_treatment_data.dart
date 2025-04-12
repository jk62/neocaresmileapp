import 'dart:io';
import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/full_screen_image_dialog.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:developer' as devtools show log;

class RenderClosedTreatmentData extends StatelessWidget {
  final Map<String, dynamic>? treatmentData;
  final void Function() onGalleryButtonPressed;
  final List<Map<String, dynamic>> pictureData;

  const RenderClosedTreatmentData({
    super.key,
    this.treatmentData,
    required this.onGalleryButtonPressed,
    required this.pictureData,
  });

  @override
  Widget build(BuildContext context) {
    if (treatmentData != null) {
      final chiefComplaint = treatmentData!['chiefComplaint'];
      final oralExamination =
          treatmentData!['oralExamination'] as List<dynamic>?;
      final procedures = treatmentData!['procedures'] as List<dynamic>?;

      devtools.log('chiefComplaint: $chiefComplaint');
      devtools.log('oralExamination: $oralExamination');
      devtools.log('procedures: $procedures');

      final treatmentCost =
          treatmentData!['treatmentCost'] as Map<String, dynamic>?;

      final widgets = <Widget>[];

      // Render Chief Complaint
      if (chiefComplaint != null && chiefComplaint.isNotEmpty) {
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: MyColors.colorPalette['outline'] ?? Colors.black,
                    ),
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      'Treatment Summary',
                      style: MyTextStyle.textStyleMap['title-large']?.copyWith(
                          color: MyColors.colorPalette['on-surface']),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Chief Complaint',
                        style: MyTextStyle.textStyleMap['title-medium']
                            ?.copyWith(
                                color: MyColors.colorPalette['on-surface']),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          chiefComplaint,
                          style: MyTextStyle.textStyleMap['label-large']
                              ?.copyWith(
                                  color: MyColors.colorPalette['secondary']),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        devtools.log('Chief Complaint is null or empty');
      }

      if (oralExamination != null && oralExamination.isNotEmpty) {
        // Add the "Oral Examination" title and divider once before the first card
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                thickness: 1.0,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Oral Examination',
                  style: MyTextStyle.textStyleMap['title-medium']
                      ?.copyWith(color: MyColors.colorPalette['on-surface']),
                ),
              ),
            ],
          ),
        );

        // Loop through the oralExamination list to add examination cards
        for (final exam in oralExamination) {
          final doctorNote = exam['doctorNote'];
          final conditionName = exam['conditionName'];
          final affectedTeeth = exam['affectedTeeth'] as List<dynamic>?;

          widgets.add(
            Container(
              width:
                  double.infinity, // Ensures the container takes up full width
              decoration: BoxDecoration(
                border: Border.all(
                  color: MyColors.colorPalette['outline']!, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius:
                    BorderRadius.circular(8.0), // Rounded corners if desired
              ),
              padding: const EdgeInsets.all(8.0), // Padding inside the border
              margin:
                  const EdgeInsets.only(bottom: 8.0), // Spacing between cards
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conditionName ?? '',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Affected Teeth',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['outline']),
                  ),
                  Wrap(
                    spacing: 4.0, // Spacing between chips
                    runSpacing: 2.0, // Spacing between rows of chips
                    children: affectedTeeth != null
                        ? affectedTeeth
                            .map(
                              (tooth) => SizedBox(
                                width: 40.0, // Fixed width for each chip
                                child: Chip(
                                  label: Text(
                                    '$tooth',
                                    style: MyTextStyle
                                        .textStyleMap['label-large']!
                                        .copyWith(
                                            color: MyColors
                                                .colorPalette['on-primary']),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0,
                                      vertical: 0.0), // Chip padding
                                  backgroundColor:
                                      MyColors.colorPalette['primary'],
                                  materialTapTargetSize: MaterialTapTargetSize
                                      .shrinkWrap, // Compact size
                                  visualDensity:
                                      VisualDensity.compact, // Compact density
                                ),
                              ),
                            )
                            .toList()
                        : [],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Doctor Note',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['on-surface']),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doctorNote ?? '',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                  ),
                ],
              ),
            ),
          );
        }
      } else {
        devtools.log('Oral Examination is null or empty');
      }

      if (procedures != null && procedures.isNotEmpty) {
        // Add the "Procedure(s)" title and divider once before the first card
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                thickness: 1.0,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Procedure(s)',
                  style: MyTextStyle.textStyleMap['title-medium']
                      ?.copyWith(color: MyColors.colorPalette['on-surface']),
                ),
              ),
            ],
          ),
        );

        // Loop through the procedures list to add procedure cards
        for (final procedure in procedures) {
          final procName = procedure['procName'];
          final doctorNote = procedure['doctorNote'];
          final affectedTeeth =
              procedure['affectedTeeth'] as List<dynamic>? ?? [];

          widgets.add(
            Container(
              width:
                  double.infinity, // Ensures the container takes up full width
              decoration: BoxDecoration(
                border: Border.all(
                  color: MyColors.colorPalette['outline']!, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius:
                    BorderRadius.circular(8.0), // Rounded corners if desired
              ),
              padding: const EdgeInsets.all(8.0), // Padding inside the border
              margin:
                  const EdgeInsets.only(bottom: 8.0), // Spacing between cards
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    procName ?? '',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Affected Teeth',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['outline']),
                  ),
                  Wrap(
                    spacing: 4.0, // Spacing between chips
                    runSpacing: 2.0, // Spacing between rows of chips
                    children: affectedTeeth
                        .map(
                          (tooth) => SizedBox(
                            width: 40.0, // Fixed width for each chip
                            child: Chip(
                              label: Text(
                                '$tooth',
                                style: MyTextStyle.textStyleMap['label-large']!
                                    .copyWith(
                                        color: MyColors
                                            .colorPalette['on-primary']),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0.0,
                                  vertical: 0.0), // Chip padding
                              backgroundColor: MyColors.colorPalette['primary'],
                              materialTapTargetSize: MaterialTapTargetSize
                                  .shrinkWrap, // Compact size
                              visualDensity:
                                  VisualDensity.compact, // Compact density
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Doctor Note',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['on-surface']),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doctorNote ?? '',
                    style: MyTextStyle.textStyleMap['label-large']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                  ),
                ],
              ),
            ),
          );
        }
      } else {
        devtools.log('Procedures are null or empty');
      }

      // Move the Picture Rendering Logic Here
      if (pictureData.isNotEmpty) {
        devtools.log('Rendering pictures in RenderTreatmentData');
        widgets.add(
          Column(
            children: [
              const Divider(
                thickness: 1.0,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Images',
                    style: MyTextStyle.textStyleMap['title-medium']
                        ?.copyWith(color: MyColors.colorPalette['on-surface']),
                  ),
                ),
              ),
            ],
          ),
        );
        final pictureWidgets = <Widget>[];

        for (int i = 0; i < 2 && i < pictureData.length; i++) {
          final picture = pictureData[i];
          final localPath = picture['localPath'];
          final picUrl = picture['picUrl'];

          pictureWidgets.add(
            SizedBox(
              width: MediaQuery.of(context).size.width / 3 - 16,
              child: GestureDetector(
                onTap: () => _showFullImage(
                  context,
                  localPath,
                  picUrl,
                  picture['note'],
                  List<String>.from(picture['tags'] ?? []),
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.0,
                      color: MyColors.colorPalette['outline'] ?? Colors.grey,
                    ),
                  ),
                  child: Center(
                    child: localPath != null && File(localPath).existsSync()
                        ? Image.file(
                            File(localPath),
                            height: 112,
                            fit: BoxFit.contain,
                          )
                        : picUrl != null
                            ? CachedNetworkImage(
                                imageUrl: picUrl,
                                height: 112,
                                fit: BoxFit.contain,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )
                            : Image.asset(
                                'assets/images/placeholder-image.png',
                                height: 112,
                                fit: BoxFit.contain,
                              ),
                  ),
                ),
              ),
            ),
          );
        }

        if (pictureData.length > 2) {
          pictureWidgets.add(
            SizedBox(
              width: MediaQuery.of(context).size.width / 3 - 16,
              child: GestureDetector(
                onTap: onGalleryButtonPressed,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.0,
                      color: MyColors.colorPalette['outline'] ?? Colors.grey,
                    ),
                  ),
                  height: 112,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 40,
                              color: Colors.black,
                            ),
                            Text(
                              'View All',
                              style: MyTextStyle.textStyleMap['label-large'],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: pictureWidgets,
            ),
          ),
        );
      }

      // Render Treatment Cost
      if (treatmentCost != null) {
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  'Total Cost',
                  style: MyTextStyle.textStyleMap['title-medium']
                      ?.copyWith(color: MyColors.colorPalette['on-surface']),
                ),
              ),
              if (treatmentCost['consultationFee'] != null)
                renderTreatmentCostItem(
                  'Consultation',
                  treatmentCost['consultationFee'] is int
                      ? (treatmentCost['consultationFee'] as int).toDouble()
                      : treatmentCost['consultationFee'] as double,
                ),
              if (procedures != null)
                for (final procedure in procedures)
                  if (treatmentCost[procedure['procId']] != null)
                    renderTreatmentCostItem(
                      procedure['procName'],
                      treatmentCost[procedure['procId']] is int
                          ? (treatmentCost[procedure['procId']] as int)
                              .toDouble()
                          : treatmentCost[procedure['procId']] as double,
                    ),
              const Divider(),
              if (treatmentCost['discount'] != null)
                renderTreatmentCostItem(
                  'Discount',
                  -(treatmentCost['discount'] is int
                      ? (treatmentCost['discount'] as int).toDouble()
                      : treatmentCost['discount'] as double),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  labelColor: MyColors.colorPalette['secondary'],
                  amountColor: MyColors.colorPalette['error'] ?? Colors.red,
                ),
              if (treatmentCost['totalCost'] != null)
                renderTreatmentCostItem(
                  'Total Cost',
                  treatmentCost['totalCost'] is int
                      ? (treatmentCost['totalCost'] as int).toDouble()
                      : treatmentCost['totalCost'] as double,
                  labelStyle: MyTextStyle.textStyleMap['title-large']
                      ?.copyWith(color: MyColors.colorPalette['on-surface']),
                  costStyle: MyTextStyle.textStyleMap['title-large']
                      ?.copyWith(color: MyColors.colorPalette['primary']),
                ),
            ],
          ),
        );
      } else {
        devtools.log('Treatment Cost is null');
      }

      return Column(
        children: widgets,
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  void _showFullImage(BuildContext context, String? localPath, String? imageUrl,
      String? note, List<String> tags) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageDialog(
          localPath: localPath,
          imageUrl: imageUrl ?? '',
          note: note,
          tags: tags,
        ),
      ),
    );
  }

  Widget renderTreatmentCostItem(String label, double? cost,
      {double fontSize = 16,
      FontWeight fontWeight = FontWeight.normal,
      Color? labelColor,
      Color? amountColor,
      TextStyle? labelStyle,
      TextStyle? costStyle}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: labelStyle ??
                MyTextStyle.textStyleMap['title-medium']?.copyWith(
                    color: labelColor ?? MyColors.colorPalette['secondary']),
          ),
          Text(
            cost != null ? cost.toStringAsFixed(0) : '',
            style: costStyle ??
                MyTextStyle.textStyleMap['title-medium']?.copyWith(
                    color: amountColor ?? MyColors.colorPalette['secondary']),
          ),
        ],
      ),
    );
  }
}
