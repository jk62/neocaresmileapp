import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/procedure.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

class AddProcedureOverlay extends StatefulWidget {
  final List<Procedure> procedures;
  final Function(Map<String, dynamic>) onProcedureAdded;
  final Map<String, dynamic>? initialProcedure;

  const AddProcedureOverlay({
    super.key,
    required this.procedures,
    required this.onProcedureAdded,
    this.initialProcedure,
  });

  @override
  State<AddProcedureOverlay> createState() => _AddProcedureOverlayState();
}

class _AddProcedureOverlayState extends State<AddProcedureOverlay> {
  Procedure? selectedProcedure;
  List<int> affectedTeeth = [];
  bool showToothTable = false;
  bool toothSelectionConfirmed = false;
  TextEditingController doctorNoteController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool showProcedureList = false;

  List<Procedure> filteredProcedures = [];

  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.procedures.sort((a, b) => a.procName.compareTo(b.procName));
    filteredProcedures = widget.procedures;
    searchController.addListener(_filterProcedures);

    // Prepopulate the fields if an initial procedure is provided
    if (widget.initialProcedure != null) {
      selectedProcedure = widget.procedures.firstWhere(
        (proc) => proc.procId == widget.initialProcedure!['procId'],
      );
      affectedTeeth = List<int>.from(widget.initialProcedure!['affectedTeeth']);
      doctorNoteController.text = widget.initialProcedure!['doctorNote'] ?? '';
      showToothTable = selectedProcedure!.isToothwise;
    }

