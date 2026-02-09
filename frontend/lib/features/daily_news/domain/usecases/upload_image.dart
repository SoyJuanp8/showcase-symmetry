import 'dart:io';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class UploadImageUseCase implements UseCase<String, UploadImageParams> {
  final ArticleRepository _articleRepository;

  UploadImageUseCase(this._articleRepository);

  @override
  Future<String> call({UploadImageParams? params}) {
    return _articleRepository.uploadImage(params!.file, params.path);
  }
}

class UploadImageParams {
  final File file;
  final String path;

  UploadImageParams({required this.file, required this.path});
}
