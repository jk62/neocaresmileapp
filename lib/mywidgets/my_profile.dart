import 'dart:io';

import 'package:flutter/material.dart';
import 'package:neocaresmileapp/constants/routes.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import 'package:neocaresmileapp/mywidgets/add_consultation_fee.dart';
import 'package:neocaresmileapp/mywidgets/add_condition.dart';
import 'package:neocaresmileapp/mywidgets/add_medical_history_condition.dart';
import 'package:neocaresmileapp/mywidgets/add_medicine.dart';
import 'package:neocaresmileapp/mywidgets/add_pre_defined_course.dart';
import 'package:neocaresmileapp/mywidgets/add_procedure.dart';
import 'package:neocaresmileapp/mywidgets/add_template.dart';
import 'package:neocaresmileapp/mywidgets/appointment_provider.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/common_app_bar.dart';
import 'package:neocaresmileapp/mywidgets/create_slots.dart';
import 'package:neocaresmileapp/mywidgets/create_user_widget.dart';
import 'package:neocaresmileapp/mywidgets/doctor_slots.dart';
import 'package:neocaresmileapp/mywidgets/manage_slots.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/replicate_condition_data.dart';
import 'package:neocaresmileapp/mywidgets/replicate_medical_history_condition_data.dart';
import 'package:neocaresmileapp/mywidgets/replicate_medicine_data.dart';
import 'package:neocaresmileapp/mywidgets/replicate_procedure_data.dart';
import 'package:neocaresmileapp/services/auth/auth_services.dart';
import 'package:neocaresmileapp/services/auth/firebase_auth_provider.dart';
import 'package:neocaresmileapp/services/bloc/auth_bloc.dart';
import 'package:neocaresmileapp/services/bloc/auth_event.dart';
import 'package:neocaresmileapp/views/change_password_view.dart';

import 'dart:developer' as devtools show log;

import 'package:provider/provider.dart';

class MyProfile extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String clinicId;
  //final PatientService patientService;

  const MyProfile({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
    //required this.patientService,
  });

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  //static const int defaultIndex = 1;
  //final int _currentIndex = defaultIndex;

  // The authorized user's UUID
  static const String authorizedUserUUID = 'YjcYxTavSybLpldQaWSmAQe2RAj2';

  // ------------------------------------------------------------------------- //
  @override
  void initState() {
    super.initState();

    // Register a listener for clinic changes
    ClinicSelection.instance.addListener(_onClinicChanged);

    // Fetch initial data for the selected clinic
    _fetchDataForClinic(ClinicSelection.instance.selectedClinicId);
  }

  @override
  void dispose() {
    // Remove the listener to prevent memory leaks
    ClinicSelection.instance.removeListener(_onClinicChanged);
    super.dispose();
  }

