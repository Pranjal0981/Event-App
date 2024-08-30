import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocery_app/Providers/userProvider.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late Razorpay _razorpay;
  bool isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.currentEvent == null || userProvider.currentEvent!['_id'] != widget.eventId) {
        userProvider.fetchEventById(widget.eventId);
      }
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Stack(
      children: [
        Scaffold(
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
                                SizedBox(height: 12),
                                _buildPrice(userProvider.currentEvent!),
                              ],
                            ),
                          ),
                        ),
                        _buildLocationAndDate(userProvider.currentEvent!),
                        SizedBox(height: 16),
                        _buildBookTicketsButton(userProvider.currentEvent!),
                      ],
                    ),
        ),
        if (isProcessingPayment)
          Container(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
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

  Widget _buildPrice(Map<String, dynamic> event) {
    return Text(
      'Price: ₹${event['price'].toString()}',
      style: TextStyle(
        color: Colors.red,
        fontSize: 20,
        fontWeight: FontWeight.bold,
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

  Widget _buildBookTicketsButton(Map<String, dynamic> event) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessingPayment
            ? null
            : () {
                _startPayment(event['price'], event['title']);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
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

  Future<void> _startPayment(int amount, String receipt) async {
    setState(() {
      isProcessingPayment = true;
    });

    try {
      final order = await _createOrder(amount, receipt);
      final orderId = order['id'];
      if (orderId != null && orderId.isNotEmpty) {
        _openRazorpayCheckout(orderId, amount);
      } else {
        _showErrorDialog('Order ID is missing.');
      }
    } catch (error) {
      setState(() {
        isProcessingPayment = false;
      });
      _showErrorDialog('Failed to create order. Please try again.');
    }
  }

  Future<Map<String, dynamic>> _createOrder(int amount, String receipt) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final url = 'http://192.168.120.187:3001/user/checkout'; // Replace with your API URL
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'amount': amount, // Ensure amount is correctly formatted
        'currency': 'INR',
        'receipt': receipt,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['order']; // Ensure this returns the order object
    } else {
      throw Exception('Failed to create order');
    }
  }

  void _openRazorpayCheckout(String orderId, int amount) {
    var options = {
      'key': 'rzp_test_yUjxBrOiwx3ugi', // Replace with your Razorpay Key ID
      'amount': amount * 100, // Amount is in the smallest currency unit (paise)
      'name': 'Event Master',
      'description': 'Ticket Booking',
      'order_id': orderId, // Ensure this is correctly set
      'prefill': {
        'contact': '9302931857',
        'email': 'pranjalshukla245@gmail.com',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        isProcessingPayment = false;
      });
      _showErrorDialog('Error opening Razorpay checkout. Please try again.');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _verifyPayment(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      isProcessingPayment = false;
    });
    _showErrorDialog('Payment failed. Please try again.');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      isProcessingPayment = false;
    });
    _showErrorDialog('External wallet selected. Please try again.');
  }

  Future<void> _verifyPayment(PaymentSuccessResponse response) async {
    final token = await _getToken();
    if (token == null) {
      setState(() {
        isProcessingPayment = false;
      });
      _showErrorDialog('No token found');
      return;
    }

    final url = 'http://192.168.120.187:3001/user/verify_payment'; // Replace with your API URL
    final responseApi = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'razorpay_payment_id': response.paymentId,
        'razorpay_order_id': response.orderId,
        'razorpay_signature': response.signature,
      }),
    );

    if (responseApi.statusCode == 200) {
      _showSuccessDialog('Payment successful. Thank you for your purchase!');
    } else {
      _showErrorDialog('Payment verification failed. Please contact support.');
    }

    setState(() {
      isProcessingPayment = false;
    });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
