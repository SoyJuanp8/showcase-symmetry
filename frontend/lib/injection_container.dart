import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_my_article.dart';
import 'features/daily_news/domain/usecases/edit_my_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_my_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article_stream.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/toggle_like.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/add_comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/detail/article_detail_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/navigation/navigation_bloc.dart';

import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firebase_article_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firebase_storage_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/search_article.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/login.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/register.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/logout.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/update_profile_photo.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final database = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .addMigrations([migration1to2]).build();
  sl.registerSingleton<AppDatabase>(database);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));
  sl.registerSingleton<FirebaseArticleService>(FirebaseArticleService());
  sl.registerSingleton<FirebaseStorageService>(FirebaseStorageService());
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<GoogleSignIn>(GoogleSignIn());

  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl(), sl()));

  sl.registerSingleton<ArticleRepository>(
      ArticleRepositoryImpl(sl(), sl(), sl(), sl()));

  //UseCases
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));

  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));

  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  sl.registerSingleton<GetMyArticlesUseCase>(GetMyArticlesUseCase(sl()));

  sl.registerSingleton<SaveMyArticleUseCase>(SaveMyArticleUseCase(sl()));

  sl.registerSingleton<EditMyArticleUseCase>(EditMyArticleUseCase(sl()));

  sl.registerSingleton<DeleteMyArticleUseCase>(DeleteMyArticleUseCase(sl()));

  sl.registerSingleton<UploadImageUseCase>(UploadImageUseCase(sl()));

  sl.registerSingleton<SearchArticleUseCase>(SearchArticleUseCase(sl()));

  sl.registerSingleton<GetArticleStreamUseCase>(GetArticleStreamUseCase(sl()));
  sl.registerSingleton<ToggleLikeUseCase>(ToggleLikeUseCase(sl()));
  sl.registerSingleton<AddCommentUseCase>(AddCommentUseCase(sl()));

  // Auth UseCases
  // Auth UseCases
  sl.registerSingleton<LoginUseCase>(LoginUseCase(sl()));
  sl.registerSingleton<RegisterUseCase>(RegisterUseCase(sl()));
  sl.registerSingleton<LogoutUseCase>(LogoutUseCase(sl()));
  sl.registerSingleton<SignInWithGoogleUseCase>(SignInWithGoogleUseCase(sl()));
  sl.registerSingleton<UpdateProfilePhotoUseCase>(
      UpdateProfilePhotoUseCase(sl()));

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl(), sl()));

  sl.registerFactory<MyArticlesBloc>(
      () => MyArticlesBloc(sl(), sl(), sl(), sl(), sl()));

  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));

  sl.registerFactory<AuthBloc>(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        signInWithGoogleUseCase: sl(),
        authRepository: sl(),
      ));

  sl.registerFactory<NavigationBloc>(() => NavigationBloc());

  sl.registerFactory<ArticleDetailBloc>(
      () => ArticleDetailBloc(sl(), sl(), sl()));
}
