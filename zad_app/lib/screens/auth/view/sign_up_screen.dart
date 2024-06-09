import 'package:flutter/material.dart';
import 'package:zad_app/models/user_model.dart';

import '../../../Controller/auth_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final AuthController _authController = AuthController();
  late String email, password, name;
  final _formKey = GlobalKey<FormState>();
  bool _passwordValid = false;
  String _passwordErrorMessage = '';
  double _passwordStrength = 0;
  IconData _passwordStrengthIcon = Icons.clear;
  bool _isPasswordFieldTouched = false;

  void _validatePassword(String value) {
    setState(() {
      _isPasswordFieldTouched = true;
      _passwordValid = true;
      _passwordErrorMessage = '';
      _passwordStrength = 0;
      _passwordStrengthIcon = Icons.clear;

      if (value.length < 8) {
        _passwordValid = false;
        _passwordErrorMessage = 'Password must be at least 8 characters long';
      } else {
        _passwordStrength += 0.25;
      }
      if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
        _passwordValid = false;
        _passwordErrorMessage += '\nPassword must contain an uppercase letter';
      } else {
        _passwordStrength += 0.25;
      }
      if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(value)) {
        _passwordValid = false;
        _passwordErrorMessage += '\nPassword must contain a special character';
      } else {
        _passwordStrength += 0.25;
      }
      if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
        _passwordValid = false;
        _passwordErrorMessage += '\nPassword must contain a number';
      } else {
        _passwordStrength += 0.25;
      }

      if (_passwordStrength == 1) {
        _passwordStrengthIcon = Icons.check_circle;
      } else if (_passwordStrength >= 0.75) {
        _passwordStrengthIcon = Icons.check;
      } else if (_passwordStrength >= 0.5) {
        _passwordStrengthIcon = Icons.remove_circle;
      } else {
        _passwordStrengthIcon = Icons.clear;
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ZAD',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
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
                        TextFormField(
                          onChanged: (value) {
                            email = value;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter Email',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(175, 255, 255, 255)),
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                            prefixIconColor: Colors.white,
                          ),
                          style:
                              const TextStyle(color: Colors.white), // Add this line
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          onChanged: (value) {
                            name = value;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter Your Name',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(175, 255, 255, 255)),
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                            prefixIconColor: Colors.white,
                          ),
                          style:
                              const TextStyle(color: Colors.white), // Add this line
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          obscureText: true,
                          onChanged: (value) {
                            password = value;
                            _validatePassword(value);
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter Password',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(175, 255, 255, 255)),
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                            prefixIconColor: Colors.white,
                          ),
                          style:
                              const TextStyle(color: Colors.white), 
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (!_passwordValid) {
                              return _passwordErrorMessage;
                            }
                            return null;
                          },
                        ),
                        if (_isPasswordFieldTouched) ...[
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: _passwordStrength,
                            backgroundColor: Colors.red,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _passwordStrength >= 1
                                  ? Colors.green
                                  : Colors.yellow,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Icon(
                            _passwordStrengthIcon,
                            color: _passwordStrength >= 1
                                ? Colors.green
                                : (_passwordStrength >= 0.75
                                    ? Colors.yellow
                                    : Colors.red),
                          ),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }
                            try {
                              User? newUser = (await _authController.register(
                                  email, password, name)) as User?;
                              if (newUser != null) {
                                Navigator.pushReplacementNamed(
                                    context, '/customer_home');
                              } else {
                                _showErrorDialog(
                                    'Registration failed. Please try again.');
                              }
                            } catch (error) {
                              _showErrorDialog(
                                  'An error occurred: ${error.toString()}');
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
                            'Create Account',
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
      ),
    );
  }
}
