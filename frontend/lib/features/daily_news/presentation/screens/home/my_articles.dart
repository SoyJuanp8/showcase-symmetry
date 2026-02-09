import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/article/remote/remote_article_bloc.dart';
import '../../bloc/article/remote/remote_article_state.dart';
import '../../widgets/organisms/home_app_bar.dart';
import '../../widgets/organisms/featured_news_widget.dart';
import '../../widgets/organisms/recent_news_widget.dart';
import '../../widgets/organisms/news_stories_widget.dart';

import '../../widgets/atoms/fade_in_up.dart';

class MyArticlesPage extends StatelessWidget {
  MyArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
        builder: (_, state) {
          if (state is RemoteArticlesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RemoteArticlesError) {
            return Center(
                child:
                    Text('Error: ${state.error?.message ?? "Unknown Error"}'));
          }
          if (state is RemoteArticlesDone) {
            final articles = state.articles ?? [];

            if (articles.isEmpty) {
              return const Center(child: Text("No articles found"));
            }

            final themeBrightness = Theme.of(context).brightness;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: NewsStoriesWidget(
                      key: ValueKey('stories_$themeBrightness'),
                      articles: articles,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: FeaturedNewsWidget(
                      key: ValueKey('featured_$themeBrightness'),
                      articles: articles,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: RecentNewsWidget(
                      key: ValueKey('recent_$themeBrightness'),
                      articles: articles,
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
