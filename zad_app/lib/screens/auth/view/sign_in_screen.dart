import 'package:flutter/material.dart';
import 'package:zad_app/models/user_model.dart';

import '../../../Controller/auth_controller.dart';
import 'sign_up_screen.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _authController = AuthController();
  late String email, password;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 12, 190),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ZAD',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/6.png',
                height: 150,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Card(
                color: const Color.fromARGB(255, 61, 7, 156),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          email = value;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter Your Email',
                          hintStyle: TextStyle(
                              color: Color.fromARGB(175, 255, 255, 255)),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                          prefixIconColor: Colors.white,
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        obscureText: true,
                        onChanged: (value) {
                          password = value;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter Password',
                          hintStyle: TextStyle(
                              color: Color.fromARGB(175, 255, 255, 255)),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          prefixIconColor: Colors.white,
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (email.isEmpty || password.isEmpty) {
                            _showErrorDialog(
                                'Email and password must not be empty.');
                            return;
                          }
                          try {
                            User? user =
                                (await _authController.login(email, password)) as User?;
                            if (user != null) {
                              if (user.role == 'admin') {
                                Navigator.pushReplacementNamed(
                                    context, '/admin_home');
                              } else {
                                Navigator.pushReplacementNamed(
                                    context, '/customer_home');
                              }
                            } else {
                              _showErrorDialog(
                                  'Login failed. Please check your credentials.');
                            }
                          } catch (error) {
                            if (error.toString().contains('wrong-password') ||
                                error.toString().contains('user-not-found')) {
                              _showErrorDialog(
                                  'Please enter the correct password or email.');
                            } else {
                              _showErrorDialog(
                                  'An error occurred: ${error.toString()}');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 14, 24, 111), // Light green color
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text(
                          'Log in',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterView()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 14, 24, 111), // Light green color
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
