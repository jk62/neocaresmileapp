// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/procedure_service.dart';
// import 'package:neocare_dental_app/mywidgets/add_procedure.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/procedure.dart';
// import 'dart:developer' as devtools show log;

// class ProcedureManagementScreen extends StatefulWidget {
//   final String clinicId;

//   const ProcedureManagementScreen({Key? key, required this.clinicId})
//       : super(key: key);

//   @override
//   State<ProcedureManagementScreen> createState() =>
//       _ProcedureManagementScreenState();
// }

// class _ProcedureManagementScreenState extends State<ProcedureManagementScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _searchController = TextEditingController();

//   late ProcedureService _procedureService;
//   List<Procedure> _matchingProcedures = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _procedureService = ProcedureService(widget.clinicId);
//     _fetchProcedures();
//   }

//   Future<void> _fetchProcedures() async {
//     setState(() {
//       _isLoading = true;
//     });
//     _matchingProcedures = await _procedureService.getProcedures();
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   void _handleSearchInput(String input) async {
//     if (input.isEmpty) {
//       _fetchProcedures();
//     } else {
//       _matchingProcedures = await _procedureService.searchProcedures(input);
//       setState(() {});
//     }
//   }

//   Future<void> _addOrEditProcedure({Procedure? procedure}) async {
//     bool result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddProcedure(
//           clinicId: widget.clinicId,
//           procedureService: _procedureService,
//           procedure: procedure,
//         ),
//       ),
//     );

//     if (result == true) {
//       _fetchProcedures();
//     }
//   }

//   void _deleteProcedure(Procedure procedure) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete Procedure'),
//         content: Text('Are you sure you want to delete ${procedure.procName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               await _procedureService.deleteProcedure(procedure.procId);
//               Navigator.pop(context);
//               _fetchProcedures();
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Manage Procedures',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//           color: MyColors.colorPalette['on-surface'],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: TextField(
//                   controller: _searchController,
//                   onChanged: _handleSearchInput,
//                   decoration: InputDecoration(
//                     labelText: 'Search Procedure',
//                     labelStyle: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(
//                             color: MyColors.colorPalette['on-surface-variant']),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(8.0)),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['primary'] ?? Colors.black,
//                       ),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(8.0)),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['on-surface-variant'] ??
//                             Colors.black,
//                       ),
//                     ),
//                     contentPadding: const EdgeInsets.only(left: 8.0),
//                   ),
//                 ),
//               ),
//               if (_isLoading)
//                 const Center(child: CircularProgressIndicator())
//               else
//                 ..._matchingProcedures.map(
//                   (procedure) => Card(
//                     child: ListTile(
//                       title: Text(procedure.procName),
//                       subtitle: Text(
//                           'Fee: \$${procedure.procFee.toStringAsFixed(2)}'),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.edit),
//                         onPressed: () =>
//                             _addOrEditProcedure(procedure: procedure),
//                       ),
//                       onLongPress: () => _deleteProcedure(procedure),
//                     ),
//                   ),
//                 ),
//               ElevatedButton(
//                 onPressed: () => _addOrEditProcedure(),
//                 child: const Text('Add New Procedure'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/procedure_service.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'procedure.dart';
// import 'dart:developer' as devtools show log;

// class ProcedureManagementScreen extends StatefulWidget {
//   final String clinicId;

//   const ProcedureManagementScreen({
//     super.key,
//     required this.clinicId,
//   });

//   @override
//   State<ProcedureManagementScreen> createState() =>
//       _ProcedureManagementScreenState();
// }

// class _ProcedureManagementScreenState extends State<ProcedureManagementScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _feeController = TextEditingController();

//   late ProcedureService _procedureService;
//   List<Procedure> _matchingProcedures = [];
//   bool _isAddingProcedure = false;
//   bool _isEditingProcedure = false;
//   Procedure? _currentProcedure;

//   @override
//   void initState() {
//     super.initState();
//     _procedureService = ProcedureService(widget.clinicId);
//     _fetchProcedures();
//   }

//   Future<void> _fetchProcedures() async {
//     _matchingProcedures = await _procedureService.getProcedures();
//     setState(() {});
//   }

//   void _handleSearchInput(String input) async {
//     if (input.isEmpty) {
//       _fetchProcedures();
//     } else {
//       _matchingProcedures = await _procedureService.searchProcedures(input);
//       setState(() {});
//     }
//   }

//   void _addOrEditProcedure() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isAddingProcedure = true;
//     });

//     try {
//       if (_isEditingProcedure && _currentProcedure != null) {
//         Procedure updatedProcedure = Procedure(
//           procId: _currentProcedure!.procId,
//           procName: _nameController.text,
//           procFee: double.parse(_feeController.text),
//         );
//         await _procedureService.updateProcedure(updatedProcedure);
//       } else {
//         Procedure newProcedure = Procedure(
//           procId: '',
//           procName: _nameController.text,
//           procFee: double.parse(_feeController.text),
//         );
//         await _procedureService.addProcedure(newProcedure);
//       }

//       _nameController.clear();
//       _feeController.clear();
//       _isEditingProcedure = false;
//       _currentProcedure = null;
//       _fetchProcedures();
//     } catch (error) {
//       devtools.log('Error adding or updating procedure: $error');
//     } finally {
//       setState(() {
//         _isAddingProcedure = false;
//       });
//     }
//   }

//   void _editProcedure(Procedure procedure) {
//     setState(() {
//       _isEditingProcedure = true;
//       _currentProcedure = procedure;
//       _nameController.text = procedure.procName;
//       _feeController.text = procedure.procFee.toString();
//     });
//   }

//   void _deleteProcedure(Procedure procedure) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete Procedure'),
//         content: Text('Are you sure you want to delete ${procedure.procName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               await _procedureService.deleteProcedure(procedure.procId);
//               Navigator.pop(context);
//               _fetchProcedures();
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: MyColors.colorPalette['surface-container-lowest'],
//         title: Text(
//           'Manage Procedures',
//           style: MyTextStyle.textStyleMap['title-large']
//               ?.copyWith(color: MyColors.colorPalette['on-surface']),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//           color: MyColors.colorPalette['on-surface'],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: TextField(
//                   controller: _searchController,
//                   onChanged: _handleSearchInput,
//                   decoration: InputDecoration(
//                     labelText: 'Search Procedure',
//                     labelStyle: MyTextStyle.textStyleMap['label-large']
//                         ?.copyWith(
//                             color: MyColors.colorPalette['on-surface-variant']),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(8.0)),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['primary'] ?? Colors.black,
//                       ),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(8.0)),
//                       borderSide: BorderSide(
//                           color: MyColors.colorPalette['on-surface-variant'] ??
//                               Colors.black),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 8.0, horizontal: 8.0),
//                   ),
//                 ),
//               ),
//               ..._matchingProcedures.map((procedure) {
//                 return Card(
//                   child: ListTile(
//                     title: Text(
//                       procedure.procName,
//                       style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                           color: MyColors.colorPalette['on_surface']),
//                     ),
//                     subtitle: Text(
//                       'Fee: ${procedure.procFee}',
//                       style: MyTextStyle.textStyleMap['label-small']?.copyWith(
//                           color: MyColors.colorPalette['on_surface']),
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           onPressed: () => _editProcedure(procedure),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () => _deleteProcedure(procedure),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//               if (_isAddingProcedure) const CircularProgressIndicator(),
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: TextFormField(
//                         controller: _nameController,
//                         decoration: InputDecoration(
//                           labelText: 'Procedure Name',
//                           labelStyle: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on-surface-variant']),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(8.0)),
//                             borderSide: BorderSide(
//                               color: MyColors.colorPalette['primary'] ??
//                                   Colors.black,
//                             ),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(8.0)),
//                             borderSide: BorderSide(
//                               color:
//                                   MyColors.colorPalette['on-surface-variant'] ??
//                                       Colors.black,
//                             ),
//                           ),
//                           contentPadding: const EdgeInsets.only(left: 8.0),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter procedure name';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: TextFormField(
//                         controller: _feeController,
//                         decoration: InputDecoration(
//                           labelText: 'Procedure Fee',
//                           labelStyle: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on-surface-variant']),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(8.0)),
//                             borderSide: BorderSide(
//                               color: MyColors.colorPalette['primary'] ??
//                                   Colors.black,
//                             ),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(8.0)),
//                             borderSide: BorderSide(
//                               color:
//                                   MyColors.colorPalette['on-surface-variant'] ??
//                                       Colors.black,
//                             ),
//                           ),
//                           contentPadding: const EdgeInsets.only(left: 8.0),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter procedure fee';
//                           }
//                           if (double.tryParse(value) == null) {
//                             return 'Please enter a valid fee';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: ElevatedButton(
//                         onPressed: _addOrEditProcedure,
//                         child: Text(_isEditingProcedure ? 'Update' : 'Add'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
