import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/view_dog_profile_page.dart';
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
  Map<String, bool> requestStatus = {};
  bool requestSent = false;

  @override
  Widget build(BuildContext context) {
    final usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Recommend location'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: usersStream,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }
            Map<String, dynamic>? data =
            snapshot.data?.data() as Map<String, dynamic>?;
            if (data != null) {
              List<dynamic> friends = data['friends'] ?? [];
              List<dynamic> matches = data['matches'] ?? [];
              List<dynamic> allUsers = [...friends, ...matches];

              if (allUsers.isEmpty) {
                return Container(
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
                          'This chat is empty. \n Go find a match!',
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: allUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  String usersFriendId = allUsers[index];
                  final usersStream = FirebaseFirestore.instance
                      .collection('users')
                      .doc(usersFriendId)
                      .snapshots();
                  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
                  String firstCheck = allUsers[index] + currentUserUid;
                  String secondCheck = currentUserUid + allUsers[index];

                  final chatStream = FirebaseFirestore.instance
                        .collection('chatMessages')
                        .where('messageId', whereIn: [firstCheck, secondCheck])
                        .orderBy('timestamp', descending: true)
                        .snapshots();
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: usersStream,
                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                      if (userSnapshot.hasError) {
                        return const Text('Something went wrong');
                      }
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Loading");
                      }
                      Map<String, dynamic>? userData = userSnapshot.data?.data() as Map<String, dynamic>?;

                      if (userData == null) {
                        return const Text('User not found');
                      }

                      return StreamBuilder<String?>(
                        stream: _MatchChatPageState.getDogNameFromOwnerID(usersFriendId),
                        builder: (BuildContext context, AsyncSnapshot<String?> dogNameSnapshot) {
                          if (dogNameSnapshot.hasError) {
                            return const Text('Something went wrong: user has no dog');
                          }
                          if (dogNameSnapshot.connectionState == ConnectionState.waiting) {
                            return const Text("Loading");
                          }
                          String? dogName = dogNameSnapshot.data;

                          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: chatStream,
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                          QuerySnapshot<Map<String, dynamic>>>
                                      chatSnapshot) {
                                if (chatSnapshot.hasError) {
                                  return const Text('Something went wrong');
                                }
                                if (chatSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text("Loading");
                                }
                                List<
                                        QueryDocumentSnapshot<
                                            Map<String, dynamic>>> messages =
                                    chatSnapshot.data!.docs.cast<
                                        QueryDocumentSnapshot<
                                            Map<String, dynamic>>>();

                                Timestamp basicTimestamp =
                                    Timestamp.fromMicrosecondsSinceEpoch(1000);

                                String latestMessage = messages.isNotEmpty
                                    ? messages.first['message'] ?? ''
                                    : '';
                                Timestamp latestMessageTimeStamp = messages.isNotEmpty
                                    ? (messages.first['timestamp'] as Timestamp? ?? basicTimestamp)
                                    : basicTimestamp;
                                String timestampConverted;
                                if (latestMessageTimeStamp != '' &&
                                    latestMessageTimeStamp != basicTimestamp) {
                                  DateTime dateTime =
                                      latestMessageTimeStamp.toDate();

                                  timestampConverted =
                                      DateFormat.Hm().format(dateTime);
                                } else if (latestMessageTimeStamp ==
                                    basicTimestamp) {
                                  timestampConverted = '';
                                } else {
                                  timestampConverted = 'error';
                                }
                                if (latestMessage.length > 20) {
                                  latestMessage =
                                      '${latestMessage.substring(0, 20)}...';
                                }

                                bool isRead = messages.isNotEmpty ? messages.first['read'] ?? false : false;
                              bool isBold = messages.isNotEmpty && messages.first['messageId'] == firstCheck;

                              TextStyle latestMessageStyle = TextStyle(
                                fontWeight: !isRead && isBold ? FontWeight.bold : FontWeight.normal,
                              );

                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MatchChatPage(
                                        friendId: usersFriendId,
                                        friendName: userData['name'],
                                      ),
                                    ),
                                  );
                                },
                                title: RichText(
                                  text: TextSpan(
                                    text: "${userData['name']} ",
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
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$latestMessage $timestampConverted',
                                      style: latestMessageStyle,
                                    ),
                                  ],
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(userData['picture'] ?? ''),
                                  radius: 30.0,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewDogProfilePage(userId: usersFriendId),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _showChatWindow(usersFriendId);
                                        },
                                      icon: const Icon(Icons.menu),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            } else {
              return const ListTile(
                  title: Text('No friends or matches'),
                );
              }
          },
        ),
      ),
    ),);
  }

  void _showChatWindow(String friendId) async {
    bool isFriend = false;

    final userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            width: 220,
            color: Colors.white,
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: userStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        Map<String, dynamic>? data = snapshot.data?.data();
                        if (data != null && data['matches'] != null &&
                            data['matches'].contains(friendId)) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(200, 30),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);

                              bool? confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: const Text(
                                        'Are you sure you want to unmatch?'),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: const Text('Confirm'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmed != null && confirmed) {
                                DatabaseHandler.unmatch(friendId);
                              }
                            },
                            child: const Text('Unmatch'),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: userStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        Map<String, dynamic>? data = snapshot.data?.data();
                        if (data != null && data['friends'] != null) {
                          List<dynamic> friends = data['friends'];
                          isFriend = friends.contains(friendId);

                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(200, 30),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);

                              bool? confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: isFriend
                                        ? const Text(
                                        'Are you sure you want to unfriend?')
                                        : const Text(
                                        'Are you sure you want to add as a friend?'),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: const Text('Confirm'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              bool requestSent = await DatabaseHandler
                                  .checkIfFriendRequestSent(friendId);

                              if (confirmed != null && confirmed) {
                                if (isFriend) {
                                  DatabaseHandler.removeFriend(friendId);
                                  setState(() {
                                    requestStatus[friendId] = false;
                                  });
                                } else if (!requestSent) {
                                  DatabaseHandler.sendFriendRequest(friendId);
                                  setState(() {
                                    requestSent = true;
                                    requestStatus[friendId] = true;
                                  });
                                }
                              }
                            },
                            child: isFriend
                                ? const Text('Unfriend')
                                : (requestStatus[friendId] == true)
                                ? const Text('Friend request sent')
                                : const Text('Send friend request'),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 30),
                      ),
                      onPressed: () {
                        DatabaseHandler.block(friendId);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User blocked'),
                          ),
                        );
                      },
                      child: const Text('Block'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 30),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
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
  late SharedPreferences _prefs;
  int buttonClicks = 0;
  int buttonClicks2 = 0;
  bool isChatWindowActive = false;
  bool isFirstRecommendation = true;

  @override
  void initState() {
    super.initState();
    isChatWindowActive = true;

    setCurrentFriend(widget.friendId);
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    int buttonClicks1;

    String firstCheck = widget.friendId + currentUserUid;
    String secondCheck = currentUserUid + widget.friendId;

    _chatStream = FirebaseFirestore.instance
        .collection('chatMessages')
        .where('messageId', whereIn: [firstCheck, secondCheck])
        .orderBy('timestamp', descending: true)
        .snapshots();

    _chatStream.listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
      for (QueryDocumentSnapshot<
          Map<String, dynamic>> messageSnapshot in snapshot.docs) {
        if (isChatWindowActive && messageSnapshot['messageId'] == firstCheck) {
          messageSnapshot.reference.update({'read': true});
        }
      }
    });

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
        buttonClicks1 = _prefs.getInt('buttonClicks' + currentFriend) ?? 0;
        buttonClicks2 = _prefs.getInt(currentFriend + 'buttonClicks') ?? 0;
        if (buttonClicks1 < buttonClicks2) {
          buttonClicks = buttonClicks2;
        } else {
          buttonClicks = buttonClicks1;
        }
      });

      _chatStream.listen((snapshot) {
        if (snapshot.docs.isEmpty) {
          _recommendLocation();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        friendName: widget.friendName,
        onRecommendLocationPressed: () {
          _recommendLocation();
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
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
                    final messageData = messages[index].data();
                    final senderId = messageData['senderId'] as String;
                    final messageText = messageData['message'];
                    final timestamp = messageData['timestamp'] as Timestamp?;
                    final String? link = messageData['link'] as String?;

                    if (messageData.containsKey('senderName') ||
                        messageData.containsValue('senderName')) {
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
                          color: isPlaceRecommendation
                              ? Colors.red[400]
                              : isSender
                              ? Colors.blue
                              : Colors.grey,
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
                                  return const CircularProgressIndicator();
                                }
                                final profilePictureUrl = snapshot.data;
                                if (isPlaceRecommendation) {
                                  return const CircleAvatar(
                                    backgroundImage: AssetImage(
                                        'assets/images/logoWhiteBg.png' ?? ''),
                                  );
                                } else {
                                  return CircleAvatar(
                                    backgroundImage:
                                    NetworkImage(profilePictureUrl ?? ''),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            isPlaceRecommendation && link != null
                                ? RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: getMainText(messageText),
                                    style: const TextStyle(
                                        color: Colors.white),
                                  ),
                                  TextSpan(
                                      text: getLastTwoWords(messageText),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          decoration:
                                          TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Uri linkToMaps =
                                          Uri.parse(link);
                                          launchUrl(linkToMaps);
                                        }),
                                ],
                              ),
                            )
                                : Text(
                              messageText,
                              style: const TextStyle(color: Colors.white),
                            ),
                            FutureBuilder<String?>(
                              future: _formatTimestamp(
                                  timestamp, senderId, isPlaceRecommendation),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    'Loading...',
                                    style: TextStyle(color: Colors.white),
                                  );
                                }
                                final formattedTimestamp =
                                    snapshot.data ?? 'Unknown';
                                return Text(
                                  formattedTimestamp,
                                  style: const TextStyle(color: Colors.white),
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
                    decoration: const InputDecoration(
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
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    isChatWindowActive = false;
    super.dispose();
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
      'messageId': (currentUserID + widget.friendId),
      'senderId': currentUserID,
      'receiverId': widget.friendId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  void _sendMessageFromBarkBuddy(String message, String senderName,
      String profilePicture, Color color, String link) {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('chatMessages').add({
      'participants': [
        currentUserID,
        widget.friendId,
      ],
      'messageId': (currentUserID + widget.friendId),
      'senderId': 'BarkBuddy',
      'receiverId': widget.friendId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'senderName': senderName,
      'profilePicture': profilePicture,
      'link': link,
      'read': false,
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
      'messageId': (currentUserID + widget.friendId),
      'senderId': 'BarkBuddy-wait-message',
      'receiverId': widget.friendId,
      'message':
      'That is all the recommendations for today, check back tomorrow!',
      'timestamp': FieldValue.serverTimestamp(),
      'senderName': 'BarkBuddy',
      'read': false,
      'profilePicture': 'assets/images/logoWhiteBg.png',
      'color': colorHex,
    });
  }

  Future<String> _formatTimestamp(Timestamp? timestamp, String senderId,
      bool isPlaceRecommendation) async {
    if (timestamp != null && !isPlaceRecommendation) {
      final dateTime = timestamp.toDate();
      final formatter = DateFormat('MMM d, HH:mm');
      final ownerName = await getOwnerNameFromOwnerID(senderId).first;
      final formattedTimestamp = formatter.format(dateTime);
      return '$formattedTimestamp - ${ownerName ?? 'Unknown'}';
    } else if (timestamp != null && isPlaceRecommendation) {
      final dateTime = timestamp.toDate();
      final formatter = DateFormat('MMM d, HH:mm');
      const ownerName = 'BarkBuddy';
      final formattedTimestamp = formatter.format(dateTime);
      return '$formattedTimestamp - ${ownerName ?? 'Unknown'}';
    }
    return 'Loading...';
  }

  static Stream<String?> getDogNameFromOwnerID(String ownerID) async* {
    final users = FirebaseFirestore.instance.collection('users');
    final dogs = await users
        .doc(ownerID)
        .get()
        .then((doc) => doc.get('dogs') as String?);

    if (dogs != null) {
      final dog = FirebaseFirestore.instance.collection('Dogs');
      final name =
      await dog.doc(dogs).get().then((doc) => doc.get('Name') as String?);
      yield name;
    } else {
      yield null;
    }
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

  String currentFriend = 'null';

  void setCurrentFriend(String friendId) {
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
    final Stream<Position?> otherUserLocationStream =
    getOtherUserLocation(currentFriend);
    List<String?>? closestLocationData;
    String? closestLocationMidPoint;
    String? closestLocationName;
    Position? otherUserLocation;
    DateTime timestamp;
    int alreadyFoundCounter = 0;
    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    String firstCheck = (currentUserUid! + currentFriend);
    String secondCheck = (currentFriend + currentUserUid!);
    await for (final position in otherUserLocationStream) {
      otherUserLocation = position;
      break; // Stop listening after receiving the first position
    }

    if (currentUserLocation == null || otherUserLocation == null) {
      return;
    }
    // Fetch the latest message timestamp from recommendation_data collection
    final recommendationsCollection = FirebaseFirestore.instance.collection(
        'recommendation_data');
    final query = recommendationsCollection
        .where('recommendationId', whereIn: [firstCheck, secondCheck])
        .orderBy('timestamp', descending: true)
        .limit(1);
    final querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      final latestRecommendation = querySnapshot.docs.first;
      timestamp = (latestRecommendation['timestamp'] as Timestamp).toDate();
      // Use the retrieved timestamp for further processing
    } else {
      // No recommendation found with the given recommendationIds
      timestamp = DateTime.fromMicrosecondsSinceEpoch(10000);
      print('No matching recommendation found.');
    }
    if (buttonClicks == 0 || timestamp?.day != DateTime
        .now()
        .day) {
      // Set the timestamp to the current time and reset buttonClicks
      timestamp = DateTime.now();
      buttonClicks = 1;
    } else {
      buttonClicks++;
      _prefs.setInt(
          'buttonClicks' + currentFriend + currentUserUid, buttonClicks);
      _prefs.setInt(
          currentFriend + 'buttonClicks' + currentUserUid, buttonClicks);
    }

    final midpoint = calculateMidpoint(currentUserLocation, otherUserLocation);
    if (buttonClicks < 3) {
      closestLocationData = await findClosestLocation(midpoint, buttonClicks);
    } else {
      _sendWaitMessageFromBarkBuddy();
      return;
    }
    closestLocationMidPoint = closestLocationData![0];
    closestLocationName = closestLocationData[1];
    closestLocationName ??= 'this dog-friendly spot at';

    if (closestLocationMidPoint == null || closestLocationName == null) {
      _sendMessageFromBarkBuddy(
          'Unable to find a recommended location.',
          'BarkBuddy',
          'assets/images/logoWhiteBg.png',
          Colors.red,
          'googleMapsLinkTrimmed');
      return;
    }
    String googleMapsLink =
        'https://maps.google.com/?q=$closestLocationMidPoint';
    String googleMapsLinkTrimmed = googleMapsLink.replaceAll(' ', '');


    // Check if the location was recommended in the last 24 hours
    final isLocationRecommended = await checkIfLocationRecommendedBefore(
        currentFriend,
        FirebaseAuth.instance.currentUser!.uid,
        googleMapsLinkTrimmed,
        timestamp);
    if (isLocationRecommended || isFirstRecommendation) {
      alreadyFoundCounter++;
      closestLocationData =
      await findClosestLocation(midpoint, buttonClicks + alreadyFoundCounter);

      closestLocationMidPoint = closestLocationData![0];
      closestLocationName = closestLocationData[1];
      closestLocationName ??= 'this dog-friendly spot at';
      googleMapsLink = 'https://maps.google.com/?q=$closestLocationMidPoint';
      googleMapsLinkTrimmed = googleMapsLink.replaceAll(' ', '');
      isFirstRecommendation = false;
    }
    print(closestLocationData?.length.toString());


    // Store the recommendation in Firestore
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final recommendationData = {
        'location': closestLocationName,
        'link': googleMapsLinkTrimmed,
        'timestamp': FieldValue.serverTimestamp(),
        'participants': [currentFriend, currentUser.uid],
        'recommendationId': (currentUser.uid + currentFriend),
      };
      final userRecommendationsCollection =
      FirebaseFirestore.instance.collection('recommendation_data');
      await userRecommendationsCollection.add(recommendationData);
    }

    final message =
        'Hey, I recommend visiting $closestLocationName  $googleMapsLinkTrimmed';
    _sendMessageFromBarkBuddy(message, 'BarkBuddy', 'assets/images/logo.png',
        Colors.red, googleMapsLinkTrimmed);
  }

  Future<bool> checkIfLocationRecommendedBefore(String currentFriend,
      String currentUserUID,
      String googleMapsLinkTrimmed,
      DateTime recommendationTimestamp) async {
    final userRecommendationsCollection =
    FirebaseFirestore.instance.collection('recommendation_data');
    final querySnapshot1 = await userRecommendationsCollection
        .where('recommendationId',
        isEqualTo: (currentFriend + currentUserUID))
        .where('link', isEqualTo: googleMapsLinkTrimmed)
        .where('timestamp', isGreaterThanOrEqualTo: recommendationTimestamp)
        .get();
    final querySnapshot2 = await userRecommendationsCollection
        .where('recommendationId',
        isEqualTo: (currentUserUID + currentFriend))
        .where('link', isEqualTo: googleMapsLinkTrimmed)
        .where('timestamp', isGreaterThanOrEqualTo: recommendationTimestamp)
        .get();
    print(querySnapshot1.docs.toString());
    print(querySnapshot2.docs.toString());


    return (querySnapshot1.docs.isNotEmpty || querySnapshot2.docs.isNotEmpty);
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

    double lat3 = atan2(sin(lat1) + sin(lat2),
        sqrt((cos(lat1) + bx) * (cos(lat1) + bx) + by * by));
    double lon3 = lon1 + atan2(by, cos(lat1) + bx);

    // Convert back to degrees
    lat3 = _toDegrees(lat3);
    lon3 = _toDegrees(lon3);

    return Position(
      latitude: lat3,
      longitude: lon3,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),
    );
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  double _toDegrees(double radian) {
    return radian * 180 / pi;
  }

  Future<List<String?>?> findClosestLocation(
      Position midpoint, int index) async {
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
        ? closestLocations.sublist((index - 1) * 2, index * 2 + 6)
        : null;
  }

  Position parseCoordinatesString(String coordinatesString) {
    final coordinatesList = coordinatesString.split(', ');
    final latitude = double.parse(coordinatesList[0]);
    final longitude = double.parse(coordinatesList[1]);
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
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(friendName),
      actions: [
        TextButton(
          onPressed: onRecommendLocationPressed,
          child: const Text(
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
