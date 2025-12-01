import 'package:flutter/material.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/loaderAnimation.gif",
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
