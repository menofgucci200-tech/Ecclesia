import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A 4-segment password strength indicator, updated live as the user types.
class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.password});

  final String password;

  int get _score {
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password) || password.length >= 12) score++;
    return score;
  }

  Color get _color {
    return switch (_score) {
      0 || 1 => AppColors.error,
      2 => AppColors.warning,
      3 => AppColors.gold,
      _ => AppColors.success,
    };
  }

  @override
  Widget build(BuildContext context) {
    final score = password.isEmpty ? 0 : _score.clamp(1, 4);

    return Row(
      children: List.generate(4, (index) {
        final filled = index < score;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 3 ? 0 : 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              decoration: BoxDecoration(
                color: filled ? _color : AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        );
      }),
    );
  }
}
