import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPage extends StatefulWidget {
  const ResetPage({super.key});

  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  String _email = '';
  final _emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void cancelReset() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: cancelReset,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                ElevatedButton(
                  onPressed: () async {
                    if (_email == null || _email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill out email.'),
                        ),
                      );
                    } else {
                      final user = await auth.fetchSignInMethodsForEmail(_email);

                      if (user.isEmpty) {
                        try {
                          // Error for email not found
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No user with such email.'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to fetch user information.'),
                            ),
                          );
                        }
                      } else {
                        // Email exists, initiate password reset
                        try {
                          await auth.sendPasswordResetEmail(email: _email);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Check your email for a link to reset your password.'),
                            ),
                          );
                          Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to send reset email.'),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Reset Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
