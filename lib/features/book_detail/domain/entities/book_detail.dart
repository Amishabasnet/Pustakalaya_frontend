import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

class BookReview {
  final String reviewerName;
  final String reviewerInitial;
  final int starRating;
  final String comment;

  const BookReview({
    required this.reviewerName,
    required this.reviewerInitial,
    required this.starRating,
    required this.comment,
  });
}

class BookDetail {
  final BookEntity book;
  final double originalPrice;
  final int discountPercent;
  final bool isVerifiedSeller;
  final bool inStock;
  final String description;
  final String returnPolicy;
  final List<BookReview> reviews;
  final bool freeDeliveryAbove;
  final double freeDeliveryThreshold;

  const BookDetail({
    required this.book,
    required this.originalPrice,
    required this.discountPercent,
    this.isVerifiedSeller = true,
    this.inStock = true,
    required this.description,
    required this.returnPolicy,
    required this.reviews,
    this.freeDeliveryAbove = true,
    this.freeDeliveryThreshold = 1500,
  });
}
