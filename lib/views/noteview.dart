import 'package:flutter/material.dart';
import 'package:my_learning_app/services/auth/authService.dart';

class Noteview extends StatefulWidget {
  const Noteview({super.key});

  @override
  State<Noteview> createState() => _NoteViewScreen();
}

enum MenuItems { profile, logout }

class _NoteViewScreen extends State<Noteview> {
  Future<bool> handleLogout() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext builder) {
            return AlertDialog(
              title: const Text("You want to be logout?"),
              content: const Text("This cannot be undone."),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context, true);
                  },
                  child: Text("Confirm"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text("Cancle"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Notes", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("All Folders", style: TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.amberAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              print("Search");
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              print("Alerts");
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(child: Text("AK")),
          ),
        ],
      ),
      drawer: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        backgroundColor: Colors.amber,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("John Doe"),
              accountEmail: Text("john.doe@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage("assets/userimage.png"),
              ),
              decoration: BoxDecoration(color: Colors.deepOrange),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                final res = await handleLogout();
                if (res) {
                  await AuthService.firebase().logout();
                }
              },
            ),
          ],
        ),
      ),

      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          
        ],
      ),
    );
  }
}
