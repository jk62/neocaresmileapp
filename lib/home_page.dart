import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neocaresmileapp/firestore/clinic_service.dart';
import 'package:neocaresmileapp/firestore/patient_service.dart';
import 'package:neocaresmileapp/landing_screen.dart';
import 'package:neocaresmileapp/mywidgets/add_new_patient.dart';
import 'package:neocaresmileapp/mywidgets/appointment_provider.dart';
import 'package:neocaresmileapp/mywidgets/book_appointment.dart';
import 'package:neocaresmileapp/mywidgets/calender_view.dart';
import 'package:neocaresmileapp/mywidgets/clinic_selection.dart';
import 'package:neocaresmileapp/mywidgets/common_app_bar.dart';
import 'package:neocaresmileapp/mywidgets/custom_route_observer.dart';
import 'package:neocaresmileapp/mywidgets/my_profile.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'package:neocaresmileapp/mywidgets/recent_patient_provider.dart';
import 'package:neocaresmileapp/mywidgets/search_and_display_all_patients.dart';
import 'dart:developer' as devtools show log;
import 'package:neocaresmileapp/mywidgets/ui_calendar_slots.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? doctorData;
  const HomePage({super.key, required this.doctorData});

  @override
  State<HomePage> createState() => HomePageState();
}

//-----------------------------------------------------------------------//
class HomePageState extends State<HomePage> with RouteAware {
  bool _isOverlayVisible = false;
  int _currentIndex = 0;

  //-----------------------------//
  // Add a public getter and setter for _currentIndex
  int get currentIndex => _currentIndex;

  set currentIndex(int value) {
    setState(() {
      _currentIndex = value;
    });
  }

  @override
  void dispose() {
    // Unsubscribe from RouteObserver
    CustomRouteObserver.routeObserver.unsubscribe(this);
    devtools.log('!!!! dispose called in HomePage');
    super.dispose();
  }

  @override
  void didPush() {
    super.didPush();
    final routeName = ModalRoute.of(context)?.settings.name ?? 'Unknown';
    devtools.log('Navigated to $routeName');
  }

  @override
  void didPop() {
    super.didPop();
    final routeName = ModalRoute.of(context)?.settings.name ?? 'Unknown';
    devtools.log('Navigated back from $routeName');
  }

  //-------------------------------------------------------------------------//

  @override
  void initState() {
    super.initState();
    devtools.log('!!!! initState of HomePage invoked !!!!');
  }

