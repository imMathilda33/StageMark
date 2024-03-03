import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Event extends StatefulWidget {
  @override
  _EventState createState() => _EventState();
}

class _EventState extends State<Event> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _seatController = TextEditingController();
  final TextEditingController _theatreController = TextEditingController();
  bool _isFieldEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add to Calendar'),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.more_vert),
          //   onPressed: () {
          //     // Action for the button
          //   },
          // ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _searchController,
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
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _dateTimeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Date & time',
                hintText: 'Select a Date',
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2010),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                  setState(() {
                    _dateTimeController.text = formattedDate;
                  });
                }
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _seatController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Seat',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _theatreController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Theatre',
              ),
            ),
            SizedBox(height: 16.0),
            if (_isFieldEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Please fill in all fields',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: 50, 
              height: 36, 
              child: ElevatedButton(
                onPressed: () {
                  _submitData();
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitData() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String search = _searchController.text;
      String name = _nameController.text;
      String dateTime = _dateTimeController.text;
      String seat = _seatController.text;
      String theatre = _theatreController.text;
      if (search.isNotEmpty &&
          name.isNotEmpty &&
          dateTime.isNotEmpty &&
          seat.isNotEmpty &&
          theatre.isNotEmpty) {
        print('Submitted Data: $search, $name, $dateTime, $seat, $theatre');
        setState(() {
          _isFieldEmpty = false;
        });
      } else {
        setState(() {
          _isFieldEmpty = true;
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Not Logged In'),
          content: Text('Please log in to submit data.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginRegisterPage()));
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _dateTimeController.dispose();
    _seatController.dispose();
    _theatreController.dispose();
    super.dispose();
  }
}
