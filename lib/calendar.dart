import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

// set default date
class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _selectedDayEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchEventsForSelectedDay();
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Use ListView.builder to display the events in _selectedDayEvents
            child: ListView.builder(
              itemCount: _selectedDayEvents.length,
              itemBuilder: (context, index) {
                final event = _selectedDayEvents[index];
                // Customize display content
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    title: Text(event['name'],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date & Time: ${event['dateTime']}'),
                        Text('Seat: ${event['seat']}'),
                        Text('Theatre: ${event['theatre']}'),
                      ],
                    ),
                    trailing: event['imageUrl'] != null
                        ? Image.network(event['imageUrl'],
                            width: 50, height: 50, fit: BoxFit.cover)
                        : null,
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
