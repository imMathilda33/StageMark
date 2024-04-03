import 'package:flutter/material.dart';

class EventDetailPage extends StatefulWidget {
  dynamic event;
  List<dynamic> selectedDayEvent;
  int index;

  EventDetailPage({Key? key, required this.selectedDayEvent, required this.index}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor:  null,
      backgroundColor:  null,
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
                color:  const Color.fromARGB(255, 241, 172, 172),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Time: ${widget.selectedDayEvent[widget.index]['dateTime'].substring(11)}',
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
                    subtitle: Text('Theatre: ${widget.selectedDayEvent[widget.index]['theatre']}'),
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
                        if (widget.index != widget.selectedDayEvent.length - 1) {
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
                      style: TextStyle(color:  Colors.black.withOpacity(0.6)),
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
