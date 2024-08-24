import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Center', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help you?',
              style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildHelpOption(context, 'FAQ', Icons.question_answer, '/faq'),
            _buildHelpOption(context, 'Contact Support', Icons.phone, '/contactSupport'),
            _buildHelpOption(context, 'Report an Issue', Icons.bug_report, '/reportIssue'),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption(BuildContext context, String title, IconData icon, String route) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.red, size: 30),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
      ),
    );
  }
}
