import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_exception.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../data/payment_models.dart';
import '../data/payment_providers.dart';
import 'payment_status_screen.dart';

/// A functional payment form for one payment type. Collects the amount (and,
/// for mass requests, the intention — or, for "Autre", a title/motif), then
/// opens the CinetPay checkout.
class PaymentFormScreen extends ConsumerStatefulWidget {
  const PaymentFormScreen({super.key, required this.option, required this.options});

  final PaymentTypeOption option;
  final PaymentOptions options;

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _amountController = TextEditingController();
  final _intentionController = TextEditingController();
  final _noteController = TextEditingController();
  final _titleController = TextEditingController();
  String? _intentionType;
  DateTime? _massDate;
  bool _submitting = false;

  bool get _hasDateField => !widget.option.isAutre;

  @override
  void initState() {
    super.initState();
    _intentionType = widget.options.massIntentionTypes.isNotEmpty
        ? widget.options.massIntentionTypes.first.value
        : null;
    // A parish-fixed amount is prefilled and locked; otherwise the field
    // starts empty so the faithful enters whatever they want.
    if (widget.option.fixedAmount != null) {
      _amountController.text = '${widget.option.fixedAmount}';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _intentionController.dispose();
    _noteController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  String _fmt(int v) => v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _massDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _massDate = picked);
  }

