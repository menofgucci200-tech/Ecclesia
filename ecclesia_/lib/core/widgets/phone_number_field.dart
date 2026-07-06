import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/phone_input_formatter.dart';
import 'country_flag_ci.dart';

/// The phone input used across the auth flow: a fixed Côte d'Ivoire dial-code
/// prefix (flag + +225) followed by the national number, grouped by pairs as
/// the user types, with a trailing phone icon (design screen 2).
class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.autofocus = false,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool autofocus;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TÉLÉPHONE', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppDimens.sm),
        TextFormField(
          controller: controller,
          enabled: enabled,
          autofocus: autofocus,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            PhoneInputFormatter(),
          ],
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 1.2,
          ),
          decoration: InputDecoration(
            errorText: errorText,
            hintText: '01 XX XX XX XX',
            hintStyle: const TextStyle(
              color: AppColors.textHint,
              fontSize: 17,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.lg,
              vertical: 18,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: AppDimens.lg, right: AppDimens.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CountryFlagCI(),
                  const SizedBox(width: AppDimens.sm),
                  Text(
                    AppConstants.defaultDialCode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Container(height: 24, width: 1.2, color: AppColors.border),
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: AppDimens.lg),
              child: Icon(Icons.phone_outlined, color: AppColors.textHint, size: 22),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ],
    );
  }
}
