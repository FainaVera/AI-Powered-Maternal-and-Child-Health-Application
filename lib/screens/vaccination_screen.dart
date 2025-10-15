import 'package:flutter/material.dart';

class VaccinationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> records;
  const VaccinationScreen({super.key, required this.records});
  @override
  Widget build(BuildContext context) {
    final vaccinationRecords = records.where((r) => r['nextAppointment'] != null).toList();
    return Scaffold(
      appBar: AppBar(title: const Text("Vaccinations")),
      body: vaccinationRecords.isEmpty
          ? const Center(child: Text("No vaccination records found"))
          : ListView.builder(
              itemCount: vaccinationRecords.length,
              itemBuilder: (context, index) {
                final r = vaccinationRecords[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.medical_services, color: Colors.green),
                    title: Text(r['name']?.toString() ?? 'Unknown'),
                    subtitle: Text("Next Appointment: ${r['nextAppointment']}"),
                  ),
                );
              },
            ),
    );
  }
}
