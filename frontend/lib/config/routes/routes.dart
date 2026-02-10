import 'package:flutter/material.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/screens/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/screens/home/story_view_page.dart';
import '../../features/auth/presentation/screens/login/login.dart';
import '../../features/auth/presentation/screens/register/register.dart';
import '../../features/daily_news/presentation/screens/profile/profile_page.dart';
import '../../features/daily_news/presentation/screens/saved/saved_articles.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        // Since home is handled in main.dart based on AuthState,
        // we can return a simple placeholder or the initial splash.
        return _materialRoute(const Scaffold());

      case '/ArticleDetails':
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _materialRoute(ArticleDetailsView(
            article: args['article'] as ArticleEntity,
            heroTag: args['heroTag'] as String?,
          ));
        }
        return _materialRoute(
            ArticleDetailsView(article: settings.arguments as ArticleEntity));

      case '/SavedArticles':
        return _materialRoute(const SavedArticlesPage());

      case '/StoryView':
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(StoryViewPage(
          articles: args['articles'] as List<ArticleEntity>,
          initialIndex: args['initialIndex'] as int,
        ));

      case '/Login':
        return _materialRoute(const LoginPage());

      case '/Register':
        return _materialRoute(const RegisterPage());

      case '/Profile':
        return _materialRoute(const ProfilePage());

      default:
        return _materialRoute(const Scaffold());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
