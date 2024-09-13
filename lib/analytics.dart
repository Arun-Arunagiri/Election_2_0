import 'package:flutter/material.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
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
                  IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.keyboard_double_arrow_left,color: Colors.white,size: 40,)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("MOUNT ZION SILVER JUBILEE SCHOOL", style: TextStyle(color:Colors.white, fontSize: 20,fontWeight: FontWeight.bold)),
                      Text("ELECTION RESULT", style: TextStyle(color:Colors.white, fontSize: 18,fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Icon(Icons.analytics_outlined,color: Colors.white,size: 40,),
                ],
              ),
              decoration: BoxDecoration(
                  color: Color(0xff0245a4)
              ),
            ),
          ),

        ],
      ),
    );
  }
}
