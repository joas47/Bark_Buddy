import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/match_chat_page.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }
            Map<String, dynamic> data = snapshot.data!.data()! as Map<String, dynamic>;
            List<dynamic> friends = data['friends'];
            return ListView.builder(
              itemCount: friends.length,
              itemBuilder: (BuildContext context, int index) {
                String friendId = friends[index];
                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(friendId)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> friendSnapshot) {
                    if (friendSnapshot.hasError) {
                      return const Text('Something went wrong');
                    }
                    if (friendSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Text("Loading");
                    }
                    Map<String, dynamic> friendData =
                        friendSnapshot.data!.data() as Map<String, dynamic>;

                    return StreamBuilder<String?>(
                      stream: DatabaseHandler.getDogNameFromOwnerID(friendId),
                      builder: (BuildContext context,
                          AsyncSnapshot<String?> dogNameSnapshot) {
                        if (dogNameSnapshot.hasError) {
                          return const Text(
                              'Something went wrong: user has no dog');
                        }
                        if (dogNameSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("Loading");
                        }
                        String? dogName = dogNameSnapshot.data;

                        return ListTile(
                          onTap: () {
                            // TODO: go to friend profile page
                          },
                          title: Text(friendData['name'].toString()),
                          subtitle: Text("(${dogName!})"),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(friendData['picture']),
                            radius: 30.0,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  // Take to chat page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const MatchChatPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat),
                              ),
                              IconButton(
                                onPressed: () {
                                  _showActivityLevelInfoSheet(friendId);
                                },
                                icon: const Icon(Icons.menu),
                              ),
                            ],
                          ),
                          onLongPress: () {
                            // TODO: make something with this? (low priority)
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showActivityLevelInfoSheet(String friendId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirmation'),
                        content:
                            const Text('Are you sure you want to unfriend?'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              // Should be two pop calls, one for the dialog and one for the bottom sheet
                              // the bottom sheet is not relevant after the friend is removed
                              Navigator.pop(context);
                              DatabaseHandler.removeFriend(friendId);
                              Navigator.pop(context);
                            },
                            child: const Text('Confirm'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Unfriend'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: block
                  Navigator.pop(context);
                  // "not implemented" snack bar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Not implemented yet'),
                    ),
                  );
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
