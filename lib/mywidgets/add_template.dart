import 'package:flutter/material.dart';
import 'package:neocaresmileapp/firestore/template_service.dart';
import 'package:neocaresmileapp/mywidgets/edit_template.dart';
import 'package:neocaresmileapp/mywidgets/mycolors.dart';
import 'package:neocaresmileapp/mywidgets/mytextstyle.dart';
import 'dart:developer' as devtools show log;
import 'package:uuid/uuid.dart';

class AddTemplate extends StatefulWidget {
  final String clinicId;
  final String doctorId;
  final String doctorName;

  const AddTemplate({
    super.key,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<AddTemplate> createState() => _AddTemplateState();
}

class _AddTemplateState extends State<AddTemplate> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool isAddingTemplate = false;
  bool addingNewTemplate = false;
  bool hasUserInput = false;
  String previousSearchInput = '';
  late TemplateService templateService;

  List<Template> matchingTemplates = [];

  @override
  void initState() {
    super.initState();
    addingNewTemplate = false;
    templateService = TemplateService(widget.clinicId);
  }

  void handleSearchInput(String userInput) async {
    setState(() {
      hasUserInput = userInput.isNotEmpty;
      previousSearchInput = userInput;
    });

    if (userInput.isEmpty) {
      setState(() {
        matchingTemplates.clear();
        return;
      });
    }

    setState(() {
      matchingTemplates.clear();
    });

    matchingTemplates = await templateService.searchTemplates(userInput);
    setState(() {});
  }

  void handleSelectedTemplate(Template template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTemplate(
          clinicId: widget.clinicId, // Pass the clinic ID
          template: template, // Pass the selected Template object
          templateService: templateService, // Pass the TemplateService instance
        ),
      ),
    ).then((updatedTemplate) {
      if (updatedTemplate != null) {
        setState(() {
          int index =
              matchingTemplates.indexWhere((t) => t.id == updatedTemplate.id);
          if (index != -1) {
            matchingTemplates[index] = updatedTemplate;
          }
        });
      }
    });
  }

  void deleteTemplate(Template template) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete ${template.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await templateService.deleteTemplate(template.id);
              Navigator.pop(context);
              setState(() {
                matchingTemplates.remove(template);
              });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addNewTemplate() async {
    if (_nameController.text.isEmpty || _contentController.text.isEmpty) {
      _showAlertDialog('Invalid Input', 'Please fill in all required fields.');
      return;
    }

    if (isAddingTemplate) {
      return;
    }

    setState(() {
      isAddingTemplate = true;
    });

    try {
      String templateId = const Uuid().v4();
      Template newTemplate = Template(
        id: templateId,
        name: _nameController.text,
        content: _contentController.text,
      );

      await templateService.addTemplate(newTemplate);

      setState(() {
        isAddingTemplate = false;
        addingNewTemplate = false;
        _nameController.clear();
        _contentController.clear();
        handleSearchInput(previousSearchInput);
      });

      _showAlertDialog('Success', 'Template added successfully.');
    } catch (error) {
      devtools.log('Error adding new template: $error');
      _showAlertDialog('Error', 'An error occurred while adding the template.');
      setState(() {
        isAddingTemplate = false;
      });
    }
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget buildAddNewTemplateUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Add Template',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              addingNewTemplate = false;
            });
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
                          onPressed: _addNewTemplate,
                          child: Text(
                            'Add Template',
                            style: MyTextStyle.textStyleMap['label-large']
                                ?.copyWith(
                              color: MyColors.colorPalette['on-primary'],
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            addingNewTemplate = false;
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                      if (isAddingTemplate)
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

  Widget buildSearchUI() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.colorPalette['surface-container-lowest'],
        title: Text(
          'Search Templates',
          style: MyTextStyle.textStyleMap['title-large']
              ?.copyWith(color: MyColors.colorPalette['on-surface']),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              addingNewTemplate = false;
              _searchController.clear();
              Navigator.pop(context);
            });
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
            child: SizedBox(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    handleSearchInput(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Enter template name',
                  labelStyle: MyTextStyle.textStyleMap['label-large']?.copyWith(
                      color: MyColors.colorPalette['on-surface-variant']),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                      color: MyColors.colorPalette['primary'] ?? Colors.black,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                        color: MyColors.colorPalette['on-surface-variant'] ??
                            Colors.black),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
                ),
              ),
            ),
          ),
          if (hasUserInput && matchingTemplates.isNotEmpty) ...[
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Existing Templates',
                            style: MyTextStyle.textStyleMap['title-large']
                                ?.copyWith(
                                    color: MyColors.colorPalette['on-surface']),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          for (var template in matchingTemplates)
                            InkWell(
                              onLongPress: () {
                                deleteTemplate(template);
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text(
                                    template.name,
                                    style: MyTextStyle
                                        .textStyleMap['label-medium']
                                        ?.copyWith(
                                            color: MyColors
                                                .colorPalette['on_surface']),
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      handleSelectedTemplate(template);
                                    },
                                    child: CircleAvatar(
                                      radius: 13.33,
                                      backgroundColor:
                                          MyColors.colorPalette['surface'] ??
                                              Colors.blueAccent,
                                      child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      MyColors.colorPalette['on-primary']!),
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
                                  setState(() {
                                    addingNewTemplate = true;
                                    hasUserInput = false;
                                    matchingTemplates.clear();
                                  });
                                },
                                child: Wrap(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: MyColors.colorPalette['primary'],
                                    ),
                                    Text(
                                      'Add New',
                                      style: MyTextStyle
                                          .textStyleMap['label-large']
                                          ?.copyWith(
                                              color: MyColors
                                                  .colorPalette['primary']),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else if (hasUserInput && matchingTemplates.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'No matching template found',
                  style: MyTextStyle.textStyleMap['label-medium']
                      ?.copyWith(color: MyColors.colorPalette['on_surface']),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        MyColors.colorPalette['on-primary']!),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        side: BorderSide(
                            color: MyColors.colorPalette['primary']!,
                            width: 1.0),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      addingNewTemplate = true;
                      hasUserInput = false;
                      matchingTemplates.clear();
                    });
                  },
                  child: Wrap(
                    children: [
                      Icon(
                        Icons.add,
                        color: MyColors.colorPalette['primary'],
                      ),
                      Text(
                        'Add New',
                        style: MyTextStyle.textStyleMap['label-large']
                            ?.copyWith(color: MyColors.colorPalette['primary']),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (addingNewTemplate) {
      return buildAddNewTemplateUI();
    }

    return buildSearchUI();
  }
}
