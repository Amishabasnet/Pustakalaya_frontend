import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/features/payment_methods/domain/entities/saved_payment_method.dart';

class SavedPaymentNotifier extends StateNotifier<List<SavedPaymentMethod>> {
  SavedPaymentNotifier()
    : super([
        const SavedPaymentMethod(
          id: 'pm_1',
          type: SavedPaymentType.esewa,
          identifier: '+977 9874563210',
          isDefault: true,
        ),
      ]);

  void add(SavedPaymentMethod method) {
    final shouldBeDefault = state.isEmpty || method.isDefault;
    final updated = shouldBeDefault
        ? state.map((m) => m.copyWith(isDefault: false)).toList()
        : List<SavedPaymentMethod>.from(state);
    state = [...updated, method.copyWith(isDefault: shouldBeDefault)];
  }

  void remove(String id) {
    final wasDefault = state.firstWhere((m) => m.id == id).isDefault;
    final updated = state.where((m) => m.id != id).toList();
    if (wasDefault && updated.isNotEmpty) {
      updated[0] = updated[0].copyWith(isDefault: true);
    }
    state = updated;
  }

  void setDefault(String id) {
    state = state.map((m) => m.copyWith(isDefault: m.id == id)).toList();
  }
}

final savedPaymentProvider =
    StateNotifierProvider<SavedPaymentNotifier, List<SavedPaymentMethod>>(
      (ref) => SavedPaymentNotifier(),
    );
