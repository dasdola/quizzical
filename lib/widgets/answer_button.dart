import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

enum AnswerState {
  /// Not answered yet - tappable.
  idle,

  /// Question already answered - this option is not the correct/chosen one.
  locked,

  /// The correct option (shown after answering or timing out).
  correct,

  /// The option the user chose and got wrong.
  incorrect,
}

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final AnswerState state;

  /// Null disables the button (after an answer has been given).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color background = Colors.white;
    Color borderColor = AppColors.border;
    Color textColor = AppColors.ink;
    Color iconColor = AppColors.muted;
    IconData icon = Icons.radio_button_unchecked_rounded;
    String status = '';

    switch (state) {
      case AnswerState.idle:
        break;
      case AnswerState.locked:
        textColor = AppColors.muted;
        break;
      case AnswerState.correct:
        background = AppColors.correct;
        borderColor = AppColors.correctDark;
        iconColor = AppColors.ink;
        icon = Icons.check_circle_rounded;
        status = ', correct answer';
        break;
      case AnswerState.incorrect:
        background = AppColors.incorrect;
        borderColor = AppColors.incorrectDark;
        iconColor = AppColors.ink;
        icon = Icons.cancel_rounded;
        status = ', your answer, incorrect';
        break;
    }

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: '$label$status',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(icon, color: iconColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
