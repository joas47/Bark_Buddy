import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/match_chat_page.dart';
import 'package:cross_platform_test/view_dog_profile_page.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match-chat'),
        actions: [
          TextButton(
            onPressed: () {

            },
            child: const Text('Recommend location'),
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }
            Map<String, dynamic>? data = snapshot.data?.data() as Map<String, dynamic>?;
            if (data != null && data['friends'] != null) {
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
                      Map<String, dynamic>? friendData = friendSnapshot.data?.data() as Map<String, dynamic>?;


                      return StreamBuilder<String?>(
                        stream: _MatchChatPageState.getOwnerNameFromOwnerID(friendId),
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewDogProfilePage(userId: friendId)));
                            },
                            title: Text(friendData?['name'].toString() ?? ''),
                            subtitle: Text("($dogName)"),
                            leading: CircleAvatar(
                              backgroundImage:
                              NetworkImage(friendData?['picture'] ?? ''),
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
                                        builder: (context) => MatchChatPage(
                                          friendId: friendId,
                                          friendName: friendData!['name'],
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
            } else {
              return ListTile(
                title: Text('No friends'),
              );
            }
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
                        content: const Text('Are you sure you want to unfriend?'),
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

class MatchChatPage extends StatefulWidget {
  final String friendId;
  final String friendName;

  const MatchChatPage({
    required this.friendId,
    required this.friendName,
  });

  @override
  _MatchChatPageState createState() => _MatchChatPageState();
}

class _MatchChatPageState extends State<MatchChatPage> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _chatStream;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setCurrentFriend(widget.friendId);
    _chatStream = FirebaseFirestore.instance
        .collection('chatMessages')
        .where('participants', arrayContains: widget.friendId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
        actions: [
          IconButton(
            onPressed: _recommendLocation,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading');
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data()!;
                    final senderId = messageData['senderId'] as String;
                    final messageText = messageData['message'];
                    final timestamp = messageData['timestamp'] as Timestamp?;

                    final isSender =
                        senderId == FirebaseAuth.instance.currentUser!.uid;

                    return Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSender ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<String?>(
                              future: _getSenderProfilePicture(senderId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                final profilePictureUrl = snapshot.data;
                                return CircleAvatar(
                                  backgroundImage:
                                  NetworkImage(profilePictureUrl ?? ''),
                                );
                              },
                            ),
                            SizedBox(height: 8),
                            Text(
                              messageText,
                              style: TextStyle(color: Colors.white),
                            ),
                            FutureBuilder<String?>(
                              future: _formatTimestamp(timestamp, senderId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    'Loading...',
                                    style: TextStyle(color: Colors.white),
                                  );
                                }
                                final formattedTimestamp = snapshot.data ?? 'Unknown';
                                return Text(
                                  formattedTimestamp,
                                  style: TextStyle(color: Colors.white),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final message = _messageController.text;
                    _messageController.clear();
                    _sendMessage(message);
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Future<String?> _getSenderProfilePicture(String senderId) async {
    final users = FirebaseFirestore.instance.collection('users');
    final snapshot = await users.doc(senderId).get();
    final data = snapshot.data();
    return data?['picture'] as String?;
  }
  void _sendMessage(String message) {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance.collection('chatMessages').add({
      'participants': [currentUserID, widget.friendId],
      'senderId': currentUserID,
      'receiverId': widget.friendId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _formatTimestamp(Timestamp? timestamp, String senderId) async {
    if (timestamp != null) {
      final dateTime = timestamp.toDate();
      final formatter = DateFormat('MMM d, HH:mm');
      final ownerName = await getOwnerNameFromOwnerID(senderId).first;
      final formattedTimestamp = formatter.format(dateTime);
      return '$formattedTimestamp - ${ownerName ?? 'Unknown'}';
    }
    return 'Loading...';
  }

  static Stream<String?> getOwnerNameFromOwnerID(String ownerID) async* {
    final users = FirebaseFirestore.instance.collection('users');
    final ownerSnapshot = await users.doc(ownerID).get();
    final ownerData = ownerSnapshot.data();

    if (ownerData != null && ownerData.containsKey('name')) {
      final ownerName = ownerData['name'] as String;
      yield ownerName;
    } else {
      yield null;
    }
  }
  // Implement the following helper methods based on your existing code and location database access:
  String currentFriend = 'null';
  void setCurrentFriend(String friendId){
    currentFriend = friendId;
  }
  Future<Position?> getCurrentUserLocation() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userData =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userData.exists) {
      final data = userData.data();
      final geoPoint = data?['LastLocation'] as GeoPoint?;
      if (geoPoint != null) {
        final latitude = geoPoint.latitude;
        final longitude = geoPoint.longitude;
        return Position(
          latitude: latitude,
          longitude: longitude,
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          timestamp: DateTime.now(),
        );
      }
    }
    return null;
  }

  Stream<Position?> getOtherUserLocation(String ownerID) async* {
    final users = FirebaseFirestore.instance.collection('users');
    final ownerSnapshot = await users.doc(ownerID).get();
    final ownerData = ownerSnapshot.data();

    if (ownerData != null && ownerData.containsKey('LastLocation')) {
      final geoPoint = ownerData['LastLocation'] as GeoPoint?;
      if (geoPoint != null) {
        final latitude = geoPoint.latitude;
        final longitude = geoPoint.longitude;
        yield Position(
          latitude: latitude,
          longitude: longitude,
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          timestamp: DateTime.now(),
        );
      }
    } else {
      yield null;
    }
  }

  void _recommendLocation() async {
    final currentUserLocation = await getCurrentUserLocation();
    final Stream<Position?> otherUserLocationStream = getOtherUserLocation(currentFriend);

    Position? otherUserLocation;
    await for (final position in otherUserLocationStream) {
      otherUserLocation = position;
      break; // Stop listening after receiving the first position
    }

    if (currentUserLocation == null || otherUserLocation == null) {
      // Error handling code
      return;
    }

    if (currentUserLocation == null || otherUserLocation == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Location Error'),
            content: const Text('Unable to retrieve user locations.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final midpoint = calculateMidpoint(currentUserLocation, otherUserLocation as Position);
    final closestLocation = await findClosestLocation(midpoint);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recommended Location'),
          content: Text('The recommended location is: ${closestLocation ?? "Name is not added yet"}'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Position calculateMidpoint(Position location1, Position location2) {
    double lat1 = location1.latitude;
    double lon1 = location1.longitude;
    double lat2 = location2.latitude;
    double lon2 = location2.longitude;

    double dLon = _toRadians(lon2 - lon1);

    // Convert to radians
    lat1 = _toRadians(lat1);
    lat2 = _toRadians(lat2);
    lon1 = _toRadians(lon1);

    double bx = cos(lat2) * cos(dLon);
    double by = cos(lat2) * sin(dLon);

    double lat3 = atan2(sin(lat1) + sin(lat2), sqrt((cos(lat1) + bx) * (cos(lat1) + bx) + by * by));
    double lon3 = lon1 + atan2(by, cos(lat1) + bx);

    // Convert back to degrees
    lat3 = _toDegrees(lat3);
    lon3 = _toDegrees(lon3);

    return Position(latitude: lat3, longitude: lon3, accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),);
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  double _toDegrees(double radian) {
    return radian * 180 / pi;
  }

  Future<String?> findClosestLocation(Position midpoint) async {
    final parksCollection = FirebaseFirestore.instance.collection('parks');

    double minDistance = double.infinity;
    String? closestLocation;

    final snapshot = await parksCollection.get();
    snapshot.docs.forEach((doc) {
      final coordinatesString = doc['mid_point'] as String?;
      if (coordinatesString != null) {
        final coordinates = parseCoordinatesString(coordinatesString);
        final distance = Geolocator.distanceBetween(
          midpoint.latitude,
          midpoint.longitude,
          coordinates.latitude,
          coordinates.longitude,
        );

        if (distance < minDistance) {
          minDistance = distance;
          closestLocation = doc['od_gis_id'] as String?;
        }
      }
    });

    return closestLocation;
  }

  Position parseCoordinatesString(String coordinatesString) {
    final coordinatesList = coordinatesString.split(', ');
    final latitude = double.parse(coordinatesList[0]);
    final longitude = double.parse(coordinatesList[1]);
    return Position(latitude: latitude, longitude: longitude, accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),);
  }
}