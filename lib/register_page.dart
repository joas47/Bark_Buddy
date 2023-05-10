import 'package:cross_platform_test/make_owner_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  String _email = '';
  String _password = '';
  String _adult = '';

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  final List<String> _ageOptions = ['Yes', 'No'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create your account!',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: _formUI(),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_validateInputs()) {
                      if (_adult == 'Yes') {
                        final createAccSuccessful = await _createUser();
                        if (createAccSuccessful) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const MakeOwnerProfilePage()));
                        }
                      }
                    }
                  },
                  child: const Text('Register'),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Already have an account? Login here.'),
                ),
              ],
            ),
          ),
        ));
  }

  Future<bool> _createUser() async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      return credential.user != null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The password provided is too weak.'),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The account already exists for that email.'),
          ),
        );
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The email address is not valid.'),
          ),
        );
      }
    }
    return false;
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

  Widget _formUI() {
    return Column(children: [
      const SizedBox(height: 32.0),

      const SizedBox(height: 16.0),
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email.';
          }
          return null;
        },
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          _email = value;
        },
      ),
      const SizedBox(height: 16.0),
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password.';
          }
          return null;
        },
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          _password = value;
        },
      ),
      const SizedBox(height: 16.0),

      const SizedBox(height: 16.0),
      const Text('Are you over 18?'),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _ageOptions
            .map((option) => Row(
          children: [
            Radio(
              value: option,
              groupValue: _adult,
              onChanged: (value) {
                setState(() {
                  _adult = value.toString();
                });
              },
            ),
            Text(option),
            const SizedBox(width: 10.0),
          ],
        ))
            .toList(),
      ),
      if (_adult == 'No') // check if the user is under 18
        const Text(
          'Sorry, you must be 18 years of age or older to register.',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      const SizedBox(height: 16.0),
    ]);
  }
}
