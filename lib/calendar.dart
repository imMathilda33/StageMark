import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  @override
  _CustomHeaderTableCalendarState createState() => _CustomHeaderTableCalendarState();
}

class _CustomHeaderTableCalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Custom Header TableCalendar"),
      // ),
      body: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay; // update `_focusedDay` here as well
          });
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false, // Hide format button
          titleCentered: true,
          // Customize header's title text style as you want
          titleTextStyle: TextStyle(fontSize: 20.0),
          leftChevronIcon: Icon(Icons.chevron_left, size: 30),
          rightChevronIcon: Icon(Icons.chevron_right, size: 30),
        ),
        onHeaderTapped: (date) {
          // When header is tapped, show date picker
          showDatePicker(
            context: context,
            initialDate: _focusedDay,
            firstDate: DateTime.utc(2010, 10, 16),
            lastDate: DateTime.utc(2030, 3, 14),
          ).then((selectedDate) {
            // Check if a date is selected
            if (selectedDate != null) {
              setState(() {
                _focusedDay = selectedDate;
                _selectedDay = selectedDate;
              });
            }
          });
        },
      ),
    );
  }
}