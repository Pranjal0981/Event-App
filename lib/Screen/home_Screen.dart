import 'package:flutter/material.dart';
import 'package:grocery_app/Providers/userProvider.dart';
import 'package:grocery_app/Screen/event_details.dart';
import 'package:grocery_app/Screen/event_search_delegate.dart';
import 'package:grocery_app/Screen/filter_sheet.dart';
import 'package:provider/provider.dart';



class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

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
                  onSearch: (query) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _searchEvents(query);
                    });
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => FilterSheet(),
              );
            },
          ),
        ],
      ),
      body: userProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userProvider.events.length,
              itemBuilder: (context, index) {
                final event = userProvider.events[index];
                return EventCard(event: event);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await userProvider.fetchEvents();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  void _searchEvents(String query) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (query.isNotEmpty) {
      await userProvider.searchEvents(query);
      if (mounted) {
        setState(() {}); // Ensure setState is only called if widget is still mounted
      }
    }
  }
}
class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

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
              _buildFavoriteButton(context, userProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final image = event['image'] is Map<String, dynamic> ? event['image'] as Map<String, dynamic> : null;

    return image != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              image['url'] ?? '',
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
      event['title'] ?? 'No Title',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      event['description'] ?? 'No Description',
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
          'Location: ${event['location'] ?? 'No Location'}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          '\$${event['price'] ?? 0}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildDate() {
    final date = event['date'] as String?;
    final formattedDate = date != null ? _formatDate(date) : 'No Date';

    return Text(
      'Date: $formattedDate',
      style: TextStyle(color: Colors.grey[600]),
    );
  }

  Widget _buildType() {
    return Text(
      'Type: ${event['eventType'] ?? 'No Type'}',
      style: TextStyle(color: Colors.grey[600]),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, UserProvider userProvider) {
    final isFavorite = userProvider.favoriteEventIds.contains(event['_id']);

    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.grey,
        ),
        onPressed: () async {
          try {
            await userProvider.toggleFavorite(event['_id']);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isFavorite ? 'Removed from favorites' : 'Added to favorites')),
            );
          } catch (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update favorite status')),
            );
          }
        },
      ),
    );
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }
}
