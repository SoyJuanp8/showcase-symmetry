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
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          toolbarHeight: 60,
          centerTitle: true,
          title: const Text(
            'Bookmarks',
            style: TextStyle(
              fontSize: 24,
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
        ),
        body: _buildSavedList(context),
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
