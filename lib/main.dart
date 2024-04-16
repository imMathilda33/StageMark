import 'package:flutter/material.dart';
import 'tab.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final databaseReference = FirebaseDatabase.instance.ref();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        tabBarTheme: const TabBarTheme(dividerColor: Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      title: 'Your App Name',
      home: MyTabbedPage(),
    );
  }
}

