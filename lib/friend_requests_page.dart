import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/match_chat_page.dart';
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
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }
            Map<String, dynamic> data =
                snapshot.data!.data()! as Map<String, dynamic>;
            if (data['friendrequests'] != null) {
              List<dynamic> friendRequests = data['friendrequests'];
              return ListView.builder(
                itemCount: friendRequests.length,
                itemBuilder: (BuildContext context, int index) {
                  String friendId = friendRequests[index];
                  final usersStream = FirebaseFirestore.instance
                      .collection('users')
                      .doc(friendId)
                      .snapshots();
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: usersStream,
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
                            return const Text('Something went wrong');
                          }
                          if (dogNameSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text("Loading");
                          }
                          String? dogName = dogNameSnapshot.data;

                          return ListTile(
                            title: Text(friendData['name'].toString()),
                            subtitle: Text(dogName ?? ''),
                            leading: CircleAvatar(
                              backgroundImage:
                              NetworkImage(friendData['picture']),
                              radius: 30.0,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              // TODO: add confirmation if click deny
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
                                    DatabaseHandler.removeFriendrequest(friendId);
                                  },
                                  icon: const Icon(Icons.close),
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
            }
            else {
              return ListTile(
                title: Text('no friend requests'),
              );
            }
          },
        ),
      ),
    );
  }

}
