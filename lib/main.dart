import 'package:cross_platform_test/login_page.dart';
import 'package:flutter/material.dart';
//this should be seen
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
          primarySwatch: Colors.blueGrey,
        ),
        home: const LoginPage());
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
