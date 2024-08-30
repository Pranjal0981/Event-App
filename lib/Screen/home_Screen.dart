import 'dart:ui';
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
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Events', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
        backgroundColor: Colors.black, // AppBar background color
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
                isScrollControlled: true
              );
            },
          ),
        ],
      ),
      body: userProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : userProvider.events.isEmpty
              ? Center(child: Text('No events available', style: Theme.of(context).textTheme.bodyMedium))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10),
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
        backgroundColor: Colors.red, // FloatingActionButton color
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(eventId: event['_id']),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black, // Card color
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color.fromARGB(255, 45, 209, 198)!), // Card border color
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageWithOverlay(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationAndPrice(),
                  SizedBox(height: 10),
                  _buildDate(),
                  SizedBox(height: 10),
                  _buildType(),
                ],
              ),
            ),
            _buildFavoriteButton(context, userProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithOverlay() {
    final image = event['image'] is Map<String, dynamic> ? event['image'] as Map<String, dynamic> : null;

    return Stack(
      children: [
        image != null
            ? ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  image['url'] ?? '',
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                height: 220,
                width: double.infinity,
                color: Colors.grey[700],
                child: Center(
                  child: Icon(Icons.image, size: 100, color: Colors.grey[400]),
                ),
              ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.4), // Blur overlay color
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event['title'] ?? 'No Title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white, // Overlay text color
                ),
              ),
              SizedBox(height: 4),
              Text(
                event['description'] ?? 'No Description',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[300], // Overlay text color
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAndPrice() {
    return Container(
      padding: EdgeInsets.all(8),
    
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Location: ${event['location'] ?? 'No Location'}',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          Text(
            '\Rs ${event['price'] ?? 0}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red, // Price color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDate() {
    final date = event['date'] as String?;
    final formattedDate = date != null ? _formatDate(date) : 'No Date';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(8),
    
      child: Text(
        'Date: $formattedDate',
        style: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildType() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(8),
    
      child: Text(
        'Type: ${event['eventType'] ?? 'No Type'}',
        style: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, UserProvider userProvider) {
    final isFavorite = userProvider.favoriteEventIds.contains(event['_id']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
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
      ),
    );
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }
}
