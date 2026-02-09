import 'package:flutter/material.dart';
import '../../../domain/entities/article.dart';
import '../molecules/trendy_card.dart';

class TrendyNewsSection extends StatelessWidget {
  final List<ArticleEntity> articles;

  const TrendyNewsSection({
    super.key,
    required this.articles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Trendy news'),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              final tag =
                  'trendy_section_${article.url ?? article.title ?? ''}_$index';
              return TrendyCard(
                article: article,
                heroTag: tag,
                onArticlePressed: (article) {
                  Navigator.pushNamed(
                    context,
                    '/ArticleDetails',
                    arguments: {
                      'article': article,
                      'heroTag': tag,
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('See all'),
          ),
        ],
      ),
    );
  }
}
