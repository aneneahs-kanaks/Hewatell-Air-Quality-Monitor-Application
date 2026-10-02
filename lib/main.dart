
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added to watch login state
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart'; // Imported our dashboard file!

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
      title: 'Hewatell Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // ─── THE STATE LISTENER HOOK ───
      // StreamBuilder watches Firebase Auth in the background automatically
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // Listens for login/logout events
        builder: (context, snapshot) {
          // If the app is still talking to Firebase on boot, show a loading wheel
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.teal),
              ),
            );
          }

          // If snapshot has user data, it means they are logged in!
          if (snapshot.hasData) {
            return const DashboardScreen(); // Auto-navigate straight to Dashboard
          }

          // If there is no user data, they are logged out. Show the onboarding form.
          return const AuthScreen();
        },
      ),
    );
  }
}
