import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calendar.dart';
import 'event.dart';
import 'login.dart';
import 'user.dart'; 
import 'function.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class MyTabbedPage extends StatefulWidget {
  @override
  _MyTabbedPageState createState() => _MyTabbedPageState();
}

class _MyTabbedPageState extends State<MyTabbedPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        isLoggedIn = user != null; 
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

// if not logged in, switch to login page
  Widget _getTabContent() {
    return isLoggedIn ? UserPage(tabController: _tabController) : LoginRegisterPage(onLoginSuccess: () {
      setState(() {
        isLoggedIn = true; 
      });
    }, tabController: _tabController,);
  }

  @override
  Widget build(BuildContext context) {
    // Transparent Navigation Bars
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:  Theme.of(context).colorScheme.background,
        statusBarColor: Theme.of(context).colorScheme.background,
      ),
    );

    return Scaffold(
      appBar: null, // Disable the app bar
      // extendBody: true, // Extend the body behind the bottom navigation bar
      // extendBodyBehindAppBar: true,
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            Calendar(),  
            Event(tabController: _tabController,),
            FunctionPage(),
            isLoggedIn ? UserPage(tabController: _tabController) : LoginRegisterPage(tabController: _tabController,),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color:  Colors.white,
        // padding: EdgeInsets.only(bottom: 0),
        child: TabBar(
          controller: _tabController,
          unselectedLabelColor: Color.fromARGB(255, 150, 150, 150),
          indicatorColor: Color.fromRGBO(247, 157, 138, 1),
          labelColor:  Color.fromRGBO(247, 157, 138, 1),
          tabs: [
            Tab(icon: Icon(Icons.calendar_month)),
            Tab(icon: Icon(Icons.playlist_add)),    
            Tab(icon: Icon(Icons.folder_special)),  
            Tab(icon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }
}