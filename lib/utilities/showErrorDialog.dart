import 'package:flutter/material.dart';

Future<bool?> showErrorDialog(BuildContext context, String errorText) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext builder) {
      return AlertDialog(
        title: const Text(
          "Login Error",
          style: TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
        content: Text(
          errorText,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Ok"),
          ),
        ],
      );
    },
  );
}
