import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/main/main_layout.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_event.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RemoteArticlesBloc>(
          create: (context) => sl()..add(const GetArticles()),
        ),
        BlocProvider<MyArticlesBloc>(
          create: (context) => sl()..add(const GetMyArticles()),
        ),
        BlocProvider<LocalArticleBloc>(
          create: (context) => sl()..add(const GetSavedArticles()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme(),
        darkTheme: darkTheme(),
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        home: const MainLayout(),
      ),
    );
  }
}
