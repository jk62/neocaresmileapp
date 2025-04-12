import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/template_service.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;

class EditTemplate extends StatefulWidget {
  final String clinicId;
  final Template template;
  final TemplateService templateService;

  const EditTemplate({
    super.key,
    required this.clinicId,
    required this.template,
    required this.templateService,
  });

  @override
  State<EditTemplate> createState() => _EditTemplateState();
}

class _EditTemplateState extends State<EditTemplate> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _contentController;

  bool isUpdatingTemplate = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template.name);
    _contentController = TextEditingController(text: widget.template.content);
  }

  void _updateTemplate() async {
    if (_nameController.text.isEmpty || _contentController.text.isEmpty) {
      _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
      return;
    }

    if (isUpdatingTemplate) {
      return;
    }

    setState(() {
      isUpdatingTemplate = true;
    });

    try {
      Template updatedTemplate = Template(
        id: widget.template.id, // Use template.id here
        name: _nameController.text,
        content: _contentController.text,
      );

      devtools.log('Updating template: ${updatedTemplate.toJson()}');

      await widget.templateService.updateTemplate(updatedTemplate);

      setState(() {
        isUpdatingTemplate = false;
      });

      _showAlertDialog('Success', 'Template updated successfully.', () {
        Navigator.pop(context, updatedTemplate);
      });
    } catch (error) {
      devtools.log('Error updating template: $error');
      setState(() {
        isUpdatingTemplate = false;
      });
      _showAlertDialog(
          'Error', 'An error occurred while updating the template.');
    }
  }

  void _showAlertDialog(String title, String content, [VoidCallback? onOk]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) onOk();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Edit Template',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: MyColors.colorPalette['on-surface'],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Template Name',
                      labelStyle: MyTextStyle.textStyleMap['label-large']
                          ?.copyWith(
                              color:
                                  MyColors.colorPalette['on-surface-variant']),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(
                          color:
                              MyColors.colorPalette['primary'] ?? Colors.black,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(
                          color: MyColors.colorPalette['on-surface-variant'] ??
                              Colors.black,
                        ),
                      ),
                      contentPadding: const EdgeInsets.only(left: 8.0),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'Template Content',
                      labelStyle: MyTextStyle.textStyleMap['label-large']
                          ?.copyWith(
                              color:
                                  MyColors.colorPalette['on-surface-variant']),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(
                          color:
                              MyColors.colorPalette['primary'] ?? Colors.black,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(
                          color: MyColors.colorPalette['on-surface-variant'] ??
                              Colors.black,
                        ),
                      ),
                      contentPadding: const EdgeInsets.only(left: 8.0),
                    ),
                    onChanged: (_) => setState(() {}),
                    maxLines: null, // Allow multiple lines of text
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 48,
                        width: 144,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                MyColors.colorPalette['primary']!),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                side: BorderSide(
                                  color: MyColors.colorPalette['primary']!,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ),
                          onPressed: _updateTemplate,
                          child: Text(
                            'Update',
                            style: MyTextStyle.textStyleMap['label-large']
                                ?.copyWith(
                              color: MyColors.colorPalette['on-primary'],
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      if (isUpdatingTemplate)
                        const Center(
                          child: CircularProgressIndicator(),
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
}