  //----------------------------------------------------------------------------//
  void dismissOverlay() {
    if (_isOverlayVisible) {
      setState(() {
        _isOverlayVisible = false;
      });
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    dismissOverlay(); // Ensure overlay is dismissed when coming back
  }

  //----------------------------------------------------------------------------//

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
      if (_isOverlayVisible) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        final appointmentProvider =
            Provider.of<AppointmentProvider>(context, listen: false);
        appointmentProvider.selectedAppointmentId =
            null; // Resetting the state in AppointmentProvider
      }
    });
  }

  //-------------------------------------------------------------------------//

  void _navigateToAddNewPatient() {
    _toggleOverlay(); // Hide the overlay immediately
    final clinicSelection = context.read<ClinicSelection>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewPatient(
          doctorId: clinicSelection.doctorId,
          doctorName: widget.doctorData!['doctorName'],
          clinicId: clinicSelection.selectedClinicId,
          appBarTitle: 'Add New Patient',
        ),
      ),
    ).then((_) => _toggleOverlay());
  }

  //-------------------------------------------------------------------------//

  //--------------------------------------------------------------------------//

  void _navigateToStartNewTreatment() {
    _toggleOverlay(); // Hide the overlay immediately
    final clinicSelection = context.read<ClinicSelection>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewPatient(
          doctorId: clinicSelection.doctorId,
          doctorName: widget.doctorData!['doctorName'],
          clinicId: clinicSelection.selectedClinicId,
          appBarTitle: 'Add New Patient',
        ),
      ),
    ).then((_) => _toggleOverlay());
  }
  //--------------------------------------------------------------------------//

  //-----------------------------------------------------------------------------//

  //-----------------------------------------------------------------------------//

  void _navigateToBookAppointment() {
    dismissOverlay(); // Ensure overlay is dismissed
    final clinicSelection =
        context.read<ClinicSelection>(); // Access latest clinic data

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UICalendarSlots(
          doctorId: clinicSelection.doctorId,
          doctorName: widget.doctorData!['doctorName'],
          clinicId: clinicSelection.selectedClinicId,
        ),
      ),
    );
  }

  //-----------------------------------------------------------------------------//

  Widget _buildOverlay() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _toggleOverlay();
      },
      child: Stack(
        children: [
          Container(
            color: Colors.transparent,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: MyColors.colorPalette['surface-bright'],
              ),
              height: MediaQuery.of(context).size.height / 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Create',
                            style: MyTextStyle.textStyleMap['title-large']
                                ?.copyWith(
                              color: MyColors.colorPalette['on-surface'],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: MyColors.colorPalette['on-surface'],
                          ),
                          onPressed: () {
                            _toggleOverlay();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            MyColors.colorPalette['outline-variant'],
                        child: const Icon(Icons.person_outline),
                      ),
                      title: Text(
                        'Add New Patient',
                        style:
                            MyTextStyle.textStyleMap['title-medium']?.copyWith(
                          color: MyColors.colorPalette['on-surface'],
                        ),
                      ),
                      onTap: _navigateToAddNewPatient,
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            MyColors.colorPalette['outline-variant'],
                        child: SvgPicture.asset(
                          'assets/icons/medicines.svg',
                          height: 24,
                        ),
                      ),
                      title: Text(
                        'Start New Treatment',
                        style:
                            MyTextStyle.textStyleMap['title-medium']?.copyWith(
                          color: MyColors.colorPalette['on-surface'],
                        ),
                      ),
                      onTap: _navigateToStartNewTreatment,
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            MyColors.colorPalette['outline-variant'],
                        child: const Icon(Icons.access_time),
                      ),
                      title: Text(
                        'Book Appointment',
                        style:
                            MyTextStyle.textStyleMap['title-medium']?.copyWith(
                          color: MyColors.colorPalette['on-surface'],
                        ),
                      ),
                      onTap: _navigateToBookAppointment,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  //-----------------------------------------------------------------//
  AppBarConfig _getAppBarConfig(int index) {
    switch (index) {
      case 0:
        return AppBarConfig(
          isLandingScreen: true,
          backgroundImage: 'assets/images/img1.png',
          additionalContent: widget.doctorData!['doctorName'],
          disableBackArrow: true,
        );
      case 1:
        return const AppBarConfig(
          isLandingScreen: false,
          backgroundImage: null,
          additionalContent: null,
          disableBackArrow: true,
        );
      case 3:
        return const AppBarConfig(
          isLandingScreen: false,
          backgroundImage: null,
          additionalContent: null,
          disableBackArrow: true,
        );
      case 4:
        return const AppBarConfig(
          isLandingScreen: false,
          backgroundImage: 'assets/images/img1.png',
          additionalContent: null,
          disableBackArrow: true,
        );
      default:
        return const AppBarConfig(
          isLandingScreen: false,
          backgroundImage: null,
          additionalContent: null,
          disableBackArrow: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = context.watch<AppointmentProvider>();
    final recentPatientProvider = context.watch<RecentPatientProvider>();
    // Show loading indicator until doctor data is loaded

    devtools.log(
        '!!!! Welcome to HomePage build method. _currentIndex is $_currentIndex!!!!');

    // Fetch the app bar configuration based on the current screen
    final AppBarConfig appBarConfig = _getAppBarConfig(_currentIndex);

    try {
      devtools.log('doctorData received is ${widget.doctorData}');
      return Scaffold(
        appBar: CommonAppBar(
          backgroundImage: appBarConfig.backgroundImage,
          isLandingScreen: appBarConfig.isLandingScreen,
          additionalContent: appBarConfig.additionalContent,
          disableBackArrow: appBarConfig.disableBackArrow,
        ),
        body: Stack(
          children: [
            if (appointmentProvider.isLoading ||
                recentPatientProvider.isLoading)
              _buildLoadingIndicator()
            else if (_currentIndex == 0)
              LandingScreen(
                doctorId: widget.doctorData!['userId'] ?? '',
                doctorName: widget.doctorData!['doctorName'] ?? '',
                clinicId: ClinicSelection.instance.selectedClinicId,
              )
            else if (_currentIndex == 1)
              CalenderView(
                doctorId: widget.doctorData!['userId'] ?? '',
                doctorName: widget.doctorData!['doctorName'] ?? '',
                clinicId: ClinicSelection.instance.selectedClinicId,
                showBottomNavigationBar: false,
              )
            else if (_currentIndex == 3)
              SearchAndDisplayAllPatients(
                doctorId: widget.doctorData!['userId'] ?? '',
                doctorName: widget.doctorData!['doctorName'] ?? '',
                clinicId: ClinicSelection.instance.selectedClinicId,
              )
            else if (_currentIndex == 4)
              MyProfile(
                doctorId: widget.doctorData!['userId'] ?? '',
                doctorName: widget.doctorData!['doctorName'] ?? '',
                clinicId: ClinicSelection.instance.selectedClinicId,
              )
            else
              Container(),
            if (_isOverlayVisible) _buildOverlay() else const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          unselectedItemColor: MyColors.colorPalette['secondary'],
          selectedItemColor: MyColors.colorPalette['primary'],
          onTap: (index) {
            if (index == 2) {
              _toggleOverlay();
            } else {
              if (_isOverlayVisible) {
                _toggleOverlay();
              }
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              setState(() {
                _currentIndex = index;
                appointmentProvider.selectedAppointmentId = null;
              });
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24),
              activeIcon: Icon(Icons.home_filled, size: 24),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined, size: 24),
              activeIcon: Icon(Icons.calendar_today, size: 24),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: MyColors.colorPalette['secondary'] ?? Colors.blue,
                  ),
                  shape: BoxShape.circle,
                ),
                width: 40,
                height: 40,
                child: FloatingActionButton(
                  onPressed: _toggleOverlay,
                  backgroundColor: _isOverlayVisible
                      ? MyColors.colorPalette['primary']
                      : MyColors.colorPalette['on-primary'],
                  child: Icon(
                    Icons.add,
                    color: _isOverlayVisible
                        ? Colors.white
                        : MyColors.colorPalette['secondary'],
                    size: 35,
                  ),
                ),
              ),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined, size: 24),
              activeIcon: Icon(Icons.search_sharp, size: 24),
              label: 'Search',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined, size: 24),
              activeIcon: Icon(Icons.person, size: 24),
              label: 'Profile',
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      devtools.log('Error building HomePage: $e');
      devtools.log(stackTrace.toString());
      // Optionally, return a placeholder widget or handle the error gracefully
      return Container(
        child: Text('Error: $e'),
      );
    }
  }
  //--------------------------------------------------------------------------//
}

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ //
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:neocare_dental_app/firestore/clinic_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/common_app_bar.dart';
// import 'package:neocare_dental_app/mywidgets/custom_route_observer.dart';
// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/recent_patient_provider.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/ui_calendar_slots.dart';
// import 'package:provider/provider.dart';

// class HomePage extends StatefulWidget {
//   final Map<String, dynamic>? doctorData;
//   const HomePage({super.key, required this.doctorData});

//   @override
//   State<HomePage> createState() => HomePageState();
// }

// //-----------------------------------------------------------------------//
// class HomePageState extends State<HomePage> with RouteAware {
//   late String doctorName;
//   late String loggedInDoctorId;
//   late List<String> clinicNames;
//   late String selectedClinicName;
//   late String selectedClinicId;

