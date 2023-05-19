import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/match_chat_page.dart';
import 'package:cross_platform_test/view_dog_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class FindMatchPage extends StatefulWidget {
  const FindMatchPage({super.key});

  @override
  State<FindMatchPage> createState() => _FindMatchPageState();
}

class _FindMatchPageState extends State<FindMatchPage> {
/*  List<String> list = [];

  void test() async {
    Future<List<String>?> _futureOfList = DatabaseHandler.getMatches();
    list = (await _futureOfList)!;
    print(list); // will print [1, 2, 3, 4] on console.
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Match'),
      ),
      /*body: Center(
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
              return const Text("Loading 1");
            }
            //test();
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                String friendId = list[index];
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
                      return const Text("Loading 2");
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
                          return const Text("Loading 3");
                        }
                        String? dogName = dogNameSnapshot.data;

                        return ListTile(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ViewDogProfilePage(userId: friendId)));
                          },title: Text(friendData['name'].toString()),
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
      ),*/

      body: Center(
          child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId,
                isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            /*return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewDogProfilePage(
                                    userId: doc.id,
                                  )));
                    },
                    title: Text(doc['name']),
                    //subtitle: Text(doc['email']),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(doc['picture']),
                      radius: 30.0,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            // Friend request
                            DatabaseHandler.sendFriendRequest(doc.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Friend request sent!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                        ),
                        IconButton(
                          onPressed: () {
                            // Take to chat page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MatchChatPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat),
                        ),
                        IconButton(
                          onPressed: () {
                            _showActivityLevelInfoSheet(doc.id);
                          },
                          icon: const Icon(Icons.menu),
                        ),
                      ],
                    ),
                    onLongPress: () {},
                  );
                });*/
            return CarouselSlider.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, int itemIndex, int pageViewIndex) {
                DocumentSnapshot doc = snapshot.data!.docs[itemIndex];
                return Column(
                  children: [
                    Container(
                      height: 300,
                      margin: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: NetworkImage(doc['picture']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(doc['name']),
                        Text(doc['age'].toString()),
                        Text(doc['gender']),
                        IconButton(
                          onPressed: () {
                            // TODO: match process...
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Liked!'),
                              ),
                            );
                          },
                          // TODO: make this button icon a heart
                          icon: const Icon(Icons.add_box),
                        ),
                      ],
                    )
                  ],
                );
              },
              options: CarouselOptions(height: 400.0),
            );
          } else {
                return const Text("No data");
              }
            },
          )),
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
                        const Text('Are you sure you want to befriend?'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              // Should be two pop calls, one for the dialog and one for the bottom sheet
                              // the bottom sheet is not relevant after the friend is removed
                              Navigator.pop(context);
                              // send friend request
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
                child: const Text('Befriend'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: unmatch
                  Navigator.pop(context);
                  // "not implemented" snack bar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Not implemented yet'),
                    ),
                  );
                },
                child: const Text('Unmatch'),
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
