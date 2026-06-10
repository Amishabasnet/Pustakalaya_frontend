import 'package:pustakalaya/features/home/domain/entities/book_entity.dart';
import 'package:pustakalaya/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  static const _featured = [
    BookEntity(
      id: 'f1',
      title: 'The Alchemist',
      author: 'Paulo Coelho',
      price: 610,
      rating: 4.7,
      reviewCount: 1876,
      genre: 'Fiction',
      coverColor: '#C0392B',
      isVerified: true,
    ),
    BookEntity(
      id: 'f2',
      title: 'The Subtle Art of Not Giving a F*ck',
      author: 'Mark Manson',
      price: 880,
      rating: 4.6,
      reviewCount: 3120,
      genre: 'Self-Help',
      coverColor: '#E8602C',
      isVerified: true,
    ),
    BookEntity(
      id: 'f3',
      title: 'Atomic Habits',
      author: 'James Clear',
      price: 720,
      rating: 4.8,
      reviewCount: 2341,
      genre: 'Self-Help',
      coverColor: '#2E86AB',
      isVerified: true,
    ),
    BookEntity(
      id: 'f4',
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      price: 950,
      rating: 4.9,
      reviewCount: 4120,
      genre: 'History',
      coverColor: '#1A6B3C',
      isVerified: true,
    ),
    BookEntity(
      id: 'f5',
      title: 'Deep Work',
      author: 'Cal Newport',
      price: 699,
      rating: 4.6,
      reviewCount: 987,
      genre: 'Productivity',
      coverColor: '#5D3FD3',
      isVerified: true,
    ),
  ];

  static const _recentlyAdded = [
    BookEntity(
      id: 'r1',
      title: 'Atomic Habits',
      author: 'James Clear',
      price: 720,
      rating: 4.8,
      reviewCount: 2341,
      genre: 'Self-Help',
      coverColor: '#2E86AB',
      isVerified: true,
      isNew: true,
    ),
    BookEntity(
      id: 'r2',
      title: 'It Ends With Us',
      author: 'Colleen Hoover',
      price: 798,
      rating: 4.7,
      reviewCount: 2910,
      genre: 'Fiction',
      coverColor: '#7D3C98',
      isVerified: true,
      isNew: true,
    ),
    BookEntity(
      id: 'r3',
      title: 'The Psychology of Money',
      author: 'Morgan Housel',
      price: 649,
      rating: 4.7,
      reviewCount: 1654,
      genre: 'Finance',
      coverColor: '#1F618D',
      isVerified: true,
      isNew: true,
    ),
    BookEntity(
      id: 'r4',
      title: 'Think & Grow Rich',
      author: 'Napoleon Hill',
      price: 499,
      rating: 4.4,
      reviewCount: 2890,
      genre: 'Finance',
      coverColor: '#B7950B',
      isVerified: false,
      isNew: true,
    ),
  ];

  @override
  Future<List<BookEntity>> getFeaturedBooks() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _featured;
  }

  @override
  Future<List<BookEntity>> getRecentlyAddedBooks() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _recentlyAdded;
  }

  @override
  Future<List<String>> getGenres() async => [
    'All',
    'Fiction',
    'Self-Help',
    'Finance',
    'History',
    'Productivity',
    'Science',
  ];
}
