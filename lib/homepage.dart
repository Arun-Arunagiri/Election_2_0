import 'dart:async';  // For Timer
import 'dart:convert';  // For JSON decoding
import 'package:election_2_0/glass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'analytics.dart';

class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}
class _HomepageState extends State<Homepage> {
  int totalVotes = 0;
  List<int> votes = List<int>.filled(8, 0);
  List<String> names = ['ABC', 'ABC', 'ABC', 'ABC', 'ABC', 'ABC', 'ABC', 'ABC'];
  List<String> vicenames = ['XYZ', 'XYZ', 'XYZ', 'XYZ', 'XYZ', 'XYZ', 'XYZ', 'XYZ'];
  List<String> imgs = ["images/c1.jpeg", "images/c2.jpeg", "images/c3.jpeg", "images/c4.jpeg", "images/c5.jpeg", "images/c6.jpeg", "images/c7.jpeg", "images/c7.jpeg"];
  bool isLoading = true;
  String errorMessage = '';
  Timer? _timer;

  //for fetching votes
  @override
  void initState() {
    super.initState();
    fetchVotes();
    // Set up a timer to fetch votes every 10 seconds
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchVotes();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchVotes() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/votes'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        final List<dynamic> votesFromResponse = responseBody['votes'];
        final int totalVotesFromResponse = responseBody['totalVotes'];

        setState(() {
          votes = List<int>.from(votesFromResponse.map((x) => int.parse(x.toString())));
          totalVotes = 400;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load votes';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching votes: $error';
        isLoading = false;
      });
    }
  }

  Widget tile(String name, int vote, String img, String vname) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Glassmorph(
        blur: 0.2,
        opacity: 0.15,
        child: Container(
          height: 100,
          width: MediaQuery.of(context).size.width < 800
              ? MediaQuery.of(context).size.width * 0.95
              : MediaQuery.of(context).size.width * 0.65,
          decoration: BoxDecoration(
            // color: Color(0xffe0aaff),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 8, right: 12, top: 8, bottom: 8),
                child:
                    CircleAvatar(radius: 40, backgroundImage: AssetImage(img)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    "$name\n$vname",
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("VOTES",
                        style: TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    Text("$vote",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 35)),
                    SizedBox(
                      width: 120,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int voted = votes.reduce((a, b) => a + b);
    int remaining = totalVotes - voted;
    return Scaffold(
      // backgroundColor: Color(0xff10002b),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xff10002b), Color(0xff7A1CAC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.25, 1.0])),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.home, color: Colors.white, size: 40),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("MOUNT ZION SILVER JUBILEE SCHOOL",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text("ELECTION RESULT",
                            style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Analytics()));
                        },
                        icon: Icon(Icons.auto_graph_sharp,
                            color: Colors.white, size: 40)),
                  ],
                ),
                decoration: BoxDecoration(color: Color(0xff240046)),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Column(
                    children: List.generate(8, (index) {
                      return tile(names[index], votes[index], imgs[index],
                          vicenames[index]);
                    }),
                  ),
                ],
              ),
            ),
            //bottom details container
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xff240046),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Total Votes",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow)),
                            Text("$totalVotes",
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Voted",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow)),
                          Text("$voted",
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white)),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Remaining Votes",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow)),
                            Text("$remaining",
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
