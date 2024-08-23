import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_app/Providers/userProvider.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.currentEvent == null || userProvider.currentEvent!['_id'] != widget.eventId) {
        userProvider.fetchEventById(widget.eventId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: userProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : userProvider.currentEvent == null
              ? Center(child: Text('Event not found', style: TextStyle(color: Colors.red, fontSize: 18)))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImage(userProvider.currentEvent!),
                            SizedBox(height: 16),
                            _buildTitle(userProvider.currentEvent!),
                            SizedBox(height: 12),
                            _buildDescription(userProvider.currentEvent!),
                          ],
                        ),
                      ),
                    ),
                    _buildLocationAndDate(userProvider.currentEvent!),
                    SizedBox(height: 16),
                    _buildBookTicketsButton(),
                  ],
                ),
    );
  }

  Widget _buildImage(Map<String, dynamic> event) {
    final image = event['image'] as Map<String, dynamic>?;

    return image != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image['url'] ?? '',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.image, size: 150, color: Colors.red),
          );
  }

  Widget _buildTitle(Map<String, dynamic> event) {
    return Text(
      event['title'] ?? 'No Title',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        color: Colors.red,
      ),
    );
  }

  Widget _buildDescription(Map<String, dynamic> event) {
    return Text(
      event['description'] ?? 'No Description',
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 16,
      ),
    );
  }

  Widget _buildLocationAndDate(Map<String, dynamic> event) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location: ${event['location'] ?? 'No Location'}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Date: ${_formatDate(event['date'] ?? '')}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookTicketsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle the booking action
          _showBookingDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // Button color
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Book Tickets',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Book Tickets'),
          content: Text('Would you like to proceed with booking tickets for this event?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to the booking page or show booking options
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Handle the booking confirmation
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }
}
