import 'package:flutter/material.dart';

import 'package:cross_platform_test/file_selector_handler.dart';

class RegisterDogPage extends StatefulWidget {
  const RegisterDogPage({super.key});

  @override
  _RegisterDogPageState createState() => _RegisterDogPageState();
}

class _RegisterDogPageState extends State<RegisterDogPage> {
  String _name = '';
  String _breed = '';
  int _age = 0;
  String _gender = '';
  String _profilePic = '';

  final List<String> _genderOptions = ['Male', 'Female'];

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register your dog'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100.0),
            const Text(
              'Enter your dog\'s information',
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
              controller: _breedController,
              decoration: const InputDecoration(
                labelText: 'Breed',
              ),
              keyboardType: TextInputType.text,
              onChanged: (value) {
                _breed = value;
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
            _buildImageUploadButton(),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // TODO: save dog information somewhere
                //Owner owner = Owner()
                //Dog dog = Dog(_name, _age, _breed, owner);
                //print(dog);
                Navigator.pushNamed(context, '/find-match');
              },
              child: const Text('Register'),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildImageUploadButton() {
    return Column(
      children: [
        _profilePic.isEmpty
            ? Container()
            : Container(
                width: 200.0,
                height: 200.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_profilePic),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Upload dog picture',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(width: 16.0),
            IconButton(
              onPressed: () async {
                // TODO: handle image upload
                final selectedImage = await FileSelectorHandler.selectImage();
              },
              icon: const Icon(Icons.upload),
            ),
          ],
        ),
      ],
    );
  }
}
