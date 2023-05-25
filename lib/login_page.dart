import 'package:cross_platform_test/database_handler.dart';
import 'package:cross_platform_test/home_page.dart';
import 'package:cross_platform_test/make_dog_profile_page.dart';
import 'package:cross_platform_test/make_owner_profile_page.dart';
import 'package:cross_platform_test/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = '';
  String _password = '';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 64.0),
              Image.asset(
                'assets/images/logo.png',
                height: 180,
                width: 250,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text('Welcome to ', style: TextStyle(
                  //   fontSize: 28.0,
                  //   fontWeight: FontWeight.bold,
                  //   color: Colors.black,
                  // ),),
                  Image.asset('assets/images/barkbuddytext.png',
                    width: 250,
                    height: 100,)
                ],
              ),
              const SizedBox(height: 32.0),
              TextField(
                controller: _emailController,
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
              TextField(
                controller: _passwordController,
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
              ElevatedButton(
                onPressed: () async {
                  if (_email.isNotEmpty && _password.isNotEmpty) {
                    final loginSuccessful = await login();
                    if (loginSuccessful) {
                      if (!await DatabaseHandler.doesCurrentUserHaveProfile()) {
                        //Check if user profile does not exist
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MakeOwnerProfilePage()),
                            (route) => false);
                      } else if (!await DatabaseHandler
                          .doesCurrentUserHaveDogProfile()) {
                        //Check if dog profile does not exist
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterDogPage()),
                            (route) => false);
                      } else {
                        //Go to home page if both profiles exist
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()),
                            (route) => false);
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill out all fields.'),
                      ),
                    );
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()));
                },
                child: const Text('Don\'t have an account? Register here.'),
              ),
            ],
          ),
        )),
      ),
    );
  }

  Future<bool> login() async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      return credential.user != null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found for that email.'),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong password provided for that user.'),
          ),
        );
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email.'),
          ),
        );
      }
    }
    return false;
  }
}
