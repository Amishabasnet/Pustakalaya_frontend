import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

class WishlistItem {
  final BookEntity book;
  final DateTime addedAt;
  final int userRating; // 0-5 stars, 0 = unrated

  const WishlistItem({
    required this.book,
    required this.addedAt,
    this.userRating = 0,
  });

  WishlistItem copyWith({int? userRating}) => WishlistItem(
    book: book,
    addedAt: addedAt,
    userRating: userRating ?? this.userRating,
  );
}