//   late ClinicSelection clinicSelection;

//   late String collectedDoctorId;
//   late String collectedDoctorName;
//   late String collectedClinicId;

//   late List<String> collectedClinicNames;
//   late String collectedSelectedClinicName;

//   bool _isLoadingData = true;
//   bool _isOverlayVisible = false;
//   int _currentIndex = 0;

//   //-----------------------------//
//   // Add a public getter and setter for _currentIndex
//   int get currentIndex => _currentIndex;

//   set currentIndex(int value) {
//     setState(() {
//       _currentIndex = value;
//     });
//   }

//   //-----------------------------//
//   final Map<int, Widget> _screens = {};

//   @override
//   void dispose() {
//     // Unsubscribe from RouteObserver
//     CustomRouteObserver.routeObserver.unsubscribe(this);
//     super.dispose();
//   }

//   @override
//   void didPush() {
//     super.didPush();
//     final routeName = ModalRoute.of(context)?.settings.name ?? 'Unknown';
//     devtools.log('Navigated to $routeName');
//   }

//   @override
//   void didPop() {
//     super.didPop();
//     final routeName = ModalRoute.of(context)?.settings.name ?? 'Unknown';
//     devtools.log('Navigated back from $routeName');
//   }

//   //-------------------------------------------------------------------------//

//   @override
//   void initState() {
//     super.initState();
//     devtools.log('!!!! initState of HomePage invoked !!!!');

//     if (widget.doctorData != null) {
//       initializeDoctorData();

//       _buildScreens(widget.doctorData!);
//     }
//   }

//   //---------------------------------------------------------------------------//
//   Future<void> initializeDoctorData() async {
//     try {
//       devtools.log(
//           '!!!! initializeDoctorData invoked. Initializing doctor data... !!!!');
//       // Initialize variables with default values
//       doctorName = widget.doctorData!['doctorName'] ?? '';
//       loggedInDoctorId = widget.doctorData!['userId'] ?? '';
//       clinicNames = [];
//       selectedClinicName = '';
//       selectedClinicId = '';
//       collectedDoctorId = '';
//       collectedDoctorName = '';
//       collectedClinicId = '';
//       collectedClinicNames = [];
//       collectedSelectedClinicName = '';
//       clinicSelection = ClinicSelection.instance;

//       // Extract clinicsMapped from the provided doctor data
//       List<dynamic>? clinicsMapped = widget.doctorData!['clinicsMapped'];

//       if (clinicsMapped != null && clinicsMapped.isNotEmpty) {
//         // Extract clinic names
//         clinicNames = clinicsMapped
//             .map((clinic) => clinic['clinicName'] as String)
//             .toList();

//         devtools.log('clinicNames mapped from clinicsMapped are $clinicNames');

//         // Set default selected clinic and get its ID
//         selectedClinicName = clinicNames.first;
//         devtools
//             .log('**** Initially selectedClinicName is $selectedClinicName');

//         // Fetch the clinic ID asynchronously
//         String clinicId = await ClinicService().getClinicId(selectedClinicName);

//         devtools.log('**** clinicId of initially selectedClinicName $clinicId');

//         setState(() {
//           selectedClinicId = clinicId;

//           // Update collected values
//           collectedDoctorId = loggedInDoctorId;
//           collectedDoctorName = doctorName;
//           collectedClinicId = selectedClinicId;
//           collectedClinicNames = clinicNames;
//           collectedSelectedClinicName = selectedClinicName;

//           // Update clinic selection parameters
//           clinicSelection.updateParameters(
//               selectedClinicName, clinicNames, selectedClinicId);

//           // Mark data loading as complete
//           _isLoadingData = false;
//         });
//       } else {
//         // Handle the case where clinicsMapped is empty or null
//         devtools.log('No clinics available in doctor data.');
//         setState(() {
//           _isLoadingData = false;
//         });
//       }
//     } catch (error) {
//       // Handle any errors that occur during initialization
//       devtools.log('Error initializing doctor data: $error');
//       setState(() {
//         _isLoadingData = false;
//       });
//     }
//   }

//   //----------------------------------------------------------------------------//
//   void dismissOverlay() {
//     if (_isOverlayVisible) {
//       setState(() {
//         _isOverlayVisible = false;
//       });
//     }
//   }

//   @override
//   void didPopNext() {
//     super.didPopNext();
//     dismissOverlay(); // Ensure overlay is dismissed when coming back
//   }

//   //----------------------------------------------------------------------------//

//   void _toggleOverlay() {
//     setState(() {
//       _isOverlayVisible = !_isOverlayVisible;
//       if (_isOverlayVisible) {
//         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//         final appointmentProvider =
//             Provider.of<AppointmentProvider>(context, listen: false);
//         appointmentProvider.selectedAppointmentId =
//             null; // Resetting the state in AppointmentProvider
//       }
//     });
//   }

//   //-------------------------------------------------------------------------//

//   void _navigateToAddNewPatient() {
//     _toggleOverlay(); // Hide the overlay immediately
//     final clinicSelection = context.read<ClinicSelection>();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddNewPatient(
//           doctorId: clinicSelection.doctorId,
//           doctorName: collectedDoctorName,
//           clinicId: clinicSelection.selectedClinicId,
//           appBarTitle: 'Add New Patient',
//         ),
//       ),
//     ).then((_) => _toggleOverlay());
//   }

//   //-------------------------------------------------------------------------//

//   //--------------------------------------------------------------------------//

//   void _navigateToStartNewTreatment() {
//     _toggleOverlay(); // Hide the overlay immediately
//     final clinicSelection = context.read<ClinicSelection>();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddNewPatient(
//           doctorId: clinicSelection.doctorId,
//           doctorName: collectedDoctorName,
//           clinicId: clinicSelection.selectedClinicId,
//           appBarTitle: 'Add New Patient',
//         ),
//       ),
//     ).then((_) => _toggleOverlay());
//   }
//   //--------------------------------------------------------------------------//

