import 'package:cross_platform_test/make_dog_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'file_selector_handler.dart';
import 'database_handler.dart';
import 'image_handler.dart';
import 'dart:io';

class MakeOwnerProfilePage extends StatefulWidget {
  const MakeOwnerProfilePage({super.key});

  @override
  State<MakeOwnerProfilePage> createState() => _MakeOwnerProfilePageState();
}

class _MakeOwnerProfilePageState extends State<MakeOwnerProfilePage> {
  String _fName = '';
  String _lName = '';
  String _gender = '';
  int _age = -1;
  String _bio = '';
  String? _profilePic = '';

  // _isImageUploading is used to prevent the user from pressing
  // the save button before the image is uploaded and resized
  bool _isImageUploading = false;

  final List<String> _genderOptions = ['Man', 'Woman', 'Other'];

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Owner Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16.0),
              Form(
                key: _formKey,
                autovalidateMode: _autoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: _formUI(),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Gender',
                style: TextStyle(fontSize: 18),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _genderOptions
                    .map((option) => Row(
                  children: [
                    Transform.scale(
                      scale: 1.4,
                      child: Radio(
                        value: option,
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value.toString();
                          });
                        },
                      ),
                    ),
                    Text(option,
                      style: TextStyle(fontSize: 16),
                    ),
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
                    // TODO: if you press Submit before the image is uploaded, you will get an error
                    if (_isImageUploading) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please wait until the image is uploaded.'),
                        ),
                      );
                      return;
                    }
                    if (_validateInputs() &&
                        _gender.isNotEmpty &&
                        _profilePic != null &&
                        _profilePic!.isNotEmpty) {
                      DatabaseHandler.addUserToDatabase(
                          _fName, _lName, _gender, _age, _bio, _profilePic);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterDogPage()));
                    } else if (_gender.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Gender must not be empty')
                        ),
                      );
                    } else if (_profilePic == null || _profilePic!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'You must upload a picture')
                        ),
                      );
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
        ),
      ),
    );
  }

  Widget _formUI() {
    return Column(
        children: [
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your First Name.';
          }
          return null;
        },
        decoration: const InputDecoration(
          labelText: 'First Name',
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
            return 'Please enter your Last Name.';
          }
          return null;
        },
        decoration: const InputDecoration(
          labelText: 'Last Name',
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
          } else if (int.parse(value) < 18) {
            return 'Age has to be over 18.';
          }
          return null;
        },
        decoration: const InputDecoration(
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your Bio.';
          }
          return null;
        },
        keyboardType: TextInputType.multiline,
        minLines: 4,
        maxLines: 8,
        decoration: const InputDecoration(
          labelText: 'About you',
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
                await ImageUtils.showImageSourceDialog(context, maxImages: 1);

            // upload image to Firebase Storage
            if (selectedImage != null) {
              _isImageUploading = true;
              final imageUrl = await ImageUtils.uploadImageToFirebase(
                  selectedImage[0], storageUrl, ImageType.owner);

              if (mounted) {
                setState(() {
                  _profilePic = imageUrl;
                  _isImageUploading = false;
                });
              }
            }
          },
          icon: _profilePic == null || _profilePic!.isEmpty
              ? const Icon(Icons.add_a_photo)
              : CircleAvatar(
                  backgroundImage: _profilePic!.startsWith('http')
                      ? NetworkImage(_profilePic!) as ImageProvider<Object>?
                      : FileImage(File(_profilePic!)) as ImageProvider<Object>?,
                  radius: 30,
                  child: _profilePic!.isEmpty || _profilePic == null
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.check, color: Colors.white),
                ),
        )
      ],
    );
  }
}
