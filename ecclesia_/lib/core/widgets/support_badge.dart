import 'package:flutter/material.dart';

import 'help_button.dart';
import 'support_contact_sheet.dart';

/// The support badge ("Besoin d'aide ?") that opens the support contact sheet.
/// Thin wrapper over [HelpButton] wired to the default support action.
class SupportBadge extends StatelessWidget {
  const SupportBadge({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return HelpButton(
      onPressed: onPressed ?? () => showSupportContactSheet(context),
    );
  }
}
