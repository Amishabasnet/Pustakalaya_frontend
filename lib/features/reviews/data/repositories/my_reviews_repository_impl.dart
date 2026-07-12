import 'package:pustakalaya/core/network/api_client.dart';
import 'package:pustakalaya/features/reviews/domain/entities/my_review_entity.dart';
import 'package:pustakalaya/features/reviews/domain/repositories/my_reviews_repository.dart';

class MyReviewsRepositoryImpl implements MyReviewsRepository {
  final ApiClient _client = ApiClient.instance;

  @override
  Future<List<MyReviewEntity>> getMyReviews() async {
    final body = await _client.get('/reviews/my-reviews');
    final data = body['data'] as Map<String, dynamic>?;
    final list = (data?['reviews'] as List?) ?? [];
    return list
        .map((r) => MyReviewEntity.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
