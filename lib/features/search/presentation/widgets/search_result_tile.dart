import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

class SearchResultTile extends StatelessWidget {
  final BookEntity book;
  final String query;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.book,
    required this.query,
    required this.onTap,
  });

  Color get _coverColor {
    final hex = book.coverColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  bool get _isDark {
    final c = _coverColor;
    return (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) / 255 < 0.55;
  }

  // Highlight matching text in query
  List<TextSpan> _highlight(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }
    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    int idx;
    while ((idx = lower.indexOf(q, start)) != -1) {
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + q.length),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
      start = idx + q.length;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final textOnCover = _isDark ? Colors.white : Colors.black87;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Mini cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 48,
                height: 62,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _coverColor,
                      Color.lerp(_coverColor, Colors.black, 0.28)!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Container(width: 5, color: Colors.black.withOpacity(0.2)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 7, 5, 7),
                      child: Text(
                        book.title,
                        style: GoogleFonts.lato(
                          fontSize: 6.5,
                          fontWeight: FontWeight.w800,
                          color: textOnCover,
                          height: 1.25,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                      children: _highlight(book.title, query),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        book.rating.toStringAsFixed(1),
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NRs. ${book.price.toStringAsFixed(0)}',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFFCCC5BB),
            ),
          ],
        ),
      ),
    );
  }
}
