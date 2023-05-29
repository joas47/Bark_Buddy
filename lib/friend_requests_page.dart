import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/database_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  @override
  Widget build(BuildContext context) {
    final userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: userStream,
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }
            Map<String, dynamic> data = snapshot.data!.data()! as Map<String, dynamic>;
            List<dynamic> friendRequests = data['friendrequests'];
            return Column(
              children: [
                Visibility(
                  visible: friendRequests.isEmpty,
                  child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 60),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/images/BarkBuddyChatBubble.png',
                              scale: 1.2),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(35, 125, 60, 10),
                            child: Text(
                              'No pending friend requests.',
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )),
                ),
                Visibility(
                  visible: friendRequests.isNotEmpty,
                  child: Expanded(
                    child: ListView.builder(
                      itemCount: friendRequests.length,
                      itemBuilder: (BuildContext context, int index) {
                        String friendId = friendRequests[index];
                        final usersStream = FirebaseFirestore.instance
                            .collection('users')
                            .doc(friendId)
                            .snapshots();
                        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: usersStream,
                          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> friendSnapshot) {
                            if (friendSnapshot.hasError) {
                              return const Text('Something went wrong');
                            }
                            if (friendSnapshot.connectionState == ConnectionState.waiting) {
                              return const Text("Loading");
                            }
                            Map<String, dynamic> friendData = friendSnapshot.data!.data() as Map<String, dynamic>;

                            return StreamBuilder<String?>(
                              stream: DatabaseHandler.getDogNameFromOwnerID(friendId),
                              builder: (BuildContext context, AsyncSnapshot<String?> dogNameSnapshot) {
                                if (dogNameSnapshot.hasError) {
                                  return const Text('Something went wrong');
                                }
                                if (dogNameSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Text("Loading");
                                }
                                String? dogName = dogNameSnapshot.data;

                                return ListTile(
                                  title: Text(friendData['name'].toString()),
                                  subtitle: Text(dogName ?? ''),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(friendData['picture']),
                                    radius: 30.0,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          // Take to chat page
                                          DatabaseHandler.addFriend(friendId);
                                        },
                                        icon: const Icon(Icons.check),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text('Confirmation'),
                                                content: const Text(
                                                    'Are you sure you want to deny?'),
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      // Should be two pop calls, one for the dialog and one for the bottom sheet
                                                      // the bottom sheet is not relevant after the friend is removed
                                                      Navigator.pop(context);
                                                      DatabaseHandler.removeFriendrequest(friendId);
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
                                        icon: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