  Future<void> _submit() async {
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount < 100) {
      _error('Montant minimum : 100 F.');
      return;
    }
    if (widget.option.isMassRequest && _intentionController.text.trim().isEmpty) {
      _error('Veuillez préciser l\'intention de la messe.');
      return;
    }
    if (widget.option.isAutre && _titleController.text.trim().isEmpty) {
      _error('Veuillez préciser le motif du paiement.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final init = await ref.read(paymentDataSourceProvider).create(
            type: widget.option.type,
            amount: amount,
            note: _noteController.text.trim(),
            intentionType: widget.option.isMassRequest ? _intentionType : null,
            intention: widget.option.isMassRequest ? _intentionController.text.trim() : null,
            title: widget.option.isAutre ? _titleController.text.trim() : null,
            date: (_hasDateField && _massDate != null)
                ? '${_massDate!.year.toString().padLeft(4, '0')}-${_massDate!.month.toString().padLeft(2, '0')}-${_massDate!.day.toString().padLeft(2, '0')}'
                : null,
          );
      if (!mounted) return;

      // Open the hosted CinetPay page, then follow the status.
      await launchUrl(Uri.parse(init.paymentUrl), mode: LaunchMode.externalApplication);
      if (!mounted) return;

      final paid = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => PaymentStatusScreen(reference: init.reference, paymentUrl: init.paymentUrl)),
      );
      ref.invalidate(myPaymentsProvider);
      if (mounted && (paid ?? false)) Navigator.of(context).pop();
    } on ApiException catch (e) {
      _error(e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _error(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final option = widget.option;
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    final locked = option.amountLocked;

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(option.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
        children: [
          Text(option.description, style: const TextStyle(fontSize: 14, color: HomePalette.textBody, height: 1.5))
              .animate()
              .fadeIn(duration: 260.ms),
          const SizedBox(height: 20),

          if (option.isAutre) ...[
            _label('Motif du paiement')
                .animate()
                .fadeIn(duration: 260.ms, delay: 40.ms),
            _card(
              child: TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Ex. Réparation toiture, cierge…'),
              ),
            ).animate().fadeIn(duration: 260.ms, delay: 40.ms).slideY(begin: .04, end: 0, duration: 260.ms, delay: 40.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 16),
          ],

          if (option.isMassRequest) ...[
            _label('Type d\'intention').animate().fadeIn(duration: 260.ms, delay: 40.ms),
            _card(
              child: DropdownButtonFormField<String>(
                initialValue: _intentionType,
                isExpanded: true,
                decoration: const InputDecoration(border: InputBorder.none),
                items: widget.options.massIntentionTypes
                    .map((t) => DropdownMenuItem(value: t.value, child: Text(t.label)))
                    .toList(),
                onChanged: (v) => setState(() => _intentionType = v),
              ),
            ).animate().fadeIn(duration: 260.ms, delay: 40.ms).slideY(begin: .04, end: 0, duration: 260.ms, delay: 40.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 16),
            _label('Intention (pour qui / quoi)').animate().fadeIn(duration: 260.ms, delay: 80.ms),
            _card(
              child: TextField(
                controller: _intentionController,
                maxLines: 2,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Ex. Repos de l\'âme de…'),
              ),
            ).animate().fadeIn(duration: 260.ms, delay: 80.ms).slideY(begin: .04, end: 0, duration: 260.ms, delay: 80.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 16),
          ],

          // Optional date — every type except "Autre" (mass date, the Sunday
          // of a quête, a célébration…).
          if (_hasDateField) ...[
            _label(option.dateLabel).animate().fadeIn(duration: 260.ms, delay: 100.ms),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: _card(
                child: Row(
                  children: [
                    const Icon(Icons.event_outlined, size: 20, color: HomePalette.navy),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _massDate == null
                            ? 'Choisir une date'
                            : '${_massDate!.day.toString().padLeft(2, '0')}/${_massDate!.month.toString().padLeft(2, '0')}/${_massDate!.year}',
                        style: TextStyle(color: _massDate == null ? HomePalette.textMuted : HomePalette.navy, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (_massDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _massDate = null),
                        child: const Icon(Icons.close, size: 18, color: HomePalette.textMuted),
                      ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 260.ms, delay: 100.ms).slideY(begin: .04, end: 0, duration: 260.ms, delay: 100.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 16),
          ],

          Row(
            children: [
              _label('Montant (F CFA)'),
              if (locked) ...[
                const SizedBox(width: 8),
                _lockedBadge(),
              ],
            ],
          ).animate().fadeIn(duration: 260.ms, delay: 120.ms),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: locked ? const Color(0xFFF3F6FA) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: locked ? HomePalette.navy.withValues(alpha: .25) : HomePalette.cardBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: TextField(
              controller: _amountController,
              enabled: !locked,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: locked ? HomePalette.navy.withValues(alpha: .7) : HomePalette.navy,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                suffixIcon: locked ? const Icon(Icons.lock_outline_rounded, size: 18, color: HomePalette.navy) : null,
              ),
            ),
          ).animate().fadeIn(duration: 260.ms, delay: 120.ms).slideY(begin: .04, end: 0, duration: 260.ms, delay: 120.ms, curve: Curves.easeOutCubic),
          if (locked) ...[
            const SizedBox(height: 6),
            Text(
              'Montant fixé par votre paroisse — non modifiable.',
              style: const TextStyle(fontSize: 11.5, color: HomePalette.textMuted),
            ).animate().fadeIn(duration: 220.ms, delay: 140.ms),
          ],
          if (!locked && option.suggestedAmounts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (i, v) in option.suggestedAmounts.indexed)
                  ActionChip(
                    label: Text('${_fmt(v)} F'),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: HomePalette.cardBorder),
                    onPressed: () => setState(() => _amountController.text = '$v'),
                  ).animate().fadeIn(duration: 220.ms, delay: (150 + i * 40).ms).scaleXY(begin: .9, end: 1, duration: 220.ms, delay: (150 + i * 40).ms, curve: Curves.easeOutBack),
              ],
            ),
          ],

          const SizedBox(height: 16),
          _label('Note (optionnel)').animate().fadeIn(duration: 260.ms, delay: 160.ms),
          _card(
            child: TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Un mot pour la paroisse…'),
            ),
          ).animate().fadeIn(duration: 260.ms, delay: 160.ms).slideY(begin: .04, end: 0, duration: 260.ms, delay: 160.ms, curve: Curves.easeOutCubic),

          if (!widget.options.configured) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE9CE8A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF8A6D1B), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Votre paroisse n\'a pas encore activé les paiements en ligne.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF8A6D1B)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: HomePalette.navy, padding: const EdgeInsets.symmetric(vertical: 15)),
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.lock_outline, size: 18),
              label: Text(
                _submitting ? 'Traitement…' : (amount >= 100 ? 'Payer ${_fmt(amount)} F' : 'Payer'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 2),
        child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: HomePalette.textBody)),
      );

  Widget _lockedBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: HomePalette.navy.withValues(alpha: .08), borderRadius: BorderRadius.circular(100)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 11, color: HomePalette.navy),
            SizedBox(width: 3),
            Text('Fixé par la paroisse', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: HomePalette.navy)),
          ],
        ),
      );

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HomePalette.cardBorder),
        ),
        child: child,
      );
}
