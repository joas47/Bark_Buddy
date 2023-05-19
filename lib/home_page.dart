import 'package:cross_platform_test/find_match_page.dart';
import 'package:cross_platform_test/friend_page.dart';
import 'package:cross_platform_test/chat_page.dart';
import 'package:cross_platform_test/start_page.dart';
import 'package:cross_platform_test/view_dog_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'location_handler.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _showStartPage = true;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _showStartPage = false; // Hide the StartPage when any item is tapped
    });

    if (!_showStartPage) {
      // Pop until only the initial route remains in the current tab
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    }

    LocationHandler.grabAndSaveLocation();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab = !await _navigatorKeys[_selectedIndex].currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the "home" index, select the "home" tab
          if (_selectedIndex != 0) {
            _onItemTapped(0);
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // add the start page
            Offstage(
              offstage: !_showStartPage,
              child: StartPage(
                onNavigate: () {
                  setState(() {
                    _showStartPage = false;
                  });
                },
                onStart: () {  // <-- Add this
                  setState(() {
                    _selectedIndex = 1;  // you might want to change this to the index of the desired page
                    _showStartPage = false;
                  });
                },
              ),
            ),
            // the rest of your pages
            ...List<Widget>.generate(_navigatorKeys.length, (index) {
              return Offstage(
                offstage: _selectedIndex != index || _showStartPage, // updated line
                child: Navigator(
                  key: _navigatorKeys[index],
                  initialRoute: '/',
                  onGenerateRoute: (routeSettings) {
                    return MaterialPageRoute(
                      builder: (_) => _getPage(index),
                    );
                  },
                ),
              );
            }),
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
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const ChatPage();
      case 1:
        return const FindMatchPage();
      case 2:
        return const FriendPage();
      case 3:
        return ViewDogProfilePage(userId: FirebaseAuth.instance.currentUser?.uid);
      default:
        return const ChatPage();
    }
  }
}