import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import '../../../../domain/entities/article.dart';

abstract class ArticleDetailState extends Equatable {
  final ArticleEntity? article;
  final DioException? error;

  const ArticleDetailState({this.article, this.error});

  @override
  List<Object?> get props => [article, error];
}

class ArticleDetailLoading extends ArticleDetailState {
  const ArticleDetailLoading();
}

class ArticleDetailLoaded extends ArticleDetailState {
  const ArticleDetailLoaded(ArticleEntity article) : super(article: article);
}

class ArticleDetailError extends ArticleDetailState {
  const ArticleDetailError(DioException error) : super(error: error);
}
