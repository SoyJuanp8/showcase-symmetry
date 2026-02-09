import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class AskArticleQuestionUseCase
    implements UseCase<DataState<String>, Map<String, String>> {
  final ArticleRepository _articleRepository;

  AskArticleQuestionUseCase(this._articleRepository);

  @override
  Future<DataState<String>> call({Map<String, String>? params}) {
    return _articleRepository.answerArticleQuestion(
      params!['content']!,
      params['question']!,
    );
  }
}
