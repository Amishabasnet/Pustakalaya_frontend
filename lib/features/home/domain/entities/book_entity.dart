import 'package:pustakalaya/core/network/app_config.dart';

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
  final String? coverImageUrl;
  final double? originalPrice;
  final int stock;

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
    this.coverImageUrl,
    this.originalPrice,
    this.stock = 0,
  });

  /// Backend shape (`BookListItemDTO` / `BookDetailDTO`):
  /// `{ _id, title, author, price, originalPrice, discountPercent,
  ///    coverImage, isVerified, rating, totalReviews, genre, stock, createdAt }`
  factory BookEntity.fromJson(Map<String, dynamic> json) {
    final genreField = json['genre'];
    final genreLabel = genreField is List
        ? genreField.join(', ')
        : (genreField ?? '').toString();

    // Deterministic placeholder color derived from the title, used when
    // there's no real cover image (or while it's loading).
    final hash = (json['title'] ?? '').toString().hashCode;
    const palette = [
      '3B5998',
      'C0392B',
      '2E86AB',
      '1A6B3C',
      '5D3FD3',
      'E8602C',
      '8E44AD',
      '16A085',
      'D35400',
      '2C3E50',
    ];
    final color = palette[hash.abs() % palette.length];

    return BookEntity(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      author: (json['author'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['totalReviews'] as num?)?.toInt() ?? 0,
      genre: genreLabel.isEmpty ? 'General' : genreLabel,
      coverColor: '#$color',
      isVerified: json['isVerified'] as bool? ?? false,
      coverImageUrl: AppConfig.resolveAssetUrl(json['coverImage'] as String?),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }
}
