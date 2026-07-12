import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pustakalaya/features/reviews/data/repositories/my_reviews_repository_impl.dart';
import 'package:pustakalaya/features/reviews/domain/entities/my_review_entity.dart';
import 'package:pustakalaya/features/reviews/domain/repositories/my_reviews_repository.dart';

final myReviewsRepositoryProvider = Provider<MyReviewsRepository>(
  (ref) => MyReviewsRepositoryImpl(),
);

final myReviewsProvider = FutureProvider.autoDispose<List<MyReviewEntity>>((
  ref,
) {
  final repo = ref.watch(myReviewsRepositoryProvider);
  return repo.getMyReviews();
});
