import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;

class DropDownMenu extends StatefulWidget {
  final List<String> clinicNames;
  final Function(String) onClinicSelected; // Added callback function

  const DropDownMenu({
    super.key,
    required this.clinicNames,
    required this.onClinicSelected,
  });

  @override
  State<DropDownMenu> createState() => _DropDownMenuState();
}

class _DropDownMenuState extends State<DropDownMenu> {
  String? dropdownValue;
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    if (widget.clinicNames.isNotEmpty) {
      dropdownValue = widget.clinicNames[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        value: dropdownValue,
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.expand_more, // This icon points downwards
          color: Colors.black,
        ),
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
            widget.onClinicSelected(newValue); // Invoke the callback function
            devtools.log(
                'This is coming from inside DropdownButton .Selected clinic: $newValue');
          });
        },
        items: widget.clinicNames.map((String clinicName) {
          return DropdownMenuItem<String>(
            value: clinicName,
            child: Text(
              clinicName,
              style: MyTextStyle.textStyleMap['title-medium']
                  ?.copyWith(color: MyColors.colorPalette['on_surface']),
            ),
          );
        }).toList(),
      ),
    );
  }
}
