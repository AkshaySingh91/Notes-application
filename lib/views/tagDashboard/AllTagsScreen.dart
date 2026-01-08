import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_learning_app/constants/AppColors.dart';
import 'package:my_learning_app/constants/appRoutesConstant.dart';
import 'package:my_learning_app/constants/tagsMaterialIconsList.dart';
import 'package:my_learning_app/services/auth/authUser.dart';
import 'package:my_learning_app/services/crud/crudExceptions.dart';
import 'package:my_learning_app/services/crud/tagService.dart';
import 'package:my_learning_app/services/crud/userService.dart';
import 'package:my_learning_app/utilities/ShowErrorDialog.dart';
import 'package:provider/provider.dart';

class AllTagsScreen extends StatefulWidget {
  const AllTagsScreen({super.key});

  @override
  State<AllTagsScreen> createState() => _AllTagsScreenState();
}

class _AllTagsScreenState extends State<AllTagsScreen> {
  final _userService = UserService();
  final _noteTagService = TagService();

  // Future<void> onUpdateTag({required int tagId}) async {
  //   try {
  //     await _noteTagService.updateNoteTag(tagId: tagId, materialIconName: materialIconName, priority: priority, customIconName: customIconName)
  //   } on NoteTagNotFoundException {
  //     showErrorDialog(context, "Tagid or Tag not found");
  //   } catch (e) {
  //     showErrorDialog(context, e.toString());
  //   }
  // }

  Future<void> onDeleteTag({required int tagId}) async {
    try {
      await _noteTagService.deleteNoteTag(tagId: tagId);
    } on NoteTagNotFoundException {
      showErrorDialog(context, "Tagid or Tag not found");
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _feedNoteTags();
    _loadNoteTags();
  }

  Future<void> _loadNoteTags() async {
    await _noteTagService.loadNoteTagsForUser();
  }

  Future<void> _feedNoteTags() async {
    await _noteTagService.feedNoteTagData();
  }

  @override
  Widget build(BuildContext context) {
    // if user has reach on tag screen from route it means that he have completed auth
    // and current user must exist
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Note Type", textAlign: TextAlign.center),
        centerTitle: true,
        actions: [
          Hero(
            tag: "AddNewTagButton",
            child: IconButton(
              onPressed: () {
                context.push(MyAppRouteConstants.tagFormModal);
              },
              icon: const Icon(Icons.add),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  AppColors.primaryVariant,
                ),
                padding: WidgetStateProperty.all(const EdgeInsets.all(6)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              iconSize: 28,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _headerRow(),
          FutureBuilder(
            future: _userService.getOrCreateUser(
              email: authProvider.currentUser!.email!,
            ),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return StreamBuilder<List<NoteTag>>(
                    stream: _noteTagService.stream,

                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                      }

                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Padding(
                            padding: EdgeInsetsGeometry.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Text("waiting for tag stream to emitt data..."),
                                SizedBox(height: 24),
                                CircularProgressIndicator(),
                              ],
                            ),
                          );

                        case ConnectionState.active:
                          // check if data exist or not
                          if (snapshot.data == null || snapshot.data!.isEmpty) {
                            return Center(child: Text("No Tag Exist"));
                          }
                          List<NoteTag> noteTagList = snapshot.data!;
                          return Expanded(
                            child: ListView.builder(
                              itemCount: noteTagList.length,
                              itemBuilder: (context, index) {
                                final tag = noteTagList[index];

                                return _tableRow(
                                  materialIconName: tag.materialIconName,
                                  customIconName: tag.customTagName,
                                  priority: tag.priority,
                                  openBottomSheetModal: () {
                                    _showBottomNoteActionMenu(
                                      context: context,
                                      tag: tag,
                                    );
                                  },
                                  key: noteTagList[index].tagId,
                                );
                              },
                            ),
                          );

                        case ConnectionState.done:
                          return const Text("Stream has ended");

                        default:
                          return CircularProgressIndicator(
                            color: AppColors.body,
                          );
                      }
                    },
                  );
                default:
                  return const Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Text("Creating Database user..."),
                        SizedBox(height: 24),
                        CircularProgressIndicator(),
                      ],
                    ),
                  );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _headerRow() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: DefaultTextStyle(
        style: TextStyle(
          color: AppColors.title,
          fontWeight: FontWeight(600),
          fontSize: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Expanded(child: Text("Icon")),
            Expanded(flex: 2, child: Text("Name")),
            Expanded(child: Text("Priority")),
            Expanded(child: Text("Actions")),
          ],
        ),
      ),
    );
  }

  Widget _tableRow({
    required String materialIconName,
    required String customIconName,
    required int priority,
    required VoidCallback openBottomSheetModal,
    required int key,
  }) {
    final int index = TagsMaterialIconsList.tagsIconsList.indexWhere(
      (iconMap) => iconMap.containsKey(materialIconName),
    );

    return Container(
      key: Key(key.toString()),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Icon(
              index != -1
                  ? TagsMaterialIconsList.tagsIconsList[index][materialIconName]
                  : Icons.help_outline,
              size: 22,
              color: AppColors.icon,
            ),
          ),
          Expanded(flex: 2, child: Text(customIconName)),
          Expanded(child: Text(priority.toString())),
          Expanded(
            child: IconButton(
              onPressed: openBottomSheetModal,
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomNoteActionMenu({
    required BuildContext context,
    required NoteTag tag,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.icon),
                title: Text(
                  "Edit",
                  style: TextStyle(color: AppColors.black, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push(MyAppRouteConstants.tagFormModal, extra: tag);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.icon),
                title: Text(
                  "Delete",
                  style: TextStyle(color: AppColors.danger, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDeleteTag(tagId: tag.tagId);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
