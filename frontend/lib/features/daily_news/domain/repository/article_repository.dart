import 'dart:io';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class ArticleRepository {
  // API methods
  Future<DataState<List<ArticleEntity>>> getNewsArticles();
  Future<DataState<List<ArticleEntity>>> searchArticles(String query);

  // Database methods
  Future<List<ArticleEntity>> getSavedArticles();

  Future<void> saveArticle(ArticleEntity article);

  Future<void> removeArticle(ArticleEntity article);

  // My Articles (User created)
  Future<DataState<List<ArticleEntity>>> getMyArticles(String userId);

  Future<void> saveMyArticle(ArticleEntity article);

  Future<void> editMyArticle(ArticleEntity article);

  Future<void> deleteMyArticle(ArticleEntity article);

  Future<String> uploadImage(File file, String path);
}
