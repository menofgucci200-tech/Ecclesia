import 'package:flutter/material.dart';

/// The Côte d'Ivoire flag drawn as three vertical bars (orange · white · green),
/// used as the dial-code prefix in the phone field.
class CountryFlagCI extends StatelessWidget {
  const CountryFlagCI({super.key, this.height = 18, this.width = 26});

  final double height;
  final double width;

  static const Color _orange = Color(0xFFF77F00);
  static const Color _green = Color(0xFF009E60);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: height,
        width: width,
        child: Row(
          children: const [
            Expanded(child: ColoredBox(color: _orange)),
            Expanded(child: ColoredBox(color: Colors.white)),
            Expanded(child: ColoredBox(color: _green)),
          ],
        ),
      ),
    );
  }
}
