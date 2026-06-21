import 'package:flutter/material.dart';

enum SavedPaymentType { card, esewa, khalti }

extension SavedPaymentTypeX on SavedPaymentType {
  String get displayName {
    switch (this) {
      case SavedPaymentType.card:
        return 'Card';
      case SavedPaymentType.esewa:
        return 'eSewa';
      case SavedPaymentType.khalti:
        return 'Khalti';
    }
  }

  IconData get icon {
    switch (this) {
      case SavedPaymentType.card:
        return Icons.credit_card_rounded;
      case SavedPaymentType.esewa:
        return Icons.smartphone_rounded;
      case SavedPaymentType.khalti:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color get color {
    switch (this) {
      case SavedPaymentType.card:
        return const Color(0xFF2E5BA8);
      case SavedPaymentType.esewa:
        return const Color(0xFF60BB46);
      case SavedPaymentType.khalti:
        return const Color(0xFF5C2D91);
    }
  }
}

class SavedPaymentMethod {
  final String id;
  final SavedPaymentType type;

  /// For cards: last 4 digits. For wallets: linked phone number.
  final String identifier;

  /// Cards only — cardholder name.
  final String? holderName;

  /// Cards only — "MM/YY".
  final String? expiry;

  final bool isDefault;

  const SavedPaymentMethod({
    required this.id,
    required this.type,
    required this.identifier,
    this.holderName,
    this.expiry,
    this.isDefault = false,
  });

  SavedPaymentMethod copyWith({bool? isDefault}) {
    return SavedPaymentMethod(
      id: id,
      type: type,
      identifier: identifier,
      holderName: holderName,
      expiry: expiry,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get maskedLabel {
    switch (type) {
      case SavedPaymentType.card:
        return '•••• •••• •••• $identifier';
      case SavedPaymentType.esewa:
      case SavedPaymentType.khalti:
        return identifier;
    }
  }
}
