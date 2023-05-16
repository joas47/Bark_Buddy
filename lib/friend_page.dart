import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/match_chat_page.dart';
import 'package:easy_search_bar/easy_search_bar.dart';

import 'package:flutter/material.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  String searchValue = '';

  // possible search values
  final List<String> _suggestions = [
    'Afeganistan',
    'Albania',
    'Algeria',
    'Australia',
    'Brazil',
    'German',
    'Madagascar',
    'Mozambique',
    'Portugal',
    'Zambia'
  ];

  // TODO: get friends from database
  //Future<dynamic> _friends = DatabaseHandler.getFriends();

  // not used, remove?
  /*Future<List<String>> _fetchSuggestions(String searchValue) async {
    await Future.delayed(const Duration(milliseconds: 750));

    return _suggestions.where((element) {
      return element.toLowerCase().contains(searchValue.toLowerCase());
    }).toList();
  }*/

  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Friends',
        theme: ThemeData(primarySwatch: Colors.orange),
        home: Scaffold(
            // TODO: implement search functionality (low priority?)
            appBar: EasySearchBar(
                title: const Text('Friends'),
                onSearch: (value) => setState(() => searchValue = value),
                suggestions: _suggestions),
            body: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              // TODO: get friends from database before/while building widgets
              children: _buildTextWidgets(/*_friends*/),
            ))));
  }

  List<Widget> _buildTextWidgets(/*List<String> friends*/) {
    List<String> items = _suggestions;
    List<Widget> textWidgets = [];
    items.forEach((item) {
      textWidgets.add(
        Row(children: [
          const CircleAvatar(
            backgroundImage:
                AssetImage('assets/images/placeholder-profile-image.png'),
            radius: 30.0,
          ),
          Text(item.toString()),
          const SizedBox(height: 10.0),
          const Text("availability placeholder"),
          const SizedBox(height: 16.0),
          IconButton(
            onPressed: () {
              // Take to chat page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MatchChatPage()),
              );
            },
            icon: const Icon(Icons.chat),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // popup
              _showActivityLevelInfoSheet();
            },
          )
        ]),
      );
    });
    return textWidgets;
  }

  void _showActivityLevelInfoSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Unfriend'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Block'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              )
            ],
          ),
        );
      },
    );
  }
}
