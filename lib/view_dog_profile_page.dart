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

  List<String> pictureUrls = []; // replace this with the actual picture urls or file paths fetched from firebase

  @override
  void initState() {
    super.initState();
    DatabaseHandler.getDogId3(userId).listen((dogId) {
      setState(() {
        _dogId = dogId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userId == FirebaseAuth.instance.currentUser?.uid) {
      currentUser = true;
    }
    final dummyStream = FirebaseFirestore.instance
        .collection('Dogs')
        .doc(_dogId ?? 'dummy')
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: dummyStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          if (!snapshot.data!.exists) {
            return const Text('This owner has no dog yet.');
          }

          final dogData = snapshot.data!;
          final activityLevel = dogData.get('Activity Level');
          final age = dogData.get('Age') as int?;
          final bio = dogData.get('Biography');
          final breed = dogData.get('Breed') as String?;
          final gender = dogData.get('Gender') as String?;
          final isCastrated = dogData.get('Is castrated') as bool?;
          final isCastratedText = isCastrated != null ? (isCastrated ? 'Is Castrated' : 'Not Castrated') : '';
          final name = dogData.get('Name');
          final size = dogData.get('Size') as String?;
          final List<dynamic>? profilePic = dogData.get('pictureUrls') as List<dynamic>?;

          if (profilePic != null && profilePic.isNotEmpty) {
            pictureUrls = List<String>.from(profilePic);
          }

          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ImageDialog(
                          pictureUrls: pictureUrls, // pass the actual picture urls or file paths here
                          initialIndex: 0, // Display the second image first
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 100.0,
                      backgroundImage: pictureUrls.isNotEmpty
                          ? NetworkImage(pictureUrls[0])
                          : const AssetImage(
                        'assets/images/placeholder-dog-image2.png',
                      ) as ImageProvider<Object>,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust the padding as needed
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name ?? '',
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ', ${age.toString()}',
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (gender == 'Male')
                          const Icon(
                            Icons.male,
                            size: 30.0,
                            color: Colors.black, // Customize the color as needed
                          )
                        else if (gender == 'Female')
                          const Icon(
                            Icons.female,
                            size: 30.0,
                            color: Colors.black, // Customize the color as needed
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 300.0,
                    child: Wrap(
                      spacing: 10.0, // Adjust the spacing between tags as needed
                      // runSpacing: 1.0, // Adjust the spacing between rows of tags as needed
                      children: [
                        if (breed != null)
                          Chip(
                            label: Text('• $breed'),
                            // Add any additional styling properties for the chip as needed
                          ),
                        if (size != null)
                          Chip(
                            label: Text('• $size'),
                            // Add any additional styling properties for the chip as needed
                          ),
                        if (activityLevel != null)
                          Chip(
                            label: Text('• $activityLevel activity level'),
                            // Add any additional styling properties for the chip as needed
                          ),
                        if (isCastrated != null)
                          Chip(
                            label: Text(isCastrated ? '• Castrated' : '• Not castrated'),
                            // Add any additional styling properties for the chip as needed
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    width: 300.0,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        TextField(
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
                      ],
                    ),
                  )
                ],
              ),
              Positioned(
                top: 10.0,
                left: 10.0,
                child: currentUser
                    ? ElevatedButton.icon(
                  icon: const Icon(Icons.add_location),
                  label: const Text('Add location'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddLocationPage(),
                      ),
                    );
                  },
                )
                    : SizedBox(),
              ),
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewOwnerProfile(userId: userId)),
                    );
                    // something like this is probably needed
                    /*                        if (!currentUser) {
                          Navigator.pop(context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ViewOwnerProfile(userId: userId)),
                          );
                        }*/
                  },
                  child: StreamBuilder<String?>(
                    stream: DatabaseHandler.getOwnerPicStream(userId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundImage: NetworkImage(snapshot.data!),
                          ),
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundImage: AssetImage('assets/images/placeholder-profile-image.png'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ImageDialog(
                          pictureUrls: pictureUrls, // pass the actual picture urls or file paths here
                          initialIndex: 0, // Display the second image first
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 100.0,
                      backgroundImage: pictureUrls.isNotEmpty
                          ? NetworkImage(pictureUrls[0])
                          : const AssetImage(
                              'assets/images/placeholder-dog-image2.png',
                            ) as ImageProvider<Object>,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust the padding as needed
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name ?? '',
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ', ${age.toString()}',
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (gender == 'Male')
                          const Icon(
                            Icons.male,
                            size: 30.0,
                            color: Colors.black, // Customize the color as needed
                          )
                        else if (gender == 'Female')
                          const Icon(
                            Icons.female,
                            size: 30.0,
                            color: Colors.black, // Customize the color as needed
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 300.0,
                    child: Wrap(
                      spacing: 10.0, // Adjust the spacing between tags as needed
                     // runSpacing: 1.0, // Adjust the spacing between rows of tags as needed
                      children: [
                        if (breed != null)
                          Chip(
                            label: Text('• $breed'),
                            // Add any additional styling properties for the chip as needed
                          ),
                        if (size != null)
                          Chip(
                            label: Text('• $size'),
                            // Add any additional styling properties for the chip as needed
                          ),
                        if (activityLevel != null)
                          Chip(
                            label: Text('• $activityLevel activity level'),
                            // Add any additional styling properties for the chip as needed
                          ),
                        if (isCastrated != null)
                          Chip(
                            label: Text(isCastrated ? '• Castrated' : '• Not castrated'),
                            // Add any additional styling properties for the chip as needed
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    width: 300.0,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        TextField(
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
                      ],
                    ),
                  )
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
  const ImageDialog({Key? key, required this.pictureUrls, this.initialIndex = 0})
      : super(key: key);

  final List<String> pictureUrls;
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
    _totalImages = widget.pictureUrls.length;
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
                      image: NetworkImage(widget.pictureUrls[index]),
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
