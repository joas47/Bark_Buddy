import 'package:cross_platform_test/find_match_page.dart';
import 'package:cross_platform_test/friend_page.dart';
import 'package:cross_platform_test/chat_page.dart';
import 'package:cross_platform_test/start_page.dart';
import 'package:cross_platform_test/view_dog_profile_page.dart';
import 'package:flutter/material.dart';
import 'location_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _showStartPage = true;

  final List<Widget> _pages = [
    const ChatPage(),
    const FindMatchPage(),
    const FriendPage(),
    const ViewDogProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex != 4) {
        _showStartPage = false;
      }
    });
    LocationHandler.grabAndSaveLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Offstage(
            offstage: _showStartPage,
            child: _pages[_selectedIndex],
          ),
          Offstage(
            offstage: !_showStartPage,
            child: StartPage(
              onNavigate: () {
                setState(() {
                  _showStartPage = false;
                });
              },
              onStart: () {
                // what happens when the user presses the start button on the start page
                setState(() {
                  _selectedIndex = 1;
                  _showStartPage = false;
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.background,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Match-chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Find match',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
