import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_pregnant_record_screen.dart';

class PregnantRecordsScreen extends StatefulWidget {
  const PregnantRecordsScreen({super.key});
  @override
  State<PregnantRecordsScreen> createState() => _PregnantRecordsScreenState();
}

class _PregnantRecordsScreenState extends State<PregnantRecordsScreen> {
  List<Map<String, dynamic>> records = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchRecords();
  }
  // Fetch all pregnant records from backend
  Future<void> fetchRecords() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("http://x.x.x.x:3000/pregnant"),
      );

      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(json.decode(response.body));
        setState(() {
          records = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Failed to fetch records: ${response.body}");
      }
    } catch (e) {
      print("Error fetching pregnant records: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _addNewRecord() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPregnantRecordScreen()),
    );
    fetchRecords();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pregnant Records"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewRecord,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text("No pregnant records found"))
              : RefreshIndicator(
                  onRefresh: fetchRecords,
                  child: ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(record['name'] ?? 'Unknown'),
                          subtitle: Text(
                              "Age: ${record['age']}, Weeks: ${record['weeks']}\n"
                              "Last Scan: ${record['lastScan'] ?? 'N/A'}, Next Appointment: ${record['nextAppointment'] ?? 'N/A'}\n"
                              "BP: ${record['bp'] ?? 'N/A'}, Sugar: ${record['sugar'] ?? 'N/A'}"),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
