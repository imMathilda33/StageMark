import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailPage extends StatefulWidget {
  dynamic event;
  List<dynamic> selectedDayEvent;
  int index;
  final String eventId;

  EventDetailPage({
    Key? key,
    required this.selectedDayEvent,
    required this.index,
    required this.eventId,
  }) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  // handling deletion of events
  void _deleteEvent(String eventId) async {
    // Confirm the deletion
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Delete'),
              content: Text('Are you sure you want to delete this event?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    // If the user confirms the deletion
    if (confirmDelete) {
      DatabaseReference eventRef = FirebaseDatabase.instance.ref(
          'users/${FirebaseAuth.instance.currentUser!.uid}/events/$eventId');
      await eventRef.remove().then((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Event deleted successfully"),
            duration: Duration(seconds: 2),
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting event: $error"),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }


// show event details
  @override
  Widget build(BuildContext context) {
    String eventId = widget.selectedDayEvent[widget.index]['eventId'];
    return Scaffold(
      drawerScrimColor: null,
      backgroundColor: null,
      appBar: AppBar(
        backgroundColor: null,
        title: Text(widget.selectedDayEvent[widget.index]['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              widget.selectedDayEvent[widget.index]['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: const Color.fromARGB(255, 241, 172, 172),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Time: ${widget.selectedDayEvent[widget.index]['dateTime'].substring(11)}',
                style: TextStyle(
                    fontSize: 20,
                    color: const Color.fromARGB(255, 252, 171, 171)),
              ),
            ),
            Card(
              margin: EdgeInsets.all(20),
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  widget.selectedDayEvent[widget.index]['imageUrl'] != null
                      ? Image.network(
                          widget.selectedDayEvent[widget.index]['imageUrl'],
                          width: 500,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 300,
                          child: Image.asset(
                            'lib/img/default.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                  ListTile(
                    title: Text(
                      widget.selectedDayEvent[widget.index]['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        'Theatre: ${widget.selectedDayEvent[widget.index]['theatre']}'),
                    leading: widget.index != 0
                        ? GestureDetector(
                            onTap: () {
                              if (widget.index != 0) {
                                // Decrement widget.index by 1
                                setState(() {
                                  widget.index -= 1;
                                });
                              }
                            },
                            child: Icon(Icons.chevron_left),
                          )
                        : null,
                    trailing: widget.index != widget.selectedDayEvent.length - 1
                        ? GestureDetector(
                            onTap: () {
                              if (widget.index !=
                                  widget.selectedDayEvent.length - 1) {
                                // Increment widget.index by 1
                                setState(() {
                                  widget.index += 1;
                                });
                              }
                            },
                            child: Icon(Icons.chevron_right),
                          )
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Seat: ${widget.selectedDayEvent[widget.index]['seat']}',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  // ButtonBar(
                  //   alignment: MainAxisAlignment.start,
                  //   children: [
                  //     TextButton(
                  //       onPressed: () {

                  //       },
                  //       child: Text(''),
                  //     ),
                  //     TextButton(
                  //       onPressed: () {

                  //       },
                  //       child: Text(''),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _deleteEvent(eventId),
              child: Text('Delete Event'),
            ),
          ],
        ),
      ),
    );
  }
}