// This method gets called when the selected clinic changes
  void _onClinicChanged() {
    devtools.log(
        'Clinic changed to: ${ClinicSelection.instance.selectedClinicName}');

    // Fetch data for the newly selected clinic
    _fetchDataForClinic(ClinicSelection.instance.selectedClinicId);
  }

  // Fetch data based on the selected clinic
  // Future<void> _fetchDataForClinic(String clinicId) async {
  //   if (clinicId.isEmpty) return;

  //   try {
  //     devtools.log('Fetching data for clinic: $clinicId');
  //     // Example: Fetch recent patients for the selected clinic
  //     await widget.patientService.fetchRecentPatients(clinicId: clinicId);

  //     setState(() {
  //       // Update the state as needed after fetching data
  //     });
  //   } catch (e) {
  //     devtools.log('Error fetching data for clinic: $e');
  //   }
  // }

  Future<void> _fetchDataForClinic(String clinicId) async {
    if (clinicId.isEmpty) return;

    try {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);

      devtools.log('Fetching data for clinic: $clinicId');
      // Example: Fetch recent patients for the selected clinic
      await appointmentProvider.patientService.fetchRecentPatients(
        clinicId: clinicId,
      );

      setState(() {
        // Update the state as needed after fetching data
      });
    } catch (e) {
      devtools.log('Error fetching data for clinic: $e');
    }
  }
  // ------------------------------------------------------------------------- //

  // void _performLogout(BuildContext context) async {
  //   try {
  //     AuthService authService = AuthService(FirebaseAuthProvider());
  //     await authService.logOut(); // Async operation

  //     if (mounted) {
  //       Navigator.pushReplacementNamed(
  //           context, loginRoute); // Safe to use context
  //     }
  //   } catch (e) {
  //     devtools.log('Logout failed: $e');
  //   }
  // }

  // void _performLogout(BuildContext context) async {
  //   try {
  //     // 1. Instantiate the authentication service using FirebaseAuthProvider.
  //     AuthService authService = AuthService(FirebaseAuthProvider());

  //     // 2. Call the logOut() method and wait for it to complete.
  //     await authService.logOut();

  //     // 3. After the user is logged out, clear the entire navigation stack and
  //     // push the login route.
  //     if (mounted) {
  //       Navigator.pushNamedAndRemoveUntil(
  //         context,
  //         loginRoute,
  //         (Route<dynamic> route) => false,
  //       );
  //     }
  //   } catch (e) {
  //     // Log any errors that occur during logout.
  //     devtools.log('Logout failed: $e');
  //   }
  // }

  // In MyProfile widget

  // void _performLogout(BuildContext context) {
  //   // Get the AuthBloc instance from the context
  //   // Make sure AuthBloc is provided above MyProfile in the widget tree (which it is via main.dart)
  //   try {
  //     context.read<AuthBloc>().add(const AuthEventLogOut());
  //     // The BlocBuilder in main.dart will handle the navigation
  //     // by rebuilding with LoginView when it receives AuthStateLoggedOut
  //   } catch (e) {
  //     // Handle potential errors if context.read fails (unlikely here)
  //     devtools.log('Error dispatching logout event: $e');
  //     // Optionally show an error message to the user
  //   }

  // }

  // void _performLogin(BuildContext context) {
  //   Navigator.pushReplacementNamed(context, loginRoute);
  // }

  void _navigateToChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordView(),
      ),
    );
  }

  // void _navigateToDoctorSlots(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => DoctorSlots(
  //         clinicId: widget.clinicId,
  //       ),
  //     ),
  //   );
  // }

  void _navigateToDoctorSlots(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorSlots(
          clinicId:
              ClinicSelection.instance.selectedClinicId, // dynamic clinic ID
        ),
      ),
    );
  }

  void _navigateToAddMedicine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicine(
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
          clinicId: widget.clinicId,
        ),
      ),
    );
  }

  // void _navigateToAddProcedure(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => AddProcedure(
  //         clinicId: widget.clinicId,
  //         doctorName: widget.doctorName,
  //         doctorId: widget.doctorId,
  //       ),
  //     ),
  //   );
  // }

  void _navigateToAddProcedure(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProcedure(
          clinicId: ClinicSelection
              .instance.selectedClinicId, // Use selected clinic ID
          doctorName: widget.doctorName,
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  void _navigateToAddPreDefinedCourse(BuildContext context) {
    String selectedClinicId = ClinicSelection.instance.selectedClinicId;
    devtools.log(
        "Navigating to AddPreDefinedCourse with clinicId: $selectedClinicId");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPreDefinedCourse(
          clinicId: selectedClinicId,
          doctorName: widget.doctorName,
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  void _navigateToAddTemplate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTemplate(
          clinicId: widget.clinicId,
          doctorName: widget.doctorName,
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  // void _navigateToAddCondition(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => AddExaminationCondition(
  //         clinicId: widget.clinicId,
  //         doctorName: widget.doctorName,
  //         doctorId: widget.doctorId,
  //       ),
  //     ),
  //   );
  // }

  void _navigateToAddCondition(BuildContext context) {
    String selectedClinicId = ClinicSelection.instance.selectedClinicId;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExaminationCondition(
          clinicId: selectedClinicId, // Use dynamic clinic ID
          doctorName: widget.doctorName,
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  // void _navigateToAddConsultationFee(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => AddConsultationFee(
  //         clinicId: widget.clinicId,
  //         doctorName: widget.doctorName,
  //         doctorId: widget.doctorId,
  //       ),
  //     ),
  //   );
  // }

  void _navigateToAddConsultationFee(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddConsultationFee(
          clinicId: ClinicSelection
              .instance.selectedClinicId, // Use dynamic clinic ID
          doctorName: widget.doctorName,
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  void _navigateToCreateUserWidget(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateUserWidget(),
      ),
    );
  }

  void _navigateToAddMedicalHisotryCondition(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicalHistoryCondition(
          //clinicId: widget.clinicId,
          clinicId: ClinicSelection.instance.selectedClinicId,
          doctorName: widget.doctorName,
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  //-------------------------//

  void _navigateToReplicateMedicineData(BuildContext context, String clinicId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReplicateMedicineData(initialSourceClinicId: clinicId),
      ),
    );
  }

  //-------------------------//
  void _navigateToCreateClinicSlots(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSlots(
          clinicId: ClinicSelection.instance.selectedClinicId,
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
        ),
      ),
    );
  }

  //-----------------------------//
  void _navigateToReplicateConditionData(
      BuildContext context, String clinicId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReplicateConditionData(initialSourceClinicId: clinicId),
      ),
    );
  }

  //-------------------------------------//
  void _navigateToReplicateProcedureData(
      BuildContext context, String clinicId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReplicateProcedureData(initialSourceClinicId: clinicId),
      ),
    );
  }

  //-------------------------------------//
  void _navigateToReplicateMedicalHistoryConditionData(
      BuildContext context, String clinicId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReplicateMedicalHistoryConditionData(
            initialSourceClinicId: clinicId),
      ),
    );
  }
  //----------------------------------------------------------------------//

