import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import '../widgets/language_selector.dart';

class AddChildRecordScreen extends StatefulWidget {
  const AddChildRecordScreen({super.key});
  @override
  State<AddChildRecordScreen> createState() => _AddChildRecordScreenState();
}

class _AddChildRecordScreenState extends State<AddChildRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int age = 0;
  double weight = 0;
  double height = 0;
  String gender = 'Male';
  String nextAppointment = '';
  bool isSubmitting = false; // Prevent duplicate submissions

  Future<void> submitRecord() async {
    if (!_formKey.currentState!.validate()) return;
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    _formKey.currentState!.save();

    final record = {
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'nextAppointment': nextAppointment,
      'type': 'Child',
    };

    try {
      final response = await http.post(
        Uri.parse('http://x.x.x.x:3000/child'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(record),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('child_record_added'.tr())),
        );
        Navigator.pop(context, record); // Return to prev screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'failed_save'.tr()}: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'network_error'.tr()}: $e')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_child_record'.tr()),
        backgroundColor: Colors.teal,
        actions: const [
          LanguageSelector(),
          SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'name'.tr()),
                validator: (val) => val == null || val.isEmpty ? 'enter_name'.tr() : null,
                onSaved: (val) => name = val ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'age'.tr()),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'enter_age'.tr() : null,
                onSaved: (val) => age = int.tryParse(val ?? '0') ?? 0,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'weight'.tr()),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'enter_weight'.tr() : null,
                onSaved: (val) => weight = double.tryParse(val ?? '0') ?? 0,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'height'.tr()),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'enter_height'.tr() : null,
                onSaved: (val) => height = double.tryParse(val ?? '0') ?? 0,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'gender'.tr()),
                initialValue: gender,
                items: [
                  DropdownMenuItem(value: 'Male', child: Text('male'.tr())),
                  DropdownMenuItem(value: 'Female', child: Text('female'.tr())),
                ],
                onChanged: (value) => setState(() => gender = value ?? 'Male'),
                validator: (val) => val == null ? 'select_gender'.tr() : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'next_appointment'.tr()),
                validator: (val) => val == null || val.isEmpty ? 'enter_appointment'.tr() : null,
                onSaved: (val) => nextAppointment = val ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : submitRecord,
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('submit'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
