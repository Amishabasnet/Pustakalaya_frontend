import 'package:pustakalaya/features/book_detail/domain/entities/book_detail.dart';

abstract class BookDetailRepository {
  Future<BookDetail> getBookDetail(String bookId);

  /// Submits the current user's review — creates it if they haven't
  /// reviewed this book yet, or updates their existing one otherwise.
  Future<void> submitReview(
    String bookId, {
    required int rating,
    String? comment,
  });

  Future<void> deleteMyReview(String bookId);
}
