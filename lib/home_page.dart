import 'package:cross_platform_test/find_match_page.dart';
import 'package:cross_platform_test/friend_page.dart';
import 'package:cross_platform_test/match_chat_page.dart';
import 'package:cross_platform_test/view_dog_profile_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 3;
  final List<Widget> _pages = [
    const MatchChatPage(),
    const FindMatchPage(),
    const FriendPage(),
    const ViewDogProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.background,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            //activeIcon: Icon(Icons.chat_outlined),
            label: 'Match-chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Hitta matchning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            //activeIcon: Icon(Icons.star),
            label: 'Vänner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            //activeIcon: Icon(Icons.star),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
