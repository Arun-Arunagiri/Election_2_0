import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EspVotesPage extends StatefulWidget {
  final Map<String, int> espVotes;
  final String? selectedDate;

  const EspVotesPage({Key? key, required this.espVotes, this.selectedDate}) : super(key: key);

  @override
  State<EspVotesPage> createState() => _EspVotesPageState();
}

class _EspVotesPageState extends State<EspVotesPage> {
  List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  List<Map<String, String>> voteRecords = [];
  DateTime? selectedDate;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchVoteRecords();  // Fetch the vote records when the widget initializes
    // Set up a timer to fetch votes every 2 seconds
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchVoteRecords();
    });
    // Set the initial selected date if passed from Analytics
    if (widget.selectedDate != null) {
      selectedDate = DateTime.parse(widget.selectedDate!);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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

  // Convert the timestamp to DateTime
  DateTime _parseTimestamp(String timestamp) {
    try {
      List<String> parts = timestamp.split(' ');
      String day = parts[0];
      String monthName = parts[1];
      String year = parts[2];
      String time = parts[4] + ' ' + parts[5];

      int month = months.indexOf(monthName) + 1;
      String formattedDate = "$year-${month.toString().padLeft(2, '0')}-${day.padLeft(2, '0')}";

      DateTime parsedDate = DateTime.parse("$formattedDate ${_convertTimeTo24HourFormat(time)}");
      return parsedDate;
    } catch (e) {
      print("Error parsing timestamp: $e");
      return DateTime.now(); // Fallback to current date
    }
  }

  // Convert time to 24-hour format
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

  // Filter the vote records based on selected date
  Map<String, int> getVotesPerEspIdForDate(DateTime? date) {
    Map<String, int> espVotesForDate = {};

    if (date == null) return espVotesForDate;

    for (var vote in voteRecords) {
      String? timestamp = vote["timestamp"];
      if (timestamp == null) continue;

      DateTime voteDate = _parseTimestamp(timestamp);
      if (voteDate.year == date.year &&
          voteDate.month == date.month &&
          voteDate.day == date.day) {

        String espId = vote["esp8266Id"]?.trim() ?? '';
        if (espId.isNotEmpty) {
          espVotesForDate[espId] = (espVotesForDate[espId] ?? 0) + 1;
        }
      }
    }

    return espVotesForDate;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> filteredEspVotes = getVotesPerEspIdForDate(selectedDate);
    int totalVotes = filteredEspVotes.values.fold(0, (sum, votes) => sum + votes); // Total votes for the day

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          // App bar similar to Analytics page
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Color(0xff0245a4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                        "VOTE MACHINE DETAILS",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Icon(Icons.analytics_outlined, color: Colors.white, size: 40),
                ],
              ),
            ),
          ),
          // Date picker button
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
                    // Update the data after date selection
                    filteredEspVotes = getVotesPerEspIdForDate(selectedDate);
                    totalVotes = filteredEspVotes.values.fold(0, (sum, votes) => sum + votes);
                  });
                }
              },
              child: Text(selectedDate != null ? 'Selected Date: ${_formatDate(selectedDate!)}' : 'Select Date'),
            ),
          ),
          // Display votes from selected date as containers
          Expanded(
            child: filteredEspVotes.isEmpty
                ? Center(child: Text('No Data Available', style: TextStyle(color: Colors.white)))
                : ListView.builder(
              itemCount: filteredEspVotes.length,
              itemBuilder: (context, index) {
                String espId = filteredEspVotes.keys.elementAt(index);
                int voteCount = filteredEspVotes[espId]!;

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ESP ID: $espId', style: TextStyle(color: Colors.white, fontSize: 18)),
                      SizedBox(height: 4),
                      Text('Vote Count: $voteCount', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                );
              },
            ),
          ),
          // Total votes at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Votes on ${selectedDate != null ? _formatDate(selectedDate!) : 'Not Selected'}: $totalVotes',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to format DateTime to yyyy-MM-dd format
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}";
  }
}
