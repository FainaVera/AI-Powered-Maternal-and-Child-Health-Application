import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Map<String, dynamic>> reminders = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchReminders();
  }

  Future<void> fetchReminders() async {
    setState(() => isLoading = true);

    try {
      final childResponse = await http.get(
        Uri.parse("http://x.x.x.x:3000/child"), 
      );
      final pregResponse = await http.get(
        Uri.parse("http://x.x.x.x:3000/pregnant"),
      );

      List<Map<String, dynamic>> allRecords = [];
      if (childResponse.statusCode == 200) {
        final childData = List<Map<String, dynamic>>.from(json.decode(childResponse.body));
        allRecords.addAll(childData.map((c) => {...c, "recordType": "Child"}));
      } else {
        print("Failed to fetch child records: ${childResponse.body}");
      }
      if (pregResponse.statusCode == 200) {
        final pregData = List<Map<String, dynamic>>.from(json.decode(pregResponse.body));
        allRecords.addAll(pregData.map((p) => {...p, "recordType": "Pregnant"}));
      } else {
        print("Failed to fetch pregnant records: ${pregResponse.body}");
      }
      final filtered = allRecords.where((r) => (r['nextAppointment'] ?? "").isNotEmpty).toList();
      setState(() {
        reminders = filtered;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching reminders: $e");
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reminders"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchReminders, // manual refresh
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reminders.isEmpty
              ? const Center(child: Text("No upcoming appointments"))
              : RefreshIndicator(
                  onRefresh: fetchReminders,
                  child: ListView.builder(
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final r = reminders[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text("${r['recordType']} - ${r['name']}"),
                          subtitle: Text("Next Appointment: ${r['nextAppointment']}"),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}