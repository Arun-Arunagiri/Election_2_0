import 'package:election_2_0/homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';

class Loginpage extends StatelessWidget {
  Loginpage({super.key});

  final String uname = "admin";
  final String password="SuperNova&4724";
  //textfield controller
  final unamecontroller =TextEditingController();
  final passwordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff10002b), 
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 60,
              width: MediaQuery.sizeOf(context).width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("MOUNT ZION SILVER JUBILEE SCHOOL",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  Text("ELECTION RESULT",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              decoration: BoxDecoration(
                  color: Color(0xff240046)
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.30,
          ),
          //login deatails container
          Container(
              width: MediaQuery.of(context).size.width < 800
                  ? MediaQuery.of(context).size.width * 0.45
                  : MediaQuery.of(context).size.width * 0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Color(0xff9d4edd),
              ),
              child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                          controller: unamecontroller,
                          
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 2.0),
                            ),
                            labelText: 'User Name',
                            hintText: 'Enter Your Name',
                            hintStyle: TextStyle(color: Colors.white),
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                          controller: passwordcontroller,
                          style: TextStyle(color: Colors.white),
                          obscureText: true,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 2.0),
                              ),
                            border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 2.0),
                              ),
                            labelText: 'Password',
                            hintText: 'Enter Password',
                              hintStyle: TextStyle(color: Colors.white),
                              labelStyle: TextStyle(color: Colors.white)
                          ),
                        ),
                      ),
                      ElevatedButton(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0,bottom: 10.0,left: 5.0,right: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("LOGIN",style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                    color: Colors.black
                              ),)
                            ],
                          ),
                        ),
                        onPressed: (){
                          if(unamecontroller.text==uname && passwordcontroller.text==password){
                            print("login");
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  Homepage()),);
                          }
                        },
                      ),
                    ],
                  )
              )
          ),
        ],
      ),
    );
  }
}
