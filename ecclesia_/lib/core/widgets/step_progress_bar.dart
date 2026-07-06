import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The segmented step indicator used across the onboarding / registration flow.
///
/// Segments before the current step are gold (done), the current one is navy
/// (active), and the remaining are grey (upcoming).
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  }) : assert(currentStep >= 1 && currentStep <= totalSteps);

  final int totalSteps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final Color color;
        if (index < currentStep - 1) {
          color = AppColors.gold;
        } else if (index == currentStep - 1) {
          color = AppColors.navy;
        } else {
          color = AppColors.border;
        }

        return Padding(
          padding: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 6,
            width: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}
