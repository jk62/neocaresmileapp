import 'dart:async';
import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/patient.dart';
import 'package:neocaresmileapp/mywidgets/recent_patient.dart';
import 'package:neocaresmileapp/mywidgets/recent_patient_provider.dart';
import 'package:neocaresmileapp/mywidgets/treatment_landing_screen.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

class SearchAndDisplayAllPatients extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String doctorName;

  const SearchAndDisplayAllPatients({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<SearchAndDisplayAllPatients> createState() =>
      _SearchAndDisplayAllPatientsState();
}

class _SearchAndDisplayAllPatientsState
    extends State<SearchAndDisplayAllPatients> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Patient>>? _patientsStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStream();
    });
  }

  void _initializeStream() {
    final recentPatientProvider =
        Provider.of<RecentPatientProvider>(context, listen: false);
    setState(() {
      _patientsStream = recentPatientProvider.getAllPatientsRealTime();
    });
  }

  void _handleSearchInput(String query) {
    final recentPatientProvider =
        Provider.of<RecentPatientProvider>(context, listen: false);

    setState(() {
      _patientsStream = query.isNotEmpty
          ? recentPatientProvider.searchPatientsRealTime(query)
          : recentPatientProvider.getAllPatientsRealTime();
    });
  }

  // Widget _buildPatientsList(List<Patient> patients) {
  //   patients.sort((a, b) => a.patientName.compareTo(b.patientName));

  //   List<Widget> widgets = [];
  //   String currentAlphabet = '';

  //   for (final patient in patients) {
  //     final patientFirstChar = patient.patientName.isNotEmpty
  //         ? patient.patientName[0].toUpperCase()
  //         : '';

  //     if (patientFirstChar != currentAlphabet) {
  //       widgets.add(
  //         Padding(
  //           padding: const EdgeInsets.only(left: 16.0),
  //           child: Align(
  //             alignment: Alignment.centerLeft,
  //             child: Text(
  //               patientFirstChar,
  //               style: MyTextStyle.textStyleMap['headline-large']?.copyWith(
  //                   color: MyColors.colorPalette['on-surface-variant']),
  //             ),
  //           ),
  //         ),
  //       );
  //       currentAlphabet = patientFirstChar;
  //     }

  //     widgets.add(
  //       GestureDetector(
  //         onTap: () => _navigateToTreatment(patient),
  //         child: Card(
  //           child: ListTile(
  //             leading: CircleAvatar(
  //               backgroundColor: MyColors.colorPalette['surface'],
  //               backgroundImage: patient.patientPicUrl != null &&
  //                       patient.patientPicUrl!.isNotEmpty
  //                   ? NetworkImage(patient.patientPicUrl!)
  //                   : Image.asset(
  //                       'assets/images/default-image.png',
  //                       color: MyColors.colorPalette['secondary'],
  //                       colorBlendMode: BlendMode.color,
  //                     ).image,
  //             ),
  //             title: Text(
  //               patient.patientName,
  //               style: MyTextStyle.textStyleMap['label-medium']
  //                   ?.copyWith(color: MyColors.colorPalette['on-surface']),
  //             ),
  //             subtitle: Text(
  //               '${patient.age}, ${patient.gender}',
  //               style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
  //                   color: MyColors.colorPalette['on-surface-variant']),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   return Column(children: widgets);
  // }
  Widget _buildPatientsList(List<Patient> patients) {
    // Perform case-insensitive sorting
    patients.sort((a, b) =>
        a.patientName.toLowerCase().compareTo(b.patientName.toLowerCase()));

    List<Widget> widgets = [];
    String currentAlphabet = '';

    for (final patient in patients) {
      final patientFirstChar = patient.patientName.isNotEmpty
          ? patient.patientName[0].toUpperCase()
          : '';

      if (patientFirstChar != currentAlphabet) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                patientFirstChar,
                style: MyTextStyle.textStyleMap['headline-large']?.copyWith(
                    color: MyColors.colorPalette['on-surface-variant']),
              ),
            ),
          ),
        );
        currentAlphabet = patientFirstChar;
      }

      widgets.add(
        GestureDetector(
          onTap: () => _navigateToTreatment(patient),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: MyColors.colorPalette['surface'],
                backgroundImage: patient.patientPicUrl != null &&
                        patient.patientPicUrl!.isNotEmpty
                    ? NetworkImage(patient.patientPicUrl!)
                    : Image.asset(
                        'assets/images/default-image.png',
                        color: MyColors.colorPalette['secondary'],
                        colorBlendMode: BlendMode.color,
                      ).image,
              ),
              title: Text(
                patient.patientName,
                style: MyTextStyle.textStyleMap['label-medium']
                    ?.copyWith(color: MyColors.colorPalette['on-surface']),
              ),
              subtitle: Text(
                '${patient.age}, ${patient.gender}',
                style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
                    color: MyColors.colorPalette['on-surface-variant']),
              ),
            ),
          ),
        ),
      );
    }

    return Column(children: widgets);
  }

  void _navigateToTreatment(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreatmentLandingScreen(
          clinicId: widget.clinicId,
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
          patientId: patient.patientId,
          patientName: patient.patientName,
          patientMobileNumber: patient.patientMobileNumber,
          age: patient.age,
          gender: patient.gender,
          patientPicUrl: patient.patientPicUrl,
          uhid: patient.uhid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => _handleSearchInput(query),
              decoration: InputDecoration(
                labelText: 'Search Patient by Name or Phone',
                prefixIcon: Icon(Icons.search,
                    color: MyColors.colorPalette['on-surface-variant']),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: MyColors.colorPalette['primary'] ?? Colors.black,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: MyColors.colorPalette['on-surface-variant'] ??
                        Colors.black,
                  ),
                ),
              ),
            ),
          ),
          RecentPatient(
            clinicId: widget.clinicId,
            doctorId: widget.doctorId,
            doctorName: widget.doctorName,
            patientService: Provider.of<RecentPatientProvider>(context)
                .patientService, // Pass patientService from provider
            showViewMoreButton: false, // Hide "View More"
          ),
          Expanded(
            // child: StreamBuilder<List<Patient>>(
            //   stream: _patientsStream,
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const Center(child: CircularProgressIndicator());
            //     } else if (snapshot.hasError) {
            //       return Center(
            //         child: Text('Error: ${snapshot.error}'),
            //       );
            //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //       return Center(
            //         child: Text(
            //           'No patients found.',
            //           style: MyTextStyle.textStyleMap['label-large']
            //               ?.copyWith(color: MyColors.colorPalette['secondary']),
            //         ),
            //       );
            //     }
            //     return SingleChildScrollView(
            //       child: _buildPatientsList(snapshot.data!),
            //     );
            //   },
            // ),
            child: StreamBuilder<List<Patient>>(
              stream: _patientsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No patients found.',
                      style: MyTextStyle.textStyleMap['label-large']
                          ?.copyWith(color: MyColors.colorPalette['secondary']),
                    ),
                  );
                }

                // Enforce alphabetical sorting
                final sortedPatients = snapshot.data!
                  ..sort((a, b) {
                    final nameA = a.patientName.toLowerCase();
                    final nameB = b.patientName.toLowerCase();
                    return nameA.compareTo(nameB);
                  });

                return SingleChildScrollView(
                  child: _buildPatientsList(sortedPatients),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// code below stable before introducing recent patient section //
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/recent_patient_provider.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'package:provider/provider.dart';
// import 'dart:developer' as devtools show log;

// class SearchAndDisplayAllPatients extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;

//   const SearchAndDisplayAllPatients({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//   });

//   @override
//   State<SearchAndDisplayAllPatients> createState() =>
//       _SearchAndDisplayAllPatientsState();
// }

// class _SearchAndDisplayAllPatientsState
//     extends State<SearchAndDisplayAllPatients> {
//   final TextEditingController _searchController = TextEditingController();
//   Stream<List<Patient>>? _patientsStream;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeStream();
//     });
//   }

//   void _initializeStream() {
//     final recentPatientProvider =
//         Provider.of<RecentPatientProvider>(context, listen: false);
//     setState(() {
//       _patientsStream = recentPatientProvider.getAllPatientsRealTime();
//     });
//   }

//   void _handleSearchInput(String query) {
//     final recentPatientProvider =
//         Provider.of<RecentPatientProvider>(context, listen: false);

//     setState(() {
//       _patientsStream = query.isNotEmpty
//           ? recentPatientProvider.searchPatientsRealTime(query)
//           : recentPatientProvider.getAllPatientsRealTime();
//     });
//   }

//   Widget _buildPatientsList(List<Patient> patients) {
//     patients.sort((a, b) => a.patientName.compareTo(b.patientName));

//     List<Widget> widgets = [];
//     String currentAlphabet = '';

//     for (final patient in patients) {
//       final patientFirstChar = patient.patientName.isNotEmpty
//           ? patient.patientName[0].toUpperCase()
//           : '';

//       if (patientFirstChar != currentAlphabet) {
//         widgets.add(
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 patientFirstChar,
//                 style: MyTextStyle.textStyleMap['headline-large']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         );
//         currentAlphabet = patientFirstChar;
//       }

//       widgets.add(
//         GestureDetector(
//           onTap: () => _navigateToTreatment(patient),
//           child: Card(
//             child: ListTile(
//               leading: CircleAvatar(
//                 backgroundColor: MyColors.colorPalette['surface'],
//                 backgroundImage: patient.patientPicUrl != null &&
//                         patient.patientPicUrl!.isNotEmpty
//                     ? NetworkImage(patient.patientPicUrl!)
//                     : Image.asset(
//                         'assets/images/default-image.png',
//                         color: MyColors.colorPalette['secondary'],
//                         colorBlendMode: BlendMode.color,
//                       ).image,
//               ),
//               title: Text(
//                 patient.patientName,
//                 style: MyTextStyle.textStyleMap['label-medium']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//               subtitle: Text(
//                 '${patient.age}, ${patient.gender}',
//                 style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return Column(children: widgets);
//   }

//   void _navigateToTreatment(Patient patient) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TreatmentLandingScreen(
//           clinicId: widget.clinicId,
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           patientId: patient.patientId,
//           patientName: patient.patientName,
//           patientMobileNumber: patient.patientMobileNumber,
//           age: patient.age,
//           gender: patient.gender,
//           patientPicUrl: patient.patientPicUrl,
//           uhid: patient.uhid,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Consumer<RecentPatientProvider>(
//         builder: (context, recentPatientProvider, _) {
//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   controller: _searchController,
//                   onChanged: (query) => _handleSearchInput(query),
//                   decoration: InputDecoration(
//                     labelText: 'Search Patient by Name or Phone',
//                     prefixIcon: Icon(Icons.search,
//                         color: MyColors.colorPalette['on-surface-variant']),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['primary'] ?? Colors.black,
//                       ),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['on-surface-variant'] ??
//                             Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: StreamBuilder<List<Patient>>(
//                   stream: _patientsStream,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return Center(
//                         child: Text('Error: ${snapshot.error}'),
//                       );
//                     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       return Center(
//                         child: Text(
//                           'No patients found.',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                       );
//                     }
//                     return SingleChildScrollView(
//                       child: _buildPatientsList(snapshot.data!),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

// class _SearchAndDisplayAllPatientsState
//     extends State<SearchAndDisplayAllPatients> {
//   final TextEditingController _searchController = TextEditingController();
//   Stream<List<Patient>>? _patientsStream;
//   String? _clinicId;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeStream();
//     });
//   }

//   void _initializeStream() {
//     final appointmentProvider =
//         Provider.of<AppointmentProvider>(context, listen: false);

//     // Fetch clinicId
//     _clinicId = appointmentProvider.clinicId;

//     if (_clinicId == null || _clinicId!.isEmpty) {
//       devtools.log('Error: clinicId is empty during initialization.');
//       return;
//     }

//     devtools.log('Initializing patient stream for clinicId: $_clinicId');
//     setState(() {
//       _patientsStream = appointmentProvider.patientService
//           .getAllPatientsRealTime(clinicId: _clinicId!);
//     });
//   }

//   void _handleSearchInput(String query, PatientService patientService) {
//     if (_clinicId == null || _clinicId!.isEmpty) {
//       devtools.log('Error: clinicId is empty. Cannot search patients.');
//       return;
//     }

//     setState(() {
//       _patientsStream = query.isNotEmpty
//           ? patientService.searchPatientsRealTime(query, _clinicId!)
//           : patientService.getAllPatientsRealTime(clinicId: _clinicId!);
//     });
//   }

//   Widget _buildPatientsList(List<Patient> patients) {
//     patients.sort((a, b) => a.patientName.compareTo(b.patientName));

//     List<Widget> widgets = [];
//     String currentAlphabet = '';

//     for (final patient in patients) {
//       final patientFirstChar = patient.patientName.isNotEmpty
//           ? patient.patientName[0].toUpperCase()
//           : '';

//       if (patientFirstChar != currentAlphabet) {
//         widgets.add(
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 patientFirstChar,
//                 style: MyTextStyle.textStyleMap['headline-large']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         );
//         currentAlphabet = patientFirstChar;
//       }

//       widgets.add(
//         GestureDetector(
//           onTap: () => _navigateToTreatment(patient),
//           child: Card(
//             child: ListTile(
//               leading: CircleAvatar(
//                 backgroundColor: MyColors.colorPalette['surface'],
//                 backgroundImage: patient.patientPicUrl != null &&
//                         patient.patientPicUrl!.isNotEmpty
//                     ? NetworkImage(patient.patientPicUrl!)
//                     : Image.asset(
//                         'assets/images/default-image.png',
//                         color: MyColors.colorPalette['secondary'],
//                         colorBlendMode: BlendMode.color,
//                       ).image,
//               ),
//               title: Text(
//                 patient.patientName,
//                 style: MyTextStyle.textStyleMap['label-medium']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//               subtitle: Text(
//                 '${patient.age}, ${patient.gender}',
//                 style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return Column(children: widgets);
//   }

//   void _navigateToTreatment(Patient patient) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TreatmentLandingScreen(
//           clinicId: _clinicId ?? '',
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           patientId: patient.patientId,
//           patientName: patient.patientName,
//           patientMobileNumber: patient.patientMobileNumber,
//           age: patient.age,
//           gender: patient.gender,
//           patientPicUrl: patient.patientPicUrl,
//           uhid: patient.uhid,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Consumer<AppointmentProvider>(
//         builder: (context, appointmentProvider, _) {
//           final patientService = appointmentProvider.patientService;

//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   controller: _searchController,
//                   onChanged: (query) =>
//                       _handleSearchInput(query, patientService),
//                   decoration: InputDecoration(
//                     labelText: 'Search Patient by Name or Phone',
//                     prefixIcon: Icon(Icons.search,
//                         color: MyColors.colorPalette['on-surface-variant']),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['primary'] ?? Colors.black,
//                       ),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       borderSide: BorderSide(
//                         color: MyColors.colorPalette['on-surface-variant'] ??
//                             Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: StreamBuilder<List<Patient>>(
//                   stream: _patientsStream,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return Center(
//                         child: Text('Error: ${snapshot.error}'),
//                       );
//                     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       return Center(
//                         child: Text(
//                           'No patients found.',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors.colorPalette['secondary']),
//                         ),
//                       );
//                     }
//                     return SingleChildScrollView(
//                       child: _buildPatientsList(snapshot.data!),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ //
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/common_app_bar.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'package:provider/provider.dart';
// import 'dart:developer' as devtools show log;

// class SearchAndDisplayAllPatients extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;

//   const SearchAndDisplayAllPatients({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//   });

//   @override
//   State<SearchAndDisplayAllPatients> createState() =>
//       _SearchAndDisplayAllPatientsState();
// }

// class _SearchAndDisplayAllPatientsState
//     extends State<SearchAndDisplayAllPatients> {
//   final TextEditingController _searchController = TextEditingController();
//   late PatientService _patientService;
//   Stream<List<Patient>>? _patientsStream;
//   bool _isLoading = false;
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final appointmentProvider =
//           Provider.of<AppointmentProvider>(context, listen: false);

//       // Log clinicId from the provider
//       devtools.log(
//           'ClinicId in AppointmentProvider: ${appointmentProvider.clinicId}');

//       if (appointmentProvider.clinicId == null ||
//           appointmentProvider.clinicId!.isEmpty) {
//         devtools.log('Error: clinicId is empty in AppointmentProvider.');
//       } else {
//         _patientService = appointmentProvider.patientService;
//         _initializeStream();
//       }
//     });

//     ClinicSelection.instance.addListener(_onClinicChanged);
//   }

//   //-------------------------------------------------------------------------//
//   void _initializeStream() {
//     final clinicId = ClinicSelection.instance.selectedClinicId;

//     if (clinicId.isEmpty) {
//       devtools.log('Error: clinicId is empty. Stream cannot be initialized.');
//       return;
//     }

//     devtools.log('Initializing patient stream for clinicId: $clinicId');
//     setState(() {
//       _patientsStream =
//           _patientService.getAllPatientsRealTime(clinicId: clinicId);
//     });
//   }

//   //--------------------------------------------------------------------------//

//   @override
//   void dispose() {
//     _searchController.dispose();
//     ClinicSelection.instance.removeListener(_onClinicChanged);
//     super.dispose();
//   }

//   void _onClinicChanged() {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();

//     _debounce = Timer(const Duration(milliseconds: 300), () {
//       devtools.log('Clinic changed. Updating patient stream...');
//       _initializeStream();
//     });
//   }

//   void _handleSearchInput(String query) {
//     final clinicId = ClinicSelection.instance.selectedClinicId;

//     if (clinicId.isEmpty) {
//       devtools.log('Error: clinicId is empty. Cannot search patients.');
//       return;
//     }

//     setState(() {
//       _patientsStream = query.isNotEmpty
//           ? _patientService.searchPatientsRealTime(query, clinicId)
//           : _patientService.getAllPatientsRealTime(clinicId: clinicId);
//     });
//   }

//   Widget _buildPatientsList(List<Patient> patients) {
//     patients.sort((a, b) => a.patientName.compareTo(b.patientName));

//     List<Widget> widgets = [];
//     String currentAlphabet = '';

//     for (final patient in patients) {
//       final patientFirstChar = patient.patientName.isNotEmpty
//           ? patient.patientName[0].toUpperCase()
//           : '';

//       if (patientFirstChar != currentAlphabet) {
//         widgets.add(
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 patientFirstChar,
//                 style: MyTextStyle.textStyleMap['headline-large']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         );
//         currentAlphabet = patientFirstChar;
//       }

//       widgets.add(
//         GestureDetector(
//           onTap: () => _navigateToTreatment(patient),
//           child: Card(
//             child: ListTile(
//               leading: CircleAvatar(
//                 backgroundColor: MyColors.colorPalette['surface'],
//                 backgroundImage: patient.patientPicUrl != null &&
//                         patient.patientPicUrl!.isNotEmpty
//                     ? NetworkImage(patient.patientPicUrl!)
//                     : Image.asset(
//                         'assets/images/default-image.png',
//                         color: MyColors.colorPalette['secondary'],
//                         colorBlendMode: BlendMode.color,
//                       ).image,
//               ),
//               title: Text(
//                 patient.patientName,
//                 style: MyTextStyle.textStyleMap['label-medium']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//               subtitle: Text(
//                 '${patient.age}, ${patient.gender}',
//                 style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return Column(children: widgets);
//   }

//   void _navigateToTreatment(Patient patient) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TreatmentLandingScreen(
//           clinicId: ClinicSelection.instance.selectedClinicId,
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           patientId: patient.patientId,
//           patientName: patient.patientName,
//           patientMobileNumber: patient.patientMobileNumber,
//           age: patient.age,
//           gender: patient.gender,
//           patientPicUrl: patient.patientPicUrl,
//           uhid: patient.uhid,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               onChanged: _handleSearchInput,
//               decoration: InputDecoration(
//                 labelText: 'Search Patient by Name or Phone',
//                 prefixIcon: Icon(Icons.search,
//                     color: MyColors.colorPalette['on-surface-variant']),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                   borderSide: BorderSide(
//                     color: MyColors.colorPalette['primary'] ?? Colors.black,
//                   ),
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                   borderSide: BorderSide(
//                     color: MyColors.colorPalette['on-surface-variant'] ??
//                         Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<List<Patient>>(
//               stream: _patientsStream,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(
//                     child: Text('Error: ${snapshot.error}'),
//                   );
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(
//                     child: Text(
//                       'No patients found.',
//                       style: MyTextStyle.textStyleMap['label-large']
//                           ?.copyWith(color: MyColors.colorPalette['secondary']),
//                     ),
//                   );
//                 }
//                 return SingleChildScrollView(
//                   child: _buildPatientsList(snapshot.data!),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/common_app_bar.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'package:provider/provider.dart';
// import 'dart:developer' as devtools show log;

// class SearchAndDisplayAllPatients extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;

//   const SearchAndDisplayAllPatients({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//   });

//   @override
//   State<SearchAndDisplayAllPatients> createState() =>
//       _SearchAndDisplayAllPatientsState();
// }

// class _SearchAndDisplayAllPatientsState
//     extends State<SearchAndDisplayAllPatients> {
//   final TextEditingController _searchController = TextEditingController();
//   late PatientService _patientService;

//   List<Patient> matchingPatients = []; // Store matching patients

//   bool hasUserInput = false; // Track if the user has entered input
//   Patient? selectedPatient;
//   Stream<List<Patient>>? matchingPatientsStream;
//   // Define a GlobalKey for the navigator
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   //int _currentIndex = 3;
//   static const int defaultIndex = 3;
//   int _currentIndex = defaultIndex;

//   List<Map<String, dynamic>> recentPatients = [];
//   bool _isLoading = false;
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     final appointmentProvider =
//         Provider.of<AppointmentProvider>(context, listen: false);

//     _patientService = appointmentProvider.patientService;
//     _searchController.text = '';

//     // Perform initial fetch with the currently selected clinic
//     _fetchInitialData();
//     matchingPatientsStream = _patientService.getAllPatientsRealTime(
//       clinicId: ClinicSelection.instance.selectedClinicId,
//     );
//     devtools.log(
//         '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//     devtools.log(
//         '!!!! This is coming from inside initState of SearchAndDisplayAllPatients !!!!!!!!!');
//     devtools.log('!!!!clinicId of selected clinic is ${widget.clinicId} !!!!');
//     devtools.log(
//         '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

//     // Add listener for clinic changes
//     ClinicSelection.instance.addListener(_onClinicChanged);
//   }

//   //-------------------------------------------------------------------------//

//   @override
//   void dispose() {
//     _searchController.dispose();
//     ClinicSelection.instance.removeListener(_onClinicChanged);
//     super.dispose();
//   }

//   //------------------------------------------------------------------------//

//   // void _onClinicChanged() {
//   //   final clinicId = ClinicSelection.instance.selectedClinicId;
//   //   if (clinicId.isEmpty) {
//   //     devtools.log('No clinic selected.');
//   //     return;
//   //   }

//   //   devtools.log(
//   //       '@@@@ This is coming from inside _onClinicChanged defined inside SearchAndDisplayAllPatients. Clinic changed to: $clinicId');
//   //   widget.patientService.updateClinicId(clinicId);
//   //   handleSearchInput(''); // Update stream on clinic change
//   //   _fetchInitialData(); // Refresh data
//   // }

//   void _onClinicChanged() {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 300), () {
//       final clinicId = ClinicSelection.instance.selectedClinicId;

//       if (clinicId.isEmpty) {
//         devtools.log('No clinic selected.');
//         return;
//       }

//       devtools.log(
//           '@@@@ This is coming from inside _onClinicChanged. Clinic changed to: $clinicId');
//       _patientService.updateClinicAndDoctor(clinicId, widget.doctorId);

//       //handleSearchInput(''); // Update stream on clinic change
//       matchingPatientsStream =
//           _patientService.getAllPatientsRealTime(clinicId: clinicId);
//       _fetchInitialData(); // Refresh data
//     });
//   }

//   //-----------------------------------------------------------------------//

//   // Future<void> _fetchInitialData() async {
//   //   final clinicId = ClinicSelection.instance.selectedClinicId;

//   //   if (clinicId.isEmpty) {
//   //     devtools.log('No clinic selected.');
//   //     return;
//   //   }

//   //   if (mounted) {
//   //     setState(() {
//   //       _isLoading = true;
//   //     });
//   //   }

//   //   try {
//   //     devtools.log(
//   //         'Fetching recent patients and all patients for clinic: $clinicId');

//   //     // Fetch recent patients for the selected clinic
//   //     recentPatients = await _patientService.fetchRecentPatients(
//   //       clinicId: clinicId,
//   //     );

//   //     // Update the stream for all patients
//   //     matchingPatientsStream =
//   //         _patientService.getAllPatientsRealTime(clinicId: clinicId);

//   //     if (mounted) {
//   //       setState(() {}); // Trigger rebuild with updated stream
//   //     }
//   //   } catch (e) {
//   //     devtools.log('Error fetching patient data: $e');
//   //   } finally {
//   //     _stopLoading();
//   //   }
//   // }
//   //---------------------------------------------------------------------------//
//   Future<void> _fetchInitialData() async {
//     final clinicId = ClinicSelection.instance.selectedClinicId;

//     if (clinicId == null || clinicId.isEmpty) {
//       devtools.log('No clinic selected. Cannot fetch data.');
//       return;
//     }

//     if (mounted) {
//       setState(() {
//         _isLoading = true;
//       });
//     }

//     try {
//       devtools.log(
//           'Fetching recent patients and all patients for clinic: $clinicId');
//       recentPatients =
//           await _patientService.fetchRecentPatients(clinicId: clinicId);
//       matchingPatientsStream =
//           _patientService.getAllPatientsRealTime(clinicId: clinicId);

//       setState(() {});
//     } catch (e) {
//       devtools.log('Error fetching patient data: $e');
//     } finally {
//       _stopLoading();
//     }
//   }

//   //---------------------------------------------------------------------------//

//   void _stopLoading() {
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   //-------------------------------------------------------------------------//

//   void handleSearchInput(String query) {
//     final clinicId = ClinicSelection.instance.selectedClinicId;

//     try {
//       if (query.isNotEmpty) {
//         matchingPatientsStream = _patientService.searchPatientsRealTime(
//           query,
//           clinicId,
//         );
//       } else {
//         matchingPatientsStream =
//             _patientService.getAllPatientsRealTime(clinicId: clinicId);
//       }
//       setState(() {}); // Trigger rebuild
//     } catch (e) {
//       devtools.log('Error handling search input: $e');
//     }
//   }

//   void handleSelectPatient(Patient patient) async {
//     _patientService.incrementSearchCount(patient.patientId);
//     setState(() {
//       selectedPatient = patient;
//     });

//     // Navigate to the TreatmentLandingScreen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TreatmentLandingScreen(
//           clinicId: ClinicSelection.instance.selectedClinicId,
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           patientId: selectedPatient?.patientId ?? '',
//           patientName: selectedPatient?.patientName ?? '',
//           patientMobileNumber: selectedPatient?.patientMobileNumber ?? '',
//           age: selectedPatient?.age ?? 0,
//           gender: selectedPatient?.gender ?? '',
//           patientPicUrl: selectedPatient?.patientPicUrl ?? '',
//           uhid: selectedPatient?.uhid ?? '',
//         ),
//       ),
//     );

//     // Do any additional actions needed with the selected patient
//     devtools.log(
//         'This is coming from inside handleSelectPatient. Selected Patient: ${selectedPatient?.patientName}');

//     if (selectedPatient != null && selectedPatient!.patientId.isNotEmpty) {
//       try {
//         final patientId = selectedPatient!.patientId;
//         devtools.log('patientId of selectedPatient is $patientId');

//         // Increment the searchCount for the found patient
//         //await widget.patientService.incrementSearchCount(patientId);
//       } catch (e) {
//         devtools.log('Error incrementing searchCount: $e');
//       }
//     }
//   }

//   List<Widget> _buildPatientsList(List<Patient> patients) {
//     patients.sort((a, b) {
//       final patientNameA = a.patientName.trim().toLowerCase();
//       final patientNameB = b.patientName.trim().toLowerCase();
//       return patientNameA.compareTo(patientNameB);
//     });

//     List<Widget> widgets = [];
//     String currentAlphabet = '';

//     for (final patient in patients) {
//       final patientFirstChar = patient.patientName.isNotEmpty
//           ? patient.patientName[0].toUpperCase()
//           : '';

//       if (patientFirstChar != currentAlphabet) {
//         // Add a header widget with a bigger font size
//         widgets.add(
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 patientFirstChar,
//                 style: MyTextStyle.textStyleMap['headline-large']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         );
//         currentAlphabet = patientFirstChar;
//       }

//       // Add the patient ListTile wrapped with GestureDetector
//       widgets.add(
//         GestureDetector(
//           onTap: () {
//             handleSelectPatient(patient);
//           },
//           //-----------------------------------------------------------------//
//           onLongPress: () {
//             _deletePatient(patient, widget.doctorName);
//           },
//           //-----------------------------------------------------------------//
//           child: Card(
//             child: ListTile(
//               leading: CircleAvatar(
//                 radius: 24,
//                 backgroundColor: MyColors.colorPalette['surface'],
//                 backgroundImage: patient.patientPicUrl != null &&
//                         patient.patientPicUrl!.isNotEmpty
//                     ? NetworkImage(patient.patientPicUrl!)
//                     : Image.asset(
//                         'assets/images/default-image.png',
//                         color: MyColors.colorPalette['secondary'],
//                         colorBlendMode: BlendMode.color,
//                       ).image,
//               ),
//               title: Text(
//                 patient.patientName,
//                 style: MyTextStyle.textStyleMap['label-medium']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//               subtitle: Text(
//                 '${patient.age}, ${patient.gender}',
//                 style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return widgets;
//   }

//   //------------------------------------------------------------------------//
//   void _deletePatient(Patient patient, String doctorName) async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Confirm Delete'),
//           content: Text(
//               'Are you sure you want to delete patient ${patient.patientName} permanently?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     try {
//       await _patientService.deletePatient(patient.patientId, doctorName);

//       handleSearchInput(_searchController.text);
//       // _fetchRecentPatients().then((recentPatientsData) {
//       //   setState(() {
//       //     recentPatients = recentPatientsData;
//       //   });
//       // });
//       _fetchInitialData();

//       scaffoldMessenger.showSnackBar(
//         SnackBar(content: Text('Patient ${patient.patientName} deleted')),
//       );
//     } catch (e) {
//       devtools.log('Error deleting patient: $e');
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(content: Text('Error deleting patient')),
//       );
//     }
//   }

//   void _deletePatientFromRecent(int index) async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     final patientId = recentPatients[index]['patientId'];
//     final patientName = recentPatients[index]['patientName'];

//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Confirm Delete'),
//           content: Text('Are you sure you want to delete $patientName?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     try {
//       await _patientService.deletePatient(patientId, widget.doctorName);

//       handleSearchInput(_searchController.text);
//       // _fetchRecentPatients().then((recentPatientsData) {
//       //   setState(() {
//       //     recentPatients = recentPatientsData;
//       //   });
//       // });
//       _fetchInitialData();

//       scaffoldMessenger.showSnackBar(
//         SnackBar(content: Text('Patient $patientName deleted')),
//       );
//     } catch (e) {
//       devtools.log('Error deleting patient: $e');
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(content: Text('Error deleting patient')),
//       );
//     }
//   }

//   // ------------------------------------------------------------------------ //
//   Stream<List<Patient>>? _getPatientStream() {
//     devtools.log(
//         '&&&& This is coming from inside _getPatientStream defined inside SearchAndDisplayAllPatients.  Fetching patient stream for clinic: ${ClinicSelection.instance.selectedClinicId}');
//     return hasUserInput
//         ? matchingPatientsStream
//         : _patientService.getAllPatientsRealTime(
//             clinicId: ClinicSelection.instance.selectedClinicId,
//           );
//   }
//   // ------------------------------------------------------------------------ //

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to SearchAndDisplayAllPatients!');
//     return Scaffold(
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: SizedBox(
//                     height: 40,
//                     child: TextField(
//                       controller: _searchController,
//                       onChanged: (value) {
//                         setState(() {
//                           hasUserInput = value.isNotEmpty;
//                         });
//                         handleSearchInput(value);
//                       },
//                       decoration: InputDecoration(
//                         labelText: 'Search Patient with name or phone number',
//                         labelStyle: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(
//                                 color: MyColors
//                                     .colorPalette['on-surface-variant']),
//                         prefixIcon: Icon(Icons.search,
//                             color: MyColors.colorPalette['on-surface-variant']),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(8.0),
//                           ),
//                           borderSide: BorderSide(
//                             color: MyColors.colorPalette['primary'] ??
//                                 Colors.black,
//                           ),
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(8.0),
//                           ),
//                           borderSide: BorderSide(
//                             color:
//                                 MyColors.colorPalette['on-surface-variant'] ??
//                                     Colors.black,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Recent Patients Section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Align(
//                     alignment: Alignment.topCenter,
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: MediaQuery.of(context).size.width * 0.1,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: recentPatients.map((patient) {
//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => TreatmentLandingScreen(
//                                     //clinicId: widget.clinicId,
//                                     clinicId: ClinicSelection
//                                         .instance.selectedClinicId,
//                                     doctorId: widget.doctorId,
//                                     doctorName: widget.doctorName,
//                                     patientId: patient['patientId'],
//                                     patientName: patient['patientName'],
//                                     patientMobileNumber:
//                                         patient['patientMobileNumber'],
//                                     age: patient['age'],
//                                     gender: patient['gender'],
//                                     patientPicUrl: patient['patientPicUrl'],
//                                     uhid: patient['uhid'],
//                                   ),
//                                 ),
//                               );
//                             },
//                             onLongPress: () {
//                               _deletePatientFromRecent(
//                                   recentPatients.indexOf(patient));
//                             },
//                             child: Column(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 24,
//                                   backgroundColor:
//                                       MyColors.colorPalette['surface'],
//                                   backgroundImage: patient['patientPicUrl'] !=
//                                               null &&
//                                           patient['patientPicUrl'].isNotEmpty
//                                       ? NetworkImage(patient['patientPicUrl'])
//                                       : Image.asset(
//                                           'assets/images/default-image.png',
//                                           color:
//                                               MyColors.colorPalette['primary'],
//                                           colorBlendMode: BlendMode.color,
//                                         ).image,
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   patient['patientName'],
//                                   style: MyTextStyle.textStyleMap['label-small']
//                                       ?.copyWith(
//                                     color: MyColors.colorPalette['on_surface'],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // All Patients Section
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'All Patients',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                           color: MyColors.colorPalette['on-surface']),
//                     ),
//                   ),
//                 ),
//                 StreamBuilder<List<Patient>>(
//                   // stream: hasUserInput
//                   //     ? matchingPatientsStream
//                   //     : widget.patientService.getAllPatientsRealTime(
//                   //         clinicId: ClinicSelection.instance.selectedClinicId,
//                   //       ),
//                   stream: _getPatientStream(),
//                   builder: (context, snapshot) {
//                     devtools.log('All Patients Snapshot Listener triggered');
//                     devtools.log('All Patients Retrieved: ${snapshot.data}');

//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const CircularProgressIndicator();
//                     } else if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     } else if (snapshot.data == null ||
//                         snapshot.data!.isEmpty) {
//                       return Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'No patients found',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on-surface-variant']),
//                         ),
//                       );
//                     } else {
//                       return Column(
//                         children: _buildPatientsList(snapshot.data!),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//     );
//   }
// }

//#############################################################################//
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/common_app_bar.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'dart:developer' as devtools show log;

// class SearchAndDisplayAllPatients extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;
//   //final PatientService patientService;

//   const SearchAndDisplayAllPatients({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//     //required this.patientService,
//   });

//   @override
//   State<SearchAndDisplayAllPatients> createState() =>
//       _SearchAndDisplayAllPatientsState();
// }

// class _SearchAndDisplayAllPatientsState
//     extends State<SearchAndDisplayAllPatients> {
//   final TextEditingController _searchController = TextEditingController();

//   List<Patient> matchingPatients = []; // Store matching patients

//   bool hasUserInput = false; // Track if the user has entered input
//   Patient? selectedPatient;
//   Stream<List<Patient>>? matchingPatientsStream;
//   // Define a GlobalKey for the navigator
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   //int _currentIndex = 3;
//   static const int defaultIndex = 3;
//   int _currentIndex = defaultIndex;

//   List<Map<String, dynamic>> recentPatients = [];
//   bool _isLoading = false;
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     _searchController.text = '';

//     // Perform initial fetch with the currently selected clinic
//     _fetchInitialData();
//     matchingPatientsStream = widget.patientService.getAllPatientsRealTime(
//       clinicId: ClinicSelection.instance.selectedClinicId,
//     );
//     devtools.log(
//         '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//     devtools.log(
//         '!!!! This is coming from inside initState of SearchAndDisplayAllPatients !!!!!!!!!');
//     devtools.log('!!!!clinicId of selected clinic is ${widget.clinicId} !!!!');
//     devtools.log(
//         '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

//     // Add listener for clinic changes
//     ClinicSelection.instance.addListener(_onClinicChanged);
//   }

//   //-------------------------------------------------------------------------//

//   @override
//   void dispose() {
//     _searchController.dispose();
//     ClinicSelection.instance.removeListener(_onClinicChanged);
//     super.dispose();
//   }

//   //------------------------------------------------------------------------//

//   // void _onClinicChanged() {
//   //   final clinicId = ClinicSelection.instance.selectedClinicId;
//   //   if (clinicId.isEmpty) {
//   //     devtools.log('No clinic selected.');
//   //     return;
//   //   }

//   //   devtools.log(
//   //       '@@@@ This is coming from inside _onClinicChanged defined inside SearchAndDisplayAllPatients. Clinic changed to: $clinicId');
//   //   widget.patientService.updateClinicId(clinicId);
//   //   handleSearchInput(''); // Update stream on clinic change
//   //   _fetchInitialData(); // Refresh data
//   // }

//   void _onClinicChanged() {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 300), () {
//       final clinicId = ClinicSelection.instance.selectedClinicId;

//       if (clinicId.isEmpty) {
//         devtools.log('No clinic selected.');
//         return;
//       }

//       devtools.log(
//           '@@@@ This is coming from inside _onClinicChanged. Clinic changed to: $clinicId');
//       widget.patientService.updateClinicId(clinicId);

//       //handleSearchInput(''); // Update stream on clinic change
//       matchingPatientsStream =
//           widget.patientService.getAllPatientsRealTime(clinicId: clinicId);
//       _fetchInitialData(); // Refresh data
//     });
//   }

//   //-----------------------------------------------------------------------//

//   Future<void> _fetchInitialData() async {
//     final clinicId = ClinicSelection.instance.selectedClinicId;

//     if (clinicId.isEmpty) {
//       devtools.log('No clinic selected.');
//       return;
//     }

//     if (mounted) {
//       setState(() {
//         _isLoading = true;
//       });
//     }

//     try {
//       devtools.log(
//           'Fetching recent patients and all patients for clinic: $clinicId');

//       // Fetch recent patients for the selected clinic
//       recentPatients = await widget.patientService.fetchRecentPatients(
//         clinicId: clinicId,
//       );

//       // Update the stream for all patients
//       matchingPatientsStream =
//           widget.patientService.getAllPatientsRealTime(clinicId: clinicId);

//       if (mounted) {
//         setState(() {}); // Trigger rebuild with updated stream
//       }
//     } catch (e) {
//       devtools.log('Error fetching patient data: $e');
//     } finally {
//       _stopLoading();
//     }
//   }
//   //---------------------------------------------------------------------------//

//   void _stopLoading() {
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   //-------------------------------------------------------------------------//

//   void handleSearchInput(String query) {
//     final clinicId = ClinicSelection.instance.selectedClinicId;

//     try {
//       if (query.isNotEmpty) {
//         matchingPatientsStream = widget.patientService.searchPatientsRealTime(
//           query,
//           clinicId,
//         );
//       } else {
//         matchingPatientsStream =
//             widget.patientService.getAllPatientsRealTime(clinicId: clinicId);
//       }
//       setState(() {}); // Trigger rebuild
//     } catch (e) {
//       devtools.log('Error handling search input: $e');
//     }
//   }

//   void handleSelectPatient(Patient patient) async {
//     widget.patientService.incrementSearchCount(patient.patientId);
//     setState(() {
//       selectedPatient = patient;
//     });

//     // Navigate to the TreatmentLandingScreen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TreatmentLandingScreen(
//           //clinicId: widget.clinicId,
//           clinicId: ClinicSelection.instance.selectedClinicId,
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           patientId: selectedPatient?.patientId ?? '',
//           patientName: selectedPatient?.patientName ?? '',
//           patientMobileNumber: selectedPatient?.patientMobileNumber ?? '',
//           age: selectedPatient?.age ?? 0,
//           gender: selectedPatient?.gender ?? '',
//           patientPicUrl: selectedPatient?.patientPicUrl ?? '',
//           uhid: selectedPatient?.uhid ?? '',
//         ),
//       ),
//     );

//     // Do any additional actions needed with the selected patient
//     devtools.log(
//         'This is coming from inside handleSelectPatient. Selected Patient: ${selectedPatient?.patientName}');

//     if (selectedPatient != null && selectedPatient!.patientId.isNotEmpty) {
//       try {
//         final patientId = selectedPatient!.patientId;
//         devtools.log('patientId of selectedPatient is $patientId');

//         // Increment the searchCount for the found patient
//         //await widget.patientService.incrementSearchCount(patientId);
//       } catch (e) {
//         devtools.log('Error incrementing searchCount: $e');
//       }
//     }
//   }

//   List<Widget> _buildPatientsList(List<Patient> patients) {
//     patients.sort((a, b) {
//       final patientNameA = a.patientName.trim().toLowerCase();
//       final patientNameB = b.patientName.trim().toLowerCase();
//       return patientNameA.compareTo(patientNameB);
//     });

//     List<Widget> widgets = [];
//     String currentAlphabet = '';

//     for (final patient in patients) {
//       final patientFirstChar = patient.patientName.isNotEmpty
//           ? patient.patientName[0].toUpperCase()
//           : '';

//       if (patientFirstChar != currentAlphabet) {
//         // Add a header widget with a bigger font size
//         widgets.add(
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 patientFirstChar,
//                 style: MyTextStyle.textStyleMap['headline-large']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         );
//         currentAlphabet = patientFirstChar;
//       }

//       // Add the patient ListTile wrapped with GestureDetector
//       widgets.add(
//         GestureDetector(
//           onTap: () {
//             handleSelectPatient(patient);
//           },
//           //-----------------------------------------------------------------//
//           onLongPress: () {
//             _deletePatient(patient, widget.doctorName);
//           },
//           //-----------------------------------------------------------------//
//           child: Card(
//             child: ListTile(
//               leading: CircleAvatar(
//                 radius: 24,
//                 backgroundColor: MyColors.colorPalette['surface'],
//                 backgroundImage: patient.patientPicUrl != null &&
//                         patient.patientPicUrl!.isNotEmpty
//                     ? NetworkImage(patient.patientPicUrl!)
//                     : Image.asset(
//                         'assets/images/default-image.png',
//                         color: MyColors.colorPalette['secondary'],
//                         colorBlendMode: BlendMode.color,
//                       ).image,
//               ),
//               title: Text(
//                 patient.patientName,
//                 style: MyTextStyle.textStyleMap['label-medium']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//               subtitle: Text(
//                 '${patient.age}, ${patient.gender}',
//                 style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return widgets;
//   }

//   //------------------------------------------------------------------------//
//   void _deletePatient(Patient patient, String doctorName) async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Confirm Delete'),
//           content: Text(
//               'Are you sure you want to delete patient ${patient.patientName} permanently?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     try {
//       await widget.patientService.deletePatient(patient.patientId, doctorName);

//       handleSearchInput(_searchController.text);
//       // _fetchRecentPatients().then((recentPatientsData) {
//       //   setState(() {
//       //     recentPatients = recentPatientsData;
//       //   });
//       // });
//       _fetchInitialData();

//       scaffoldMessenger.showSnackBar(
//         SnackBar(content: Text('Patient ${patient.patientName} deleted')),
//       );
//     } catch (e) {
//       devtools.log('Error deleting patient: $e');
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(content: Text('Error deleting patient')),
//       );
//     }
//   }

//   void _deletePatientFromRecent(int index) async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     final patientId = recentPatients[index]['patientId'];
//     final patientName = recentPatients[index]['patientName'];

//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Confirm Delete'),
//           content: Text('Are you sure you want to delete $patientName?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     try {
//       await widget.patientService.deletePatient(patientId, widget.doctorName);

//       handleSearchInput(_searchController.text);
//       // _fetchRecentPatients().then((recentPatientsData) {
//       //   setState(() {
//       //     recentPatients = recentPatientsData;
//       //   });
//       // });
//       _fetchInitialData();

//       scaffoldMessenger.showSnackBar(
//         SnackBar(content: Text('Patient $patientName deleted')),
//       );
//     } catch (e) {
//       devtools.log('Error deleting patient: $e');
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(content: Text('Error deleting patient')),
//       );
//     }
//   }

//   // ------------------------------------------------------------------------ //
//   Stream<List<Patient>>? _getPatientStream() {
//     devtools.log(
//         '&&&& This is coming from inside _getPatientStream defined inside SearchAndDisplayAllPatients.  Fetching patient stream for clinic: ${ClinicSelection.instance.selectedClinicId}');
//     return hasUserInput
//         ? matchingPatientsStream
//         : widget.patientService.getAllPatientsRealTime(
//             clinicId: ClinicSelection.instance.selectedClinicId,
//           );
//   }
//   // ------------------------------------------------------------------------ //

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to SearchAndDisplayAllPatients!');
//     return Scaffold(
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: SizedBox(
//                     height: 40,
//                     child: TextField(
//                       controller: _searchController,
//                       onChanged: (value) {
//                         setState(() {
//                           hasUserInput = value.isNotEmpty;
//                         });
//                         handleSearchInput(value);
//                       },
//                       decoration: InputDecoration(
//                         labelText: 'Search Patient with name or phone number',
//                         labelStyle: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(
//                                 color: MyColors
//                                     .colorPalette['on-surface-variant']),
//                         prefixIcon: Icon(Icons.search,
//                             color: MyColors.colorPalette['on-surface-variant']),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(8.0),
//                           ),
//                           borderSide: BorderSide(
//                             color: MyColors.colorPalette['primary'] ??
//                                 Colors.black,
//                           ),
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(8.0),
//                           ),
//                           borderSide: BorderSide(
//                             color:
//                                 MyColors.colorPalette['on-surface-variant'] ??
//                                     Colors.black,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Recent Patients Section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Align(
//                     alignment: Alignment.topCenter,
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: MediaQuery.of(context).size.width * 0.1,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: recentPatients.map((patient) {
//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => TreatmentLandingScreen(
//                                     //clinicId: widget.clinicId,
//                                     clinicId: ClinicSelection
//                                         .instance.selectedClinicId,
//                                     doctorId: widget.doctorId,
//                                     doctorName: widget.doctorName,
//                                     patientId: patient['patientId'],
//                                     patientName: patient['patientName'],
//                                     patientMobileNumber:
//                                         patient['patientMobileNumber'],
//                                     age: patient['age'],
//                                     gender: patient['gender'],
//                                     patientPicUrl: patient['patientPicUrl'],
//                                     uhid: patient['uhid'],
//                                   ),
//                                 ),
//                               );
//                             },
//                             onLongPress: () {
//                               _deletePatientFromRecent(
//                                   recentPatients.indexOf(patient));
//                             },
//                             child: Column(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 24,
//                                   backgroundColor:
//                                       MyColors.colorPalette['surface'],
//                                   backgroundImage: patient['patientPicUrl'] !=
//                                               null &&
//                                           patient['patientPicUrl'].isNotEmpty
//                                       ? NetworkImage(patient['patientPicUrl'])
//                                       : Image.asset(
//                                           'assets/images/default-image.png',
//                                           color:
//                                               MyColors.colorPalette['primary'],
//                                           colorBlendMode: BlendMode.color,
//                                         ).image,
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   patient['patientName'],
//                                   style: MyTextStyle.textStyleMap['label-small']
//                                       ?.copyWith(
//                                     color: MyColors.colorPalette['on_surface'],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // All Patients Section
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'All Patients',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                           color: MyColors.colorPalette['on-surface']),
//                     ),
//                   ),
//                 ),
//                 StreamBuilder<List<Patient>>(
//                   // stream: hasUserInput
//                   //     ? matchingPatientsStream
//                   //     : widget.patientService.getAllPatientsRealTime(
//                   //         clinicId: ClinicSelection.instance.selectedClinicId,
//                   //       ),
//                   stream: _getPatientStream(),
//                   builder: (context, snapshot) {
//                     devtools.log('All Patients Snapshot Listener triggered');
//                     devtools.log('All Patients Retrieved: ${snapshot.data}');

//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const CircularProgressIndicator();
//                     } else if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     } else if (snapshot.data == null ||
//                         snapshot.data!.isEmpty) {
//                       return Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'No patients found',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on-surface-variant']),
//                         ),
//                       );
//                     } else {
//                       return Column(
//                         children: _buildPatientsList(snapshot.data!),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/common_app_bar.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'dart:developer' as devtools show log;

// class SearchAndDisplayAllPatients extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;
//   final PatientService patientService;

//   const SearchAndDisplayAllPatients({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//     required this.patientService,
//   });

//   @override
//   State<SearchAndDisplayAllPatients> createState() =>
//       _SearchAndDisplayAllPatientsState();
// }

// class _SearchAndDisplayAllPatientsState
//     extends State<SearchAndDisplayAllPatients> {
//   final TextEditingController _searchController = TextEditingController();

//   List<Patient> matchingPatients = []; // Store matching patients

//   bool hasUserInput = false; // Track if the user has entered input
//   Patient? selectedPatient;
//   Stream<List<Patient>>? matchingPatientsStream;
//   // Define a GlobalKey for the navigator
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   //int _currentIndex = 3;
//   static const int defaultIndex = 3;
//   int _currentIndex = defaultIndex;

//   List<Map<String, dynamic>> recentPatients = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _searchController.text = '';

//     // Perform initial fetch with the currently selected clinic
//     _fetchInitialData();
//     matchingPatientsStream = widget.patientService.getAllPatientsRealTime(
//       clinicId: ClinicSelection.instance.selectedClinicId,
//     );

//     // Add listener for clinic changes
//     ClinicSelection.instance.addListener(_onClinicChanged);
//   }

//   //-------------------------------------------------------------------------//

//   @override
//   void dispose() {
//     _searchController.dispose();
//     ClinicSelection.instance.removeListener(_onClinicChanged);
//     super.dispose();
//   }

//   //------------------------------------------------------------------------//

//   void _onClinicChanged() {
//     final clinicId = ClinicSelection.instance.selectedClinicId;
//     if (clinicId.isEmpty) {
//       devtools.log('No clinic selected.');
//       return;
//     }

//     devtools.log('Clinic changed to: $clinicId');
//     widget.patientService.updateClinicId(clinicId);
//     handleSearchInput(''); // Update stream on clinic change
//     _fetchInitialData(); // Refresh data
//   }

//   //-----------------------------------------------------------------------//

//   Future<void> _fetchInitialData() async {
//     final clinicId = ClinicSelection.instance.selectedClinicId;

//     if (clinicId.isEmpty) {
//       devtools.log('No clinic selected.');
//       return;
//     }

//     if (mounted) {
//       setState(() {
//         _isLoading = true;
//       });
//     }

//     try {
//       devtools.log(
//           'Fetching recent patients and all patients for clinic: $clinicId');

//       // Fetch recent patients for the selected clinic
//       recentPatients = await widget.patientService.fetchRecentPatients(
//         clinicId: clinicId,
//       );

//       // Update the stream for all patients
//       matchingPatientsStream =
//           widget.patientService.getAllPatientsRealTime(clinicId: clinicId);

//       if (mounted) {
//         setState(() {}); // Trigger rebuild with updated stream
//       }
//     } catch (e) {
//       devtools.log('Error fetching patient data: $e');
//     } finally {
//       _stopLoading();
//     }
//   }

//   void _stopLoading() {
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   //-------------------------------------------------------------------------//

//   void handleSearchInput(String query) {
//     final clinicId = ClinicSelection.instance.selectedClinicId;

//     try {
//       if (query.isNotEmpty) {
//         matchingPatientsStream = widget.patientService.searchPatientsRealTime(
//           query,
//           clinicId,
//         );
//       } else {
//         matchingPatientsStream =
//             widget.patientService.getAllPatientsRealTime(clinicId: clinicId);
//       }
//       setState(() {}); // Trigger rebuild
//     } catch (e) {
//       devtools.log('Error handling search input: $e');
//     }
//   }

//   void handleSelectPatient(Patient patient) async {
//     widget.patientService.incrementSearchCount(patient.patientId);
//     setState(() {
//       selectedPatient = patient;
//     });

//     // Navigate to the TreatmentLandingScreen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TreatmentLandingScreen(
//           //clinicId: widget.clinicId,
//           clinicId: ClinicSelection.instance.selectedClinicId,
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           patientId: selectedPatient?.patientId ?? '',
//           patientName: selectedPatient?.patientName ?? '',
//           patientMobileNumber: selectedPatient?.patientMobileNumber ?? '',
//           age: selectedPatient?.age ?? 0,
//           gender: selectedPatient?.gender ?? '',
//           patientPicUrl: selectedPatient?.patientPicUrl ?? '',
//           uhid: selectedPatient?.uhid ?? '',
//         ),
//       ),
//     );

//     // Do any additional actions needed with the selected patient
//     devtools.log(
//         'This is coming from inside handleSelectPatient. Selected Patient: ${selectedPatient?.patientName}');

//     if (selectedPatient != null && selectedPatient!.patientId.isNotEmpty) {
//       try {
//         final patientId = selectedPatient!.patientId;
//         devtools.log('patientId of selectedPatient is $patientId');

//         // Increment the searchCount for the found patient
//         //await widget.patientService.incrementSearchCount(patientId);
//       } catch (e) {
//         devtools.log('Error incrementing searchCount: $e');
//       }
//     }
//   }

//   List<Widget> _buildPatientsList(List<Patient> patients) {
//     patients.sort((a, b) {
//       final patientNameA = a.patientName.trim().toLowerCase();
//       final patientNameB = b.patientName.trim().toLowerCase();
//       return patientNameA.compareTo(patientNameB);
//     });

//     List<Widget> widgets = [];
//     String currentAlphabet = '';

//     for (final patient in patients) {
//       final patientFirstChar = patient.patientName.isNotEmpty
//           ? patient.patientName[0].toUpperCase()
//           : '';

//       if (patientFirstChar != currentAlphabet) {
//         // Add a header widget with a bigger font size
//         widgets.add(
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 patientFirstChar,
//                 style: MyTextStyle.textStyleMap['headline-large']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         );
//         currentAlphabet = patientFirstChar;
//       }

//       // Add the patient ListTile wrapped with GestureDetector
//       widgets.add(
//         GestureDetector(
//           onTap: () {
//             handleSelectPatient(patient);
//           },
//           //-----------------------------------------------------------------//
//           onLongPress: () {
//             _deletePatient(patient, widget.doctorName);
//           },
//           //-----------------------------------------------------------------//
//           child: Card(
//             child: ListTile(
//               leading: CircleAvatar(
//                 radius: 24,
//                 backgroundColor: MyColors.colorPalette['surface'],
//                 backgroundImage: patient.patientPicUrl != null &&
//                         patient.patientPicUrl!.isNotEmpty
//                     ? NetworkImage(patient.patientPicUrl!)
//                     : Image.asset(
//                         'assets/images/default-image.png',
//                         color: MyColors.colorPalette['secondary'],
//                         colorBlendMode: BlendMode.color,
//                       ).image,
//               ),
//               title: Text(
//                 patient.patientName,
//                 style: MyTextStyle.textStyleMap['label-medium']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//               subtitle: Text(
//                 '${patient.age}, ${patient.gender}',
//                 style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return widgets;
//   }

//   //------------------------------------------------------------------------//
//   void _deletePatient(Patient patient, String doctorName) async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Confirm Delete'),
//           content: Text(
//               'Are you sure you want to delete patient ${patient.patientName} permanently?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     try {
//       await widget.patientService.deletePatient(patient.patientId, doctorName);

//       handleSearchInput(_searchController.text);
//       // _fetchRecentPatients().then((recentPatientsData) {
//       //   setState(() {
//       //     recentPatients = recentPatientsData;
//       //   });
//       // });
//       _fetchInitialData();

//       scaffoldMessenger.showSnackBar(
//         SnackBar(content: Text('Patient ${patient.patientName} deleted')),
//       );
//     } catch (e) {
//       devtools.log('Error deleting patient: $e');
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(content: Text('Error deleting patient')),
//       );
//     }
//   }

//   void _deletePatientFromRecent(int index) async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     final patientId = recentPatients[index]['patientId'];
//     final patientName = recentPatients[index]['patientName'];

//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Confirm Delete'),
//           content: Text('Are you sure you want to delete $patientName?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     try {
//       await widget.patientService.deletePatient(patientId, widget.doctorName);

//       handleSearchInput(_searchController.text);
//       // _fetchRecentPatients().then((recentPatientsData) {
//       //   setState(() {
//       //     recentPatients = recentPatientsData;
//       //   });
//       // });
//       _fetchInitialData();

//       scaffoldMessenger.showSnackBar(
//         SnackBar(content: Text('Patient $patientName deleted')),
//       );
//     } catch (e) {
//       devtools.log('Error deleting patient: $e');
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(content: Text('Error deleting patient')),
//       );
//     }
//   }

//   // ------------------------------------------------------------------------ //

//   // ------------------------------------------------------------------------ //

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to SearchAndDisplayAllPatients!');
//     return Scaffold(
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: SizedBox(
//                     height: 40,
//                     child: TextField(
//                       controller: _searchController,
//                       onChanged: (value) {
//                         setState(() {
//                           hasUserInput = value.isNotEmpty;
//                         });
//                         handleSearchInput(value);
//                       },
//                       decoration: InputDecoration(
//                         labelText: 'Search Patient with name or phone number',
//                         labelStyle: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(
//                                 color: MyColors
//                                     .colorPalette['on-surface-variant']),
//                         prefixIcon: Icon(Icons.search,
//                             color: MyColors.colorPalette['on-surface-variant']),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(8.0),
//                           ),
//                           borderSide: BorderSide(
//                             color: MyColors.colorPalette['primary'] ??
//                                 Colors.black,
//                           ),
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(8.0),
//                           ),
//                           borderSide: BorderSide(
//                             color:
//                                 MyColors.colorPalette['on-surface-variant'] ??
//                                     Colors.black,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Recent Patients Section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Align(
//                     alignment: Alignment.topCenter,
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: MediaQuery.of(context).size.width * 0.1,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: recentPatients.map((patient) {
//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => TreatmentLandingScreen(
//                                     clinicId: widget.clinicId,
//                                     doctorId: widget.doctorId,
//                                     doctorName: widget.doctorName,
//                                     patientId: patient['patientId'],
//                                     patientName: patient['patientName'],
//                                     patientMobileNumber:
//                                         patient['patientMobileNumber'],
//                                     age: patient['age'],
//                                     gender: patient['gender'],
//                                     patientPicUrl: patient['patientPicUrl'],
//                                     uhid: patient['uhid'],
//                                   ),
//                                 ),
//                               );
//                             },
//                             onLongPress: () {
//                               _deletePatientFromRecent(
//                                   recentPatients.indexOf(patient));
//                             },
//                             child: Column(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 24,
//                                   backgroundColor:
//                                       MyColors.colorPalette['surface'],
//                                   backgroundImage: patient['patientPicUrl'] !=
//                                               null &&
//                                           patient['patientPicUrl'].isNotEmpty
//                                       ? NetworkImage(patient['patientPicUrl'])
//                                       : Image.asset(
//                                           'assets/images/default-image.png',
//                                           color:
//                                               MyColors.colorPalette['primary'],
//                                           colorBlendMode: BlendMode.color,
//                                         ).image,
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   patient['patientName'],
//                                   style: MyTextStyle.textStyleMap['label-small']
//                                       ?.copyWith(
//                                     color: MyColors.colorPalette['on_surface'],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // All Patients Section
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'All Patients',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                           color: MyColors.colorPalette['on-surface']),
//                     ),
//                   ),
//                 ),
//                 StreamBuilder<List<Patient>>(
//                   stream: hasUserInput
//                       ? matchingPatientsStream
//                       : widget.patientService.getAllPatientsRealTime(
//                           clinicId: ClinicSelection.instance.selectedClinicId,
//                         ),
//                   builder: (context, snapshot) {
//                     devtools.log('All Patients Snapshot Listener triggered');
//                     devtools.log('All Patients Retrieved: ${snapshot.data}');

//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const CircularProgressIndicator();
//                     } else if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     } else if (snapshot.data == null ||
//                         snapshot.data!.isEmpty) {
//                       return Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'No patients found',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on-surface-variant']),
//                         ),
//                       );
//                     } else {
//                       return Column(
//                         children: _buildPatientsList(snapshot.data!),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//     );
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// code below stable with direct implementation of CommonAppBar
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/common_app_bar.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/patient.dart';
// import 'package:neocare_dental_app/mywidgets/treatment_landing_screen.dart';
// import 'dart:developer' as devtools show log;

// class SearchAndDisplayAllPatients extends StatefulWidget {
//   final String clinicId;
//   final String doctorId;
//   final String doctorName;
//   final PatientService patientService;

//   const SearchAndDisplayAllPatients({
//     super.key,
//     required this.clinicId,
//     required this.doctorId,
//     required this.doctorName,
//     required this.patientService,
//   });

//   @override
//   State<SearchAndDisplayAllPatients> createState() =>
//       _SearchAndDisplayAllPatientsState();
// }

// class _SearchAndDisplayAllPatientsState
//     extends State<SearchAndDisplayAllPatients> {
//   final TextEditingController _searchController = TextEditingController();

//   List<Patient> matchingPatients = []; // Store matching patients

//   bool hasUserInput = false; // Track if the user has entered input
//   Patient? selectedPatient;
//   Stream<List<Patient>>? matchingPatientsStream;
//   // Define a GlobalKey for the navigator
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   //int _currentIndex = 3;
//   static const int defaultIndex = 3;
//   int _currentIndex = defaultIndex;

//   List<Map<String, dynamic>> recentPatients = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _searchController.text = '';

//     // Perform initial fetch with the currently selected clinic
//     _fetchInitialData();
//     matchingPatientsStream = widget.patientService.getAllPatientsRealTime(
//       clinicId: ClinicSelection.instance.selectedClinicId,
//     );

//     // Add listener for clinic changes
//     ClinicSelection.instance.addListener(_onClinicChanged);
//   }

//   //-------------------------------------------------------------------------//

//   @override
//   void dispose() {
//     _searchController.dispose();
//     ClinicSelection.instance.removeListener(_onClinicChanged);
//     super.dispose();
//   }

//   //------------------------------------------------------------------------//

//   void _onClinicChanged() {
//     final clinicId = ClinicSelection.instance.selectedClinicId;
//     if (clinicId.isEmpty) {
//       devtools.log('No clinic selected.');
//       return;
//     }

//     devtools.log('Clinic changed to: $clinicId');
//     widget.patientService.updateClinicId(clinicId);
//     handleSearchInput(''); // Update stream on clinic change
//     _fetchInitialData(); // Refresh data
//   }

//   //-----------------------------------------------------------------------//

//   Future<void> _fetchInitialData() async {
//     final clinicId = ClinicSelection.instance.selectedClinicId;

//     if (clinicId.isEmpty) {
//       devtools.log('No clinic selected.');
//       return;
//     }

//     if (mounted) {
//       setState(() {
//         _isLoading = true;
//       });
//     }

//     try {
//       devtools.log(
//           'Fetching recent patients and all patients for clinic: $clinicId');

//       // Fetch recent patients for the selected clinic
//       recentPatients = await widget.patientService.fetchRecentPatients(
//         clinicId: clinicId,
//       );

//       // Update the stream for all patients
//       matchingPatientsStream =
//           widget.patientService.getAllPatientsRealTime(clinicId: clinicId);

//       if (mounted) {
//         setState(() {}); // Trigger rebuild with updated stream
//       }
//     } catch (e) {
//       devtools.log('Error fetching patient data: $e');
//     } finally {
//       _stopLoading();
//     }
//   }

//   void _stopLoading() {
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   //-------------------------------------------------------------------------//

//   void handleSearchInput(String query) {
//     final clinicId = ClinicSelection.instance.selectedClinicId;

//     try {
//       if (query.isNotEmpty) {
//         matchingPatientsStream = widget.patientService.searchPatientsRealTime(
//           query,
//           clinicId,
//         );
//       } else {
//         matchingPatientsStream =
//             widget.patientService.getAllPatientsRealTime(clinicId: clinicId);
//       }
//       setState(() {}); // Trigger rebuild
//     } catch (e) {
//       devtools.log('Error handling search input: $e');
//     }
//   }

//   void handleSelectPatient(Patient patient) async {
//     widget.patientService.incrementSearchCount(patient.patientId);
//     setState(() {
//       selectedPatient = patient;
//     });

//     // Navigate to the TreatmentLandingScreen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TreatmentLandingScreen(
//           //clinicId: widget.clinicId,
//           clinicId: ClinicSelection.instance.selectedClinicId,
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           patientId: selectedPatient?.patientId ?? '',
//           patientName: selectedPatient?.patientName ?? '',
//           patientMobileNumber: selectedPatient?.patientMobileNumber ?? '',
//           age: selectedPatient?.age ?? 0,
//           gender: selectedPatient?.gender ?? '',
//           patientPicUrl: selectedPatient?.patientPicUrl ?? '',
//           uhid: selectedPatient?.uhid ?? '',
//         ),
//       ),
//     );

//     // Do any additional actions needed with the selected patient
//     devtools.log(
//         'This is coming from inside handleSelectPatient. Selected Patient: ${selectedPatient?.patientName}');

//     if (selectedPatient != null && selectedPatient!.patientId.isNotEmpty) {
//       try {
//         final patientId = selectedPatient!.patientId;
//         devtools.log('patientId of selectedPatient is $patientId');

//         // Increment the searchCount for the found patient
//         //await widget.patientService.incrementSearchCount(patientId);
//       } catch (e) {
//         devtools.log('Error incrementing searchCount: $e');
//       }
//     }
//   }

//   List<Widget> _buildPatientsList(List<Patient> patients) {
//     patients.sort((a, b) {
//       final patientNameA = a.patientName.trim().toLowerCase();
//       final patientNameB = b.patientName.trim().toLowerCase();
//       return patientNameA.compareTo(patientNameB);
//     });

//     List<Widget> widgets = [];
//     String currentAlphabet = '';

//     for (final patient in patients) {
//       final patientFirstChar = patient.patientName.isNotEmpty
//           ? patient.patientName[0].toUpperCase()
//           : '';

//       if (patientFirstChar != currentAlphabet) {
//         // Add a header widget with a bigger font size
//         widgets.add(
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 patientFirstChar,
//                 style: MyTextStyle.textStyleMap['headline-large']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         );
//         currentAlphabet = patientFirstChar;
//       }

//       // Add the patient ListTile wrapped with GestureDetector
//       widgets.add(
//         GestureDetector(
//           onTap: () {
//             handleSelectPatient(patient);
//           },
//           //-----------------------------------------------------------------//
//           onLongPress: () {
//             _deletePatient(patient, widget.doctorName);
//           },
//           //-----------------------------------------------------------------//
//           child: Card(
//             child: ListTile(
//               leading: CircleAvatar(
//                 radius: 24,
//                 backgroundColor: MyColors.colorPalette['surface'],
//                 backgroundImage: patient.patientPicUrl != null &&
//                         patient.patientPicUrl!.isNotEmpty
//                     ? NetworkImage(patient.patientPicUrl!)
//                     : Image.asset(
//                         'assets/images/default-image.png',
//                         color: MyColors.colorPalette['secondary'],
//                         colorBlendMode: BlendMode.color,
//                       ).image,
//               ),
//               title: Text(
//                 patient.patientName,
//                 style: MyTextStyle.textStyleMap['label-medium']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//               subtitle: Text(
//                 '${patient.age}, ${patient.gender}',
//                 style: MyTextStyle.textStyleMap['label-medium']?.copyWith(
//                     color: MyColors.colorPalette['on-surface-variant']),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return widgets;
//   }

//   //------------------------------------------------------------------------//
//   void _deletePatient(Patient patient, String doctorName) async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Confirm Delete'),
//           content: Text(
//               'Are you sure you want to delete patient ${patient.patientName} permanently?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     try {
//       await widget.patientService.deletePatient(patient.patientId, doctorName);

//       handleSearchInput(_searchController.text);
//       // _fetchRecentPatients().then((recentPatientsData) {
//       //   setState(() {
//       //     recentPatients = recentPatientsData;
//       //   });
//       // });
//       _fetchInitialData();

//       scaffoldMessenger.showSnackBar(
//         SnackBar(content: Text('Patient ${patient.patientName} deleted')),
//       );
//     } catch (e) {
//       devtools.log('Error deleting patient: $e');
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(content: Text('Error deleting patient')),
//       );
//     }
//   }

//   void _deletePatientFromRecent(int index) async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     final patientId = recentPatients[index]['patientId'];
//     final patientName = recentPatients[index]['patientName'];

//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Confirm Delete'),
//           content: Text('Are you sure you want to delete $patientName?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     try {
//       await widget.patientService.deletePatient(patientId, widget.doctorName);

//       handleSearchInput(_searchController.text);
//       // _fetchRecentPatients().then((recentPatientsData) {
//       //   setState(() {
//       //     recentPatients = recentPatientsData;
//       //   });
//       // });
//       _fetchInitialData();

//       scaffoldMessenger.showSnackBar(
//         SnackBar(content: Text('Patient $patientName deleted')),
//       );
//     } catch (e) {
//       devtools.log('Error deleting patient: $e');
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(content: Text('Error deleting patient')),
//       );
//     }
//   }

//   // ------------------------------------------------------------------------ //

//   // ------------------------------------------------------------------------ //

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('Welcome to SearchAndDisplayAllPatients!');
//     return Scaffold(
//       appBar: const CommonAppBar(
//         isLandingScreen: false,
//         additionalContent: null,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: SizedBox(
//                     height: 40,
//                     child: TextField(
//                       controller: _searchController,
//                       onChanged: (value) {
//                         setState(() {
//                           hasUserInput = value.isNotEmpty;
//                         });
//                         handleSearchInput(value);
//                       },
//                       decoration: InputDecoration(
//                         labelText: 'Search Patient with name or phone number',
//                         labelStyle: MyTextStyle.textStyleMap['label-large']
//                             ?.copyWith(
//                                 color: MyColors
//                                     .colorPalette['on-surface-variant']),
//                         prefixIcon: Icon(Icons.search,
//                             color: MyColors.colorPalette['on-surface-variant']),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(8.0),
//                           ),
//                           borderSide: BorderSide(
//                             color: MyColors.colorPalette['primary'] ??
//                                 Colors.black,
//                           ),
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(8.0),
//                           ),
//                           borderSide: BorderSide(
//                             color:
//                                 MyColors.colorPalette['on-surface-variant'] ??
//                                     Colors.black,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Recent Patients Section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Align(
//                     alignment: Alignment.topCenter,
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: MediaQuery.of(context).size.width * 0.1,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: recentPatients.map((patient) {
//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => TreatmentLandingScreen(
//                                     clinicId: widget.clinicId,
//                                     doctorId: widget.doctorId,
//                                     doctorName: widget.doctorName,
//                                     patientId: patient['patientId'],
//                                     patientName: patient['patientName'],
//                                     patientMobileNumber:
//                                         patient['patientMobileNumber'],
//                                     age: patient['age'],
//                                     gender: patient['gender'],
//                                     patientPicUrl: patient['patientPicUrl'],
//                                     uhid: patient['uhid'],
//                                   ),
//                                 ),
//                               );
//                             },
//                             onLongPress: () {
//                               _deletePatientFromRecent(
//                                   recentPatients.indexOf(patient));
//                             },
//                             child: Column(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 24,
//                                   backgroundColor:
//                                       MyColors.colorPalette['surface'],
//                                   backgroundImage: patient['patientPicUrl'] !=
//                                               null &&
//                                           patient['patientPicUrl'].isNotEmpty
//                                       ? NetworkImage(patient['patientPicUrl'])
//                                       : Image.asset(
//                                           'assets/images/default-image.png',
//                                           color:
//                                               MyColors.colorPalette['primary'],
//                                           colorBlendMode: BlendMode.color,
//                                         ).image,
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   patient['patientName'],
//                                   style: MyTextStyle.textStyleMap['label-small']
//                                       ?.copyWith(
//                                     color: MyColors.colorPalette['on_surface'],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // All Patients Section
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'All Patients',
//                       style: MyTextStyle.textStyleMap['title-large']?.copyWith(
//                           color: MyColors.colorPalette['on-surface']),
//                     ),
//                   ),
//                 ),
//                 StreamBuilder<List<Patient>>(
//                   stream: hasUserInput
//                       ? matchingPatientsStream
//                       : widget.patientService.getAllPatientsRealTime(
//                           clinicId: ClinicSelection.instance.selectedClinicId,
//                         ),
//                   builder: (context, snapshot) {
//                     devtools.log('All Patients Snapshot Listener triggered');
//                     devtools.log('All Patients Retrieved: ${snapshot.data}');

//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const CircularProgressIndicator();
//                     } else if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     } else if (snapshot.data == null ||
//                         snapshot.data!.isEmpty) {
//                       return Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'No patients found',
//                           style: MyTextStyle.textStyleMap['label-large']
//                               ?.copyWith(
//                                   color: MyColors
//                                       .colorPalette['on-surface-variant']),
//                         ),
//                       );
//                     } else {
//                       return Column(
//                         children: _buildPatientsList(snapshot.data!),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//     );
//   }
// }
