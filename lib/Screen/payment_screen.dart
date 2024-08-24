import 'package:flutter/material.dart';

class PaymentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payments', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildPaymentOption(context, 'Payment Method 1', 'VISA ****1234', Icons.credit_card, '/paymentMethod1'),
            _buildPaymentOption(context, 'Payment Method 2', 'Mastercard ****5678', Icons.credit_card, '/paymentMethod2'),
            _buildPaymentOption(context, 'Add New Payment Method', '', Icons.add, '/addPaymentMethod'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, String title, String subtitle, IconData icon, String route) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.red, size: 30),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white70)) : null,
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
      ),
    );
  }
}
