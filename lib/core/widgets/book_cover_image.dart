import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';

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
      errorBuilder: (_, error, __) {
        debugPrint('[BookCoverImage] failed to load "$url": $error');
        return illustration;
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return illustration;
      },
    );
  }
}
