import 'package:flutter/material.dart';

class Event extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add to Calendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Action for the button
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16.0),
            Text('Or enter manually:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Date & time',
                hintText: 'Select a Date',
              ),
              onTap: () {
                // Action to show date picker
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Seat',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Theatre',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
