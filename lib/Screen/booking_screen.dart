import 'dart:convert'; // For base64 decoding
import 'package:flutter/material.dart';
import 'package:grocery_app/Providers/userProvider.dart';
import 'package:provider/provider.dart';

class BookingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        backgroundColor: Colors.black, // Black AppBar
        iconTheme: IconThemeData(color: Colors.red), // Red icons in the AppBar
      ),
      body: FutureBuilder<void>(
        future: userProvider.fetchBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (userProvider.bookings.isEmpty) {
            return Center(child: Text('No bookings found.'));
          } else {
            return ListView.builder(
              itemCount: userProvider.bookings.length,
              itemBuilder: (context, index) {
                final booking = userProvider.bookings[index];
                final event = booking['eventId'];
                final user = booking['userId'];
                final qrCode = booking['qrCode'];

                return BookingCard(
                  event: event,
                  user: user,
                  qrCode: qrCode,
                  booking: booking,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class BookingCard extends StatefulWidget {
  final Map<String, dynamic>? event;
  final Map<String, dynamic>? user;
  final String? qrCode;
  final Map<String, dynamic> booking;

  BookingCard({
    required this.event,
    required this.user,
    required this.qrCode,
    required this.booking,
  });

  @override
  _BookingCardState createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _borderWidthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..forward();
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _borderColorAnimation = ColorTween(
      begin: Colors.red,
      end: const Color.fromARGB(255, 126, 127, 95),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _borderWidthAnimation = Tween<double>(begin: 2.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final user = widget.user;
    final qrCode = widget.qrCode;
    final booking = widget.booking;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _borderColorAnimation.value!,
                  width: _borderWidthAnimation.value,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                color: Colors.black, // Black card background
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event != null ? event['title'] ?? 'No Event Title' : 'No Event Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.red, // Red title text
                        ),
                      ),
                      SizedBox(height: 8.0),
                      _buildAnimatedText('Description: ${event != null ? event['description'] ?? 'No Description' : 'N/A'}'),
                      SizedBox(height: 8.0),
                      _buildAnimatedText('Date: ${event != null ? event['date'] != null ? DateTime.parse(event['date']).toLocal().toString() : 'No Date' : 'N/A'}'),
                      SizedBox(height: 8.0),
                      _buildAnimatedText('Booked by: ${user != null ? "${user['firstName'] ?? 'No First Name'} ${user['lastName'] ?? 'No Last Name'}" : 'No User Name'}'),
                      SizedBox(height: 8.0),
                      _buildAnimatedText('Email: ${user != null ? user['email'] ?? 'No Email' : 'N/A'}'),
                      SizedBox(height: 8.0),
                      _buildAnimatedText('Number of People: ${booking['numberOfPeople'] ?? 'N/A'}'),
                      SizedBox(height: 8.0),
                      _buildAnimatedText('Verified: ${booking['isVerified'] ? 'Yes' : 'No'}',
                        textStyle: TextStyle(
                          color: booking['isVerified'] ? Colors.red : Colors.white, // Red if verified, white if not
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      qrCode != null
                          ? _buildQrCodeButton(context, qrCode)
                          : SizedBox.shrink(), // Display nothing if qrCode is null
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText(String text, {TextStyle? textStyle}) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 500),
      child: Text(
        text,
        style: textStyle ?? TextStyle(fontSize: 16.0, color: Colors.white),
      ),
    );
  }

 Widget _buildQrCodeButton(BuildContext context, String qrCode) {
  return ElevatedButton(
    onPressed: () => _showQrCodeModal(context, qrCode),
    child: Text('Verify with QR'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red, // Button background color
      foregroundColor: Colors.white, // Button text color
    ),
  );
}


void _showQrCodeModal(BuildContext context, String qrCode) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows modal to be resized
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'QR Code',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: _buildQrCodeImage(qrCode),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      );
    },
  );
}

  Widget _buildQrCodeImage(String qrCode) {
    try {
      final base64Data = _cleanBase64(qrCode);
      final decodedBytes = base64Decode(base64Data);
      return Image.memory(
        decodedBytes,
        height: 150,
        width: 150,
        fit: BoxFit.contain,
      );
    } catch (e) {
      print('Error decoding QR code: $e');
      return Center(child: Text('Error displaying QR code'));
    }
  }

  String _cleanBase64(String base64String) {
    // Remove the data URI scheme if present
    return base64String.replaceFirst('data:image/png;base64,', '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
