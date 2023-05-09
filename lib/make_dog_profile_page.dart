import 'package:cross_platform_test/home_page.dart';
import 'package:cross_platform_test/view_dog_profile_page.dart';
import 'package:flutter/material.dart';
import 'image_handler.dart';

import 'package:cross_platform_test/file_selector_handler.dart';

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

  // TODO: make this a file
  String? _profilePic = '';

  final List<String> _genderOptions = ['Tik', 'Hane'];
  final List<String> _activityOptions = ['Låg', 'Medel', 'Hög'];
  final List<String> _sizeOptions = ['Liten', 'Medel', 'Stor'];

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrera din hund'),
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                    //changed below from "//int.tryParse(value) ?? 0;" to "int.parse(value);"
                    _age = int.tryParse(value) ?? 0;

                  },
                ),
                const SizedBox(height: 10.0),
                const Text("Kön"),
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
                  title: const Text('Kastrerad'),
                  value: _isCastrated,
                  onChanged: (value) {
                    setState(() {
                      _isCastrated = value!;
                    });
                  },
                ),
                const Text("Aktivitetsnivå"),
                // TODO: add a tooltip
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
                  children: const [
                    Text("Storlek"),
                    // TODO: add a tooltip
                    Icon(
                      Icons.info,
                      color: Colors.blue,
                    )
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
                    decoration: InputDecoration(
                      hintText: 'Om din hund',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
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
                    // TODO: add more fields to the dog // this was done but i kept the comment anyway
                    // TODO: uncomment this, only for testing
                    if (_name.isNotEmpty &&
                    _breed.isNotEmpty &&
                    !_age.isNaN &&
                    _gender.isNotEmpty &&
                    _isCastrated != null &&
                    _activity.isNotEmpty &&
                    _size.isNotEmpty &&
                    _bio.isNotEmpty

                    ) {
                  //TODO: handle all fields //this was done but i kept the comment anyway
                  // TODO: uncomment this

                  DatabaseHandler.addDogToDatabase(_name, _breed, _age, _gender, _isCastrated, _activity, _size, _bio, _profilePic);

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
                  child: const Text('Registrera'),
                ),
              ],
            ),
          )),
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
            final selectedImage = await ImageUtils.showImageSourceDialog(context);

            // upload image to Firebase Storage
            if (selectedImage != null) {
              final imageUrl = await ImageUtils.uploadImageToFirebase(selectedImage, storageUrl);
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
