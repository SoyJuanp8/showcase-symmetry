import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/article/remote/remote_article_bloc.dart';
import '../../bloc/article/remote/remote_article_event.dart';
import '../../bloc/article/remote/remote_article_state.dart';
import '../../widgets/molecules/discover_search_bar.dart';
import '../../widgets/molecules/trendy_card.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Molecule: Search Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: DiscoverSearchBar(
                    onSearch: (query) {
                      if (query.isNotEmpty) {
                        context
                            .read<RemoteArticlesBloc>()
                            .add(SearchArticles(query));
                      } else {
                        context
                            .read<RemoteArticlesBloc>()
                            .add(const GetArticles());
                      }
                    },
                  ),
                ),

                // Organism: Trendy News (Grid)
                Expanded(
                  child: _buildBody(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(RemoteArticlesState state) {
    if (state is RemoteArticlesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is RemoteArticlesError) {
      return const Center(child: Icon(Icons.refresh));
    }
    if (state is RemoteArticlesDone) {
      final articles = state.articles ?? [];
      if (articles.isEmpty) {
        return const Center(child: Text('No articles found'));
      }
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.6, // Adjusted to prevent overflow
        ),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return TrendyCard(
            article: articles[index],
            onArticlePressed: (article) => _onArticlePressed(context, article),
          );
        },
      );
    }
    return const SizedBox();
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }
}
