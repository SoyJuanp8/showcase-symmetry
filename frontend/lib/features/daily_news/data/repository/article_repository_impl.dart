import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final AppDatabase _appDatabase;
  ArticleRepositoryImpl(this._appDatabase);

  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
    // Phase 2.1: Always use mock data for now
    return DataSuccess(_getMockArticles());
  }

  List<ArticleModel> _getMockArticles() {
    return [
      const ArticleModel(
          id: 1,
          title: 'Symmetry Revolutionizes Mobile News Experience',
          author: 'John Doe',
          description:
              'A deep dive into how Symmetry is changing the game for mobile news consumers worldwide.',
          urlToImage:
              'https://images.unsplash.com/photo-1504711434969-e33886168f5c?q=80&w=2070&auto=format&fit=crop',
          publishedAt: '2026-02-08T12:00:00Z',
          category: 'Tech'),
      const ArticleModel(
          id: 2,
          title: 'Global Markets Reach Record Highs',
          author: 'Jane Smith',
          description:
              'Financial markets across the globe see unprecedented growth as new trade agreements are signed.',
          urlToImage:
              'https://images.unsplash.com/photo-1611974714851-48206138473c?q=80&w=2070&auto=format&fit=crop',
          publishedAt: '2026-02-07T10:30:00Z',
          category: 'Business'),
      const ArticleModel(
          id: 3,
          title: 'The Future of Sustainable Architecture',
          author: 'Alex River',
          description:
              'Architects are finding new ways to build eco-friendly skyscrapers using recycled materials.',
          urlToImage:
              'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2070&auto=format&fit=crop',
          publishedAt: '2026-02-06T15:45:00Z',
          category: 'Design'),
      const ArticleModel(
          id: 4,
          title: 'New Health Breakthrough in Longevity',
          author: 'Dr. Sarah Lee',
          description:
              'Scientists discover a new compound that could potentially slow down the aging process.',
          urlToImage:
              'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?q=80&w=2070&auto=format&fit=crop',
          publishedAt: '2026-02-05T08:15:00Z',
          category: 'Health'),
    ];
  }

  @override
  Future<List<ArticleModel>> getSavedArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _appDatabase.articleDAO
        .deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO
        .insertArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<DataState<List<ArticleModel>>> getMyArticles() {
    throw UnimplementedError();
  }

  @override
  Future<void> saveMyArticle(ArticleEntity article) {
    throw UnimplementedError();
  }
}
