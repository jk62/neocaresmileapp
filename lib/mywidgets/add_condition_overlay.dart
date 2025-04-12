import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/examination_service.dart';
import 'package:neocaresmileapp/mywidgets/condition.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;

class AddConditionOverlay extends StatefulWidget {
  //final List<Condition> conditions;
  final Function(Map<String, dynamic>) onConditionAdded;
  final Map<String, dynamic>? initialCondition;
  final ExaminationService examinationService;

  const AddConditionOverlay({
    super.key,
    //required this.conditions,
    required this.onConditionAdded,
    required this.examinationService,
    this.initialCondition,
  });

  @override
  State<AddConditionOverlay> createState() => _AddConditionOverlayState();
}

class _AddConditionOverlayState extends State<AddConditionOverlay> {
  Condition? selectedCondition;
  List<int> affectedTeeth = [];
  bool showToothTable = false;
  bool toothSelectionConfirmed = false;
  TextEditingController doctorNoteController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool showConditionList = false;

  List<Condition> filteredConditions = [];
  FocusNode searchFocusNode = FocusNode();

  // @override
  // void initState() {
  //   super.initState();
  //   widget.conditions
  //       .sort((a, b) => a.conditionName.compareTo(b.conditionName));
  //   filteredConditions = widget.conditions;
  //   searchController.addListener(_filterConditions);

  //   //---------------------//
  //   // If editing, prepopulate with the passed condition data
  //   if (widget.initialCondition != null) {
  //     selectedCondition = widget.conditions.firstWhere(
  //       (condition) =>
  //           condition.conditionId == widget.initialCondition!['conditionId'],
  //     );
  //     affectedTeeth = List<int>.from(widget.initialCondition!['affectedTeeth']);
  //     doctorNoteController.text = widget.initialCondition!['doctorNote'] ?? '';
  //     showToothTable = selectedCondition!.isToothTable;
  //   }

  //   //---------------------//
  // }

  // void _filterConditions() {
  //   setState(() {
  //     final query = searchController.text.toLowerCase();
  //     if (query.isEmpty) {
  //       filteredConditions = widget.conditions;
  //     } else {
  //       filteredConditions = widget.conditions
  //           .where((condition) =>
  //               condition.conditionName.toLowerCase().startsWith(query))
  //           .toList();
  //     }
  //   });
  // }
  //-----------------------------------------------------------//
  @override
  void initState() {
    super.initState();
    _loadConditions(); // Fetch conditions for the selected clinic
    searchController.addListener(_filterConditions);

    if (widget.initialCondition != null) {
      _populateInitialCondition();
    }
  }

  Future<void> _loadConditions() async {
    try {
      final allConditions = await widget.examinationService.getAllConditions();
      setState(() {
        filteredConditions = allConditions;
        filteredConditions
            .sort((a, b) => a.conditionName.compareTo(b.conditionName));
      });
    } catch (e) {
      devtools.log('Failed to load conditions: $e');
    }
  }

  void _populateInitialCondition() {
    final initialConditionId = widget.initialCondition!['conditionId'];
    selectedCondition = filteredConditions.firstWhere(
      (condition) => condition.conditionId == initialConditionId,
      orElse: () => Condition(
        conditionId: '', // Provide a default empty ID
        conditionName: '', // Provide a default empty name
        toothTable1: [],
        toothTable2: [],
        toothTable3: [],
        toothTable4: [],
        doctorNote: '',
        isToothTable: false,
      ),
    );

    if (selectedCondition != null &&
        selectedCondition!.conditionId.isNotEmpty) {
      affectedTeeth = List<int>.from(widget.initialCondition!['affectedTeeth']);
      doctorNoteController.text = widget.initialCondition!['doctorNote'] ?? '';
      showToothTable = selectedCondition!.isToothTable;
    } else {
      selectedCondition = null;
    }
  }

  void _filterConditions() {
    setState(() {
      final query = searchController.text.toLowerCase();
      if (query.isEmpty) {
        filteredConditions = filteredConditions;
      } else {
        filteredConditions = filteredConditions
            .where((condition) =>
                condition.conditionName.toLowerCase().startsWith(query))
            .toList();
      }
    });
  }
  //-----------------------------------------------------------//

  void _resetSelection() {
    setState(() {
      selectedCondition = null;
      affectedTeeth.clear();
      showToothTable = false;
      searchController.clear();
      searchFocusNode.unfocus();
      showConditionList = false;
    });
  }

  void selectCondition(Condition condition) {
    setState(() {
      selectedCondition = condition;
      searchController.text = condition.conditionName;
      filteredConditions = [];
      showToothTable = condition.isToothTable;
      showConditionList = false;
      //searchFocusNode.requestFocus();
      searchFocusNode.unfocus();
    });
  }

