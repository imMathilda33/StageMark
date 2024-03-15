import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class EventsListPage extends StatelessWidget {
  final Map<DateTime, List<dynamic>> allEvents;

  EventsListPage({Key? key, required this.allEvents}) : super(key: key);

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    // Sort allEvents by date first.
    var sortedEvents = allEvents.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    List<Widget> eventTiles = [];
    DateTime? lastAddedDate;

    for (var entry in sortedEvents) {
     // Add a date title if the current date is different from the last date added
      if (lastAddedDate == null || !isSameDay(lastAddedDate, entry.key)) {
        eventTiles.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat('yyyy-MM-dd').format(entry.key), 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                fontSize: 20,
              ),
            ),
          ),
        );
        lastAddedDate = entry.key; // Update the last date added
      }

      // Then add all events under that date
      eventTiles.addAll(
        entry.value.map(
          (event) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            color: Color.fromRGBO(255, 218, 205, 1), 
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              title: Text(
                event['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.grey[800], 
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Date & Time: ${event['dateTime']}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey.withOpacity(0.8), 
                  ),
                ),
              ),
              trailing: event['imageUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(event['imageUrl'],
                          width: 50, height: 50, fit: BoxFit.cover),
                    )
                  : SizedBox(width: 50, height: 50), // Show empty container if there are no images
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('All Events'),
      ),
      body: ListView(
        children: eventTiles,
      ),
    );
  }
}