//   //-----------------------------------------------------------------------------//

//   //-----------------------------------------------------------------------------//

//   void _navigateToBookAppointment() {
//     dismissOverlay(); // Ensure overlay is dismissed
//     final clinicSelection =
//         context.read<ClinicSelection>(); // Access latest clinic data

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => UICalendarSlots(
//           doctorId: clinicSelection.doctorId,
//           doctorName: collectedDoctorName,
//           clinicId: clinicSelection.selectedClinicId,
//         ),
//       ),
//     );
//   }

//   //-----------------------------------------------------------------------------//

//   Widget _buildOverlay() {
//     return GestureDetector(
//       onTap: () {
//         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//         _toggleOverlay();
//       },
//       child: Stack(
//         children: [
//           Container(
//             color: Colors.transparent,
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: MyColors.colorPalette['surface-bright'],
//               ),
//               height: MediaQuery.of(context).size.height / 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             'Create',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                               color: MyColors.colorPalette['on-surface'],
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             Icons.close,
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                           onPressed: () {
//                             _toggleOverlay();
//                           },
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),
//                     ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor:
//                             MyColors.colorPalette['outline-variant'],
//                         child: const Icon(Icons.person_outline),
//                       ),
//                       title: Text(
//                         'Add New Patient',
//                         style:
//                             MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                       onTap: _navigateToAddNewPatient,
//                     ),
//                     const SizedBox(height: 24),
//                     ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor:
//                             MyColors.colorPalette['outline-variant'],
//                         child: SvgPicture.asset(
//                           'assets/icons/medicines.svg',
//                           height: 24,
//                         ),
//                       ),
//                       title: Text(
//                         'Start New Treatment',
//                         style:
//                             MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                       onTap: _navigateToStartNewTreatment,
//                     ),
//                     const SizedBox(height: 24),
//                     ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor:
//                             MyColors.colorPalette['outline-variant'],
//                         child: const Icon(Icons.access_time),
//                       ),
//                       title: Text(
//                         'Book Appointment',
//                         style:
//                             MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                       onTap: _navigateToBookAppointment,
//                     ),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _buildScreens(Map<String, dynamic> doctorData) {
//     //devtools.log('[log]-  ${DateTime.now()} ');
//     _buildScreen(0, doctorData); // LandingScreen
//     _buildScreen(1, doctorData); // CalenderView
//     _buildScreen(3, doctorData); // SearchAndDisplayAllPatients
//     _buildScreen(4, doctorData); // MyProfile
//   }

//   Widget _buildScreen(int index, Map<String, dynamic> doctorData) {
//     Widget screen;
//     //Widget? screen;

//     switch (index) {
//       case 0:
//         screen = LandingScreen(
//           doctorId: collectedDoctorId,
//           doctorName: collectedDoctorName,
//           clinicId: collectedClinicId,
//         );
//         devtools.log('case 0 triggered !');

//         break;

//       case 1:
//         screen = CalenderView(
//           doctorId: collectedDoctorId,
//           doctorName: collectedDoctorName,
//           clinicId: collectedClinicId,
//           showBottomNavigationBar: false,
//         );
//         devtools.log('case 1 triggered !');
//         break;

//       case 3:
//         screen = SearchAndDisplayAllPatients(
//           doctorId: collectedDoctorId,
//           doctorName: collectedDoctorName,
//           clinicId: collectedClinicId,
//         );
//         devtools.log('case 3 triggered !');
//         break;

//       case 4:
//         screen = MyProfile(
//           doctorId: collectedDoctorId,
//           doctorName: collectedDoctorName,
//           clinicId: collectedClinicId,
//         );
//         devtools.log('case 4 triggered !');
//         break;

//       default:
//         screen = Container();
//     }

//     _screens[index] = screen;
//     //return screen;
//     return screen ?? Container();
//   }

//   Widget _buildLoadingIndicator() {
//     return const Center(
//       child: CircularProgressIndicator(),
//     );
//   }

//   //-----------------------------------------------------------------//
//   AppBarConfig _getAppBarConfig(int index) {
//     switch (index) {
//       case 0:
//         return AppBarConfig(
//           isLandingScreen: true,
//           backgroundImage: 'assets/images/img1.png',
//           additionalContent: collectedDoctorName,
//           disableBackArrow: true,
//         );
//       case 1:
//         return const AppBarConfig(
//           isLandingScreen: false,
//           backgroundImage: null,
//           additionalContent: null,
//           disableBackArrow: true,
//         );
//       case 3:
//         return const AppBarConfig(
//           isLandingScreen: false,
//           backgroundImage: null,
//           additionalContent: null,
//           disableBackArrow: true,
//         );
//       case 4:
//         return const AppBarConfig(
//           isLandingScreen: false,
//           backgroundImage: 'assets/images/img1.png',
//           additionalContent: null,
//           disableBackArrow: true,
//         );
//       default:
//         return const AppBarConfig(
//           isLandingScreen: false,
//           backgroundImage: null,
//           additionalContent: null,
//           disableBackArrow: true,
//         );
//     }
//   }

//   //-----------------------------------------------------------------//

//   @override
//   Widget build(BuildContext context) {
//     final appointmentProvider = context.watch<AppointmentProvider>();
//     final recentPatientProvider = context.watch<RecentPatientProvider>();
//     // Show loading indicator until doctor data is loaded
//     if (_isLoadingData) {
//       return Scaffold(
//         //---------------------------------//

//         //---------------------------------//
//         body: _buildLoadingIndicator(),
//       );
//     }

//     devtools.log('Welcome to HomePage build method.');

//     // Fetch the app bar configuration based on the current screen
//     final AppBarConfig appBarConfig = _getAppBarConfig(_currentIndex);

//     try {
//       devtools.log('Welcome to HomePage build method.');
//       devtools.log('doctorData received is ${widget.doctorData}');
//       return Scaffold(
//         appBar: CommonAppBar(
//           backgroundImage: appBarConfig.backgroundImage,
//           isLandingScreen: appBarConfig.isLandingScreen,
//           additionalContent: appBarConfig.additionalContent,
//           disableBackArrow: appBarConfig.disableBackArrow,
//         ),
//         // body: Stack(
//         //   children: [
//         //     _buildScreen(_currentIndex, {}) ?? Container(),
//         //     if (_isOverlayVisible) _buildOverlay() else const SizedBox.shrink(),
//         //   ],
//         // ),

//         // body: Stack(
//         //   children: [
//         //     if (appointmentProvider.isLoading &&
//         //         appointmentProvider.nextAppointment == null)
//         //       _buildLoadingIndicator()
//         //     else
//         //       _buildScreen(_currentIndex, {}) ?? Container(),
//         //     if (_isOverlayVisible) _buildOverlay() else const SizedBox.shrink(),
//         //   ],
//         // ),

//         body: Stack(
//           children: [
//             if (appointmentProvider.isLoading &&
//                     appointmentProvider.nextAppointment == null ||
//                 recentPatientProvider.isLoading)
//               _buildLoadingIndicator()
//             else
//               _buildScreen(_currentIndex, {}) ?? Container(),
//             if (_isOverlayVisible) _buildOverlay() else const SizedBox.shrink(),
//           ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: _currentIndex,
//           unselectedItemColor: MyColors.colorPalette['secondary'],
//           selectedItemColor: MyColors.colorPalette['primary'],
//           onTap: (index) {
//             if (index == 2) {
//               _toggleOverlay();
//             } else {
//               if (_isOverlayVisible) {
//                 _toggleOverlay();
//               }
//               ScaffoldMessenger.of(context).hideCurrentSnackBar();
//               setState(() {
//                 _currentIndex = index;
//                 appointmentProvider.selectedAppointmentId = null;
//               });
//             }
//           },
//           items: [
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined, size: 24),
//               activeIcon: Icon(Icons.home_filled, size: 24),
//               label: 'Home',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_today_outlined, size: 24),
//               activeIcon: Icon(Icons.calendar_today, size: 24),
//               label: 'Calendar',
//             ),
//             BottomNavigationBarItem(
//               icon: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     width: 2,
//                     color: MyColors.colorPalette['secondary'] ?? Colors.blue,
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 width: 40,
//                 height: 40,
//                 child: FloatingActionButton(
//                   onPressed: _toggleOverlay,
//                   backgroundColor: _isOverlayVisible
//                       ? MyColors.colorPalette['primary']
//                       : MyColors.colorPalette['on-primary'],
//                   child: Icon(
//                     Icons.add,
//                     color: _isOverlayVisible
//                         ? Colors.white
//                         : MyColors.colorPalette['secondary'],
//                     size: 35,
//                   ),
//                 ),
//               ),
//               label: '',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.search_outlined, size: 24),
//               activeIcon: Icon(Icons.search_sharp, size: 24),
//               label: 'Search',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.person_outlined, size: 24),
//               activeIcon: Icon(Icons.person, size: 24),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       );
//     } catch (e, stackTrace) {
//       devtools.log('Error building HomePage: $e');
//       devtools.log(stackTrace.toString());
//       // Optionally, return a placeholder widget or handle the error gracefully
//       return Container(
//         child: Text('Error: $e'),
//       );
//     }
//   }
// }



// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// ############################################################################//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:neocare_dental_app/firestore/clinic_service.dart';
// import 'package:neocare_dental_app/firestore/patient_service.dart';
// import 'package:neocare_dental_app/landing_screen.dart';
// import 'package:neocare_dental_app/mywidgets/add_new_patient.dart';
// import 'package:neocare_dental_app/mywidgets/appointment_provider.dart';
// import 'package:neocare_dental_app/mywidgets/book_appointment.dart';
// import 'package:neocare_dental_app/mywidgets/calender_view.dart';
// import 'package:neocare_dental_app/mywidgets/clinic_selection.dart';
// import 'package:neocare_dental_app/mywidgets/common_app_bar.dart';
// import 'package:neocare_dental_app/mywidgets/custom_route_observer.dart';
// import 'package:neocare_dental_app/mywidgets/my_profile.dart';
// import 'package:neocare_dental_app/mywidgets/mycolors.dart';
// import 'package:neocare_dental_app/mywidgets/mytextstyle.dart';
// import 'package:neocare_dental_app/mywidgets/search_and_display_all_patients.dart';
// import 'dart:developer' as devtools show log;
// import 'package:neocare_dental_app/mywidgets/ui_calendar_slots.dart';
// import 'package:provider/provider.dart';

// class HomePage extends StatefulWidget {
//   final Map<String, dynamic>? doctorData;
//   final PatientService collectedPatientService;
//   const HomePage(
//       {super.key,
//       required this.doctorData,
//       required this.collectedPatientService});

//   @override
//   State<HomePage> createState() => HomePageState();
// }

// //-----------------------------------------------------------------------//
// class HomePageState extends State<HomePage> with RouteAware {
//   late String doctorName;
//   late String loggedInDoctorId;
//   late List<String> clinicNames;
//   late String selectedClinicName;
//   late String selectedClinicId;

//   late ClinicSelection clinicSelection;

//   late String collectedDoctorId;
//   late String collectedDoctorName;
//   late String collectedClinicId;

//   //late PatientService _patientService;
//   PatientService _patientService = PatientService('', '');

//   // PatientService collectedPatientService = PatientService('', '');

//   late List<String> collectedClinicNames;
//   late String collectedSelectedClinicName;

//   bool _isLoadingData = true;
//   bool _isOverlayVisible = false;
//   int _currentIndex = 0;

//   //-----------------------------//
//   // Add a public getter and setter for _currentIndex
//   int get currentIndex => _currentIndex;

