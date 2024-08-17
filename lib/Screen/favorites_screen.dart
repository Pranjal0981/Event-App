import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Example list of favorite events
    final List<String> favorites = [
      'Event 1',
      'Event 2',
      'Event 3',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(favorites[index]),
            leading: Icon(Icons.favorite, color: Colors.redAccent),
          );
        },
      ),
    );
  }
}
