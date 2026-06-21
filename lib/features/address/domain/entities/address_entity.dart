import 'package:flutter/material.dart';

enum AddressLabel { home, work, other }

extension AddressLabelX on AddressLabel {
  String get displayName {
    switch (this) {
      case AddressLabel.home:
        return 'Home';
      case AddressLabel.work:
        return 'Work';
      case AddressLabel.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case AddressLabel.home:
        return Icons.home_rounded;
      case AddressLabel.work:
        return Icons.work_rounded;
      case AddressLabel.other:
        return Icons.location_on_rounded;
    }
  }
}

class AddressEntity {
  final String id;
  final AddressLabel label;
  final String recipientName;
  final String phoneNumber;
  final String addressLine;
  final String city;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phoneNumber,
    required this.addressLine,
    required this.city,
    this.isDefault = false,
  });

  AddressEntity copyWith({
    AddressLabel? label,
    String? recipientName,
    String? phoneNumber,
    String? addressLine,
    String? city,
    bool? isDefault,
  }) {
    return AddressEntity(
      id: id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get fullAddress => '$addressLine, $city';
}
