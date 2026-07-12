import 'package:pustakalaya/features/support/domain/entities/support_issue_type.dart';

abstract class SupportRepository {
  /// Submits a return/support request. Throws [ApiException] on failure.
  Future<void> submitRequest({
    required SupportIssueType issueType,
    required String description,
    required String email,
    String? phoneNumber,
  });
}
