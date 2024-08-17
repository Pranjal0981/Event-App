import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle

class FilterSheet extends StatefulWidget {
  @override
  _FilterSheetState createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String _selectedFilter = 'City'; // Track selected filter category
  Map<String, bool> _filterOptions = {}; // Track selected options
  List<String> _filterOptionsList = []; // List to store fetched options
  List<String> _filteredOptionsList = []; // List to store filtered options
  String _searchQuery = ''; // Track search query

  @override
  void initState() {
    super.initState();
    _initializeFilterOptions();
  }

  Future<void> _initializeFilterOptions() async {
    List<String> options;
    switch (_selectedFilter) {
      case 'City':
        options = await _loadFilterOptionsFromFile('assets/cities.json');
        break;
      case 'Price':
        options = [
          'Free', 'Under \Rs 25', 'Under \Rs 50', 'Under \Rs 75', 'Under \Rs 100', 'Under \Rs 150', 'Over \Rs 300',
        ];
        break;
      case 'Type':
        options = [
          'Tech', 'History', 'Construction', 'Music', 'Art', 'Education', 'Science',
          'Food & Drink', 'Sports', 'Health', 'Travel', 'Business', 'Lifestyle', 'Entertainment',
          'Workshops', 'Conferences', 'Meetups'
        ];
        break;
      default:
        options = [];
    }
    setState(() {
      _filterOptionsList = options;
      _filteredOptionsList = options; // Initialize filtered list
      _filterOptions = Map.fromIterable(options, key: (option) => option, value: (_) => false);
    });
  }

  Future<List<String>> _loadFilterOptionsFromFile(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final data = jsonDecode(jsonString) as List;
    return List<String>.from(data);
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _filteredOptionsList = _filterOptionsList.where((option) {
        return option.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8.0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Filter Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterCategory('City', Icons.location_city),
                      _buildFilterCategory('Price', Icons.money),
                      _buildFilterCategory('Type', Icons.category),
                    ],
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  flex: 5,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildFilterOptions(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Apply'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCategory(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
          _initializeFilterOptions();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: _selectedFilter == title ? Colors.redAccent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: _selectedFilter == title ? Colors.redAccent : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: _selectedFilter == title ? Colors.redAccent : Colors.white),
            SizedBox(width: 8.0),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _selectedFilter == title ? Colors.redAccent : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Column(
      children: [
        if (_selectedFilter == 'City') // Only show search box for 'City' filter
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search cities...',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _updateSearchQuery,
            ),
          ),
        Expanded(
          child: ListView(
            key: ValueKey<String>(_selectedFilter),
            padding: EdgeInsets.zero,
            children: _filteredOptionsList.map((option) {
              return CheckboxListTile(
                title: Text(option, style: TextStyle(color: Colors.white)),
                value: _filterOptions[option],
                onChanged: (bool? selected) {
                  setState(() {
                    _filterOptions[option] = selected ?? false;
                  });
                },
                checkColor: Colors.white,
                activeColor: Colors.redAccent,
                controlAffinity: ListTileControlAffinity.leading,
                tileColor: Colors.black,
                contentPadding: EdgeInsets.symmetric(vertical: 4.0),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
