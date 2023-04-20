import 'package:cross_platform_test/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'file_selector_handler.dart';

class MakeProfilePage extends StatefulWidget {
  const MakeProfilePage({super.key});

  @override
  State<MakeProfilePage> createState() => _MakeProfilePageState();
}

class _MakeProfilePageState extends State<MakeProfilePage> {
  String _name = '';
  int _age = 0;
  String _gender = '';
  XFile? _profilePic;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 64.0),
              const Text(
                'Tell us more about yourself!',
                style: TextStyle(fontSize: 24.0),
              ),
              const SizedBox(height: 16.0),
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
              const SizedBox(height: 16.0),
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
              const SizedBox(height: 16.0),
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
                    if (_name.isNotEmpty &&
                        !_age.isNegative &&
                        !_age.isNaN &&
                        _gender.isNotEmpty &&
                        _profilePic != null) {
                      // TODO: save owner to database
                      //Owner owner = Owner(_name, _age, _gender);
                      DatabaseHandler.addUserToDatabase(
                          _name, _age, _gender, _profilePic!);
                      Navigator.pushNamed(context, '/register-dog');
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

  Widget _buildProfilePictureUploadButton() {
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
            // TODO: handle the selected image
            _profilePic = await FileSelectorHandler.selectImage();
          },
          icon: const Icon(Icons.upload),
        ),
      ],
    );
  }
}
