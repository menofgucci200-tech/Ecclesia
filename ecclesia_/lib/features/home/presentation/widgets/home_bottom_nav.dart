import 'package:flutter/material.dart';

import '../theme/home_palette.dart';

/// The 5-tab bottom navigation bar: Accueil · Mouvements · Paiements ·
/// Agenda · Menu. Purely presentational — the parent owns the selected
/// index. "Menu" (index 4) is an action button that opens the end drawer;
/// it never becomes the active tab.
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.activeColor = HomePalette.navy,
    this.avatarUrl,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;

  /// When set, the "Menu" tab shows the faithful's photo instead of a
  /// generic icon.
  final String? avatarUrl;

  static const List<(IconData, String)> _items = [
    (Icons.home_outlined, 'Accueil'),
    (Icons.groups_outlined, 'Mouvements'),
    (Icons.credit_card_outlined, 'Paiements'),
    (Icons.calendar_today_outlined, 'Agenda'),
    (Icons.menu_outlined, 'Menu'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFEEF2F8))),
        boxShadow: [
          BoxShadow(
            color: HomePalette.navy.withValues(alpha: .1),
            blurRadius: 16,
            offset: const Offset(0, -4),
            spreadRadius: -8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: _items[i].$1,
                    label: _items[i].$2,
                    active: i == currentIndex,
                    activeColor: activeColor,
                    // The last tab (Menu) shows the user's avatar when set.
                    avatarUrl: i == _items.length - 1 ? avatarUrl : null,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.active, required this.activeColor, required this.onTap, this.avatarUrl});

  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : HomePalette.textMuted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 42,
            height: 26,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: active && avatarUrl == null ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: activeColor.withValues(alpha: .12), borderRadius: const BorderRadius.all(Radius.circular(100))),
                    ),
                  ),
                ),
                if (avatarUrl != null)
                  Container(
                    width: 24,
                    height: 24,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: active ? activeColor : Colors.transparent, width: 2),
                    ),
                    child: Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(icon, size: 20, color: color),
                    ),
                  )
                else
                  AnimatedScale(
                    scale: active ? 1.08 : 1,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(end: color),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, animatedColor, _) => Icon(icon, size: 20, color: animatedColor),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(fontSize: 9.5, color: color, fontWeight: active ? FontWeight.w700 : FontWeight.w400),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
