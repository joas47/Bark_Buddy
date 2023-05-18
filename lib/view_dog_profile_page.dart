import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/add_location_page.dart';
import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/settings_page.dart';
import 'package:cross_platform_test/view_owner_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'database_handler.dart';

import 'edit_dog_profile_page.dart';


class ViewDogProfilePage extends StatefulWidget {
  String? userId;
  ViewDogProfilePage({Key? key, this.userId = 'defaultValue'}) : super(key: key);


  @override
  _ViewDogProfilePageState createState() => _ViewDogProfilePageState(userId);
}

class _ViewDogProfilePageState extends State<ViewDogProfilePage> {
  String? _dogId;
  String? userId;
  bool currentUser = false;
  _ViewDogProfilePageState(this.userId);


  @override
  void initState() {
    super.initState();
    currentUser = false;
    DatabaseHandler.getDogId3(userId).listen((dogId) {
      setState(() {
        _dogId = dogId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if(userId == FirebaseAuth.instance.currentUser?.uid){
      currentUser = true;
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('View Dog Profile'),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Dogs')
              .doc(_dogId ?? 'dummy')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          if (!snapshot.data!.exists) {
            return const Text('This owner has no dog yet.');
          }
          try {
            snapshot.data!.get('friends');
          } on StateError {
            return const Text('StateError: This owner has no friends yet.');
          }

          final dogData = snapshot.data!;
          final activityLevel = dogData.get('Activity Level');
          final age = dogData.get('Age') as int?;
          final bio = dogData.get('Biography');
          final breed = dogData.get('Breed') as String?;
          final gender = dogData.get('Gender') as String?;
          final isCastrated = dogData.get('Is castrated') as bool?;
          final isCastratedText = isCastrated != null
              ? (isCastrated ? 'Is Castrated' : 'Not Castrated')
              : '';
          final name = dogData.get('Name');
          final size = dogData.get('Size') as String?;
          final String? profilePic = dogData.get('picture') as String?;

          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    // TODO: display the add location only if we're in the current user's profile
                    child: currentUser
                        ? ElevatedButton.icon(
                            icon: const Icon(Icons.add_location),
                            label: const Text('Add location'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AddLocationPage()),
                              );
                            },
                          )
                        : null,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        // TODO: make the bottom navigation bar persist when navigating to the owner profile page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewOwnerProfile(userId: userId)),
                        );
                      },
                      child: StreamBuilder<String?>(
                        stream: DatabaseHandler.getOwnerPicStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasData && snapshot.data != null) {
                            return CircleAvatar(
                              radius: 50.0,
                              backgroundImage: NetworkImage(snapshot.data!),
                            );
                          } else {
                            return CircleAvatar(
                              radius: 50.0,
                              backgroundImage: AssetImage('assets/images/placeholder-profile-image.png'),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.network(
                                profilePic ?? '',
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 100.0,
                      backgroundImage: profilePic != null
                          ? NetworkImage(profilePic)
                          : AssetImage('assets/images/placeholder-profile-image.png') as ImageProvider<Object>,
                    ),
                  ),
                  Text(
                    name ?? '',
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 300.0,
                    child: TextField(
                      readOnly: true,
                      minLines: 1,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: '• Breed: ${breed ?? ''}\n'
                            '• Gender: ${gender ?? ''}\n'
                            '• Age: ${age.toString()} years old\n'
                            '• Size: ${size ?? ''}\n'
                            '• Activity level: ${activityLevel ?? ''}\n'
                            '• $isCastratedText',
                        border: const OutlineInputBorder(),
                        suffixIcon: currentUser ?
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditDogProfilePage()));
                          },
                        ) : null,
                      ),
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    width: 300.0,
                    child: TextField(
                      readOnly: true,
                      minLines: 5,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '• $bio',
                        border: const OutlineInputBorder(),
                      ),
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }


  void getDogID(void Function(String) onDogID) {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users.doc(userUid).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        String dogRef = documentSnapshot.get('dogs');
        print("dogRef:$dogRef");
        onDogID(dogRef);
      } else {
        print('Document does not exist on the database');
        onDogID('');
      }
    });
  }
}

class ImageDialog extends StatefulWidget {
  const ImageDialog({Key? key, required this.imagePaths, this.initialIndex = 0})
      : super(key: key);

  final List<String> imagePaths;
  final int initialIndex;

  @override
  _ImageDialogState createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  late PageController _pageController;
  late int _currentIndex;
  late int _totalImages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _totalImages = widget.imagePaths.length;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 500,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: _totalImages,
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: ExactAssetImage(widget.imagePaths[index]),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                );
              },
            ),
            if (_currentIndex > 0)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ),
            if (_currentIndex < _totalImages - 1)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child:
                  const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
