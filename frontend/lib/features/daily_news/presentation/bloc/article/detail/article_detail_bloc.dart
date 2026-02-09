import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/add_comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article_stream.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/toggle_like.dart';
import 'article_detail_event.dart';
import 'article_detail_state.dart';

class ArticleDetailBloc extends Bloc<ArticleDetailEvent, ArticleDetailState> {
  final GetArticleStreamUseCase _getArticleStreamUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase;
  final AddCommentUseCase _addCommentUseCase;

  ArticleDetailBloc(
    this._getArticleStreamUseCase,
    this._toggleLikeUseCase,
    this._addCommentUseCase,
  ) : super(const ArticleDetailLoading()) {
    on<GetArticleDetail>(_onGetArticleDetail);
    on<ToggleLikeArticle>(_onToggleLikeArticle);
    on<AddCommentArticle>(_onAddCommentArticle);
  }

  void _onGetArticleDetail(
      GetArticleDetail event, Emitter<ArticleDetailState> emit) async {
    // Initialize with provided (API) article
    emit(ArticleDetailLoaded(event.article));

    final stream =
        await _getArticleStreamUseCase(params: event.article.socialId);
    await emit.forEach(
      stream,
      onData: (article) {
        if (article != null) {
          // If we have Firestore data, it prevails (has latest likes/comments)
          return ArticleDetailLoaded(article);
        } else {
          // If Firestore is empty (new API article), keep current state
          return state;
        }
      },
      onError: (_, __) => state,
    );
  }

  void _onToggleLikeArticle(
      ToggleLikeArticle event, Emitter<ArticleDetailState> emit) async {
    if (state.article != null) {
      await _toggleLikeUseCase(
          params:
              ToggleLikeParams(article: state.article!, userId: event.userId));
    }
  }

  void _onAddCommentArticle(
      AddCommentArticle event, Emitter<ArticleDetailState> emit) async {
    if (state.article != null) {
      await _addCommentUseCase(
          params: AddCommentParams(
              article: state.article!, comment: event.comment));
    }
  }
}
