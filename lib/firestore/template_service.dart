import 'package:cloud_firestore/cloud_firestore.dart';

class Template {
  final String id;
  final String name;
  final String content;

  Template({
    required this.id,
    required this.name,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
    };
  }

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'],
      name: json['name'],
      content: json['content'],
    );
  }
}

class TemplateService {
  final String clinicId;

  TemplateService(this.clinicId);

  Future<void> addTemplate(Template template) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('templates')
        .doc();

    template = Template(
      id: docRef.id,
      name: template.name,
      content: template.content,
    );

    await docRef.set(template.toJson());
  }

  Future<void> updateTemplate(Template template) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('templates')
        .doc(template.id);

    await docRef.update(template.toJson());
  }

  Future<void> deleteTemplate(String templateId) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('templates')
        .doc(templateId);

    await docRef.delete();
  }

  Future<List<Template>> getTemplates() async {
    final templatesCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('templates');

    final querySnapshot = await templatesCollection.get();
    List<Template> templates = [];

    for (var doc in querySnapshot.docs) {
      templates.add(Template.fromJson(doc.data()));
    }

    return templates;
  }

  Future<List<Template>> searchTemplates(String query) async {
    final templatesCollection = FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('templates');

    final querySnapshot = await templatesCollection.get();
    List<Template> matchingTemplates = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      final templateName = data['name'].toString().toLowerCase();

      if (templateName.startsWith(query.toLowerCase())) {
        matchingTemplates.add(Template.fromJson(data));
      }
    }

    return matchingTemplates;
  }
}
