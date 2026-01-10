import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_learning_app/constants/appColors.dart';
import 'package:my_learning_app/constants/tagsMaterialIconsList.dart';
import 'package:my_learning_app/services/crud/noteService.dart';
import 'package:my_learning_app/services/crud/tagService.dart';
import 'package:my_learning_app/utilities/ShowErrorDialog.dart';

class AddNewTextNoteScreen extends StatefulWidget {
  final DatabaseNote? existingTextNote;
  bool get isEditMode => existingTextNote != null;

  const AddNewTextNoteScreen({super.key, required this.existingTextNote});
  @override
  State<AddNewTextNoteScreen> createState() => _AddNewTextNoteScreenState();
}

class _AddNewTextNoteScreenState extends State<AddNewTextNoteScreen> {
  bool isEditMode = false;
  bool isSheetOpen = false;
  List<NoteTag> selectedTag = [];

  late final DraggableScrollableController _sheetController;
  final _rowScrollController = ScrollController();

  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _bodyFocusNode = FocusNode();

  final _noteService = NoteService();
  final _tagService = TagService();
  List<NoteTag> _userNoteTags = [];

  void _handleSheetController() {
    // safe access — don't call setState if unmounted
    double pixels = 0;
    try {
      if (_sheetController.isAttached) {
        pixels = _sheetController.pixels;
      }
    } catch (_) {
      pixels = 0;
    }

    if (!mounted) return;

    if (!pixels.isNaN && pixels <= 0) {
      setState(() {
        isSheetOpen = false;
      });
    }
  }

