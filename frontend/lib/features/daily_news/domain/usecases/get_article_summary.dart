import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetArticleSummaryUseCase implements UseCase<DataState<String>, String> {
  final ArticleRepository _articleRepository;

  GetArticleSummaryUseCase(this._articleRepository);

  @override
  Future<DataState<String>> call({String? params}) {
    return _articleRepository.summarizeArticle(params!);
  }
}
