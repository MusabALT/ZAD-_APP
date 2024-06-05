import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/auth/view/sign_in_screen.dart';
import 'screens/auth/view/sign_up_screen.dart';
import 'screens/home/admin/admin_screen.dart';
import 'screens/home/views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //must put this
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/customer_home': (context) => const HomeScreen(),
        '/admin_home': (context) => const AdminScreen(),
        '/login': (context) => const LoginView()
      },
    );
  }
}
