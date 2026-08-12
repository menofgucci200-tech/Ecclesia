import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/home_palette.dart';

/// The 5-tab bottom navigation bar: Accueil · Mouvements · Paiements ·
/// Agenda · Menu. Purely presentational — the parent owns the selected
/// index. "Menu" (index 4) is an action button that opens the end drawer;
/// it never becomes the active tab, so the sliding indicator ignores it.
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

  static const List<(IconData, IconData, String)> _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Accueil'),
    (Icons.groups_outlined, Icons.groups_rounded, 'Mouvements'),
    (Icons.credit_card_outlined, Icons.credit_card_rounded, 'Paiements'),
    (Icons.calendar_today_outlined, Icons.calendar_month_rounded, 'Agenda'),
    (Icons.menu_outlined, Icons.menu_rounded, 'Menu'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: HomePalette.navy.withValues(alpha: .14),
            blurRadius: 28,
            offset: const Offset(0, -8),
            spreadRadius: -10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final slotWidth = constraints.maxWidth / _items.length;
                // The "Menu" tab (last item) never becomes active — no slot
                // to slide the indicator into.
                final showIndicator = currentIndex < _items.length - 1;
                const pillWidth = 56.0;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      left: slotWidth * currentIndex + (slotWidth - pillWidth) / 2,
                      top: 2,
                      width: pillWidth,
                      height: 40,
                      child: AnimatedOpacity(
                        opacity: showIndicator ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [activeColor.withValues(alpha: .16), activeColor.withValues(alpha: .09)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < _items.length; i++)
                          Expanded(
                            child: _NavItem(
                              icon: _items[i].$1,
                              activeIcon: _items[i].$2,
                              label: _items[i].$3,
                              active: i == currentIndex,
                              activeColor: activeColor,
                              // The last tab (Menu) shows the user's avatar when set.
                              avatarUrl: i == _items.length - 1 ? avatarUrl : null,
                              onTap: () => onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
    this.avatarUrl,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  final String? avatarUrl;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.active ? widget.activeColor : HomePalette.textMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 42,
              height: 26,
              child: Center(
                child: widget.avatarUrl != null
                    ? Container(
                        width: 24,
                        height: 24,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: widget.active ? widget.activeColor : Colors.transparent, width: 2),
                        ),
                        child: Image.network(
                          widget.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(widget.icon, size: 20, color: color),
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          widget.active ? widget.activeIcon : widget.icon,
                          key: ValueKey(widget.active),
                          size: 21,
                          color: color,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(fontSize: 9.5, color: color, fontWeight: widget.active ? FontWeight.w700 : FontWeight.w400),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }
}
