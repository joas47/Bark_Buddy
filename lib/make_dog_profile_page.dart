import 'package:flutter/material.dart';

import 'package:cross_platform_test/file_selector_handler.dart';

import 'database_handler.dart';

/*
Namn
Kön (kastrerad eller ej)
Ålder
Ras
Aktivitetsnivå
Storlek
Om hunden (fritext)
Bild
Spara
 */

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

  bool _isChecked = false;

  // TODO: make this a file
  String _profilePic = '';

  final List<String> _genderOptions = ['Tik', 'Hane'];
  final List<String> _activityOptions = ['Låg', 'Medel', 'Hög'];
  final List<String> _sizeOptions = ['Liten', 'Medel', 'Stor'];

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
            Text("Kön"),
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
            CheckboxListTile(
              title: const Text('Kastrerad'),
              value: _isChecked,
              onChanged: (value) {
                setState(() {
                  _isChecked = value!;
                });
              },
            ),
            const Text("Aktivitetsnivå"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _activityOptions
                  .map((option) =>
                  Row(
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
                  .map((option) =>
                  Row(
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
            const SizedBox(
              //height: 500.0,
              width: 300.0,
              child: TextField(
                keyboardType: TextInputType.multiline,
                minLines: 4,
                maxLines: 5,
                decoration: InputDecoration(
                  // TODO: get this information from the database
                  hintText: 'Om din hund',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
            _buildImageUploadButton(),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // TODO: get the owner email from the database or from the login page
                // TODO: add more fields to the dog
                if (_name.isNotEmpty &&
                    _breed.isNotEmpty &&
                    !_age.isNaN &&
                    _gender.isNotEmpty) {
                  // TODO: reference the current user to add the dog to the database
                  DatabaseHandler.addDogToDatabase(
                      _name, _breed, "john@doe.com", _gender);
                  Navigator.pushNamed(context, '/find-match');
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
