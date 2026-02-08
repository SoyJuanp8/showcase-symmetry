import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetMyArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, void> {
  final ArticleRepository _articleRepository;

  GetMyArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call({void params}) async {
    // MOCK DATA IMPLEMENTATION
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final mockArticles = [
      const ArticleEntity(
        id: 1,
        author: 'Juan Forero (Mock)',
        title: 'My First Mock Article',
        description:
            'This is a description for the mock article to test the UI.',
        url: '',
        urlToImage: 'https://via.placeholder.com/150',
        publishedAt: '2026-02-08T15:00:00Z',
        content: 'Content of the mock article...',
      ),
      const ArticleEntity(
        id: 2,
        author: 'Symmetry Team',
        title: 'Welcome to Symmetry',
        description: 'This app is going to be awesome.',
        url: '',
        urlToImage: 'https://via.placeholder.com/150',
        publishedAt: '2026-02-08T16:00:00Z',
        content: 'More mock content...',
      ),
    ];

    return DataSuccess(mockArticles);
    // return _articleRepository.getMyArticles(); // We will switch to this later
  }
}
