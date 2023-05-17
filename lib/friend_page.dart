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

  // funkar, men inte information om hundarna
  /*Widget build(BuildContext context) {
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
                    Map<String, dynamic> friendData = friendSnapshot.data!
                        .data() as Map<String, dynamic>; // Explicit cast
                    return ListTile(
                      title: Text(friendData['name'].toString()),
                      subtitle: const Text("availability placeholder"),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MatchChatPage()),
                              );
                            },
                            icon: const Icon(Icons.chat),
                          ),
                          IconButton(
                            onPressed: () {
                              // popup
                              _showActivityLevelInfoSheet();
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
        ),
      ),
    );
  }*/

  /*@override
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
                DocumentReference friendRef = friends[index];
                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: friendRef.snapshots().map(
                        (event) => event as DocumentSnapshot<Map<String, dynamic>>,
                  ),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> friendSnapshot) {
                    if (friendSnapshot.hasError) {
                      return const Text('Something went wrong');
                    }
                    if (friendSnapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Loading");
                    }
                    Map<String, dynamic> friendData = friendSnapshot.data!.data()! as Map<String, dynamic>;

                    DocumentReference dogRef = friendData['dogs'];
                    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: dogRef.snapshots().map(
                            (event) => event as DocumentSnapshot<Map<String, dynamic>>,
                      ),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> dogSnapshot) {
                        if (dogSnapshot.hasError) {
                          return const Text('Something went wrong');
                        }
                        if (dogSnapshot.connectionState == ConnectionState.waiting) {
                          return const Text("Loading");
                        }
                        Map<String, dynamic> dogData = dogSnapshot.data!.data()! as Map<String, dynamic>;

                        return ListTile(
                          title: Text(friendData['name'].toString()),
                          subtitle: Text(dogData['name'].toString()),
                          leading: const CircleAvatar(
                            backgroundImage: AssetImage('assets/images/placeholder-profile-image.png'),
                            radius: 30.0,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MatchChatPage()),
                                  );
                                },
                                icon: const Icon(Icons.chat),
                              ),
                              IconButton(
                                onPressed: () {
                                  _showActivityLevelInfoSheet();
                                },
                                icon: const Icon(Icons.menu),
                              ),
                            ],
                          ),
                          onLongPress: () {
                            // TODO: Handle long press
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
  }*/

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
                    return ListTile(
                      title: Text(friendData['name'].toString()),
                      subtitle: Text(
                          DatabaseHandler.getDogNameFromOwnerID(friends[index])
                              .toString()),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MatchChatPage()),
                              );
                            },
                            icon: const Icon(Icons.chat),
                          ),
                          IconButton(
                            onPressed: () {
                              // popup
                              _showActivityLevelInfoSheet();
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
        ),
      ),
    );
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