//   void _showScrollableMenu(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(height: 10),
//                 const Text(
//                   'Menu Options',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const Divider(),
//                 ..._buildMenuListTiles(context),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   List<Widget> _buildMenuListTiles(BuildContext context) {
//     return [
//       _buildListTile('Logout', () => _performLogout(context)),
//       _buildListTile('Login', () => _performLogin(context)),
//       _buildListTile(
//           'Change Password', () => _navigateToChangePassword(context)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile('Doctor Slots', () => _navigateToDoctorSlots(context)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile('Add Medicine', () => _navigateToAddMedicine(context)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile('Add Procedure', () => _navigateToAddProcedure(context)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile('Add Pre Defined Course',
//             () => _navigateToAddPreDefinedCourse(context)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile('Add Template', () => _navigateToAddTemplate(context)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile('Add Condition', () => _navigateToAddCondition(context)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile('Add Consultation Fee',
//             () => _navigateToAddConsultationFee(context)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile(
//             'Create New User', () => _navigateToCreateUserWidget(context)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile('Add Medical Condition',
//             () => _navigateToAddMedicalHisotryCondition(context)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile('Replicate Medicine Data',
//             () => _navigateToReplicateMedicineData(context, widget.clinicId)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile(
//             'Create Clinic Slots', () => _navigateToCreateClinicSlots(context)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile('Replicate Condition Data',
//             () => _navigateToReplicateConditionData(context, widget.clinicId)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile('Replicate Procedure Data',
//             () => _navigateToReplicateProcedureData(context, widget.clinicId)),
//       if (widget.doctorId == authorizedUserUUID)
//         _buildListTile(
//             'Replicate Medical Condition Data',
//             () => _navigateToReplicateMedicalHistoryConditionData(
//                 context, widget.clinicId)),
//     ];
//   }

