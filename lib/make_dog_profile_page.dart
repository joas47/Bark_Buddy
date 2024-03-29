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

  String? _profilePic = '';

  final List<String> _genderOptions = ['She', 'He'];
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
                // TODO: make this a form for the checks
            TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
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
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {

                    _age = int.tryParse(value) ?? 0;

                  },
                ),
                const SizedBox(height: 10.0),
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
                  children:  [
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
                  children:  [
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
                  onPressed: () {
                    if (_name.isNotEmpty &&
                    _breed.isNotEmpty &&
                    !_age.isNaN &&
                    _gender.isNotEmpty &&
                    _activity.isNotEmpty &&
                    _size.isNotEmpty &&
                    _bio.isNotEmpty) {
                  DatabaseHandler.addDogToDatabase(_name, _breed, _age, _gender,
                      _isCastrated, _activity, _size, _bio, _profilePic);
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
                  child: const Text('Register'),
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
              Text('Info', style: Theme.of(context).textTheme.titleLarge),

              Text('Small dog', style: Theme.of(context).textTheme.bodyLarge),
              Text('up to 10kg'),

              Text('Medium dog', style: Theme.of(context).textTheme.bodyLarge),
              Text('10 - 25kg'),

              Text('Large dog',style: Theme.of(context).textTheme.bodyLarge),
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
              Text('Low activity level:', style: Theme.of(context).textTheme.bodyLarge),
              Text('For dogs who prefer shorter walks'),

              Text('Moderate activity level:', style: Theme.of(context).textTheme.bodyLarge),
              Text('For dogs who need a moderate amount of exercise and '
                  'will be happy with a 1-2 hour walk. '),

              Text('High activity level: ', style: Theme.of(context).textTheme.bodyLarge),
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
  String? getProfilePic() {
    return _profilePic;
  }
}
