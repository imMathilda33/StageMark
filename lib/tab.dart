import 'package:flutter/material.dart';
import 'calendar.dart'; // 确保你有一个名为calendar.dart的文件，其中定义了Calendar这个widget

class MyTabbedPage extends StatefulWidget {
  @override
  _MyTabbedPageState createState() => _MyTabbedPageState();
}

class _MyTabbedPageState extends State<MyTabbedPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Calendar(), 
          Center(child: Text('Page 2')), 
          Center(child: Text('Page 3')), 
          Center(child: Text('Page 4')), 
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white, 
        padding: EdgeInsets.only(bottom: 16), 
        child: TabBar(
          controller: _tabController,
          unselectedLabelColor: Color.fromARGB(255, 150, 150, 150),
          indicatorColor: Color.fromRGBO(247, 157, 138, 1),
          labelColor: Color.fromRGBO(247, 157, 138, 1),
          tabs: [
            Tab(icon: Icon(Icons.calendar_month)),
            Tab(icon: Icon(Icons.playlist_add)),
            Tab(icon: Icon(Icons.folder_special)),
            Tab(icon: Icon(Icons.edit_note)),
          ],
        ),
      ),
    );
  }
}
