/// A payment type advertised by the API (mass request, quête, don…).
class PaymentTypeOption {
  const PaymentTypeOption({
    required this.type,
    required this.label,
    required this.description,
    required this.isMassRequest,
    required this.isAutre,
    required this.suggestedAmounts,
    required this.dateLabel,
    this.fixedAmount,
    this.amountLocked = false,
  });

  final String type;
  final String label;
  final String description;
  final bool isMassRequest;
  final bool isAutre;
  final List<int> suggestedAmounts;
  final String dateLabel;

  /// The amount set by the parish for this type, if any.
  final int? fixedAmount;

  /// Whether [fixedAmount] must be paid exactly (the amount field is
  /// read-only in the form).
  final bool amountLocked;

  factory PaymentTypeOption.fromJson(Map<String, dynamic> json) => PaymentTypeOption(
        type: json['type'] as String,
        label: json['label'] as String? ?? '',
        description: json['description'] as String? ?? '',
        isMassRequest: json['is_mass_request'] as bool? ?? false,
        isAutre: json['is_autre'] as bool? ?? false,
        suggestedAmounts: ((json['suggested_amounts'] as List<dynamic>?) ?? const [])
            .map((e) => (e as num).toInt())
            .toList(),
        dateLabel: json['date_label'] as String? ?? 'Date (optionnel)',
        fixedAmount: (json['fixed_amount'] as num?)?.toInt(),
        amountLocked: json['amount_locked'] as bool? ?? false,
      );
}

class MassIntentionTypeOption {
  const MassIntentionTypeOption({required this.value, required this.label});

  final String value;
  final String label;

  factory MassIntentionTypeOption.fromJson(Map<String, dynamic> json) =>
      MassIntentionTypeOption(value: json['value'] as String, label: json['label'] as String? ?? '');
}

/// The full payments catalogue returned by `GET /payments/options`.
class PaymentOptions {
  const PaymentOptions({
    required this.configured,
    required this.currency,
    required this.types,
    required this.massIntentionTypes,
    this.parishName,
  });

  final bool configured;
  final String currency;
  final String? parishName;
  final List<PaymentTypeOption> types;
  final List<MassIntentionTypeOption> massIntentionTypes;

  factory PaymentOptions.fromJson(Map<String, dynamic> json) => PaymentOptions(
        configured: json['configured'] as bool? ?? false,
        currency: json['currency'] as String? ?? 'XOF',
        parishName: (json['parish'] as Map<String, dynamic>?)?['name'] as String?,
        types: ((json['types'] as List<dynamic>?) ?? const [])
            .map((e) => PaymentTypeOption.fromJson(e as Map<String, dynamic>))
            .toList(),
        massIntentionTypes: ((json['mass_intention_types'] as List<dynamic>?) ?? const [])
            .map((e) => MassIntentionTypeOption.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// A payment as stored server-side (history + status polling).
class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.reference,
    required this.type,
    required this.typeLabel,
    required this.label,
    required this.amount,
    required this.status,
    required this.statusLabel,
    this.createdAt,
    this.paidAt,
  });

  final int id;
  final String reference;
  final String type;
  final String typeLabel;
  final String label;
  final int amount;
  final String status; // pending | paid | failed | cancelled | expired
  final String statusLabel;
  final String? createdAt;
  final String? paidAt;

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isFinal => status != 'pending';

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        id: json['id'] as int,
        reference: json['reference'] as String,
        type: json['type'] as String? ?? '',
        typeLabel: json['type_label'] as String? ?? '',
        label: json['label'] as String? ?? '',
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? 'pending',
        statusLabel: json['status_label'] as String? ?? '',
        createdAt: json['created_at'] as String?,
        paidAt: json['paid_at'] as String?,
      );
}

/// The result of initiating a payment: the reference to poll + the hosted URL.
class PaymentInit {
  const PaymentInit({required this.reference, required this.paymentUrl});
  final String reference;
  final String paymentUrl;
}
