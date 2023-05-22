import 'package:cross_platform_test/home_page.dart';
import 'package:flutter/material.dart';
import 'image_handler.dart';
import 'dart:io';

import 'database_handler.dart';

class RegisterDogPage extends StatefulWidget {
  const RegisterDogPage({super.key});

  @override
  _RegisterDogPageState createState() => _RegisterDogPageState();
}

class _RegisterDogPageState extends State<RegisterDogPage> {
  String _name = '';
  String _breed = '';
  String _gender = '';
  String _activity = '';
  int _age = 0;
  String _size = '';
  bool _isCastrated = false;
  String _bio = '';

  // _isImageUploading is used to prevent the user from pressing
  // the save button before the image is uploaded and resized
  bool _isImageUploading = false;

  //String? _profilePic = '';
  List<String> _pictureUrls = [];

  //String? _profilePic = '';

  final List<String> _genderOptions = ['Female', 'Male'];
  final List<String> _activityOptions = ['Low', 'Medium', 'High'];
  final List<String> _sizeOptions = ['Small', 'Medium', 'Large'];

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Dog Profile'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: make this a form for the checks, like in the owner profile page.
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(fontSize: 18),
              ),
              keyboardType: TextInputType.name,
              onChanged: (value) {
                _name = value;
              },
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _breedController,
              decoration: const InputDecoration(
                labelText: 'Breed',
                labelStyle: TextStyle(fontSize: 18),
              ),
              keyboardType: TextInputType.text,
              onChanged: (value) {
                _breed = value;
              },
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                labelStyle: TextStyle(fontSize: 18),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _age = int.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 16.0),

            Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Gender',
                          style: TextStyle(fontSize: 18),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                                      Text(
                                        option,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      //const SizedBox(width: 16.0),
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
                      "Activity Level",
                      style: TextStyle(fontSize: 18),
                    ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                              Text(
                                option,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ))
                      .toList(),
                ),
                //const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Size",
                      style: TextStyle(fontSize: 18),
                    ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _sizeOptions
                      .map((option) => Row(
                            children: [
                              Transform.scale(
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

                              Text(
                                option,
                                style: const TextStyle(fontSize: 16),
                              ),
                              //const SizedBox(width: 16.0),
                            ],
                          ))
                      .toList(),
                ),
              ],
            ),

            SizedBox(
              //height: 500.0,
              //width: 300.0,
              child: TextField(
                controller: _bioController,
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
                  _bio = value;
                },
              ),
            ),
            _buildImageUploadButton(),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 40), // Adjust the padding as needed
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
                // TODO: give specific error messages to the user for each check
                if (_name.isNotEmpty &&
                    _breed.isNotEmpty &&
                    !_age.isNaN &&
                    _gender.isNotEmpty &&
                    _activity.isNotEmpty &&
                    _size.isNotEmpty &&
                    _bio.isNotEmpty &&
                    _pictureUrls.isNotEmpty) {
                  DatabaseHandler.addDogToDatabase(_name, _breed, _age, _gender,
                      _isCastrated, _activity, _size, _bio, _pictureUrls);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill out all the fields'),
                    ),
                  );
                }
              },
              child: const Text(
                'Register',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      )),
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
              const Text('Up to 10 kg'),
              Text('Medium dog:', style: Theme.of(context).textTheme.bodyLarge),
              const Text('Between 10 - 25 kg'),
              Text('Large dog:', style: Theme.of(context).textTheme.bodyLarge),
              const Text('More than 25 kg'),
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
              const Text('For dogs who prefer shorter walks'),
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
            // If there are already 5 images, remove them before adding the new ones
            if (_pictureUrls.length >= 5) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('You have reached the maximum number of photos! Adding more will replace the existing ones.'),
                ),
              );
              _pictureUrls.clear();
            }

            // Always allow them to select images, but limit the selection to the remaining quota
            int remainingImagesCount = 5 - _pictureUrls.length;
            final selectedImages = await ImageUtils.showImageSourceDialog(context, maxImages: remainingImagesCount);

            // upload image to Firebase Storage
            if (selectedImages != null && selectedImages.isNotEmpty) {
              setState(() {
                _isImageUploading = true;
              });

              for (final selectedImage in selectedImages) {
                final imageUrl = await ImageUtils.uploadImageToFirebase(
                    selectedImage, storageUrl, ImageType.dog);

                if (mounted) {
                  setState(() {
                    _pictureUrls.add(imageUrl!);
                  });
                }
              }

              setState(() {
                _isImageUploading = false;
              });
            }
          },

          icon: _isImageUploading
              ? const CircularProgressIndicator()
              : _pictureUrls.isEmpty
                  ? const Icon(Icons.add_a_photo)
                  : CircleAvatar(
                      backgroundImage: _pictureUrls[0].startsWith('http')
                          ? NetworkImage(_pictureUrls[0])
                          : FileImage(File(_pictureUrls[0]))
                              as ImageProvider<Object>?,
                      radius: 30,
                      child: _pictureUrls.isEmpty
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.check, color: Colors.white),
                    ),
/*          icon: _pictureUrls.isEmpty
              ? const Icon(Icons.add_a_photo)
              : CircleAvatar(
            backgroundImage: _pictureUrls[0].startsWith('http')
                ? NetworkImage(_pictureUrls[0])
                : FileImage(File(_pictureUrls[0])) as ImageProvider<Object>?,
            radius: 30,
            child: _isImageUploading
                ? const CircularProgressIndicator()
                : const Icon(Icons.check, color: Colors.white),
          ),*/
/*          icon: _pictureUrls.isEmpty
              ?const Icon(Icons.add_a_photo)
              : CircleAvatar(
            backgroundImage: _pictureUrls[0].startsWith('http')
                ? NetworkImage(_pictureUrls[0])
                : FileImage(File(_pictureUrls[0])) as ImageProvider<Object>?,
            radius: 30,
            child: _pictureUrls.isEmpty
                ? const CircularProgressIndicator()
                : const Icon(Icons.check, color: Colors.white),
          ),*/
        )
      ],
    );
  }
  //String? getProfilePic() {
  //  return _profilePic;
  //}
}
