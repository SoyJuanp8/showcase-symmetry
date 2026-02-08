import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_state.dart';

class MyArticlesBloc extends Bloc<MyArticlesEvent, MyArticlesState> {
  final GetMyArticlesUseCase _getMyArticlesUseCase;

  MyArticlesBloc(this._getMyArticlesUseCase)
      : super(const MyArticlesLoading()) {
    on<GetMyArticles>(onGetMyArticles);
  }

  void onGetMyArticles(
      GetMyArticles event, Emitter<MyArticlesState> emit) async {
    // emit(const MyArticlesLoading()); // Optional: only if we want to reset to loading on re-fetch
    final dataState = await _getMyArticlesUseCase();

    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(MyArticlesDone(dataState.data!));
    }

    if (dataState is DataFailed) {
      emit(MyArticlesError(dataState.error!));
    }
  }
}