//   Widget _buildListTile(String title, VoidCallback onTap) {
//     return Column(
//       children: [
//         ListTile(
//           title: Text(title),
//           onTap: onTap,
//         ),
//         const Divider(),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CommonAppBar(
//         backgroundImage: 'assets/images/img1.png',
//         isLandingScreen: false,
//         additionalContent: null,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: MyColors.colorPalette['primary'],
//             ),
//             const SizedBox(height: 16),
//             Align(
//               alignment: Alignment.center,
//               child: Text(
//                 'Hi  ${widget.doctorName} !',
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => _showScrollableMenu(context),
//               child: const Text('Show Menu'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

  //-----------------------------------------------------------------------------//
  // Build the custom scrollable popup menu
  void _showScrollableMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Menu Options',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ..._buildPopupMenuItems(context),
              ],
            ),
          ),
        );
      },
    );
  }

  // Generate the list of menu items
  List<Widget> _buildPopupMenuItems(BuildContext context) {
    return [
      //===========================================================//

      PopupMenuItem(
        child: const Text('Logout'),
        onTap: () {
          // Can be synchronous now

          // 1. Dispatch the event to tell the Bloc to start logging out Firebase
          //    This happens in the background.
          devtools.log(
              'Dispatching AuthEventLogOut from MyProfile (immediate dialog follows)');
          context.read<AuthBloc>().add(const AuthEventLogOut());

          // 2. Immediately show the confirmation dialog.
          //    We are NOT waiting for the AuthStateLoggedOut state here.
          //    This dialog appears *while* the Bloc is processing the logout.
          showDialog<void>(
            context: context, // Use the context from MyProfile
            barrierDismissible: false, // User must tap OK
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text(
                    'Logout Requested'), // Title reflects action initiated
                content: const Text(
                  'You will be logged out.\nPress OK to exit the App.',
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      devtools.log('OK pressed on logout dialog. Exiting app.');
                      // Exit the application directly from the dialog.
                      // This prevents the app from hitting the "used after disposed" error
                      // that would occur if it tried to rebuild based on AuthStateLoggedOut
                      // with the original main.dart structure.
                      exit(0);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      //===========================================================//
      // PopupMenuItem(
      //   child: const Text('Login'),
      //   onTap: () {
      //     WidgetsBinding.instance.addPostFrameCallback((_) {
      //       _performLogin(context);
      //     });
      //   },
      // ),
      PopupMenuItem(
        child: const Text('Change Password'),
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToChangePassword(context);
          });
        },
      ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Doctor Slots'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToDoctorSlots(context);
            });
          },
        ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Add Medicine'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToAddMedicine(context);
            });
          },
        ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Add Procedure'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToAddProcedure(context);
            });
          },
        ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Add Pre Defined Course'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToAddPreDefinedCourse(context);
            });
          },
        ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Add Template'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToAddTemplate(context);
            });
          },
        ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Add Condition'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToAddCondition(context);
            });
          },
        ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Add Consultation Fee'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToAddConsultationFee(
                  context); // Now uses dynamic clinic ID
            });
          },
        ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Create New User'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToCreateUserWidget(context);
            });
          },
        ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Add Medical Condition'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToAddMedicalHisotryCondition(context);
            });
          },
        ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Create Clinic Slots'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToCreateClinicSlots(context);
            });
          },
        ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Replicate Medicine Data'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToReplicateMedicineData(
                  context, widget.clinicId); // Use widget.clinicId here
            });
          },
        ),
      // if (widget.doctorId == authorizedUserUUID)
      //   PopupMenuItem(
      //     child: const Text('Create Clinic Slots'),
      //     onTap: () {
      //       WidgetsBinding.instance.addPostFrameCallback((_) {
      //         _navigateToCreateClinicSlots(context);
      //       });
      //     },
      //   ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Replicate Condition Data'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToReplicateConditionData(
                  context, widget.clinicId); // Use widget.clinicId here
            });
          },
        ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Replicate Procedure Data'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToReplicateProcedureData(
                  context, widget.clinicId); // Use widget.clinicId here
            });
          },
        ),
      if (widget.doctorId == authorizedUserUUID)
        PopupMenuItem(
          child: const Text('Replicate Medical Condition Data'),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToReplicateMedicalHistoryConditionData(
                  context, widget.clinicId);
            });
          },
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: MyColors.colorPalette['primary'],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Hi  ${widget.doctorName} !',
                style: MyTextStyle.textStyleMap['title-large']
                    ?.copyWith(color: MyColors.colorPalette['on-surface']),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showScrollableMenu(context),
              child: const Text('Show Menu'),
            ),
          ],
        ),
      ),
    );
  }
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// #############################################################################//
// import 'package:flutter/material.dart';
// import 'package:neocare_dental_app/constants/routes.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/mywidgets/add_consultation_fee.dart';
// import 'package:neocare_dental_app/mywidgets/add_condition.dart';
// import 'package:neocare_dental_app/mywidgets/add_medical_history_condition.dart';
// import 'package:neocare_dental_app/mywidgets/add_medicine.dart';
// import 'package:neocare_dental_app/mywidgets/add_pre_defined_course.dart';
// import 'package:neocare_dental_app/mywidgets/add_procedure.dart';
// import 'package:neocare_dental_app/mywidgets/add_template.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/common_app_bar.dart';
// import 'package:neocare_dental_app/mywidgets/create_slots.dart';
// import 'package:neocare_dental_app/mywidgets/create_user_widget.dart';
// import 'package:neocare_dental_app/mywidgets/doctor_slots.dart';
// import 'package:neocare_dental_app/mywidgets/manage_slots.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/replicate_condition_data.dart';
// import 'package:neocare_dental_app/mywidgets/replicate_medical_history_condition_data.dart';
// import 'package:neocare_dental_app/mywidgets/replicate_medicine_data.dart';
// import 'package:neocare_dental_app/mywidgets/replicate_procedure_data.dart';
// import 'package:neocare_dental_app/services/auth/auth_services.dart';
// import 'package:neocare_dental_app/services/auth/firebase_auth_provider.dart';
// import 'package:neocare_dental_app/views/change_password_view.dart';

