import 'package:flutter/material.dart';
import '../../../domain/entities/article.dart';

class NewsStoriesWidget extends StatelessWidget {
  final List<ArticleEntity> articles;

  const NewsStoriesWidget({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    // Only show unique sources for stories (like IG people)
    final uniqueSourceArticles = _getUniqueSourceArticles(articles);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Stories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: uniqueSourceArticles.length,
            itemBuilder: (context, index) {
              final article = uniqueSourceArticles[index];
              return _buildStoryCircle(
                  context, article, index, uniqueSourceArticles);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoryCircle(BuildContext context, ArticleEntity article,
      int index, List<ArticleEntity> articles) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/StoryView',
        arguments: {
          'articles': articles,
          'initialIndex': index,
        },
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF833AB4), Color(0xFFF77737)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    article.urlToImage ?? 'https://via.placeholder.com/150',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 70,
              child: Text(
                article.source?.name ?? article.author ?? 'Symmetry',
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ArticleEntity> _getUniqueSourceArticles(List<ArticleEntity> articles) {
    final Map<String, ArticleEntity> seenSources = {};
    for (var article in articles) {
      final sourceKey = article.source?.name ?? article.author ?? 'Symmetry';
      if (!seenSources.containsKey(sourceKey)) {
        seenSources[sourceKey] = article;
      }
    }
    return seenSources.values.toList();
  }
}
