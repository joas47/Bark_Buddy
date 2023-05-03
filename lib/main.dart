import 'package:cross_platform_test/match_chat_page.dart';
import 'package:cross_platform_test/settings_page.dart';
import 'package:cross_platform_test/view_profile_page.dart';
import 'package:cross_platform_test/login_page.dart';
import 'package:cross_platform_test/register_page.dart';
import 'package:cross_platform_test/register_dog_page.dart';
import 'package:cross_platform_test/find_match_page.dart';
import 'package:cross_platform_test/make_profile_page.dart';

import 'package:flutter/material.dart';
//test Morgan
// firebase stuff, don't remove
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// for the MatchChatPage
//import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Run the app
  runApp(const BarkBuddy());
}

class BarkBuddy extends StatelessWidget {
  const BarkBuddy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Bark Buddy',
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        initialRoute: '/',
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/make-profile': (context) => const MakeProfilePage(),
          '/register-dog': (context) => const RegisterDogPage(),
          '/find-match': (context) => const FindMatchPage(),
          '/profile': (context) => const ViewProfilePage(),
          '/match-chat': (context) => const MatchChatPage(),
          '/settings': (context) => const SettingsPage(),
        },
        // TODO: change this to the login page when time for merge
        //home: const LoginPage());
        home: const MakeProfilePage());
  }
}

// with some basic API calls
/*class MatchChatPage extends StatelessWidget {
  final String matchId;

  MatchChatPage({required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('matchId', isEqualTo: matchId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;
                List<Widget> messages = docs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String,
                      dynamic>;
                  return ListTile(
                    title: Text(data['message']),
                    subtitle: Text(data['sender']),
                  );
                }).toList();

                return ListView(
                  reverse: true,
                  children: messages,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // TODO: Implement send message functionality.
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/