  void _handleTitleFocusChange() {
    if (!_titleFocusNode.hasFocus) return;
    if (!mounted) return;
    setState(() {
      isSheetOpen = false;
    });
    try {
      if (_sheetController.isAttached) {
        _sheetController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.bounceOut,
        );
      }
    } catch (_) {}
  }

  void _handleBodyFocusChange() {
    if (!_bodyFocusNode.hasFocus) return;
    if (!mounted) return;
    setState(() {
      isSheetOpen = false;
    });
    try {
      if (_sheetController.isAttached) {
        _sheetController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.bounceOut,
        );
      }
    } catch (_) {}
  }

  @override
  void initState() {
    isEditMode = widget.isEditMode;
    if (isEditMode) {
      _title.text = widget.existingTextNote!.title;
      _body.text = widget.existingTextNote!.body;
      // fetch note all tags
      _fetchAllNoteTags(noteId: widget.existingTextNote!.id);
    }
    _getAllNoteTags();

    _sheetController = DraggableScrollableController();
    _sheetController.addListener(_handleSheetController);

    // use named listeners so we can remove them in dispose
    _titleFocusNode.addListener(_handleTitleFocusChange);
    _bodyFocusNode.addListener(_handleBodyFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((Duration timestamp) {});
    super.initState();
  }

  void _openSheet({required BuildContext context}) {
    // if keyboard is open , close it
    FocusScope.of(context).unfocus();

    if (isSheetOpen) {
      _sheetController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.bounceOut,
      );
      setState(() {
        isSheetOpen = false;
      });
    } else {
      _sheetController.animateTo(
        0.6, // 40%
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() {
        isSheetOpen = true;
      });
    }
  }

  @override
  void dispose() {
    // remove listeners before disposing nodes/controllers
    _titleFocusNode.removeListener(_handleTitleFocusChange);
    _bodyFocusNode.removeListener(_handleBodyFocusChange);
    _sheetController.removeListener(_handleSheetController);

    _title.dispose();
    _body.dispose();

    _titleFocusNode.dispose();
    _bodyFocusNode.dispose();
    _sheetController.dispose();
    _rowScrollController.dispose();
    super.dispose();
  }

  void _moveRowAfterAddingTag() {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (_rowScrollController.hasClients) {
        _rowScrollController.animateTo(
          _rowScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // new note methods
  Future<void> _addNewNote({required BuildContext context}) async {
    // if user save new note
    // validate new note & than save in database
    try {
      if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) {
        if (!mounted) return;
        context.pop();
        return;
      }
      final DatabaseNote dbNote = await _noteService.createNote(
        title: _title.text,
        body: _body.text,
        noteTags: selectedTag,
      );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  Future<void> _fetchAllNoteTags({required int noteId}) async {
    try {
      List<NoteTag> noteTags = await _noteService.getAllTagsOfSpecificNote(
        noteId: noteId,
      );

      setState(() {
        selectedTag = noteTags;
      });
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  // if edit mode is true
  Future<void> _updateNote({required BuildContext context}) async {
    try {
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
        noteTags: selectedTag,
      );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  //get all user note tags
  Future<void> _getAllNoteTags() async {
    try {
      List<NoteTag> tags = await _tagService.getAllNoteTags();
      if (tags.isNotEmpty) {
        setState(() {
          _userNoteTags = tags;
        });
      }
    } catch (e) {
      showErrorDialog(context, e.toString());
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _title,
                      focusNode: _titleFocusNode,
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
                        focusNode: _bodyFocusNode,
                        keyboardType: TextInputType.text,
                        expands: true,
                        style: const TextStyle(
                          fontSize: 24,
                          color: AppColors.body,
                        ),
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "Write your note here..",
                          hintStyle: TextStyle(
                            fontSize: 24,
                            color: AppColors.body,
                          ),
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

              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0,
                maxChildSize: 0.7,
                minChildSize: 0,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    // This prevents overflow when the sheet is small
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Select Icons",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              // Safe Icon Retrieval
                              final iconData = TagsMaterialIconsList
                                  .tagsIconsList
                                  .firstWhere(
                                    (element) =>
                                        element.keys.first ==
                                        _userNoteTags[index].materialIconName,
                                    orElse: () => {'default': Icons.label},
                                  )
                                  .values
                                  .first;

                              final isTagSelected = selectedTag.any(
                                (t) => t.tagId == _userNoteTags[index].tagId,
                              );

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isTagSelected) {
                                      selectedTag.removeWhere(
                                        (t) =>
                                            t.tagId ==
                                            _userNoteTags[index].tagId,
                                      );
                                    } else {
                                      _moveRowAfterAddingTag();
                                      selectedTag.add(_userNoteTags[index]);
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: isTagSelected
                                        ? AppColors.primary.withOpacity(0.1)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isTagSelected
                                          ? AppColors.primary
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        iconData,
                                        color: isTagSelected
                                            ? AppColors.primary
                                            : AppColors.body,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _userNoteTags[index].materialIconName,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.body,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }, childCount: _userNoteTags.length),
                          ),
                        ),
                        // Extra padding at bottom so grid doesn't cut off
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      ],
                    ),
                  );
                },
              ),

              ListenableBuilder(
                listenable: Listenable.merge([_sheetController]),
                builder: (context, child) {
                  double currentSize = 0;
                  if (_sheetController.isAttached) {
                    currentSize = _sheetController.size;
                  }
                  final mediaQuery = MediaQuery.of(context);

                  final safeHeight =
                      mediaQuery.size.height -
                      mediaQuery.padding.top -
                      mediaQuery.padding.bottom;
                  final double sheetHeightInPixels = currentSize * safeHeight;

                  return Positioned(
                    left: 12,
                    right: 12,
                    bottom: currentSize <= 0 ? 24 : sheetHeightInPixels,
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () => _openSheet(context: context),
                          style: ButtonStyle(
                            side: WidgetStatePropertyAll(
                              BorderSide(
                                width: isSheetOpen ? 2 : 1,
                                color: isSheetOpen
                                    ? AppColors.primary
                                    : AppColors.primaryVariant,
                              ),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              isSheetOpen
                                  ? AppColors.primaryVariant
                                  : Color.fromARGB(255, 255, 191, 73),
                            ),
                          ),
                          child: Text("Add Tag"),
                        ),

                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: _noteTagRow(selectedTag: selectedTag),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _noteTagRow({required List<NoteTag> selectedTag}) {
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 6),
      child: ListView.builder(
        controller: _rowScrollController,
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
            padding: EdgeInsetsGeometry.symmetric(horizontal: 3),
            child: TextButton(
              onPressed: () {},
              style: ButtonStyle(
                side: WidgetStatePropertyAll(
                  BorderSide(width: 1, color: AppColors.primary),
                ),
                backgroundColor: WidgetStatePropertyAll(
                  AppColors.primary.withOpacity(0.1),
                ),
              ),
              child: Icon(icon, size: 24, color: AppColors.primary),
            ),
          );
        },
      ),
    );
  }
}
