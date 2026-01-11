import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_learning_app/constants/tagsMaterialIconsList.dart';
import 'package:my_learning_app/services/crud/noteService.dart';
import 'package:my_learning_app/services/crud/tagService.dart';
import 'package:my_learning_app/utilities/AppColors.dart';
import 'package:my_learning_app/utilities/ShowErrorDialog.dart';

class NoteDetailScreen extends StatefulWidget {
  final noteId;
  final heroTag;

  List<NoteTag>? initialTags;
  DatabaseNote? initialNote;

  NoteDetailScreen({
    super.key,
    required int this.noteId,
    required String this.heroTag,
    this.initialNote,
    this.initialTags,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _noteService = NoteService();
  DatabaseNote? noteDetail = null;

  Future<DatabaseNote?> _fetchNote() async {
    try {
      final id = widget.noteId;
      final note = await _noteService.getNote(id: id);
      return note;
    } catch (e) {
      showErrorDialog(context, e.toString());
      return null;
    }
  }

  Future<List<NoteTag>> _fetchAllNoteTags() async {
    try {
      final noteId = widget.noteId;
      List<NoteTag> noteTags = await _noteService.getAllTagsOfSpecificNote(
        noteId: noteId,
      );

      return noteTags;
    } catch (e) {
      showErrorDialog(context, e.toString());
      return [];
    }
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
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Text Note",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Hero(
          tag: widget.heroTag,
          child: Material(
            type: MaterialType.transparency,
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(0),
                child: Padding(
                  padding: EdgeInsetsGeometry.all(14),
                  child: FutureBuilder(
                    future: _fetchNote(),
                    initialData: widget.initialNote,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              color: AppColors.divider,
                              child: Text(
                                "${snapshot.error}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      if (!snapshot.hasData) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              color: AppColors.divider,
                              child: Text(
                                "No Note found, id may be wrong",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      DatabaseNote note = snapshot.data!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            note.title,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Color.fromARGB(221, 42, 41, 41),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            note.body,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight(400),
                              color: Color.fromARGB(255, 87, 87, 87),
                            ),
                          ),
                          const SizedBox(height: 12),

                          FutureBuilder<List<NoteTag>>(
                            future: _fetchAllNoteTags(),
                            initialData: widget.initialTags,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Container(
                                  child: Text("${snapshot.error}"),
                                );
                              }
                              if (!snapshot.hasData) {
                                return Container(
                                  child: Text("No Note Tag found"),
                                );
                              }
                              final noteTags = snapshot.data!;

                              return _noteTagRow(selectedTag: noteTags);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _noteTagRow({required List<NoteTag> selectedTag}) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        itemCount: selectedTag.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final materialIconName = selectedTag[index].materialIconName;
          final icon = TagsMaterialIconsList.tagsIconsList
              .firstWhere(
                (element) {
                  return element.keys.first == materialIconName;
                },
                orElse: () {
                  return {'defalut': Icons.label};
                },
              )
              .values
              .first;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Container(
              width: 80,
              height: 52,
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(width: 1, color: AppColors.primary),
                color: AppColors.primary.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, size: 24, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      selectedTag[index].customTagName,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                      
                        fontSize: 12,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
