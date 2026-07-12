import 'package:pustakalaya/core/network/api_client.dart';
import 'package:pustakalaya/features/support/domain/entities/support_issue_type.dart';
import 'package:pustakalaya/features/support/domain/repositories/support_repository.dart';

class SupportRepositoryImpl implements SupportRepository {
  final ApiClient _client = ApiClient.instance;

  @override
  Future<void> submitRequest({
    required SupportIssueType issueType,
    required String description,
    required String email,
    String? phoneNumber,
  }) async {
    await _client.post(
      '/support',
      body: {
        'issueType': issueType.apiValue,
        'description': description.trim(),
        'email': email.trim(),
        if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
          'phoneNumber': phoneNumber.trim(),
      },
    );
  }
}
