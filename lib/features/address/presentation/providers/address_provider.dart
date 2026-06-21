import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/features/address/domain/entities/address_entity.dart';

class AddressNotifier extends StateNotifier<List<AddressEntity>> {
  AddressNotifier()
    : super([
        const AddressEntity(
          id: 'addr_1',
          label: AddressLabel.home,
          recipientName: 'Amisha Basnet',
          phoneNumber: '+977 9874563210',
          addressLine: 'Baneshwor, Ward No. 10',
          city: 'Kathmandu',
          isDefault: true,
        ),
      ]);

  void add(AddressEntity address) {
    // First address added is automatically default.
    final shouldBeDefault = state.isEmpty || address.isDefault;
    final updated = shouldBeDefault
        ? state.map((a) => a.copyWith(isDefault: false)).toList()
        : List<AddressEntity>.from(state);
    state = [...updated, address.copyWith(isDefault: shouldBeDefault)];
  }

  void update(AddressEntity address) {
    state = state.map((a) => a.id == address.id ? address : a).toList();
  }

  void remove(String id) {
    final wasDefault = state.firstWhere((a) => a.id == id).isDefault;
    final updated = state.where((a) => a.id != id).toList();
    if (wasDefault && updated.isNotEmpty) {
      updated[0] = updated[0].copyWith(isDefault: true);
    }
    state = updated;
  }

  void setDefault(String id) {
    state = state.map((a) => a.copyWith(isDefault: a.id == id)).toList();
  }
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, List<AddressEntity>>(
      (ref) => AddressNotifier(),
    );

/// Convenience: the address that should be pre-filled at Checkout.
final defaultAddressProvider = Provider<AddressEntity?>((ref) {
  final addresses = ref.watch(addressProvider);
  if (addresses.isEmpty) return null;
  return addresses.firstWhere(
    (a) => a.isDefault,
    orElse: () => addresses.first,
  );
});
