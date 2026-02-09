import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_my_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_state.dart';

import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_image.dart';

class MyArticlesBloc extends Bloc<MyArticlesEvent, MyArticlesState> {
  final GetMyArticlesUseCase _getMyArticlesUseCase;
  final SaveMyArticleUseCase _saveMyArticleUseCase;
  final UploadImageUseCase _uploadImageUseCase;

  MyArticlesBloc(
    this._getMyArticlesUseCase,
    this._saveMyArticleUseCase,
    this._uploadImageUseCase,
  ) : super(const MyArticlesLoading()) {
    on<GetMyArticles>(onGetMyArticles);
    on<SaveMyArticle>(onSaveMyArticle);
  }

  void onGetMyArticles(
      GetMyArticles event, Emitter<MyArticlesState> emit) async {
    final dataState = await _getMyArticlesUseCase();

    if (dataState is DataSuccess && dataState.data != null) {
      emit(MyArticlesDone(dataState.data!));
    }

    if (dataState is DataFailed) {
      emit(MyArticlesError(dataState.error!));
    }
  }

  void onSaveMyArticle(
      SaveMyArticle event, Emitter<MyArticlesState> emit) async {
    emit(const MyArticlesLoading());
    try {
      var articleToSave = event.article;

      if (event.imageFile != null) {
        final path = 'articles/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imageUrl = await _uploadImageUseCase(
            params: UploadImageParams(file: event.imageFile!, path: path));

        articleToSave = event.article.copyWith(urlToImage: imageUrl);
      }

      await _saveMyArticleUseCase(params: articleToSave);
      emit(const MyArticlesActionSuccess());
    } catch (e) {
      emit(MyArticlesError(DioException(
        requestOptions: RequestOptions(),
        error: e,
        message: e.toString(),
      )));
    }
  }
}
