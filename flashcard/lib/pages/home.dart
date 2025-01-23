import 'package:flutter/material.dart';
import './decks_page.dart';
import './review_page.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DecksTab(),
    ReviewTab(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: const Color(0xffb983ff),
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.library_books),
            label: 'Decks',
          ),
          NavigationDestination(
            icon: Icon(Icons.refresh),
            label: 'Review',
          ),
        ],
      ),
    );
  }
}
