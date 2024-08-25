import 'package:flutter/material.dart';
import 'package:grocery_app/Providers/userProvider.dart';
import 'package:grocery_app/Screen/event_details.dart';
import 'package:provider/provider.dart';

class FavoriteEventsScreen extends StatefulWidget {
  @override
  _FavoriteEventsScreenState createState() => _FavoriteEventsScreenState();
}

class _FavoriteEventsScreenState extends State<FavoriteEventsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch favorite events when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchFavoriteEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorite Events',
          style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 4.0, // Slight shadow for AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.red),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: Colors.red));
          }

          if (userProvider.favoriteEventIds.isEmpty) {
            return Center(
              child: Text(
                'No favorite events yet.',
                style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            );
          }

          // Filter events based on favorite IDs
          final favoriteEvents = userProvider.events.where((event) {
            return userProvider.favoriteEventIds.contains(event['_id']);
          }).toList();

          return ListView.builder(
            itemCount: favoriteEvents.length,
            itemBuilder: (context, index) {
              final event = favoriteEvents[index];

              return GestureDetector(
                onTap: () {
                  // Navigate to the EventDetailsScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(eventId: event['_id']),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.black, // Card background color
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 6.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    leading: event['image'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              event['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[900], // Placeholder color
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(Icons.event, color: Colors.red, size: 40),
                          ),
                    title: Text(
                      event['title'] ?? 'No Title',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      event['description'] ?? 'No Description',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis, // Truncate long descriptions
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        // Handle un-favorite action
                        Provider.of<UserProvider>(context, listen: false)
                            .toggleFavorite(event['_id']);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
