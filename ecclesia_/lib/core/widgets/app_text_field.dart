import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// A labelled text field with the shared Ecclesia styling. The uppercase label
/// sits above a themed [TextFormField]; on focus, a soft glow and a subtle
/// scale animate the field into place.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.labelTrailing,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final Widget? labelTrailing;
  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus != _focused) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: Theme.of(context).textTheme.labelMedium),
            if (widget.labelTrailing != null) ...[
              const SizedBox(width: AppDimens.sm),
              widget.labelTrailing!,
            ],
          ],
        ),
        const SizedBox(height: AppDimens.sm),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
            boxShadow: _focused
                ? [BoxShadow(color: AppColors.navy.withValues(alpha: .16), blurRadius: 14, offset: const Offset(0, 4))]
                : const [],
          ),
          child: AnimatedScale(
            scale: _focused ? 1.01 : 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: widget.obscureText,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              validator: widget.validator,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onSubmitted,
              inputFormatters: widget.inputFormatters,
              autofillHints: widget.autofillHints,
              textCapitalization: widget.textCapitalization,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
                suffixIcon: widget.suffix,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
