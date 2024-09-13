import 'package:election_2_0/analytics.dart';
import 'package:flutter/material.dart';
import 'package:election_2_0/analytics.dart';




class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int totalVotes = 0;

  List<int> votes = List<int>.filled(8, 0);

  List<String> names = ['ABC','ABC','ABC','ABC','ABC','ABC','ABC','ABC','ABC'];

  List<String> vicenames= ['XYZ','XYZ','XYZ','XYZ','XYZ','XYZ','XYZ','XYZ','XYZ'];

  List<String> imgs = ["images/c1.jpeg","images/c2.jpeg","images/c3.jpeg","images/c4.jpeg","images/c5.jpeg","images/c6.jpeg","images/c7.jpeg","images/c7.jpeg"];

  @override
  void initState() {
    super.initState();

  }

  Widget tile(String name, int vote, String img,String vname) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color:Color(0xffffdec0),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8,right: 12,top: 8,bottom: 8),
              child: CircleAvatar(radius: 40, backgroundImage: AssetImage(img)),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "$name\n$vname",
                  style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("VOTES", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text("$vote", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int voted = votes.reduce((a, b) => a + b);
    int remaining = totalVotes - voted;
    return  Scaffold(
      backgroundColor: Colors.black87,
      //
      body: Column(
        children:[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 60,
              width: MediaQuery.sizeOf(context).width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.home,color: Colors.white,size: 40,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("MOUNT ZION SILVER JUBILEE SCHOOL", style: TextStyle(color:Colors.white, fontSize: 20,fontWeight: FontWeight.bold)),
                      Text("ELECTION RESULT", style: TextStyle(color:Colors.white, fontSize: 18,fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>const Analytics()));}, icon: Icon(Icons.auto_graph_sharp,color: Colors.white,size: 40,))
                ],
              ),
              decoration: BoxDecoration(
                  color: Color(0xff0245a4)
              ),
            ),
          ),
          Expanded(
            child: ListView(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  children: List.generate(8, (index) {
                    return tile(names[index], votes[index], imgs[index],vicenames[index]);
                  }),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              width: MediaQuery.of(context).size.width,
              // height: MediaQuery.sizeOf(context).height/7,
              decoration: BoxDecoration(
                color: Color(0xff0245a4),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
                          Text("Total Votes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:Colors.white)),
                          Text("$totalVotes", style: TextStyle(fontSize: 25, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("Voted", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:Colors.white)),
                        Text("$voted", style: TextStyle(fontSize: 25, color: Colors.white)),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Remaining Votes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:Colors.white)),
                          Text("$remaining", style: TextStyle(fontSize: 25, color: Colors.white)),

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
    ); ;
  }
}
