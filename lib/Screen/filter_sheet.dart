import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:grocery_app/Providers/userProvider.dart';
import 'package:provider/provider.dart';

class FilterSheet extends StatefulWidget {
  @override
  _FilterSheetState createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String _selectedFilter = 'City';
  Map<String, bool> _cityFilterOptions = {};
  Map<String, bool> _priceFilterOptions = {};
  Map<String, bool> _typeFilterOptions = {};
  List<String> _filteredOptionsList = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeFilterOptions();
  }

  Future<void> _initializeFilterOptions() async {
    switch (_selectedFilter) {
      case 'City':
        List<String> cities = await _loadFilterOptionsFromFile('assets/cities.json');
        setState(() {
          _cityFilterOptions = {for (var city in cities) city: false};
          _filteredOptionsList = cities;
        });
        break;
      case 'Price':
        List<String> prices = [
          'Free', 'Under ₹25', 'Under ₹50', 'Under ₹75', 'Under ₹100', 'Under ₹150', 'Over ₹300',
        ];
        setState(() {
          _priceFilterOptions = {for (var price in prices) price: false};
          _filteredOptionsList = prices;
        });
        break;
      case 'Type':
        List<String> types = [
          'Tech', 'History', 'Construction', 'Music', 'Art', 'Education', 'Science',
          'Food & Drink', 'Sports', 'Health', 'Travel', 'Business', 'Lifestyle', 'Entertainment',
          'Workshops', 'Conferences', 'Meetups'
        ];
        setState(() {
          _typeFilterOptions = {for (var type in types) type: false};
          _filteredOptionsList = types;
        });
        break;
      default:
        _filteredOptionsList = [];
    }
  }

  Future<List<String>> _loadFilterOptionsFromFile(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((item) => item.toString()).toList();
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _filteredOptionsList = _getOptionsForCurrentFilter().where((option) {
        return option.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  List<String> _getOptionsForCurrentFilter() {
    switch (_selectedFilter) {
      case 'City':
        return _cityFilterOptions.keys.toList();
      case 'Price':
        return _priceFilterOptions.keys.toList();
      case 'Type':
        return _typeFilterOptions.keys.toList();
      default:
        return [];
    }
  }

  Future<void> _applyFilters() async {
    final cityFilters = _cityFilterOptions;
    final priceFilters = _priceFilterOptions;
    final typeFilters = _typeFilterOptions;

    try {
      await Provider.of<UserProvider>(context, listen: false).applyFilters(
        cityFilters,
        priceFilters,
        typeFilters,
      );
      Navigator.pop(context); // Close the filter sheet
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to apply filters. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.9,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20.0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Filter Options',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildFilterCategory('City'),
                      _buildFilterCategory('Price'),
                      _buildFilterCategory('Type'),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  flex: 6,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.5, 0),
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
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _applyFilters,
            child: Text('Apply'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCategory(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
          _initializeFilterOptions();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: _selectedFilter == title ? Colors.redAccent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: _selectedFilter == title ? Colors.redAccent : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _selectedFilter == title ? Colors.redAccent : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    final optionsList = _filteredOptionsList;
    final filterOptions = _getCurrentFilterOptions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_selectedFilter == 'City')
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                labelStyle: TextStyle(color: Colors.white70),
              ),
              onChanged: _updateSearchQuery,
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: optionsList.length,
            itemBuilder: (context, index) {
              final option = optionsList[index];
              return CheckboxListTile(
                title: Text(
                  option,
                  style: TextStyle(color: Colors.white70),
                ),
                value: filterOptions[option] ?? false,
                onChanged: (value) {
                  setState(() {
                    filterOptions[option] = value ?? false;
                  });
                },
                activeColor: Colors.redAccent,
                checkColor: Colors.white,
              );
            },
          ),
        ),
      ],
    );
  }

  Map<String, bool> _getCurrentFilterOptions() {
    switch (_selectedFilter) {
      case 'City':
        return _cityFilterOptions;
      case 'Price':
        return _priceFilterOptions;
      case 'Type':
        return _typeFilterOptions;
      default:
        return {};
    }
  }
}
