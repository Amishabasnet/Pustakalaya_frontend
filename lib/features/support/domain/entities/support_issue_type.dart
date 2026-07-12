import 'package:flutter/material.dart';

/// Mirrors the backend's `VALID_ISSUE_TYPES` in support.service.js.
enum SupportIssueType {
  damagedBook,
  incorrectBook,
  delayedDelivery,
  paymentProblem;

  String get displayName => switch (this) {
    SupportIssueType.damagedBook => 'Damaged Book',
    SupportIssueType.incorrectBook => 'Incorrect Book Received',
    SupportIssueType.delayedDelivery => 'Delayed Delivery',
    SupportIssueType.paymentProblem => 'Payment Problem',
  };

  /// Value the backend expects in the `issueType` field.
  String get apiValue => switch (this) {
    SupportIssueType.damagedBook => 'damaged_book',
    SupportIssueType.incorrectBook => 'incorrect_book',
    SupportIssueType.delayedDelivery => 'delayed_delivery',
    SupportIssueType.paymentProblem => 'payment_problem',
  };

  IconData get icon => switch (this) {
    SupportIssueType.damagedBook => Icons.menu_book_outlined,
    SupportIssueType.incorrectBook => Icons.error_outline_rounded,
    SupportIssueType.delayedDelivery => Icons.local_shipping_outlined,
    SupportIssueType.paymentProblem => Icons.payment_outlined,
  };
}