// import 'dart:developer' as devtools show log;

// class MyProfile extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String clinicId;
//   final PatientService patientService;

//   const MyProfile({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.clinicId,
//     required this.patientService,
//   });

//   @override
//   State<MyProfile> createState() => _MyProfileState();
// }

// class _MyProfileState extends State<MyProfile> {
//   //static const int defaultIndex = 1;
//   //final int _currentIndex = defaultIndex;

//   // The authorized user's UUID
//   static const String authorizedUserUUID = 'YjcYxTavSybLpldQaWSmAQe2RAj2';

//   // ------------------------------------------------------------------------- //
//   @override
//   void initState() {
//     super.initState();

//     // Register a listener for clinic changes
//     ClinicSelection.instance.addListener(_onClinicChanged);

//     // Fetch initial data for the selected clinic
//     _fetchDataForClinic(ClinicSelection.instance.selectedClinicId);
//   }

//   @override
//   void dispose() {
//     // Remove the listener to prevent memory leaks
//     ClinicSelection.instance.removeListener(_onClinicChanged);
//     super.dispose();
//   }

// // This method gets called when the selected clinic changes
//   void _onClinicChanged() {
//     devtools.log(
//         'Clinic changed to: ${ClinicSelection.instance.selectedClinicName}');

//     // Fetch data for the newly selected clinic
//     _fetchDataForClinic(ClinicSelection.instance.selectedClinicId);
//   }

//   // Fetch data based on the selected clinic
//   Future<void> _fetchDataForClinic(String clinicId) async {
//     if (clinicId.isEmpty) return;

//     try {
//       devtools.log('Fetching data for clinic: $clinicId');
//       // Example: Fetch recent patients for the selected clinic
//       await widget.patientService.fetchRecentPatients(clinicId: clinicId);

//       setState(() {
//         // Update the state as needed after fetching data
//       });
//     } catch (e) {
//       devtools.log('Error fetching data for clinic: $e');
//     }
//   }
//   // ------------------------------------------------------------------------- //

//   void _performLogout(BuildContext context) async {
//     try {
//       AuthService authService = AuthService(FirebaseAuthProvider());
//       await authService.logOut(); // Async operation

//       if (mounted) {
//         Navigator.pushReplacementNamed(
//             context, loginRoute); // Safe to use context
//       }
//     } catch (e) {
//       devtools.log('Logout failed: $e');
//     }
//   }

//   void _performLogin(BuildContext context) {
//     Navigator.pushReplacementNamed(context, loginRoute);
//   }

//   void _navigateToChangePassword(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const ChangePasswordView(),
//       ),
//     );
//   }

