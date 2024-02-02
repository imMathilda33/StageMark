import 'package:flutter/material.dart';
import 'tab.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
