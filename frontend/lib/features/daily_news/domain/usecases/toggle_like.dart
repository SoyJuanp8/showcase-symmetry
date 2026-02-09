import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class ToggleLikeParams {
  final ArticleEntity article;
  final String userId;
  ToggleLikeParams({required this.article, required this.userId});
}

class ToggleLikeUseCase implements UseCase<void, ToggleLikeParams> {
  final ArticleRepository _articleRepository;

  ToggleLikeUseCase(this._articleRepository);

  @override
  Future<void> call({ToggleLikeParams? params}) {
    return _articleRepository.toggleLike(params!.article, params.userId);
  }
}
