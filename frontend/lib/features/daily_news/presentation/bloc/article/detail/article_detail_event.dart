import 'package:equatable/equatable.dart';
import '../../../../domain/entities/article.dart';
import '../../../../domain/entities/comment.dart';

abstract class ArticleDetailEvent extends Equatable {
  const ArticleDetailEvent();

  @override
  List<Object> get props => [];
}

class GetArticleDetail extends ArticleDetailEvent {
  final ArticleEntity article;
  const GetArticleDetail(this.article);

  @override
  List<Object> get props => [article];
}

class ToggleLikeArticle extends ArticleDetailEvent {
  final String userId;
  const ToggleLikeArticle(this.userId);
}

class AddCommentArticle extends ArticleDetailEvent {
  final CommentEntity comment;
  const AddCommentArticle(this.comment);
}

class GenerateSummary extends ArticleDetailEvent {
  final String content;
  const GenerateSummary(this.content);

  @override
  List<Object> get props => [content];
}

class AskArticleQuestion extends ArticleDetailEvent {
  final String question;
  const AskArticleQuestion(this.question);

  @override
  List<Object> get props => [question];
}
