import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_learning_app/utilities/AppColors.dart';

class Notetile extends StatelessWidget {
  final String title;
  final int id;
  final bool isDone;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final VoidCallback onToggle;

  const Notetile({
    super.key,
    required this.id,
    required this.title,
    required this.isDone,
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: IconButton(
          onPressed: onToggle,
          icon: Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? AppColors.primary : AppColors.icon,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.title,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: isDone
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.icon),
          onPressed: () => _showBottomNoteActionMenu(context),
        ),
        onLongPress: () {
          HapticFeedback.lightImpact();
          _showBottomNoteActionMenu(context);
        },
      ),
    );
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
