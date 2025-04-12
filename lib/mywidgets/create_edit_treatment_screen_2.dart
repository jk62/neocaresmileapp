import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/procedure_service.dart';
import 'package:neocaresmileapp/mywidgets/add_procedure_overlay.dart';
import 'package:neocaresmileapp/mywidgets/create_edit_treatment_screen_3.dart';
import 'package:neocaresmileapp/mywidgets/image_cache_provider.dart';
import 'package:neocaresmileapp/mywidgets/my_bottom_navigation_bar.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/procedure.dart';
import 'package:neocaresmileapp/mywidgets/user_data_provider.dart';
import 'package:neocaresmileapp/mywidgets/procedure_cache_provider.dart';

import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

class CreateEditTreatmentScreen2 extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String patientId;
  final int age;
  final String gender;
  final String patientName;
  final String patientMobileNumber;
  final String? patientPicUrl;
  final PageController pageController;
  final UserDataProvider userData;
  final String doctorName;
  final String? uhid;
  final Map<String, dynamic>? treatmentData;
  final String? treatmentId;
  final bool isEditMode;
  final List<String>? originalProcedures;
  final String? chiefComplaint;
  final ImageCacheProvider imageCacheProvider;

  const CreateEditTreatmentScreen2({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.patientId,
    required this.age,
    required this.gender,
    required this.patientName,
    required this.patientMobileNumber,
    required this.patientPicUrl,
    required this.pageController,
    required this.userData,
    required this.doctorName,
    required this.uhid,
    required this.treatmentData,
    required this.treatmentId,
    required this.isEditMode,
    required this.originalProcedures,
    required this.chiefComplaint,
    required this.imageCacheProvider,
  });

  @override
  State<CreateEditTreatmentScreen2> createState() =>
      _CreateEditTreatmentScreen2State();
}

