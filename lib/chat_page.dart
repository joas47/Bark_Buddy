import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/match_chat_page.dart';
import 'package:cross_platform_test/view_dog_profile_page.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int buttonClicks = 0;

  @override
  void initState() {
    super.initState();
    setCurrentFriend(widget.friendId);
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    String firstCheck = widget.friendId + currentUserUid;
    String secondCheck = currentUserUid + widget.friendId;

    _chatStream = FirebaseFirestore.instance
        .collection('chatMessages')
        .where('messageId', whereIn: [firstCheck, secondCheck])
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        friendName: widget.friendName,
        onRecommendLocationPressed: () {
          _recommendLocation();
          // Handle the recommend location button press here
          // Add the code to trigger the recommend location functionality
        },
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
                    bool isPlaceRecommendation = false;
                    final messageData = messages[index].data()!;
                    final senderId = messageData['senderId'] as String;
                    final messageText = messageData['message'];
                    final timestamp = messageData['timestamp'] as Timestamp?;
                    final String? link = messageData['link'] as String?;

                    if (messageData.containsKey('senderName') || messageData.containsValue('senderName')){
                      isPlaceRecommendation = true;
                    }

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
                          color: isPlaceRecommendation ? Colors.red[400] : isSender ? Colors.blue : Colors.grey,
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
                                if(isPlaceRecommendation){
                                  return const CircleAvatar(
                                    backgroundImage: AssetImage('assets/images/logoWhiteBg.png'  ?? ''),
                                  );
                                } else {
                                  return CircleAvatar(
                                    backgroundImage:
                                    NetworkImage(profilePictureUrl ?? ''),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 8),
                            isPlaceRecommendation && link != null
                                ? RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: getMainText(messageText),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                      text: getLastTwoWords(messageText),
                                      style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Uri linkToMaps = Uri.parse(link);
                                          launchUrl(linkToMaps);
                                        }
                                  ),
                                ],
                              ),
                            )
                                : Text(
                              messageText,
                              style: TextStyle(color: Colors.white),
                            ),
                            FutureBuilder<String?>(
                              future: _formatTimestamp(timestamp, senderId, isPlaceRecommendation),
                              builder: (context, snapshot)

                              {
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
  String getLastTwoWords(String text) {
    List<String> words = text.split(' ');
    if (words.length < 2) return text;
    return words.sublist(words.length - 1).join(' ');
  }

  String getMainText(String text) {
    List<String> words = text.split(' ');
    if (words.length < 2) return '';
    return words.sublist(0, words.length - 1).join(' ');
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
      'messageId' : (currentUserID + widget.friendId),
      'senderId': currentUserID,
      'receiverId': widget.friendId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _sendMessageFromBarkBuddy(String message, String senderName, String profilePicture, Color color, String link) {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('chatMessages').add({
      'participants': [
        currentUserID,
        widget.friendId,
      ],
      'messageId' : (currentUserID + widget.friendId),
      'senderId': 'bark-buddy',
      'receiverId': widget.friendId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'senderName': senderName,
      'profilePicture': profilePicture,
      'link' : link,
      'color': '#${color.value.toRadixString(16)}',
    });
  }
  void _sendWaitMessageFromBarkBuddy() {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    final colorHex = Colors.red.value.toRadixString(16);
    FirebaseFirestore.instance.collection('chatMessages').add({
      'participants': [
        FirebaseAuth.instance.currentUser!.uid,
        widget.friendId,
      ],
      'messageId' : (currentUserID + widget.friendId),
      'senderId': 'bark-buddy-wait-message',
      'receiverId': widget.friendId,
      'message': 'That is all the recommendations for today, check back tomorrow!',
      'timestamp': FieldValue.serverTimestamp(),
      'senderName': 'Bark-buddy',
      'profilePicture': 'assets/images/logoWhiteBg.png',
      'color': colorHex,
    });
  }

  Future<String> _formatTimestamp(Timestamp? timestamp, String senderId, bool isPlaceRecommendation) async {
    if (timestamp != null && !isPlaceRecommendation) {
      final dateTime = timestamp.toDate();
      final formatter = DateFormat('MMM d, HH:mm');
      final ownerName = await getOwnerNameFromOwnerID(senderId).first;
      final formattedTimestamp = formatter.format(dateTime);
      return '$formattedTimestamp - ${ownerName ?? 'Unknown'}';
    } else if(timestamp != null && isPlaceRecommendation) {
      final dateTime = timestamp.toDate();
      final formatter = DateFormat('MMM d, HH:mm');
      const ownerName = 'Bark-Buddy';
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
    List<String?>? closestLocationData;
    String? closestLocationMidPoint;
    String? closestLocationName;
    Position? otherUserLocation;
    DateTime timestamp = DateTime.now();
    bool resetToday = false;
    await for (final position in otherUserLocationStream) {
      otherUserLocation = position;
      break; // Stop listening after receiving the first position
    }

    if (currentUserLocation == null || otherUserLocation == null) {
      // Error handling code
      return;
    }

    if (buttonClicks == 0 || timestamp?.day != DateTime.now().day) {
      // Set the timestamp to the current time and reset buttonClicks
      timestamp = DateTime.now();
      buttonClicks = 1;
      resetToday = true;
    } else {
      buttonClicks++;
    }

    final midpoint = calculateMidpoint(currentUserLocation, otherUserLocation);
    if (buttonClicks <= 3) {
      closestLocationData = await findClosestLocation(midpoint, buttonClicks);
    } else {
      _sendWaitMessageFromBarkBuddy();
      return;
    }
    closestLocationMidPoint = closestLocationData![0];
    closestLocationName = closestLocationData[1];
    closestLocationName ??= 'this dog-friendly spot at';

    if (closestLocationMidPoint == null || closestLocationName == null) {
      _sendMessageFromBarkBuddy('Unable to find a recommended location.', 'bark-buddy', 'assets/images/logoWhiteBg.png', Colors.red, 'googleMapsLinkTrimmed');
      return;
    }

    String googleMapsLink = 'https://maps.google.com/?q=$closestLocationMidPoint';
    final String googleMapsLinkTrimmed = googleMapsLink.replaceAll(' ', '');

    // Check if the location was recommended in the last 24 hours
    final isLocationRecommended = await checkIfLocationRecommendedBefore(currentFriend, FirebaseAuth.instance.currentUser!.uid, googleMapsLinkTrimmed, timestamp);
    if (isLocationRecommended) {
      _sendMessageFromBarkBuddy('This location was already recommended in the last 24 hours.', 'bark-buddy', 'assets/images/logoWhiteBg.png', Colors.red, googleMapsLinkTrimmed);
      return;
    }

    // Store the recommendation in Firestore
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final recommendationData = {
        'location': closestLocationName,
        'link': googleMapsLinkTrimmed,
        'timestamp': FieldValue.serverTimestamp(),
        'participants': [currentFriend, currentUser.uid],
      };
      final userRecommendationsCollection = FirebaseFirestore.instance.collection('recommendation_data');
      await userRecommendationsCollection.add(recommendationData);
    }

    final message = 'Hey, I recommend visiting $closestLocationName $googleMapsLinkTrimmed';
    _sendMessageFromBarkBuddy(message, 'bark-buddy', 'assets/images/logo.png', Colors.red, googleMapsLinkTrimmed);
  }
  Future<bool> checkIfLocationRecommendedBefore(String currentFriend, String currentUserUID, String googleMapsLinkTrimmed, DateTime recommendationTimestamp) async {
    final userRecommendationsCollection = FirebaseFirestore.instance.collection('user_recommendations');
    final querySnapshot = await userRecommendationsCollection
        .where('participants', arrayContainsAny: [currentFriend, currentUserUID])
        .where('link', isEqualTo: googleMapsLinkTrimmed)
        .where('timestamp', isGreaterThanOrEqualTo: recommendationTimestamp)
        .get();

    return querySnapshot.docs.isNotEmpty;
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

  Future<List<String?>?> findClosestLocation(Position midpoint, int index) async {
    final parksCollection = FirebaseFirestore.instance.collection('parks');

    List<String?> closestLocations = [];
    double minDistance = double.infinity;

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
          closestLocations.insert(0, doc['mid_point'] as String?);
          closestLocations.insert(1, doc['od_gis_id'] as String?);
        } else if (closestLocations.length >= index * 2) {
          closestLocations.insert(index * 2, doc['mid_point'] as String?);
          closestLocations.insert(index * 2 + 1, doc['od_gis_id'] as String?);
        }
      }
    });

    if (closestLocations.isEmpty) {
      return null;
    }

    return closestLocations.length >= index * 2
        ? closestLocations.sublist((index - 1) * 2, index * 2 + 1)
        : null;
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

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String friendName;
  final VoidCallback onRecommendLocationPressed;

  const CustomAppBar({
    required this.friendName,
    required this.onRecommendLocationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(friendName),
      actions: [
        TextButton(
          onPressed: onRecommendLocationPressed,
          child: Text(
            'Recommend a new location',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}