import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/ecclesia_logo.dart';

/// Shown while the initial session (auto-login) is being resolved.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EcclesiaLogo(size: 200),
            SizedBox(height: 32),
            CircularProgressIndicator(color: AppColors.navy),
          ],
        ),
      ),
    );
  }
}
