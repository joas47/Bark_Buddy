import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_handler.dart';
import 'image_handler.dart';
import 'dart:io';
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

  String? _updatedFName;
  String? _updatedLName;
  int? _updatedAge;
  String? _updatedBio;
  String? _updatedProfilePic;

  // _isImageUploading is used to prevent the user from pressing
  // the save button before the image is uploaded and resized
  bool _isImageUploading = false;

  final List<String> _genderOptions = ['Man', 'Woman', 'Other'];

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot>(
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
            _fName = name;
            final surname = userData.get('surname');
            _lName = surname;
            final about = userData.get('about') as String?;
            _bio = about!;
            final age = userData.get('age') as int;
            _age = age;
            final gender = userData.get('gender');
            if (_gender.isEmpty) {
              _gender = gender;
            }
            final String profilePic = userData.get('picture');
            _profilePic = profilePic;
            final String dogRef = userData.get('dogs') as String;

            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16.0),
                    Form(
                      key: _formKey,
                      autovalidateMode: _autoValidate
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: _formUI(name, surname, about, age, gender, about),
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
                    _buildImageUploadButton(),
                    const SizedBox(height: 16.0),
                    Builder(builder: (BuildContext context) {
                      return ElevatedButton(
                        onPressed: () {
                          if (_isImageUploading) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please wait until the image is uploaded.'),
                              ),
                            );
                            return;
                          }
                          if (_validateInputs() &&
                              _gender.isNotEmpty &&
                              _profilePic != null) {
                            if (_updatedFName != null) {
                              _fName = _updatedFName!;
                            }
                            if (_updatedLName != null) {
                              _lName = _updatedLName!;
                            }
                            if (_updatedAge != null) {
                              _age = _updatedAge!;
                            }
                            if (_updatedBio != null) {
                              _bio = _updatedBio!;
                            }
                            if (_updatedProfilePic != null) {
                              _profilePic = _updatedProfilePic;
                            }
                            DatabaseHandler.updateUser(_fName, _lName, _gender,
                                _age, _bio, _profilePic, dogRef);
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
              ],
            );
          },
        ),
      ),
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
        decoration: const InputDecoration(
          labelText: 'First name',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.name,
        onChanged: (value) {
          _updatedFName = value;
        },
      ),
      const SizedBox(height: 16.0),
      TextFormField(
        initialValue: surname,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your last name.';
          }
          return null;
        },
        decoration: const InputDecoration(
          labelText: 'Last name',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.name,
        onChanged: (value) {
          _updatedLName = value;
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
        decoration: const InputDecoration(
          labelText: 'Age',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          _updatedAge = int.tryParse(value) ?? -1;
        },
      ),
      const SizedBox(height: 16.0),
      TextFormField(
        initialValue: about,
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
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          _updatedBio = value;
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

  Widget _buildImageUploadButton() {
    String storageUrl = "gs://bark-buddy.appspot.com";
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Update profile picture:',
          style: TextStyle(fontSize: 18.0),
        ),
        const SizedBox(width: 16.0),
        IconButton(
          onPressed: () async {
            // show dialog with options to choose image or take a new one
            final selectedImage = await ImageUtils.showImageSourceDialog(context);

            // upload image to Firebase Storage
            if (selectedImage != null) {
              setState(() {
                _isImageUploading = true;
              });
              final imageUrl = await ImageUtils.uploadImageToFirebase(
                  selectedImage[0], storageUrl, ImageType.owner);
              if (mounted) {
                setState(() {
                  _updatedProfilePic = imageUrl;
                  _isImageUploading = false;
                });
              }
            }
          },
          icon: _isImageUploading
              ? const CircularProgressIndicator()
              : _updatedProfilePic != null
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : _profilePic != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(_profilePic!),
                          radius: 30)
                      : const Icon(Icons.add_a_photo),
        ),
      ],
    );
  }
}
