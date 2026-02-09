import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetMyArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, String> {
  final ArticleRepository _articleRepository;

  GetMyArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call({String? params}) async {
    return _articleRepository.getMyArticles(params!);
  }
}
