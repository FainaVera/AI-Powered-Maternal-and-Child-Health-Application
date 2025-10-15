import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class MalnutritionScreen extends StatefulWidget {
  final List<Map<String, dynamic>> records;
  final Future<void> Function()? onRefresh;
  const MalnutritionScreen({super.key, required this.records, this.onRefresh});
  @override
  State<MalnutritionScreen> createState() => _MalnutritionScreenState();
}

class _MalnutritionScreenState extends State<MalnutritionScreen> {
  late List<Map<String, dynamic>> _records;

  @override
  void initState() {
    super.initState();
    _records = List<Map<String, dynamic>>.from(widget.records);
  }

  Future<void> _refresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
      // To get updated records passed back when returning after refreshing the dash
    }
    setState(() {});
  }

  // WHO Z-score calculation: Z = (observed - median) / standard deviation
  double calculateZScore(double observed, double median, double standardDeviation) {
    if (standardDeviation == 0) return 0;
    return (observed - median) / standardDeviation;
  }

  // Weight-for-Age Z-score calculation
  Map<String, dynamic> calculateWeightForAgeZScore(int ageMonths, double weight, String gender) {
    Map<String, double> reference = getWeightForAgeReference(ageMonths, gender);
    double zScore = calculateZScore(weight, reference['median']!, reference['sd']!);
    String status = getWeightForAgeStatus(zScore);
    return {'zScore': zScore, 'status': status, 'category': 'Weight-for-Age'};
  }

  // Height-for-Age Z-score calculation  
  Map<String, dynamic> calculateHeightForAgeZScore(int ageMonths, double height, String gender) {
    Map<String, double> reference = getHeightForAgeReference(ageMonths, gender);
    double zScore = calculateZScore(height, reference['median']!, reference['sd']!);
    String status = getHeightForAgeStatus(zScore);
    return {'zScore': zScore, 'status': status, 'category': 'Height-for-Age'};
  }

  // Weight-for-Height Z-score calculation
  Map<String, dynamic> calculateWeightForHeightZScore(double height, double weight, String gender) {
    Map<String, double> reference = getWeightForHeightReference(height, gender);
    double zScore = calculateZScore(weight, reference['median']!, reference['sd']!);
    String status = getWeightForHeightStatus(zScore);
    return {'zScore': zScore, 'status': status, 'category': 'Weight-for-Height'};
  }

  // WHO reference data for Weight-for-Age (simplified)
  Map<String, double> getWeightForAgeReference(int ageMonths, String gender) {
    if (gender.toLowerCase() == 'male') {
      if (ageMonths <= 6) return {'median': 7.5, 'sd': 1.1};
      if (ageMonths <= 12) return {'median': 9.6, 'sd': 1.3};
      if (ageMonths <= 24) return {'median': 12.2, 'sd': 1.5};
      if (ageMonths <= 36) return {'median': 14.3, 'sd': 1.7};
      return {'median': 16.3, 'sd': 2.0};
    } else {
      if (ageMonths <= 6) return {'median': 6.9, 'sd': 1.0};
      if (ageMonths <= 12) return {'median': 8.9, 'sd': 1.2};
      if (ageMonths <= 24) return {'median': 11.5, 'sd': 1.4};
      if (ageMonths <= 36) return {'median': 13.9, 'sd': 1.6};
      return {'median': 15.7, 'sd': 1.9};
    }
  }

  // WHO reference data for Height-for-Age
  Map<String, double> getHeightForAgeReference(int ageMonths, String gender) {
    if (gender.toLowerCase() == 'male') {
      if (ageMonths <= 6) return {'median': 67.6, 'sd': 2.6};
      if (ageMonths <= 12) return {'median': 75.7, 'sd': 2.9};
      if (ageMonths <= 24) return {'median': 87.1, 'sd': 3.2};
      if (ageMonths <= 36) return {'median': 96.1, 'sd': 3.5};
      return {'median': 103.3, 'sd': 3.8};
    } else {
      if (ageMonths <= 6) return {'median': 65.7, 'sd': 2.4};
      if (ageMonths <= 12) return {'median': 74.0, 'sd': 2.8};
      if (ageMonths <= 24) return {'median': 85.7, 'sd': 3.1};
      if (ageMonths <= 36) return {'median': 95.1, 'sd': 3.4};
      return {'median': 102.7, 'sd': 3.7};
    }
  }

  // WHO reference data for Weight-for-Height
  Map<String, double> getWeightForHeightReference(double height, String gender) {
    if (gender.toLowerCase() == 'male') {
      if (height < 70) return {'median': 8.5, 'sd': 1.2};
      if (height < 80) return {'median': 10.2, 'sd': 1.4};
      if (height < 90) return {'median': 12.8, 'sd': 1.6};
      if (height < 100) return {'median': 15.2, 'sd': 1.8};
      return {'median': 17.8, 'sd': 2.1};
    } else {
      if (height < 70) return {'median': 8.1, 'sd': 1.1};
      if (height < 80) return {'median': 9.8, 'sd': 1.3};
      if (height < 90) return {'median': 12.2, 'sd': 1.5};
      if (height < 100) return {'median': 14.8, 'sd': 1.7};
      return {'median': 17.2, 'sd': 2.0};
    }
  }

  // Status classification for Weight-for-Age
  String getWeightForAgeStatus(double zScore) {
    if (zScore < -3) return "Severely Underweight";
    if (zScore < -2) return "Moderately Underweight";
    if (zScore >= -2 && zScore <= 2) return "Normal Weight";
    return "Overweight";
  }

  // Status classification for Height-for-Age (Stunting)
  String getHeightForAgeStatus(double zScore) {
    if (zScore < -3) return "Severely Stunted";
    if (zScore < -2) return "Moderately Stunted";
    return "Normal Height";
  }

  // Status classification for Weight-for-Height (Wasting)
  String getWeightForHeightStatus(double zScore) {
    if (zScore < -3) return "Severely Wasted";
    if (zScore < -2) return "Moderately Wasted";
    if (zScore >= -2 && zScore <= 2) return "Normal";
    if (zScore > 2 && zScore <= 3) return "Overweight";
    return "Obese";
  }

  // Get status color based on classification
  Color getStatusColor(String status) {
    if (status.contains("Severe")) return Colors.red[800]!;
    if (status.contains("Moderate")) return Colors.orange[800]!;
    if (status.contains("Normal")) return Colors.green[600]!;
    if (status.contains("Overweight") || status.contains("Obese")) return Colors.blue[600]!;
    return Colors.grey[600]!;
  }
  @override
  Widget build(BuildContext context) {
    final childRecords = _records.where((r) => r['type'] == 'Child').toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("WHO Malnutrition Screening"),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: childRecords.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Icon(Icons.info_outline, size: 64, color: Colors.grey)),
                  SizedBox(height: 16),
                  Center(child: Text("No child records found for analysis")),
                  SizedBox(height: 8),
                  Center(child: Text("Add child records with age, weight, height, and gender")),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: childRecords.length,
                itemBuilder: (context, index) {
                  final record = childRecords[index];
                  return _buildChildAnalysisCard(record);
                },
              ),
      ),
    );
  }

  Widget _buildChildAnalysisCard(Map<String, dynamic> record) {
    final name = record['name']?.toString() ?? 'Unknown';
    final ageMonths = int.tryParse(record['age']?.toString() ?? '') ?? 0;
    final weight = double.tryParse(record['weight']?.toString() ?? '') ?? double.nan;
    final height = double.tryParse(record['height']?.toString() ?? '') ?? double.nan;
    final gender = (record['gender']?.toString() ?? 'Male');

    final hasWeight = weight.isFinite;
    final hasHeight = height.isFinite;
    final hasAge = ageMonths > 0;

    final assessments = <Map<String, dynamic>>[];
    if (hasAge && hasWeight) {
      assessments.add(calculateWeightForAgeZScore(ageMonths, weight, gender));
    }
    if (hasAge && hasHeight) {
      assessments.add(calculateHeightForAgeZScore(ageMonths, height, gender));
    }
    if (hasHeight && hasWeight) {
      assessments.add(calculateWeightForHeightZScore(height, weight, gender));
    }

    return FutureBuilder<String?>(
      future: _fetchAISuggestions(
        name: name,
        ageMonths: ageMonths,
        weightKg: hasWeight ? weight : null,
        heightCm: hasHeight ? height : null,
        gender: gender,
        assessments: assessments,
      ),
      builder: (context, snap) {
        final aiText = snap.connectionState == ConnectionState.done && snap.hasData
            ? snap.data!.trim()
            : null;
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.purple[100],
                      child: Icon(
                        gender.toLowerCase() == 'male' ? Icons.boy : Icons.girl,
                        color: Colors.purple[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$gender • $ageMonths months • ${hasWeight ? '$weight kg' : '–'} • ${hasHeight ? '$height cm' : '–'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                
                // WHO Z-Score Analysis
                Text(
                  'WHO Z-Score Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Weight-for-Age
                if (assessments.isEmpty) ...[
                  Text(
                    'Insufficient data to compute Z-scores',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ] else ...[
                  for (final a in assessments) ...[
                    _buildZScoreIndicator(
                      '${a['category']}',
                      (a['zScore'] as double),
                      (a['status'] as String),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                  _buildOverallAssessment(assessments),
                ],

                // AI suggestions
                const SizedBox(height: 12),
                Text(
                  'Lifestyle Suggestions from AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
                const SizedBox(height: 8),
                if (snap.connectionState == ConnectionState.waiting) ...[
                  Row(children: const [
                    SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('Generating suggestions...'),
                  ]),
                ] else if (aiText != null && aiText.isNotEmpty) ...[
                  Text(aiText),
                ] else ...[
                  Text(
                    'No suggestions available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildZScoreIndicator(String title, double zScore, String status) {
    Color statusColor = getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Z: ${zScore.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getOverallStatus(List<Map<String, dynamic>> assessments) {
    final hasSevere = assessments.any((a) => a['status'].toString().toLowerCase().contains('severe'));
    final hasModerate = assessments.any((a) => a['status'].toString().toLowerCase().contains('moderate'));
    if (hasSevere) return 'Requires Immediate Attention';
    if (hasModerate) return 'Requires Monitoring';
    return 'Normal Growth Pattern';
  }

  Widget _buildOverallAssessment(List<Map<String, dynamic>> assessments) {
    final overallStatus = _getOverallStatus(assessments);

    Color overallColor;
    IconData overallIcon;
    if (overallStatus == 'Requires Immediate Attention') {
      overallColor = Colors.red[700]!;
      overallIcon = Icons.warning;
    } else if (overallStatus == 'Requires Monitoring') {
      overallColor = Colors.orange[700]!;
      overallIcon = Icons.info;
    } else {
      overallColor = Colors.green[600]!;
      overallIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: overallColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: overallColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(overallIcon, color: overallColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Assessment',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  overallStatus,
                  style: TextStyle(
                    color: overallColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _fetchAISuggestions({
    required String name,
    required int ageMonths,
    double? weightKg,
    double? heightCm,
    required String gender,
    required List<Map<String, dynamic>> assessments,
  }) async {
    try {
      final uri = Uri.parse(Config.aiSuggestionsUrl);
      final overallStatus = _getOverallStatus(assessments);
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'ageMonths': ageMonths,
          'weightKg': weightKg,
          'heightCm': heightCm,
          'gender': gender,
          'overall': overallStatus,
          'assessments': assessments,
        }),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return data['suggestions']?.toString();
      } else {
        print('AI suggestions HTTP ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      print('AI suggestions error: $e');
    }
    return null;
  }
}
