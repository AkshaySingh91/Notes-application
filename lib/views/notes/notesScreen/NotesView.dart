import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_learning_app/constants/appRoutesConstant.dart';
import 'package:my_learning_app/services/auth/authService.dart';
import 'package:my_learning_app/services/auth/authUser.dart';
import 'package:my_learning_app/services/crud/noteService.dart';
import 'package:my_learning_app/services/crud/tagService.dart';
import 'package:my_learning_app/services/crud/userService.dart';
import 'package:my_learning_app/utilities/AppColors.dart';
import 'package:my_learning_app/utilities/ShowErrorDialog.dart';
import 'package:my_learning_app/views/notes/notesScreen/AnimatedFloatingActionButton.dart';
import 'package:my_learning_app/views/notes/notesScreen/NoteTile.dart';
import 'package:my_learning_app/views/notes/notesScreen/SearchAndFilter.dart';
import 'package:provider/provider.dart';

class Noteview extends StatefulWidget {
  const Noteview({super.key});

  @override
  State<Noteview> createState() => _NoteViewScreen();
}

enum MenuItems { profile, logout }

class _NoteViewScreen extends State<Noteview>
    with SingleTickerProviderStateMixin {
  final _noteService = NoteService();
  final _userService = UserService();

  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Total duration
    );
    _loadNotes();
    super.initState();
  }

  Future<void> _loadNotes() async {
    await _noteService.loadNotesForUser();
  }

  @override
  void dispose() {
    // singleton service should not be closed by ui especially when it used in streambuilder
    // if we close it stream might want to access db
    // _noteService.close();
    super.dispose();
    _animationController.dispose();
  }

  Future<void> deleteNote(int id) async {
    _noteService.deleteNote(id: id);
  }

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

  Future<List<NoteTag>> _fetchAllNotesTag({required int noteId}) async {
    try {
      final tags = await _noteService.getAllTagsOfSpecificNote(noteId: noteId);
      return tags;
    } catch (e) {
      showErrorDialog(context, e.toString());
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context, listen: true);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _animationController.reverse();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("My Notes", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("All Folders", style: TextStyle(fontSize: 12)),
            ],
          ),
          backgroundColor: Color.fromARGB(255, 247, 247, 247),
          actions: [
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text("AK")),
            ),
          ],
        ),

        drawer: Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          backgroundColor: const Color(0xFFF7F7F7),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text(
                  "John Doe",
                  style: TextStyle(
                    color: Color(0xFF1C1C1C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                accountEmail: const Text(
                  "john.doe@example.com",
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage("assets/userimage.png"),
                ),
                decoration: const BoxDecoration(color: Color(0xFFEDEDED)),
              ),

              _drawerItem(
                icon: Icons.settings,
                title: "Settings",
                onTap: () {},
              ),
              _drawerItem(
                icon: Icons.logout,
                title: "Logout",
                onTap: () async {
                  final res = await handleLogout();
                  if (res) {
                    await AuthService.firebase().logout();
                  }
                },
              ),
              _drawerItem(
                icon: Icons.label,
                onTap: () {
                  context.pop();
                  _animationController.reset();
                  context.push(MyAppRouteConstants.tagsDashboardRoute);
                },
                title: "Tags Dashboard",
              ),
            ],
          ),
        ),

        floatingActionButton: AnimatedFloatingActionButton(
          onAddTextNoteClick: () {
            // navigate to Add New Note Screen
            context.push(MyAppRouteConstants.textNoteFormModal);
          },
          onAddVoiceNoteClick: () {
            // navigate to Add New Note Screen
            context.push(MyAppRouteConstants.textNoteFormModal);
          },
          animationController: _animationController,
        ),

        body: Stack(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder(
              future: _userService.getOrCreateUser(
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
                      return StreamBuilder<List<DatabaseNote>>(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                              // if data is null or notes list is empty
                              if (!(snapshot.hasData &&
                                  snapshot.data!.isNotEmpty)) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsetsGeometry.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.note_outlined,
                                          size: 48,
                                          color: AppColors.body,
                                        ),
                                        Text(
                                          "No notes found",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.title,
                                          ),
                                        ),
                                        Text(
                                          "Start adding them now",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.body,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              final list = snapshot.data;

                              return ListView.builder(
                                padding: EdgeInsets.only(top: 60),
                                itemCount: list!.length,
                                itemBuilder: (context, index) {
                                  return FutureBuilder<List<NoteTag>>(
                                    future: _fetchAllNotesTag(
                                      noteId: list[index].id,
                                    ),
                                    builder: (context, snapshot) {
                                      List<NoteTag> tags = [];
                                      if (snapshot.hasData &&
                                          !snapshot.hasError) {
                                        tags = snapshot.data!;
                                      }
                                      return Notetile(
                                        note: list[index],
                                        noteTags: tags,
                                        onDelete: () {
                                          final noteToDelete = list[index];
                                          deleteNote(noteToDelete.id);
                                        },
                                        onUpdate: () async {
                                          // we will just pass current note to edit note screen
                                          final existingTextNote = list[index];
                                          context.push(
                                            MyAppRouteConstants
                                                .textNoteFormModal,
                                            extra: existingTextNote,
                                          );
                                        },
                                        onToggle: () {
                                          // get isDone for note (capture current note from surrounding scope)
                                          final currentNote = list[index];
                                          final updatedIsDone =
                                              currentNote.isDone != 0 ? 1 : 0;
                                          // mark that task as done whose id is given
                                          _noteService.updateNoteIsDone(
                                            id: currentNote.id,
                                            isDone: updatedIsDone != 0
                                                ? true
                                                : false,
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );

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
            // search bar & filter button
            Searchandfilter(),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4B5563)),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1C1C1C),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
