import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import '../../../../domain/entities/article.dart';

abstract class ArticleDetailState extends Equatable {
  final ArticleEntity? article;
  final DioException? error;

  // Summary fields
  final String? summary;
  final bool isSummarizing;
  final String? summaryError;

  // Question fields
  final String? questionAnswer;
  final bool isAskingQuestion;
  final String? questionError;

  const ArticleDetailState({
    this.article,
    this.error,
    this.summary,
    this.isSummarizing = false,
    this.summaryError,
    this.questionAnswer,
    this.isAskingQuestion = false,
    this.questionError,
  });

  @override
  List<Object?> get props => [
        article,
        error,
        summary,
        isSummarizing,
        summaryError,
        questionAnswer,
        isAskingQuestion,
        questionError,
      ];

  // Helper method to "clear" nullables if needed
  ArticleDetailState copyWith({
    ArticleEntity? article,
    DioException? error,
    String? summary,
    bool? isSummarizing,
    String? summaryError,
    bool clearSummaryError = false,
    String? questionAnswer,
    bool? isAskingQuestion,
    String? questionError,
    bool clearQuestionError = false,
  }) {
    return ArticleDetailLoaded(
      article ?? this.article!,
      summary: summary ?? this.summary,
      isSummarizing: isSummarizing ?? this.isSummarizing,
      summaryError:
          clearSummaryError ? null : (summaryError ?? this.summaryError),
      questionAnswer: questionAnswer ?? this.questionAnswer,
      isAskingQuestion: isAskingQuestion ?? this.isAskingQuestion,
      questionError:
          clearQuestionError ? null : (questionError ?? this.questionError),
    );
  }
}

class ArticleDetailLoading extends ArticleDetailState {
  const ArticleDetailLoading();
}

class ArticleDetailLoaded extends ArticleDetailState {
  const ArticleDetailLoaded(
    ArticleEntity article, {
    String? summary,
    bool isSummarizing = false,
    String? summaryError,
    String? questionAnswer,
    bool isAskingQuestion = false,
    String? questionError,
  }) : super(
          article: article,
          summary: summary,
          isSummarizing: isSummarizing,
          summaryError: summaryError,
          questionAnswer: questionAnswer,
          isAskingQuestion: isAskingQuestion,
          questionError: questionError,
        );
}

class ArticleDetailError extends ArticleDetailState {
  const ArticleDetailError(DioException error) : super(error: error);
}
