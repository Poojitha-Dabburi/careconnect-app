import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HealthGraphScreen extends StatefulWidget {
  final String uid;
  const HealthGraphScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<HealthGraphScreen> createState() => _HealthGraphScreenState();
}

class _HealthGraphScreenState extends State<HealthGraphScreen> {
  Map<String, List<double>> _dailySeverity = {};
  List<String> _datesSorted = [];

  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('health_responses')
        .orderBy('timestamp', descending: false)
        .get();

    final data = snapshot.docs;

    Map<String, List<double>> tempMap = {};

    for (var doc in data) {
      final time = (doc['timestamp'] as Timestamp).toDate();
      final dateStr = DateFormat('yyyy-MM-dd').format(time);
      final severity = (doc['severity'] as num).toDouble();

      tempMap.putIfAbsent(dateStr, () => []).add(severity);
    }

    setState(() {
      _dailySeverity = tempMap;
      _datesSorted = _dailySeverity.keys.toList()..sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lineSpots = _datesSorted.asMap().entries.map((entry) {
      int index = entry.key;
      String date = entry.value;
      List<double> severityList = _dailySeverity[date]!;
      double avg = severityList.reduce((a, b) => a + b) / severityList.length;
      return FlSpot(index.toDouble(), avg);
    }).toList();

    final isImproving = lineSpots.length >= 2 &&
        lineSpots.last.y < lineSpots.first.y;

    final lineColor = isImproving ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Progress Chart',style: TextStyle( fontWeight: FontWeight.w600, color: Colors.white),),
        backgroundColor: isImproving ? Colors.green : Colors.red,
      ),
      body: _datesSorted.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Your Health Trend",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isImproving ? Colors.green : Colors.red),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, _) {
                                if (value == 1) return const Text('Better');
                                if (value == 5) return const Text('Moderate');
                                if (value == 10) return const Text('Worse');
                                return const Text('');
                              },
                              reservedSize: 42,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                if (value.toInt() < _datesSorted.length) {
                                  String date = _datesSorted[value.toInt()];
                                  return Text(DateFormat('MM/dd').format(DateTime.parse(date)),
                                      style: const TextStyle(fontSize: 10));
                                }
                                return const Text('');
                              },
                              interval: 1,
                              reservedSize: 32,
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                        minY: 0,
                        maxY: 10,
                        lineBarsData: [
                          LineChartBarData(
                            spots: lineSpots,
                            isCurved: true,
                            color: lineColor,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: lineColor.withOpacity(0.2),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isImproving ? Colors.green : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isImproving ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isImproving ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isImproving
                                ? "Your health trend is improving!"
                                : "Health severity is increasing. Consider seeking help.",
                            style: TextStyle(
                                fontSize: 16,
                                color: isImproving ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
