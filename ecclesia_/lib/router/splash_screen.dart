import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/ecclesia_logo.dart';

/// Shown while the initial session (auto-login) is being resolved.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const EcclesiaLogo(size: 200)
                .animate()
                .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(.92, .92),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.navy)
                .animate(delay: 350.ms)
                .fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
