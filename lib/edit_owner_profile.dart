import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/make_dog_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_handler.dart';
import 'image_handler.dart';

class EditOwnerProfilePage extends StatefulWidget {
  const EditOwnerProfilePage({super.key});

  @override
  State<EditOwnerProfilePage> createState() => _EditOwnerProfilePageState();
}

class _EditOwnerProfilePageState extends State<EditOwnerProfilePage> {
  String _fName = '';
  String _lName = '';
  String _gender = '';
  int _age = -1;
  String _bio = '';
  String? _profilePic = '';

  final List<String> _genderOptions = ['Man', 'Woman', 'Other'];

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    //DatabaseHandler.getOwnerProfileData();
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
      ),
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
            final name = userData.get('name');
            final surname = userData.get('surname');
            final about = userData.get('about') as String?;
            final age = userData.get('age');
            final gender = userData.get('gender');
            final bio = userData.get('about');
            final String? profilePic = userData.get('picture') as String?;

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
                    child: _formUI(name, surname, about, age, gender, bio),
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
                          DatabaseHandler.addUserToDatabase(
                              _fName, _lName, _gender, _age, _bio, _profilePic);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterDogPage()));
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
    );
  }

  Widget _formUI(String name, String surname, String? about, int age,
      String gender, String bio) {
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
          //hintText: name,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.name,
        onChanged: (value) {
          _fName = value;
        },
      ),
      const SizedBox(height: 16.0),
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your last name.';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Last name',
          hintText: surname,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.name,
        onChanged: (value) {
          _lName = value;
        },
      ),
      const SizedBox(height: 16.0),
      TextFormField(
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your age.';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Age',
          hintText: age.toString(),
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          _age = int.tryParse(value) ?? -1;
        },
      ),
      const SizedBox(height: 16.0),
      TextFormField(
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
          labelText: 'About you',
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
