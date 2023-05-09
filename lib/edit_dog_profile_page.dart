import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/make_dog_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_handler.dart';
import 'image_handler.dart';

class EditDogProfilePage extends StatefulWidget {
  const EditDogProfilePage({super.key});

  @override
  State<EditDogProfilePage> createState() => _EditDogProfilePageState();
}

class _EditDogProfilePageState extends State<EditDogProfilePage> {
  String _name = '';
  String _breed = '';
  String _gender = '';
  int _age = -1;
  String _bio = '';
  String? _profilePic = '';

  final List<String> _genderOptions = ['Man', 'Woman', 'Other'];

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

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
    //DatabaseHandler.getOwnerProfileData();
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Dog profile'),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot>(
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
              final age = dogData.get('Age');
              final bio = dogData.get('Biography') as String?;
              final breed = dogData.get('Breed');
              final gender = dogData.get('Gender') as String?;
              final isCastrated = dogData.get('Is castrated') as bool?;
              final name = dogData.get('Name');
              final size = dogData.get('Size') as String?;
              final String? profilePic = dogData.get('picture') as String?;

              _profilePic = profilePic;

              return Stack(alignment: Alignment.center, children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16.0),
                    Form(
                      key: _formKey,
                      autovalidateMode: _autoValidate
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: _formUI(name, breed, age, bio),
                    ),
                    const SizedBox(height: 16.0),
                    // TODO: move this Text so it's next to the radio buttons instead of above.
                    const Text('Kön'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _genderOptions
                          .map((option) => Row(
                        children: [
                          Radio(
                            value: option,
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value.toString();
                              });
                            },
                          ),
                          Text(option),
                          const SizedBox(width: 16.0),
                        ],
                      ))
                          .toList(),
                    ),
                    const SizedBox(height: 16.0),
                    _buildProfilePictureUploadButton(),
                    const SizedBox(height: 16.0),
                    Builder(builder: (BuildContext context) {
                      return ElevatedButton(
                        onPressed: () {
                          // TODO: uncomment this
                          if (_validateInputs() &&
                              _gender.isNotEmpty &&
                              _profilePic != null) {
                            // TODO: save owner to database  (uncomment the line below)
                            /*DatabaseHandler.updateDog(_name, _breed, _gender,
                                _age, _bio, _profilePic);*/
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'You must fill out all the fields before continuing.'),
                              ),
                            );
                          }
                        },
                        child: const Text('Save profile'),
                      );
                    }),
                  ],
                ),
              ]);
            }),
      ),
    );
  }

  Widget _formUI(String name, String breed, int age,
       String? bio) {
    return Column(children: [
      TextFormField(
        initialValue: name,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your first name.';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'First name',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.name,
        onChanged: (value) {
          _name = value;
        },
      ),
      const SizedBox(height: 16.0),
      TextFormField(
        initialValue: breed,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your last name.';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Breed',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.name,
        onChanged: (value) {
          _breed = value;
        },
      ),
      const SizedBox(height: 16.0),
      TextFormField(
        initialValue: age.toString(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your age.';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Age',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          _age = int.tryParse(value) ?? -1;
        },
      ),
      const SizedBox(height: 16.0),
      TextFormField(
        initialValue: bio,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your bio.';
          }
          return null;
        },
        keyboardType: TextInputType.multiline,
        minLines: 4,
        maxLines: 8,
        decoration: InputDecoration(
          labelText: 'About dog',
          hintText: bio,
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          _bio = value;
        },
      ),
    ]);
  }

  bool _validateInputs() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      return true;
    } else {
      setState(() {
        _autoValidate = true;
      });
      return false;
    }
  }

  Widget _buildProfilePictureUploadButton() {
    String storageUrl = "gs://bark-buddy.appspot.com";
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Upload profile picture',
          style: TextStyle(fontSize: 18.0),
        ),
        const SizedBox(width: 16.0),
        IconButton(
          onPressed: () async {
            // show dialog with options to choose image or take a new one
            final selectedImage =
            await ImageUtils.showImageSourceDialog(context);

            // upload image to Firebase Storage
            if (selectedImage != null) {
              final imageUrl = await ImageUtils.uploadImageToFirebase(
                  selectedImage, storageUrl);
              setState(() {
                _profilePic = imageUrl;
              });
            }
          },
          icon: const Icon(Icons.upload),
        ),
      ],
    );
  }
}
