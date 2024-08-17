import 'package:flutter/material.dart';
import 'filter_sheet.dart'; // Import the new filter file
import 'event_search_delegate.dart'; // Import the search delegate file

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Event> events = [
    Event(
      title: 'Music Concert',
      description: 'Enjoy an evening of live music.',
      date: '2024-08-20',
    ),
    Event(
      title: 'Art Exhibition',
      description: 'Explore modern art and installations.',
      date: '2024-08-25',
    ),
    Event(
      title: 'Food Festival',
      description: 'Taste various cuisines from around the world.',
      date: '2024-09-05',
    ),
  ];

  List<Event> filteredEvents = [];

  @override
  void initState() {
    super.initState();
    filteredEvents = events;
  }

  void _filterEvents(String query) {
    setState(() {
      filteredEvents = events
          .where((event) =>
              event.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7, // Constrain height to 70% of screen height
          ),
          child: FilterSheet(), // Use the FilterSheet widget
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: EventSearchDelegate(
                  onSearch: _filterEvents,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return EventCard(
                    title: event.title,
                    description: event.description,
                    date: event.date,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Event {
  final String title;
  final String description;
  final String date;

  Event({
    required this.title,
    required this.description,
    required this.date,
  });
}

class EventCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;

  EventCard({
    required this.title,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              date,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
