import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_my_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_state.dart';

class MyArticlesBloc extends Bloc<MyArticlesEvent, MyArticlesState> {
  final GetMyArticlesUseCase _getMyArticlesUseCase;
  final SaveMyArticleUseCase _saveMyArticleUseCase;

  MyArticlesBloc(this._getMyArticlesUseCase, this._saveMyArticleUseCase)
      : super(const MyArticlesLoading()) {
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
      await _saveMyArticleUseCase(params: event.article);
      emit(const MyArticlesActionSuccess());
    } catch (e) {
      // In a real app, we'd map this to a DioException or similar
      // For now, let's emit a generic error state
      emit(MyArticlesError(DioException(
        requestOptions: RequestOptions(),
        error: e,
        message: e.toString(),
      )));
    }
  }
}
