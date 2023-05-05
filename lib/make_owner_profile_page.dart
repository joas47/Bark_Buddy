import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'file_selector_handler.dart';

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
  XFile? _profilePic;

  final List<String> _genderOptions = ['Man', 'Kvinna', 'Annan'];

  final _fNameController = TextEditingController();
  final _lNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skapa profil'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 64.0),
              const SizedBox(height: 16.0),
              TextField(
                controller: _fNameController,
                decoration: const InputDecoration(
                  labelText: 'Namn',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.name,
                onChanged: (value) {
                  _fName = value;
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                  controller: _lNameController,
                  decoration: const InputDecoration(
                    labelText: 'Efternamn',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.name,
                  onChanged: (value) {
                    _lName = value;
                  }),
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
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Ålder',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _age = int.tryParse(value) ?? -1;
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _bioController,
                keyboardType: TextInputType.multiline,
                minLines: 4,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Om dig',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _bio = value;
                },
              ),
              _buildProfilePictureUploadButton(),
              const SizedBox(height: 16.0),
              Builder(builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    // TODO: divide into multiple checks, give more specific error messages
                    // TODO: remove the true in the if statement, only for testing
                    if (/*_fName.isNotEmpty &&
                        _lName.isNotEmpty &&
                        _gender.isNotEmpty &&
                        !_age.isNegative &&
                        !_age.isNaN &&
                        _bio.isNotEmpty &&
                        _profilePic != null*/
                        true) {
                      // TODO: save owner to database (uncomment the line below)
                      //DatabaseHandler.addUserToDatabase(_fName, _lName, _gender, _age, _bio, _profilePic!);
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
