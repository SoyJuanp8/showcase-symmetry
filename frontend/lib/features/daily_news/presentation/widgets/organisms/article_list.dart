import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/molecules/my_article_card.dart';

class ArticleList extends StatelessWidget {
  final List<ArticleEntity>? articles;
  final bool? isRemovable;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;

  const ArticleList({
    Key? key,
    this.articles,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (articles == null || articles!.isEmpty) {
      return const Center(child: Text('No articles found'));
    }

    return ListView.builder(
      itemCount: articles!.length,
      itemBuilder: (context, index) {
        return MyArticleCard(
          article: articles![index],
          isRemovable: isRemovable,
          onRemove: onRemove,
          onArticlePressed: onArticlePressed,
        );
      },
    );
  }
}
