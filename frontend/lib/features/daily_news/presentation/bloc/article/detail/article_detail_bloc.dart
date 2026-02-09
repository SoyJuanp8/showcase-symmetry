import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/add_comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article_summary.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/ask_article_question.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article_stream.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/toggle_like.dart';
import '../../../../../../core/resources/data_state.dart';
import 'article_detail_event.dart';
import 'article_detail_state.dart';

class ArticleDetailBloc extends Bloc<ArticleDetailEvent, ArticleDetailState> {
  final GetArticleStreamUseCase _getArticleStreamUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase;
  final AddCommentUseCase _addCommentUseCase;
  final GetArticleSummaryUseCase _getArticleSummaryUseCase;
  final AskArticleQuestionUseCase _askArticleQuestionUseCase;

  ArticleDetailBloc(
    this._getArticleStreamUseCase,
    this._toggleLikeUseCase,
    this._addCommentUseCase,
    this._getArticleSummaryUseCase,
    this._askArticleQuestionUseCase,
  ) : super(const ArticleDetailLoading()) {
    on<GetArticleDetail>(_onGetArticleDetail);
    on<ToggleLikeArticle>(_onToggleLikeArticle);
    on<AddCommentArticle>(_onAddCommentArticle);
    on<GenerateSummary>(_onGenerateSummary);
    on<AskArticleQuestion>(_onAskArticleQuestion);
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

  void _onGenerateSummary(
      GenerateSummary event, Emitter<ArticleDetailState> emit) async {
    if (state.article == null) return;

    emit(state.copyWith(isSummarizing: true, summaryError: null));

    final dataState = await _getArticleSummaryUseCase(params: event.content);

    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(state.copyWith(
          summary: dataState.data,
          isSummarizing: false,
          clearSummaryError: true));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(
          isSummarizing: false,
          summaryError: dataState.error?.message ?? 'Unknown error'));
    }
  }

  void _onAskArticleQuestion(
      AskArticleQuestion event, Emitter<ArticleDetailState> emit) async {
    if (state.article == null) return;

    emit(state.copyWith(
      isAskingQuestion: true,
      clearQuestionError: true,
      questionAnswer: null,
    ));

    final dataState = await _askArticleQuestionUseCase(params: {
      'content': state.article!.content ?? '',
      'question': event.question,
    });

    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(state.copyWith(
        questionAnswer: dataState.data,
        isAskingQuestion: false,
        clearQuestionError: true,
      ));
    } else if (dataState is DataFailed) {
      emit(state.copyWith(
        isAskingQuestion: false,
        questionError: dataState.error?.message ?? 'Unknown error',
      ));
    }
  }
}
