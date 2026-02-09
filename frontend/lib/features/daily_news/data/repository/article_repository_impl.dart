import 'dart:io';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firebase_article_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firebase_storage_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final FirebaseArticleService _firebaseArticleService;
  final FirebaseStorageService _firebaseStorageService;
  final AppDatabase _appDatabase;

  // In-memory cache for client-side search
  List<ArticleModel> _cachedApiArticles = [];

  ArticleRepositoryImpl(
    this._newsApiService,
    this._firebaseArticleService,
    this._firebaseStorageService,
    this._appDatabase,
  );

  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
    try {
      // 1. Fetch from NewsAPI (External)
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      List<ArticleModel> apiArticles = [];
      if (httpResponse.response.statusCode == 200) {
        // Filter out articles without images or with default image
        apiArticles = httpResponse.data.articles
            .where((article) =>
                article.urlToImage != null &&
                article.urlToImage!.isNotEmpty &&
                article.urlToImage != kDefaultImage)
            .toList();
        _cachedApiArticles = apiArticles; // Save to cache
      }

      // 2. Fetch from Firebase (Community)
      final communityArticles = await _firebaseArticleService.getArticles();

      // 3. Merge Logic: Community articles first, then API articles
      final combinedArticles = [...communityArticles, ...apiArticles];

      return DataSuccess(combinedArticles);
    } on DioException catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(),
        error: e,
        type: DioExceptionType.unknown,
      ));
    }
  }

  @override
  Future<DataState<List<ArticleModel>>> searchArticles(String query) async {
    try {
      final q = query.toLowerCase();

      // 1. Search Cached API Articles (Client-side)
      final localApiMatches = _cachedApiArticles.where((article) {
        final title = article.title?.toLowerCase() ?? '';
        final description = article.description?.toLowerCase() ?? '';
        return title.contains(q) || description.contains(q);
      }).toList();

      // 2. Fetch from Firebase (Local/Community) & Filter
      final communityArticles =
          await _firebaseArticleService.searchArticles(query);

      // 3. Merge: Community matches first, then API cache matches
      final combinedArticles = [...communityArticles, ...localApiMatches];

      return DataSuccess(combinedArticles);
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(),
        error: e,
        type: DioExceptionType.unknown,
      ));
    }
  }

  @override
  Future<List<ArticleModel>> getSavedArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _appDatabase.articleDAO
        .deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.insertArticle(ArticleModel.fromEntity(
        article.copyWith(savedAt: DateTime.now().toIso8601String())));
  }

  @override
  Future<DataState<List<ArticleModel>>> getMyArticles() async {
    try {
      final articles = await _firebaseArticleService.getArticles();
      return DataSuccess(articles);
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(),
        error: e,
        type: DioExceptionType.unknown,
      ));
    }
  }

  @override
  Future<void> saveMyArticle(ArticleEntity article) {
    return _firebaseArticleService
        .publishArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<String> uploadImage(File file, String path) {
    return _firebaseStorageService.uploadImage(file, path);
  }
}
