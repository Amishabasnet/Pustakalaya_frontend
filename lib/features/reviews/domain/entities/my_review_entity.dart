import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

class MyReviewEntity {
  final String id;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final BookEntity book;

  const MyReviewEntity({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.book,
  });

  /// Backend shape (`MyReviewDTO`):
  /// `{ _id, rating, comment, createdAt, book: BookListItemDTO }`
  factory MyReviewEntity.fromJson(Map<String, dynamic> json) {
    final bookJson = json['book'] as Map<String, dynamic>? ?? const {};
    final createdAtStr = json['createdAt'] as String?;
    return MyReviewEntity(
      id: (json['_id'] ?? '').toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: (json['comment'] ?? '').toString(),
      createdAt: createdAtStr != null
          ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
          : DateTime.now(),
      book: BookEntity.fromJson(bookJson),
    );
  }
}
