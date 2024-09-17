import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'EspVotesPage.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  List<Map<String, String>> voteRecords = [];
  List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  DateTime? selectedDate;
  Timer? _timer;

  // Fetch vote records from the API
  Future<void> fetchVoteRecords() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/voteRecords'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> records = jsonResponse['voteRecords'];

        setState(() {
          voteRecords = List<Map<String, String>>.from(
              records.map((record) => {
                "candidate": record["candidate"].toString(),
                "timestamp": record["timestamp"].toString(),
                "esp8266Id": record["esp8266Id"].toString()
              })
          );
        });
      } else {
        print('Failed to load vote records');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVoteRecords();  // Fetch the vote records when the widget initializes
    // Set up a timer to fetch votes every 10 seconds
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchVoteRecords();
    });
  }
  Map<String, int> getVotesPerEspId() {
    Map<String, int> espVotes = {};

    for (var vote in voteRecords) {
      String espId = vote["esp8266Id"]?.trim() ?? '';

      if (espId.isNotEmpty) {
        espVotes[espId] = (espVotes[espId] ?? 0) + 1;
      }
    }

    return espVotes;
  }

  Map<String, Map<String, int>> getVotesPerDateAndHour() {
    Map<String, Map<String, int>> voteCounts = {};

    for (var vote in voteRecords) {
      String? timestamp = vote["timestamp"]?.trim();

      if (timestamp == null) {
        continue;
      }

      try {
        List<String> parts = timestamp.split(' ');
        String day = parts[0];
        String monthName = parts[1];
        String year = parts[2];
        String time = parts[4] + ' ' + parts[5];
        int month = months.indexOf(monthName) + 1;
        String dateKey = "$year-${month.toString().padLeft(2, '0')}-${day.padLeft(2, '0')}";
        DateTime parsedTime = DateTime.parse("$year-${month.toString().padLeft(2, '0')}-${day.padLeft(2, '0')} ${_convertTimeTo24HourFormat(time)}");
        String hourKey = "${parsedTime.hour.toString().padLeft(2, '0')}";

        if (!voteCounts.containsKey(dateKey)) {
          voteCounts[dateKey] = {};
        }

        if (voteCounts[dateKey]!.containsKey(hourKey)) {
          voteCounts[dateKey]![hourKey] = voteCounts[dateKey]![hourKey]! + 1;
        } else {
          voteCounts[dateKey]![hourKey] = 1;
        }
      } catch (e) {
        print("Error parsing date: $e");
      }
    }

    return voteCounts;
  }

  String _convertTimeTo24HourFormat(String time) {
    List<String> timeParts = time.split(' ');
    String amPm = timeParts[1].toLowerCase();
    List<String> hourMinuteSecond = timeParts[0].split(':');
    int hour = int.parse(hourMinuteSecond[0]);
    String minute = hourMinuteSecond[1];
    String second = hourMinuteSecond[2];

    if (amPm == 'pm' && hour != 12) {
      hour += 12;
    } else if (amPm == 'am' && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, int>> voteCounts = getVotesPerDateAndHour();
    List<Widget> charts = [];

    // Check if selectedDate is valid and update charts
    String? selectedDateKey = selectedDate != null ? _formatDate(selectedDate!) : null;
    if (selectedDateKey != null && voteCounts.containsKey(selectedDateKey)) {
      Map<String, int> hoursMap = voteCounts[selectedDateKey]!;

      List<FlSpot> spots = [];
      List<String> labels = List.generate(24, (index) => "$index:00");  // Generate labels for 24 hours
      for (int hour = 0; hour < 24; hour++) {
        String hourKey = hour.toString().padLeft(2, '0');
        int count = hoursMap[hourKey] ?? 0;  // Use 0 if no votes for that hour
        spots.add(FlSpot(hour.toDouble(), count.toDouble()));
      }

      charts.add(Column(
        children: [
          Text(
            "Votes on $selectedDateKey",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 300,  // Increased height for better visibility
            child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      axisNameWidget: Text(
                        'Time (Hour)',  // Label for the x-axis
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < labels.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(labels[index], style: TextStyle(color: Colors.white, fontSize: 10)),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(
                        'Vote Count',  // Label for the y-axis
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(value.toInt().toString(), style: TextStyle(color: Colors.white, fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 2,
                      color: Colors.blue,
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                    ),
                  ],
                )

            ),
          ),
        ],
      ));
    }

    return Scaffold(
      backgroundColor: Color(0xff10002b),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Color(0xff240046)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () { Navigator.pop(context); },
                    icon: Icon(Icons.keyboard_double_arrow_left, color: Colors.white, size: 40),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "MOUNT ZION SILVER JUBILEE SCHOOL",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "GRAPH",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EspVotesPage(
                            espVotes: getVotesPerEspId(),
                            selectedDate: selectedDate != null ? _formatDate(selectedDate!) : null,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.analytics_outlined, color: Colors.white, size: 40),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text(selectedDate != null ? 'Selected Date: ${_formatDate(selectedDate!)}' : 'Select Date'),
            ),
          ),
          Expanded(
            child: voteRecords.isEmpty
                ? Center(child: CircularProgressIndicator())
                : charts.isEmpty
                ? Center(child: Text('No Data Available', style: TextStyle(color: Colors.white)))
                : ListView(children: charts),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
