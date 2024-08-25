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

              return Card(
                color: Colors.black, // Set card background to black
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.redAccent, width: 2), // Red accent border
                ),
                child: InkWell(
                  onTap: () {
                    // Handle event tap if needed
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image section
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: imageUrl.isNotEmpty
                            ? Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover)
                            : Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey.shade900,
                                child: Icon(Icons.event, color: Colors.grey.shade700, size: 50),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
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
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  date,
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Description
                            Text(
                              description,
                              style: TextStyle(fontSize: 16, color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            // Location and Price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      location,
                                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Text(
                                  price,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
