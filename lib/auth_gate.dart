import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_learning_app/dashboard_screen.dart';
import 'package:my_learning_app/main.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to the Firebase auth state
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print(snapshot);
        // Show a loader while checking
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If the snapshot HAS DATA, the user is logged in
        if (snapshot.hasData) {
          // --- User is logged in, show Dashboard ---
          return const DashboardScreen();
        }

        // If snapshot has NO DATA, user is logged out
        // --- User is logged out, show HomePage ---
        return const HomePage();
      },
    );
  }
}
