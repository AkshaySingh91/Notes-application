import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_learning_app/provider/authProvider.dart';
import 'package:my_learning_app/routes/appRoutes.dart';
import 'package:provider/provider.dart';

class Constants {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    runApp(
      ChangeNotifierProvider(
        create: (context) => MyAuthProvider(),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    runApp(
      Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Something went wrong while initializing the app.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$e',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
    final myAppRoutes = MyAppRoutes(authProvider);

    return MaterialApp.router(
      title: 'Flutter Login UI',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(textTheme: GoogleFonts.interTextTheme()),
      routerConfig: myAppRoutes.router,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/appLogo.png",
                width: 450,
                height: 450,
                fit: BoxFit.cover,
              ),
              Text(
                "You lovely created first flutter application here.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "Personal notes application",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Colors.amber[700],
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    style: TextButton.styleFrom(
                      elevation: 5,
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepOrange[300],
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                    ),
                    child: const Text("Login"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/register');
                    },
                    style: TextButton.styleFrom(
                      elevation: 5,
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepOrange[300],
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                    ),
                    child: const Text("Register"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
