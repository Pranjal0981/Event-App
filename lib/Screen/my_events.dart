import 'package:flutter/material.dart';
import 'package:grocery_app/Providers/userProvider.dart';
import 'package:provider/provider.dart';

class MyEventsScreen extends StatelessWidget {
  static const routeName = '/my-events';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        title: Text('My Events'),
        backgroundColor: Colors.redAccent, // Red accent for the app bar
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Add functionality to refresh the event list
              Provider.of<UserProvider>(context, listen: false).fetchEvents();
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (ctx, eventProvider, _) {
          if (eventProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: Colors.redAccent));
          }

          if (eventProvider.events.isEmpty) {
            return Center(
              child: Text(
                'No events found.',
                style: TextStyle(fontSize: 18, color: Colors.redAccent), // Use red accent for no events text
              ),
            );
          }

          return ListView.builder(
            itemCount: eventProvider.events.length,
            itemBuilder: (ctx, index) {
              final event = eventProvider.events[index];

              // Null checks and default values
              final title = event['title'] ?? 'No title';
              final description = event['description'] ?? 'No description';
              final price = event['price'] != null ? '\$${event['price']}' : 'Free';
              final date = event['date'] != null ? formatDate(event['date']) : 'No date';
              final location = event['location'] ?? 'No location';
              final imageUrl = event['image'] != null ? event['image']['url'] ?? '' : ''; // Handle image URL
              final eventId = event['_id']; // Event ID

              return Card(
                color: Colors.black, // Set card background to black
                elevation: 8, // Increased elevation for a more pronounced shadow
                margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Larger border radius
                ),
                child: Stack(
                  children: [
                    // Image section
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: imageUrl.isNotEmpty
                          ? Stack(
                              children: [
                                Image.network(imageUrl, height: 250, width: double.infinity, fit: BoxFit.cover),
                                Container(
                                  height: 250,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              height: 250,
                              width: double.infinity,
                              color: Colors.grey.shade900,
                              child: Icon(Icons.event, color: Colors.grey.shade700, size: 70),
                            ),
                    ),
                    Positioned(
                      right: 15,
                      top: 15,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent, size: 30),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Confirm Delete'),
                              content: Text('Are you sure you want to delete this event?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm) {
                            try {
                              await eventProvider.deleteEvent(eventId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Event deleted successfully.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to delete event.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20), // Increased padding
                        color: Colors.black.withOpacity(0.7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent), // Larger title text
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  date,
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500), // Larger date text
                                ),
                              ],
                            ),
                            SizedBox(height: 10), // Increased spacing
                            // Description
                            Text(
                              description,
                              style: TextStyle(fontSize: 18, color: Colors.white), // Larger description text
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 10), // Increased spacing
                            // Location and Price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                                    SizedBox(width: 6),
                                    Text(
                                      location,
                                      style: TextStyle(fontSize: 16, color: Colors.grey.shade500), // Larger location text
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Text(
                                  price,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent), // Larger price text
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Utility function to format the date
  String formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final String day = date.day.toString().padLeft(2, '0');
      final String month = date.month.toString().padLeft(2, '0');
      final String year = date.year.toString();

      // Customize the format as needed, e.g., 'dd MMM yyyy'
      return '$day ${_getMonthName(date.month)} $year';
    } catch (e) {
      print('Error formatting date: $e');
      return 'Invalid date';
    }
  }

  String _getMonthName(int month) {
    const List<String> monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }
}
