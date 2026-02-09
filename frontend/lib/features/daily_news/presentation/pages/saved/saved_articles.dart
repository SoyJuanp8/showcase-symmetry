import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../widgets/molecules/bookmark_item.dart';
import '../../widgets/atoms/fade_in_up.dart';

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
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          toolbarHeight: 60,
          centerTitle: true,
          title: const FadeInUp(
            delay: Duration(milliseconds: 100),
            child: Text(
              'Bookmarks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: FadeInUp(
          delay: const Duration(milliseconds: 300),
          child: _buildSavedList(context),
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
              return Dismissible(
                key: Key(article.url ?? index.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  context.read<LocalArticleBloc>().add(RemoveArticle(article));
                  _showSimpleSnackBar(context, 'Removed from favorites');
                },
                child: BookmarkItem(
                  article: article,
                  onTap: () {
                    Navigator.pushNamed(context, '/ArticleDetails',
                        arguments: article);
                  },
                  onRemove: () {
                    context
                        .read<LocalArticleBloc>()
                        .add(RemoveArticle(article));
                    _showSimpleSnackBar(context, 'Removed from favorites');
                  },
                ),
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
