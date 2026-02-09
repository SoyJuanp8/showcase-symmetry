import 'dart:io';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class MyArticlesEvent {
  const MyArticlesEvent();
}

class GetMyArticles extends MyArticlesEvent {
  const GetMyArticles();
}

class SaveMyArticle extends MyArticlesEvent {
  final ArticleEntity article;
  final File? imageFile;
  const SaveMyArticle(this.article, {this.imageFile});
}
