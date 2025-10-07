import 'package:flutter/material.dart';
import './features/components/professional_card.dart';
import './features/components/project_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFF1B1B1B),
        appBar: AppBar(
          backgroundColor: Color(0xFF1B1B1B),
          elevation: 0,
          leading: IconButton(
            onPressed: null,
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
          title: Image.asset('lib/images/logo.png', height: 100, width: 100),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFA32626),
            indicatorWeight: 3.0,
            labelColor: Colors.white,
            tabs: [
              Tab(text: 'Professionals'),
              Tab(text: 'Projects'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            //Professionals tab
            ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 10,
              itemBuilder: (context, index) {
                return ProfessionalCard();
              },
            ),

            //Projects tab
            ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 10,
              itemBuilder: (context, index) {
                return ProjectCard();
              },
            ),
          ],
        ),
        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xFF1B1B1B),
          selectedItemColor: Color(0xFFA32626),
          unselectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          ],
          currentIndex: 0,
          onTap: (index) {
            // Handle navigation logic here
          },
        ),
      ),
    );
  }
}
