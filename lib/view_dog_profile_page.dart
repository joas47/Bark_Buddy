import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/settings_page.dart';
import 'package:cross_platform_test/view_owner_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'database_handler.dart';

import 'edit_dog_profile_page.dart';

/*class ViewDogProfilePage extends StatelessWidget {
  const ViewDogProfilePage({super.key});


  @override
  Widget build(BuildContext context) {
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
            },
          ),
        ],
      ),

      // TODO: This is a lot of reading from the database. Is there a better way?
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userUid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final userData = snapshot.data!;
            final dog = userData.get('dogs');

            return Stack(alignment: Alignment.center, children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: ElevatedButton(
                        child: const Text('Add place'),
                        onPressed: () {},
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage: AssetImage(
                              'assets/images/placeholder-dog-image2.png'),
                        ),
                      ),
                    ),
                  ]),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                      onTap: () async {
                        await showDialog(
                            context: context,
                            builder: (context) => const ImageDialog(
                                  imagePaths: [
                                    'assets/images/placeholder-dog-image.png',
                                    'assets/images/placeholder-dog-image2.png',
                                  ],
                                  initialIndex: 0, // Display second image first
                                ));
                      },
                      child: const CircleAvatar(
                        radius: 100.0,
                        backgroundImage:
// TODO: get this information from the database
                            AssetImage(
                                'assets/images/placeholder-dog-image2.png'),
                      )),
                  Text(
                    name + ' ' + surname,
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    //height: 500.0,
                    width: 300.0,
                    child: TextField(
                      readOnly: true,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                          // TODO: get this information from the database
                          hintText: '• ' + gender! + '\n• ' + age.toString(),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => const EditOwnerProfile()));
                            },
                          )),
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    //height: 500.0,
                    width: 300.0,
                    child: TextField(
                      readOnly: true,
                      minLines: 5,
                      maxLines: 5,
                      decoration: InputDecoration(
                        // TODO: get this information from the database
                        hintText: '• ' + about!,
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ]);
          }),
    );
  }
}*/

class ViewDogProfilePage extends StatefulWidget {
  const ViewDogProfilePage({Key? key}) : super(key: key);

  @override
  _ViewDogProfilePageState createState() => _ViewDogProfilePageState();
}

class _ViewDogProfilePageState extends State<ViewDogProfilePage> {
  String? _dogId;

  @override
  void initState() {
    super.initState();
    DatabaseHandler.getDogId3().listen((dogId) {
      setState(() {
        _dogId = dogId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
              return const Text('Document does not exist');
            }

          final dogData = snapshot.data!;
          final activityLevel = dogData.get('Activity Level');
          final age = dogData.get('Age') as int?;
          final bio = dogData.get('Biography');
          final breed = dogData.get('Breed') as String?;
          final gender = dogData.get('Gender') as String?;
          final isCastrated = dogData.get('Is castrated') as bool?;
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
                    child: ElevatedButton(
                      child: const Text('Add location'),
                      onPressed: () {},
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViewOwnerProfile(),
                          ),
                        );
                      },
                      child: FutureBuilder<String?>(
                        future: DatabaseHandler.getOwnerPic(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasData && snapshot.data != null) {
                            return CircleAvatar(
                              radius: 50.0,
                              backgroundImage: NetworkImage(snapshot.data!),
                            );
                          } else {
                            return CircleAvatar(
                              radius: 50.0,
                              backgroundImage: AssetImage(
                                'assets/images/placeholder-profile-image.png',
                              ),
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
                  CircleAvatar(
                    radius: 100.0,
                    backgroundImage: profilePic != null
                        ? NetworkImage(profilePic)
                        : AssetImage(
                      'assets/images/placeholder-profile-image.png',
                    ) as ImageProvider<Object>,
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
                        hintText: '• ${breed ?? ''}\n'
                            '• ${gender ?? ''}\n'
                            '• ${age.toString()} years\n'
                            '• ${size ?? ''}\n'
                            '• ${activityLevel ?? ''}\n'
                            '• ${isCastrated ?? ''}',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => const EditDogProfile()));
                          },
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    //height: 500.0,
                    width: 300.0,
                    child: TextField(
                      readOnly: true,
                      minLines: 5,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '• ' + bio!,
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      )
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
