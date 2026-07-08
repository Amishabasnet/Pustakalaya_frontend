import 'package:pustakalaya/core/network/api_client.dart';
import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';
import 'package:pustakalaya/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiClient _client = ApiClient.instance;

  @override
  Future<List<BookEntity>> getFeaturedBooks() async {
    final body = await _client.get('/books/home');
    final list = (body['data']?['featured'] as List?) ?? [];
    return list
        .map((b) => BookEntity.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<BookEntity>> getRecentlyAddedBooks() async {
    final body = await _client.get('/books/home');
    final list = (body['data']?['recentlyAdded'] as List?) ?? [];
    return list
        .map((b) => BookEntity.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<String>> getGenres() async {
    final body = await _client.get('/books/filter-options');
    final list = (body['data']?['genres'] as List?) ?? [];
    return ['All', ...list.map((g) => g.toString())];
  }
}
