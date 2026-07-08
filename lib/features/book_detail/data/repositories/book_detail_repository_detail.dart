import 'package:pustakalaya/core/network/api_client.dart';
import 'package:pustakalaya/core/network/api_exception.dart';
import 'package:pustakalaya/features/book_detail/domain/entities/book_detail.dart';
import 'package:pustakalaya/features/book_detail/domain/repositories/book_detail_repository.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

class BookDetailRepositoryImpl implements BookDetailRepository {
  final ApiClient _client = ApiClient.instance;

  @override
  Future<BookDetail> getBookDetail(String bookId) async {
    final body = await _client.get('/books/$bookId');
    final data = body['data'] as Map<String, dynamic>;

    final book = BookEntity.fromJson(data);
    final originalPrice =
        (data['originalPrice'] as num?)?.toDouble() ?? book.price;
    final effectiveDiscount = (data['effectiveDiscount'] as num?)?.toInt() ?? 0;

    final reviewsJson = (data['recentReviews'] as List?) ?? [];
    final reviews = reviewsJson.map((r) {
      final map = r as Map<String, dynamic>;
      final userMap = map['user'] as Map<String, dynamic>?;
      final name = (userMap?['fullName'] as String?)?.trim();
      final displayName = (name == null || name.isEmpty) ? 'Reader' : name;
      return BookReview(
        reviewerName: displayName,
        reviewerInitial: displayName[0].toUpperCase(),
        starRating: (map['rating'] as num?)?.toInt() ?? 0,
        comment: (map['comment'] ?? '').toString(),
      );
    }).toList();

    return BookDetail(
      book: book,
      originalPrice: originalPrice,
      discountPercent: effectiveDiscount,
      isVerifiedSeller: data['isVerified'] as bool? ?? false,
      inStock:
          (data['stock'] as num?)?.toInt() != null &&
          (data['stock'] as num).toInt() > 0,
      description: (data['description'] ?? '').toString(),
      returnPolicy: (data['returnPolicy'] ?? '').toString(),
      reviews: reviews,
      freeDeliveryAbove: true,
      freeDeliveryThreshold:
          (data['freeDeliveryOver'] as num?)?.toDouble() ?? 1500,
    );
  }

  @override
  Future<void> submitReview(
    String bookId, {
    required int rating,
    String? comment,
  }) async {
    final body = {'rating': rating, if (comment != null) 'comment': comment};
    try {
      await _client.post('/books/$bookId/reviews', body: body);
    } on ApiException catch (e) {
      // Already reviewed this book — update the existing review instead.
      if (e.statusCode == 409) {
        await _client.put('/books/$bookId/reviews', body: body);
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteMyReview(String bookId) async {
    await _client.delete('/books/$bookId/reviews');
  }
}
