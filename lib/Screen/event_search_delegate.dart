import 'package:flutter/material.dart';
import 'package:grocery_app/Providers/userProvider.dart';
import 'package:grocery_app/Screen/home_Screen.dart';
import 'package:provider/provider.dart';

class EventSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;

  EventSearchDelegate({required this.onSearch});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close search delegate
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query); // Trigger search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
    return Center(child: CircularProgressIndicator()); // Placeholder while loading
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Provide suggestions if needed; otherwise, return an empty container
    return Container();
  }
}
