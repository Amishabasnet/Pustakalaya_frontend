import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';

abstract class HomeRepository {
  Future<List<BookEntity>> getFeaturedBooks();
  Future<List<BookEntity>> getRecentlyAddedBooks();
  Future<List<String>> getGenres();
}
