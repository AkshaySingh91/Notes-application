import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:my_learning_app/constants/appRoutesConstant.dart';
import 'package:my_learning_app/constants/tagsMaterialIconsList.dart';
import 'package:my_learning_app/services/crud/noteService.dart';
import 'package:my_learning_app/services/crud/tagService.dart';
import 'package:my_learning_app/utilities/AppColors.dart';
import 'package:my_learning_app/utilities/DateAndTimeConverter.dart';
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
  bool isCopiedTooltipOpen = false;
  Timer? _toolTipTimer;
  DatabaseNote? fetchedNote;

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

  Future<void> _copyTextBody({required String body}) async {
    try {
      await Clipboard.setData(ClipboardData(text: body));
      setState(() {
        isCopiedTooltipOpen = true;
      });
      _toolTipTimer?.cancel();

      _toolTipTimer = Timer.periodic(Duration(milliseconds: 600), (Timer _) {
        if (!mounted) return;
        setState(() {
          isCopiedTooltipOpen = false;
        });
      });
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  @override
  void initState() {
    _fetchNoteAtOnce();
    super.initState();
  }

  Future<void> _fetchNoteAtOnce() async {
    final note = await _fetchNote();
    setState(() {
      fetchedNote = note;
    });
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(
            MyAppRouteConstants.textNoteFormModal,
            extra: fetchedNote,
          );
        },
        backgroundColor: AppColors.primaryVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(30),
        ),

        child: const Icon(Icons.edit, size: 24, color: AppColors.black),
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

                      final createdAtDate = Dateandtimeconverter.getDateAndTime(
                        dateAndTime: note.createdAt,
                      )["date"];
                      final updatedAtDate = Dateandtimeconverter.getDateAndTime(
                        dateAndTime: note.updatedAt,
                      )["date"];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // title
                          Text(
                            note.title,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Color.fromARGB(221, 42, 41, 41),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // date
                          Row(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.date_range,
                                    size: 14,
                                    color: AppColors.icon,
                                    weight: 500,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    createdAtDate!,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 74, 96, 107),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              if (createdAtDate != updatedAtDate)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,

                                  children: [
                                    const Icon(
                                      Icons.edit,
                                      size: 14,
                                      color: AppColors.icon,
                                      weight: 500,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      updatedAtDate!,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 74, 96, 107),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsGeometry.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: TextButton(
                                          onPressed: () =>
                                              _copyTextBody(body: note.body),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.copy_rounded,
                                                size: 16,
                                                color: AppColors.icon,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "Copy",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.icon,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SelectableText(
                                    note.body,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      height: 1.5,
                                      fontWeight: FontWeight(400),
                                      color: Color.fromARGB(255, 87, 87, 87),
                                    ),
                                  ),
                                ],
                              ),

                              Positioned(
                                right: 0,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: isCopiedTooltipOpen ? 1.0 : 0.0,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 270),
                                    transform: Matrix4.translationValues(
                                      0,
                                      isCopiedTooltipOpen ? -20 : 0,
                                      0,
                                    ),
                                    child: Container(
                                      padding: EdgeInsetsGeometry.symmetric(
                                        vertical: 3,
                                        horizontal: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Text Copied!",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // tags
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Tags",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              FutureBuilder<List<NoteTag>>(
                                future: _fetchAllNoteTags(),
                                initialData: widget.initialTags,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Container(
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
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data != null &&
                                          snapshot.data!.isEmpty) {
                                    return Container(
                                      padding: EdgeInsets.all(12),
                                      color: AppColors.divider,
                                      child: Text(
                                        "No tags added",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    );
                                  }
                                  final noteTags = snapshot.data!;

                                  return _noteTagRow(selectedTag: noteTags);
                                },
                              ),
                            ],
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
