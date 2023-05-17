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

  // funkar, med hundens namn
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
            );
          },
        ),
      ),
    );
  }

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
                    DatabaseHandler.getDogNameFromOwnerID(friendId).listen((event) {
                      _dogName = event;
                    });
                    return ListTile(
                      title: Text(friendData['name'].toString()),
                      subtitle: Text(_dogName!),
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
