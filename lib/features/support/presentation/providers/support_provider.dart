import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/core/network/api_exception.dart';
import 'package:pustakalaya/features/support/data/repositories/support_repository_impl.dart';
import 'package:pustakalaya/features/support/domain/entities/support_issue_type.dart';
import 'package:pustakalaya/features/support/domain/repositories/support_repository.dart';

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => SupportRepositoryImpl(),
);

class SupportSubmitState {
  final bool isSubmitting;
  final bool success;
  final String? error;

  const SupportSubmitState({
    this.isSubmitting = false,
    this.success = false,
    this.error,
  });

  SupportSubmitState copyWith({
    bool? isSubmitting,
    bool? success,
    String? error,
  }) => SupportSubmitState(
    isSubmitting: isSubmitting ?? this.isSubmitting,
    success: success ?? this.success,
    error: error,
  );
}

class SupportSubmitNotifier extends StateNotifier<SupportSubmitState> {
  final SupportRepository _repo;

  SupportSubmitNotifier(this._repo) : super(const SupportSubmitState());

  Future<bool> submit({
    required SupportIssueType issueType,
    required String description,
    required String email,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null, success: false);
    try {
      await _repo.submitRequest(
        issueType: issueType,
        description: description,
        email: email,
        phoneNumber: phoneNumber,
      );
      state = state.copyWith(isSubmitting: false, success: true);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.message);
      return false;
    }
  }

  void reset() => state = const SupportSubmitState();
}

final supportSubmitProvider =
    StateNotifierProvider.autoDispose<
      SupportSubmitNotifier,
      SupportSubmitState
    >((ref) => SupportSubmitNotifier(ref.watch(supportRepositoryProvider)));
