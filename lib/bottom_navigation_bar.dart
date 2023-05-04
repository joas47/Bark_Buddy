import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavigationBarCustom {
  static Widget build(BuildContext context) {
    // make the method public and static
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Match Chat',
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
      currentIndex: 0,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
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
