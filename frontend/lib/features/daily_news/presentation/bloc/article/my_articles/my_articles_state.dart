import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class MyArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final DioException? error;

  const MyArticlesState({this.articles, this.error});

  @override
  List<Object?> get props => [articles, error];
}

class MyArticlesLoading extends MyArticlesState {
  const MyArticlesLoading();
}

class MyArticlesDone extends MyArticlesState {
  const MyArticlesDone(List<ArticleEntity> article) : super(articles: article);
}

class MyArticlesError extends MyArticlesState {
  const MyArticlesError(DioException error) : super(error: error);
}

class MyArticlesActionSuccess extends MyArticlesState {
  const MyArticlesActionSuccess();
}
