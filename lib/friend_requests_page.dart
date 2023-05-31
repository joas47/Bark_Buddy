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
/*            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }*/
            Map<String, dynamic> data = snapshot.data!.data()! as Map<String, dynamic>;
            List<dynamic> friendRequests = data['friendrequests'];
            return Padding(
                padding: const EdgeInsets.only(top: 100), // adjust the value as per your need
            child: Column(
            children: [
                Visibility(
                  visible: friendRequests.isEmpty,
                  child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 100),
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
/*                            if (friendSnapshot.connectionState == ConnectionState.waiting) {
                              return const Text("Loading");
                            }*/
                              Map<String, dynamic> friendData = friendSnapshot.data!.data() as Map<String, dynamic>;

                            return StreamBuilder<String?>(
                              stream: DatabaseHandler.getDogNameFromOwnerID(friendId),
                              builder: (BuildContext context, AsyncSnapshot<String?> dogNameSnapshot) {
                                if (dogNameSnapshot.hasError) {
                                  return const Text('Something went wrong');
                                }
/*                                if (dogNameSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Text("Loading");
                                }*/
                                  String? dogName = dogNameSnapshot.data;

                                return ListTile(
                                  title: RichText(
                                    text: TextSpan(
                                      text: "${friendData['name']} ",
                                      style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: "($dogName)",
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: DefaultTextStyle.of(context).style.fontSize!,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
            ),
            );
          },
        ),
      ),
    );
  }
}

