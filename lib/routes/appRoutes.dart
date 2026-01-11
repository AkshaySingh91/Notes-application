import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_learning_app/main.dart';
import 'package:my_learning_app/constants/appRoutesConstant.dart';
import 'package:my_learning_app/services/auth/authUser.dart';
import 'package:my_learning_app/services/crud/noteService.dart';
import 'package:my_learning_app/services/crud/tagService.dart';
import 'package:my_learning_app/views/notes/noteDetailScreen/NoteDetailScreen.dart';
import 'package:my_learning_app/views/notes/textNoteFormModal/TextNoteFormView.dart';
import 'package:my_learning_app/views/notes/notesScreen/Notesview.dart';
import 'package:my_learning_app/views/LoginView.dart';
import 'package:my_learning_app/views/RegisterView.dart';
import 'package:my_learning_app/views/SplashScreen.dart';
import 'package:my_learning_app/views/tagDashboard/AllTagsScreen.dart';
import 'package:my_learning_app/views/tagDashboard/TagFormModal.dart';
import 'package:my_learning_app/views/VerifyEmailScreen.dart';

class MyAppRoutes {
  final MyAuthProvider authProvider;

  MyAppRoutes(this.authProvider);

  late final GoRouter router = GoRouter(
    refreshListenable: authProvider,
    initialLocation: MyAppRouteConstants.splashRoute,
    routes: [
      GoRoute(
        path: MyAppRouteConstants.splashRoute,
        builder: (context, state) => const Splashscreen(),
      ),
      GoRoute(
        path: MyAppRouteConstants.landingRoute,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: MyAppRouteConstants.loginRoute,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: MyAppRouteConstants.registerRoute,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: MyAppRouteConstants.homeRoute,
        builder: (context, state) => const Noteview(),
      ),
      GoRoute(
        path: MyAppRouteConstants.verifyEmailRoute,
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: MyAppRouteConstants.textNoteFormModal,
        builder: (context, state) =>
            TextNoteFormView(existingTextNote: state.extra as DatabaseNote?),
      ),
      GoRoute(
        path: MyAppRouteConstants.tagsDashboardRoute,
        builder: (context, state) => AllTagsScreen(),
      ),
      GoRoute(
        path: MyAppRouteConstants.tagFormModal,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: TagFormModal(existingTag: state.extra as NoteTag?),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final tween = Tween<Offset>(
                    // 1 -> 100% height ie from below screen edge slide occur
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        name: 'note',
        path: MyAppRouteConstants.noteDetailRoute,
        builder: (context, state) {
          final int noteid =
              int.tryParse(state.pathParameters['noteid'].toString()) ?? 0;

          final Map<String, dynamic>? data =
              state.extra is Map<String, dynamic>?
              ? state.extra as Map<String, dynamic>?
              : null;

          final String herotag = data?['herotag'] as String? ?? '';

          final DatabaseNote? initialNote =
              data?['initialnote'] as DatabaseNote?;

          final List<NoteTag>? initialTags =
              data?['initialtags'] as List<NoteTag>?;

          return NoteDetailScreen(
            noteId: noteid,
            heroTag: herotag,
            initialNote: initialNote,
            initialTags: initialTags,
          );
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool isInitialized = authProvider.isInitialized;
      final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final String location = state.matchedLocation; // or state.uri.toString()
      final bool isEmailVerified = authProvider.isEmailVerified;

      if (!isInitialized) {
        return MyAppRouteConstants.splashRoute;
      }
      if (!isLoggedIn) {
        if (location == MyAppRouteConstants.landingRoute ||
            location == MyAppRouteConstants.loginRoute ||
            location == MyAppRouteConstants.registerRoute) {
          return null;
        }
        return MyAppRouteConstants.landingRoute;
      }
      if (!isEmailVerified) {
        if (location == MyAppRouteConstants.loginRoute ||
            location == MyAppRouteConstants.registerRoute ||
            location == MyAppRouteConstants.landingRoute) {
          return null;
        }
        return MyAppRouteConstants.verifyEmailRoute;
      }
      if (location == MyAppRouteConstants.splashRoute ||
          location == MyAppRouteConstants.landingRoute ||
          location == MyAppRouteConstants.loginRoute ||
          location == MyAppRouteConstants.registerRoute ||
          location == MyAppRouteConstants.verifyEmailRoute) {
        return MyAppRouteConstants.homeRoute;
        return MyAppRouteConstants.textNoteFormModal;
      }
      return null;
    },
  );
}
