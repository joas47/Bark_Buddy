import 'package:cross_platform_test/database_handler.dart';
import 'package:flutter/material.dart';

class MatchChatPage extends StatelessWidget {
  const MatchChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match-chat'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chat with your match!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: add a real user, not a hardcoded one
                //DatabaseHandler.addFriend("L64gYe4KwvON61lKukdNnGFJb3p2");
                DatabaseHandler.addRandomFriend();
              },
              child: const Text('Add random friend'),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // TODO: add a real user, not a hardcoded one
                //DatabaseHandler.sendFriendRequest("");
              },
              child: const Text('Send friend request'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendRequestsPage()));
              },
              child: const Text('See friend requests'),
            ),
            // TODO: Implement chat UI.
          ],
        ),
      ),
    );
  }
}
