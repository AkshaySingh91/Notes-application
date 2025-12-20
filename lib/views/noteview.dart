import 'package:flutter/material.dart';
import 'package:my_learning_app/services/auth/authService.dart';
import 'package:my_learning_app/services/auth/authUser.dart';
import 'package:my_learning_app/services/crud/noteService.dart';
import 'package:provider/provider.dart';

class Noteview extends StatefulWidget {
  const Noteview({super.key});

  @override
  State<Noteview> createState() => _NoteViewScreen();
}

enum MenuItems { profile, logout }

class _NoteViewScreen extends State<Noteview> {
  final _noteService = NoteService();

  Future<void> printTable() async {
    final n = NoteService();
    await n.checkAllTable();
  }

  @override
  void initState() {
    _noteService.open();
    super.initState();
  }

  @override
  void dispose() {
    _noteService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    final authProvider = Provider.of<MyAuthProvider>(context, listen: true);

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
            ListTile(
              leading: Icon(Icons.print),
              title: Text('printAllTable'),
              onTap: () {
                printTable();
              },
            ),
          ],
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder(
            future: _noteService.getOrCreateUser(
              email: authProvider.currentUser!.email!,
            ),
            builder: (context, snapshot) {
              // future can give error
              //future can give wating state
              //future can give empty data
              //lastly future state will done
              //we dont use data so data empty/not-empty doesnt important
              if (snapshot.hasError) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(snapshot.error.toString())],
                );
              } else {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    // we will get notes here as a stream data
                    return StreamBuilder(
                      stream: _noteService.stream,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsetsGeometry.all(12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "waiting for text to appear here..",
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );

                          case ConnectionState.active:
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text("No Notes found");
                            }
                            return const Text("Your data will appear here");

                          case ConnectionState.done:
                            return const Text("Stream has ended");

                          default:
                            return const CircularProgressIndicator();
                        }
                      },
                    );
                  default:
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [CircularProgressIndicator()],
                    );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
