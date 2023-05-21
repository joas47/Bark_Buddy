import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_platform_test/make_dog_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_handler.dart';
import 'image_handler.dart';
import 'dart:io';

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
  String _size = '';

  bool _isCastrated = false;
  bool _initCastraded = false;
  String _activity = '';
  String? _updatedName;
  String? _updatedBreed;
  int? _updatedAge;
  String? _updatedBio;

  // _isImageUploading is used to prevent the user from pressing
  // the save button before the image is uploaded and resized
  bool _isImageUploading = false;

  List<String> _profilePicUrls = [];
  List<String> _updatedProfilePicUrls = [];

  final List<String> _genderOptions = ['Female', 'Male']; // Micke
  final List<String> _activityOptions = ['Low', 'Medium', 'High'];
  final List<String> _sizeOptions = ['Small', 'Medium', 'Large'];

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  String? _dogId;

  @override
  void initState() {
    super.initState();
    DatabaseHandler.getDogId3(FirebaseAuth.instance.currentUser?.uid).listen((dogId) {
      setState(() {
        _dogId = dogId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //DatabaseHandler.getOwnerProfileData();

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
              if (_activity.isEmpty) {
                _activity = activityLevel;
              }
              final age = dogData.get('Age');
              _age = age;
              final bio = dogData.get('Biography') as String?;
              _bio = bio!;
              final breed = dogData.get('Breed');
              _breed = breed;
              final gender = dogData.get('Gender');
              if (_gender.isEmpty) {
                _gender = gender;
              }

              final isCastrated = dogData.get('Is castrated');
              if (_initCastraded == false) {
                _isCastrated = isCastrated;
                _initCastraded = true;
              }
              final name = dogData.get('Name');
              _name = name;
              final size = dogData.get('Size');
              if (_size.isEmpty) {
                _size = size;
              }


              final List<dynamic>? profilePicUrlsDynamic = dogData.get('pictureUrls') as List<dynamic>?;
              final List<String>? profilePicUrls = profilePicUrlsDynamic?.map((item) => item as String).toList();
              _profilePicUrls = profilePicUrls ?? [];


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
                    const Text("Gender"),
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
                                  const SizedBox(width: 10.0),
                                ],
                              ))
                          .toList(),
                    ),
                    CheckboxListTile(
                      // TODO: shrink size
                      title: const Text('Castrated'),
                      value: _isCastrated,
                      onChanged: (value) {
                        setState(() {
                          _isCastrated = value!;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Activity Level"),
                        // TODO: add a tooltip // this is done but i decided to keep the comment anyway
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () {
                            // Call the callback function to show the info sheet.
                            _showActivityLevelInfoSheet();
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _activityOptions
                          .map((option) => Row(
                                children: [
                                  Radio(
                                    value: option,
                                    groupValue: _activity,
                                    onChanged: (value) {
                                      setState(() {
                                        _activity = value.toString();
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Size"),
                        // TODO: add a tooltip // this is done but i decided to keep the comment anyway
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () {
                            // Call the callback function to show the info sheet.
                            _showSizeInfoSheet();
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _sizeOptions
                          .map((option) => Row(
                                children: [
                                  Radio(
                                    value: option,
                                    groupValue: _size,
                                    onChanged: (value) {
                                      setState(() {
                                        _size = value.toString();
                                      });
                                    },
                                  ),
                                  Text(option),
                                  const SizedBox(width: 16.0),
                                ],
                              ))
                          .toList(),
                    ),
                    SizedBox(
                      //height: 500.0,
                      //width: 300.0,
                      child: TextField(
                        controller: TextEditingController(text: _bio),
                        keyboardType: TextInputType.multiline,
                        minLines: 4,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'About your dog',
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                        onChanged: (value) {
                          _updatedBio = value;
                        },
                      ),
                    ),

                    _buildImageUploadButton(),
                    const SizedBox(height: 16.0),
                    // TODO: move this Text so it's next to the radio buttons instead of above.
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
                              _profilePicUrls != null) {
                            if (_updatedBio != null) {
                              _bio = _updatedBio!;
                            }
                            if (_updatedName != null) {
                              _name = _updatedName!;
                            }
                            if (_updatedBreed != null) {
                              _breed = _updatedBreed!;
                            }
                            if (_updatedAge != null) {
                              _age = _updatedAge!;
                            }
                            if (_updatedProfilePicUrls != null) {
                              _profilePicUrls = _updatedProfilePicUrls!;
                            }
                            DatabaseHandler.updateDog(
                                _name,
                                _breed,
                                _gender,
                                _age,
                                _bio,
                                _profilePicUrls,
                                _size,
                                _isCastrated,
                                _activity,
                                _dogId!);
                            Navigator.pop(context); //--------------------------
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

  void _showSizeInfoSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Info', style: Theme.of(context).textTheme.titleLarge),
              Text('Small dog', style: Theme.of(context).textTheme.bodyLarge),
              Text('up to 10kg'),
              Text('Medium dog', style: Theme.of(context).textTheme.bodyLarge),
              Text('10 - 25kg'),
              Text('Large dog', style: Theme.of(context).textTheme.bodyLarge),
              Text('More than 25kg'),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showActivityLevelInfoSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Info', style: Theme.of(context).textTheme.titleLarge),
              Text('Low activity level:',
                  style: Theme.of(context).textTheme.bodyLarge),
              Text('For dogs who prefer shorter walks'),
              Text('Moderate activity level:',
                  style: Theme.of(context).textTheme.bodyLarge),
              Text('For dogs who need a moderate amount of exercise and '
                  'will be happy with a 1-2 hour walk. '),
              Text('High activity level: ',
                  style: Theme.of(context).textTheme.bodyLarge),
              Text('For dogs who require a large amount of exercise. '
                  'For example longer walks or activities such as running or swimming.'),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _formUI(String name, String breed, int age, String? bio) {
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
          _updatedName = value;
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
          _updatedBreed = value;
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
          _updatedAge = int.tryParse(value) ?? -1;
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
          'Upload profile picture',
          style: TextStyle(fontSize: 18.0),
        ),
        const SizedBox(width: 16.0),
        IconButton(
          onPressed: () async {
            // show dialog with options to choose image or take a new one
            final selectedImages = await ImageUtils.showImageSourceDialog(context, maxImages: 5);

            // upload image to Firebase Storage
            /*if (selectedImage != null) {
              final imageUrl = await ImageUtils.uploadImageToFirebase(
                  selectedImage, storageUrl);
              setState(() {
                _updatedProfilePic = imageUrl;
              });
            }*/
            if (selectedImages != null && selectedImages.isNotEmpty){
              _isImageUploading = true;
              for (final selectedImage in selectedImages) {
                final imageUrl = await ImageUtils.uploadImageToFirebase(
                    selectedImage, storageUrl, ImageType.dog);

                if (mounted) {
                  setState(() {
                    _updatedProfilePicUrls.add(imageUrl!);
                  });
                }
              }
            }
            _isImageUploading = false;
          },
          icon: _profilePicUrls.isEmpty
              ?const Icon(Icons.add_a_photo)
              :CircleAvatar(
                backgroundImage: _profilePicUrls[0].startsWith('http')
                ? NetworkImage(_profilePicUrls[0])
                : FileImage(File(_profilePicUrls[0])) as ImageProvider<Object>?,
                radius: 30,
                child: _profilePicUrls.isEmpty
                ? const CircularProgressIndicator()
                : const Icon(Icons.check, color: Colors.white),
              ),

          /*icon: _profilePic == null || _profilePic!.isEmpty
              ? const Icon(Icons.add_a_photo)
              : CircleAvatar(
                backgroundImage: _profilePic!.startsWith('http')
                ? NetworkImage(_profilePic!) as ImageProvider<Object>?
                : FileImage(File(_profilePic!)) as ImageProvider<Object>?,
                radius: 30,
                child: _profilePic!.isEmpty || _profilePic == null
                ? const CircularProgressIndicator()
                : const Icon(Icons.check, color: Colors.white),
              ),*/
        )
      ],
    );
  }
}