    //-----------------//
    // if (widget.initialCondition != null) {
    //   selectedCondition = widget.conditions.firstWhere(
    //     (condition) =>
    //         condition.conditionId == widget.initialCondition!['conditionId'],
    //   );
    //   affectedTeeth = List<int>.from(widget.initialCondition!['affectedTeeth']);
    //   doctorNoteController.text = widget.initialCondition!['doctorNote'] ?? '';
    //   showToothTable = selectedCondition!.isToothTable;
    // }
    //-----------------//
  }

  void _filterProcedures() {
    setState(() {
      final query = searchController.text.toLowerCase();
      if (query.isEmpty) {
        filteredProcedures = widget.procedures;
      } else {
        filteredProcedures = widget.procedures
            .where((procedure) =>
                procedure.procName.toLowerCase().startsWith(query))
            .toList();
      }
    });
  }

  void _resetSelection() {
    setState(() {
      selectedProcedure = null;
      affectedTeeth.clear();
      showToothTable = false;
      doctorNoteController.clear();
      searchController.clear();
      searchFocusNode.unfocus();
      showProcedureList = false;
    });
  }

  // void selectProcedure(Procedure procedure) {
  //   setState(() {
  //     selectedProcedure = procedure;
  //     searchController.text = procedure.procName;
  //     filteredProcedures = [];
  //     showToothTable = procedure.isToothwise;
  //     showProcedureList = false;
  //     searchFocusNode.requestFocus();
  //   });
  // }
  void selectProcedure(Procedure procedure) {
    setState(() {
      selectedProcedure = procedure;
      searchController.text = procedure.procName;
      filteredProcedures = [];
      showToothTable = procedure.isToothwise;
      showProcedureList = false;
      searchFocusNode
          .unfocus(); // Unfocus the search bar to stop the blinking cursor
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

  void closeOverlay({bool saveProcedure = false}) {
    if (saveProcedure && selectedProcedure != null) {
      widget.onProcedureAdded({
        'procId': selectedProcedure!.procId,
        'procName': selectedProcedure!.procName,
        'affectedTeeth': affectedTeeth,
        'doctorNote': doctorNoteController.text,
      });
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterProcedures);
    searchController.dispose();
    doctorNoteController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void toggleProcedureList() {
    setState(() {
      showProcedureList = !showProcedureList;
      if (showProcedureList) {
        FocusScope.of(context).requestFocus(searchFocusNode);
      } else {
        _resetSelection();
      }
    });
  }

  Widget buildToothTable() {
    if (!showToothTable || selectedProcedure == null) {
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
                    itemCount: selectedProcedure!.toothTable1.length,
                    itemBuilder: (context, index) {
                      int toothNumber = selectedProcedure!.toothTable1[index];
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
                    itemCount: selectedProcedure!.toothTable2.length,
                    itemBuilder: (context, index) {
                      int toothNumber = selectedProcedure!.toothTable2[index];
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
                    itemCount: selectedProcedure!.toothTable3.length,
                    itemBuilder: (context, index) {
                      int toothNumber = selectedProcedure!.toothTable3[index];
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
                    itemCount: selectedProcedure!.toothTable4.length,
                    itemBuilder: (context, index) {
                      int toothNumber = selectedProcedure!.toothTable4[index];
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
            onPressed: () => closeOverlay(saveProcedure: false),
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
                      labelText: 'Search Procedure',
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
                      if (!showProcedureList) {
                        toggleProcedureList();
                      }

                      // Reset the procedure and hide the tooth table, doctor note, and buttons
                      setState(() {
                        selectedProcedure = null;
                        affectedTeeth.clear();
                        showToothTable = false;
                        toothSelectionConfirmed = false;
                        doctorNoteController.clear();
                      });
                    },
                  ),

                  const SizedBox(
                      height: 0.0), // Remove space between search bar and list
                  if (showProcedureList)
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
                        maxHeight: 480.0, // Adjust as needed
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredProcedures.length,
                        itemBuilder: (context, index) {
                          Procedure procedure = filteredProcedures[index];
                          return ListTile(
                            title: Text(
                              procedure.procName,
                              style: MyTextStyle.textStyleMap['title-medium']
                                  ?.copyWith(
                                color: MyColors.colorPalette['on-surface'],
                              ),
                            ),
                            onTap: () => selectProcedure(procedure),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            if (selectedProcedure != null)
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
                            if (selectedProcedure!.isToothwise) ...[
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
                                        closeOverlay(saveProcedure: true);
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
                                    onPressed: () =>
                                        closeOverlay(saveProcedure: false),
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

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// CODE BELOW IS STABLE WITH NON-EDITABLE PROCEDURE CARD
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/mywidgets/procedure.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';

// class AddProcedureOverlay extends StatefulWidget {
//   final List<Procedure> procedures;
//   final Function(Map<String, dynamic>) onProcedureAdded;

//   const AddProcedureOverlay({
//     super.key,
//     required this.procedures,
//     required this.onProcedureAdded,
//   });

//   @override
//   State<AddProcedureOverlay> createState() => _AddProcedureOverlayState();
// }

// class _AddProcedureOverlayState extends State<AddProcedureOverlay> {
//   Procedure? selectedProcedure;
//   List<int> affectedTeeth = [];
//   bool showToothTable = false;
//   bool toothSelectionConfirmed = false;
//   TextEditingController doctorNoteController = TextEditingController();
//   TextEditingController searchController = TextEditingController();
//   bool showProcedureList = false;

//   List<Procedure> filteredProcedures = [];

//   FocusNode searchFocusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     widget.procedures.sort((a, b) => a.procName.compareTo(b.procName));
//     filteredProcedures = widget.procedures;
//     searchController.addListener(_filterProcedures);
//   }

//   void _filterProcedures() {
//     setState(() {
//       final query = searchController.text.toLowerCase();
//       if (query.isEmpty) {
//         filteredProcedures = widget.procedures;
//       } else {
//         filteredProcedures = widget.procedures
//             .where((procedure) =>
//                 procedure.procName.toLowerCase().startsWith(query))
//             .toList();
//       }
//     });
//   }

//   void _resetSelection() {
//     setState(() {
//       selectedProcedure = null;
//       affectedTeeth.clear();
//       showToothTable = false;
//       doctorNoteController.clear();
//       searchController.clear();
//       searchFocusNode.unfocus();
//       showProcedureList = false;
//     });
//   }

//   // void selectProcedure(Procedure procedure) {
//   //   setState(() {
//   //     selectedProcedure = procedure;
//   //     searchController.text = procedure.procName;
//   //     filteredProcedures = [];
//   //     showToothTable = procedure.isToothwise;
//   //     showProcedureList = false;
//   //     searchFocusNode.requestFocus();
//   //   });
//   // }
//   void selectProcedure(Procedure procedure) {
//     setState(() {
//       selectedProcedure = procedure;
//       searchController.text = procedure.procName;
//       filteredProcedures = [];
//       showToothTable = procedure.isToothwise;
//       showProcedureList = false;
//       searchFocusNode
//           .unfocus(); // Unfocus the search bar to stop the blinking cursor
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

//   void closeOverlay({bool saveProcedure = false}) {
//     if (saveProcedure && selectedProcedure != null) {
//       widget.onProcedureAdded({
//         'procId': selectedProcedure!.procId,
//         'procName': selectedProcedure!.procName,
//         'affectedTeeth': affectedTeeth,
//         'doctorNote': doctorNoteController.text,
//       });
//     }

//     Navigator.pop(context);
//   }

//   @override
//   void dispose() {
//     searchController.removeListener(_filterProcedures);
//     searchController.dispose();
//     doctorNoteController.dispose();
//     searchFocusNode.dispose();
//     super.dispose();
//   }

//   void toggleProcedureList() {
//     setState(() {
//       showProcedureList = !showProcedureList;
//       if (showProcedureList) {
//         FocusScope.of(context).requestFocus(searchFocusNode);
//       } else {
//         _resetSelection();
//       }
//     });
//   }

//   Widget buildToothTable() {
//     if (!showToothTable || selectedProcedure == null) {
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
//                     itemCount: selectedProcedure!.toothTable1.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = selectedProcedure!.toothTable1[index];
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
//                     itemCount: selectedProcedure!.toothTable2.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = selectedProcedure!.toothTable2[index];
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
//                     itemCount: selectedProcedure!.toothTable3.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = selectedProcedure!.toothTable3[index];
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
//                     itemCount: selectedProcedure!.toothTable4.length,
//                     itemBuilder: (context, index) {
//                       int toothNumber = selectedProcedure!.toothTable4[index];
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
//             onPressed: () => closeOverlay(saveProcedure: false),
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
//                   // TextField(
//                   //   controller: searchController,
//                   //   focusNode: searchFocusNode,
//                   //   decoration: InputDecoration(
//                   //     prefixIcon: Icon(
//                   //       Icons.search,
//                   //       color:
//                   //           MyColors.colorPalette['on-surface'] ?? Colors.grey,
//                   //     ),
//                   //     suffixIcon: searchController.text.isNotEmpty ||
//                   //             selectedProcedure != null
//                   //         ? IconButton(
//                   //             icon: Icon(
//                   //               Icons.close,
//                   //               color: MyColors.colorPalette['on-surface'] ??
//                   //                   Colors.grey,
//                   //             ),
//                   //             onPressed: _resetSelection,
//                   //           )
//                   //         : null,
//                   //     labelText: 'Search Procedure',
//                   //     border: OutlineInputBorder(
//                   //       borderRadius: BorderRadius.circular(8.0),
//                   //       borderSide: BorderSide(
//                   //         color: MyColors.colorPalette['on-surface'] ??
//                   //             Colors.grey,
//                   //         width: 1.0,
//                   //       ),
//                   //     ),
//                   //     contentPadding: const EdgeInsets.symmetric(
//                   //         horizontal: 8.0, vertical: 16.0),
//                   //   ),
//                   //   onTap: () {
//                   //     if (!showProcedureList) {
//                   //       toggleProcedureList();
//                   //     }
//                   //   },
//                   // ),
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
//                       labelText: 'Search Procedure',
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
//                       if (!showProcedureList) {
//                         toggleProcedureList();
//                       }

//                       // Reset the procedure and hide the tooth table, doctor note, and buttons
//                       setState(() {
//                         selectedProcedure = null;
//                         affectedTeeth.clear();
//                         showToothTable = false;
//                         toothSelectionConfirmed = false;
//                         doctorNoteController.clear();
//                       });
//                     },
//                   ),

//                   const SizedBox(
//                       height: 0.0), // Remove space between search bar and list
//                   if (showProcedureList)
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
//                       constraints: BoxConstraints(
//                         maxHeight: 480.0, // Adjust as needed
//                       ),
//                       child: ListView.builder(
//                         padding: const EdgeInsets.only(bottom: 16.0),
//                         shrinkWrap: true,
//                         physics: const BouncingScrollPhysics(),
//                         itemCount: filteredProcedures.length,
//                         itemBuilder: (context, index) {
//                           Procedure procedure = filteredProcedures[index];
//                           return ListTile(
//                             title: Text(
//                               procedure.procName,
//                               style: MyTextStyle.textStyleMap['title-medium']
//                                   ?.copyWith(
//                                 color: MyColors.colorPalette['on-surface'],
//                               ),
//                             ),
//                             onTap: () => selectProcedure(procedure),
//                           );
//                         },
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             if (selectedProcedure != null)
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
//                             if (selectedProcedure!.isToothwise) ...[
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
//                                         closeOverlay(saveProcedure: true);
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
//                                     onPressed: () =>
//                                         closeOverlay(saveProcedure: false),
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
