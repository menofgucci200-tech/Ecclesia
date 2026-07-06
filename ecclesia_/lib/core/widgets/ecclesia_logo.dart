import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Displays the official Ecclesia emblem (arch, cross, community, book,
/// wordmark and tagline) from `assets/images/logo.png`.
/// Falls back to a brand-coloured placeholder if the asset is missing.
class EcclesiaLogo extends StatelessWidget {
  const EcclesiaLogo({super.key, this.size = 180});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _Fallback(size: size),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.church_outlined, size: size * 0.55, color: AppColors.navy),
        const SizedBox(height: 12),
        const Text(
          'ECCLESIA',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppConstants.appTagline.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
