import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_learning_app/main.dart';
import 'package:my_learning_app/views/noteview.dart';
import 'package:my_learning_app/views/loginView.dart';
import 'package:my_learning_app/views/registerView.dart';
import 'package:my_learning_app/provider/authProvider.dart';
import 'package:my_learning_app/views/splashScreen.dart';
import 'package:my_learning_app/views/verifyEmail.dart';

class MyAppRoutes {
  final MyAuthProvider authProvider;

  MyAppRoutes(this.authProvider);

  late final GoRouter router = GoRouter(
    refreshListenable: authProvider,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: "/splash",
        builder: (context, state) => const Splashscreen(),
      ),
      GoRoute(path: "/landing", builder: (context, state) => const HomePage()),
      GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: "/register",
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: "/home", builder: (context, state) => const Noteview()),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool isInitialized = authProvider.isInitialized;
      final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final String location = state.matchedLocation; // or state.uri.toString()
      final bool isEmailVerified = authProvider.isEmailVerified;

      if (!isInitialized) {
        return '/splash';
      }
      if (!isLoggedIn) {
        if (location == '/landing' ||
            location == '/login' ||
            location == '/register') {
          return null;
        }
        return '/landing';
      }
      if (!isEmailVerified) {
        if (location == '/login' ||
            location == '/register' ||
            location == '/landing') {
          return null;
        }
        return '/verify-email';
      }
      if (location == '/splash' ||
          location == '/landing' ||
          location == '/login' ||
          location == '/register' ||
          location == '/verify-email') {
        return '/home';
      }
      return null;
    },
  );
}
