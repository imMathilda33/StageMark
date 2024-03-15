import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'event_list.dart';

Map<DateTime, List<dynamic>> allEvents = {};

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

// set default date
class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _selectedDayEvents = [];

  void _showAllEvents() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventsListPage(allEvents: allEvents),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchEventsForSelectedDay();
    _fetchAllEvents();
  }

  void _fetchAllEvents() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref('users/${currentUser.uid}/events');
      DatabaseEvent event = await ref.once();
      final eventsMap = event.snapshot.value as Map<dynamic, dynamic>?;
      if (eventsMap != null) {
        allEvents.clear();
        eventsMap.forEach((key, value) {
          DateTime eventDate = DateTime.parse(value['dateTime']);
          if (allEvents[eventDate] == null) allEvents[eventDate] = [];
          allEvents[eventDate]!.add(value);
        });
        setState(() {}); // Refresh the UI
      }
      print(allEvents);
    }
  }

// fetch the event user has added for the specific
  void _fetchEventsForSelectedDay() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && _selectedDay != null) {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref('users/${currentUser.uid}/events');
      DatabaseEvent event = await ref.once();
      final eventsMap = event.snapshot.value as Map<dynamic, dynamic>?;

      List<dynamic> events = [];
      if (eventsMap != null) {
        eventsMap.forEach((key, value) {
          DateTime eventDate = DateTime.parse(value['dateTime']);
          if (isSameDay(eventDate, _selectedDay)) {
            events.add(value);
          }
        });
      }

      setState(() {
        _selectedDayEvents = events;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _showAllEvents,
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _fetchEventsForSelectedDay();
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (allEvents[date] != null && allEvents[date]!.isNotEmpty) {
                  // 如果这个日期有事件，显示一个下标
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue[400],
                      ),
                      width: 16.0,
                      height: 16.0,
                      child: Center(
                        child: Text(
                          '${allEvents[date]!.length}',
                          style: TextStyle().copyWith(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 20.0),
              leftChevronIcon: Icon(Icons.chevron_left, size: 30),
              rightChevronIcon: Icon(Icons.chevron_right, size: 30),
            ),
            onHeaderTapped: (date) {
              // Show date picker when header is clicked
              showDatePicker(
                context: context,
                initialDate: _focusedDay,
                firstDate: DateTime.utc(2010, 10, 16),
                lastDate: DateTime.utc(2030, 3, 14),
              ).then((selectedDate) {
                // Check if the date is selected
                if (selectedDate != null) {
                  setState(() {
                    _focusedDay = selectedDate;
                    _selectedDay = selectedDate;
                  });
                }
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedDayEvents.length,
              itemBuilder: (context, index) {
                final event = _selectedDayEvents[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  color: Color.fromRGBO(255, 218, 205, 1),// Set the card color
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date & Time: ${event['dateTime']}',
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[800]), 
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Seat: ${event['seat']}',
                            style: TextStyle(
                                fontSize: 14.0, color: Colors.grey[800]),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Theatre: ${event['theatre']}',
                            style: TextStyle(
                                fontSize: 14.0, color: Colors.grey[800]),
                          ),
                        ],
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildEventsMarker(DateTime date, List events) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      color: Color.fromRGBO(247, 157, 138, 1),
    ),
    width: 16.0,
    height: 16.0,
    child: Center(
      child: Text(
        '${events.length}',
        style: TextStyle().copyWith(
          color: Colors.white,
          fontSize: 12.0,
        ),
      ),
    ),
  );
}
