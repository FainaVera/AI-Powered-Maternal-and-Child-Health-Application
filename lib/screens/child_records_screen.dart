import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'add_child_record_screen.dart';
import '../widgets/language_selector.dart';

class ChildRecordsScreen extends StatefulWidget {
  const ChildRecordsScreen({super.key});
  @override
  State<ChildRecordsScreen> createState() => _ChildRecordsScreenState();
}

class _ChildRecordsScreenState extends State<ChildRecordsScreen> {
  List<Map<String, dynamic>> records = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    try {
      final response =
          await http.get(Uri.parse("http://x.x.x.x:3000/child")); 
      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(json.decode(response.body));
        setState(() {
          records = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching child records: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> navigateToAddRecord() async {
    final newRecord = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddChildRecordScreen()),
    );

    // To prevent duplicates
    if (newRecord != null) {
      setState(() {
        // Check if already exists by comparing a unique field like (name+age)
        final exists = records.any((r) =>
            r['name'] == newRecord['name'] &&
            r['age'] == newRecord['age'] &&
            r['type'] == newRecord['type']);
        if (!exists) records.add(newRecord);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('child_records'.tr()),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: navigateToAddRecord,
          ),
          const LanguageSelector(),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? Center(child: Text('no_records'.tr()))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      title: Text(record['name'] ?? 'Unknown'),
                      subtitle: Text(
                          "Age: ${record['age']}, Weight: ${record['weight']}, Height: ${record['height']}"),
                    );
                  },
                ),
    );
  }
}
