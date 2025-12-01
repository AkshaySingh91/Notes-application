import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_learning_app/provider/authProvider.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  @override
  Timer? verificationTimer;

  @override
  void initState() {
    super.initState();

    // Auto-check every 20 seconds
    verificationTimer = Timer.periodic(Duration(seconds: 20), (_) {
      Provider.of<MyAuthProvider>(
        context,
        listen: false,
      ).refreshVerificationStatus();
    });
  }

  @override
  void dispose() {
    verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<MyAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Email verification"),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Verify Your Email",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "A verification link has been sent to ${auth.currentUser?.email}. Please tap the verification link and return to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),

              if (auth.isCheckingVerification) CircularProgressIndicator(),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await auth.refreshVerificationStatus();
                },
                child: Text("Check Again"),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser
                      ?.sendEmailVerification();
                },
                child: Text("Resend Email"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
