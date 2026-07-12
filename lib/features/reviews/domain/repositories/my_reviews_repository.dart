import 'package:pustakalaya/features/reviews/domain/entities/my_review_entity.dart';

abstract class MyReviewsRepository {
  Future<List<MyReviewEntity>> getMyReviews();
}
