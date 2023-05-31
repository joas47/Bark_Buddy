import 'package:cloud_firestore/cloud_firestore.dart';
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

  final List<String> _genderOptions = ['Female', 'Male'];
  final List<String> _activityOptions = ['Low', 'Medium', 'High'];
  final List<String> _sizeOptions = ['Small', 'Medium', 'Large'];

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  String? _dogId;

  @override
  void initState() {
    super.initState();
    DatabaseHandler.getDogId(FirebaseAuth.instance.currentUser?.uid).listen((dogId) {
      setState(() {
        _dogId = dogId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final dummyStream = FirebaseFirestore.instance
        .collection('Dogs')
        .doc(_dogId ?? 'dummy')
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Dog profile'),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot>(
            stream: dummyStream,
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

              final List<dynamic>? profilePicUrlsDynamic =
              dogData.get('pictureUrls') as List<dynamic>?;
              final List<String>? profilePicUrls =
              profilePicUrlsDynamic?.map((item) => item as String).toList();
              _profilePicUrls = profilePicUrls!;

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
                          child: _formUI(name, breed, age, bio),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Gender',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: _genderOptions
                                      .map((option) => Row(
                                    children: [Transform.scale(
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
                                      Text(option),
                                      const SizedBox(width: 10.0),
                                    ],
                                  ))
                                      .toList(),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Castrated?',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Transform.scale(
                                  scale: 1.3,
                                  child: Checkbox(
                                    value: _isCastrated,
                                    onChanged: (value) {
                                      setState(() {
                                        _isCastrated = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Activity level',
                              style: TextStyle(fontSize: 18),
                            ),

                            IconButton(
                              icon: const Icon(Icons.help_outline),
                              onPressed: () {
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
                              Transform.scale(
                                scale: 1.4,
                                child: Radio(
                                  value: option,
                                  groupValue: _activity,
                                  onChanged: (value) {
                                    setState(() {
                                      _activity = value.toString();
                                    });
                                  },
                                ),
                              ),
                              Text(option),
                              const SizedBox(width: 16.0),
                            ],
                          ))
                              .toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Size',
                              style: TextStyle(fontSize: 18),
                            ),

                            IconButton(
                              icon: const Icon(Icons.help_outline),
                              onPressed: () {
                                _showSizeInfoSheet();
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _sizeOptions
                              .map((option) => Row(
                            children: [Transform.scale(
                              scale: 1.4,
                              child: Radio(
                                value: option,
                                groupValue: _size,
                                onChanged: (value) {
                                  setState(() {
                                    _size = value.toString();
                                  });
                                },
                              ),
                            ),

                              Text(option),
                              const SizedBox(width: 16.0),
                            ],
                          ))
                              .toList(),
                        ),
                        SizedBox(
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
                        Builder(builder: (BuildContext context) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 40,
                                ),
                              ),
                              onPressed: () {
                                if (_isImageUploading) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please wait until the image is uploaded.'),
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
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('You must fill out all the fields before continuing.'),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Save profile',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
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
              Text('Size info', style: Theme.of(context).textTheme.titleLarge),
              Text('Small dog:', style: Theme.of(context).textTheme.bodyLarge),
              Text('Up to 10 kg'),
              Text('Medium dog:', style: Theme.of(context).textTheme.bodyLarge),
              Text('Between 10 - 25 kg'),
              Text('Large dog:', style: Theme.of(context).textTheme.bodyLarge),
              Text('More than 25 kg'),
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
              Text('Activity info', style: Theme.of(context).textTheme.titleLarge),
              Text('Low activity level:',
                  style: Theme.of(context).textTheme.bodyLarge),
              const Text('For dogs who prefer shorter walks.'),
              Text('Moderate activity level:',
                  style: Theme.of(context).textTheme.bodyLarge),
              const Text('For dogs who need a moderate amount of \n exercise and'
                  'will be happy with a 1-2 hour walk.'),
              Text('High activity level: ',
                  style: Theme.of(context).textTheme.bodyLarge),
              const Text('For dogs who require a large amount of exercise. \n '
                  'For example longer walks or activities such as \n running or swimming.'),
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
          labelText: 'Name',
          labelStyle: TextStyle(fontSize: 18),
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
          labelStyle: TextStyle(fontSize: 18),
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
          labelStyle: TextStyle(fontSize: 18),
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

            if (selectedImages != null && selectedImages.isNotEmpty) {
              setState(() {
                _isImageUploading = true;
              });

              for (final selectedImage in selectedImages) {
                final imageUrl = await ImageUtils.uploadImageToFirebase(
                    selectedImage, storageUrl, ImageType.dog);

                if (mounted) {
                  setState(() {
                    _updatedProfilePicUrls.add(imageUrl!);
                  });
                }
              }

              setState(() {
                _isImageUploading = false;
              });
            }
          },
          icon: _profilePicUrls.isEmpty
              ? const Icon(Icons.add_a_photo)
              : CircleAvatar(
                  backgroundImage: _profilePicUrls[0].startsWith('http')
                      ? NetworkImage(_profilePicUrls[0])
                      : FileImage(File(_profilePicUrls[0]))
                          as ImageProvider<Object>?,
                  radius: 30,
                  child: _isImageUploading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.check, color: Colors.white),
                ),

        )
      ],
    );
  }
}
