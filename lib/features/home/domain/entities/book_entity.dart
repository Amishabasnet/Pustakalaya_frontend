class BookEntity {
  final String id;
  final String title;
  final String author;
  final double price;
  final double rating;
  final int reviewCount;
  final String genre;
  final String coverColor; 
  final bool isVerified;
  final bool isNew;

  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.genre,
    required this.coverColor,
    this.isVerified = true,
    this.isNew = false,
  });
}
