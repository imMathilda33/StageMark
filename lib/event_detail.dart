import 'package:flutter/material.dart';

class EventDetailPage extends StatefulWidget {
  final dynamic event;

  EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              widget.event['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: const Color.fromARGB(255, 241, 172, 172), 
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Time: ${widget.event['dateTime'].substring(11)}', 
                style: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 252, 171, 171)),
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
                  widget.event['imageUrl'] != null
                      ? Image.network(
                          widget.event['imageUrl'],
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
                      widget.event['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Theatre: ${widget.event['theatre']}'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Seat: ${widget.event['seat']}',
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
          ],
        ),
      ),
    );
  }
}
