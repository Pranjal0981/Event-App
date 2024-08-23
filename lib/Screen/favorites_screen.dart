import 'package:flutter/material.dart';
import 'package:grocery_app/Providers/userProvider.dart';
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
        title: Text('Favorite Events'),
        backgroundColor: Colors.black,
        elevation: 0, // Remove shadow for a flat look
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
            return Center(child: CircularProgressIndicator());
          }

          if (userProvider.favoriteEventIds.isEmpty) {
            return Center(
              child: Text(
                'No favorite events yet.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          final favoriteEvents = userProvider.events.where((event) {
            return userProvider.favoriteEventIds.contains(event['_id']);
          }).toList();

          return ListView.builder(
            itemCount: favoriteEvents.length,
            itemBuilder: (context, index) {
              final event = favoriteEvents[index];
              return Card(
                color: Colors.black, // Card background color
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4.0,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  leading: event['image'] != null
                      ? Image.network(
                          event['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : SizedBox(width: 60, height: 60),
                  title: Text(
                    event['title'] ?? 'No Title',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    event['description'] ?? 'No Description',
                    style: TextStyle(color: Colors.grey[400]), // Lighter gray for subtitle
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
              );
            },
          );
        },
      ),
    );
  }
}
