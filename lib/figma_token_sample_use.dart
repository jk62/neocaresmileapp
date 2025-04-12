import 'package:flutter/material.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';

class HelloWorldApp extends StatelessWidget {
  const HelloWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hello, World!'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-large']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-large']
                        ?.copyWith(color: MyColors.colorPalette['on_primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-large']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-large']?.copyWith(
                        color: MyColors.colorPalette['on_secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-large']
                        ?.copyWith(color: MyColors.colorPalette['tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-large']
                        ?.copyWith(color: MyColors.colorPalette['on_tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-medium']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-medium']
                        ?.copyWith(color: MyColors.colorPalette['on_primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-medium']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-medium']?.copyWith(
                        color: MyColors.colorPalette['on_secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-medium']
                        ?.copyWith(color: MyColors.colorPalette['tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-medium']
                        ?.copyWith(color: MyColors.colorPalette['on_tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-small']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-small']
                        ?.copyWith(color: MyColors.colorPalette['on_primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-small']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-small']?.copyWith(
                        color: MyColors.colorPalette['on_secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-small']
                        ?.copyWith(color: MyColors.colorPalette['tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['display-small']
                        ?.copyWith(color: MyColors.colorPalette['on_tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-large']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-large']
                        ?.copyWith(color: MyColors.colorPalette['on_primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-large']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-large']?.copyWith(
                        color: MyColors.colorPalette['on_secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-large']
                        ?.copyWith(color: MyColors.colorPalette['tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-large']
                        ?.copyWith(color: MyColors.colorPalette['on_tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-medium']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-medium']
                        ?.copyWith(color: MyColors.colorPalette['on_primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-medium']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-medium']
                        ?.copyWith(
                            color: MyColors.colorPalette['on_secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-medium']
                        ?.copyWith(color: MyColors.colorPalette['tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-medium']
                        ?.copyWith(color: MyColors.colorPalette['on_tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-small']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-small']
                        ?.copyWith(color: MyColors.colorPalette['on_primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-small']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-small']?.copyWith(
                        color: MyColors.colorPalette['on_secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-small']
                        ?.copyWith(color: MyColors.colorPalette['tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['headline-small']
                        ?.copyWith(color: MyColors.colorPalette['on_tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-large']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-large']
                        ?.copyWith(color: MyColors.colorPalette['on_primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-large']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-large']?.copyWith(
                        color: MyColors.colorPalette['on_secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-large']
                        ?.copyWith(color: MyColors.colorPalette['tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-large']
                        ?.copyWith(color: MyColors.colorPalette['on_tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-medium']
                        ?.copyWith(color: MyColors.colorPalette['primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-medium']
                        ?.copyWith(color: MyColors.colorPalette['on_primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-medium']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-medium']?.copyWith(
                        color: MyColors.colorPalette['on_secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-medium']
                        ?.copyWith(color: MyColors.colorPalette['tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-medium']
                        ?.copyWith(color: MyColors.colorPalette['on_tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-small']
                        ?.copyWith(color: MyColors.colorPalette['on_primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-small']
                        ?.copyWith(color: MyColors.colorPalette['on_primary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-small']
                        ?.copyWith(color: MyColors.colorPalette['secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-small']?.copyWith(
                        color: MyColors.colorPalette['on_secondary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-small']
                        ?.copyWith(color: MyColors.colorPalette['tertiary']),
                  ),
                  Text(
                    'Hello, World!',
                    style: MyTextStyle.textStyleMap['title-small']
                        ?.copyWith(color: MyColors.colorPalette['on_tertiary']),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const HelloWorldApp());
}