//   set currentIndex(int value) {
//     setState(() {
//       _currentIndex = value;
//     });
//   }

//   //-----------------------------//
//   final Map<int, Widget> _screens = {};

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     final args = ModalRoute.of(context)?.settings.arguments as Map?;
//     if (args == null || args['selectedClinicId'] == null) {
//       return; // No valid arguments, skip update.
//     }

//     final newSelectedClinicId = args['selectedClinicId'];

//     if (newSelectedClinicId == ClinicSelection.instance.selectedClinicId) {
//       devtools.log(
//           'Skipping update in didChangeDependencies: Clinic is up-to-date.');
//       return; // Avoid redundant updates.
//     }

//     devtools.log('Processing route arguments in didChangeDependencies...');
//     ClinicService().fetchClinicData(newSelectedClinicId).then((clinicData) {
//       if (clinicData != null && clinicData['clinicName'] != null) {
//         Provider.of<ClinicSelection>(context, listen: false).updateClinic(
//           clinicData['clinicName'],
//           newSelectedClinicId,
//         );
//       }
//     }).catchError((error) {
//       devtools.log('Error in didChangeDependencies: $error');
//     });
//   }

//   @override
//   void dispose() {
//     // Unsubscribe from RouteObserver
//     CustomRouteObserver.routeObserver.unsubscribe(this);
//     super.dispose();
//   }

//   @override
//   void didPush() {
//     super.didPush();
//     final routeName = ModalRoute.of(context)?.settings.name ?? 'Unknown';
//     devtools.log('Navigated to $routeName');
//   }

//   @override
//   void didPop() {
//     super.didPop();
//     final routeName = ModalRoute.of(context)?.settings.name ?? 'Unknown';
//     devtools.log('Navigated back from $routeName');
//   }

//   //-------------------------------------------------------------------------//

//   @override
//   void initState() {
//     super.initState();
//     devtools.log('!!!! initState of HomePage invoked !!!!');

//     if (widget.doctorData != null) {
//       initializeDoctorData();

//       _buildScreens(widget.doctorData!);
//     }
//   }

//   //---------------------------------------------------------------------------//
//   Future<void> initializeDoctorData() async {
//     try {
//       devtools.log(
//           '!!!! initializeDoctorData invoked. Initializing doctor data... !!!!');
//       // Initialize variables with default values
//       doctorName = widget.doctorData!['doctorName'] ?? '';
//       loggedInDoctorId = widget.doctorData!['userId'] ?? '';
//       clinicNames = [];
//       selectedClinicName = '';
//       selectedClinicId = '';
//       collectedDoctorId = '';
//       collectedDoctorName = '';
//       collectedClinicId = '';
//       collectedClinicNames = [];
//       collectedSelectedClinicName = '';
//       clinicSelection = ClinicSelection.instance;

//       // Extract clinicsMapped from the provided doctor data
//       List<dynamic>? clinicsMapped = widget.doctorData!['clinicsMapped'];

//       if (clinicsMapped != null && clinicsMapped.isNotEmpty) {
//         // Extract clinic names
//         clinicNames = clinicsMapped
//             .map((clinic) => clinic['clinicName'] as String)
//             .toList();

//         devtools.log('clinicNames mapped from clinicsMapped are $clinicNames');

//         // Set default selected clinic and get its ID
//         selectedClinicName = clinicNames.first;
//         devtools
//             .log('**** Initially selectedClinicName is $selectedClinicName');

//         // Fetch the clinic ID asynchronously
//         String clinicId = await ClinicService().getClinicId(selectedClinicName);

//         devtools.log('**** clinicId of initially selectedClinicName $clinicId');

//         // Update the state after fetching the clinic ID
//         setState(() {
//           selectedClinicId = clinicId;

//           // Update collected values
//           collectedDoctorId = loggedInDoctorId;
//           collectedDoctorName = doctorName;
//           collectedClinicId = selectedClinicId;
//           collectedClinicNames = clinicNames;
//           collectedSelectedClinicName = selectedClinicName;

//           // Update clinic selection parameters
//           clinicSelection.updateParameters(
//               selectedClinicName, clinicNames, selectedClinicId);

//           // Assign the patient service from widget to local variable
//           _patientService = widget.collectedPatientService;

//           // Mark data loading as complete
//           _isLoadingData = false;
//         });
//       } else {
//         // Handle the case where clinicsMapped is empty or null
//         devtools.log('No clinics available in doctor data.');
//         setState(() {
//           _isLoadingData = false;
//         });
//       }
//     } catch (error) {
//       // Handle any errors that occur during initialization
//       devtools.log('Error initializing doctor data: $error');
//       setState(() {
//         _isLoadingData = false;
//       });
//     }
//   }

//   //----------------------------------------------------------------------------//
//   void dismissOverlay() {
//     if (_isOverlayVisible) {
//       setState(() {
//         _isOverlayVisible = false;
//       });
//     }
//   }

//   @override
//   void didPopNext() {
//     super.didPopNext();
//     dismissOverlay(); // Ensure overlay is dismissed when coming back
//   }

//   //----------------------------------------------------------------------------//

//   void _toggleOverlay() {
//     setState(() {
//       _isOverlayVisible = !_isOverlayVisible;
//       if (_isOverlayVisible) {
//         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//         final appointmentProvider =
//             Provider.of<AppointmentProvider>(context, listen: false);
//         appointmentProvider.selectedAppointmentId =
//             null; // Resetting the state in AppointmentProvider
//       }
//     });
//   }

//   //-------------------------------------------------------------------------//
//   void _navigateToAddNewPatient() {
//     _toggleOverlay(); // Hide the overlay immediately
//     final clinicSelection = context.read<ClinicSelection>();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddNewPatient(
//           doctorId: clinicSelection.doctorId,
//           doctorName: collectedDoctorName,
//           clinicId: clinicSelection.selectedClinicId, // Pass correct clinicId
//           patientService: PatientService(
//             clinicSelection.selectedClinicId,
//             clinicSelection.doctorId,
//           ),
//           appBarTitle: 'Add New Patient',
//         ),
//       ),
//     ).then((_) => _toggleOverlay());
//   }

