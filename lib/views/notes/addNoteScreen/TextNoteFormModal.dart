import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_learning_app/constants/appColors.dart';
import 'package:my_learning_app/services/crud/noteService.dart';
import 'package:my_learning_app/services/crud/userService.dart';

class AddNewTextNoteScreen extends StatefulWidget {
  final DatabaseNote? existingTextNote;
  bool get isEditMode => existingTextNote != null;

  const AddNewTextNoteScreen({super.key, required this.existingTextNote});
  @override
  State<AddNewTextNoteScreen> createState() => _AddNewTextNoteScreenState();
}

class _AddNewTextNoteScreenState extends State<AddNewTextNoteScreen> {
  bool isEditMode = false;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();
  final _noteService = NoteService();
  final _userService = UserService();

  @override
  void initState() {
    isEditMode = widget.isEditMode;
    if (isEditMode) {
      _title.text = widget.existingTextNote!.title;
      _body.text = widget.existingTextNote!.body;
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _title.dispose();
    _body.dispose();
  }

  // new note methods
  Future<void> _addNewNote({required BuildContext context}) async {
    // if user save new note
    // validate new note & than save in database
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) {
      if (!mounted) return;
      context.pop();
      return;
    }
    final DatabaseNote dbNote = await _noteService.createNote(
      title: _title.text,
      body: _body.text,
    );
    if (!mounted) return;
    context.pop();
  }

  // if edit mode is true
  Future<void> _updateNote({required BuildContext context}) async {
    // if user save new note
    // validate new note & than save in database
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) {
      if (!mounted) return;
      context.pop();
      return;
    }
    final DatabaseNote dbNote = await _noteService.updateNoteText(
      id: widget.existingTextNote!.id,
      title: _title.text,
      body: _body.text,
    );
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  isEditMode ? "Edit Note" : "Text Note",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (isEditMode) {
                  _updateNote(context: context);
                } else {
                  _addNewNote(context: context);
                }
              },
              child: const Text(
                "Save",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Hero(
        tag: "addNewTextNote",
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _title,
                  keyboardType: TextInputType.text,
                  minLines: 1,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 36,
                    color: AppColors.title,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: "Title Here",
                    hintStyle: TextStyle(
                      color: AppColors.body,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _body,
                    keyboardType: TextInputType.text,
                    expands: true,
                    style: const TextStyle(fontSize: 24, color: AppColors.body),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Write your note here..",
                      hintStyle: TextStyle(fontSize: 24, color: AppColors.body),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
