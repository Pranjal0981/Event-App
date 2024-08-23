import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_app/Providers/userProvider.dart'; // Adjust the import path as needed

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Fetch events if not already loaded
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      if (userProvider.events.isEmpty && !userProvider.isLoading) {
        await userProvider.fetchEvents();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
        ],
      ),
      body: _buildBody(userProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await userProvider.fetchEvents();
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody(UserProvider userProvider) {
    if (userProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (userProvider.events.isEmpty) {
      return Center(
        child: Text(
          'No events available',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await userProvider.fetchEvents();
      },
      child: ListView.builder(
        itemCount: userProvider.events.length,
        itemBuilder: (context, index) {
          final event = userProvider.events[index];
          return EventCard(event: event);
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isFavorite = event['isFavorite'] ?? false;

    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            SizedBox(height: 12),
            _buildTitle(),
            SizedBox(height: 8),
            _buildDescription(),
            SizedBox(height: 8),
            _buildLocationAndPrice(),
            SizedBox(height: 8),
            _buildDate(),
            SizedBox(height: 8),
            _buildType(),
            SizedBox(height: 8),
            _buildFavoriteButton(userProvider, isFavorite),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return event['image'] != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              event['image']['url'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[300],
            child: Icon(Icons.image, size: 100, color: Colors.grey),
          );
  }

  Widget _buildTitle() {
    return Text(
      event['title'],
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.red,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      event['description'],
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Colors.grey[700]),
    );
  }

  Widget _buildLocationAndPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Location: ${event['location']}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          '\$${event['price']}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildDate() {
    return Text(
      'Date: ${_formatDate(event['date'])}',
      style: TextStyle(color: Colors.grey[600]),
    );
  }

  Widget _buildType() {
    return Text(
      'Type: ${event['eventType']}',
      style: TextStyle(color: Colors.grey[600]),
    );
  }

  Widget _buildFavoriteButton(UserProvider userProvider, bool isFavorite) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.grey,
        ),
        onPressed: () {
          // userProvider.toggleFavorite(event['_id']);
        },
      ),
    );
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }
}
