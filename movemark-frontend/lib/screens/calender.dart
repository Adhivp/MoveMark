import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // List of holidays (you can add more dates as needed)
  final List<DateTime> _holidays = [
    DateTime.utc(2023, 1, 1), // New Year's Day
    DateTime.utc(2023, 12, 25), // Christmas Day
    DateTime.utc(2023, 7, 4), // Independence Day (example)
    DateTime.utc(2023, 10, 31), // Halloween (example)
  ];

  // Function to check if a day is a holiday
  bool _isHoliday(DateTime day) {
    return _holidays.any((holiday) => isSameDay(holiday, day));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                // Add events for holidays
                if (_isHoliday(day)) {
                  return ['Holiday'];
                }
                return [];
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  // Check if the day is a Sunday or a holiday
                  if (day.weekday == DateTime.sunday || _isHoliday(day)) {
                    return Center(
                      child: Tooltip(
                        message: _isHoliday(day) ? 'Holiday' : 'Sunday',
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  return null; // Use default styling for other days
                },
              ),
            ),
            SizedBox(height: 20),
            if (_selectedDay != null)
              Text(
                'Selected Day: ${DateFormat('yyyy-MM-dd').format(_selectedDay!)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