//   //-------------------------------------------------------------------------//

//   //--------------------------------------------------------------------------//
//   void _navigateToStartNewTreatment() {
//     _toggleOverlay(); // Hide the overlay immediately
//     final clinicSelection = context.read<ClinicSelection>();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddNewPatient(
//           doctorId: clinicSelection.doctorId,
//           doctorName: collectedDoctorName,
//           clinicId: clinicSelection.selectedClinicId, // Pass correct clinicId
//           patientService: PatientService(
//             clinicSelection.selectedClinicId,
//             clinicSelection.doctorId,
//           ),
//           appBarTitle: 'Add New Patient',
//         ),
//       ),
//     ).then((_) => _toggleOverlay());
//   }
//   //--------------------------------------------------------------------------//

//   //-----------------------------------------------------------------------------//
//   // void _navigateToBookAppointment() {
//   //   _toggleOverlay(); // Hide the overlay immediately
//   //   final clinicSelection =
//   //       context.read<ClinicSelection>(); // Access latest clinic data

//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => UICalendarSlots(
//   //         doctorId: clinicSelection.doctorId, // Use selected doctorId
//   //         doctorName:
//   //             collectedDoctorName, // Keep the doctor name from HomePage state
//   //         clinicId: clinicSelection.selectedClinicId, // Use latest clinicId
//   //         patientService: PatientService(
//   //           clinicSelection.selectedClinicId,
//   //           clinicSelection.doctorId, // Pass correct doctorId and clinicId
//   //         ),
//   //       ),
//   //     ),
//   //   ).then((_) {
//   //     _toggleOverlay(); // Remove the overlay when navigated back
//   //   });
//   // }

//   //-----------------------------------------------------------------------------//
//   void _navigateToBookAppointment() {
//     dismissOverlay(); // Ensure overlay is dismissed
//     final clinicSelection =
//         context.read<ClinicSelection>(); // Access latest clinic data

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => UICalendarSlots(
//           doctorId: clinicSelection.doctorId,
//           doctorName: collectedDoctorName,
//           clinicId: clinicSelection.selectedClinicId,
//           patientService: PatientService(
//             clinicSelection.selectedClinicId,
//             clinicSelection.doctorId,
//           ),
//         ),
//       ),
//     );
//   }

//   //-----------------------------------------------------------------------------//

//   Widget _buildOverlay() {
//     return GestureDetector(
//       onTap: () {
//         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//         _toggleOverlay();
//       },
//       child: Stack(
//         children: [
//           Container(
//             color: Colors.transparent,
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: MyColors.colorPalette['surface-bright'],
//               ),
//               height: MediaQuery.of(context).size.height / 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             'Create',
//                             style: MyTextStyle.textStyleMap['title-large']
//                                 ?.copyWith(
//                               color: MyColors.colorPalette['on-surface'],
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             Icons.close,
//                             color: MyColors.colorPalette['on-surface'],
//                           ),
//                           onPressed: () {
//                             _toggleOverlay();
//                           },
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),
//                     ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor:
//                             MyColors.colorPalette['outline-variant'],
//                         child: const Icon(Icons.person_outline),
//                       ),
//                       title: Text(
//                         'Add New Patient',
//                         style:
//                             MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                       onTap: _navigateToAddNewPatient,
//                     ),
//                     const SizedBox(height: 24),
//                     ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor:
//                             MyColors.colorPalette['outline-variant'],
//                         child: SvgPicture.asset(
//                           'assets/icons/medicines.svg',
//                           height: 24,
//                         ),
//                       ),
//                       title: Text(
//                         'Start New Treatment',
//                         style:
//                             MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                       onTap: _navigateToStartNewTreatment,
//                     ),
//                     const SizedBox(height: 24),
//                     ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor:
//                             MyColors.colorPalette['outline-variant'],
//                         child: const Icon(Icons.access_time),
//                       ),
//                       title: Text(
//                         'Book Appointment',
//                         style:
//                             MyTextStyle.textStyleMap['title-medium']?.copyWith(
//                           color: MyColors.colorPalette['on-surface'],
//                         ),
//                       ),
//                       onTap: _navigateToBookAppointment,
//                     ),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _buildScreens(Map<String, dynamic> doctorData) {
//     //devtools.log('[log]-  ${DateTime.now()} ');
//     _buildScreen(0, doctorData); // LandingScreen
//     _buildScreen(1, doctorData); // CalenderView
//     _buildScreen(3, doctorData); // SearchAndDisplayAllPatients
//     _buildScreen(4, doctorData); // MyProfile
//   }

//   Widget _buildScreen(int index, Map<String, dynamic> doctorData) {
//     Widget screen;
//     //Widget? screen;

//     switch (index) {
//       case 0:
//         screen = LandingScreen(
//           doctorId: collectedDoctorId, //_collectedDoctorId,
//           doctorName: collectedDoctorName, //_collectedDoctorName,
//           clinicId: collectedClinicId, //_collectedClinicId,
//           //patientService: collectedPatientService, //_collectedPatientService,
//           patientService: _patientService, //_collectedPatientService,
//         );
//         devtools.log('case 0 triggered !');

//         break;

//       case 1:
//         screen = CalenderView(
//           doctorId: collectedDoctorId, //_collectedDoctorId,
//           doctorName: collectedDoctorName, //_collectedDoctorName,
//           clinicId: collectedClinicId, //_collectedClinicId,
//           //patientService: collectedPatientService, //_collectedPatientService,
//           patientService: _patientService, //_collectedPatientService,
//           showBottomNavigationBar: false,
//         );
//         devtools.log('case 1 triggered !');
//         break;

