import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:my_learning_app/constants/tagsMaterialIconsList.dart';
import 'package:my_learning_app/services/crud/noteService.dart';
import 'package:my_learning_app/services/crud/tagService.dart';
import 'package:my_learning_app/utilities/AppColors.dart';

class Notetile extends StatelessWidget {
  final DatabaseNote note;
  final List<NoteTag> noteTags;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final VoidCallback onToggle;

  const Notetile({
    super.key,
    required this.note,
    required this.noteTags,
    required this.onDelete,
    required this.onUpdate,
    required this.onToggle,
  });

  void _showBottomNoteActionMenu(BuildContext context) {
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
              _bottomAction(
                icon: Icons.edit,
                label: "Edit",
                onTap: () {
                  Navigator.pop(context);
                  onUpdate();
                },
              ),
              _bottomAction(
                icon: Icons.delete,
                label: "Delete",
                color: AppColors.danger,
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, String> _getDateAndTime({required String dateAndTime}) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Jun',
      'July',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final parsedDateAndTime = DateTime.tryParse(dateAndTime);
    if (parsedDateAndTime == null) {
      return {'date': 'Not Defined', 'time': 'Not Defined'};
    }
    final date = parsedDateAndTime.day.toString();
    final month = months[parsedDateAndTime.month - 1];
    final time = '${parsedDateAndTime.hour} ${parsedDateAndTime.minute}';
    return {'date': "$month $date", 'time': time};
  }

  @override
  Widget build(BuildContext context) {
    final date = _getDateAndTime(dateAndTime: note.createdAt)['date'];
    final time = _getDateAndTime(dateAndTime: note.createdAt)['time'];
    final herotag = "detailNoteScreen-${note.id}";

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.lightImpact();
        _showBottomNoteActionMenu(context);
      },
      onTap: () {
        context.pushNamed(
          'note',
          pathParameters: {'noteid': note.id.toString()},
          extra: {
            "herotag": herotag,
            "initialnote": note,
            "initialtags": noteTags,
          },
        );
      },
      child: Hero(
        tag: herotag,
        child: Card(
          color: AppColors.card,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsetsGeometry.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top header to show toggle button, ðate & time, action menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: onToggle,
                      icon: Icon(
                        note.isDone != 0
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: note.isDone != 0
                            ? AppColors.primary
                            : AppColors.icon,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: date,
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 14,
                          ),
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Text(
                                ' · ',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            TextSpan(
                              text: time,
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: AppColors.icon),
                      onPressed: () => _showBottomNoteActionMenu(context),
                    ),
                  ],
                ),
                // title
                Text(
                  "${note.title}",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight(800),
                    color: const Color.fromARGB(221, 42, 41, 41),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${note.body}",
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight(400),
                    color: const Color.fromARGB(255, 87, 87, 87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ), // body
                // tags
                Row(children: [...noteTagsChips(noteTags: noteTags)]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> noteTagsChips({required List<NoteTag> noteTags}) {
    List<NoteTag> shortListOfTags = noteTags;

    if (noteTags.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Container(
            width: 72,
            height: 38,
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(width: 1, color: AppColors.primary),
              color: AppColors.primary.withOpacity(0.2),
            ),
            child: Text(
              "No tag",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.deepOrange),
            ),
          ),
        ),
      ];
    }
    if (noteTags.length > 3) {
      shortListOfTags = noteTags.sublist(0, 3);
    }
    List<Widget> widgetList = shortListOfTags.map((tag) {
      final materialIconName = tag.materialIconName;
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
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Container(
          width: 72,
          height: 38,
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(width: 1, color: AppColors.primary),
            color: AppColors.primary.withOpacity(0.4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  tag.customTagName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    if (noteTags.length > 3) {
      widgetList.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Container(
            width: 52,
            height: 38,
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(width: 2, color: AppColors.primary),
              color: AppColors.primary.withOpacity(0.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 20,
                  fontWeight: FontWeight(800),
                  color: AppColors.primary,
                ),
                Text(
                  '${noteTags.length - 3}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight(800),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widgetList;
  }

  Widget _bottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.title,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontSize: 16)),
      onTap: onTap,
    );
  }
}
