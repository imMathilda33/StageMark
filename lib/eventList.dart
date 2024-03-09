import 'package:flutter/material.dart';

class EventsListPage extends StatelessWidget {
  final Map<DateTime, List<dynamic>> allEvents;

  EventsListPage({Key? key, required this.allEvents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> eventTiles = allEvents.entries.expand((entry) {
      return entry.value.map((event) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
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
                      fontSize: 14.0, color: Colors.grey.withOpacity(0.8)),
                ),
              ),
              trailing: event['imageUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        event['imageUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  : SizedBox(width: 50, height: 50),
            ),
          ));
    }).toList();

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
