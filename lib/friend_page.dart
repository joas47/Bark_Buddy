import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/chat_page.dart';
import 'package:cross_platform_test/view_dog_profile_page.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'friend_requests_page.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({Key? key}) : super(key: key);

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _friendRequestStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream in the initState
    _friendRequestStream = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: <Widget>[
          Stack(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.people),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FriendRequestsPage(),
                    ),
                  );
                },
              ),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _friendRequestStream,
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading");
                  }
                  int counter = 0;
                  if (snapshot.data != null) {
                    Map<String, dynamic>? data = snapshot.data!.data();
                    if (data != null && data['friendrequests'] != null) {
                      List<dynamic> friendRequestList = data['friendrequests'];
                      counter = friendRequestList.length;
                    }
                  }
                  return counter != 0
                      ? Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minHeight: 14,
                        minWidth: 14,
                      ),
                      child: Text(
                        '$counter',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                      : Container();
                },
              ),
            ],
          ),
        ],
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

            if (data['friends'] != null) {
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

                      DocumentSnapshot<Object?> friendSnapshotData =
                          friendSnapshot.data!;

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

                          return _buildFriendRow(context, friendId, friendData,
                              dogName, friendSnapshotData);
                        },
                      );
                    },
                  );
                },
              );
            } else {
              return const ListTile(
                title: Text('no friends'),
              );
            }
          },
        ),
      ),
    );
  }

  ListTile _buildFriendRow(
      BuildContext context,
      String friendId,
      Map<String, dynamic> friendData,
      String? dogName,
      DocumentSnapshot<Object?> friendSnapshotData) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(12, 10, 10, 0),
      splashColor: Colors.transparent,
      title: Text(friendData['name'].toString()),
      subtitle: Text("(${dogName!})"),
      leading: CircleAvatar(
          backgroundImage: NetworkImage(friendData['picture']),
          radius: 30.0,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewDogProfilePage(userId: friendId)));
            },
          )),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // TODO: What happens if the owner/dog has a long name? Then the name will be too close to the text 'available'
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: /*friendData['availability'] == null*/ !_isAvailabilityValid(
                    friendSnapshotData)
                ? const Text('Not available',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center)
                : Text(
                    'Available \n${friendData['availability']['startTime']} - ${friendData['availability']['endTime']}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center),
          ),
          // TODO: check if user is available, not just if they have an availability field

          IconButton(
            onPressed: () {
              // Take to chat page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchChatPage(
                    friendId: friendId,
                    friendName: friendData['name'],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.chat),
          ),
          IconButton(
            onPressed: () {
              _showActivityLevelInfoSheet(friendId);
            },
            icon: const Icon(Icons.menu_outlined),
          ),
        ],
      ),
      onLongPress: () {
        // TODO: make something with this? (low priority)
      },
    );
  }

  bool _isAvailabilityValid(DocumentSnapshot<Object?> userDoc) {
    // if the user has not set their availability yet, return false
    if (userDoc.data().toString().contains('availability') &&
        userDoc['availability']['createdOn'] != null) {
      Timestamp availability = userDoc['availability']['createdOn'];
      DateTime dateTime = availability.toDate();

      print(userDoc.get('name') + " " + dateTime.toString());

      // if the availability is from yesterday, it's not valid, return false
      if (DateUtils.isSameDay(dateTime, DateTime.now())) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  void _showActivityLevelInfoSheet(String friendId) {
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            width: 180, // Set width as needed
            color: Colors.white,
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(120, 30),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirmation'),
                              content: const Text(
                                  'Are you sure you want to unfriend?'),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: this crashes the app, sometimes...
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
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(120, 30),
                      ),
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
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(120, 30),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    );
  }
}
