import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class AddCommentParams {
  final ArticleEntity article;
  final CommentEntity comment;
  AddCommentParams({required this.article, required this.comment});
}

class AddCommentUseCase implements UseCase<void, AddCommentParams> {
  final ArticleRepository _articleRepository;

  AddCommentUseCase(this._articleRepository);

  @override
  Future<void> call({AddCommentParams? params}) {
    return _articleRepository.addComment(params!.article, params.comment);
  }
}
