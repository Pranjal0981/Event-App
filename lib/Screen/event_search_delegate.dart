import 'package:flutter/material.dart';

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
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container(); // Returning an empty container as we are using the main screen for results
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Provide suggestions if needed; otherwise, you can return an empty container
    return Container();
  }
}
