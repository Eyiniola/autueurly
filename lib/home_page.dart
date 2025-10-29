import 'package:flutter/material.dart';
import 'package:auteurly/features/projects/create_project_page.dart'; // Import your create page
import 'home_content.dart'; // Import the new content widget
import 'package:auteurly/features/search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _goToHome() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  // List of the main pages in your app
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(),
      CreateProjectPage(
        onProjectCreated: _goToHome,
        onCancel: _goToHome,
      ), // <-- Pass the callback here
      const SearchPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(
        _selectedIndex,
      ), // Display the selected page from the list
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1B1B1B),
        selectedItemColor: const Color(0xFFA32626),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed, // Important for dark backgrounds
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
        currentIndex: _selectedIndex, // Use the state variable
        onTap: _onItemTapped, // Call the update method
      ),
    );
  }
}
