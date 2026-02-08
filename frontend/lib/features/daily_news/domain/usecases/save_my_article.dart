import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class SaveMyArticleUseCase implements UseCase<void, ArticleEntity> {
  final ArticleRepository _articleRepository;

  SaveMyArticleUseCase(this._articleRepository);

  @override
  Future<void> call({ArticleEntity? params}) async {
    // MOCK IMPLEMENTATION
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay
    print("Mock saving article: ${params?.title}");
    return;
    // return _articleRepository.saveMyArticle(params!); // We will switch to this later
  }
}
