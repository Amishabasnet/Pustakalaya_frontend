import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pustakalaya/features/book_detail/domain/entities/book_detail.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

BookDetail _mockDetail(BookEntity book) {
  return BookDetail(
    book: book,
    originalPrice: book.price * 1.25,
    discountPercent: 20,
    isVerifiedSeller: true,
    inStock: true,
    description:
        '${book.title} is a philosophical novel by ${book.author} that follows Santiago, an Andalusian shepherd boy. Driven by a recurring dream of hidden treasure, he leaves Spain to journey across the Sahara Desert toward the Egyptian pyramids. Along the way, he learns to read omens, listen to his heart, and fulfill his destiny.',
    returnPolicy:
        '7-day hassle-free returns on all physical books. Raise a return from the app and we\'ll arrange free pickup. Refunds process in 3–5 business days to your original payment method.',
    reviews: const [
      BookReview(
        reviewerName: 'Aarav S.',
        reviewerInitial: 'A',
        starRating: 5,
        comment:
            'Absolutely magical. Read it in one sitting – couldn\'t put it down. Arrived perfectly packed.',
      ),
      BookReview(
        reviewerName: 'Priya M.',
        reviewerInitial: 'P',
        starRating: 4,
        comment:
            'A beautifully written book. Great condition, fast delivery. Will definitely order again!',
      ),
    ],
  );
}

final selectedBookProvider = StateProvider<BookEntity?>((ref) => null);

final bookDetailProvider = Provider<BookDetail?>((ref) {
  final book = ref.watch(selectedBookProvider);
  if (book == null) return null;
  return _mockDetail(book);
});

final bookQuantityProvider = StateProvider<int>((ref) => 1);

final accordionProvider =
    StateProvider<Map<int, bool>>((ref) => {0: true, 1: false, 2: true});
