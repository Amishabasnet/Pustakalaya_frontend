import 'package:flutter/material.dart';

/// Renders a book's real cover photo (`coverImageUrl`) when one exists,
/// and falls back to the given illustrated placeholder otherwise — or if
/// the network image fails to load or is still loading.
///
/// Every card/tile that shows a book cover should go through this widget
/// so that covers uploaded from the admin panel actually show up across
/// the whole app, not just on the home screen.
class BookCoverImage extends StatelessWidget {
  final String? imageUrl;
  final Widget illustration;
  final BoxFit fit;

  const BookCoverImage({
    super.key,
    required this.imageUrl,
    required this.illustration,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return illustration;

    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, __, ___) => illustration,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return illustration;
      },
    );
  }
}
