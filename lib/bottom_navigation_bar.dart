import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavigationBarCustom {
  static Widget build(BuildContext context) {
    // make the method public and static
    return BottomNavigationBar(
      //selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          activeIcon: Icon(Icons.star),
          label: 'Match Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'Find match',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          activeIcon: Icon(Icons.star),
          label: 'Friends',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          activeIcon: Icon(Icons.star),
          label: 'Profile',
        ),
      ],
      currentIndex: 0,
      //selectedItemColor: Theme.of(context).colorScheme.secondary,
      onTap: (index) {
        if (index == 0) {
          // Navigate to the profile page
          Navigator.pushNamed(context, '/match-chat');
        } else if (index == 1) {
          // Navigate to the match chat page
          Navigator.pushNamed(context, '/find-match');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/friends');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/profile');
        }
      },
    );
  }
}

/*class BottomNavigationBarCustom extends StatefulWidget {
  const BottomNavigationBarCustom({Key? key}) : super(key: key);

  @override
  _BottomNavigationBarCustomState createState() =>
      _BottomNavigationBarCustomState();
}

class _BottomNavigationBarCustomState extends State {
  int _selectedTab = 0;

  List _pages = [
    Center(
      child: Text("Match Chat"),
    ),
    Center(
      child: Text("Find Match"),
    ),
    Center(
      child: Text("Friends"),
    ),
    Center(
      child: Text("testststs"),
    ),
  ];

  _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _pages[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => _changeTab(index),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Match Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Find Match"),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_3x3_outlined), label: "Friends"),
          BottomNavigationBarItem(
              icon: Icon(Icons.contact_mail), label: "Profile"),
        ],
      ),
    );
  }
}*/
