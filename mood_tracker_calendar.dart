import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodTrackerCalendar extends StatefulWidget {
  const MoodTrackerCalendar({super.key});

  @override
  MoodTrackerCalendarState createState() => MoodTrackerCalendarState();
}

class MoodTrackerCalendarState extends State<MoodTrackerCalendar> {
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mood color definitions
  static const Color happyColor = Color.fromARGB(255, 240, 219, 142);
  static const Color sadColor = Color.fromARGB(255, 139, 173, 228);
  static const Color anxiousColor = Color.fromARGB(255, 171, 137, 215);
  static const Color frustratedColor = Color.fromARGB(255, 210, 118, 117);
  static const Color disgustedColor = Color.fromARGB(255, 133, 190, 130);
  static const Color indifferentColor = Color.fromARGB(255, 154, 154, 154);
  static const Color defaultColor = Color.fromARGB(255, 234, 234, 234);

  final Map<DateTime, String> moodLogs = {
    DateTime(2025, 4, 1): 'happy',
    DateTime(2025, 4, 2): 'sad',
    DateTime(2025, 4, 3): 'anxious',
    DateTime(2025, 4, 4): 'anxious',
    DateTime(2025, 4, 5): 'frustrated',
  };

  final Map<DateTime, String> journalEntries = {
    DateTime(2025, 4, 1, 10, 30): "I CAN'T BELIEVE IT WORKS -Josh",
    DateTime(2025, 4, 2, 18, 45): 'I survived my first hackathon and all I got was this shirt?! (and a super cool app!! :) ) -Finley',
    DateTime(2025, 4, 3, 9, 15): 'Never installing Flutter onto my MacBook EVER AGAIN !!!! -Yabi :D',
  };

  final List<String> _moodOptions = [
    'happy',
    'sad',
    'anxious',
    'frustrated',
    'disgusted',
    'indifferent',
  ];

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('moodi')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) {
                  return false;
                },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showMoodPicker(context, selectedDay);
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                final color = _getColorForMood(date);
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: color.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          if (_selectedDay != null &&
              moodLogs.containsKey(_normalizeDate(_selectedDay!)))
            Text(
              'Mood on ${_selectedDay!.month}/${_selectedDay!.day}: '
              '${moodLogs[_normalizeDate(_selectedDay!)]}',
              style: const TextStyle(fontSize: 18),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildJournalEntriesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddJournalEntryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildJournalEntriesList() {
    if (journalEntries.isEmpty) {
      return const Center(
        child: Text('No journal entries yet. Tap + to add one!'),
      );
    }

    final sortedEntries = journalEntries.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(entry.key),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showAddJournalEntryDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Journal Entry'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'How are you feeling today?',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                final now = DateTime.now();
                final entryDate = DateTime(
                  _selectedDay?.year ?? now.year,
                  _selectedDay?.month ?? now.month,
                  _selectedDay?.day ?? now.day,
                  now.hour,
                  now.minute,
                );
                setState(() {
                  journalEntries[entryDate] = textController.text.trim();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMoodPicker(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select mood for ${date.month}/${date.day}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _moodOptions.map((mood) {
              return ListTile(
                title: Text(mood),
                leading: Icon(
                  Icons.circle,
                  color: _getColorForMoodByMoodString(mood),
                ),
                onTap: () {
                  setState(() {
                    moodLogs[_normalizeDate(date)] = mood;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color _getColorForMood(DateTime date) {
    final mood = moodLogs[_normalizeDate(date)];
    return _getColorForMoodByMoodString(mood);
  }

  Color _getColorForMoodByMoodString(String? mood) {
    switch (mood) {
      case 'happy':
        return happyColor;
      case 'sad':
        return sadColor;
      case 'anxious':
        return anxiousColor;
      case 'frustrated':
        return frustratedColor;
      case 'disgusted':
        return disgustedColor;
      case 'indifferent':
        return indifferentColor;
      default:
        return defaultColor;
    }
  }
}