class _CreateEditTreatmentScreen2State
    extends State<CreateEditTreatmentScreen2> {
  List<Procedure> procedures = [];
  bool isLoading = true;
  List<Map<String, dynamic>> selectedProcedures = [];
  bool nextIconSelectable = false;

  @override
  void initState() {
    super.initState();
    devtools.log(
        'Welcome to initState of CreateEditTreatmentScreen2. originalProcedures are ${widget.originalProcedures}');
    devtools.log('@@@@@@ treatmentData is ${widget.treatmentData}');

    _fetchProcedures();

    if (widget.isEditMode && widget.treatmentData != null) {
      final proceduresData =
          widget.treatmentData!['procedures'] as List<dynamic>;
      final procedureCache = context.read<ProcedureCacheProvider>();
      proceduresData.forEach((data) {
        procedureCache.addProcedure({
          'procId': data['procId'],
          'procName': data['procName'],
          'affectedTeeth': data['affectedTeeth'],
          'isToothwise': data['isToothwise'],
          'doctorNote': data['doctorNote'],
        });
      });
      _updateNextIconState();
    }
  }

  Future<void> _fetchProcedures() async {
    try {
      ProcedureService procedureService = ProcedureService(widget.clinicId);
      List<Procedure> fetchedProcedures =
          await procedureService.searchProcedures('');

      // Sort procedures alphabetically by procName
      fetchedProcedures.sort((a, b) => a.procName.compareTo(b.procName));

      setState(() {
        procedures = fetchedProcedures;
        isLoading = false;
      });
    } catch (error) {
      devtools.log('Error fetching procedures: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  //--------------------------------------------------------------------//
  void _showAddProcedureOverlay({Map<String, dynamic>? procedure, int? index}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddProcedureOverlay(
          procedures: procedures,
          initialProcedure: procedure, // Pass the procedure for editing
          onProcedureAdded: (Map<String, dynamic> updatedProcedure) {
            updatedProcedure['isToothwise'] = procedures
                .firstWhere((p) => p.procId == updatedProcedure['procId'])
                .isToothwise; // Include isToothwise field

            // If editing an existing procedure, update it in cache
            if (index != null) {
              context
                  .read<ProcedureCacheProvider>()
                  .updateProcedure(index, updatedProcedure);
            } else {
              // If adding a new procedure, add it to cache
              context
                  .read<ProcedureCacheProvider>()
                  .addProcedure(updatedProcedure);
            }

            _updateNextIconState();
          },
        );
      },
    );
  }

  //--------------------------------------------------------------------//

  void _updateNextIconState() {
    setState(() {
      final procedureCache = context.read<ProcedureCacheProvider>();
      nextIconSelectable = procedureCache.selectedProcedures.isNotEmpty;
    });
  }

  void updateUserData() {
    final procedureCache = context.read<ProcedureCacheProvider>();
    final selectedProcedures = procedureCache.selectedProcedures;

    // Lists to store data for backend operations
    List<Map<String, dynamic>> deletedProceduresData = [];
    List<Map<String, dynamic>> selectedProceduresData = [];
    devtools.log(
        '**************************** Welcome to updateUserData *******************');

    devtools.log('@@@@@ Original Procedures: ${widget.originalProcedures}');
    devtools.log('@@@@@ Selected Procedures: $selectedProcedures');

    // Identify procedures to remove and keep track of them
    final originalProcIds = widget.originalProcedures?.toSet() ?? {};
    final selectedProcIds = selectedProcedures.map((p) => p['procId']).toSet();
    final proceduresToRemove = originalProcIds.difference(selectedProcIds);

    devtools.log('Procedures to Remove: $proceduresToRemove');

    // Handle procedures to remove
    for (var procId in proceduresToRemove) {
      final originalProcedureData = widget.userData.procedures.firstWhere(
        (userProcedure) => userProcedure['procId'] == procId,
        orElse: () => <String, dynamic>{},
      );

      if (originalProcedureData.isNotEmpty) {
        deletedProceduresData.add(originalProcedureData);
        devtools.log('Procedure to delete: $originalProcedureData');
      }

      // Remove the procedure from userData
      widget.userData.procedures
          .removeWhere((userProcedure) => userProcedure['procId'] == procId);
    }

    // Handle added or re-selected procedures
    for (var procedure in selectedProcedures) {
      if (!procedure.containsKey('isToothwise')) {
        devtools.log(
            'Warning: isToothwise missing in procedure ${procedure['procName']}');
        procedure['isToothwise'] =
            false; // Set a default value or handle appropriately
      }

      // Check if it's a re-selection with different details
      final bool isReSelectedWithChanges = originalProcIds
              .contains(procedure['procId']) &&
          widget.userData.procedures.any((userProcedure) =>
              userProcedure['procId'] == procedure['procId'] &&
              (userProcedure['affectedTeeth'] != procedure['affectedTeeth'] ||
                  userProcedure['doctorNote'] != procedure['doctorNote']));

      if (isReSelectedWithChanges) {
        // Mark the original for deletion
        final originalProcedureData = widget.userData.procedures.firstWhere(
          (userProcedure) => userProcedure['procId'] == procedure['procId'],
          orElse: () => <String, dynamic>{},
        );
        if (originalProcedureData.isNotEmpty) {
          deletedProceduresData.add(originalProcedureData);
          devtools.log(
              'Original procedure marked for deletion due to re-selection with changes: $originalProcedureData');
        }

        // Remove the original from userData
        widget.userData.procedures.removeWhere(
            (userProcedure) => userProcedure['procId'] == procedure['procId']);
      }

      // Treat re-selected procedures as new additions
      widget.userData.addOrUpdateProcedure(procedure);
      selectedProceduresData.add(procedure);
      devtools.log('Added Procedure: ${procedure['procId']}');
    }

    // Update userData with the final lists
    widget.userData.deletedProcedures = deletedProceduresData;
    widget.userData.selectedProcedures = selectedProceduresData
        .map((procedure) => procedure['procId'] as String)
        .toList();

    devtools.log('Final Selected Procedures: $selectedProceduresData');
    devtools.log('Final Deleted Procedures: $deletedProceduresData');
    devtools
        .log('Updated Procedures in UserData: ${widget.userData.procedures}');
  }

  // ----------------------------------------------------------------------- //

  Widget _buildPatientInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, top: 24, bottom: 24),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: MyColors.colorPalette['outline'] ?? Colors.blueAccent,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: MyColors.colorPalette['surface'],
                  backgroundImage: widget.patientPicUrl != null &&
                          widget.patientPicUrl!.isNotEmpty
                      ? NetworkImage(widget.patientPicUrl!)
                      : Image.asset(
                          'assets/images/default-image.png',
                          color: MyColors.colorPalette['primary'],
                          colorBlendMode: BlendMode.color,
                        ).image,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patientName,
                        style: MyTextStyle.textStyleMap['label-medium']
                            ?.copyWith(
                                color: MyColors.colorPalette['on-surface']),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.age.toString(),
                            style: MyTextStyle.textStyleMap['label-small']
                                ?.copyWith(
                                    color: MyColors
                                        .colorPalette['on-surface-variant']),
                          ),
                          Text(
                            '/',
                            style: MyTextStyle.textStyleMap['label-small']
                                ?.copyWith(
                                    color: MyColors
                                        .colorPalette['on-surface-variant']),
                          ),
                          Text(
                            widget.gender,
                            style: MyTextStyle.textStyleMap['label-small']
                                ?.copyWith(
                                    color: MyColors
                                        .colorPalette['on-surface-variant']),
                          ),
                        ],
                      ),
                      Text(
                        widget.patientMobileNumber,
                        style: MyTextStyle.textStyleMap['label-small']
                            ?.copyWith(
                                color: MyColors
                                    .colorPalette['on-surface-variant']),
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

  //------------------------------------------------------------------------//
  Widget _buildProcedureCards() {
    final procedureCache = context.watch<ProcedureCacheProvider>();
    final selectedProcedures = procedureCache.selectedProcedures;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedProcedures.isNotEmpty)
          ...selectedProcedures.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> procedure = entry.value;

            // Check if there are affected teeth and if there's a doctor note
            bool hasAffectedTeeth = procedure['affectedTeeth'] != null &&
                (procedure['affectedTeeth'] as List<dynamic>).isNotEmpty;
            bool hasDoctorNote = procedure['doctorNote'] != null &&
                procedure['doctorNote'].trim().isNotEmpty;

            return GestureDetector(
              onTap: () {
                // When card is tapped, open overlay for editing
                _showAddProcedureOverlay(
                  procedure: procedure, // Pass the procedure for editing
                  index: index, // Pass the index to update it later
                );
              },
              child: Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      side: BorderSide(
                                          color:
                                              MyColors.colorPalette['primary']!,
                                          width: 1.0),
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  // Card tap opens the edit overlay now
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${index + 1}. ${procedure['procName']}',
                                      style: MyTextStyle
                                          .textStyleMap['label-large']
                                          ?.copyWith(
                                        color: MyColors.colorPalette['primary'],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: MyColors.colorPalette['primary'],
                                ),
                                onPressed: () {
                                  procedureCache
                                      .removeProcedure(procedure['procId']);
                                  _updateNextIconState();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (hasAffectedTeeth) ...[
                          const Text('Affected Teeth'),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              double chipWidth = constraints.maxWidth / 8 - 4;
                              final List<int> affectedTeeth =
                                  (procedure['affectedTeeth'] as List<dynamic>?)
                                          ?.map((item) => item as int)
                                          .toList() ??
                                      [];

                              return Wrap(
                                spacing: 4.0,
                                runSpacing: 4.0,
                                children: affectedTeeth.map((tooth) {
                                  return SizedBox(
                                    width: chipWidth,
                                    child: Chip(
                                      label: Text(
                                        '$tooth',
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0,
                                        vertical: 0.0,
                                      ),
                                      backgroundColor:
                                          MyColors.colorPalette['primary'],
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (hasDoctorNote) ...[
                          const Text('Doctor Note'),
                          Text(
                            procedure['doctorNote'] ?? '',
                            style: MyTextStyle.textStyleMap['label-large']
                                ?.copyWith(
                                    color: MyColors.colorPalette['on-surface']),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  //------------------------------------------------------------------------//

  Widget _buildAddProcedureButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  MyColors.colorPalette['on-primary']!),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  side: BorderSide(
                      color: MyColors.colorPalette['primary']!, width: 1.0),
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
            ),
            onPressed: _showAddProcedureOverlay,
            child: Row(
              mainAxisSize: MainAxisSize
                  .min, // Ensures the button size matches its content
              children: [
                Icon(
                  Icons.add,
                  color: MyColors.colorPalette['primary'],
                ),
                const SizedBox(width: 4),
                Text(
                  'Add Procedure',
                  style: MyTextStyle.textStyleMap['label-large']
                      ?.copyWith(color: MyColors.colorPalette['primary']),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    devtools.log(
        'Welcome to build widget of CreateEditTreatmentScreen2. userData is ${widget.userData}');
    devtools.log(
        'This is coming from inside build widget of CreateEditTreatmentScreen2. originalProcedures are ${widget.originalProcedures}');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          widget.isEditMode ? 'Edit Procedure' : 'New Procedure',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        iconTheme: IconThemeData(
          color: MyColors.colorPalette['on-surface'],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPatientInfo(),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Procedure(s)',
                  style: MyTextStyle.textStyleMap['title-large']
                      ?.copyWith(color: MyColors.colorPalette['on-surface']),
                ),
              ),
            ),
            _buildProcedureCards(),
            _buildAddProcedureButton(),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<ProcedureCacheProvider>(
        builder: (context, procedureCache, child) {
          return MyBottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.circle),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.circle),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.circle),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.circle),
                label: '',
              ),
            ],
            currentIndex: 1,
            //nextIconSelectable: procedureCache.selectedProcedures.isNotEmpty,
            nextIconSelectable: true,
            onTap: (int navIndex) {
              if (navIndex == 0) {
                Navigator.of(context).pop();
              } else if (navIndex == 3) {
                // } else if (navIndex == 3 &&
                //     procedureCache.selectedProcedures.isNotEmpty) {
                updateUserData();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateEditTreatmentScreen3(
                      clinicId: widget.clinicId,
                      doctorId: widget.doctorId,
                      patientId: widget.patientId,
                      age: widget.age,
                      gender: widget.gender,
                      patientName: widget.patientName,
                      patientMobileNumber: widget.patientMobileNumber,
                      patientPicUrl: widget.patientPicUrl,
                      pageController: widget.pageController,
                      userData: widget.userData,
                      doctorName: widget.doctorName,
                      uhid: widget.uhid,
                      treatmentData: widget.treatmentData,
                      treatmentId: widget.treatmentId,
                      originalProcedures: widget.originalProcedures,
                      imageCacheProvider: widget.imageCacheProvider,
                      isEditMode: widget.isEditMode,
                      currentProcedures: procedureCache.selectedProcedures,
                      chiefComplaint: widget.chiefComplaint,
                    ),
                    settings:
                        const RouteSettings(name: 'CreateEditTreatmentScreen3'),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