//       case 3:
//         screen = SearchAndDisplayAllPatients(
//           doctorId: collectedDoctorId, //_collectedDoctorId,
//           doctorName: collectedDoctorName, //_collectedDoctorName,
//           clinicId: collectedClinicId, //_collectedClinicId,
//           //patientService: collectedPatientService, //_collectedPatientService,
//           patientService: _patientService, //_collectedPatientService,
//         );
//         devtools.log('case 3 triggered !');
//         break;

//       case 4:
//         screen = MyProfile(
//           doctorId: collectedDoctorId, //_collectedDoctorId,
//           doctorName: collectedDoctorName, //_collectedDoctorName,
//           clinicId: collectedClinicId, //_collectedClinicId,
//           //patientService: collectedPatientService, //_collectedPatientService,
//           patientService: _patientService, //_collectedPatientService,
//         );
//         devtools.log('case 4 triggered !');
//         break;

//       default:
//         screen = Container();
//     }

//     _screens[index] = screen;
//     //return screen;
//     return screen ?? Container();
//   }

//   Widget _buildLoadingIndicator() {
//     return const Center(
//       child: CircularProgressIndicator(),
//     );
//   }

//   //-----------------------------------------------------------------//
//   AppBarConfig _getAppBarConfig(int index) {
//     switch (index) {
//       case 0:
//         return AppBarConfig(
//           isLandingScreen: true,
//           backgroundImage: 'assets/images/img1.png',
//           additionalContent: collectedDoctorName,
//           disableBackArrow: true,
//         );
//       case 1:
//         return const AppBarConfig(
//           isLandingScreen: false,
//           backgroundImage: null,
//           additionalContent: null,
//           disableBackArrow: true,
//         );
//       case 3:
//         return const AppBarConfig(
//           isLandingScreen: false,
//           backgroundImage: null,
//           additionalContent: null,
//           disableBackArrow: true,
//         );
//       case 4:
//         return const AppBarConfig(
//           isLandingScreen: false,
//           backgroundImage: 'assets/images/img1.png',
//           additionalContent: null,
//           disableBackArrow: true,
//         );
//       default:
//         return const AppBarConfig(
//           isLandingScreen: false,
//           backgroundImage: null,
//           additionalContent: null,
//           disableBackArrow: true,
//         );
//     }
//   }

//   //-----------------------------------------------------------------//

//   @override
//   Widget build(BuildContext context) {
//     final clinicSelection = context.watch<ClinicSelection>();
//     final appointmentProvider = context.watch<AppointmentProvider>();
//     // Show loading indicator until doctor data is loaded
//     if (_isLoadingData) {
//       return Scaffold(
//         //---------------------------------//

//         //---------------------------------//
//         body: _buildLoadingIndicator(),
//       );
//     }
//     devtools.log(
//         'Welcome to HomePage build method with clinic: ${clinicSelection.selectedClinicName}');

//     // Fetch the app bar configuration based on the current screen
//     final AppBarConfig appBarConfig = _getAppBarConfig(_currentIndex);

//     try {
//       devtools.log('Welcome to HomePage build method.');
//       devtools.log('doctorData received is ${widget.doctorData}');
//       return Scaffold(
//         appBar: CommonAppBar(
//           backgroundImage: appBarConfig.backgroundImage,
//           isLandingScreen: appBarConfig.isLandingScreen,
//           additionalContent: appBarConfig.additionalContent,
//           disableBackArrow: appBarConfig.disableBackArrow,
//         ),
//         body: Stack(
//           children: [
//             if (appointmentProvider.isLoading &&
//                 appointmentProvider.nextAppointment == null)
//               _buildLoadingIndicator()
//             else
//               _buildScreen(_currentIndex, {}) ?? Container(),
//             if (_isOverlayVisible) _buildOverlay() else const SizedBox.shrink(),
//           ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: _currentIndex,
//           unselectedItemColor: MyColors.colorPalette['secondary'],
//           selectedItemColor: MyColors.colorPalette['primary'],
//           onTap: (index) {
//             if (index == 2) {
//               _toggleOverlay();
//             } else {
//               if (_isOverlayVisible) {
//                 _toggleOverlay();
//               }
//               ScaffoldMessenger.of(context).hideCurrentSnackBar();
//               setState(() {
//                 _currentIndex = index;
//                 appointmentProvider.selectedAppointmentId = null;
//               });
//             }
//           },
//           items: [
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined, size: 24),
//               activeIcon: Icon(Icons.home_filled, size: 24),
//               label: 'Home',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_today_outlined, size: 24),
//               activeIcon: Icon(Icons.calendar_today, size: 24),
//               label: 'Calendar',
//             ),
//             BottomNavigationBarItem(
//               icon: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     width: 2,
//                     color: MyColors.colorPalette['secondary'] ?? Colors.blue,
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 width: 40,
//                 height: 40,
//                 child: FloatingActionButton(
//                   onPressed: _toggleOverlay,
//                   backgroundColor: _isOverlayVisible
//                       ? MyColors.colorPalette['primary']
//                       : MyColors.colorPalette['on-primary'],
//                   child: Icon(
//                     Icons.add,
//                     color: _isOverlayVisible
//                         ? Colors.white
//                         : MyColors.colorPalette['secondary'],
//                     size: 35,
//                   ),
//                 ),
//               ),
//               label: '',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.search_outlined, size: 24),
//               activeIcon: Icon(Icons.search_sharp, size: 24),
//               label: 'Search',
//             ),
//             const BottomNavigationBarItem(
//               icon: Icon(Icons.person_outlined, size: 24),
//               activeIcon: Icon(Icons.person, size: 24),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       );
//     } catch (e, stackTrace) {
//       devtools.log('Error building HomePage: $e');
//       devtools.log(stackTrace.toString());
//       // Optionally, return a placeholder widget or handle the error gracefully
//       return Container(
//         child: Text('Error: $e'),
//       );
//     }
//   }
// }

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
