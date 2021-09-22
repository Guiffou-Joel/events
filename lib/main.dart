import 'package:events/screens/launch_screen.dart';
import 'package:events/screens/login_screen.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:events/screens/event_screen.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Future testData() async {
    Firestore db = Firestore.instance;

    var data = await db.collection("event_details").getDocuments();
    if (data != null) {
      var details = data.documents.toList();
      details.forEach((document) {
        print(document.documentID);
      });
    } else {
      print("data is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    testData();
    return MaterialApp(
      title: 'Events',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      // home: EventScreen(),
      // home: LoginScreen(),
      home: LaunchScreen(),
    );
  }
}
