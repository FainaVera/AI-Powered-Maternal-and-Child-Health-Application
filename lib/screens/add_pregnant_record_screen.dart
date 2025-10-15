import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import '../widgets/language_selector.dart';

class AddPregnantRecordScreen extends StatefulWidget {
  const AddPregnantRecordScreen({super.key});
  @override
  State<AddPregnantRecordScreen> createState() => _AddPregnantRecordScreenState();
}

class _AddPregnantRecordScreenState extends State<AddPregnantRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int age = 0;
  int weeks = 0;
  String lastScan = '';
  String nextAppointment = '';
  String bp = '';
  String sugar = '';

  Future<void> submitRecord() async {
    final record = {
      'name': name,
      'age': age,
      'weeks': weeks,
      'lastScan': lastScan,
      'nextAppointment': nextAppointment,
      'bp': bp,
      'sugar': sugar,
      'type': 'Pregnant Lady',
    };

    try {
      final response = await http.post(
        Uri.parse('http://x.x.x.x:3000/pregnant'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(record),
      );

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('pregnant_record_added'.tr())),
        );
        Navigator.pop(context, record);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed: ${response.body}')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Network error: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_pregnant_record'.tr()),
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
                onChanged: (val) => name = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'age'.tr()),
                keyboardType: TextInputType.number,
                onChanged: (val) => age = int.tryParse(val) ?? 0,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'weeks_pregnant'.tr()),
                keyboardType: TextInputType.number,
                onChanged: (val) => weeks = int.tryParse(val) ?? 0,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'last_scan_date'.tr()),
                onChanged: (val) => lastScan = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'next_appointment'.tr()),
                onChanged: (val) => nextAppointment = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'blood_pressure'.tr()),
                onChanged: (val) => bp = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'sugar_level'.tr()),
                onChanged: (val) => sugar = val,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitRecord,
                child: Text('submit'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}