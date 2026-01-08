import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_learning_app/constants/tagsMaterialIconsList.dart';
import 'package:my_learning_app/services/crud/crudExceptions.dart';
import 'package:my_learning_app/services/crud/tagService.dart';
import 'package:my_learning_app/utilities/AppColors.dart';
import 'dart:math' show pi;

import 'package:my_learning_app/utilities/ShowErrorDialog.dart';

class TagFormModal extends StatefulWidget {
  final NoteTag? existingTag;

  const TagFormModal({super.key, this.existingTag});
  bool get isEditMode => existingTag != null;

  @override
  State<TagFormModal> createState() => _TagFormModalState();
}

class _TagFormModalState extends State<TagFormModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _tagName = TextEditingController();
  final TextEditingController _priority = TextEditingController();
  bool isEditMode = false;

  final _tagService = TagService();

  String _selectedIconName =
      TagsMaterialIconsList.tagsIconsList.first.keys.first;
  IconData _selectedIcon =
      TagsMaterialIconsList.tagsIconsList.first.values.first;

  String? _tempSelectedIconName;
  IconData? _tempSelectedIcon;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isEditMode = widget.isEditMode;
    if (isEditMode) {
      _tagName.text = widget.existingTag!.customTagName;
      _priority.text = widget.existingTag!.priority.toString();
      _selectedIconName = widget.existingTag!.materialIconName;

      final map = TagsMaterialIconsList.tagsIconsList.firstWhere(
        (map) => map.containsKey(_selectedIconName),
      );
      _selectedIcon = map[_selectedIconName]!;
    }

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _selectedIconName = _tempSelectedIconName!;
          _selectedIcon = _tempSelectedIcon!;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _flipController.dispose();
    _tagName.dispose();
    _priority.dispose();
  }

  Future<void> _createNewTag(BuildContext context) async {
    try {
      await _tagService.createNoteTag(
        materialIconName: _selectedIconName,
        priority: int.parse(_priority.text),
        customIconName: _tagName.text,
      );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  Future<void> _saveNoteTag(BuildContext context) async {
    try {
      await _tagService.updateNoteTag(
        tagId: widget.existingTag!.tagId,
        materialIconName: _selectedIconName,
        priority: int.parse(_priority.text),
        customIconName: _tagName.text,
      );
      if (!mounted) return;
      context.pop();
    } on CouldNotUpdateNote {
      showErrorDialog(context, "Could not update");
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  Widget _buildFlipFace(bool isUnder) {
    // when icon takes more than 90 degree will change icon to selected on so that user dont get to know when it changed
    final IconData icon = isUnder
        ? _tempSelectedIcon ?? _selectedIcon
        : _selectedIcon;
    final String name = isUnder
        ? _tempSelectedIconName ?? _selectedIconName
        : _selectedIconName;

    return Transform(
      alignment: Alignment.center,
      // very important we will flip icon in between so that no mirror image render
      transform: isUnder ? Matrix4.rotationX(pi) : Matrix4.identity(),
      child: Container(
        padding: const EdgeInsets.all(14),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: AppColors.surface,
          boxShadow: const [
            BoxShadow(blurRadius: 6, color: Color.fromARGB(30, 0, 0, 0)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.black),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedIconPreview() {
    return GestureDetector(
      onTap: () async {
        final result = await _openIconPickerSheet();
        if (result != null) {
          _flipController.forward(from: 0);
          setState(() {
            _tempSelectedIcon = result.icon;
            _tempSelectedIconName = result.name;
          });
        }
      },
      child: Column(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_flipController]),
            builder: (context, child) {
              final angle = _flipAnimation.value;
              final isUnder = angle > pi / 2;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(angle),
                child: _buildFlipFace(isUnder),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            "Tap icon to change",
            style: TextStyle(fontSize: 12, color: AppColors.body),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Tag" : "Create New Tag"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.cancel_sharp, size: 24),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _animatedIconPreview(),
              const SizedBox(height: 24),

              Column(
                children: [
                  _buildTextField(
                    label: "Tag Name",
                    hintText: "e.g., Groceries",
                    leadingIcon: Icons.label,
                    controller: _tagName,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value != null && value.length > 20) {
                        return 'Must be less than 20 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: "Priority",
                    hintText: "1 (High) - 10 (low)",
                    leadingIcon: Icons.sort,
                    controller: _priority,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && int.tryParse(value) == null) {
                        return 'Must be a number';
                      } else if (int.tryParse(value)! > 10 ||
                          int.tryParse(value)! < 1) {
                        return 'Must be from 1 to 10';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final isValid = _formKey.currentState!.validate();
                        if (isValid) {
                          if (isEditMode) {
                            _saveNoteTag(context);
                          } else {
                            _createNewTag(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors
                            .primary, // Make sure AppColors.primary exists or use Colors.blue
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: const Text(
                        "Save Tag",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required IconData leadingIcon,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 14,
            fontWeight: FontWeight(700),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(leadingIcon, color: AppColors.body),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.title, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Future<IconPickerResult?> _openIconPickerSheet() async {
    final result = await showModalBottomSheet<IconPickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        String tempSelectedIcon = _selectedIconName;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.9,

              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Drag handle
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
                        "Select Icon",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                          itemCount: TagsMaterialIconsList.tagsIconsList.length,
                          itemBuilder: (context, index) {
                            final map =
                                TagsMaterialIconsList.tagsIconsList[index];
                            final iconName = map.keys.first;
                            final icon = map.values.first;
                            final isSelected = iconName == tempSelectedIcon;

                            return InkWell(
                              onTap: () {
                                // just for local change for few sec
                                setModalState(() {
                                  tempSelectedIcon = iconName;
                                });
                                Future.delayed(Duration(milliseconds: 400));

                                Navigator.pop(
                                  context,
                                  IconPickerResult(icon: icon, name: iconName),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.title.withOpacity(0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.title
                                        : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      icon,
                                      color: isSelected
                                          ? AppColors.title
                                          : AppColors.body,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      iconName,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected
                                            ? AppColors.title
                                            : AppColors.body,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Scrollable icon list
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    return result;
  }
}

class IconPickerResult {
  final String name;
  final IconData icon;

  IconPickerResult({required this.name, required this.icon});
}