//   // void _navigateToDoctorSlots(BuildContext context) {
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => DoctorSlots(
//   //         clinicId: widget.clinicId,
//   //       ),
//   //     ),
//   //   );
//   // }

//   void _navigateToDoctorSlots(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => DoctorSlots(
//           clinicId:
//               ClinicSelection.instance.selectedClinicId, // dynamic clinic ID
//         ),
//       ),
//     );
//   }

//   void _navigateToAddMedicine(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddMedicine(
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//           clinicId: widget.clinicId,
//         ),
//       ),
//     );
//   }

//   // void _navigateToAddProcedure(BuildContext context) {
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => AddProcedure(
//   //         clinicId: widget.clinicId,
//   //         doctorName: widget.doctorName,
//   //         doctorId: widget.doctorId,
//   //       ),
//   //     ),
//   //   );
//   // }

//   void _navigateToAddProcedure(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddProcedure(
//           clinicId: ClinicSelection
//               .instance.selectedClinicId, // Use selected clinic ID
//           doctorName: widget.doctorName,
//           doctorId: widget.doctorId,
//         ),
//       ),
//     );
//   }

//   void _navigateToAddPreDefinedCourse(BuildContext context) {
//     String selectedClinicId = ClinicSelection.instance.selectedClinicId;
//     devtools.log(
//         "Navigating to AddPreDefinedCourse with clinicId: $selectedClinicId");

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddPreDefinedCourse(
//           clinicId: selectedClinicId,
//           doctorName: widget.doctorName,
//           doctorId: widget.doctorId,
//         ),
//       ),
//     );
//   }

//   void _navigateToAddTemplate(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddTemplate(
//           clinicId: widget.clinicId,
//           doctorName: widget.doctorName,
//           doctorId: widget.doctorId,
//         ),
//       ),
//     );
//   }

//   // void _navigateToAddCondition(BuildContext context) {
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => AddExaminationCondition(
//   //         clinicId: widget.clinicId,
//   //         doctorName: widget.doctorName,
//   //         doctorId: widget.doctorId,
//   //       ),
//   //     ),
//   //   );
//   // }

//   void _navigateToAddCondition(BuildContext context) {
//     String selectedClinicId = ClinicSelection.instance.selectedClinicId;

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddExaminationCondition(
//           clinicId: selectedClinicId, // Use dynamic clinic ID
//           doctorName: widget.doctorName,
//           doctorId: widget.doctorId,
//         ),
//       ),
//     );
//   }

//   // void _navigateToAddConsultationFee(BuildContext context) {
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => AddConsultationFee(
//   //         clinicId: widget.clinicId,
//   //         doctorName: widget.doctorName,
//   //         doctorId: widget.doctorId,
//   //       ),
//   //     ),
//   //   );
//   // }

//   void _navigateToAddConsultationFee(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddConsultationFee(
//           clinicId: ClinicSelection
//               .instance.selectedClinicId, // Use dynamic clinic ID
//           doctorName: widget.doctorName,
//           doctorId: widget.doctorId,
//         ),
//       ),
//     );
//   }

//   void _navigateToCreateUserWidget(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const CreateUserWidget(),
//       ),
//     );
//   }

//   void _navigateToAddMedicalHisotryCondition(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddMedicalHistoryCondition(
//           //clinicId: widget.clinicId,
//           clinicId: ClinicSelection.instance.selectedClinicId,
//           doctorName: widget.doctorName,
//           doctorId: widget.doctorId,
//         ),
//       ),
//     );
//   }

//   //-------------------------//

//   void _navigateToReplicateMedicineData(BuildContext context, String clinicId) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             ReplicateMedicineData(initialSourceClinicId: clinicId),
//       ),
//     );
//   }

//   //-------------------------//
//   void _navigateToCreateClinicSlots(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CreateSlots(
//           clinicId: ClinicSelection.instance.selectedClinicId,
//           doctorId: widget.doctorId,
//           doctorName: widget.doctorName,
//         ),
//       ),
//     );
//   }

//   //-----------------------------//
//   void _navigateToReplicateConditionData(
//       BuildContext context, String clinicId) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             ReplicateConditionData(initialSourceClinicId: clinicId),
//       ),
//     );
//   }

//   //-------------------------------------//
//   void _navigateToReplicateProcedureData(
//       BuildContext context, String clinicId) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             ReplicateProcedureData(initialSourceClinicId: clinicId),
//       ),
//     );
//   }

//   //-------------------------------------//
//   void _navigateToReplicateMedicalHistoryConditionData(
//       BuildContext context, String clinicId) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ReplicateMedicalHistoryConditionData(
//             initialSourceClinicId: clinicId),
//       ),
//     );
//   }
//   //----------------------------------------------------------------------//

// //   void _showScrollableMenu(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return Dialog(
// //           child: SingleChildScrollView(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 const SizedBox(height: 10),
// //                 const Text(
// //                   'Menu Options',
// //                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //                 ),
// //                 const Divider(),
// //                 ..._buildMenuListTiles(context),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   List<Widget> _buildMenuListTiles(BuildContext context) {
// //     return [
// //       _buildListTile('Logout', () => _performLogout(context)),
// //       _buildListTile('Login', () => _performLogin(context)),
// //       _buildListTile(
// //           'Change Password', () => _navigateToChangePassword(context)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile('Doctor Slots', () => _navigateToDoctorSlots(context)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile('Add Medicine', () => _navigateToAddMedicine(context)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile('Add Procedure', () => _navigateToAddProcedure(context)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile('Add Pre Defined Course',
// //             () => _navigateToAddPreDefinedCourse(context)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile('Add Template', () => _navigateToAddTemplate(context)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile('Add Condition', () => _navigateToAddCondition(context)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile('Add Consultation Fee',
// //             () => _navigateToAddConsultationFee(context)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile(
// //             'Create New User', () => _navigateToCreateUserWidget(context)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile('Add Medical Condition',
// //             () => _navigateToAddMedicalHisotryCondition(context)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile('Replicate Medicine Data',
// //             () => _navigateToReplicateMedicineData(context, widget.clinicId)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile(
// //             'Create Clinic Slots', () => _navigateToCreateClinicSlots(context)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile('Replicate Condition Data',
// //             () => _navigateToReplicateConditionData(context, widget.clinicId)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile('Replicate Procedure Data',
// //             () => _navigateToReplicateProcedureData(context, widget.clinicId)),
// //       if (widget.doctorId == authorizedUserUUID)
// //         _buildListTile(
// //             'Replicate Medical Condition Data',
// //             () => _navigateToReplicateMedicalHistoryConditionData(
// //                 context, widget.clinicId)),
// //     ];
// //   }

// //   Widget _buildListTile(String title, VoidCallback onTap) {
// //     return Column(
// //       children: [
// //         ListTile(
// //           title: Text(title),
// //           onTap: onTap,
// //         ),
// //         const Divider(),
// //       ],
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: const CommonAppBar(
// //         backgroundImage: 'assets/images/img1.png',
// //         isLandingScreen: false,
// //         additionalContent: null,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(8.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             CircleAvatar(
// //               radius: 30,
// //               backgroundColor: MyColors.colorPalette['primary'],
// //             ),
// //             const SizedBox(height: 16),
// //             Align(
// //               alignment: Alignment.center,
// //               child: Text(
// //                 'Hi  ${widget.doctorName} !',
// //                 style: MyTextStyle.textStyleMap['title-large']
// //                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //             ElevatedButton(
// //               onPressed: () => _showScrollableMenu(context),
// //               child: const Text('Show Menu'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

//   //-----------------------------------------------------------------------------//
//   // Build the custom scrollable popup menu
//   void _showScrollableMenu(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(height: 10),
//                 const Text(
//                   'Menu Options',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const Divider(),
//                 ..._buildPopupMenuItems(context),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Generate the list of menu items
//   List<Widget> _buildPopupMenuItems(BuildContext context) {
//     return [
//       PopupMenuItem(
//         child: const Text('Logout'),
//         onTap: () {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _performLogout(context);
//           });
//         },
//       ),
//       PopupMenuItem(
//         child: const Text('Login'),
//         onTap: () {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _performLogin(context);
//           });
//         },
//       ),
//       PopupMenuItem(
//         child: const Text('Change Password'),
//         onTap: () {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _navigateToChangePassword(context);
//           });
//         },
//       ),
//       if (widget.doctorId == authorizedUserUUID)
//         PopupMenuItem(
//           child: const Text('Doctor Slots'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToDoctorSlots(context);
//             });
//           },
//         ),
//       if (widget.doctorId == authorizedUserUUID)
//         PopupMenuItem(
//           child: const Text('Add Medicine'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToAddMedicine(context);
//             });
//           },
//         ),
//       if (widget.doctorId == authorizedUserUUID)
//         PopupMenuItem(
//           child: const Text('Add Procedure'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToAddProcedure(context);
//             });
//           },
//         ),
//       if (widget.doctorId == authorizedUserUUID)
//         PopupMenuItem(
//           child: const Text('Add Pre Defined Course'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToAddPreDefinedCourse(context);
//             });
//           },
//         ),
//       if (widget.doctorId == authorizedUserUUID)
//         PopupMenuItem(
//           child: const Text('Add Template'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToAddTemplate(context);
//             });
//           },
//         ),
//       if (widget.doctorId == authorizedUserUUID)
//         PopupMenuItem(
//           child: const Text('Add Condition'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToAddCondition(context);
//             });
//           },
//         ),
//       if (widget.doctorId == authorizedUserUUID)
        
//         PopupMenuItem(
//           child: const Text('Add Consultation Fee'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToAddConsultationFee(
//                   context); // Now uses dynamic clinic ID
//             });
//           },
//         ),
//       if (widget.doctorId == authorizedUserUUID)
//         PopupMenuItem(
//           child: const Text('Create New User'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToCreateUserWidget(context);
//             });
//           },
//         ),
//       if (widget.doctorId == authorizedUserUUID)
//         PopupMenuItem(
//           child: const Text('Add Medical Condition'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToAddMedicalHisotryCondition(context);
//             });
//           },
//         ),
//       if (widget.doctorId == authorizedUserUUID)
//         PopupMenuItem(
//           child: const Text('Create Clinic Slots'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToCreateClinicSlots(context);
//             });
//           },
//         ),
//       if (widget.doctorId == authorizedUserUUID)
//         PopupMenuItem(
//           child: const Text('Replicate Medicine Data'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToReplicateMedicineData(
//                   context, widget.clinicId); // Use widget.clinicId here
//             });
//           },
//         ),
//       // if (widget.doctorId == authorizedUserUUID)
//       //   PopupMenuItem(
//       //     child: const Text('Create Clinic Slots'),
//       //     onTap: () {
//       //       WidgetsBinding.instance.addPostFrameCallback((_) {
//       //         _navigateToCreateClinicSlots(context);
//       //       });
//       //     },
//       //   ),
//       if (widget.doctorId == authorizedUserUUID)
//         PopupMenuItem(
//           child: const Text('Replicate Condition Data'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToReplicateConditionData(
//                   context, widget.clinicId); // Use widget.clinicId here
//             });
//           },
//         ),
//       if (widget.doctorId == authorizedUserUUID)
//         PopupMenuItem(
//           child: const Text('Replicate Procedure Data'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToReplicateProcedureData(
//                   context, widget.clinicId); // Use widget.clinicId here
//             });
//           },
//         ),
//       if (widget.doctorId == authorizedUserUUID)
//         PopupMenuItem(
//           child: const Text('Replicate Medical Condition Data'),
//           onTap: () {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _navigateToReplicateMedicalHistoryConditionData(
//                   context, widget.clinicId);
//             });
//           },
//         ),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: MyColors.colorPalette['primary'],
//             ),
//             const SizedBox(height: 16),
//             Align(
//               alignment: Alignment.center,
//               child: Text(
//                 'Hi  ${widget.doctorName} !',
//                 style: MyTextStyle.textStyleMap['title-large']
//                     ?.copyWith(color: MyColors.colorPalette['on-surface']),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => _showScrollableMenu(context),
//               child: const Text('Show Menu'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

  //----------------------------------------------------------------------------//
