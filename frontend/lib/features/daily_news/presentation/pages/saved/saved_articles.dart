import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../widgets/molecules/bookmark_item.dart';

class SavedArticlesPage extends StatefulWidget {
  const SavedArticlesPage({super.key});

  @override
  State<SavedArticlesPage> createState() => _SavedArticlesPageState();
}

class _SavedArticlesPageState extends State<SavedArticlesPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            toolbarHeight: 80,
            title: const Text(
              'Bookmarks',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.swap_vert, color: theme.primaryColor),
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TabBar(
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF3A4A7D),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: theme.textTheme.titleLarge?.color,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  tabs: const [
                    Tab(
                      height: 38,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Saved'),
                      ),
                    ),
                    Tab(
                      height: 38,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Categories'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSavedList(context),
              const Center(child: Text('Categories View Coming Soon')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedList(BuildContext context) {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        if (state is LocalArticlesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LocalArticlesDone) {
          final savedArticles = state.articles ?? [];

          if (savedArticles.isEmpty) {
            return const Center(child: Text("No saved articles yet."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: savedArticles.length,
            separatorBuilder: (context, index) => const Divider(height: 40),
            itemBuilder: (context, index) {
              final article = savedArticles[index];
              return BookmarkItem(
                article: article,
                onTap: () {
                  Navigator.pushNamed(context, '/ArticleDetails',
                      arguments: article);
                },
                onRemove: () {
                  context.read<LocalArticleBloc>().add(RemoveArticle(article));
                  _showSimpleSnackBar(context, 'Removed from favorites');
                },
              );
            },
          );
        }

        return const Center(child: Text("Error loading bookmarks"));
      },
    );
  }

  void _showSimpleSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
