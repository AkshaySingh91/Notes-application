import 'package:flutter/material.dart';
import 'package:my_learning_app/utilities/AppColors.dart';
import 'dart:math' show pi;

class AnimatedFloatingActionButton extends StatefulWidget {
  final VoidCallback onAddTextNoteClick;
  final VoidCallback onAddVoiceNoteClick;
  final AnimationController animationController;

  const AnimatedFloatingActionButton({
    super.key,
    required this.onAddTextNoteClick,
    required this.onAddVoiceNoteClick,
    required this.animationController,
  });

  @override
  State<AnimatedFloatingActionButton> createState() =>
      _AnimatedFloatingActionButtonState();
}

class _AnimatedFloatingActionButtonState
    extends State<AnimatedFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _rotateFab;
  late Animation<double> _translateTextIcon;
  late Animation<double> _translateVoiceIcon;
  late Animation<double> _expandTextWidth;
  late Animation<double> _expandVoiceWidth;

  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();

    _animationController = widget.animationController;

    // 1. Rotate FAB (0% to 40% of time)
    _rotateFab = Tween<double>(begin: 0, end: pi / 4).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // 2. Move Buttons Up (Staggered)
    // Voice Icon moves up first (0% to 50%)
    _translateVoiceIcon = Tween<double>(begin: 0, end: 60).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // Text Icon moves up further (0% to 60%)
    _translateTextIcon = Tween<double>(begin: 0, end: 120).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // 3. Expand Labels (After buttons have moved up)
    // Expand Voice Label (40% to 80%)
    _expandVoiceWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Expand Text Label (50% to 90%)
    _expandTextWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Removed the fixed width SizedBox constraints
    return SizedBox(
      height: 200, // Sufficient height for expansion upward
      // The width is unconstrained so it can grow to the left
      child: Stack(
        alignment: Alignment.bottomRight, // Anchor everything to the right
        clipBehavior: Clip.none,
        children: [
          // --- Text Note Button ---
          _buildOptionButton(
            translation: _translateTextIcon,
            expandAnimation: _expandTextWidth,
            label: "Text Note",
            icon: Icons.text_fields_rounded,
            color: AppColors.primary,
            onClick: () {
              _animationController.reset();
              widget.onAddTextNoteClick();
            },
          ),

          // --- Voice Note Button ---
          _buildOptionButton(
            translation: _translateVoiceIcon,
            expandAnimation: _expandVoiceWidth,
            label: "Voice Note",
            icon: Icons.keyboard_voice_outlined,
            color: AppColors.secondary,
            onClick: () {
              _animationController.reset();
              widget.onAddVoiceNoteClick();
            },
          ),

          // --- Main FAB ---
          Padding(
            padding: const EdgeInsets.all(4.0), // mimic standard FAB padding
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _toggleFab,
              child: AnimatedBuilder(
                animation: _rotateFab,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateFab.value,
                    child: const Icon(
                      Icons.add,
                      fontWeight: FontWeight.bold,
                      size: 24,
                      color: AppColors.black,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required Animation<double> translation,
    required Animation<double> expandAnimation,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onClick,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([translation, expandAnimation]),
      builder: (context, child) {
        // Hide completely if not translated up yet to prevent blocking hits
        if (translation.value == 0) return const SizedBox.shrink();

        return Transform.translate(
          offset: Offset(0, -translation.value),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(50),
            ),
            child: GestureDetector(
              onTap: onClick,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text expands horizontally
                  SizeTransition(
                    sizeFactor: expandAnimation,
                    axis: Axis.horizontal,
                    axisAlignment: 1.0, // Anchor to the right end
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.white,
                          ),
                          // Ensure text doesn't wrap during animation
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    icon,
                    fontWeight: FontWeight.bold,
                    size: 24,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