  void toggleToothSelection(int toothNumber) {
    setState(() {
      if (affectedTeeth.contains(toothNumber)) {
        affectedTeeth.remove(toothNumber);
      } else {
        affectedTeeth.add(toothNumber);
      }
    });
  }

  void confirmToothSelection() {
    setState(() {
      showToothTable = false;
      toothSelectionConfirmed = true;
    });
  }

  void closeOverlay({bool saveCondition = false}) {
    if (saveCondition && selectedCondition != null) {
      widget.onConditionAdded({
        'conditionId': selectedCondition!.conditionId,
        'conditionName': selectedCondition!.conditionName,
        'affectedTeeth': affectedTeeth,
        'doctorNote': doctorNoteController.text,
      });
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterConditions);
    searchController.dispose();
    doctorNoteController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void toggleConditionList() {
    setState(() {
      showConditionList = !showConditionList;
      if (showConditionList) {
        FocusScope.of(context).requestFocus(searchFocusNode);
      } else {
        _resetSelection();
      }
    });
  }

  Widget buildToothTable() {
    if (!showToothTable || selectedCondition == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Top row containing first and second quadrants
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: MyColors.colorPalette['on-surface'] ?? Colors.grey,
                width: 2.0,
              ),
            ),
          ),
          child: Row(
            children: [
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color:
                            MyColors.colorPalette['on-surface'] ?? Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: selectedCondition!.toothTable1.length,
                    itemBuilder: (context, index) {
                      int toothNumber = selectedCondition!.toothTable1[index];
                      bool isSelected = affectedTeeth.contains(toothNumber);

                      return GestureDetector(
                        onTap: () => toggleToothSelection(toothNumber),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MyColors.colorPalette['primary']
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? MyColors.colorPalette['primary'] ??
                                      Colors.blueAccent
                                  : MyColors.colorPalette['on-surface'] ??
                                      Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              '$toothNumber',
                              style: MyTextStyle.textStyleMap['label-medium']
                                  ?.copyWith(
                                color: isSelected
                                    ? MyColors.colorPalette['on-primary']
                                    : MyColors.colorPalette['on-surface'],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color:
                            MyColors.colorPalette['on-surface'] ?? Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: selectedCondition!.toothTable2.length,
                    itemBuilder: (context, index) {
                      int toothNumber = selectedCondition!.toothTable2[index];
                      bool isSelected = affectedTeeth.contains(toothNumber);

                      return GestureDetector(
                        onTap: () => toggleToothSelection(toothNumber),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MyColors.colorPalette['primary']
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? MyColors.colorPalette['primary'] ??
                                      Colors.blueAccent
                                  : MyColors.colorPalette['on-surface'] ??
                                      Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              '$toothNumber',
                              style: MyTextStyle.textStyleMap['label-medium']
                                  ?.copyWith(
                                color: isSelected
                                    ? MyColors.colorPalette['on-primary']
                                    : MyColors.colorPalette['on-surface'],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom row containing third and fourth quadrants
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: MyColors.colorPalette['on-surface'] ?? Colors.grey,
                width: 2.0,
              ),
            ),
          ),
          child: Row(
            children: [
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color:
                            MyColors.colorPalette['on-surface'] ?? Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: selectedCondition!.toothTable3.length,
                    itemBuilder: (context, index) {
                      int toothNumber = selectedCondition!.toothTable3[index];
                      bool isSelected = affectedTeeth.contains(toothNumber);

                      return GestureDetector(
                        onTap: () => toggleToothSelection(toothNumber),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MyColors.colorPalette['primary']
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? MyColors.colorPalette['primary'] ??
                                      Colors.blueAccent
                                  : MyColors.colorPalette['on-surface'] ??
                                      Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              '$toothNumber',
                              style: MyTextStyle.textStyleMap['label-medium']
                                  ?.copyWith(
                                color: isSelected
                                    ? MyColors.colorPalette['on-primary']
                                    : MyColors.colorPalette['on-surface'],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color:
                            MyColors.colorPalette['on-surface'] ?? Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: selectedCondition!.toothTable4.length,
                    itemBuilder: (context, index) {
                      int toothNumber = selectedCondition!.toothTable4[index];
                      bool isSelected = affectedTeeth.contains(toothNumber);

                      return GestureDetector(
                        onTap: () => toggleToothSelection(toothNumber),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MyColors.colorPalette['primary']
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? MyColors.colorPalette['primary'] ??
                                      Colors.blueAccent
                                  : MyColors.colorPalette['on-surface'] ??
                                      Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              '$toothNumber',
                              style: MyTextStyle.textStyleMap['label-medium']
                                  ?.copyWith(
                                color: isSelected
                                    ? MyColors.colorPalette['on-primary']
                                    : MyColors.colorPalette['on-surface'],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------- //

  // -------------------------------------------------------------------- //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: IconButton(
            icon: Icon(
              Icons.close,
              size: 24.0,
              color: MyColors.colorPalette['on-surface'],
            ),
            onPressed: () => closeOverlay(saveCondition: false),
          ),
        ),
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color:
                            MyColors.colorPalette['on-surface'] ?? Colors.grey,
                      ),
                      suffixIcon: searchController.text.isNotEmpty ||
                              searchFocusNode.hasFocus
                          ? IconButton(
                              icon: Icon(
                                Icons.close,
                                color: MyColors.colorPalette['on-surface'] ??
                                    Colors.grey,
                              ),
                              onPressed: _resetSelection,
                            )
                          : null,
                      labelText: 'Search Condition',
                      //------------------------------//

                      floatingLabelStyle:
                          MyTextStyle.textStyleMap['label-medium']?.copyWith(
                        color: MyColors.colorPalette['on-surface'],
                      ),
                      //------------------------------//
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: MyColors.colorPalette['on-surface'] ??
                              Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      //---------------------------------//
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: MyColors.colorPalette['on-surface'] ??
                              Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      //----------------------------------//
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 16.0),
                    ),
                    onTap: () {
                      if (!showConditionList) {
                        toggleConditionList();
                      }

                      // Reset the condition and hide the tooth table, doctor note, and buttons
                      setState(() {
                        selectedCondition = null;
                        affectedTeeth.clear();
                        showToothTable = false;
                        toothSelectionConfirmed = false;
                        doctorNoteController.clear();
                      });
                    },
                  ),

                  const SizedBox(
                      height: 0.0), // Remove space between search bar and list
                  if (showConditionList)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: MyColors.colorPalette['on-surface'] ??
                              Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8.0),
                        ),
                      ),
                      constraints: const BoxConstraints(
                        maxHeight: 508.0, // Adjust as needed
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredConditions.length,
                        itemBuilder: (context, index) {
                          Condition condition = filteredConditions[index];
                          return ListTile(
                            title: Text(
                              condition.conditionName,
                              style: MyTextStyle.textStyleMap['title-medium']
                                  ?.copyWith(
                                color: MyColors.colorPalette['on-surface'],
                              ),
                            ),
                            onTap: () => selectCondition(condition),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            if (selectedCondition != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedCondition!.isToothTable) ...[
                              Text(
                                'Mark Affected Teeth',
                                style: MyTextStyle.textStyleMap['title-medium']
                                    ?.copyWith(
                                        color:
                                            MyColors.colorPalette['secondary']),
                              ),
                              const SizedBox(height: 8),
                              buildToothTable(),
                              const SizedBox(height: 16),
                            ],
                            // ---------------------------------------------- //

                            // ---------------------------------------------- //
                            const SizedBox(height: 16),
                            Text(
                              'Add Note',
                              style: MyTextStyle.textStyleMap['title-medium']
                                  ?.copyWith(
                                      color:
                                          MyColors.colorPalette['secondary']),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: MyColors.colorPalette['on-surface'] ??
                                      const Color(0xFF011718),
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: TextFormField(
                                controller: doctorNoteController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16.0),
                                ),
                                maxLines: null,
                                style: MyTextStyle.textStyleMap['label-large']
                                    ?.copyWith(
                                        color:
                                            MyColors.colorPalette['secondary']),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 48,
                                    width: 144,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(MyColors
                                                .colorPalette['primary']!),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            side: BorderSide(
                                              color: MyColors
                                                  .colorPalette['primary']!,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        confirmToothSelection();
                                        closeOverlay(saveCondition: true);
                                      },
                                      child: Text(
                                        'Add',
                                        style: MyTextStyle
                                            .textStyleMap['label-large']
                                            ?.copyWith(
                                                color: MyColors.colorPalette[
                                                    'on-primary']),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/condition.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class AddConditionOverlay extends StatefulWidget {
//   final List<Condition> conditions;
//   final Function(Map<String, dynamic>) onConditionAdded;
//   final Map<String, dynamic>? initialCondition;

//   const AddConditionOverlay({
//     super.key,
//     required this.conditions,
//     required this.onConditionAdded,
//     this.initialCondition,
//   });

//   @override
//   State<AddConditionOverlay> createState() => _AddConditionOverlayState();
// }

// class _AddConditionOverlayState extends State<AddConditionOverlay> {
//   Condition? selectedCondition;
//   List<int> affectedTeeth = [];
//   bool showToothTable = false;
//   bool toothSelectionConfirmed = false;
//   TextEditingController doctorNoteController = TextEditingController();
//   TextEditingController searchController = TextEditingController();
//   bool showConditionList = false;

//   List<Condition> filteredConditions = [];
//   FocusNode searchFocusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     widget.conditions
//         .sort((a, b) => a.conditionName.compareTo(b.conditionName));
//     filteredConditions = widget.conditions;
//     searchController.addListener(_filterConditions);

//     //---------------------//
//     // If editing, prepopulate with the passed condition data
//     if (widget.initialCondition != null) {
//       selectedCondition = widget.conditions.firstWhere(
//         (condition) =>
//             condition.conditionId == widget.initialCondition!['conditionId'],
//       );
//       affectedTeeth = List<int>.from(widget.initialCondition!['affectedTeeth']);
//       doctorNoteController.text = widget.initialCondition!['doctorNote'] ?? '';
//       showToothTable = selectedCondition!.isToothTable;
//     }

//     //---------------------//
//   }

//   void _filterConditions() {
//     setState(() {
//       final query = searchController.text.toLowerCase();
//       if (query.isEmpty) {
//         filteredConditions = widget.conditions;
//       } else {
//         filteredConditions = widget.conditions
//             .where((condition) =>
//                 condition.conditionName.toLowerCase().startsWith(query))
//             .toList();
//       }
//     });
//   }

//   void _resetSelection() {
//     setState(() {
//       selectedCondition = null;
//       affectedTeeth.clear();
//       showToothTable = false;
//       searchController.clear();
//       searchFocusNode.unfocus();
//       showConditionList = false;
//     });
//   }

//   void selectCondition(Condition condition) {
//     setState(() {
//       selectedCondition = condition;
//       searchController.text = condition.conditionName;
//       filteredConditions = [];
//       showToothTable = condition.isToothTable;
//       showConditionList = false;
//       //searchFocusNode.requestFocus();
//       searchFocusNode.unfocus();
//     });
//   }

//   void toggleToothSelection(int toothNumber) {
//     setState(() {
//       if (affectedTeeth.contains(toothNumber)) {
//         affectedTeeth.remove(toothNumber);
//       } else {
//         affectedTeeth.add(toothNumber);
//       }
//     });
//   }

//   void confirmToothSelection() {
//     setState(() {
//       showToothTable = false;
//       toothSelectionConfirmed = true;
//     });
//   }

//   void closeOverlay({bool saveCondition = false}) {
//     if (saveCondition && selectedCondition != null) {
//       widget.onConditionAdded({
//         'conditionId': selectedCondition!.conditionId,
//         'conditionName': selectedCondition!.conditionName,
//         'affectedTeeth': affectedTeeth,
//         'doctorNote': doctorNoteController.text,
//       });
//     }

//     Navigator.pop(context);
//   }

//   @override
//   void dispose() {
//     searchController.removeListener(_filterConditions);
//     searchController.dispose();
//     doctorNoteController.dispose();
//     searchFocusNode.dispose();
//     super.dispose();
//   }

//   void toggleConditionList() {
//     setState(() {
//       showConditionList = !showConditionList;
//       if (showConditionList) {
//         FocusScope.of(context).requestFocus(searchFocusNode);
//       } else {
//         _resetSelection();
//       }
//     });
//   }

//   Widget buildToothTable() {
//     if (!showToothTable || selectedCondition == null) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       children: [
//         // Top row containing first and second quadrants
//         Container(
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                 width: 2.0,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               Flexible(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       right: BorderSide(
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                         width: 1.0,
//                       ),
//                     ),
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: selectedCondition!.toothTable1.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = selectedCondition!.toothTable1[index];
//                       bool isSelected = affectedTeeth.contains(toothNumber);

//                       return GestureDetector(
//                         onTap: () => toggleToothSelection(toothNumber),
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? MyColors.colorPalette['primary']
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: isSelected
//                                   ? MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent
//                                   : MyColors.colorPalette['on-surface'] ??
//                                       Colors.grey,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$toothNumber',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                 color: isSelected
//                                     ? MyColors.colorPalette['on-primary']
//                                     : MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               Flexible(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       left: BorderSide(
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                         width: 1.0,
//                       ),
//                     ),
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: selectedCondition!.toothTable2.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = selectedCondition!.toothTable2[index];
//                       bool isSelected = affectedTeeth.contains(toothNumber);

//                       return GestureDetector(
//                         onTap: () => toggleToothSelection(toothNumber),
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? MyColors.colorPalette['primary']
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: isSelected
//                                   ? MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent
//                                   : MyColors.colorPalette['on-surface'] ??
//                                       Colors.grey,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$toothNumber',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                 color: isSelected
//                                     ? MyColors.colorPalette['on-primary']
//                                     : MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // Bottom row containing third and fourth quadrants
//         Container(
//           decoration: BoxDecoration(
//             border: Border(
//               top: BorderSide(
//                 color: MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                 width: 2.0,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               Flexible(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       right: BorderSide(
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                         width: 1.0,
//                       ),
//                     ),
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: selectedCondition!.toothTable3.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = selectedCondition!.toothTable3[index];
//                       bool isSelected = affectedTeeth.contains(toothNumber);

//                       return GestureDetector(
//                         onTap: () => toggleToothSelection(toothNumber),
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? MyColors.colorPalette['primary']
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: isSelected
//                                   ? MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent
//                                   : MyColors.colorPalette['on-surface'] ??
//                                       Colors.grey,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$toothNumber',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                 color: isSelected
//                                     ? MyColors.colorPalette['on-primary']
//                                     : MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               Flexible(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       left: BorderSide(
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                         width: 1.0,
//                       ),
//                     ),
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: selectedCondition!.toothTable4.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = selectedCondition!.toothTable4[index];
//                       bool isSelected = affectedTeeth.contains(toothNumber);

//                       return GestureDetector(
//                         onTap: () => toggleToothSelection(toothNumber),
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? MyColors.colorPalette['primary']
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: isSelected
//                                   ? MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent
//                                   : MyColors.colorPalette['on-surface'] ??
//                                       Colors.grey,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$toothNumber',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                 color: isSelected
//                                     ? MyColors.colorPalette['on-primary']
//                                     : MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // --------------------------------------------------------------------- //

//   // -------------------------------------------------------------------- //

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: Padding(
//           padding: const EdgeInsets.only(top: 24.0),
//           child: IconButton(
//             icon: Icon(
//               Icons.close,
//               size: 24.0,
//               color: MyColors.colorPalette['on-surface'],
//             ),
//             onPressed: () => closeOverlay(saveCondition: false),
//           ),
//         ),
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         elevation: 1,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 16.0),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextField(
//                     controller: searchController,
//                     focusNode: searchFocusNode,
//                     decoration: InputDecoration(
//                       prefixIcon: Icon(
//                         Icons.search,
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                       ),
//                       suffixIcon: searchController.text.isNotEmpty ||
//                               searchFocusNode.hasFocus
//                           ? IconButton(
//                               icon: Icon(
//                                 Icons.close,
//                                 color: MyColors.colorPalette['on-surface'] ??
//                                     Colors.grey,
//                               ),
//                               onPressed: _resetSelection,
//                             )
//                           : null,
//                       labelText: 'Search Condition',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                         borderSide: BorderSide(
//                           color: MyColors.colorPalette['on-surface'] ??
//                               Colors.grey,
//                           width: 1.0,
//                         ),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 8.0, vertical: 16.0),
//                     ),
//                     onTap: () {
//                       if (!showConditionList) {
//                         toggleConditionList();
//                       }

//                       // Reset the condition and hide the tooth table, doctor note, and buttons
//                       setState(() {
//                         selectedCondition = null;
//                         affectedTeeth.clear();
//                         showToothTable = false;
//                         toothSelectionConfirmed = false;
//                         doctorNoteController.clear();
//                       });
//                     },
//                   ),

//                   const SizedBox(
//                       height: 0.0), // Remove space between search bar and list
//                   if (showConditionList)
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: MyColors.colorPalette['on-surface'] ??
//                               Colors.grey,
//                           width: 1.0,
//                         ),
//                         borderRadius: const BorderRadius.vertical(
//                           bottom: Radius.circular(8.0),
//                         ),
//                       ),
//                       constraints: const BoxConstraints(
//                         maxHeight: 508.0, // Adjust as needed
//                       ),
//                       child: ListView.builder(
//                         padding: const EdgeInsets.only(bottom: 16.0),
//                         shrinkWrap: true,
//                         physics: const BouncingScrollPhysics(),
//                         itemCount: filteredConditions.length,
//                         itemBuilder: (context, index) {
//                           Condition condition = filteredConditions[index];
//                           return ListTile(
//                             title: Text(
//                               condition.conditionName,
//                               style: MyTextStyle.textStyleMap['title-medium']
//                                   ?.copyWith(
//                                 color: MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                             onTap: () => selectCondition(condition),
//                           );
//                         },
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             if (selectedCondition != null)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Card(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (selectedCondition!.isToothTable) ...[
//                               Text(
//                                 'Mark Affected Teeth',
//                                 style: MyTextStyle.textStyleMap['title-medium']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary']),
//                               ),
//                               const SizedBox(height: 8),
//                               buildToothTable(),
//                               const SizedBox(height: 16),
//                             ],
//                             // ---------------------------------------------- //

//                             // ---------------------------------------------- //
//                             const SizedBox(height: 16),
//                             Text(
//                               'Add Note',
//                               style: MyTextStyle.textStyleMap['title-medium']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['secondary']),
//                             ),
//                             const SizedBox(height: 8),
//                             Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   width: 1,
//                                   color: MyColors.colorPalette['on-surface'] ??
//                                       const Color(0xFF011718),
//                                 ),
//                                 borderRadius: BorderRadius.circular(5.0),
//                               ),
//                               child: TextFormField(
//                                 controller: doctorNoteController,
//                                 decoration: const InputDecoration(
//                                   border: InputBorder.none,
//                                   contentPadding: EdgeInsets.all(16.0),
//                                 ),
//                                 maxLines: null,
//                                 style: MyTextStyle.textStyleMap['label-large']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary']),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Row(
//                                 children: [
//                                   SizedBox(
//                                     height: 48,
//                                     width: 144,
//                                     child: ElevatedButton(
//                                       style: ButtonStyle(
//                                         backgroundColor:
//                                             MaterialStateProperty.all(MyColors
//                                                 .colorPalette['primary']!),
//                                         shape: MaterialStateProperty.all(
//                                           RoundedRectangleBorder(
//                                             side: BorderSide(
//                                               color: MyColors
//                                                   .colorPalette['primary']!,
//                                               width: 1.0,
//                                             ),
//                                             borderRadius:
//                                                 BorderRadius.circular(24.0),
//                                           ),
//                                         ),
//                                       ),
//                                       onPressed: () {
//                                         confirmToothSelection();
//                                         closeOverlay(saveCondition: true);
//                                       },
//                                       child: Text(
//                                         'Add',
//                                         style: MyTextStyle
//                                             .textStyleMap['label-large']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on-primary']),
//                                       ),
//                                     ),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                     },
//                                     child: const Text('Cancel'),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW STABLE WITH NON-EDITABLE CONDITION CARD
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/condition.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class AddConditionOverlay extends StatefulWidget {
//   final List<Condition> conditions;
//   final Function(Map<String, dynamic>) onConditionAdded;
//   

//   const AddConditionOverlay({
//     super.key,
//     required this.conditions,
//     required this.onConditionAdded,
//     
//   });

//   @override
//   State<AddConditionOverlay> createState() => _AddConditionOverlayState();
// }

// class _AddConditionOverlayState extends State<AddConditionOverlay> {
//   Condition? selectedCondition;
//   List<int> affectedTeeth = [];
//   bool showToothTable = false;
//   bool toothSelectionConfirmed = false;
//   TextEditingController doctorNoteController = TextEditingController();
//   TextEditingController searchController = TextEditingController();
//   bool showConditionList = false;

//   List<Condition> filteredConditions = [];
//   FocusNode searchFocusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     widget.conditions
//         .sort((a, b) => a.conditionName.compareTo(b.conditionName));
//     filteredConditions = widget.conditions;
//     searchController.addListener(_filterConditions);
//   }

//   void _filterConditions() {
//     setState(() {
//       final query = searchController.text.toLowerCase();
//       if (query.isEmpty) {
//         filteredConditions = widget.conditions;
//       } else {
//         filteredConditions = widget.conditions
//             .where((condition) =>
//                 condition.conditionName.toLowerCase().startsWith(query))
//             .toList();
//       }
//     });
//   }

//   void _resetSelection() {
//     setState(() {
//       selectedCondition = null;
//       affectedTeeth.clear();
//       showToothTable = false;
//       searchController.clear();
//       searchFocusNode.unfocus();
//       showConditionList = false;
//     });
//   }

//   void selectCondition(Condition condition) {
//     setState(() {
//       selectedCondition = condition;
//       searchController.text = condition.conditionName;
//       filteredConditions = [];
//       showToothTable = condition.isToothTable;
//       showConditionList = false;
//       //searchFocusNode.requestFocus();
//       searchFocusNode.unfocus();
//     });
//   }

//   void toggleToothSelection(int toothNumber) {
//     setState(() {
//       if (affectedTeeth.contains(toothNumber)) {
//         affectedTeeth.remove(toothNumber);
//       } else {
//         affectedTeeth.add(toothNumber);
//       }
//     });
//   }

//   void confirmToothSelection() {
//     setState(() {
//       showToothTable = false;
//       toothSelectionConfirmed = true;
//     });
//   }

//   void closeOverlay({bool saveCondition = false}) {
//     if (saveCondition && selectedCondition != null) {
//       widget.onConditionAdded({
//         'conditionId': selectedCondition!.conditionId,
//         'conditionName': selectedCondition!.conditionName,
//         'affectedTeeth': affectedTeeth,
//         'doctorNote': doctorNoteController.text,
//       });
//     }

//     Navigator.pop(context);
//   }

//   @override
//   void dispose() {
//     searchController.removeListener(_filterConditions);
//     searchController.dispose();
//     doctorNoteController.dispose();
//     searchFocusNode.dispose();
//     super.dispose();
//   }

//   void toggleConditionList() {
//     setState(() {
//       showConditionList = !showConditionList;
//       if (showConditionList) {
//         FocusScope.of(context).requestFocus(searchFocusNode);
//       } else {
//         _resetSelection();
//       }
//     });
//   }

//   Widget buildToothTable() {
//     if (!showToothTable || selectedCondition == null) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       children: [
//         // Top row containing first and second quadrants
//         Container(
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                 width: 2.0,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               Flexible(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       right: BorderSide(
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                         width: 1.0,
//                       ),
//                     ),
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: selectedCondition!.toothTable1.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = selectedCondition!.toothTable1[index];
//                       bool isSelected = affectedTeeth.contains(toothNumber);

//                       return GestureDetector(
//                         onTap: () => toggleToothSelection(toothNumber),
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? MyColors.colorPalette['primary']
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: isSelected
//                                   ? MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent
//                                   : MyColors.colorPalette['on-surface'] ??
//                                       Colors.grey,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$toothNumber',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                 color: isSelected
//                                     ? MyColors.colorPalette['on-primary']
//                                     : MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               Flexible(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       left: BorderSide(
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                         width: 1.0,
//                       ),
//                     ),
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: selectedCondition!.toothTable2.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = selectedCondition!.toothTable2[index];
//                       bool isSelected = affectedTeeth.contains(toothNumber);

//                       return GestureDetector(
//                         onTap: () => toggleToothSelection(toothNumber),
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? MyColors.colorPalette['primary']
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: isSelected
//                                   ? MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent
//                                   : MyColors.colorPalette['on-surface'] ??
//                                       Colors.grey,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$toothNumber',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                 color: isSelected
//                                     ? MyColors.colorPalette['on-primary']
//                                     : MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // Bottom row containing third and fourth quadrants
//         Container(
//           decoration: BoxDecoration(
//             border: Border(
//               top: BorderSide(
//                 color: MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                 width: 2.0,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               Flexible(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       right: BorderSide(
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                         width: 1.0,
//                       ),
//                     ),
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: selectedCondition!.toothTable3.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = selectedCondition!.toothTable3[index];
//                       bool isSelected = affectedTeeth.contains(toothNumber);

//                       return GestureDetector(
//                         onTap: () => toggleToothSelection(toothNumber),
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? MyColors.colorPalette['primary']
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: isSelected
//                                   ? MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent
//                                   : MyColors.colorPalette['on-surface'] ??
//                                       Colors.grey,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$toothNumber',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                 color: isSelected
//                                     ? MyColors.colorPalette['on-primary']
//                                     : MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               Flexible(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       left: BorderSide(
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                         width: 1.0,
//                       ),
//                     ),
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: selectedCondition!.toothTable4.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = selectedCondition!.toothTable4[index];
//                       bool isSelected = affectedTeeth.contains(toothNumber);

//                       return GestureDetector(
//                         onTap: () => toggleToothSelection(toothNumber),
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? MyColors.colorPalette['primary']
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: isSelected
//                                   ? MyColors.colorPalette['primary'] ??
//                                       Colors.blueAccent
//                                   : MyColors.colorPalette['on-surface'] ??
//                                       Colors.grey,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$toothNumber',
//                               style: MyTextStyle.textStyleMap['label-medium']
//                                   ?.copyWith(
//                                 color: isSelected
//                                     ? MyColors.colorPalette['on-primary']
//                                     : MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // --------------------------------------------------------------------- //

//   // -------------------------------------------------------------------- //

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: Padding(
//           padding: const EdgeInsets.only(top: 24.0),
//           child: IconButton(
//             icon: Icon(
//               Icons.close,
//               size: 24.0,
//               color: MyColors.colorPalette['on-surface'],
//             ),
//             onPressed: () => closeOverlay(saveCondition: false),
//           ),
//         ),
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         elevation: 1,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 16.0),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextField(
//                     controller: searchController,
//                     focusNode: searchFocusNode,
//                     decoration: InputDecoration(
//                       prefixIcon: Icon(
//                         Icons.search,
//                         color:
//                             MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                       ),
//                       suffixIcon: searchController.text.isNotEmpty ||
//                               searchFocusNode.hasFocus
//                           ? IconButton(
//                               icon: Icon(
//                                 Icons.close,
//                                 color: MyColors.colorPalette['on-surface'] ??
//                                     Colors.grey,
//                               ),
//                               onPressed: _resetSelection,
//                             )
//                           : null,
//                       labelText: 'Search Condition',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                         borderSide: BorderSide(
//                           color: MyColors.colorPalette['on-surface'] ??
//                               Colors.grey,
//                           width: 1.0,
//                         ),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 8.0, vertical: 16.0),
//                     ),
//                     onTap: () {
//                       if (!showConditionList) {
//                         toggleConditionList();
//                       }

//                       // Reset the condition and hide the tooth table, doctor note, and buttons
//                       setState(() {
//                         selectedCondition = null;
//                         affectedTeeth.clear();
//                         showToothTable = false;
//                         toothSelectionConfirmed = false;
//                         doctorNoteController.clear();
//                       });
//                     },
//                   ),

//                   const SizedBox(
//                       height: 0.0), // Remove space between search bar and list
//                   if (showConditionList)
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: MyColors.colorPalette['on-surface'] ??
//                               Colors.grey,
//                           width: 1.0,
//                         ),
//                         borderRadius: const BorderRadius.vertical(
//                           bottom: Radius.circular(8.0),
//                         ),
//                       ),
//                       constraints: const BoxConstraints(
//                         maxHeight: 508.0, // Adjust as needed
//                       ),
//                       child: ListView.builder(
//                         padding: const EdgeInsets.only(bottom: 16.0),
//                         shrinkWrap: true,
//                         physics: const BouncingScrollPhysics(),
//                         itemCount: filteredConditions.length,
//                         itemBuilder: (context, index) {
//                           Condition condition = filteredConditions[index];
//                           return ListTile(
//                             title: Text(
//                               condition.conditionName,
//                               style: MyTextStyle.textStyleMap['title-medium']
//                                   ?.copyWith(
//                                 color: MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                             onTap: () => selectCondition(condition),
//                           );
//                         },
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             if (selectedCondition != null)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Card(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (selectedCondition!.isToothTable) ...[
//                               Text(
//                                 'Mark Affected Teeth',
//                                 style: MyTextStyle.textStyleMap['title-medium']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary']),
//                               ),
//                               const SizedBox(height: 8),
//                               buildToothTable(),
//                               const SizedBox(height: 16),
//                             ],
//                             // ---------------------------------------------- //

//                             // ---------------------------------------------- //
//                             const SizedBox(height: 16),
//                             Text(
//                               'Add Note',
//                               style: MyTextStyle.textStyleMap['title-medium']
//                                   ?.copyWith(
//                                       color:
//                                           MyColors.colorPalette['secondary']),
//                             ),
//                             const SizedBox(height: 8),
//                             Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   width: 1,
//                                   color: MyColors.colorPalette['on-surface'] ??
//                                       const Color(0xFF011718),
//                                 ),
//                                 borderRadius: BorderRadius.circular(5.0),
//                               ),
//                               child: TextFormField(
//                                 controller: doctorNoteController,
//                                 decoration: const InputDecoration(
//                                   border: InputBorder.none,
//                                   contentPadding: EdgeInsets.all(16.0),
//                                 ),
//                                 maxLines: null,
//                                 style: MyTextStyle.textStyleMap['label-large']
//                                     ?.copyWith(
//                                         color:
//                                             MyColors.colorPalette['secondary']),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Row(
//                                 children: [
//                                   SizedBox(
//                                     height: 48,
//                                     width: 144,
//                                     child: ElevatedButton(
//                                       style: ButtonStyle(
//                                         backgroundColor:
//                                             MaterialStateProperty.all(MyColors
//                                                 .colorPalette['primary']!),
//                                         shape: MaterialStateProperty.all(
//                                           RoundedRectangleBorder(
//                                             side: BorderSide(
//                                               color: MyColors
//                                                   .colorPalette['primary']!,
//                                               width: 1.0,
//                                             ),
//                                             borderRadius:
//                                                 BorderRadius.circular(24.0),
//                                           ),
//                                         ),
//                                       ),
//                                       onPressed: () {
//                                         confirmToothSelection();
//                                         closeOverlay(saveCondition: true);
//                                       },
//                                       child: Text(
//                                         'Add',
//                                         style: MyTextStyle
//                                             .textStyleMap['label-large']
//                                             ?.copyWith(
//                                                 color: MyColors.colorPalette[
//                                                     'on-primary']),
//                                       ),
//                                     ),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                     },
//                                     child: const Text('Cancel'),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
