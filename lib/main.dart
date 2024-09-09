import 'package:euro_docs/home/show_files.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Authentication/signin_screen.dart';
import 'firebase_options.dart';
import 'home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Danfoss',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Lexend'),
          bodyMedium: TextStyle(fontFamily: 'Lexend'),
          bodySmall: TextStyle(fontFamily: 'Lexend'),
          displayLarge: TextStyle(fontFamily: 'Lexend'),
          displayMedium: TextStyle(fontFamily: 'Lexend'),
          displaySmall: TextStyle(fontFamily: 'Lexend'),
          titleSmall: TextStyle(fontFamily: 'Lexend'),
          titleMedium: TextStyle(fontFamily: 'Lexend'),
          titleLarge: TextStyle(fontFamily: 'Lexend'),
          labelLarge: TextStyle(fontFamily: 'Lexend'),
          labelMedium: TextStyle(fontFamily: 'Lexend'),
          labelSmall: TextStyle(fontFamily: 'Lexend'),
          headlineLarge: TextStyle(fontFamily: 'Lexend'),
          headlineMedium: TextStyle(fontFamily: 'Lexend'),
          headlineSmall: TextStyle(fontFamily: 'Lexend'),
        ),
        useMaterial3: false,
      ),
      home: const AuthWrapper(), // Update this to use AuthWrapper
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const SignInScreen();
          } else {
            // Pass the user's email to HomePage
            return const ViewFilesScreen();
          }
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
